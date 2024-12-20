local class = require "KA_CC.modules.class"
Test = class("KA_Test")

function Test:init(context)
    self.context = context
    self.tests = {}
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
    for _, test in pairs(self.tests) do
        test(self.context)
        if waitForInput then
            _ = io.read("Press key to do next test.")
        end
    end
end

return Test