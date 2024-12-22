local utils = require "KA_CC.modules.utils"
local expect = require "cc.expect".expect -- Can't use customn one here
-- From http://lua-users.org/wiki/SimpleLuaClasses with quite a few modifications

-- DONE:
-- Each class has a name (This ends up weirdly helpful).
-- Can add getters and setters by calling the function with the property name and function.
-- Has implementation of publish-subscribe model. Call <class>:addSubscriber(eventName, callback) and run self:_notifyEvent(eventName, ...) when event should occur.
-- NOTE: For above I recommend adding a static EVENTS Enum table, however "class" does not enforce this.
-- Removes case sensitivity for keys (and thereby functions and properties of class). Do not expect .X and .x to be different. (Technically they still are since removing case sensitivity is a fallback) 

-- TODO:
-- Multiple base classes, for "implements" and for "extends". Including checks for valid implementation by adding functions that need to be impemented to a list
-- (maybe) Doc maker, a function that allows you to pass in a function and doc string and stores the documentation. 
-- ... Then you can call a function to get all docs. And another to pass in a function and gets its docs

-- DO THIS: add a function that allows you to set a function to be non-case sensitive instead of presuming they all are.

local function expectFunction(index, value)
    expect(2, value, "function", "table")
    if type(callback) == "table" then
        assert(getmetatable(value) and getmetatable(value).__call, "value is a table but not callable at " .. index) -- needs to act like a function
    end
end

local module = {}

local function class(name, base)
    expect(1, name, "string")
    expect(2, base, "table", "nil")

    local cls = {}

    -- INHERITANCE
    if base and type(base) == 'table' then
        utils.shallowMerge(cls, base)
        cls.super = base
    end

    -- OVERWRITES FIELDS
    cls._className = name or cls._className or "KA_Class" -- Use own first, then base, then generic
    cls._subsribers = {} -- For publish-subscribe model

    -- INHERITS FIELDS
    cls._properties = cls._properties or {} -- For getters and setters
    cls._case_insensitive = cls._case_insensitive or {} -- For case insensitivity on fields and methods

    cls.__tostring = cls.__tostring or function (self)
        self:getClassName()
    end

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
        expect(1, klass, "table", "string")
        if type(klass) == "table" then
            assert(klass._className, "Not a class or className, cannot check if isClass")
        end
        local klass_name = type(klass) == "string" and klass or klass._className
        local self_classes = self:getAllClassNames()

        return utils.hasValue(self_classes, klass_name)
    end

    function cls:hasClass(klass) return self:isClass(klass) end -- alternate name

    function cls:getClassName()
        return cls._className -- You would think that "getmetatable(self)" could be used instead of "cls", but it errors here.
    end

    function cls:getAllClassNames()
        local names = {}
        local mt = getmetatable(self)
        while mt do
            table.insert(names, mt._className)
            mt = mt.super
        end

        table.insert(names, "KA_Class")

        return names
    end

    -- PUBLISH-SUBSCRIBE
    function cls:addSubscriber(eventName, callback)
        expect(1, eventName, "string", "number")
        expectFunction(2, callback)

        if not self._subsribers[eventName] then
            self._subsribers[eventName] = {}
        end
        table.insert(self._subsribers[eventName], callback)
    end

    function cls:_notifyEvent(eventName, ...)
        expect(1, eventName, "string", "number")
        if self._subsribers[eventName] then
            for _, callback in ipairs(self._subsribers[eventName]) do
                callback(self, ...)
            end
        end
    end

    -- REMOVE CASE SENSITIVITY
    function cls:removeCaseSensitive(true_key)
        expect(1, true_key, "string") -- For obvious reasons, don't try and do this with a non string
        local lower_key = string.lower(true_key)
        self._case_insensitive[lower_key] = true_key
    end

    -- PROPERTIES (GETTER/SETTER)
    function cls:addGetter(propName, getterFunc) -- CAN be self
        expect(1, propName, "string", "number", "table", "function") -- How would a function as a key work?
        expectFunction(2, getterFunc)
        local lower_propName = type(propName) == "string" and string.lower(propName) or nil -- For case insensitivity
        if not self._properties[lower_propName and lower_propName or propName] then
            self._properties[lower_propName and lower_propName or propName] = {}
            self._properties[lower_propName and lower_propName or propName]["getter"] = getterFunc
        end
    end

    function cls:addSetter(propName, setterFunc) -- CANNOT be self
        expect(1, propName, "string", "number", "table", "function") -- How would a function as a key work?
        expectFunction(2, setterFunc)
        local lower_propName = type(propName) == "string" and string.lower(propName) or nil -- For case insensitivity
        if not cls._properties[lower_propName and lower_propName or propName] then
            cls._properties[lower_propName and lower_propName or propName] = {}
            cls._properties[lower_propName and lower_propName or propName]["setter"] = setterFunc
        end
    end

    -- SET THE INDEX AND NEW_INDEX

    cls.__index = function(tbl, key) -- NOTE: This is also how we are making the whole class work, it will automatically fallback onto the "cls" which holds the class methods
        local lower_key = type(key) == "string" and string.lower(key) or nil -- For case insensitivity

        -- Call the getter functions if possible
        if (cls._properties[lower_key and lower_key or key] and cls._properties[lower_key and lower_key or key].getter) then 
            return cls._properties[lower_key and lower_key or key].getter(tbl)
        end

        -- Check if the lower_key is in the case insensitive table

        if lower_key and cls._case_insensitive[lower_key] then
            local true_key = cls._case_insensitive[lower_key]

            local try = rawget(cls, true_key) -- This usually works 99% of the time
            return try and try or rawget(tbl, true_key) -- SPECIFICALLY for instance fields (defined self.<key> = <value> since they don't live in cls and would never be called here normally)
        end
        -- Works like normal
        return rawget(cls, key)
    end

    cls.__newindex = function(tbl, key, value)
        local lower_key = type(key) == "string" and string.lower(key) or nil -- For case insensitivity

        -- Call the setter functions if possible
        if (lower_key and cls._properties[lower_key] and cls._properties[lower_key].setter) then
            return cls._properties[lower_key].setter(tbl, value)
        end

        -- Works like normal
        return rawset(tbl, key, value)
    end


-- RETURNS
    return cls
end

module.Class = class

setmetatable(module, {
    __call = function (_,...)
        return class(...)
    end
})

return module