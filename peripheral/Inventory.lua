local class = require "KA_CC.modules.class"
local Peripheral = require "KA_CC.peripheral.Peripheral"
local p_utils = require "KA_CC.peripheral.utils"
local utils = require "KA_CC.modules.utils"

local native = _G.peripheral

local COMPUTER_SIDES = {
    ["front"] = true,
    ["back"] = true,
    ["right"] = true,
    ["left"] = true,

    ["top"] = true,
    ["botttom"] = true,
    ["north"] = true,
    ["south"] = true,
    ["west"] = true,
    ["east"]= true,
}

local SIDES = {
    ["up"] = true,
    ["down"] = true,
    ["north"] = true,
    ["south"] = true,
    ["west"] = true,
    ["east"]= true,
}

local NEEDS_SIDE = {
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

local function isInventory(Inventory) 
    return Inventory._className and Inventory._className == "KA_Inventory"
end

local function needsSideSpecified(InventoryOrWrappedOrName)
    local mod = nil
    local mods = nil
    local needs_side = false
    if isInventory(InventoryOrWrappedOrName)  then
        return InventoryOrWrappedOrName.needs_side
    elseif p_utils.isWrapped(InventoryOrWrappedOrName) or p_utils.isName(InventoryOrWrappedOrName) then
        _, _, _, _, mod, mods = p_utils.getClassFields(InventoryOrWrappedOrName)
    else
        error("Invalid input")
    end

    if not needs_side and mods then
        for _,_m in pairs(mods) do
            needs_side = utils.containsValue(NEEDS_SIDE.mods, _m)
            if needs_side then
                break
            end
        end
    elseif not needs_side and mod then
        needs_side = utils.containsValue(NEEDS_SIDE.mods, mod)
    end
    
    -- TODO: Insert code for exact and pattern matching

    return needs_side
end

local Inventory = class("KA_Inventory", Peripheral)

function Inventory:init(wrappedOrName, sideOrNil)
    self._super.init(self, wrappedOrName)

    assert(self.api.list, "The peripheral passed in is not an inventory")

    self.sideSpecified = SIDES[sideOrNil] and sideOrNil or nil -- For blocks where the side matters. (ideally you pass in during the push/pull as well)

    self:sync()

    self.needs_side = needsSideSpecified(self.api) -- Don't call with self because that uses the field set here, which obv. isn't set yet.
end

function Inventory:setSide(side)
    assert(SIDES[side], "Trying to set an invalid side and sideSpecified")
    self.sideSpecified = SIDES[side] and side or self.sideSpecified
end

function Inventory:assertValidOperation(other_InventoryOrWrappedOrName, selfSideOrNil, otherSideOrNil)
    local needs_side = needsSideSpecified(self)
    local other_needs_side = needsSideSpecified(other_InventoryOrWrappedOrName)

    local selfSide = selfSideOrNil or self.sideSpecified or nil
    local otherSide = otherSideOrNil or (isInventory(other_InventoryOrWrappedOrName) and other_InventoryOrWrappedOrName.sideSpecified) or nil
    
    assert(not (needs_side and other_needs_side), "Cannot do operation between 2 inventories that need to specify a side, needs an imbetween inventory")
    assert(not (needs_side and not selfSide), "The calling Inventory requires a side to be specified (init, setSide, or pass in)")
    assert(not (needs_side and not SIDES[selfSide]), "The calling Inventory requires a side, the side is invalid")
    assert(not (other_needs_side and not otherSide), "The other Inventory requires a side to be specified (init, setSide, or pass in)")
    assert(not (other_needs_side and not SIDES[otherSide]), "The other Inventory requires a side, the side is invalid")


    return true
end

function Inventory:sync() -- updates "contents"
    self.contents = self.api.list()
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
    local otherSide = otherSideOrNil or (isInventory(other) and other.sideSpecified) or nil
    local selfSidedName = self.name .. "." .. selfSide .. "_side"
    local otherSidedName = otherName .. "." .. otherSide .. "_side"

    local ret = nil

    if self.needs_side then -- You can't call from a peripheral that needs a side
        ret = native.call(otherName, "pullItems", selfSidedName, fromSlot, limitOrNil, toSlotOrNil)
    elseif needsSideSpecified(other) then
        ret = self.api.pushItems(otherSidedName, fromSlot, limitOrNil, toSlotOrNil)
    else
        ret = self.api.pushItems(otherName, fromSlot, limitOrNil, toSlotOrNil)
    end

    self:sync()

    if isInventory(other) then
        other:sync()
    end

    return ret
end

function Inventory:pull(other, fromSlot, limitOrNil, toSlotOrNil, selfSideOrNil, otherSideOrNil)
    self:assertValidOperation(other, selfSideOrNil, otherSideOrNil)

    local otherName = p_utils.getName(other)

    local selfSide = selfSideOrNil or self.sideSpecified or nil
    local otherSide = otherSideOrNil or (isInventory(other) and other.sideSpecified) or nil
    local selfSidedName = self.name .. "." .. selfSide .. "_side"
    local otherSidedName = otherName .. "." .. otherSide .. "_side"

    local ret = nil

    if self.needs_side then -- You can't call from a peripheral that needs a side
        ret = native.call(otherName, "pushItems", selfSidedName, fromSlot, limitOrNil, toSlotOrNil)
    elseif needsSideSpecified(other) then
        ret = self.api.pullItems(otherSidedName, fromSlot, limitOrNil, toSlotOrNil)
    else
        ret = self.api.pullItems(otherName, fromSlot, limitOrNil, toSlotOrNil)
    end

    self:sync()

    if isInventory(other) then
        other:sync()
    end

    return ret
end


return Inventory