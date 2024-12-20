local context = {}
local params = {}
local flags = {}
-- Set CC network parameters
params = {
}
-- Flags (Determines what tests can run)
flags = {
    -- On Network, flags to say something exists on network and could be found via the find() command (or similar)
    ["vanilla_chest"] = true,
    ["ic2_reactor"] = false,
    -- In provider chest, flags to show items are in the provider chest for tests

    --
}
--
context["params"] = params
context["flags"] = flags
-- Extra Params
context["testTitles"] = true
context["verbose"] = false

return context