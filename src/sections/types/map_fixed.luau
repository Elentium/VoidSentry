--!strict
local type_node_export = require("../exports/type_node")

type TypeNode = type_node_export.typeNode

local Config = require("../shared/Config")

return function(KeyType: TypeNode, ValueType: TypeNode, len: number)
	return {
		name = "map_fixed",
		bytes = @native function(value: { [any]: any }): number
			local total = 0
			for k, v in value do
				total += (typeof(KeyType.bytes) == "function" and (KeyType.bytes :: (value: any) -> number)(k) or KeyType.bytes :: number) :: number
				total += (typeof(ValueType.bytes) == "function" and (ValueType.bytes :: (value: any) -> number)(v) or ValueType.bytes :: number) :: number
			end
			return total
		end,

		write = @native function(b: buffer, offset: number, value: { any }): number
			if Config.VALIDATION_LEVEL >= 2 then
				local count = 0
				for _ in value do
					count += 1
				end
				if len ~= count then
					error(`map_fixed.write: Map length ({count}) does not match expected length ({len}).`)
				end
			end
			for k, v in value do
				offset = KeyType.write(b, offset, k)
				offset = ValueType.write(b, offset, v)
			end

			return offset
		end,

		read = @native function(b: buffer, offset: number): ({ [any]: any }, number)
			local value = {}
			for i = 1, len do
				local k
				k, offset = KeyType.read(b, offset)
				value[k], offset = ValueType.read(b, offset)
			end
			return value, offset
		end,
	}
end
