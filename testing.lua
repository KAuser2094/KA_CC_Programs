-- Usage: `local inv = tryRequire({ "inventory", "KA_CC_Programs/inventory", "../inventory" })`
local function tryRequire(paths)
	local errorMsgs = {}
	for _, path in ipairs(paths) do
		local success, module = pcall(require, path)
		if success then
			return module
		else
			table.insert(errorMsgs, "Failed to require from '" .. path .. "': " .. module)
		end
	end
	error(table.concat(errorMsgs, "\n"))
end
local invModule = tryRequire({ "inventory", "KA_CC_Programs/inventory", "../inventory" })

local oN = "minecraft:ironchest_obsidian_1"
local o = invModule.createBetterInventory(oN)

local reactors = { peripheral.find("ic2:nuclear reactor") }
local reactors = invModule.convertInventoryListToBetterInventoryList(reactors)
for _, reactor in ipairs(reactors) do
	print(reactor.name)
	reactor:setConnectionSide("up")

	-- Tests:
	-- reactor:pullItems(o, 1)
	-- reactor:pushItems(o, 1)
	-- o:pullItems(reactor, 1)
	-- o:pushItems(reactor, 1)
end

print("Press a key to end program ")
io.read()
