-- Holds class related methods and stuff
-- Closure oop method might be better for this but shouldn't be too bad doing it like this.
local expect = require "cc.expect".expect
local pretty = require "cc.pretty".pretty

local function get_type_names(...)
    local types = table.pack(...)
    -- for i = types.n, 1, -1 do
    --     if types[i] == "nil" then table.remove(types, i) end
    -- end

    if #types <= 1 then
        return tostring(...)
    else
        return table.concat(types, ", ", 1, #types - 1) .. " or " .. types[#types]
    end
end

local BASE_TYPES = {
    NIL = "nil",
    BOOLEAN = "boolean",
    NUMBER = "number",
    STRING = "string",
    TABLE = "table",
    FUNCTION = "function",
    USER_DATA = "userdata",
    THREAD = "thread",
}

local i_BASE_TYPES = {
    "nil",
    "boolean",
    "number",
    "string",
    "table",
    "function",
    "userdata",
    "thread",
}

local function class(base) -- Hide methods but show key-value pairs
    local cls = {}

    if base then
        setmetatable(cls, { __index = base })
    end

    -- CONSTRUCTOR
    function cls:__new(...)
        local instance = setmetatable({}, {
            __index = cls,  -- Look up methods in cls
            __newindex = function(t, k, v)
                if cls:_isKeyProtected(k) then
                    local err = type(k) == string and k .. " is protected and cannot be set" or "The key you are trying to set is protected"
                    error(err)
                end
                rawset(t, k, v)  -- Add key to the instance itself
            end,
        })
        if instance.__init then
            instance:__init(...)
        end
        return instance
    end

    -- MAKE TABLE CALLABLE
    setmetatable(cls, {
        __call = function(_, ...)
            return cls:__new(...)
        end,
    })

    function cls._expect() -- Every class is going to need this so might as well put it here
        -- MAYBE: Change this to work like a module, returning a few different variations
        local module = {}
        local function exp(index, value, ...)
            local success, value_or_err = pcall(expect, "N/A", value, ...)
            local err = success and "none" or value_or_err
            assert(success, index .. " Got type of " .. type(value) .. "; Expected: " .. get_type_names(...) .. "\nError: " .. err)
            return value
        end
        module.expect = exp
        module.expectAny = function (index, value)
            return exp(index, value, table.unpack(i_BASE_TYPES))
        end
        module.expectNot = function (index, value)
            return exp(index, value, BASE_TYPES.NIL)
        end
        module.expectBoolean = function (index, value)
            return exp(index, value, BASE_TYPES.BOOLEAN)
        end
        module.expectNumber = function (index, value)
            return exp(index, value, BASE_TYPES.NUMBER)
        end
        module.expectString = function (index, value)
            return exp(index, value, BASE_TYPES.STRING)
        end
        module.expectTable = function (index, value)
            return exp(index, value, BASE_TYPES.TABLE)
        end
        module.expectFunction = function (index, value)
            return exp(index, value, BASE_TYPES.FUNCTION)
        end
        module.expectUserData = function (index, value)
            return exp(index, value, BASE_TYPES.USER_DATA)
        end
        module.expectThread = function (index, value)
            return exp(index, value, BASE_TYPES.USER_DATA)
        end
        module.expectCallable = function (index, value)
            if type(value) == "table" and getmetatable(value).__call then
                return value
            end
            return exp(index, value, BASE_TYPES.FUNCTION, "callabe_table") -- Just to show user
        end
        return module
    end

    cls._BASE_TYPES = BASE_TYPES

    cls.__protected = {
    }

    function cls:_addProtectedKey(key)
        assert(type(self) == "table", "Forgot to use :")
        assert(key, "A key cannot be nil. (_addProtectedKey)")
        self.__protected[key] = true
    end

    function cls:_removeProtectedKey(key)
        assert(type(self) == "table", "Forgot to use :")
        assert(key, "A key cannot be nil. (_addProtectedKey)")
        self.__protected[key] = false
    end

    function cls:_ProtectAllCurrentKeys()
        assert(type(self) == "table", "Forgot to use :")

        for k, _ in pairs(self) do
            self:_addProtectedKey(k)
        end
    end

    function cls:_isKeyProtected(key)
        return self.__protected[key]
    end

    cls:_ProtectAllCurrentKeys()

-- RETURNS
    return cls
end

return class