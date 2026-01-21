local level = 0
local initialized = false

local log = {}

function log.init(newLevel: number)
	if initialized then
		return
	end

	initialized = true
	level = newLevel
end

function log.print(...: any)
	if level >= 2 then
		print("[VoidSentry] ", ...)
	end
end

function log.warn(...: any)
	if level >= 1 then
		warn("[VoidSentry] ", ...)
	end
end

return log
