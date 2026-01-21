local w_f32 = buffer.writef32
local r_f32 = buffer.readf32

return {
	name = "float32",
	bytes = 4,
	write = @native function(b: buffer, offset: number, value: number): number
		w_f32(b, offset, value)
		return offset + 4
	end,
	read = @native function(b: buffer, offset: number): (number, number)
		local value = r_f32(b, offset)
		return value, offset + 4
	end,
}
