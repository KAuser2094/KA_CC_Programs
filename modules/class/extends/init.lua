-- Holds a bunch of possible (usually generic) extends that you can use.
local GetterSetter = require "KA_CC.modules.class.extends.GetterSetter"
local CaseInsensitive = require "KA_CC.modules.class.extends.CaseInsensitive"
local PublishSubscribe = require "KA_CC.modules.class.extends.PublishSubscribe"

local Class = require "KA_CC.modules.class.class"
local AllExtends = Class("KA_AllExtends", GetterSetter, CaseInsensitive, PublishSubscribe)

return {
    ALL = AllExtends,
    GetterSetter = GetterSetter,
    CaseInsensitive = CaseInsensitive,
    PublishSubscribe = PublishSubscribe,
}