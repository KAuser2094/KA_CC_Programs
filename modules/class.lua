local utils = require "KA_CC.modules.utils"
-- From http://lua-users.org/wiki/SimpleLuaClasses
local function class(name, base)
    local cls = {}

    -- INHERITANCE
    if base and type(base) == 'table' then
        utils.shallowMerge(cls, base)
        cls._super = base
    end

    -- OVERWRITES FIELDS
    cls._className = name
    cls._subsribers = {} -- For publish-subscribe model

    -- INHERITS FIELDS
    cls._properties = cls._properties or {}
    

    -- CONSTRUCTOR
    function cls:new(...)
        local instance = setmetatable({}, cls)
        if instance.init then
            instance:init(...)
        end
        return instance
    end

    -- MAKE TABLE CALLABLE
    setmetatable(cls, {
        __call = function(_, ...)
            return cls:new(...)
        end,
    })

    -- GENERIC CLASS FUNCTIONS
    function cls:isClass(klass)
        local self_classes = self:getAllClassNames()
        local mt = getmetatable(self)
        while mt do
            if mt._className == klass._className then return true end
            mt = mt._super
        end
        return false
    end

    function cls:getClassName()
        return cls._className -- You would think that "getmetatable(self)" could be used instead of "cls", but it errors here.
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
    function cls:addSubscriber(eventName, callback)
        if not self._subsribers[eventName] then
            self._subsribers[eventName] = {}
        end
        table.insert(self._subsribers[eventName], callback)
    end

    function cls:_notifyEvent(eventName, ...)
        if self._subsribers[eventName] then
            for _, callback in ipairs(self._subsribers[eventName]) do
                callback(self, ...)
            end
        end
    end

    -- PROPERTIES (GETTER/SETTER)
    function cls:addGetter(propName, getterFunc)
        if not self._properties[propName] then
            self._properties[propName] = {}
        end
        self._properties[propName].getter = getterFunc
    end

    function cls:addSetter(propName, setterFunc)
        if not self._properties[propName] then
            self._properties[propName] = {}
        end
        self._properties[propName].setter = setterFunc
    end

    cls.__index = function(tbl, key) -- NOTE: This is also how we are making the whole class work, it will automatically fallback onto the "cls" which holds the class methods
        if cls._properties[key] and cls._properties[key].getter then
            return cls._properties[key].getter(tbl) -- Call the getter function
        end
        return rawget(cls, key) -- Fallback to normal indexing
    end

    cls.__newindex = function(tbl, key, value)
        if cls._properties[key] and cls._properties[key].setter then
            return cls._properties[key].setter(tbl, value)
        end
        rawset(tbl, key, value)
    end


-- RETURNS
    return cls
end

return class