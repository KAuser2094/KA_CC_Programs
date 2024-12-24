local Class = require "KA_CC.modules.class".Class
local PublishSubscribe = require "KA_CC.modules.class".MixIns.PublishSubscribe
local Peripheral = require "KA_CC.peripheral.Peripheral"
local p_utils = require "KA_CC.peripheral.utils"
local utils = require "KA_CC.modules.utils"

local native = _G.peripheral

assert(PublishSubscribe, "Failed to import PublishSubscribe")

local Inventory = Class("KA_Inventory", Peripheral, PublishSubscribe)

-- STATIC

Inventory.EVENTS = {
    SYNC = "KA_Inventory_sync", -- For when contents are synced and possibly changed
}

Inventory:doNotInhertKey("EVENTS")

Inventory:mergeEventHookEnum(Inventory.EVENTS)

Inventory.SIDES = {
    up = true,
    down = true,
    north = true,
    south = true,
    west = true,
    east= true,
}

Inventory.NEEDS_SIDE = {
    mods = {
        "ic2"
    },
    -- Specific types
    match_exact = {

    },
    -- Use regex (I hate it)
    math_pattern = {

    },
}

function Inventory.isInventory(i)
    return i.isClass and i:isClass(Inventory)
end

function Inventory.needsSideSpecified(InventoryOrWrappedOrName)
    local mod = nil
    local needs_side = false
    if Inventory.isInventory(InventoryOrWrappedOrName)  then
        return InventoryOrWrappedOrName.needs_side
    elseif p_utils.isWrapped(InventoryOrWrappedOrName) or p_utils.isName(InventoryOrWrappedOrName) then
        _, _, _, _, mod = p_utils.getClassFields(InventoryOrWrappedOrName)
    else
        error("Invalid input")
    end

    if not needs_side and mod then
        needs_side = utils.containsValue(Inventory.NEEDS_SIDE.mods, mod)
    end
    
    -- TODO: Insert code for exact and pattern matching

    return needs_side
end

-- INSTANCE (PUBLIC/PRIVATE)

function Inventory:init(wrappedOrName, sideOrNil)
    self:super(Peripheral).init(self, wrappedOrName)

    assert(self.api.list, "The peripheral passed in is not an inventory")

    self.sideSpecified = Inventory.SIDES[sideOrNil] and sideOrNil or nil -- For blocks where the side matters. (ideally you pass in during the push/pull as well)

    self:sync()

    self.needs_side = Inventory.needsSideSpecified(self.api) -- Don't call with self because that uses the field set here, which obv. isn't set yet.
end

-- SETTERS

function Inventory:setSide(side)
    assert(Inventory.SIDES[side], "Trying to set an invalid side and sideSpecified")
    self.sideSpecified = Inventory.SIDES[side] and side or self.sideSpecified
end

-- GETTERS/PROPERTIES

--! Note that this isn't about whether the inventory is full, just whether the slots are.
function Inventory:slotsFull()
	return self:slotsFilled() == self.api.size()
end

function Inventory:isEmpty()
	return self:slotsFilled() == 0
end

function Inventory:slotsFilled()
	return #(self.contents)
end

-- ASSERT/PRINT/UTIL

function Inventory:assertValidOperation(other_InventoryOrWrappedOrName, selfSideOrNil, otherSideOrNil)
    local needs_side = Inventory.needsSideSpecified(self)
    local other_needs_side = Inventory.needsSideSpecified(other_InventoryOrWrappedOrName)

    local selfSide = selfSideOrNil or self.sideSpecified or nil
    local otherSide = otherSideOrNil or (Inventory.isInventory(other_InventoryOrWrappedOrName) and other_InventoryOrWrappedOrName.sideSpecified) or nil
    
    assert(not (needs_side and other_needs_side), "Cannot do operation between 2 inventories that need to specify a side, needs an imbetween inventory")
    assert(not (needs_side and not selfSide), "The calling Inventory requires a side to be specified (init, setSide, or pass in)")
    assert(not (needs_side and not Inventory.SIDES[selfSide]), "The calling Inventory requires a side, the side is invalid")
    assert(not (other_needs_side and not otherSide), "The other Inventory requires a side to be specified (init, setSide, or pass in)")
    assert(not (other_needs_side and not Inventory.SIDES[otherSide]), "The other Inventory requires a side, the side is invalid")


    return true
end

-- ITEM MOVEMENT

function Inventory:sync() -- updates "contents"
    self.contents = self.api.list()

    self:_notifyEvent(Inventory.EVENTS.SYNC)
end

function Inventory:rearrange(fromSlot, limit, toSlot)
    self:assertValidOperation(self)
    local ret = self.api.pushItems(self.name, fromSlot, limit, toSlot)
    self:sync()
    return ret
end

function Inventory:push(other, fromSlot, limitOrNil, toSlotOrNil, selfSideOrNil, otherSideOrNil)
    self:assertValidOperation(other, selfSideOrNil, otherSideOrNil)

    local otherName = p_utils.getName(other)

    local selfSide = selfSideOrNil or self.sideSpecified or nil
    local otherSide = otherSideOrNil or (Inventory.isInventory(other) and other.sideSpecified) or nil
    local selfSidedName = self.name .. "." .. selfSide .. "_side"
    local otherSidedName = otherName .. "." .. otherSide .. "_side"

    local ret = nil

    if self.needs_side then -- You can't call from a peripheral that needs a side
        ret = native.call(otherName, "pullItems", selfSidedName, fromSlot, limitOrNil, toSlotOrNil)
    elseif Inventory.needsSideSpecified(other) then
        ret = self.api.pushItems(otherSidedName, fromSlot, limitOrNil, toSlotOrNil)
    else
        ret = self.api.pushItems(otherName, fromSlot, limitOrNil, toSlotOrNil)
    end

    self:sync()

    if Inventory.isInventory(other) then
        other:sync()
    end

    return ret
end

function Inventory:pull(other, fromSlot, limitOrNil, toSlotOrNil, selfSideOrNil, otherSideOrNil)
    self:assertValidOperation(other, selfSideOrNil, otherSideOrNil)

    local otherName = p_utils.getName(other)

    local selfSide = selfSideOrNil or self.sideSpecified or nil
    local otherSide = otherSideOrNil or (Inventory.isInventory(other) and other.sideSpecified) or nil
    local selfSidedName = self.name .. "." .. selfSide .. "_side"
    local otherSidedName = otherName .. "." .. otherSide .. "_side"

    local ret = nil

    if self.needs_side then -- You can't call from a peripheral that needs a side
        ret = native.call(otherName, "pushItems", selfSidedName, fromSlot, limitOrNil, toSlotOrNil)
    elseif Inventory.needsSideSpecified(other) then
        ret = self.api.pullItems(otherSidedName, fromSlot, limitOrNil, toSlotOrNil)
    else
        ret = self.api.pullItems(otherName, fromSlot, limitOrNil, toSlotOrNil)
    end

    self:sync()

    if Inventory.isInventory(other) then
        other:sync()
    end

    return ret
end

return Inventory