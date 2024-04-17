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
local data = dofile("KA_CC_Programs/ic2/reactor_component_data.lua")

-- Index based list where each index is a slot and the value is the component at that slot
-- Looks at `reactor_component_data` to find what you need to put in the strings (you need to put the key value)
local plan = settings.plan
local providers = {}
for _, providerName in ipairs(settings.providerNames) do
	table.insert(providers, invMod.createBetterInventory(providerName))
end
local reactor = ic2Mod.createBetterReactor(settings.reactorName)
reactor:setConnectionSide(settings.reactorConnectionSide)

if #plan ~= reactor:size() then
	error("Plan does not fit reactor (use nil for slots that are unused)")
end

local countTransferred = 0
local tryProvider = 1
for slot, compFuncName in ipairs(plan) do
	if compFuncName and data.compFuncName then
		countTransferred = 0
		while countTransferred == 0 and tryProvider < (#providers + 1) do
			local provider = providers[tryProvider]
			countTransferred = countTransferred
				+ reactor["find" .. compFuncName .. "AndPull"](reactor, provider, nil, nil, 1, slot)
		end -- while countTransferred == 0 and tryProvider < (#providers + 1) do
		if countTransferred == 0 then
			print("Failed to put " .. compFuncName .. " into slot " .. slot)
		end
	end -- if compFuncName then
end -- for slot, compFuncName in pairs(plan) do
