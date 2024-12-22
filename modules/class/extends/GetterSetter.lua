-- Lets you create getter and setter functions that will act as fields.
local Class = require "KA_CC.modules.class.class"

local GetterSetter = Class("KA_GetterSetter")

local helper = GetterSetter.__helper

local shallowMergeWithPreserve = helper.shallowMergeWithPreserve

GetterSetter.__classProperties = {} -- Stores getters and setters

GetterSetter.__preserveKeys["__classProperties"] = true -- Want to add not replace

function GetterSetter:addGetter(propName, getterFunc)
    local lower_propName = type(propName) == "string" and string.lower(propName) or nil -- For case insensitivity
    if not self.__classProperties[lower_propName and lower_propName or propName] then
        self.__classProperties[lower_propName and lower_propName or propName] = {}
        self.__classProperties[lower_propName and lower_propName or propName]["getter"] = getterFunc
    end
end

function GetterSetter:addSetter(propName, setterFunc)
    local lower_propName = type(propName) == "string" and string.lower(propName) or nil -- For case insensitivity
    if not self.__classProperties[lower_propName and lower_propName or propName] then
        self.__classProperties[lower_propName and lower_propName or propName] = {}
        self.__classProperties[lower_propName and lower_propName or propName]["setter"] = setterFunc
    end
end

-- -- Hooks

local function getGetter(cls, tbl, key)
    local lower_key = type(key) == "string" and string.lower(key) or nil -- For case insensitivity

    -- Call the getter functions if possible
    if (cls.__classProperties[lower_key and lower_key or key] and cls.__classProperties[lower_key and lower_key or key].getter) then
        return cls.__classProperties[lower_key and lower_key or key].getter(tbl)
    end
end

GetterSetter:addIndexHook(getGetter)

local function getSetter(cls, tbl, key, value)
    local lower_key = type(key) == "string" and string.lower(key) or nil -- For case insensitivity

    -- Call the setter functions if possible
    if (lower_key and cls.__classProperties[lower_key] and cls.__classProperties[lower_key].setter) then
        return cls.__classProperties[lower_key].setter(tbl, value)
    end
    
end

GetterSetter:addNewIndexHook(getSetter)

local function inheritGettersAndSetters(base, klass)
    klass.__classProperties = klass.__classProperties or {}
    shallowMergeWithPreserve(klass.__classProperties, base.__classProperties)
end

GetterSetter:addInheritsHook(inheritGettersAndSetters)

return GetterSetter