-- Just saves the docs of whatever is at the `networkname` to `info` so you can `pastebin put docs` later
local networkName = "back"
local back = peripheral.wrap(networkName)
local info = {}
-- Docs
local docTable = back.getDocs()
info.docs = textutils.serialise(docTable)
-- Methods (May not appear in docs)
local methods = peripheral.getMethods(networkName)
info.methods = textutils.serialise(methods)

-- Print to file
local infoFile = fs.open("Info", "w")
infoFile.write("return " .. textutils.serialise(info))
infoFile.close()

print("Press key to exit")
local event, key = os.pullEvent("key")
