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

-- BETTER REACTOR: Basically betterInventory but with some extra stuff that is more specific.
local betterReactor = inv.getCopyOfBetterInventoryDefinitionTable() -- "Inherits" fields and methods

-- @return { "KA_betterReactor", "KA_betterInventory" }
function betterReactor.getClassTypes()
	return { "KA_betterReactor", "KA_betterInventory" }
end

function module.createBetterReactor(networkName)
	local instance = {
		name = networkName,
		api = peripheral.wrap(networkName),
		type = peripheral.getType(networkName),
		mod = networkName:match("([^:_]+)"),
	}
	if not instance.api then
		print(instance.name .. " is not an available peripheral, cannot create a betterInventory instance with it")
	end
	if not instance.api.list then
		print(instance.name .. " is not an inventory, cannot create a betterInventory instance with it")
		return nil
	end
	instance.content = instance.api.list()
	instance.verbosity = 0
	setmetatable(instance, { __index = betterReactor })
	instance:getAPIFunctions()

	return instance
end

function module.convertReactorToBetterReactor(inventoryApi)
	return module.createBetterReactor(peripheral.getName(inventoryApi))
end

function module.convertReactorListToBetterReactorList(inventoryApiList)
	local newList = {}
	for i, inventoryApi in ipairs(inventoryApiList) do
		newList[i] = module.convertReactorToBetterReactor(inventoryApi)
	end
	return newList
end

function module.getCopyOfBetterReactorDefinitionTable()
	return shallowCopy(betterReactor)
end

-- END OF BETTER REACTOR

return module
