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

local bhN = "industrialforegoing:black_hole_unit_tile_0"
local bh = invModule.createBetterInventory(bhN)

local bhcN = "industrialforegoing:black_hole_controller_reworked_tile_0"
local bhc = invModule.createBetterInventory(bhcN)

local reactors = { ic2Module.findAllReactorsInNetwork() }
local r1 = reactors[1]
r1:setConnectionSide("up")
r1.verbosity = 1
local r2 = reactors[2]
r2:setConnectionSide("up")
r2.verbosity = 1

print("Testing bh")
print(bh:size())
print(bhc:size())

-- bh:printDocs()
-- bhc:printDocs()

print("Press Enter to end program ")
io.read()
