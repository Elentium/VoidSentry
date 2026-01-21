local w_u8 = buffer.writeu8
local r_u8 = buffer.readu8
local w_string = buffer.writestring
local r_string = buffer.readstring
local Config = require("../shared/Config")

return {
	name = "string_tiny",
	bytes = @native function(val: string): number
		return #val + 1
	end,
	write = @native function(b: buffer, offset: number, value: string): number
		local len = #value
		if Config.VALIDATION_LEVEL >= 2 then
			if len > 255 then
				error(`string_tiny.write: String length ({len}) exceeds max length (255).`)
			end
		end
		w_u8(b, offset, len)
		offset += 1
		w_string(b, offset, value)
		return offset + len
	end,
	read = @native function(b: buffer, offset: number): (string, number)
		local len = r_u8(b, offset)
		offset += 1
		local value = r_string(b, offset, len)
		return value, offset + len
	end,
}
