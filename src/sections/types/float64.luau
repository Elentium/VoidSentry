--!strict
local w_f64 = buffer.writef64
local r_f64 = buffer.readf64
return {
	name = "float64",
	bytes = 8,
	write = @native function(b: buffer, offset: number, value: number): number
		w_f64(b, offset, value)
		return offset + 8
	end,
	read = @native function(b: buffer, offset: number): (number, number)
		local value = r_f64(b, offset)
		return value, offset + 8
	end,
}
