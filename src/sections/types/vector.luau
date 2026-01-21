--!strict
local w_f32 = buffer.writef32
local r_f32 = buffer.readf32
local vec_new = vector.create

return {
	name = "vector",
	bytes = 12,
	write = @native function(b: buffer, offset: number, value: vector): number
		w_f32(b, offset, value.x)
		w_f32(b, offset + 4, value.y)
		w_f32(b, offset + 8, value.z)
		return offset + 12
	end,
	read = @native function(b: buffer, offset: number): (vector, number)
		local value = vec_new(r_f32(b, offset), r_f32(b, offset + 4), r_f32(b, offset + 8))
		return value, offset + 12
	end,
}
