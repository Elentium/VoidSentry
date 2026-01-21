local w_i32 = buffer.writei32
local r_i32 = buffer.readi32
local Config = require("../shared/Config")
local math_floor = math.floor

local INT32_MIN = -2147483648
local INT32_MAX = 2147483647

return {
	name = "int32",
	bytes = 4,
	write = @native function(b: buffer, offset: number, value: number): number
		if Config.VALIDATION_LEVEL >= 2 then
			if math_floor(value) ~= value or value < INT32_MIN or value > INT32_MAX then
				error(`int32.write: Value {value} is out of range ({INT32_MIN}..{INT32_MAX}).`)
			end
		end
		w_i32(b, offset, value)
		return offset + 4
	end,
	read = @native function(b: buffer, offset: number): (number, number)
		local value = r_i32(b, offset)
		return value, offset + 4
	end,
}
