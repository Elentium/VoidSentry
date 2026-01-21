local w_u8 = buffer.writeu8
local r_u8 = buffer.readu8
local Config = require("../shared/Config")
local math_floor = math.floor

local UINT8_MIN = 0
local UINT8_MAX = 255

return {
	name = "uint8",
	bytes = 1,
	write = @native function(b: buffer, offset: number, value: number): number
		if Config.VALIDATION_LEVEL >= 2 then
			if math_floor(value) ~= value or value < UINT8_MIN or value > UINT8_MAX then
				error(`uint8.write: Value {value} is out of range ({UINT8_MIN}..{UINT8_MAX}).`)
			end
		end
		w_u8(b, offset, value)
		return offset + 1
	end,
	read = @native function(b: buffer, offset: number): (number, number)
		local value = r_u8(b, offset)
		return value, offset + 1
	end,
}
