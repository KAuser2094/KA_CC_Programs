local netNameOrSide = "back"
local requester = peripheral.wrap("back")
local available = requester.getAvailableItems()
local ItemIdentifier1 = available[1]
for key, value in pairs(ItemIdentifier1) do
	print("Key:", key, "Value:", value)
end
