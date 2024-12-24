-- local expect = require "KA_CC.modules.expect"
-- local e = require "KA_CC.modules.expect"

-- An extension/rewrite of cc.expect but it also allows you to use classes
-- If "index" is a table then we presume we are calling field instead

-- TODO:
-- Add "peripheral" as a type

local type = type
local select = select

-- FROM cc.expect (slightly rewritten)

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

local function call_native_reimpl(index, value, ...) -- reimpl so it doesn't break with non number index
    local t = type(value)
    for i = 1, select("#", ...) do
        if t == select(i, ...) then return value end
    end
    local type_names = get_type_names(...)
    error("bad argument/field (".. index .. "): Expected " .. type_names .. ", got " .. t, 3)
end

-- MODULE

local module = {}

local TYPES = {
    NIL = "nil",
    BOOLEAN = "boolean",
    NUMBER = "number",
    STRING = "string",
    TABLE = "table",
    FUNCTION = "function",
    USER_DATA = "userdata",
    THREAD = "thread",

    CALLABLE = "callable",
    CLASS = "class",
}

module.TYPES = TYPES

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

module.BASE_TYPES = BASE_TYPES


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

module.i_BASE_TYPES = i_BASE_TYPES

local function copy(tbl)
    local copy = {}
    for k, v in pairs(tbl) do
        copy[k] = v
    end
    return copy
end

local function getKeyWithValue(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return k
        end
    end
end

local function complement(tbl, ...)
    local complement = copy(tbl)
    for i = 1, select('#', ...) do
        local value = select(i, ...)
        local key = getKeyWithValue(complement, value)
        if key then
            table.remove(complement, key)
        end
    end
    return complement
end

local function getIndexAndValueToCheck(index_or_table, value_or_key)
    local ty = type(index_or_table)

    if ty == TYPES.TABLE then -- We want to check a table's value at key is type expected
        return value_or_key, index_or_table[value_or_key]
    else -- I don't actually care what we are indexing by
        return index_or_table, value_or_key
    end
end

local function toTitleCaseLiteralUnderscores(str)
    return str:lower():gsub("(%a)([%w]*)", function(first, rest)
        return first:upper() .. rest
    end)
end

local function toCamelCase(str)
    local title_with_underscore = toTitleCaseLiteralUnderscores(str)
    local camel = title_with_underscore:gsub("_", ""):gsub(" ","")
    return camel
end

local function isAClass(value)
    local t = type(value)
    local className = (t == TYPES.TABLE and value.isClass) and value:getClassName() or nil -- is a class
    return className
end

local function isACallable(value)
    local t = type(value)
    return (t == TYPES.FUNCTION) or (t == TYPES.TABLE and getmetatable(value) and getmetatable(value).__call)
end

local function makeIsFunction(expectFunction)
    return function (value, ...) -- The types possibly
        local success, val_or_err = pcall(expectFunction, "N/A", value, ...)
        return success and val_or_err or nil -- Return value if the value is what is expected
    end
end

local expect = {}
local is = {}

module.expect = expect
module.feild = expect
module.is = is

expect.TYPES = TYPES

-- TODO:
-- Remake this but instead follow these steps:
-- - Do the "native" implementation first.
-- - Check for "callable", if so do that check, then similarly for "peripheral", use the "get_type_names" in the error message. Check simply for "class" is also here
-- - Check for specific class names

local function call(index_or_table, value_or_key, ...)
    local index, value = getIndexAndValueToCheck(index_or_table, value_or_key)
    local t = type(value)
    local className = isAClass(value)
    if className then
        -- Do the check with class first
        for i = 1, select('#', ...) do
            local other = select(i, ...) -- get the ith in the ...
            local other_name = isAClass(other) or (type(other) == TYPES.STRING and other or nil)
            if other_name == TYPES.CLASS then return value end -- General any class
            if other_name and value:isClass(other_name) then return value end
        end
    end

    -- Table that effectively is a function and,,,well a function is effectively a function too.
    if isACallable(value) then
        for i = 1, select('#', ...) do
            local other = select(i, ...) -- get the ith in the ...
            if other == TYPES.CALLABLE then return value end
        end
    end

    return call_native_reimpl(index, value, ...)
end

setmetatable(expect, { -- lets you call expect()
    __call = function(_, ...)
        call(...)
    end,
})

local is_call = makeIsFunction(call)

setmetatable(is, { -- lets you call is(value, types...)
    __call = function(_, ...)
        is_call(...)
    end,
})

function expect.NOT(index_or_table, value_or_key, ...)
    local index, value = getIndexAndValueToCheck(index_or_table, value_or_key)
    local t = type(value)
    -- Check if t is a class, if so make sure none of the ... is a class it has, if so, error
    local className = isAClass(value)
    if className then
        -- Do the check with class first
        local err_msg = index .. " had a bad class value"
        for i = 1, select('#', ...) do
            local other = select(i, ...) -- get the ith in the ...
            local other_name = isAClass(other) or (type(other) == TYPES.STRING and other or nil)
            assert(other_name ~= TYPES.TABLE, err_msg)
            assert(other_name ~= TYPES.CLASS, err_msg)
            assert(not (other_name and value:isClass(other_name)), err_msg)
        end
    end
    
    -- Check if t is a callable table or functio, if so if effective function is inside then error
    if isACallable(value) then
        for i = 1, select('#', ...) do
            local other = select(i, ...) -- get the ith in the ...
            assert(other ~= TYPES.CALLABLE, index .. " is an effective function which is blacklisted")
        end
    end

    -- Take the complement of the basic types and any basic types in the .. and call expect on that.
    local complement = complement(i_BASE_TYPES, ...)
    return call_native_reimpl(index, value, table.unpack(complement))
end

module.expectNot = expect.NOT
module.fieldNot = expect.NOT
is.NOT = makeIsFunction(expect.NOT)
module.isNot = is.NOT

function expect.ANY(index, value) -- So not nil
    assert(type(value) ~= "nil", index .. " must be a non-nil value")
    return value
end

module.expectAny = expect.ANY
module.fieldAny = expect.ANY

function expect.OPTIONAL(index, value, ...) -- Literally just, could be nil. Why would you ever call this?
    return call(index, value, TYPES.NIL, ...)
end

module.expectOptional = expect.OPTIONAL
module.fieldOptional = expect.OPTIONAL

local function addSingleTypeExpects(tbl)
    for key, ty in pairs(BASE_TYPES) do
        tbl[key] = function (index, value)
            assert(type(value) == ty, index .. " must be of " .. ty .. " type")
            return value
        end
        tbl["OPTIONAL_" .. key] = function (index, value)
            assert(type(value) == ty or type(value) == "nil", index .. " must be of " .. ty .. " type. Or, or be nil")
            return value
        end
        tbl["NOT_" .. key] = function (index, value) 
            assert(type(value) ~= ty, index .. " must NOT be of " .. ty .. " type")
            return value
        end

        -- "OptionalNot" makes no sense, will always end up true

        local camelCaseKey = toCamelCase(key)
        module["expect" .. camelCaseKey] = tbl[key]
        module["expectNot" .. camelCaseKey] = tbl["NOT_" .. key]
        module["optional" .. camelCaseKey]= tbl["OPTIONAL_" .. key]
        module["field" .. camelCaseKey] = tbl[key]
        module["fieldNot" .. camelCaseKey] = tbl["NOT_" .. key]
        if ty ~= "nil" then -- "isNil" makes no sense, always returns nil
            is[key] = makeIsFunction(tbl[key])
            module["is" .. camelCaseKey] = is[key]
        end
        is["NOT_" .. key] = makeIsFunction(tbl["NOT_" .. key])
        module["isNot" .. camelCaseKey] = is["NOT_" .. key]
    end
end

addSingleTypeExpects(expect)

-- CALLABLE
expect[TYPES.CALLABLE] = function (index, value)
    assert(isACallable(value), index .. "must be callable")
    return value
end
expect["OPTIONAL_" .. TYPES.CALLABLE] = function (index, value)
    assert(isACallable(value) or type(value) == "nil", index .. " must be callable or nil")
    return value
end
expect["NOT_" .. TYPES.CALLABLE] = function (index, value)
    assert(not isACallable(value), index .. " cannot be callable")
    return value
end

local key = getKeyWithValue(TYPES, TYPES.CALLABLE)
local camelCaseKey = toCamelCase(key)
module["expect" .. camelCaseKey] = expect[key]
module["expectNot" .. camelCaseKey] = expect["NOT_" .. key]
module["optional" .. camelCaseKey]= expect["OPTIONAL_" .. key]
module["field" .. camelCaseKey] = expect[key]
module["fieldNot" .. camelCaseKey] = expect["NOT_" .. key]

is[key] = makeIsFunction(expect[key])
module["is" .. camelCaseKey] = is[key]
is["NOT_" .. key] = makeIsFunction(expect["NOT_" .. key])
module["isNot" .. camelCaseKey] = is["NOT_" .. key]

-- CLASS
expect[TYPES.CLASS] = function (index, value)
    assert(isAClass(value), index .. "must be a ckass")
    return value
end
expect["OPTIONAL_" .. TYPES.CLASS] = function (index, value)
    assert(isAClass(value) or type(value) == "nil", index .. " must be ckass or nil")
    return value
end
expect["NOT_" .. TYPES.CLASS] = function (index, value)
    assert(not isAClass(value), index .. " cannot be a ckass")
    return value
end

key = getKeyWithValue(TYPES, TYPES.CLASS)
camelCaseKey = toCamelCase(key)
module["expect" .. camelCaseKey] = expect[key]
module["expectNot" .. camelCaseKey] = expect["NOT_" .. key]
module["optional" .. camelCaseKey]= expect["OPTIONAL_" .. key]
module["field" .. camelCaseKey] = expect[key]
module["fieldNot" .. camelCaseKey] = expect["NOT_" .. key]

is[key] = makeIsFunction(expect[key])
module["is" .. camelCaseKey] = is[key]
is["NOT_" .. key] = makeIsFunction(expect["NOT_" .. key])
module["isNot" .. camelCaseKey] = is["NOT_" .. key]

-- Enforce no other args

function expect.NoVargs(index, ...) -- Kind of weird since you need to add a "..." at the end and the add an except after, making the signature look like it DOES accept it
    local vargs = { ... }
    assert(#vargs == 0, index .. " has " .. #vargs .. " variable arguments when expecting none")
    -- return nil
end

module.expectNoVargs = expect.NoVargs

-- Extras

function module.serialise() -- For printing out since functions hate being turned into strings
    local fields = {}
    for k, v in pairs(module) do
        local ty = type(v)

        if ty == TYPES.TABLE or ty == TYPES.FUNCTION then
            fields[k] = ty
        else
            fields[k] = v
        end
    end
    return textutils.serialise(fields)
end

return module