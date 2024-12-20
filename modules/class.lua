local utils = require "KA_CC.modules.utils"
-- From http://lua-users.org/wiki/SimpleLuaClasses
local function class(base)
    local cls = {}
    if base and type(base) == 'table' then
        utils.shallowMerge(cls, base)
        cls.super = base
    end

    cls.__index = cls -- Use the fact that __index will be called on fallback


    function cls:new(...)
        local instance = setmetatable({}, cls)
        if instance.init then
            instance:init(...)
        end
        return instance
    end

    function cls:addClass(className)
        if not cls.class then
            cls.class = {}  -- Initialize the class table if not already done
        end
        if not utils.containsValue(cls.class, className) then
            table.insert(cls.class, className)
        end
    end

    function cls:isClass(className)
        if not cls.class then
            return false
        end
        for _, name in ipairs(cls.class) do
            if name == className then
                return true
            end
        end
        return false
    end

    setmetatable(cls, {
        __call = function(_, ...)
            return cls:new(...)
        end
    })

    function cls:is_a(klass)
        local m = getmetatable(self)
        while m do
            if m == klass then return true end
            m = m._super
        end
        return false
    end

    return cls
end

return class