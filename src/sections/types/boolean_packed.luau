--!strict

local bor = bit32.bor
local lshift = bit32.lshift
local w_u8 = buffer.writeu8
local r_u8 = buffer.readu8
local band = bit32.band
local Config = require("../shared/Config")

return {
	name = "boolean_packed",
	bytes = 1,
	write = @native function(b: buffer, offset: number, value: { boolean }): number
		if Config.VALIDATION_LEVEL >= 2 then
			if #value ~= 8 then
				error(`boolean_packed.write: Expected 8 booleans, got {#value}.`)
			end
		end
		local byte = 0x0
		for i = 1, #value do
			byte = bor(byte, lshift(value[i] and 0x1 or 0x0, i - 1))
		end
		w_u8(b, offset, byte)
		return offset + 1
	end,
	read = @native function(b: buffer, offset: number): ({ boolean }, number)
		local byte = r_u8(b, offset)
		local value: { boolean } = {}
		for i = 1, 8 do
			value[i] = band(byte, lshift(0x1, i - 1)) ~= 0x0
		end
		return value, offset + 1
	end,
}
