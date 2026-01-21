return {
	name = "unknown",
	bytes = 0,
	write = function(b: buffer, offset: number, value: unknown): never
		error(`Unknown type detected`)
	end,
	read = function(b: buffer, offset: number): never
		error(`Unknown type detected`)
	end,

	transfer = true,
}
