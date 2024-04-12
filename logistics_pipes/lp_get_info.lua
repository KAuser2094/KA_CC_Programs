-- same as get_info but for logistics pipes because it is a mess.
-- Just saves the docs of whatever is at the `networkname` to `info` so you can `pastebin put docs` later
local networkName = "back"
local wrapped = peripheral.wrap(networkName)
local info = {}

-- Docs
info.docs = wrapped.getDocs()
-- Methods (May not appear in docs)
info.methods = peripheral.getMethods(networkName)
-- Command help (this is a mess)
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

-- Print to file
local infoFile = fs.open("lp_info", "w")
infoFile.write("return " .. textutils.serialise(info))
infoFile.close()

print("Press key to exit")
local event, key = os.pullEvent("key")
