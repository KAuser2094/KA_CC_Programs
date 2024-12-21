local utils = require "KA_CC.modules.utils"
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

local function class(name, base)
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
        -- TODO: Expect a "KA_Class" or string
        if not klass then return false end -- TEMPORARY
        local klass_name = type(klass) == "string" and klass or klass._className
        local self_classes = self:getAllClassNames()

        return utils.hasValue(self_classes, klass_name)
    end

    function cls:hasClass(klass) return self:isClass(klass) end

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
    function cls:addGetter(propName, getterFunc) -- CAN be self
        local lower_propName = type(propName) == "string" and string.lower(propName) or nil -- For case insensitivity
        if not self._properties[lower_propName and lower_propName or propName] then
            self._properties[lower_propName and lower_propName or propName] = {}
            self._properties[lower_propName and lower_propName or propName]["getter"] = getterFunc
        end
    end

    function cls:addSetter(propName, setterFunc) -- CANNOT be self
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
        if (cls._properties[key] and cls._properties[key].getter) then 
            return cls._properties[key].getter(tbl)
        end

        -- Try again with lower case (removes case sensitivity)
        if (lower_key and cls._properties[lower_key] and cls._properties[lower_key].getter) then
            return cls._properties[lower_key].getter(tbl)
        end

        -- Check if the lower_key is in the case insensitive table (only works for instance values -_-)
        if lower_key and cls._case_insensitive[lower_key] then
            return cls._case_insensitive[lower_key]
        end

        -- Manually loop over keys for static and instance methods
        if lower_key then
            for k,v in pairs(cls) do
                local lower_k = type(k) == "string" and string.lower(k) or nil
                if lower_k == lower_key then
                    cls._case_insensitive[lower_key] = v -- Add to table so you don't need to do this again
                    return v
                end
            end
        end

        -- Works like normal
        return rawget(cls, key)
    end

    cls.__newindex = function(tbl, key, value)
        local lower_key = type(key) == "string" and string.lower(key) or nil -- For case insensitivity

        if (lower_key and cls._properties[lower_key] and cls._properties[lower_key].setter) then -- setters should automatically be normalised to lower
            return cls._properties[lower_key].setter(tbl, value)
        end

        -- Add to insensitive table (only works for instance fields for some reason)
        if lower_key then
            cls._case_insensitive[lower_key] = value
        end

        -- Works like normal
        return rawset(tbl, key, value)
    end


-- RETURNS
    return cls
end

return class