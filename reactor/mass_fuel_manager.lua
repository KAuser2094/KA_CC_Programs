-- Connects to multiple reactors and manages the fuel set up for you.
-- Void chest (should be railcraft:chest_void_X) where X is a number
local void_chest = peripheral.wrap("railcraft:chest_void_0")
-- Ender Chest (with fuel) (should be minecraft:ender chest_X) where X is a number
local ender_chest = peripheral.wrap("minecraft:ender chest_0")
-- Reactors
local reactors = { peripheral.find("ic2:reactor chamber") }

local count = 1
for _, reactor in pairs(reactors) do
	print(peripheral.getName(reactor))
	reactor.pullItems(peripheral.getName(ender_chest), count)
	count = count + 1
end

ender_chest.pushItems(peripheral.getName(void_chest), 1)
