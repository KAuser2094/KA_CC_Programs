local class = require "KA_CC.modules.class.class"
local mixins = require "KA_CC.modules.class.mixins"
local simple = require "KA_CC.modules.class.simple"

local module = {}

local function ClassExtendsAll(name, ...) -- Get a class with all extensions (as defined by mixins.ALL)
    return Class(name, mixins.ALL, ...)
end

module.Class = class
module.ExpandedClass = ClassExtendsAll
module.SimpleClass = simple
module.MixIn = mixins

setmetatable(module, {
    __call = function (_,...)
        return class(...)
    end
})

return module