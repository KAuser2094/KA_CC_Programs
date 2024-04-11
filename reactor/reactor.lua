--[[
  LZH Condensators use "Durability" nbt which is a number from 0-1 (won't actually show 0) where it represents the % lost.
  i.e. a durability of 0.75 means only 25% is left (10k*25% is 2.5k)
  You can loop and check for any that are below (above a number) threshold durability and stop the reactor. Then simply dump out and in old and new condensators.
]]
local chamber = peripheral.wrap("back")
local reactor = chamber.getReactorCore()
local inv = reactor.list()
local invAsStr = textutils.serialise(inv)
--textutils.pagedPrint(invAsStr)
local itemMeta1 = textutils.serialise(reactor.getItemMeta(1))
print(itemMeta1)
local itemMeta22 = textutils.serialise(reactor.getItemMeta(22))
print(itemMeta22)

print("Press any key to finish")
local event, key = os.pullEvent("key")
