return {
  docs = {
    suck = "function([slot:int[, limit:int]]):int -- Suck an item from the ground",
    getDocs = "function([name: string]):string|table -- Get the documentation for all functions or the function specified. Errors if the function cannot be found.",
    getItemMeta = "function(slot:int):table|nil -- The metadata of the item in the specified slot. The slot number starts from 1.",
    getMetadata = "function():table -- Get metadata about this object",
    pullItems = "function(fromName:string, fromSlot:int[, limit:int[, toSlot:int]]):int -- Pull items to this inventory from another inventory. Returns the amount transferred.",
    getTransferLocations = "function([location:string]):table -- Get a list of all available objects which can be transferred to or from",
    drop = "function(slot:int[, limit:int[, direction:string]]):int -- Drop an item on the ground. Returns the number of items dropped",
    pushItems = "function(toName:string, fromSlot:int[, limit:int[, toSlot:int]]):int -- Push items from this inventory to another inventory. Returns the amount transferred.",
    list = "function():table -- List all items in this inventory",
    getItem = "function(slot:int):table|nil -- The item in the specified slot. The slot number starts from 1.",
    size = "function():int -- The size of the inventory",
  },
  commandHelp = {
    "---------------------------------\
Command: getRotation\
Parameter: NONE\
Return Type: int\
Description: \
Returns the LP rotation value for this block",
    "No command with that index",
  },
  methods = {
    "drop",
    "getMetadata",
    "getRotation",
    "getTransferLocations",
    "getItemMeta",
    "getItem",
    "list",
    "commandHelp",
    "getDocs",
    "help",
    "size",
    "getType",
    "pullItems",
    "suck",
    "pushItems",
  },
}