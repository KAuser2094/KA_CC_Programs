local native = _G.native

local utils = require "KA_CC.modules.utils"

local p_utils = {}

p_utils.PERIPHERAL_CLASS_NAME = "KA_Peripheral"
p_utils.INVENTORY_CLASS_NAME = "KA_Inventory"


function p_utils.isPeripheralNative(peripheralNative)
    local mt = getmetatable(peripheralNative)
    if not mt or mt.__name ~= "peripheral" or type(mt.types) ~= "table" then
        return false
    end
    return true
end

function p_utils.isName(name)
    return native.isPresent(name)
end

function p_utils.isPeripheral(Peripheral)
    return utils.isClass(Peripheral, p_utils.PERIPHERAL_CLASS_NAME)
end

function p_utils.isInventory(Inventory)
    return utils.isClass(Inventory, p_utils.INVENTORY_CLASS_NAME)
end

function p_utils.getClassFields(nativeOrName)
    local peripheral = nil
    local name = nil

    local type = nil
    local types = nil
    
    local mod = nil
    local mods = nil

    if p_utils.isPeripheralNative(nativeOrName) then
        peripheral = nativeOrName
        name = native.getName(peripheral)
    elseif p_utils.isName(nativeOrName) then
        peripheral = native.wrap(nativeOrName)
        name = nativeOrName
    end

    local version = utils.getVersion()
    if version >= 1.99 then
        types = native.getType(name) -- technically a table of values...maybe? (It changes in a later version...1.99)
    else
        type = native.getType(name)
    end

     -- NOTE: The below does not really work alot of the time...given we are just stripping the before the semicolon. It does work for ic2 however.
     if types then -- Has a list of types
        mods = {}
        for _,v in ipairs(types) do
            table.insert(mods, v:match("([^:_]+)"))
        end
    elseif type then -- Singular Type
        mod = type:match("([^:_]+)")
    else
        error("No Type or Types to extract mod from")
    end

    return peripheral, name, type, types, mod, mods
end

function p_utils.getName(PeripheralOrNativeOrName)
    if p_utils.isPeripheral(PeripheralOrNativeOrName) then
        return PeripheralOrNativeOrName.name
    elseif p_utils.isPeripheralNative(PeripheralOrNativeOrName) then
        return native.getName(PeripheralOrNativeOrName)
    elseif p_utils.isName(PeripheralOrNativeOrName) then
        return PeripheralOrNativeOrName
    else
        error("Invalid input")
    end
end

return p_utils