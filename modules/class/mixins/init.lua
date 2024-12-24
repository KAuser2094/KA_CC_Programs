-- Holds a bunch of possible (usually generic) MixIns that you can use.
local GetterSetter = require "KA_CC.modules.class.mixins.GetterSetter"
local CaseInsensitive = require "KA_CC.modules.class.mixins.CaseInsensitive"
local PublishSubscribe = require "KA_CC.modules.class.mixins.PublishSubscribe"

local Class = require "KA_CC.modules.class.class"
local AllMixins = Class("KA_AllMixins", GetterSetter, CaseInsensitive, PublishSubscribe)

return {
    ALL = AllMixins,
    GetterSetter = GetterSetter,
    CaseInsensitive = CaseInsensitive,
    PublishSubscribe = PublishSubscribe,
}