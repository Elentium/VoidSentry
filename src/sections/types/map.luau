local type_node_export = require("../exports/type_node")
local Config = require("../shared/Config")

type TypeNode = type_node_export.typeNode

local w_u16 = buffer.writeu16
local r_u16 = buffer.readu16

return function(KeyType: TypeNode, ValueType: TypeNode)
	return {
		name = "map",
		bytes = @native function(value: { [any]: any }): number
			local total = 0
			for k, v in value do
				total += (typeof(KeyType.bytes) == "function" and (KeyType.bytes :: (value: any) -> number)(k) or KeyType.bytes :: number) :: number
				total += (typeof(ValueType.bytes) == "function" and (ValueType.bytes :: (value: any) -> number)(v) or ValueType.bytes :: number) :: number
			end
			return total + 2
		end,

		write = @native function(b: buffer, offset: number, value: { any }): number
			local len = 0
			for _ in value do
				len += 1
			end
			if Config.VALIDATION_LEVEL >= 2 then
				if len > 65535 then
					error(`map.write: Map length ({len}) exceeds max length (65535).`)
				end
			end
			w_u16(b, offset, len)
			offset += 2
			for k, v in value do
				offset = KeyType.write(b, offset, k)
				offset = ValueType.write(b, offset, v)
			end

			return offset
		end,

		read = @native function(b: buffer, offset: number): ({ [any]: any }, number)
			local len = r_u16(b, offset)
			offset += 2
			local value = {}
			for _ = 1, len do
				local k
				k, offset = KeyType.read(b, offset)
				value[k], offset = ValueType.read(b, offset)
			end
			return value, offset
		end,
	}
end
