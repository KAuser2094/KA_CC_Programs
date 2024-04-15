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

function shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end

local function gatherFunctions(tbl)
	local functions = {}
	for key, value in pairs(tbl) do
		if type(value) == "function" then
			functions[key] = value
		end
	end
	return functions
end

local function printTableItemByItem(tbl)
	for index, value in pairs(tbl) do
		print("Index:", index, "\nValue:", value)
		print("Press Enter to print next item")
		io.read()
	end
end

-- BETTER INVENTORY: Basically a different api when working with inventory peripherals, wraps around the normal stuff and gives extra functionality
local betterInventory = {}

-- Takes in either a string or betterInventory and returns the betterInventory, or creates one and returns that.
function betterInventory:getInstanceOrCreate(otherName_or_other)
	local otherName = nil
	local other = nil
	if otherName_or_other.getClassTypes and isInList(otherName_or_other.getClassTypes(), "KA_betterInventory") then
		otherName = otherName_or_other.name
		other = otherName_or_other
	else
		otherName = otherName_or_other
		other = module.createBetterInventory(otherName)
	end
	return other
end

-- Allows you to use ALL functions in inventory api in betterInventory using colon notation over dot notation.
-- (You can still use dot notation but remember `self` is the first argument, so pass in the table. ie `betterInventory.size(betterInventory)`)
-- @return nil
function betterInventory:getAPIFunctions()
	for funcName, funcObj in pairs(gatherFunctions(self.api)) do
		if not self[funcName] then -- Don't override my overrides with original
			self[funcName] = function(self, ...)
				return self.api[funcName](...)
			end
		end
	end
end

-- For certain mods that need you to wrap the connection side as well you must have used `:setConnectionSide(direction)`.
function betterInventory:pushItems(otherName_or_other, fromSlot, limit, toSlot)
	local other = self:getInstanceOrCreate(otherName_or_other)
	self:debugPrint(
		"Goal: "
			.. (limit or "max")
			.. " from "
			.. self.name
			.. " at slot "
			.. fromSlot
			.. " to "
			.. other.name
			.. " at slot "
			.. (toSlot or "any")
	)
	if self:needsConnectionSideSpecified() and other:needsConnectionSideSpecified() then
		print(
			"Cannot push/pull between 2 inventories that require a connectionSide specifed, use a relay inventory in the middle."
		)
		return 0
	end
	if self:needsConnectionSideSpecified() then
		if not self.connectionSide then
			print(
				self.name
					.. " needs a connection side specified, you must run `<betterInventory>:setConnectionSide(side) before any push/pull"
			)
			return 0
		end
		self:debugPrint(other.name .. " pulls from " .. self.name .. "." .. self.connectionSide .. "_side")
		return other.api.pullItems(self.name .. "." .. self.connectionSide .. "_side", fromSlot, limit, toSlot)
	end
	if other:needsConnectionSideSpecified() then
		if not other.connectionSide then
			print(
				other.name
					.. " needs a connection side specified, you must run `<betterInventory>:setConnectionSide(side) before any push/pull"
			)
			return 0
		end
		self:debugPrint(other.name .. " pushes into " .. other.name .. "." .. other.connectionSide .. "_side")
		return self.api.pushItems(other.name .. "." .. other.connectionSide .. "_side", fromSlot, limit, toSlot)
	end
	self:debugPrint(self.name .. " pushes into " .. other.name)
	return self.api.pushItems(other.name, fromSlot, limit, toSlot)
end

-- For certain mods that need you to wrap the connection side as well you must have used `:setConnectionSide(direction)`.
function betterInventory:pullItems(otherName_or_other, fromSlot, limit, toSlot)
	local other = self:getInstanceOrCreate(otherName_or_other)
	local otherVerbosity = other.verbosity
	other.verbosity = self.verbosity
	local result = other:pushItems(self, fromSlot, limit, toSlot)
	other.verbosity = otherVerbosity
	return result
end

-- Will search through inventory for an item that fulfils the lowerFunction and push it into the other inventory
function betterInventory:findAndPush(otherName_or_other, lowerFunction, startRange, endRange, limit, toSlot)
	local slots = self:findItemsThatFulfilsFunction(lowerFunction, startRange, endRange)
	if #slots > 0 then
		return self:pushItems(otherName_or_other, slots[1], limit, toSlot)
	end
	return 0
end

-- Will search through inventory for an item that fulfils the lowerFunction and pull it from the other inventory
function betterInventory:findAndPull(otherName_or_other, lowerFunction, startRange, endRange, limit, toSlot)
	local other = self:getInstanceOrCreate(otherName_or_other)
	local otherVerbosity = other.verbosity
	other.verbosity = self.verbosity
	local result = other:findAndPush(self, lowerFunction, startRange, endRange, limit, toSlot)
	other.verbosity = otherVerbosity
	return result
end

-- Same as original api, but adds extra methods and usages.
function betterInventory:getDocs()
	local docs = self.api.getDocs()
	-- TODO: Add an "Introduction" to start of table that explains the object.
	-- TODO: Add/Overide fields to explain new/overridden methods.
	return docs
end

-- pagePrint if verbosity is set > 0.
-- @return nil
function betterInventory:debugPrint(string)
	if self.verbosity and self.verbosity > 0 then
		textutils.pagedPrint(string)
	end
end

-- prints item by item whatever is at `self:getDocs()`
-- @return nil
function betterInventory:printDocs()
	printTableItemByItem(self:getDocs())
end

-- @return { "KA_betterInventory" }
function betterInventory.getClassTypes()
	return { "KA_betterInventory" }
end

-- The known insides of the inventory are only updated when this is called. Most functions use the api directly, however, so you can mostly ignore this.
-- @return nil.
function betterInventory:refreshContent()
	self.content = self.api.list()
end

function betterInventory:needsConnectionSideSpecified()
	local modList = { "ic2" }
	return isInList(modList, self.mod)
end

-- TODO: Uses another inventory (that doesn't need a connectionSide) and tries to push an item in from different directions, whatever works is the correct direction.
function betterInventory:calculateConnectionSide(otherName_or_other, fromSlot, toSlot) end

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
	local itemMeta = self.api.getItemMeta(slot)
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
		local itemMeta = self.api.getItemMeta(slot)
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

-- @param name - the minecraft name of the item (eg. `minecraft:stone`)
-- @param damage - the damage in the meta data (usually used for variants of similar/same items)
-- @param (opt.) startRange - At what slot in inventory to start search. (Default is 1)
-- @param (opt.) endRange - At what slot in inventory to end search. (Default is `.size()` of api)
-- @return A list of the inventory slots where the name and damage match.
function betterInventory:findItemsWithNameAndDamage(name, damage, startRange, endRange)
	local lowerFunction = function(inputItemMeta)
		return (name == itemMeta["name"] and damage == itemMeta["damage"])
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
	}
	instance.mod = instance.type:match("([^:_]+)")
	if not instance.api then
		print(instance.name .. " is not an available peripheral, cannot create a betterInventory instance with it")
		return nil
	end
	if not instance.api.list then
		print(instance.name .. " is not an inventory, cannot create a betterInventory instance with it")
		return nil
	end
	instance.content = instance.api.list()
	setmetatable(instance, { __index = betterInventory })
	instance:getAPIFunctions()

	return instance
end

function module.convertInventoryToBetterInventory(inventoryApi)
	return module.createBetterInventory(peripheral.getName(inventoryApi))
end

function module.convertInventoryListToBetterInventoryList(inventoryApiList)
	local newList = {}
	for i, inventoryApi in ipairs(inventoryApiList) do
		newList[i] = module.convertInventoryToBetterInventory(inventoryApi)
	end
	return newList
end

function module.getCopyOfBetterInventoryDefinitionTable()
	return shallowCopy(betterInventory)
end
-- END OF BETTER INVENTORY

return module
