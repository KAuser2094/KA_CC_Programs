local exp = require "KA_CC.modules.expect".expect
local expNot = require "KA_CC.modules.expect".expectNot
local TYPES = require "KA_CC.modules.expect".TYPES
local Inventory = require "KA_CC.peripheral.Inventory"
local Peripheral = require "KA_CC.peripheral.Peripheral"
local class = require "KA_CC.modules.class"
local t_utils = require "KA_CC.tests.utils"

local chest_type = "minecraft:chest"

local tests = {}

local function _pcall(func, ...)
    local s, r_e = pcall(func, ...)
    local r = s and r_e or "nil"
    local e = s and "nil" or r_e
    return s, r, e
end

function tests.expect(context)
    t_utils.testTitle(context, "Testing: Expect, except function works")
    local name, wrapped = t_utils.getNameAndWrappedFromType(context, chest_type)
    local chestInv = Inventory(name)
    -- Sanity
    assert(exp, "didn't import expect properly")
    assert(chestInv:isClass(Inventory), "chestInv:isClass(Inventory) should return True")
    assert(chestInv:isClass(Inventory:getClassName()), "chestInv:isClass(Inventory.getClassName()) should return True")

    -- Tests over class
    local success, res, err  = _pcall(exp,"1",chestInv, Inventory)
    assert(success, "Pass in Inventory, err: " .. err)

    local success, res, err  = _pcall(exp,"2",chestInv, Inventory.__className)
    assert(success, "Pass in Inventory name, err: " .. err)

    local success, res, err  = _pcall(exp,"3",chestInv, Peripheral)
    assert(success, "Pass in Peripheral, err: " .. err)

    local tempClass = class("Temp Class")

    local success, res, err  = _pcall(exp,"4",chestInv, "class")
    assert(success, "Pass in class, err: " .. err)

    local success, res, err  = _pcall(exp,"5",chestInv, "table")
    assert(success, "Pass in table str, err: " .. err)

    local success, res, err  = _pcall(exp,"6",chestInv, "string")
    assert(not success, "Pass in string str (should fail), res: " .. res)

    local success, res, err  = _pcall(exp,"7",chestInv, "string", "bad", "test", "nil", Peripheral)
    assert(success, "Pass in Peripheral after junk, err: " .. err)

    -- extra types (effective function)

    local just_table = {}

    local success, res, err = _pcall(exp, "8", just_table, TYPES.CALLABLE)
    assert(not success, "Passed in a raw table and should have failed effective function")

    
    local success, res, err = _pcall(exp, "9", Inventory, TYPES.CALLABLE)
    assert(success, "Passed in a class (callable) table and should have been effective function, err: " .. err)
    
    -- test over base types
    local success, res, err  = _pcall(exp,"10","this is a string", Peripheral)
    assert(not success, "Pass in Peripheral to string, should fail, res: " .. res)

    local success, res, err  = _pcall(exp,"11","this is a string", "string")
    assert(success, "Pass in string to a string, err: " .. err)
end

function tests.expectNot(context)
    t_utils.testTitle(context, "Testing: Expect: exceptNot function works")
    local name, wrapped = t_utils.getNameAndWrappedFromType(context, chest_type)
    local chestInv = Inventory(name)
    -- Sanity
    assert(expNot, "didn't import expectNot properly")
    assert(chestInv:isClass(Inventory), "chestInv:isClass(Inventory) should return True")
    assert(chestInv:isClass(Inventory:getClassName()), "chestInv:isClass(Inventory.getClassName()) should return True")

    -- Tests over class
    local success, res, err  = _pcall(expNot,"1",chestInv, Inventory)
    assert(not success, "Pass in Inventory, res: " .. res)

    local success, res, err  = _pcall(expNot,"2",chestInv, Inventory.__className)
    assert(not success, "Pass in Inventory name, res: " .. res)

    local success, res, err  = _pcall(expNot,"3",chestInv, Peripheral)
    assert(not success, "Pass in Peripheral, res: " .. res)

    local tempClass = class("Temp Class")

    local success, res, err  = _pcall(expNot,"4",chestInv, "class")
    assert(not success, "Pass in class, res: " .. res)

    local success, res, err  = _pcall(expNot,"5",chestInv, "table")
    local out = success and "true" or "false"
    print(out)
    assert(not success, "Pass in table str")

    local success, res, err  = _pcall(expNot,"6",chestInv, "string")
    assert(success, "Pass in string str (should fail), err: " .. err)

    local success, res, err  = _pcall(expNot,"7",chestInv, "string", "bad", "test", "nil", Peripheral)
    assert(not success, "Pass in Peripheral after junk, res: " .. res)

    -- extra types (effective function)

    local just_table = {}

    local success, res, err = _pcall(expNot, "8", just_table, TYPES.CALLABLE)
    assert(success, "Passed in a raw table and should have failed effective function")

    
    local success, res, err = _pcall(expNot, "9", Inventory, TYPES.CALLABLE)
    assert(not success, "Passed in a class (callable) table and should have been effective function")
    
    -- test over base types
    local success, res, err  = _pcall(expNot,"10","this is a string", Peripheral)
    assert(success, "Pass in Peripheral to string, should success, err: " .. err)

    local success, res, err  = _pcall(expNot,"11","this is a string", "string")
    assert(not success, "Pass in string to a string, res: " .. res)
end

-- TODO:
-- test fields (as in works on tables)

return tests