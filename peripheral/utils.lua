local native = _G.peripheral

local utils = require "KA_CC.modules.utils"

local p_utils = {}

p_utils.PERIPHERAL_CLASS_NAME = "KA_Peripheral"
p_utils.INVENTORY_CLASS_NAME = "KA_Inventory"


function p_utils.isWrapped(wrapped)
    local mt = type(wrapped) == 'table' and getmetatable(wrapped)
    if not mt or mt.__name ~= "peripheral" then
        return false
    end
    return true
end

function p_utils.isName(name)
    return type(name) == 'string' and native.isPresent(name)
end

function p_utils.getClassFields(wrappedOrName)
    local peripheral = nil
    local name = nil

    local type = nil
    local types = nil
    
    local mod = nil
    local mods = nil

    if p_utils.isWrapped(wrappedOrName) then
        peripheral = wrappedOrName
        name = native.getName(peripheral)
    elseif p_utils.isName(wrappedOrName) then
        peripheral = native.wrap(wrappedOrName)
        name = wrappedOrName
    else
        error("passed in value was not a native peripheral or a name on the network: " .. wrappedOrName)
    end

    local version = utils.getVersion()
    if version >= 1.99 then
        types = native.getType(name) -- technically a table of values...maybe? (It changes in a later version...1.99)
    else
        type = native.getType(name)
    end

    mod = p_utils.getMod(peripheral)

    return peripheral, name, type, types, mod
end

function p_utils.getName(PeripheralOrWrappedOrName)
    if p_utils.isPeripheral(PeripheralOrWrappedOrName) then
        return PeripheralOrWrappedOrName.name
    elseif p_utils.isWrapped(PeripheralOrWrappedOrName) then
        return native.getName(PeripheralOrWrappedOrName)
    elseif p_utils.isName(PeripheralOrWrappedOrName) then
        return PeripheralOrWrappedOrName
    else
        error("Invalid input")
    end
end

function p_utils.getMod(Wrapped) -- TODO: actually do the logic to allow a Peripheral or a Name to be passed in. Too lazy right now
    return Wrapped.getMetadata()["name"]:match(("([^:]+)")) -- From the meta data, get the "name" and strip everything before the first :
end

return p_utils