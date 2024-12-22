local class = require "KA_CC.modules.class.class"
local extends = require "KA_CC.modules.class.extends"
local simple = require "KA_CC.modules.class.simple"

local module = {}

local function ClassExtendsAll(name, ...) -- Get a class with all extensions (as defined by extends.ALL)
    return Class(name, extends.ALL, ...)
end

module.Class = class
module.ExpandedClass = ClassExtendsAll
module.SimpleClass = simple
module.Extends = extends

setmetatable(module, {
    __call = function (_,...)
        return class(...)
    end
})

return module