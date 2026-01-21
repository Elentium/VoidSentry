--!strict
local type_node_export = require("../exports/type_node")

local w_u8 = buffer.writeu8
local r_u8 = buffer.readu8

type TypeNode = type_node_export.typeNode
return function(Type: TypeNode)
	return {
		name = "optional",
		bytes = function(value: any?): number
			if value == nil then
				return 1
			end
			return (
				typeof(Type.bytes) == "function" and (Type.bytes :: (value: any) -> number)(value)
				or Type.bytes :: number
			) + 1
		end,
		write = @native function(b: buffer, offset: number, value: any?): number
			w_u8(b, offset, value == nil and 1 or 0)
			offset += 1
			if value ~= nil then
				offset = Type.write(b, offset, value)
			end
			return offset
		end,
		read = @native function(b: buffer, offset: number): (any?, number)
			local exists = r_u8(b, offset)
			if exists == 1 then
				return nil, offset + 1
			end
			return Type.read(b, offset + 1)
		end,
	}
end
