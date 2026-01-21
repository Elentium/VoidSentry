local w_u8 = buffer.writeu8
local r_u8 = buffer.readu8

return {
	name = "bool",
	bytes = 1,
	write = @native function(b: buffer, offset: number, value: boolean): number
		w_u8(b, offset, value and 1 or 0)
		return offset + 1
	end,
	read = @native function(b: buffer, offset: number): (boolean, number)
		local value = r_u8(b, offset) == 1
		return value, offset + 1
	end,
}
