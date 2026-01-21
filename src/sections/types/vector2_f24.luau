--!strict
local f24 = require("./float24")
local write = f24.write
local read = f24.read
local vec2_new = Vector2.new

return {
	name = "vector2_f24",
	bytes = 6,
	write = @native function(b: buffer, offset: number, value: Vector2): number
		offset = write(b, offset, value.X)
		offset = write(b, offset, value.Y)
		return offset
	end,
	read = @native function(b: buffer, offset: number): (Vector2, number)
		local a = {}
		for i = 1, 2 do
			a[i], offset = read(b, offset)
		end
		local value = vec2_new(a[1], a[2])
		return value, offset
	end,
}
