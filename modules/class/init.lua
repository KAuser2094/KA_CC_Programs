local class = require "KA_CC.modules.class.class"
local mixins = require "KA_CC.modules.class.mixins"
local simple = require "KA_CC.modules.class.simple"

local module = {}

module.Class = class
module.SimpleClass = simple
module.MixIns = mixins

setmetatable(module, {
    __call = function (_,...)
        return class(...)
    end
})

return module