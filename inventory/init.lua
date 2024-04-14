-- Define a table to store the module functions
local module = {}

-- Generic Functions
local function isInList(list, value)
	for _, v in ipairs(list) do
		if v == value then
			return true
		end
	end
	return false
end

-- BETTER INVENTORY: Basically a different api when working with inventory peripherals, wraps around the normal stuff and gives extra functionality
local betterInventory = {}

-- Original Inventory API functions:
-- Look at original api wiki
function betterInventory:size()
	return self.api.size()
end

-- Look at original api wiki
function betterInventory:list()
	return self.api.list()
end

-- Look at original api wiki
function betterInventory:getItemDetail(slot)
	return self.api.getItemDetail(slot)
end

-- Look at original api wiki
function betterInventory:getItemLimit(slot)
	return self.api.getItemDetail(slot)
end

-- Look at original api wiki for most inventories.
-- For certain mods that need you to wrap the connection side as well you must have used `:setConnectionSide(direction)`
function betterInventory:pushItems(toName, fromSlot, limit, toSlot)
	-- Yes these seem a bit redundant
	limit = limit or nil
	toSlot = toSlot or nil
	if self:needsConnectionSideSpecified() then
		local other = module.createBetterInventory(fromName)
		if other:needsConnectionSideSpecified() then
			print(
				"Cannot push/pull between 2 inventories that require a connectionSide specifed, use a relay inventory in the middle."
			)
			return 0
		end
		return other.api.pullItems(self.name .. "." .. self.connectionSide .. "_side", fromSlot, limit, toSlot)
	end
	return self.api.pushItems(fromName, fromSlot, limit, toSlot)
end

-- Look at original api wiki
function betterInventory:pullItems(fromName, fromSlot, limit, toSlot)
	-- Yes these seem a bit redundant
	limit = limit or nil
	toSlot = toSlot or nil
	if self:needsConnectionSideSpecified() then
		local other = module.createBetterInventory(fromName)
		if other:needsConnectionSideSpecified() then
			print(
				"Cannot push/pull between 2 inventories that require a connectionSide specifed, use a relay inventory in the middle."
			)
			return 0
		end
		return other.api.pushItems(self.name .. "." .. self.connectionSide .. "_side", fromSlot, limit, toSlot)
	end
	return self.api.pullItems(fromName, fromSlot, limit, toSlot)
end
-- End of original inventory API

-- The known insides of the inventory are only updated when this is called. Most functions use the api directly, however.
-- @return nil.
function betterInventory:refreshContent()
	self.content = self.api.list()
end

function betterInventory:needsConnectionSideSpecified()
	local modList = { "ic2" }
	return isInList(modList, self.mod)
end

-- Sets the internal connectionSide for use in push/pull if this inventory needs it.
-- @param direction - The direction the inventory is connected to the network to. (So if the machine is west of the modem block, then west.
-- Should be from {"up","down","north","east","south","west"}.
-- @return nil.
function betterInventory:setConnectionSide(direction)
	if not isInList({ "up", "down", "north", "east", "south", "west" }, direction) then
		print(direction .. " is not a valid connection direction (cardinals + up + down)")
		return
	end
	self.connectionSide = direction
end

-- @param key - what key in the item meta whose value you want to retrieve.
-- @param slot - What slot in the inventory to get value from.
-- @return The value, or nil if not found.
function betterInventory:getMetaDataValueAtKeyAtSlot(key, slot)
	local itemMeta = self.api.getItemDetail(slot)
	local val_or_nil = itemMeta[key]
	return val_or_nil
end

-- @param lowerFunction - This should take in an item's meta data and return either true if you want to keep it, or false to discard.
-- @param (opt.) startRange - At what slot in inventory to start search. (Default is 1)
-- @param (opt.) endRange - At what slot in inventory to end search. (Default is `.size()` of api)
-- @return A list of the inventory slots that fulfil the `lowerFunction`.
function betterInventory:findItemsThatFulfilsFunction(lowerFunction, startRange, endRange)
	startRange = startRange or 1
	endRange = endRange or self.api.size()
	local indexList = {}
	for slot = startRange, endRange do
		local itemMeta = self.api.getItemDetail(slot)
		if lowerFunction(itemMeta) then
			table.insert(indexList, slot)
		end
	end
	return indexList
end

-- @param value - What value you want to find
-- @param metakey - What key in the metadata to look for value in
-- @param (opt.) startRange - At what slot in inventory to start search. (Default is 1)
-- @param (opt.) endRange - At what slot in inventory to end search. (Default is `.size()` of api)
-- @return A list of the inventory slots where the `value` was found at the `metakey` key in the item metadata.
function betterInventory:findItemsWithMetaDataValueAtKey(value, metaKey, startRange, endRange)
	local lowerFunction = function(inputItemMeta)
		return value == itemMeta[metakey]
	end
	startRange = startRange or 1
	endRange = endRange or self.api.size()
	return self:findItemsThatFulfilsFunction(lowerFunction, startRange, endRange)
end

function module.createBetterInventory(networkName)
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
	setmetatable(instance, { __index = betterInventory })

	return instance
end
-- END OF BETTER INVENTORY

return module
