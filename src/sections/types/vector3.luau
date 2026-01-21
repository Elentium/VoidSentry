--!strict
local w_f32 = buffer.writef32
local r_f32 = buffer.readf32
local vec3_new = Vector3.new

return {
	name = "vector3",
	bytes = 12,
	write = @native function(b: buffer, offset: number, value: Vector3): number
		w_f32(b, offset, value.X)
		w_f32(b, offset + 4, value.Y)
		w_f32(b, offset + 8, value.Z)
		return offset + 12
	end,
	read = @native function(b: buffer, offset: number): (Vector3, number)
		local value = vec3_new(r_f32(b, offset), r_f32(b, offset + 4), r_f32(b, offset + 8))
		return value, offset + 12
	end,
}
