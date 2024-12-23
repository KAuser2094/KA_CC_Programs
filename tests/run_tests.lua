-- Runs tests is KA_CC.tests
local Test = require "KA_CC.tests.class"
local context = require "KA_CC.tests.test_context"

-- Run
local function run_tests(waitForInput)
    waitForInput = waitForInput or true
    -- Get test class
    local tester = Test(context)
    -- Some pre-tests since the tester literally relies on some of the stuff being tested -_-.
    assert(tester, "Tester couldn't be instantiated")

    -- Run
    local results = tester:runTests(waitForInput)
    tester:printResults(results)
end

return run_tests
-- Add a file in the root directory with:
-- require "KA_CC".tests.run_tests()

-- This will try and build/compile (whatever the term) most of the lua files and the run the tests