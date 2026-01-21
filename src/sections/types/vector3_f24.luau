--!strict
local f24 = require("./float24")
local write = f24.write
local read = f24.read
local vec3_new = Vector3.new

return {
	name = "vector3_f24",
	bytes = 9,
	write = @native function(b: buffer, offset: number, value: Vector3): number
		offset = write(b, offset, value.X)
		offset = write(b, offset, value.Y)
		offset = write(b, offset, value.Z)
		return offset
	end,
	read = @native function(b: buffer, offset: number): (Vector3, number)
		local a = {}
		for i = 1, 3 do
			a[i], offset = read(b, offset)
		end
		local value = vec3_new(a[1], a[2], a[3])
		return value, offset
	end,
}
