-- Allows for a class with the publish-subscribe model
local textutils = _G.textutils

local e = require "KA_CC.modules.expect"
local Class = require "KA_CC.modules.class.class"
local utils = require "KA_CC.modules.utils"

-- Some extra functionality that I didn't feel like adding into the basic class
local PublishSubsribe = Class("KA_PublishSubscribe")

PublishSubsribe.__subsribers = {} -- For publish-subscribe model

PublishSubsribe:addBubbledField("__ENUM_EVENTS", utils.shallowCopy(PublishSubsribe.__BASIC_HOOKS)) -- Enum with all events/hooks

function PublishSubsribe:EVENT_HOOKS()
    return self.__ENUM_EVENTS
end

function PublishSubsribe:addEventHook(enumName, eventName) -- please use snake case or normal typing (with spaces)
    eventName = eventName and eventName or enumName -- I wanted enum to go first -_-
    enumName = self:getClassName() .. "_" .. enumName
    for k, v in pairs(self.__ENUM_EVENTS) do
        assert(enumName ~= k, enumName .. " is already a key in the event/hook enum.")
        assert(eventName ~= v, eventName .. " is already a possible event name, adding a duplicate may result in unintended consequences, try adding getClassName() to the start of the name")
    end
    self.__ENUM_EVENTS[enumName] = eventName
end

function PublishSubsribe:mergeEventHookEnum(otherEnum)
    e.expectTable("PublishSubsribe.mergeEventHookEnum.otherEnum", otherEnum)
    for k,v in pairs(otherEnum) do
        local true_k = self:getClassName() .. "_" .. k
        self.__ENUM_EVENTS[true_k] = v
    end
end

function PublishSubsribe:addSubscriber(eventName, callback) -- One callback per event per class
    e.expectAny("PublishSubsribe.addSubscriber.eventName", eventName)
    e.expectCallable("PublishSubsribe.addSubscriber.callback", callback)
    assert(utils.hasValue(self.__ENUM_EVENTS, eventName), eventName .. "is not in the list of events, add or merge in the event first. Current Events: " .. textutils.serialise(self.__ENUM_EVENTS))
    self:addHook(eventName, callback)
end

function PublishSubsribe:_notifyEvent(eventName, ...)
    e.expectAny("PublishSubsribe._notifyEvent.eventName", eventName)
    assert(utils.hasValue(self.__ENUM_EVENTS, eventName), eventName .. "is not in the list of events, add or merge in the event first. Current Events: " .. textutils.serialise(self.__ENUM_EVENTS))
    self:_execHooks(eventName, ...)
end

return PublishSubsribe