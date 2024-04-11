-- Wrap the block at the back of the computer in a peripheral
local peripheralName = "back" -- Change this to match the side where the peripheral is located
local peripheralObj = peripheral.wrap(peripheralName)

-- Check if the peripheral has an inventory
if peripheralObj and peripheralObj.list then
	-- Iterate through each inventory slot
	local inventorySize = peripheralObj.size()
	for slot = 1, inventorySize do
		local itemDetail = peripheralObj.getItemDetail(slot)
		if itemDetail then
			-- Item exists in the slot, print its details
			print("Slot " .. slot .. ": " .. itemDetail.name .. " x" .. itemDetail.count)
		else
			-- No item in the slot
			print("Slot " .. slot .. ": Empty")
		end
	end
else
	print("Peripheral not found or does not have an inventory.")
end
