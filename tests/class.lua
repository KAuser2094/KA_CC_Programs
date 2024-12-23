-- TODO: 
-- Move all this to a "class" file and make this a module table. So you should be able to do local run_tests = "KA_CC".tests.run_tests -- run_tests()

local textutils = _G.textutils

local expect = require "cc.expect".expect

local class = require "KA_CC.modules.class.simple"
local t_utils = require "KA_CC.tests.utils"

local class_tests = require "KA_CC.tests.test_class"
local expect_tests = require "KA_CC.tests.test_expect"
local peripheral_tests = require "KA_CC.tests.test_peripheral"

Test = class("KA_Test")

function Test:init(context)
    self.context = context
    self.tests = {}

    assert(class_tests, "class_tests")
    self:addTests(class_tests)
    assert(expect_tests, "expect_tests")
    self:addTests(expect_tests)
    assert(peripheral_tests, "peripheral_tests")
    self:addTests(peripheral_tests)
end

function Test:addTest(testFunction)
    expect(1,testFunction,"function")
    table.insert(self.tests, testFunction)
end

function Test:addTests(testsTable)
    expect(1, testsTable, "table")
    for _, test in pairs(testsTable) do
        self:addTest(test)
    end
end

function Test:runTests(waitForInput)
    local results = {
        ["FAILS"] = 0,
        ["SKIPS"] = 0,
        ["PASSES"] = 0,
        ["TOTAL_RUN"] = 0,
        ["TOTAL"] = #self.tests
    }
    local test_count = #self.tests
    for i, test in ipairs(self.tests) do
        -- Run the test
        t_utils.testResolutionPrint(self.context, "--------------------")
        t_utils.testResolutionPrint(self.context, "TEST: (" .. i .. "/" .. test_count .. ")")
        local notFail, skipped = pcall(test,self.context) -- Will return true early if skipped
        if not notFail then
            t_utils.assertPrint(self.context, skipped) -- Skipped holds the error value if errored
        end
        t_utils.testResolutionPrint(self.context, not notFail and "[FAILED]" or (skipped and "[SKIPPED]" or "[PASSED]"))
        t_utils.testResolutionPrint(self.context, "--------------------")
        -- Update results
        if not notFail then
            results["FAILS"] = results["FAILS"] + 1
            results["TOTAL_RUN"] = results["TOTAL_RUN"] + 1
        elseif skipped then
            results["SKIPS"] = results["SKIPS"] + 1
        else
            results["PASSES"] = results["PASSES"] + 1
            results["TOTAL_RUN"] = results["TOTAL_RUN"] + 1
        end

        -- Wait for input
        if i ~= test_count and waitForInput then
            print("Enter for next test. (" .. (i+1) .. "/" .. test_count .. ")")
---@diagnostic disable-next-line: discard-returns
            io.read()
        end
    end
    return results
end

function Test:printResults(results)
    local skips = results["SKIPS"]
    local fails = results["FAILS"]
    local passes = results["PASSES"]
    local total_run = results["TOTAL_RUN"]
    local total = results["TOTAL"]
    print("--------------------")
    print("SKIPS: " .. skips .. " out of " .. total)
    print("PASSES: " .. passes .. " out of " .. total_run)
    print("FAILS: " .. fails .. " out of " .. total_run)
    print("--------------------")
    
    assert(total-skips == total_run, "Possible malformed results")
    assert(fails+passes == total_run, "Possible malformed results")
end

function Test:printContext()
    local serialised = textutils.serialise(self.context)
    print(serialised)
end

return Test