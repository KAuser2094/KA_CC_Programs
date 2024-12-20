-- Runs tests is KA_CC.tests
local Test = require "KA_CC.tests"
local context = require "KA_CC.tests.test_context"
-- (maybe) use passed in parameters in terminal to change context (like verbosity and waiting for input before next test)
local waitForInput = true
-- Get test class
local tester = Test(context)
-- Some pre-tests since the tester literally relies on some of the stuff being tested -_-.
assert(tester, "Tester couldn't be instantiated")

-- Run
local results = tester:runTests(waitForInput)
tester:printResults(results)