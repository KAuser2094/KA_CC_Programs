local obs = peripheral.warp("minecraft:ironchest_obsidian_1")
local reactors = { peripheral.find("ic2:nuclear") }
for _, reactor in ipairs(reactors) do
	print(peripheral.getName(reactor))
end
