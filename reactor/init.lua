-- IC2 uses "Durability" nbt which is a number from 0-1 (won't actually show 0) where it represents the % lost.
-- i.e. a durability of 0.75 means only 25% is left
-- You can loop and check for any that are below (above a number) threshold durability and stop the reactor. Then simply dump out and in old and new condensators.

local function tryRequire(paths)
	local errorMsgs = {}
	for _, path in ipairs(paths) do
		local success, module = pcall(require, path)
		if success then
			return module
		else
			table.insert(errorMsgs, "Failed to require from '" .. path .. "': " .. module)
		end
	end
	error(table.concat(errorMsgs, "\n"))
end

local inv = tryRequire({ "inventory", "KA_CC_Programs/inventory", "../inventory" })

-- Store modules
local module = {}

return module
