local netNameOrSide = "back"
local requester = peripheral.wrap("back")
local available = requester.getAvailableItems()
local Wrapped_II_1 = available[1]
for key, value in pairs(Wrapped_II_1) do
	print("Key:", key, "Value:", value)
end
local II_1 = Wrapped_II_1.getValue1()
local info = {}

local notFound = "No command with that index" -- Don't think there is a way to actually find the max index XD
local currentCommandHelp = ""
local index = 0
local commandHelp = {}
while currentCommandHelp ~= notFound do
	currentCommandHelp = wrapped.commandHelp(index)
	table.insert(commandHelp, currentCommandHelp)
	index = index + 1
end
info.commandHelp = commandHelp

local infoFile = fs.open("II_info", "w")
infoFile.write("return " .. textutils.serialise(info))
infoFile.close()
