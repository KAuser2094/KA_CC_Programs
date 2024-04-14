local netNameOrSide = "back"
local requester = peripheral.wrap("back")
local available = requester.getAvailableItems()
for _, item in ipairs(available) do
	-- Extract information about the item
	local itemName = item.getName()
	local itemObject = item.getObject()

	-- Do whatever you need with the item information
	print("Item: " .. itemName .. ", Object: " .. itemObject)
end
