-- IC2 uses "Durability" nbt which is a number from 0-1 (won't actually show 0) where it represents the % lost.
-- i.e. a durability of 0.75 means only 25% is left
-- You can loop and check for any that are below (above a number) threshold durability and stop the reactor. Then simply dump out and in old and new condensators.

-- Generic Functions
local function isInList(list, value)
	for _, v in ipairs(list) do
		if v == value then
			return true
		end
	end
	return false
end

function shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end

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

-- I refuse to make all these methods manually.
function betterReactor:getFindReactorComponentFunctions()
	itemDatas = tryRequire({
		"reactor_component_data",
		"ic2/reactor_component_data",
		"KA_CC_Programs/ic2/reactor_component_data",
	})
	local function lower1()
		return function(itemMeta)
			itemDurability = itemMeta["durability"] and (1 - itemMeta["durability"]) or 1
			return name == itemMeta["name"] and damage == itemMeta["damage"] and itemDurability < durabilityDecimal
		end
	end
	local function lower2()
		return function(itemMeta)
			itemDurability = itemMeta["durability"] and (1 - itemMeta["durability"]) or 1
			return name == itemMeta["name"] and damage == itemMeta["damage"] and itemDurability > durabilityDecimal
		end
	end
	for key, itemData in pairs(itemDatas) do
		self["find" .. key] = function(self, startRange, endRange)
			return self:findItemsWithNameAndDamage(itemData.name, itemData.damage, startRange, endRange)
		end
		self["find" .. key .. "DurabilityBelow"] = function(self, durabilityDecimal, startRange, endRange)
			return self:findItemsThatFulfilsFunction(lower1(), startRange, endRange)
		end
		self["find" .. key .. "DurabilityAbove"] = function(self, durabilityDecimal, startRange, endRange)
			return self:findItemsThatFulfilsFunction(lower2(), startRange, endRange)
		end
	end
end

function module.createBetterReactor(networkName)
	local instance = {
		name = networkName,
		api = peripheral.wrap(networkName),
		type = peripheral.getType(networkName),
		mod = networkName:match("([^:_]+)"),
	}
	if not instance.api then
		print(instance.name .. " is not an available peripheral, cannot create a betterReactor instance with it")
	end
	if not instance.api.list then
		print(instance.name .. " is not an inventory, cannot create a betterReactor instance with it")
		return nil
	end
	if not isInList({ "ic2:reactor chamber", "ic2:nuclear reactor" }, instance.type) then
		print(instance.name .. " is not a reactor block, cannot create a betterReactor instance with it")
		return nil
	end
	instance.core = (instance.type == "ic2:nuclear reactor") and instance.api or instance.api.getReactorCore()
	instance.content = instance.api.list()
	instance.verbosity = 0
	setmetatable(instance, { __index = betterReactor })
	instance:getAPIFunctions()
	instance:getFindReactorComponentFunctions()

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

function module.findAllReactorsInNetwork()
	local reactors = { peripheral.find("ic2:reactor chamber"), peripheral.find("ic2:nuclear reactor") }
	reactors = module.convertReactorListToBetterReactorList(reactors)
	return table.unpack(reactors)
end

function module.getCopyOfBetterReactorDefinitionTable()
	return shallowCopy(betterReactor)
end

function module.giveAnotherBetterInventoryFindReactorComponentFunctions(betterInventory)
	betterReactor.getFindReactorComponentFunctions(betterInventory)
end
-- END OF BETTER REACTOR

return module
