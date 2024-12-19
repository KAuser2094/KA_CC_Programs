local class = require "KA_CC.modules.class"
local p_utils = require "KA_CC.peripheral.utils"
local utils = require "KA_CC.modules.utils"

local native = _G.peripheral

local Peripheral = class()

function Peripheral:init(peripheral_or_name)
    -- peripheral could be its exact name, a direction, etc etc.
    local name = ""
    local peripheral = {}
    if p_utils.isPeripheralCC(peripheral_or_name) then
        peripheral = peripheral_or_name
        name = native.getName(peripheral_or_name)
    elseif p_utils.isName(peripheral_or_name) then
        peripheral = native.wrap(peripheral_or_name)
        name = peripheral_or_name
    else
        error("Invalid Input for peripheral or peripheral name")
    end
    
    self.api = peripheral -- How to call normal wrap of peripheral
    self.name = name -- Name on network

    local version = utils.getVersion()
    if version >= 1.99 then
        self.types = native.getType(name) -- technically a table of values...maybe? (It changes in a later version...1.99)
    else
        self.type = native.getType(name)
    end
    
    -- Make it so that this can be used instead of normal peripherals. (So any dot function should exist)
    local methods = native.getMethods(name)
    for _, method in ipairs(methods) do
        self[method] = function(...)
            return native.call(self.name, method, ...)
        end
    end

    self:addClass(p_utils.PERIPHERAL_CLASS_NAME)
end

return Peripheral