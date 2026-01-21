--!strict
local w_f32 = buffer.writef32
local r_f32 = buffer.readf32
local vec2_new = Vector2.new

return {
	name = "vector2",
	bytes = 8,
	write = @native function(b: buffer, offset: number, value: Vector2): number
		w_f32(b, offset, value.X)
		w_f32(b, offset + 4, value.Y)
		return offset + 8
	end,
	read = @native function(b: buffer, offset: number): (Vector2, number)
		local value = vec2_new(r_f32(b, offset), r_f32(b, offset + 4))
		return value, offset + 8
	end,
}
