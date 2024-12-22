-- Allows for a class with the publish-subscribe model

local Class = require "KA_CC.modules.class.class"

local PublishSubsribe = Class("KA_PublishSubscribe")

PublishSubsribe.__subsribers = {} -- For publish-subscribe model

function PublishSubsribe:addSubscriber(eventName, callback)

    if not self.__subsribers[eventName] then
        self.__subsribers[eventName] = {}
    end
    table.insert(self.__subsribers[eventName], callback)
end

function PublishSubsribe:_notifyEvent(eventName, ...)
    if self.__subsribers[eventName] then
        for _, callback in ipairs(self.__subsribers[eventName]) do
            callback(self, ...)
        end
    end
end

return PublishSubsribe