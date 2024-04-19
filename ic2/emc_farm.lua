-- RM emc = 10059784
-- Rod emc = 1536
-- Total Rods made = 6549.3385416667
-- in stacks: 102.33 = 103 (round up)

local invMod = dofile("KA_CC_Programs/inventory/init.lua")
local ic2Mod = dofile("KA_CC_Programs/ic2/init.lua")

local lowerBound = 0
local upperBound = lowerBound + 21

local condensorName = "projecte:condenser_mk2_0"
local condensor = invMod.createBetterInventory(condensorName)

local macerators = {}

for i = lowerBound, upperBound do
	local macerator = invMod.createBetterInventory("ic2:macerator_" .. i)
	macerator:setConnectionSide("south")
	table.insert(macerators, macerator)
end

local slotInCondensor = 43 -- Start of output inventory

for _, macerator in ipairs(macerators) do
	condensor:pushItems(macerator, slotInCondensor)
	slotInCondensor = (slotInCondensor == 84) and 43 or (slotInCondensor + 1)
end
