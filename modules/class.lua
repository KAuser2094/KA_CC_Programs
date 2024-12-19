local req = require "KA_CC.require"
local utils = req "utils"
local function class(base)
    local cls = {}
    cls.__index = cls -- Use the fact that __index will be called on fallback

    if base then
        setmetatable(cls, { __index = base })
        cls.super = base
    end

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

    return cls
end

return class