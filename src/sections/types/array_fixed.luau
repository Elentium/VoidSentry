--!strict
local type_node_export = require("../exports/type_node")

type TypeNode = type_node_export.typeNode

local Config = require("../shared/Config")

return function(ValueType: TypeNode, len: number)
	return {
		name = "array_fixed",
		bytes = @native function(value: { any }): number
			local total = 0
			for i = 1, len do
				local v = value[i]
				total += (typeof(ValueType.bytes) == "function" and (ValueType.bytes :: (value: any) -> number)(v) or ValueType.bytes :: number) :: number
			end
			return total
		end,

		write = @native function(b: buffer, offset: number, value: { any }): number
			if Config.VALIDATION_LEVEL >= 2 then
				if len ~= #value then
					error(`array_fixed.write: Array length ({#value}) does not match expected length ({len}).`)
				end
			end
			for i = 1, len do
				offset = ValueType.write(b, offset, value[i])
			end

			return offset
		end,

		read = @native function(b: buffer, offset: number): ({ any }, number)
			local value = table.create(len)
			for i = 1, len do
				value[i], offset = ValueType.read(b, offset)
			end
			return value, offset
		end,
	}
end
