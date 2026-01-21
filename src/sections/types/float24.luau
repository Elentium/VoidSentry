--!strict
local w_u8 = buffer.writeu8
local r_u8 = buffer.readu8
local b_fill = buffer.fill
local math_frexp = math.frexp
local math_clamp = math.clamp
local math_floor = math.floor
local math_pow = math.pow
local bit32_extract = bit32.extract
local bit32_lshift = bit32.lshift

return {
	name = "float24",
	bytes = 3,
	write = @native function(b: buffer, offset: number, value: number): number
		if value == 0 then
			b_fill(b, offset, 0, 3)
			return offset + 3
		end

		local sign = 0
		if value < 0 then
			sign = 1
			value = -value
		end

		local mantissa, exponent = math_frexp(value)
		-- standard IEEE: mantissa is in [0.5, 1).
		-- we shift it to fit 16 bits (multiply by 2^16)
		-- we adjust exponent for the bias (63)
		local e = math_clamp(exponent + 63, 0, 127)
		local m = math_floor((mantissa * 2 - 1) * 65536 + 0.5)

		-- pack: [S EEEEEEE] [MMMMMMMM] [MMMMMMMM]
		w_u8(b, offset, (sign * 128) + e)
		w_u8(b, offset + 1, bit32_extract(m, 8, 8))
		w_u8(b, offset + 2, bit32_extract(m, 0, 8))

		return offset + 3
	end,

	read = @native function(b: buffer, offset: number): (number, number)
		local b1 = r_u8(b, offset)
		local b2 = r_u8(b, offset + 1)
		local b3 = r_u8(b, offset + 2)

		local sign = bit32_extract(b1, 7, 1) == 1 and -1 or 1
		local exponent = bit32_extract(b1, 0, 7)
		local m_raw = bit32_lshift(b2, 8) + b3

		if exponent == 0 and m_raw == 0 then
			return 0, offset + 3
		end

		-- reconstruct: (1 + m/2^16) * 2^(e - bias - 1)
		local mantissa = (m_raw / 65536) + 1
		local value = sign * mantissa * math_pow(2, exponent - 63 - 1)

		return value, offset + 3
	end,
}
