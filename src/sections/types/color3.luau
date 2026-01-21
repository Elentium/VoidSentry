--!strict
local w_u8 = buffer.writeu8
local r_u8 = buffer.readu8
local color3_new = Color3.fromRGB

return {
	name = "color3",
	bytes = 3,
	write = @native function(b: buffer, offset: number, value: Color3): number
		w_u8(b, offset, bit32.band(value.R * 255, 0xFF))
		w_u8(b, offset + 1, bit32.band(value.G * 255, 0xFF))
		w_u8(b, offset + 2, bit32.band(value.B * 255, 0xFF))
		return offset + 3
	end,
	read = @native function(buf: buffer, offset: number): (Color3, number)
		local r = r_u8(buf, offset)
		local g = r_u8(buf, offset + 1)
		local b = r_u8(buf, offset + 2)
		local value = color3_new(r, g, b)
		return value, offset + 3
	end,
}
