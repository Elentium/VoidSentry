--!strict

type bits = number

local Config = require("../shared/Config")

local w_8 = buffer.writeu8
local w_16 = buffer.writeu16
local w_32 = buffer.writeu32

local r_8 = buffer.readu8
local r_16 = buffer.readu16
local r_32 = buffer.readu32

local function node(
	name: string,
	count: number,
	step: number,
	write_fn: (b: buffer, offset: number, value: number) -> (),
	read_fn: (b: buffer, offset: number) -> number,
	mask: number
)
	return {
		name = name,
		bytes = count * step,
		write = @native function(b: buffer, offset: number, value: { bits }): number
			if Config.VALIDATION_LEVEL >= 2 then
				if #value ~= count then
					error(`bits.write: Expected {count} values, got {#value}.`)
				end
				for i = 1, count do
					local v = value[i]
					if type(v) ~= "number" or v < 0 or v > mask then
						error(`bits.write: Invalid value at index {i}. Must be 0..{mask}.`)
					end
				end
			end
			for i = 1, count do
				local bits = bit32.band(value[i], mask)
				write_fn(b, offset, bits)
				offset += step
			end
			return offset
		end,
		read = @native function(b: buffer, offset: number): ({ bits }, number)
			local bitsArray = {}
			for i = 1, count do
				bitsArray[i] = read_fn(b, offset)
				offset += step
			end
			return bitsArray, offset
		end,
	}
end

return {
	_8 = function(count: number)
		return node("8_bit_array", count, 1, w_8, r_8, 0xFF)
	end,
	_16 = function(count: number)
		return node("16_bit_array", count, 2, w_16, r_16, 0xFFFF)
	end,
	_32 = function(count: number)
		return node("32_bit_array", count, 4, w_32, r_32, 0xFFFFFFFF)
	end,
}
