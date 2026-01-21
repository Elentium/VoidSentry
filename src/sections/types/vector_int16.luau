--!strict
local write = buffer.writei16
local read = buffer.readi16
local vec_new = vector.create

return {
	name = "vector_int16",
	bytes = 6,
	write = @native function(b: buffer, offset: number, value: vector): number
		write(b, offset, value.x)
		write(b, offset + 2, value.y)
		write(b, offset + 4, value.z)
		return offset + 6
	end,
	read = @native function(b: buffer, offset: number): (vector, number)
		local x, y, z = read(b, offset), read(b, offset + 2), read(b, offset + 4)
		return vec_new(x, y, z), offset + 6
	end,
}
