local w_u32 = buffer.writeu32
local r_u32 = buffer.readu32
local Config = require("../shared/Config")
local math_floor = math.floor

local UINT32_MIN = 0
local UINT32_MAX = 4294967295

return {
	name = "uint32",
	bytes = 4,
	write = @native function(b: buffer, offset: number, value: number): number
		if Config.VALIDATION_LEVEL >= 2 then
			if math_floor(value) ~= value or value < UINT32_MIN or value > UINT32_MAX then
				error(`uint32.write: Value {value} is out of range ({UINT32_MIN}..{UINT32_MAX}).`)
			end
		end
		w_u32(b, offset, value)
		return offset + 4
	end,
	read = @native function(b: buffer, offset: number): (number, number)
		local value = r_u32(b, offset)
		return value, offset + 4
	end,
}
