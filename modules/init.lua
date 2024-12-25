-- "KA_CC.modules"
local class = require "KA_CC.modules.class"
local expect = require "KA_CC.modules.expect"
local tabula = require "KA_CC.modules.tabula"
local utils = require "KA_CC.modules.utils"

local modules = {}

modules.class = class
modules.expect = expect
modules.tabula = tabula
modules.utils = utils

return modules