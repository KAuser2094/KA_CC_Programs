local netNameOrSide = "back"
local requester = peripheral.wrap("back")
local available = requester.getAvailableItems()
local II_1_Stack = available[1]
local II_1 = II_1_Stack.getValue1()
requester.makeRequest(II_1_Stack)
