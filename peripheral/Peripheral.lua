local Class = require "KA_CC.modules.class".Class
local utils = require "KA_CC.modules.utils"
local e = require "KA_CC.modules.expect"
local p_utils = require "KA_CC.peripheral.utils"

local native = _G.peripheral

local Peripheral = Class("KA_Peripheral")

function Peripheral:init(wrappedOrName)
    e.expect("Peripheral.init.wrappedOrName", wrappedOrName, "table", "string")
    self.api, self.name, self.type, self.types, self.mod, self.mods = p_utils.getClassFields(wrappedOrName)
    
    -- Make it so that this can be used instead of normal peripherals. (So any dot function should exist)
    local methods = native.getMethods(self.name)
    for _, method in ipairs(methods) do
        self[method] = function(...)
            return native.call(self.name, method, ...)
        end
    end
end

function Peripheral:onNetwork()
    local network = native.getNames()
    return utils.hasSubset(network, self.name)
end

function Peripheral.__eq(self, other)
    return self.name == other.name
end

function Peripheral.__tostring(self)
    return self:getClassName() .. ": " .. self.name
end

return Peripheral