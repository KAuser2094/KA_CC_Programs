local utils = require "KA_CC.modules.utils"
-- From http://lua-users.org/wiki/SimpleLuaClasses
local function class(name, base)
    local cls = {}
    -- Inheritance
    if base and type(base) == 'table' then
        utils.shallowMerge(cls, base)
        cls._super = base
    end
    -- Overwrites from base
    cls._className = name
    cls._subsribers = {} -- For publish-subscribe model
    
    cls.__index = cls -- Use the fact that __index will be called on fallback

    -- Constructor
    function cls:new(...)
        local instance = setmetatable({}, cls)
        if instance.init then
            instance:init(...)
        end
        return instance
    end
    -- Lets you call <class>(<args>)
    setmetatable(cls, {
        __call = function(_, ...)
            return cls:new(...)
        end,
    })

    -- GENERIC CLASS FUNCTIONS
    function cls:isClass(klass)
        local mt = getmetatable(self)
        while mt do
            if mt == klass then return true end
            mt = mt._super
        end
        return false
    end

    function cls:getClassName()
        return cls._className
    end

    function cls:getAllClassNames()
        local names = {}
        local mt = getmetatable(self)
        while mt do
            table.insert(names, mt._className)
            mt = mt._super
        end

        table.insert(names, "KA_Class")

        return names
    end
    -- PUBLISH-SUBSCRIBE
    function cls:subscribeEvent(eventName, callback)
        if not cls._subsribers[eventName] then
            cls._subsribers[eventName] = {}
        end
        table.insert(cls._subsribers[eventName], callback)
    end

    function cls:_notifyEvent(eventName, ...)
        if cls._subsribers[eventName] then
            for _, callback in ipairs(cls._subsribers[eventName]) do
                callback(self, ...)
            end
        end
    end


-- RETURNS
    return cls
end

return class