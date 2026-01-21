--!strict
local w_string = buffer.writestring
local r_string = buffer.readstring
local r_u8 = buffer.readu8

return {
	name = "string_null_terminated",
	bytes = function(value: string): number
		return #value + 1 -- +1 for null terminator
	end,
	write = @native function(b: buffer, offset: number, value: string): number
		w_string(b, offset, value)
		offset += #value
		-- write null terminator
		buffer.writeu8(b, offset, 0)
		return offset + 1
	end,
	read = @native function(b: buffer, offset: number): (string, number)
		local len = 0
		
		-- find null terminator
		while true do
			local byte = r_u8(b, offset + len)
			if byte == 0 then
				break
			end
			len += 1
		end
		
		local value = r_string(b, offset, len)
		return value, offset + len + 1 -- +1 for null terminator
	end,
}
