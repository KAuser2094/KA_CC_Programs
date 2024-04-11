-- LZH Condensators use "Durability" nbt which is a number from 0-1 (won't actually show 0) where it represents the % lost.
-- i.e. a durability of 0.75 means only 25% is left (10k*25% is 2.5k)
-- You can loop and check for any that are below (above a number) threshold durability and stop the reactor. Then simply dump out and in old and new condensators.

local inv = require("KA_CC_Programs/inventory/inventory")
local chamber = peripheral.wrap("back")
local reactor = chamber.getReactorCore()

print("Press any key to finish")
local event, key = os.pullEvent("key")
