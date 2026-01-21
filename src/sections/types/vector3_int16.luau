--!strict
local w_i16 = buffer.writei16
local r_i16 = buffer.readi16
local vec3i16_new = Vector3int16.new

return {
	name = "vector3_int16",
	bytes = 6,
	write = @native function(b: buffer, offset: number, value: Vector3int16): number
		w_i16(b, offset, value.X)
		w_i16(b, offset + 2, value.Y)
		w_i16(b, offset + 4, value.Z)
		return offset + 6
	end,
	read = @native function(b: buffer, offset: number): (Vector3int16, number)
		local value = vec3i16_new(r_i16(b, offset), r_i16(b, offset + 2), r_i16(b, offset + 4))
		return value, offset + 6
	end,
}
