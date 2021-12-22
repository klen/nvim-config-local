local Notifier = {}
Notifier.__index = Notifier

--Initialize hash helper
---@param silent boolean: is silent mode enabled
---@returns Notifier
function Notifier:init(silent)
	local self = {}
	setmetatable(self, Notifier)
	self.silent = silent
	self.prefix = "[config-local]: "
	return self
end

--Send notify
function Notifier:notify(msg, level)
	vim.notify(self.prefix .. msg, level or 2)
end

--Send optional notify
function Notifier:onotify(msg, level)
	if not self.silent then
		vim.notify(self.prefix .. msg, level or 2)
	end
end

--Ask for a confirmation
function Notifier:confirm(msg, choices)
	local _, choice = pcall(vim.fn.confirm, self.prefix .. msg, choices, 1)
	return choice
end

return Notifier
