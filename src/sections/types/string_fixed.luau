--!strict
local w_string = buffer.writestring
local r_string = buffer.readstring
local Config = require("../shared/Config")

return function(len: number)
	return {
		name = "string_fixed",
		bytes = len,
		write = @native function(b: buffer, offset: number, value: string): number
			if Config.VALIDATION_LEVEL >= 2 then
				if len ~= #value then
					error(`string_fixed.write: String length ({#value}) does not match expected length ({len}).`)
				end
			end
			w_string(b, offset, value, len)
			return offset + len
		end,
		read = @native function(b: buffer, offset: number): (string, number)
			return r_string(b, offset, len), offset + len
		end,
	}
end
