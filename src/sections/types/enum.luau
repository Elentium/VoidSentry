--!strict

local w_u16 = buffer.writeu16
local r_u16 = buffer.readu16
local Config = require("../shared/Config")

return function(Enum: Enum)
	return {
		name = "enum",
		bytes = 2,
		write = @native function(b: buffer, offset: number, value: EnumItem): number
			if Config.VALIDATION_LEVEL >= 2 then
				if typeof(value) ~= "EnumItem" then
					error(`enum.write: Expected EnumItem, got {typeof(value)}`)
				end
				if value.EnumType ~= Enum then
					error(`enum.write: EnumItem belongs to {value.EnumType}, expected {Enum}`)
				end
			end
			w_u16(b, offset, value.Value)
			return offset + 2
		end,
		read = @native function(b: buffer, offset: number): (EnumItem, number)
			local value = Enum:FromValue(r_u16(b, offset))
			return value, offset + 2
		end,
	}
end
