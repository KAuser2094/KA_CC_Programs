local peripheral = _G.peripheral

local utils = {}

function utils.isPeripheral(peripheral)
    local mt = getmetatable(peripheral)
    if not mt or mt.__name ~= "peripheral" or type(mt.types) ~= "table" then
        return false
    end
    return true
end

function utils.isName(name)
    return peripheral.isPresent(name)
end

return utils