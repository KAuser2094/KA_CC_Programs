-- RM emc = 10059784
-- Rod emc = 1536
-- Total Rods made = 6549.3385416667
-- in stacks: 102.33 = 103 (round up)

-- 27 seconds per 5 mil
-- 185,185 emc per second

local invMod = dofile("KA_CC_Programs/inventory/init.lua")
local ic2Mod = dofile("KA_CC_Programs/ic2/init.lua")

-- Time needed to sleep so macerators are finished before pulling/pushing
local timeNeeded = 0.1

local lowerBound = 0
local upperBound = lowerBound + 20

local condensorRodName = "projecte:condenser_mk2_0"
local condensorRod = invMod.createBetterInventory(condensorRodName)

local condensorRMName = "projecte:condenser_mk2_1"
local condensorRM = invMod.createBetterInventory(condensorRMName)

local macerators = {}

for i = lowerBound, upperBound do
	local macerator = invMod.createBetterInventory("ic2:macerator_" .. i)
	macerator:setConnectionSide("south")
	table.insert(macerators, macerator)
end

local slotInCondensorRod = 43 -- Start of output inventory

local function pushToMacerators() -- Does 21 stacks
	for _, macerator in ipairs(macerators) do
		condensorRod:pushItems(macerator, slotInCondensorRod)
		slotInCondensorRod = (slotInCondensorRod == 84) and 43 or (slotInCondensorRod + 1)
	end
end

local function extraWaitForMacerators()
	os.sleep(timeNeeded)
end

local function pullFromMacerators()
	for i, macerator in ipairs(macerators) do
		macerator:pushItems(condensorRM, 2) -- Who knows why this is 2 when pulling/pushing but is actually in slot 3
	end
end

local function refillRodCondensor()
	condensorRM:pushItems(condensorRod, 43, 1)
end

local function emcLoop()
	print("Refilling Rods...")
	refillRodCondensor()
	for i = 1, 5 do
		print("Pushing")
		pushToMacerators() -- This has an os.sleep(1)
		extraWaitForMacerators()
		print("Pulling") -- Makes 3 stacks per 1 stack of rod
		pullFromMacerators()
		extraWaitForMacerators()
		pullFromMacerators()
		extraWaitForMacerators()
		pullFromMacerators()
	end
	print("Done")
end

emcLoop()
