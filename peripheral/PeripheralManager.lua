local class = require "KA_CC.modules.class"
local Peripheral = require "KA_CC.peripheral.Peripheral"
local p_utils = require "KA_CC.peripheral.p_utils"
local utils = require "KA_CC.modules.utils"

local native = _G.peripheral

local function isPeripheral(p)
    return type(p) == 'table' and p.isClass and p:isClass(Peripheral)
end

local function isPeripheralOrWrappedOrName(p)
    if type(p) == 'table' then
        return isPeripheral(p) or p_utils.isWrapped(p)
    elseif type(p) == 'string' then
        return p_utils.isName(p)
    else
        return False
    end
end

local function toPeripheral(PeripheralOrWrappedOrName) -- TODO: Should convert to highest level of class possible
    assert(isPeripheralOrWrappedOrName(PeripheralOrWrappedOrName), "Not a valid input to become/already is Peripheral")
    if isPeripheral(PeripheralOrWrappedOrName) then return PeripheralOrWrappedOrName end
    return Peripheral(PeripheralOrWrappedOrName)
end

PeripheralManager = class("KA_Peripheral_Manager") -- What the heck is this meant to do

function PeripheralManager:init(PeripheralOrWrappedOrNameOrTable, filterFunc)
    self.list = {} -- This is a horrible name but it works and isn't stupidly long
    -- Add starting peripherals
    if type(PeripheralOrWrappedOrNameOrTable) == 'table' then
        self:addPeripherals(PeripheralOrWrappedOrNameOrTable, filterFunc)
    else
        assert(isPeripheralOrWrappedOrName(PeripheralOrWrappedOrNameOrTable))
        self:addPeripheral(PeripheralOrWrappedOrNameOrTable, filterFunc)
    end

    self:prune(true)
end

function PeripheralManager:hasPeripheral(p)
    return utils.hasValue(self.list, p) -- Linear search and check if any p2 in list == p given
end

function PeripheralManager:addPeripheral(PeripheralOrWrappedOrName, filterFunc)
    local per = toPeripheral(PeripheralOrWrappedOrName)

    if not self:hasPeripheral(per) and (not filterFunc or filterFunc(per)) then -- not already there, and either there is no filter or the filter passes
        table.insert(self.list, per)
    end
end

function PeripheralManager:addPeripherals(PeripheralOrWrappedOrNameTable, filterFunc)
    for _,v in pairs(PeripheralOrWrappedOrNameTable) do
        self:addPeripheral(v, filterFunc)
    end
end

function PeripheralManager:prune(removeNotOnNetwork)
    -- remove duplicates
    self.list = utils.removeDuplicates(self.list)
    -- remove no longer in network (Could be bad in case of temporary networks that may cut off)
    if removeNotOnNetwork then
        local names = native.getNames()
        local filter = utils.partialFunction(utils.hasValue(names)) -- Takes in a value and checks if the valie is in names
        local name_filter = function (p)
            return filter(p.name)
        end
        self.list = utils.filterIndex(self.list, name_filter)
    end
end
-- TODO: Conversion functions (to Peripheral to Inventory etc)
return PeripheralManager