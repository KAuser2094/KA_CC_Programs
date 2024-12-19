local class = require "KA_CC.modules.class"
local Peripheral = require "KA_CC.peripheral.Peripheral"
local p_utils = require "KA_CC.peripheral.utils"
local utils = require "KA_CC.modules.utils"

local _p = _G.peripheral

local Inventory = class(Peripheral)

function Inventory:init(peripheral_or_name)
    self.super.init(self, peripheral_or_name) -- .init(self, ...) == :init(...)

    if not self.api.list then
        error("Not an inventory peripheral")
    end

    self:addClass(p_utils.INVENTORY_CLASS_NAME)
    self:sync()
end

function Inventory:sync() -- updates "contents"
    self.contents = self.api.list()
end

function Inventory:rearrange(fromSlot, limit, toSlot)
    local ret = self.api.pushItems(self.name, fromSlot, limit, toSlot)
    self:sync()
    return ret
end

function Inventory:push(other, fromSlot, limit, toSlot)
    if p_utils.isInventory(other) then
        local ret = self.api.pushItems(other.name, fromSlot, limit, toSlot)
        self:sync()
        other:sync()
        return ret
    elseif p_utils.isPeripheralCC(other) then
        local ret = self.api.pushItems(_p.getName(other), fromSlot, limit, toSlot)
        self:sync()
        return ret
    elseif p_utils.isName(other) then
        local ret = self.api.pushItems(other, fromSlot, limit, toSlot)
        self:sync()
        return ret
    else
        error("Invalid 'other': " .. other)
    end
end

function Inventory:pull(other, fromSlot, limit, toSlot)
    if p_utils.isInventory(other) then
        local ret = self.api.pullItems(other.name, fromSlot, limit, toSlot)
        self:sync()
        other:sync()
        return ret
    elseif p_utils.isPeripheralCC(other) then
        local ret = self.api.pullItems(_p.getName(other), fromSlot, limit, toSlot)
        self:sync()
        return ret
    elseif p_utils.isName(other) then
        local ret = self.api.pullItems(other, fromSlot, limit, toSlot)
        self:sync()
        return ret
    else
        error("Invalid 'other': " .. other)
    end
end


return Inventory