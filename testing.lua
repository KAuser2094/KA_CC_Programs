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
local invModule = tryRequire({
	"inventory",
	"KA_CC_Programs/inventory",
	-- "../inventory",
})
local ic2Module = tryRequire({
	"ic2",
	"KA_CC_Programs/ic2",
	-- "../ic2",
})

local oN = "minecraft:ironchest_obsidian_1"
local o = invModule.createBetterInventory(oN)

local cN = "minecraft:chest_0"
local c = invModule.createBetterInventory(cN)

local reactors = { peripheral.find("ic2:nuclear reactor") }
local reactors = ic2Module.convertReactorListToBetterReactorList(reactors)
local r1 = reactors[1]
r1:setConnectionSide("up")
r1.verbosity = 1
local r2 = reactors[2]
r2:setConnectionSide("up")
r2.verbosity = 1

print("Chest")
c:getDocs()

print("Obsidian")
-- o:getDocs()

print("Reactor")
-- r1:getDocs()

print("Press Enter to end program ")
io.read()
