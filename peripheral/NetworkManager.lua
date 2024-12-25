-- Is essentially a class that monitors the network and tries to keep an accurate image of it. Let's you hook into it to see network events that happened.

local Class = require "KA_CC.modules.class".Class
local PublishSubcsribe = require "KA_CC.modules.class".MixIns.PublishSubcsribe
local Table = require "KA_CC.modules.tabula".Table

local NetworkManager = Class("KA_NetworkManager", PublishSubcsribe)

NetworkManager.EVENTS = {

}

NetworkManager.__PERIPHERALS_ON_NETWORK = {} -- Stores a [<name>] = true for each <name> on the network

NetworkManager:doNotInhertKey("EVENTS")

NetworkManager:mergeEventHookEnum(NetworkManager.EVENTS)

function NetworkManager:tick() -- Calls to this update its image of the network
    
end

return NetworkManager