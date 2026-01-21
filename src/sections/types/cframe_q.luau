--!strict
local w_f32 = buffer.writef32
local r_f32 = buffer.readf32
local sqrt = math.sqrt
local cframe_new = CFrame.new

--[[
    Quaternion cframe serialization, less precise but faster, recommended for most cases.
]]
@native
local function toQuaternion(cf: CFrame)
	local _, _, _, m00, m01, m02, m10, m11, m12, m20, m21, m22 = cf:GetComponents()

	local trace = m00 + m11 + m22
	local qx, qy, qz, qw

	if trace > 0 then
		local s = sqrt(trace + 1) * 2
		qw = 0.25 * s
		qx = (m21 - m12) / s
		qy = (m02 - m20) / s
		qz = (m10 - m01) / s
	elseif (m00 > m11) and (m00 > m22) then
		local s = sqrt(1 + m00 - m11 - m22) * 2
		qw = (m21 - m12) / s
		qx = 0.25 * s
		qy = (m01 + m10) / s
		qz = (m02 + m20) / s
	elseif m11 > m22 then
		local s = sqrt(1 + m11 - m00 - m22) * 2
		qw = (m02 - m20) / s
		qx = (m01 + m10) / s
		qy = 0.25 * s
		qz = (m12 + m21) / s
	else
		local s = sqrt(1 + m22 - m00 - m11) * 2
		qw = (m10 - m01) / s
		qx = (m02 + m20) / s
		qy = (m12 + m21) / s
		qz = 0.25 * s
	end

	return qx, qy, qz, qw
end

return {
	name = "cframe_q",
	bytes = 28,
	write = @native function(b: buffer, offset: number, value: CFrame): number
		local pos = value.Position
		local qx, qy, qz, qw = toQuaternion(value)

		-- write position
		w_f32(b, offset, pos.X)
		w_f32(b, offset + 4, pos.Y)
		w_f32(b, offset + 8, pos.Z)

		-- write quaternion
		w_f32(b, offset + 12, qx)
		w_f32(b, offset + 16, qy)
		w_f32(b, offset + 20, qz)
		w_f32(b, offset + 24, qw)
		return offset + 28
	end,
	read = @native function(b: buffer, offset: number): (CFrame, number)
		return cframe_new(
			r_f32(b, offset), -- x
			r_f32(b, offset + 4), -- y
			r_f32(b, offset + 8), -- z
			r_f32(b, offset + 12), -- qx
			r_f32(b, offset + 16), -- qy
			r_f32(b, offset + 20), -- qz
			r_f32(b, offset + 24) -- qw
		),
			offset + 28
	end,
}
