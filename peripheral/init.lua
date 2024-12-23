-- Collect the classes and define some extra functions
local Peripheral = require "KA_CC.peripheral.Peripheral"
local Inventory = require "KA_CC.peripheral.Inventory"
local utils = require "KA_CC.peripheral.utils"

local module = {}

module.Peripheral = Peripheral
module.Inventory = Inventory
module.utils = utils

return module