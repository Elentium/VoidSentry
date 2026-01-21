local GetElementType = require("../shared/GetElementType")
local TypeSigns = require("../shared/TypeSigns")
local export_type_node = require("../exports/type_node")
local GetElementNode = require("../shared/GetElementNode")

type TypeNode = export_type_node.typeNode

local w_u8 = buffer.writeu8
local w_u16 = buffer.writeu16
local w_string = buffer.writestring

local mapModule = require("./map")
local arrayModule = require("./array")
local array_tinyModule = require("./array_tiny")
local enumModule = require("./enum")

local anyType
anyType = {
	name = "any",
	bytes = function(v: any): number
		local t = GetElementType(v)

		-- for arrays and maps, use Any type for elements to support mixed types
		local mod: TypeNode
		if t == "ARRAY" then
			mod = arrayModule(anyType)
		elseif t == "ARRAY_TINY" then
			mod = array_tinyModule(anyType)
		elseif t == "MAP" then
			mod = mapModule(anyType, anyType)
		elseif t == "ENUM" then
			mod = enumModule(v.EnumType)
		else
			mod = GetElementNode(require(`./{t:lower()}`), v)
		end

		local baseSize = typeof(mod.bytes) == "function" and (mod.bytes :: (value: any) -> number)(v)
			or mod.bytes :: number

		-- calculate total size including type signs
		local typeSignBytes = 1 -- main type sign

		-- for Enum types, we need to also store the Enum type name (2 bytes length + string length)
		if t == "ENUM" then
			local enumTypeName = tostring(v.EnumType)
			typeSignBytes += 2 + #enumTypeName -- 2 bytes for length, then string bytes
		end

		-- for arrays and maps in dynamic serialization, we don't write nested type signs
		-- since they always have 'any' types

		return baseSize + typeSignBytes
	end,
	write = @native function(b: buffer, offset: number, value: any): number
		local t = GetElementType(value)

		-- for arrays and maps, use Any type for elements to support mixed types
		local mod: TypeNode
		if t == "ARRAY" then
			mod = arrayModule(anyType)
		elseif t == "ARRAY_TINY" then
			mod = array_tinyModule(anyType)
		elseif t == "MAP" then
			mod = mapModule(anyType, anyType)
		elseif t == "ENUM" then
			mod = enumModule(value.EnumType)
		else
			mod = GetElementNode(require(`./{t:lower()}`), value)
		end

		-- write the nested type sign first
		local typeName = mod.name
		local baseType = typeName:upper()
		local sign = TypeSigns[baseType] :: number
		w_u8(b, offset, sign)
		offset += 1

		-- for Enum types, write the Enum type name so BuildTypeNode can reconstruct it
		if t == "ENUM" then
			local enumTypeName = tostring(value.EnumType)
			local nameLen = #enumTypeName
			w_u16(b, offset, nameLen)
			offset += 2
			w_string(b, offset, enumTypeName)
			offset += nameLen
		end

		-- for arrays and maps in dynamic serialization, we don't write nested type signs
		-- since they always have 'any' types. BuildTypeNode will assume 'any' when reading.

		-- write the actual value
		offset = mod.write(b, offset, value)
		return offset
	end,
	read = @native function(b: buffer, offset: number): (any, number)
		-- build the type node recursively
		local BuildTypeNode = require("../shared/BuildTypeNode")
		local mod: TypeNode
		mod, offset = BuildTypeNode(b, offset) -- BuildTypeNode reads the type sign and advances offset
		-- read the value
		local value: any
		value, offset = mod.read(b, offset)
		return value, offset
	end,
}

return anyType
