local context = {}
local params = {}
local flags = {}
-- Set CC network parameters
params = {
}
-- Flags (Determines what tests can run)
flags = {
    -- On Network, flags to say something exists on network and could be found via the find() command (or similar)
    ["has_vanilla_chest"] = true,
    ["has_ic2_reactor"] = false,
    -- In provider chest, flags to show items are in the provider chest for tests
    ["provider"] = nil,

    --
}
--
context["params"] = params
context["flags"] = flags
-- Extra Params
context["silent"] = false
context["resolutions"] = true
context["testTitles"] = true
context["verbose"] = true
context["extremely_verbose"] = true

return context