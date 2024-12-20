local class = require "KA_CC.modules.class"
local p_utils = require "KA_CC.peripheral.utils"

local native = _G.peripheral

local Peripheral = class("KA_Peripheral")

function Peripheral:init(wrappedOrName)
    self.api, self.name, self.type, self.types, self.mod, self.mods = p_utils.getClassFields(wrappedOrName)
    
    -- Make it so that this can be used instead of normal peripherals. (So any dot function should exist)
    local methods = native.getMethods(self.name)
    for _, method in ipairs(methods) do
        self[method] = function(...)
            return native.call(self.name, method, ...)
        end
    end
end

return Peripheral