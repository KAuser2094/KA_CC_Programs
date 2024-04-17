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
-- local invMod = tryRequire({ "inventory", "KA_CC_Programs/inventory" })
-- local ic2Mod = tryRequire({ "ic2", "KA_CC_Programs/ic2" })
-- local settings =
-- 	tryRequire({ "fill_reactor_settings", "KA_CC_Programs/ic2/fill_reactor_settings", "ic2/fill_reactor_settings" })
-- local data =
-- 	tryRequire({ "reactor_component_data", "KA_CC_Programs/ic2/reactor_component_data", "ic2/reactor_component_data" })

local invMod = dofile("KA_CC_Programs/inventory/init.lua")
local ic2Mod = dofile("KA_CC_Programs/ic2/init.lua")
local settings = dofile("KA_CC_Programs/ic2/fill_reactor_settings.lua")

-- Index based list where each index is a slot and the value is the component at that slot
-- Looks at `reactor_component_data` to find what you need to put in the strings (you need to put the key value)
local plan = settings.plan
local providers = settings.providers
for _, provider in ipairs(providers) do
	provider.api = invMod.createBetterInventory(provider.name)
end
local reactor = ic2Mod.createBetterReactor(settings.reactor.name)
reactor:setConnectionSide(settings.reactor.connectionSide)

if #plan ~= reactor:size() then
	error("Plan does not fit reactor (use nil for slots that are unused)")
end

for slot, compName in ipairs(plan) do
	if compName and reactor["find" .. compName] then
		for _, provider in ipairs(providers) do
			if provider.content == compName then
				provider.api:pushItems(reactor, 1, 1, slot)
			end
		end -- for _, provider in ipairs(providers) do
	end -- if compName then
end -- for slot, compName in pairs(plan) do
