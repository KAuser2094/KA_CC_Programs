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
local ic2Module = tryRequire({ "ic2", "KA_CC_Programs/ic2", "../ic2" })

local oN = "minecraft:ironchest_obsidian_1"
local o = invModule.createBetterInventory(oN)

local reactors = { peripheral.find("ic2:nuclear reactor") }
local reactors = invModule.convertReactorListToBetterReactorList(reactors)
for i, reactor in ipairs(reactors) do
	print(reactor.name)
	reactor:setConnectionSide("up")
	reactor.verbosity = 1

	-- Tests:
	-- print(reactor:size())

	-- reactor:pullItems(o, i)
	-- reactor:pushItems(o, 1)
	-- o:pushItems(reactor, i)
	-- o:pullItems(reactor, 1)
end

print("Press Enter to end program ")
io.read()
