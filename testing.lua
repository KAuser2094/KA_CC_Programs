local netNameOrSide = "back"
local requester = peripheral.wrap("back")
local available = requester.getAvailableItems()
local serialised = textutils.serialise(available)
textutils.pagedPrint(serialised)
