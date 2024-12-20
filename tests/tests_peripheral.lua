local textutils = _G.textutils
local native = _G.peripheral

local Peripheral = require "KA_CC.peripheral.Peripheral"
local Inventory = require "KA_CC.peripheral.Inventory"
local p_utils = require "KA_CC.peripheral.utils"
local t_utils = require "KA_CC.tests.utils"

local chest_type = "minecraft:chest"

local chestInv = Inventory(chest_name)

assert(chestInv, "chest was not made")

assert(chestInv:isClass(Peripheral), "Could not use isClass on Peripheral")
assert(chestInv:isClass(Inventory), "Could not use isClass on Inventory")

print("Class = " .. chestInv:getClassName())
print("All Classes = " .. textutils.serialise(chestInv:getAllClassNames()))

local tests = {}

function tests.testUtilsIsX(context)
    -- Requires: chest on network
    t_utils.testTitle(context, "Testing: per. utils isName and isWrapped")
    local wrapped = t_utils.getNameAndWrappedFromType(chest_type)

    local name = native.getName(wrapped)

    assert(p_utils.isName(name), "Name was invalidly not recognised")
    assert(p_utils.isWrapped(wrapped), "Native peripheral was invalidly not recognised")

    assert(not p_utils.isName(wrapped), "native peripheral was recognised as name")
    assert(not p_utils.isWrapped(name), "name was recognised as peripheral (native)")
end


return tests