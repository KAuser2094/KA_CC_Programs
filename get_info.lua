-- Just saves the docs of whatever is at the `networkname` to `info` so you can `pastebin put docs` later
local networkName = "back"
local wrapped = peripheral.wrap(networkName)
local info = {}

-- Docs
info.docs = wrapped.getDocs()
-- Methods (May not appear in docs)
info.methods = peripheral.getMethods(networkName)

-- Print to file
local infoFile = fs.open("info", "w")
infoFile.write("return " .. textutils.serialise(info))
infoFile.close()

print("Press key to exit")
local event, key = os.pullEvent("key")
