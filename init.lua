-- Requiring nearly all the files in the repo sounds like a good idea :)
-- At least this will let me know if there is a build/compile error

local modules = require "KA_CC.modules"
local _peripheral = require "KA_CC.peripheral"
local tests = require "KA_CC.tests"

local t = {}

t.modules = modules
t.peripheral = _peripheral
t.tests = tests

return t