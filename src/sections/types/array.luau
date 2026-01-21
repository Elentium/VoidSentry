local type_node_export = require("../exports/type_node")
local Config = require("../shared/Config")

type TypeNode = type_node_export.typeNode

local w_u16 = buffer.writeu16
local r_u16 = buffer.readu16

return function(ValueType: TypeNode)
	return {
		name = "array",
		bytes = @native function(value: { any }): number
			local total = 0
			for i = 1, #value do
				local v = value[i]
				total += (typeof(ValueType.bytes) == "function" and (ValueType.bytes :: (value: any) -> number)(v) or ValueType.bytes :: number) :: number
			end
			return total + 2
		end,

		write = @native function(b: buffer, offset: number, value: { any }): number
			local len = #value
			if Config.VALIDATION_LEVEL >= 2 then
				if len > 65535 then
					error(`array.write: Array length ({len}) exceeds max length (65535).`)
				end
			end
			w_u16(b, offset, len)
			offset += 2
			for i = 1, len do
				offset = ValueType.write(b, offset, value[i])
			end

			return offset
		end,

		read = @native function(b: buffer, offset: number): ({ any }, number)
			local len = r_u16(b, offset)
			offset += 2
			local value = table.create(len)
			for i = 1, len do
				value[i], offset = ValueType.read(b, offset)
			end
			return value, offset
		end,
	}
end
