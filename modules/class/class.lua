-- local Class = require "KA_CC.modules.class.new_class"
-- local Class = require "KA_CC.modules.class".Class

-- MAYBE:
-- Add "remove" methods for inheritance stuff, right now if you add a rule to a field/method it MUST propogate up. An inheriting class may want to disable it.

local type = type

local function expectCallable(_index, value, custom_err)
    local index = _index and _index or "N/A"
    local err = custom_err and custom_err or "value is not callable at " .. index .. " has type: " .. type(value)
    assert(type(value) == "function" or type(value) == "table", err)
    if type(value) == "table" then
        assert(getmetatable(value) and getmetatable(value).__call, err) -- needs to act like a function
    end
    return value
end

local function expectClass(index, value)
    local err = "Expected a class at " .. index
    assert(type(value) == "table", err)
    assert(value.__className, err)
    return value
end

local function bothExactSameClass(lhs, rhs)
    -- MUST either be a string or a class, error otherwise
    local lhsName = type(lhs) == "string" and lhs or expectClass("bothExactSameClass.lhs", lhs):getClassName()
    local rhsName = type(rhs) == "string" and rhs or expectClass("bothExactSameClass.rhs", rhs):getClassName()
    return lhsName == rhsName
end

local function PRESERVE_KEYS() 
    return { -- Do not copy these over when inheriting (at least don't override them)
    -- Don't change (defaults or top class values)
    __className = true,
    __helper = true,
    __default = true,
    -- Stuff you should add not replace (merge the values (the tables) not the keys (which replaces a table)
    __preserveKeys = true,
    __mergeKeys = true,
    __deepMergeKeys = true,
    __inherits = true,
    __abstractFields = true,
    __abstractMethods = true,
    ---- Hooks
    __hooks = true, -- TODO: !! THIS NEEDS TO BE A DEEP MERGE UP, don't use simply MERGES_UP
    }
end

local function MERGES_UP()
    return { -- Merge the table up (or overwrite if it doesnt exist)
    __inherits = true,
    __abstractFields = true,
    __abstractMethods = true,
    }
end

local function DEEP_MERGES_UP()
    return {
        __hooks = true,
    }
end

local function shallowMerge(tbl, other)
    for k,v in pairs(other) do
        tbl[k] = v
    end
end

local function deepMerge(tbl, other)
    for k, v in pairs(other) do
        if type(v) == "table" then
            tbl[k] = tbl[k] or {} -- Presumes same shape of tables (ignoring other types)
            deepMerge(tbl[k], v)
        else
            tbl[k] = v
        end
    end
end

local function shallowMergeWithPreserve(tbl, other, preserveOrNil)
    for k,v in pairs(other) do
        if (preserveOrNil and preserveOrNil[k]) then -- Case: Preserve
            -- print("Preserved " .. k)
        else -- Case: Overwrite
            tbl[k] = v
        end
    end
end

local BASIC_HOOKS = {
    INDEX = "INDEX_HOOK",
    NEW_INDEX = "NEW_INDEX_HOOK",
    INHERITS = "INHERITS_HOOK",
    POST_INIT = "POST_INIT_HOOK",
    WELLFORMED = "WELLFORMED_HOOK",
}

-- local YouClassName = Class(YouClassNameString, Class_i?...Class_n?)
-- Note: NO checks for conflicts by default.
local function class(name, ...)
    ----------------------------------------------------------------------------------------------------
    assert(type(name) == "string", "Name needs to be given and a string")
    ----------------------------------------------------------------------------------------------------
    -- MAKE THE CLASS
    ----------------------------------------------------------------------------------------------------
    
    local base_classes = table.pack(...)

    local cls = {}

    -- Holds a guarenteed base implementation of generic class methods just in case of overrides
    cls.__default = { __className = "KA_Class" } -- Name is just here so it is still treated as a class -- MAYBE: add the local functions into this

    cls.__className = name -- Should not be changed after this
    cs.__BASIC_HOOKS = BASIC_HOOKS
    cls.__preserveKeys = PRESERVE_KEYS() -- preserve the values at those keys. (They should not be overridden, can be added to)
    cls.__mergeKeys = MERGES_UP() -- Table values that are copied up (or set if not yet exists)
    cls.__deepMergeKeys = DEEP_MERGES_UP() -- Same as above but use a deep merge
    -- NOTE: Tables below should be in the form "<className>" = <value> 
    -- Each class should have a unique value in the tables (if any) and we use the fact the table key constraint is the exact same to do this.
    cls.__inherits = {} -- Stores all classes this inherits from
    cls.__abstractMethods = {} -- Holds methods that must be implemented or error, ideally: bubbles up from interfaces
    cls.__abstractFields = {} -- Holds fields that must be implemented or error, ideally: bubbles up from interfaces

    cls.__hooks = {} -- Holds hooks

    if base_classes then
        for i = #base_classes, 1, -1 do
            local klass = base_classes[i]
            expectClass("BaseClass_" .. i, klass)
            klass:inheritsInto(cls)
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- INHERITANCE
    ----------------------------------------------------------------------------------------------------
    
    function cls:_basicInheritInto(klass) -- At a basic level, extends and implements are the exact same. They are just seperated for clarity and extra functionality.
        expectClass("class._basicInheritInto.klass", klass)
        -- Only merge in the ones that are NOT preserved by either class AND bubble/merge up where needed
        shallowMergeWithPreserve(klass.__preserveKeys, self.__preserveKeys)
        shallowMergeWithPreserve(klass, self, klass.__preserveKeys)

        -- Merge/Bubble up needed tables
        shallowMergeWithPreserve(klass.__mergeKeys, self.__mergeKeys)
        for k, v in pairs(klass.__mergeKeys) do
            if v then -- Just in case someone set to false
                klass[k] = klass[k] and klass[k] or {}
                self[k] = self[k] and self[k] or {}
                shallowMerge(klass[k],self[k])
            end
        end
        -- Need to add yourself to the inherits
        klass.__inherits[self:getClassName()] = self -- Set yourself as a base class as well

        -- Deep Merge/Bubble up needed tables
        shallowMergeWithPreserve(klass.__deepMergeKeys, self.__deepMergeKeys)
        for k, v in pairs(klass.__deepMergeKeys) do
            if v then -- Just in case someone set to false
                klass[k] = klass[k] and klass[k] or {}
                self[k] = self[k] and self[k] or {}
                deepMerge(klass[k],self[k])
            end
        end

        -- Any extra work specific classes need
        cls:_execInheritsHook(klass)
    end

    function cls:inheritsInto(klass)
        expectClass("class.inheritsInto.klass", klass)
        self:_basicInheritInto(klass)
    end
    cls.__default.inheritsInto = cls.inheritsInto

    --------------------------------------------------
    ---- Preserved (Not overridden when inheriting)
    -------------------------------------------------- TODO: add Method version? (A bit redundant)
    
    function cls:addPreservedField(key, value)
        self.__preserveKeys[key] = true
        self[key] = value
    end
    cls.__default.addPreservedField = cls.addPreservedField

    --------------------------------------------------
    ---- Bubble (Merges tables instead of overriding when inheriting, merging with nil is the same as with {})
    -------------------------------------------------- TODO: add Method version? (A bit redundant)
    
    function cls:addBubbledField(key, value)
        assert(type(value) == "table", "You can only set a table to be bubbled/merged up")
        self.__preserveKeys[key] = true
        self.__mergeKeys[key] = true
        self[key] = value
    end
    cls.__default.addBubbledField = cls.addBubbledField

    function cls:addDeepBubbledField(key, value)
        assert(type(value) == "table", "You can only set a table to be deep bubbled/merged up")
        self.__preserveKeys[key] = true
        self.__deepMergeKeys[key] = true
        self[key] = value
    end
    cls.__default.addDeepBubbledField = cls.addDeepBubbledField

    ----------------------------------------------------------------------------------------------------
    -- GENERICS
    ----------------------------------------------------------------------------------------------------
    
    function cls:isExactClass(klass)
        local klassName = type(klass) == "string" and klass or (expectClass("class.isExactClass.klass", klass):getClassName())
        if bothExactSameClass(self, klassName) then return true end
    end
    cls.__default.isExactClass = cls.isExactClass

    function cls:inheritsClass(klass)
        local klassName = type(klass) == "string" and klass or (expectClass("class.inheritsClass.klass", klass):getClassName())
        for _,extension in pairs(self.__inherits) do
            if bothExactSameClass(extension, klassName) then return true end
        end
    end
    cls.__default.inheritsClass = cls.inheritsClass

    function cls:isClass(klass)
        local klassName = type(klass) == "string" and klass or (expectClass("class.isClass.klass", klass):getClassName())
        if self:isExactClass(klassName) then return true end
        if self:inheritsClass(klassName) then return true end
    end
    cls.__default.isClass = cls.isClass

    function cls:hasClass(klass) return self:isClass(klass) end
    cls.__default.hasClass = cls.hasClass

    function cls:super(klass) -- take in a class (or instance of one) and return the extension from that class (if it exists)
        expectClass("class.super.klass", klass)
        for _, extension in pairs(self.__inherits) do
            if bothExactSameClass(extension, klass) then return extension end
        end
    end
    cls.__default.super = cls.super

    function cls:getClassName()
        return cls.__className -- You would think that "getmetatable(self)" could be used instead of "cls", but it errors here.
    end
    cls.__default.getClassName = cls.getClassName

    function cls:getAllClassNames()
        local names = {}
        
        table.insert(names, self:getClassName())
        for n, _ in pairs(self.__inherits) do
            table.insert(names, n)
        end
        return names
    end
    cls.__default.getAllClassNames = cls.getAllClassNames

    ----------------------------------------------------------------------------------------------------
    -- INTERFACE
    ----------------------------------------------------------------------------------------------------
    
    function cls:_assertWellFormed()
        for k, desc in pairs(self.__abstractMethods) do
            local method = self[k]
            local custom_err = "Missing " .. k  .. ": " .. desc
            expectCallable("", method, custom_err)
        end

        for k, desc_type in pairs(self.__abstractFields) do
            local field = self[k]
            local custom_err = "Missing or mistyped " .. k .. "(" .. desc_type["type"] .. "): " .. desc_type["description"]
            assert(field, custom_err)
            assert(type(field) == desc_type["type"], custom_err)    
        end

        self:_execWellformedHooks()
    end

    --------------------------------------------------
    ---- Abstract (Must be defined somewhere)
    --------------------------------------------------

    function cls:abstractField(key, description, ty) -- Note: Will override old abstracts
        assert(key, "You need a key for the field to be assigned to")
        self.__abstractFields[key] = { description = description, type = ty}
    end
    cls.__default.abstractField = cls.abstractField

    function cls:abstractMethod(key, description) -- Note: Will override old abstracts
        assert(key, "You need a key that the method will be assigned to")
        self.__abstractMethods[key] = description
    end
    cls.__default.abstractMethod = cls.abstractMethod

    --------------------------------------------------
    ---- forceDeclare (Must be defined by CURRENT class)
    --------------------------------------------------

    function cls:forceDeclareField(key, description, ty) -- Forces each class to declare this field themselves
        assert(key, "You need a key for the field to be assigned to")
        self.__abstractFields[key] = { description = description, type = ty}
        self.__preserveKeys[key] = true
    end
    cls.__default.forceDeclareField = cls.forceDeclareField


    function cls:forceDeclareMethod(key, description) -- Forces each class to declare this method themselves
        assert(key, "You need a key that the method will be assigned to")
        self.__abstractMethods[key] = description
        self.__preserveKeys[key] = true
    end
    cls.__default.forceDeclareMethod = cls.forceDeclareMethod

    ----------------------------------------------------------------------------------------------------
    -- HOOKS (Let you modify certain functions which due to inheritance can't be directly chagned, each class can only add one function per hook)
    ----------------------------------------------------------------------------------------------------

    function cls:addHook(hookName, func) -- NOTE: ONLY 1 FUNCTION PER HOOK PER CLASS
        expectCallable("class.addHook.func", func)
        self.__hooks[hookName] = self.__hooks[hookName] or {}
        self.__hooks[hookName][self:getClassName()] = func
    end
    cls.__default.addHook = cls.addHook

    function cls:_execHooks(hookName, ...)
        local hooks = self.__hooks[hookName]
        if not hooks then return nil end
        for _, func in pairs(hooks) do
            func(self, ...)
        end
    end

    --------------------------------------------------
    ---- PostInit Hooks (Called in sequence: PostInit, Wellformed)
    --------------------------------------------------
    -------------------------
    ------ Wellformed
    -------------------------

    function cls:addWellformedHook(func)
        expectCallable("class.addWellformedHook.func", func)
        self:addHook(self.__BASIC_HOOKS.WELLFORMED. func)
    end
    cls.__default.addWellformedHook = cls.addWellformedHook

    function cls:_execWellformedHooks()
        self:_execHooks(self.__BASIC_HOOKS.WELLFORMED)
    end

    -------------------------
    ------ PostInit
    -------------------------

    function cls:addPostInitHook(func)
        expectCallable("class.addPostInitHook.func", func)
        self:addHook(self.__BASIC_HOOKS.POST_INIT, func)
    end
    cls.__default.addPostInitHook = cls.addPostInitHook

    function cls:_execPostInitHooks()
        self:_execHooks(self.__BASIC_HOOKS.POST_INIT)
    end

    --------------------------------------------------
    ---- Inherits (Post) 
    --------------------------------------------------

    function cls:addInheritsHook(func)
        expectCallable("cls.addInheritsHook.func", func)
        self:addHook(self.__BASIC_HOOKS.INHERITS, func)
    end
    cls.__default.addInheritsHook = cls.addInheritsHook

    function cls:_execInheritsHook(klass) -- Note this is called by the base class inheriting INTO the sub class
        expectClass("class._execInheritsHook.klass", klass)
        self:_execHooks(self.__BASIC_HOOKS.INHERITS, klass)
    end

    --------------------------------------------------
    ---- Meta Tablle hooks
    --------------------------------------------------
    -------------------------
    ------ Index
    -------------------------

    function cls:addIndexHook(func)
        expectCallable("cls.addIndexHook.func", func)
        self:addHook(self.__BASIC_HOOKS.INDEX, func)
    end
    cls.__default.addIndexHook = cls.addIndexHook

    function cls:_execIndexHooks(cls, tbl, key) -- Special case 1
        for _, func in pairs(cls.__hooks[cls.__BASIC_HOOKS.INDEX]) do
            local result = func(cls, tbl, key)
            if result ~= nil then
                return result
            end
        end
    end

    -------------------------
    ------ NewIndex
    -------------------------

    function cls:addNewIndexHook(func)
        expectCallable("cls.addNewIndexHook.func", func)
        self:addHook(self.__BASIC_HOOKS.NEW_INDEX, func)
    end
    cls.__default.addNewIndexHook = cls.addNewIndexHook

    function cls:_execNewIndexHooks(cls, tbl, key, value) -- Special case 2
        for _, func in pairs(cls.__hooks[cls.__BASIC_HOOKS.NEW_INDEX]) do
            local result = func(cls, tbl, key, value)
            if result ~= nil then
                return result
            end
        end
    end

    ----------------------------------------------------------------------------------------------------
    -- DEFAULT (For cases where a class overwrites a method)
    ----------------------------------------------------------------------------------------------------

    function cls:DEFAULT() -- Note you will have to use dot notation to call the functions
        return self.__default
    end

    function cls:default() -- I am an idiot
        return cls:DEFAULT()
    end

    ----------------------------------------------------------------------------------------------------
    -- CONSTRUCTOR
    ----------------------------------------------------------------------------------------------------

    function cls:_new(...)
        local instance = setmetatable({}, cls)
        if instance.init then
            instance:init(...)
        end
        instance:_execPostInitHooks()
        instance:_assertWellFormed()
        return instance
    end

    ----------------------------------------------------------------------------------------------------
    -- META METHODS
    ----------------------------------------------------------------------------------------------------
    -- MAKE TABLE CALLABLE AS CONSTRUCTOR
    setmetatable(cls, {
        __call = function(_, ...)
            return cls:_new(...)
        end,
    })

    cls.__tostring = cls.__tostring or function (self)
        self:getClassName()
    end

    -- SET THE FALLBACK TO TABLE ITSELF SO THE INSTANCE METHODS WORK
    cls.__index = function(tbl, key)
        local try = cls:_execIndexHooks(cls, tbl, key)
        -- DEFAULT (Well slightly changed so the class indexing works)
        return try and try or (rawget(cls, key) and rawget(cls, key) or rawget(tbl, key))
    end

    cls.__newindex = function(tbl, key, value)
        local try = cls:_execNewIndexHooks(cls, tbl, key, value)
        -- DEFAULT
        return try and try or rawset(tbl, key, value)
    end

-- RETURNS
    return cls
end

return class