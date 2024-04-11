-- IC2 uses "Durability" nbt which is a number from 0-1 (won't actually show 0) where it represents the % lost.
-- i.e. a durability of 0.75 means only 25% is left
-- You can loop and check for any that are below (above a number) threshold durability and stop the reactor. Then simply dump out and in old and new condensators.

local function tryRequire(moduleName, paths)
	local errorMsgs = {}
	for _, path in ipairs(paths) do
		local tryPath = ""
		if path == "" then
			tryPath = moduleName
		else
			tryPath = path .. "." .. moduleName
		end
		local success, module = pcall(require, tryPath)
		if success then
			return module
		else
			table.insert(errorMsgs, "Failed to require '" .. moduleName .. "' from '" .. path .. "': " .. module)
		end
	end
	error(table.concat(errorMsgs, "\n"))
end

local inv = tryRequire("inventory", { "", "KA_CC_Programs", "../" })

-- Store modules
local reactor = {}

reactor.core = nil

-- Takes In: String of Chamber's side or network name
function reactor.wrapCoreUsingChamber(reactorChamberNameOrSide)
	reactor.core = peripheral.wrap(reactorChamberNameOrSide).getReactorCore()
end

-- Take In: String of Core's side or network name
function reactor.wrapCoreDirectly(reactorCoreNameOrSide)
	reactor.core = peripheral.wrap(reactorCoreNameOrSide)
end

-- Takes in: Decimal form of percentage of durability
-- Returns: A list of slots with durabilities below the percentage
function reactor.findAllComponentsWithDurabilityBelow(decimalPercentage)
	local lowerFunction = function(inputItemMeta)
		durabilityTaken = inputItemMeta["Durability"] or 0
		return (1 - durabilityTaken) < decimalPercentage
	end
	return inv.findItemsInInvThatFulfilsFunction(reactor.core, lowerFunction)
end

-- Takes in: Decimal form of percentage of durability, the display name of the item
-- Returns: A list of slots with durabilities below the percentage
function reactor.findAllComponentsWithDurabilityBelowAndDisplayName(decimalPercentage, displayName)
	local lowerFunction = function(inputItemMeta)
		durabilityTaken = inputItemMeta["durability"] or 0
		itemDisplayName = inputItemMeta["displayName"] or nil
		return ((1 - durabilityTaken) < decimalPercentage) and (itemDisplayName == displayName)
	end
	return inv.findItemsInInvThatFulfilsFunction(reactor.core, lowerFunction)
end

return reactor
