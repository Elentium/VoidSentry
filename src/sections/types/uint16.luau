local w_u16 = buffer.writeu16
local r_u16 = buffer.readu16
local Config = require("../shared/Config")
local math_floor = math.floor

local UINT16_MIN = 0
local UINT16_MAX = 65535

return {
	name = "uint16",
	bytes = 2,
	write = @native function(b: buffer, offset: number, value: number): number
		if Config.VALIDATION_LEVEL >= 2 then
			if math_floor(value) ~= value or value < UINT16_MIN or value > UINT16_MAX then
				error(`uint16.write: Value {value} is out of range ({UINT16_MIN}..{UINT16_MAX}).`)
			end
		end
		w_u16(b, offset, value)
		return offset + 2
	end,
	read = @native function(b: buffer, offset: number): (number, number)
		local value = r_u16(b, offset)
		return value, offset + 2
	end,
}
