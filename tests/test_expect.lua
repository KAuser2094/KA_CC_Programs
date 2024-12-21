local exp = require "KA_CC.modules.expect".expect
local Inventory = require "KA_CC.peripheral.Inventory"
local Peripheral = require "KA_CC.peripheral.Peripheral"
local class = require "KA_CC.modules.class"
local t_utils = require "KA_CC.tests.utils"

local chest_type = "minecraft:chest"

local tests = {}

local function _pcall(func, ...)
    local s, r_e = pcall(func, ...)
    local r = s and r_e or nil
    local e = s and "" or r_e
    return s, r, e
end

function tests.expect(context)
    t_utils.testTitle(context, "Testing: Expect, except function works")
    local name, wrapped = t_utils.getNameAndWrappedFromType(context, chest_type)
    local chestInv = Inventory(name)
    -- Sanity
    assert(chestInv:isClass(Inventory), "chestInv:isClass(Inventory) should return True")
    assert(chestInv:isClass(Inventory:getClassName()), "chestInv:isClass(Inventory.getClassName()) should return True")

    local success, res, err  = _pcall(exp,"1",chestInv, Inventory)
    assert(success, "Pass in Inventory, err: " .. err)

    local success, res, err  = _pcall(exp,"1",chestInv, Inventory._className)
    assert(success, "Pass in Inventory name, err: " .. err)

    local success, res, err  = _pcall(exp,"1",chestInv, Peripheral)
    assert(success, "Pass in Peripheral, err: " .. err)

    local success, res, err  = _pcall(exp,"1",chestInv, class())
    assert(success, "Pass in Class, err: " .. err)

    local success, res, err  = _pcall(exp,"1",chestInv, "table")
    assert(success, "Pass in table str, err: " .. err)

    local success, res, err  = _pcall(exp,"1",chestInv, "string")
    local res = success and res or "nil"
    assert(not success, "Pass in string str (should fail), res: " .. res)

    local success, res, err  = _pcall(exp,"1",chestInv, "string", "bad", "test", "nil", Peripheral)
    assert(success, "Pass in Peripheral after junk, err: " .. err)

    local success, res, err  = _pcall(exp,"1","this is a string", Peripheral)
    local res = success and res or "nil"
    assert(not success, "Pass in Peripheral to string, should fail, res: " .. res)

    local success, res, err  = _pcall(exp,"1","this is a string", "string")
    assert(success, "Pass in string to a string, err: " .. err)
end

return tests