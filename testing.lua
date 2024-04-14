local netNameOrSide = "back"
local requester = peripheral.wrap("back")
local available = requester.getAvailableItems()
for key, value in pairs(available) do
	print("Key:", key, "Value:", value)
end
