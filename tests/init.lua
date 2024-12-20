local textutils = _G.textutils

local class = require "KA_CC.modules.class"
local t_utils = require "KA_CC.tests.utils"

local peripheral_tests = require "KA_CC.tests.tests_peripheral"

Test = class("KA_Test")

function Test:init(context)
    self.context = context
    self.tests = {}

    self:addTests(peripheral_tests)
end

function Test:addTest(testFunction)
    table.insert(self.tests, testFunction)
end

function Test:addTests(testsTable)
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
            print("Enter for next test. (" .. i .. "/" .. test_count .. ")")
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