local w_u16 = buffer.writeu16
local r_u16 = buffer.readu16
local w_string = buffer.writestring
local r_string = buffer.readstring
local Config = require("../shared/Config")

return {
	name = "string",
	bytes = @native function(val: string): number
		return #val + 2
	end,
	write = @native function(b: buffer, offset: number, value: string): number
		local len = #value
		if Config.VALIDATION_LEVEL >= 2 then
			if len > 65535 then
				error(`string.write: String length ({len}) exceeds max length (65535).`)
			end
		end
		w_u16(b, offset, len)
		offset += 2
		w_string(b, offset, value)
		return offset + len
	end,
	read = @native function(b: buffer, offset: number): (string, number)
		local len = r_u16(b, offset)
		offset += 2
		local value = r_string(b, offset, len)
		return value, offset + len
	end,
}
