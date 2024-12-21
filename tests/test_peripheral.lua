local textutils = _G.textutils
local native = _G.peripheral

local Peripheral = require "KA_CC.peripheral.Peripheral"
local Inventory = require "KA_CC.peripheral.Inventory"
local p_utils = require "KA_CC.peripheral.utils"
local t_utils = require "KA_CC.tests.utils"
local utils = require "KA_CC.modules.utils"

local chest_type = "minecraft:chest"

local tests = {}

function tests.testUtilsIsX(context)
    -- Requires: chest on network
    t_utils.testTitle(context, "Testing: per. utils isName and isWrapped")
    local name, wrapped = t_utils.getNameAndWrappedFromType(context, chest_type)

    assert(p_utils.isName(name), "Name was invalidly not recognised")
    assert(p_utils.isWrapped(wrapped), "Native peripheral was invalidly not recognised")

    assert(not p_utils.isName(wrapped), "native peripheral was recognised as name")
    assert(not p_utils.isWrapped(name), "name was recognised as peripheral (native)")
end

function tests.testInventoryClass(context)
    t_utils.testTitle(context, "Testing: KA_Inventory Class works as a class")

    local name, wrapped = t_utils.getNameAndWrappedFromType(context, chest_type)
    local chestInv = Inventory(name)
    local chestInv2 = Inventory(wrapped)

    assert(chestInv, "KA_Inventory was not made from name")
    assert(chestInv2, "KA_Inventory was not made from wrapped")

    assert(chestInv == chestInv2, "Same chest, not equal")

    assert(tostring(chestInv) == "KA_Inventory: " .. name, "tostring is incorrect, got: " .. tostring(chestInv))

    assert(chestInv:isClass(Peripheral), "Could not use isClass on Peripheral")
    assert(chestInv:isClass(Inventory), "Could not use isClass on Inventory")

    local className = chestInv:getClassName()
    assert(className == "KA_Inventory", "Did not get correct classname for KA_Inventory, got: " .. className)

    local allClassNames = chestInv:getAllClassNames()
    -- TODO: add a similar test in test_class as it really should be there instead -_-
    -- This is a bit weird since it effectively just means = in this instance (well that would require a second call with swapped params)
    t_utils.verbosePrint(context, "allClassNames = " .. textutils.serialise(allClassNames))
    local hasClasses = utils.hasSubset(allClassNames, {"KA_Inventory", "KA_Peripheral", "KA_Class"})
    local coHasClasses = utils.hasSubset({"KA_Inventory", "KA_Peripheral", "KA_Class"}, allClassNames)
    assert(hasClasses and coHasClasses, "Did not have all classes expected, got: " .. textutils.serialise(allClassNames))
end


return tests