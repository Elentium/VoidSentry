return {
	name = "void",
	bytes = 0,
	write = function(b: buffer, offset: number, value: {}): number
		return offset
	end,
	read = function(b: buffer, offset: number): ({}, number)
		return {}, offset
	end,
}
