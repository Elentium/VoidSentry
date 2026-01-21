--!strict
local w_f32 = buffer.writef32
local r_f32 = buffer.readf32
local table_pack = table.pack
local cframe_new = CFrame.new

--[[
    Most precise cframe serialization, but also the most expensive.
]]
return {
	name = "cframe",
	bytes = 48,
	write = @native function(b: buffer, offset: number, value: CFrame): number
		local components = table_pack(value:GetComponents())
		for i = 1, components.n do
			w_f32(b, offset, components[i])
			offset += 4
		end
		return offset
	end,
	read = @native function(b: buffer, offset: number): (CFrame, number)
		local cf = cframe_new(
			-- position
			r_f32(b, offset),
			r_f32(b, offset + 4),
			r_f32(b, offset + 8),
			-- r0
			r_f32(b, offset + 12),
			r_f32(b, offset + 16),
			r_f32(b, offset + 20),
			-- r1
			r_f32(b, offset + 24),
			r_f32(b, offset + 28),
			r_f32(b, offset + 32),
			-- r2
			r_f32(b, offset + 36),
			r_f32(b, offset + 40),
			r_f32(b, offset + 44)
		)
		return cf, offset + 48
	end,
}
