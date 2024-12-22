-- Allows for a class with the publish-subscribe model

local e = require "KA_CC.modules.expect"

local Class = require "KA_CC.modules.class.class"

local PublishSubsribe = Class("KA_PublishSubscribe")

PublishSubsribe.__subsribers = {} -- For publish-subscribe model

function PublishSubsribe:addSubscriber(eventName, callback)
    e.expectAny("PublishSubsribe.addSubscriber.eventName", eventName)
    e.expectCallable("PublishSubsribe.addSubscriber.callback", callback)
    if not self.__subsribers[eventName] then
        self.__subsribers[eventName] = {}
    end
    table.insert(self.__subsribers[eventName], callback)
end

function PublishSubsribe:_notifyEvent(eventName, ...)
    e.expectAny("PublishSubsribe._notifyEvent.eventName", eventName)
    if self.__subsribers[eventName] then
        for _, callback in ipairs(self.__subsribers[eventName]) do
            callback(self, ...)
        end
    end
end

-- TODO: Add a "EVENTS" field that starts of {} and bubbles up. Need to add a hook (or change class/extend a new one) so that it doesn't conflict values

return PublishSubsribe