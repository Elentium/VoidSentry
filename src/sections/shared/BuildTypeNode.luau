local export_type_node = require("../exports/type_node")
local TypeSigns = require("./TypeSigns")
local Config = require("./Config")

type TypeNode = export_type_node.typeNode

local array = require("../types/array")
local array_tiny = require("../types/array_tiny")
local map = require("../types/map")
local read_u8 = buffer.readu8
local read_u16 = buffer.readu16
local read_string = buffer.readstring
local blen = buffer.len

-- create reverse mapping (number -> name) for deserialization
local TypeSignsReverse: { [number]: string } = {}
for name, sign in TypeSigns do
	TypeSignsReverse[sign] = name
end

-- this function builds a type node from serialized type information
-- it reads type signs from the buffer to reconstruct nested type structures
-- used during deserialization when we dont have the actual value
return function(b: buffer, offset: number): (TypeNode, number)
	-- validation: buffer bounds check
	if Config.VALIDATION_LEVEL >= 1 then
		if offset < 0 or offset >= blen(b) then
			error(`BuildTypeNode: Buffer out of bounds. Offset: {offset}, Buffer length: {blen(b)}`)
		end
	end

	local sign = read_u8(b, offset)
	offset += 1

	local typeName = TypeSignsReverse[sign]
	if not typeName then
		error(`BuildTypeNode: Invalid type sign {sign} at offset {offset - 1}. Buffer length: {buffer.len(b)}`)
	end
	local typeModule = require(`../types/{typeName:lower()}`)

	-- if it's an enum type, read the Enum type name and reconstruct the Enum type
	if typeName == "ENUM" then
		-- read the Enum type name length and name
		local nameLen = read_u16(b, offset)
		offset += 2
		local enumTypeName = read_string(b, offset, nameLen)
		offset += nameLen

		-- get the Enum type from Enum[enumTypeName]
		local enumType = Enum[enumTypeName]
		if not enumType then
			error(`BuildTypeNode: Invalid Enum type name: {enumTypeName}`)
		end

		return typeModule(enumType), offset
	-- if it's a function type (array, map, array_tiny), use 'any' for nested types in dynamic serialization
	elseif typeof(typeModule) == "function" then
		if typeModule == array or typeModule == array_tiny then
			-- in dynamic serialization, arrays always have 'any' element type
			-- no need to read nested type sign since it's always 'any'
			local anyType = require("../types/any" :: string)
			return typeModule(anyType), offset
		elseif typeModule == map then
			-- in dynamic serialization, maps always have 'any' key and value types
			-- no need to read nested type signs since they're always 'any'
			local anyType = require("../types/any" :: string)
			return typeModule(anyType, anyType), offset
		end
	end

	-- simple type, just return the module
	return typeModule, offset
end
