local TypeSigns = require("./TypeSigns")

local w_u8 = buffer.writeu8
local w_u16 = buffer.writeu16
local w_string = buffer.writestring

-- helper function to write type signs recursively for nested types
return function(b: buffer, offset: number, typeNode: any, value: any, types: { [string]: any }): number
	local typeName = typeNode.name
	local baseType = typeName:upper()

	-- write the type sign
	local sign = TypeSigns[baseType] :: number
	w_u8(b, offset, sign)
	offset += 1

	-- if this is an enum type, write the Enum type name
	if typeName == "enum" then
		-- store the Enum type name so we can reconstruct it during deserialization
		local enumTypeName = tostring(value.EnumType) -- since Enum does not have a name property, we just use tostring which actually gives the name
		local nameLen = #enumTypeName
		w_u16(b, offset, nameLen)
		offset += 2
		w_string(b, offset, enumTypeName)
		offset += nameLen
		-- for arrays and maps in dynamic serialization, we don't write nested type signs
		-- since they always have 'any' types. BuildTypeNode will assume 'any' when reading.
	end

	return offset
end
