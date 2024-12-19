local peripheral = _G.peripheral

local utils = require "KA_CC.modules.utils"

local p_utils = {}

p_utils.PERIPHERAL_CLASS_NAME = "KA_Peripheral"
p_utils.INVENTORY_CLASS_NAME = "KA_Inventory"


function p_utils.isPeripheralCC(peripheral)
    local mt = getmetatable(peripheral)
    if not mt or mt.__name ~= "peripheral" or type(mt.types) ~= "table" then
        return false
    end
    return true
end

function p_utils.isName(name)
    return peripheral.isPresent(name)
end

function p_utils.isPeripheral(Peripheral)
    return utils.isClass(Peripheral, p_utils.PERIPHERAL_CLASS_NAME)
end

function p_utils.isInventory(Inventory)
    return utils.isClass(Inventory, p_utils.INVENTORY_CLASS_NAME)
end

return p_utils