-- Uses Chassie to locate module, then gets the command help of each module.
local networkName = "back"
local moduleSlot = 1
local wrappedChassie = peripheral.wrap(networkName)
local mod = wrappedChassie.getModuleInSlot(moduleSlot)
local info = {}
-- Command help (this is a mess)
local notFound = "No command with that index" -- Don't think there is a way to actually find the max index XD
local currentCommandHelp = ""
local index = 0
local commandHelp = {}
while currentCommandHelp ~= notFound do
	currentCommandHelp = mod.commandHelp(index)
	table.insert(commandHelp, currentCommandHelp)
	index = index + 1
end
info.commandHelp = commandHelp

-- Print to file
local infoFile = fs.open("lp_info_mod", "w")
infoFile.write("return " .. textutils.serialise(info))
infoFile.close()

print("Press key to start edit file")
local event, key = os.pullEvent("key")

shell.run("edit lp_info_mod")
