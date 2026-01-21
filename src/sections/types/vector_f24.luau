--!strict
local f24 = require("./float24")
local write = f24.write
local read = f24.read
local vec_new = vector.create

return {
	name = "vector_f24",
	bytes = 9,
	write = @native function(b: buffer, offset: number, value: vector): number
		offset = write(b, offset, value.x)
		offset = write(b, offset, value.y)
		offset = write(b, offset, value.z)
		return offset
	end,
	read = @native function(b: buffer, offset: number): (vector, number)
		local x, y, z
		x, offset = read(b, offset)
		y, offset = read(b, offset)
		z, offset = read(b, offset)
		return vec_new(x, y, z), offset
	end,
}
