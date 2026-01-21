local w_i8 = buffer.writei8
local r_i8 = buffer.readi8
local Config = require("../shared/Config")
local math_floor = math.floor

local INT8_MIN = -128
local INT8_MAX = 127

return {
	name = "int8",
	bytes = 1,
	write = @native function(b: buffer, offset: number, value: number): number
		if Config.VALIDATION_LEVEL >= 2 then
			if math_floor(value) ~= value or value < INT8_MIN or value > INT8_MAX then
				error(`int8.write: Value {value} is out of range ({INT8_MIN}..{INT8_MAX}).`)
			end
		end
		w_i8(b, offset, value)
		return offset + 1
	end,
	read = @native function(b: buffer, offset: number): (number, number)
		local value = r_i8(b, offset)
		return value, offset + 1
	end,
}
