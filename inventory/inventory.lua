-- Define a table to store the module functions
local inventory = {}

local function checkIfInv(invTable)
  if invTable.list then
    return true
  else
    print("invTable: " .. invTable.getMetadata["name"] .. " may not be an inventory, missing methods")
    return false

--[[
  Takes in: Inventory Block Table, Slot number, Key in the item meta to read.
  Returns: The value to the key in the item at the slot given or nil if failure.
]]
function inventory.getValueAtInv_Slot_MetaKey(invTable, slot, metakey)
  if not checkIfInv(invTable) then
    return
  end
  local itemMeta = invTable.getItemMeta(slot)
  local val_or_nil = itemMeta[metakey]
  if val_or_nil == nil then
    print("Key: " .. metakey .. " did not exist")
  end
  return val_or_nil
end

--[[
  Takes in: Inventory Block Table, Metakey of value, function that takes in value and return true or false
  Optional: Start Range, End Range
  Returns: List with slots of items that fulfil the criteria
]]
function inventory.findItemsInInvWith_MetaKeyValue_ThatFulfilsFunction(invTable, metaKey, lowerFunction, startRange, endRange)
  if not checkIfInv(invTable) then
    return
  end
  startRange = startRange or 1
  endRange = endRange or invTable.size()
  local indexList = {}
  for slot = startRange,endRange do
    value = inventory.getValueAtInv_Slot_MetaKey(invTable,slot,metaKey)
    if lowerFunction(value) then
      table.insert(indexList,slot)
    end
  end
  return indexList
end

--[[
  Takes in: Inventory Block Table, Value for comparison, Key of value.
  Optional: Start Range, End Range
  Returns: List with slots of items that fulfil the criteria
]]
function inventory.findItemsInInvWith_Value_AtMetaKey(invTable, value, metaKey, startRange, endRange)
  if not checkIfInv(invTable) then
    return
  end
  local lowerFunction = function(inputVal) return value == inputVal end 
  startRange = startRange or 1
  endRange = endRange or invTable.size()
  return inventory.findItemsInInvWith_MetaKeyValue_ThatFulfilsFunction(invTable,metaKey,lowerFunction,startRange,endRange)
end

return inventory
