-- local eexpect = require "KA_CC.modules.expect"

-- An extension/rewrite of cc.expect but it also allows you to use classes
-- If "index" is a table then we presume we are calling field instead
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
    error("bad argument/field (#".. index .. "): Expected " .. type_names .. ", got " .. t, 3)
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

local expect = {}

module.expect = expect
module.feild = expect

expect.TYPES = TYPES

local function call(index_or_table, value_or_key, ...)
    local index, value = getIndexAndValueToCheck(index_or_table, value_or_key)
    local t = type(value)
    local className = (t == TYPES.TABLE and value.isClass) and value:getClassName() or nil -- is a class
    if className then
        -- Do the check with class first
        for i = 1, select('#', ...) do
            local other = select(i, ...) -- get the ith in the ...
            local other_name = (type(other) == TYPES.TABLE and other.isClass) and other.__className or (type(other) == TYPES.STRING and other or nil)
            if other_name == TYPES.CLASS then return value end -- General any class
            if other_name and value:isClass(other_name) then return value end
        end
    end

    -- Table that effectively is a function and,,,well a function is effectively a function too.
    if (t == TYPES.FUNCTION) or (t == TYPES.TABLE and getmetatable(value) and getmetatable(value).__call) then
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

function expect.NOT(index_or_table, value_or_key, ...)
    local index, value = getIndexAndValueToCheck(index_or_table, value_or_key)
    local t = type(value)
    -- Check if t is a class, if so make sure none of the ... is a class it has, if so, error
    local className = (t == TYPES.TABLE and value.isClass) and value:getClassName() or nil -- is a class
    if className then
        -- Do the check with class first
        local err_msg = "Parameter #" .. index .. " had a bad class value"
        for i = 1, select('#', ...) do
            local other = select(i, ...) -- get the ith in the ...
            local other_name = (type(other) == TYPES.TABLE and other.isClass) and other.__className or (type(other) == TYPES.STRING and other or nil)
            assert(other_name ~= TYPES.TABLE, err_msg)
            assert(other_name ~= TYPES.CLASS, err_msg)
            assert(not (other_name and value:isClass(other_name)), err_msg)
        end
    end
    
    -- Check if t is a callable table or functio, if so if effective function is inside then error
    if (t == TYPES.FUNCTION) or (t == TYPES.TABLE and getmetatable(value) and getmetatable(value).__call) then
        for i = 1, select('#', ...) do
            local other = select(i, ...) -- get the ith in the ...
            assert(other ~= TYPES.CALLABLE, "Parameter #" .. index .. " is an effective function which is blacklisted")
        end
    end

    -- Take the complement of the basic types and any basic types in the .. and call expect on that.
    local complement = complement(i_BASE_TYPES, ...)
    return call_native_reimpl(index, value, table.unpack(complement))
end

module.expectNot = expect.NOT
module.fieldNot = expect.NOT

function expect.ANY(index, value) -- So not nil
    assert(type(value) ~= "nil", "Parameter #" .. index .. " must be a non-nil value")
    return value
end

module.expectAny = expect.ANY
module.fieldAny = expect.ANY

function expect.OPTIONAL(index, value, ...) -- Literally just, could be nil. Why would you ever call this?
    return call(index, value, TYPES.NIL, ...)
end

module.expectOptional = expect.OPTIONAL
module.fieldOptional = expect.OPTIONAL

-- TODO: add <TYPE>? functions (probably goes here)
local function addSingleTypeExpects(tbl)
    for key, ty in pairs(BASE_TYPES) do
        tbl[key] = function (index, value)
            assert(type(value) == ty, "Paramter #" .. index .. " must be of " .. ty .. " type")
            return value
        end
        tbl["NOT_" .. key] = function (index, value) 
            assert(type(value) ~= ty, "Paramter #" .. index .. " must NOT be of " .. ty .. " type")
            return value
        end
        module["expect" .. toCamelCase(key)] = tbl[key]
        module["expectNot" .. toCamelCase(key)] = tbl["NOT_" .. key]
        module["field" .. toCamelCase(key)] = tbl[key]
        module["fieldNot" .. toCamelCase(key)] = tbl["NOT_" .. key]
    end
end

addSingleTypeExpects(expect)

-- TODO: Add single Type expects for the effective function and class

--



function module.getFields()
    local fields = {}
    for k, v in pairs(module) do
        local ty = type(v)

        if ty == TYPES.TABLE or ty == TYPES.FUNCTION then
            fields[k] = ty
        else
            fields[k] = v
        end
    end
    return fields
end

return module