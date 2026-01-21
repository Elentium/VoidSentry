return {
	name = "nil",
	bytes = 0,
	write = function(b: buffer, offset: number, value: nil): number
		return offset
	end,
	read = @native function(b: buffer, offset: number): (nil, number)
		return nil, offset
	end,
}
