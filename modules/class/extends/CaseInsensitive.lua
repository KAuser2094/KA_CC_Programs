-- Lets you set a method to case insensitive.
local Class = require "KA_CC.modules.class.class"

local CaseInsensitive = Class("KA_RemoveCaseSensitivity")

local helper = CaseInsensitive.__helper

local shallowMergeWithPreserve = helper.shallowMergeWithPreserve

CaseInsensitive.__case_insensitive = {} -- For case insensitivity on fields and methods

CaseInsensitive.__preserveKeys["__case_insensitive"] = true -- Want to add not replace


function CaseInsensitive:removeCaseSensitivity(true_key)
    local lower_key = string.lower(true_key)
    self.__case_insensitive[lower_key] = true_key
end

-- Needs an "inherits" hook
local function getWithoutCaseSensitive(cls, tbl, key)
    local lower_key = type(key) == "string" and string.lower(key) or nil -- For case insensitivity

    if lower_key and cls.__case_insensitive[lower_key] then
        local true_key = cls.__case_insensitive[lower_key]
        -- The second is SPECIFICALLY for instance fields (defined self.<key> = <value> since they don't live in cls and would never be called here normally)
        local try = rawget(cls, true_key) or rawget(tbl, true_key)
        return try
    end
end
CaseInsensitive:addIndexHook(getWithoutCaseSensitive)

-- Needs an "index" hook
local function inheritCaseInsensitivity(base, klass)
    klass.__case_insensitive = klass.__case_insensitive or {}
    shallowMergeWithPreserve(klass.__case_insensitive, base.__case_insensitive)
end
CaseInsensitive:addInheritsHook(inheritCaseInsensitivity)

return CaseInsensitive