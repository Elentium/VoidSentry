local type_node_export = require("../exports/type_node")

type TypeNode = type_node_export.typeNode

return function<T>(Struct: { [any]: TypeNode } & T)
	return {
		name = "struct",
		bytes = @native function(value: { [any]: TypeNode } & T): number
			local total = 0
			for k, v in Struct :: { [any]: TypeNode } do
				total += (typeof(v.bytes) == "function" and (v.bytes :: (value: any) -> number)((value :: any)[k]) or v.bytes :: number) :: number
			end
			return total
		end,

		write = @native function(b: buffer, offset: number, value: { [any]: any }): number
			for k, v in Struct :: { [any]: TypeNode } do
				offset = v.write(b, offset, (value :: { [any]: TypeNode })[k])
			end
			return offset
		end,

		read = @native function(b: buffer, offset: number): ({ [any]: TypeNode }, number)
			local value = {}
			for k, v in Struct :: { [any]: TypeNode } do
				value[k], offset = v.read(b, offset)
			end
			return value, offset
		end,
	}
end
