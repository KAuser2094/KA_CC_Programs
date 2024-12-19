local req = require "KA_CC.require"

local class = req "class"
local Peripheral = req "peripheral.Peripheral"

local Inventory = class(Peripheral)

function Inventory:init(peripheral_or_name)
    self.super.init(self, peripheral_or_name) -- .init(self, ...) == :init(...)

    if not self.api.list() then
        error("Not an inventory peripheral")
    end

    self:addClass("KA_inventory")
end

return Inventory