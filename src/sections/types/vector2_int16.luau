--!strict
local w_i16 = buffer.writei16
local r_i16 = buffer.readi16
local vec2i16_new = Vector2int16.new

return {
	name = "vector2_int16",
	bytes = 4,
	write = @native function(b: buffer, offset: number, value: Vector2int16): number
		w_i16(b, offset, value.X)
		w_i16(b, offset + 2, value.Y)
		return offset + 4
	end,
	read = @native function(b: buffer, offset: number): (Vector2int16, number)
		local value = vec2i16_new(r_i16(b, offset), r_i16(b, offset + 2))
		return value, offset + 4
	end,
}
