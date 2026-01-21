local w_i16 = buffer.writei16
local r_i16 = buffer.readi16
local Config = require("../shared/Config")
local math_floor = math.floor

local INT16_MIN = -32768
local INT16_MAX = 32767

return {
	name = "int16",
	bytes = 2,
	write = @native function(b: buffer, offset: number, value: number): number
		if Config.VALIDATION_LEVEL >= 2 then
			if math_floor(value) ~= value or value < INT16_MIN or value > INT16_MAX then
				error(`int16.write: Value {value} is out of range ({INT16_MIN}..{INT16_MAX}).`)
			end
		end
		w_i16(b, offset, value)
		return offset + 2
	end,
	read = @native function(b: buffer, offset: number): (number, number)
		local value = r_i16(b, offset)
		return value, offset + 2
	end,
}
