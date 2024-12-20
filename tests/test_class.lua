local class = require "KA_CC.modules.class"

local t_utils = require "KA_CC.tests.utils"

-- DEFINE CONTEXT WE ARE WORKING OFF
local TESTING_CLASS_NAME = "A test class"
local CHILD_TESTING_CLASS_NAME = "A child test class"
local SUBSCRIBER_TESTING_CLASS_NAME = "A subscriber class"
local EVENTS = {
    TEST1 = 0,
    Test2 = 1,
}
local function getTestingClass()
    id = id or nil
    local testClass = class(TESTING_CLASS_NAME)

    function testClass:init(id)
        self.id = id or nil
    end

    function testClass:addToSubscribers(value)
        self:_notifyEvent(EVENTS.TEST1, value)
    end

    return testClass
end

local function getChildTestingClass()
    local base = getTestingClass()
    local child = class(CHILD_TESTING_CLASS_NAME, base)

    return child
end

local function getSubscriberClass()
    local subscriber = class(SUBSCRIBER_TESTING_CLASS_NAME)

    function subscriber:init(testingClass)
        self.publisher = testingClass
        self.value = 0

        self.publisher:addSubscriber(EVENTS.TEST1, function (publisher,value)
            if publisher.id and self.publisher.id and publisher.id == self.publisher.id then
                self.value = self.value + value
            end
        end)
    end

    return subscriber
end

local tests = {}

function tests.className(context)
    t_utils.testTitle(context, "Testing: Class module's className and its functions work")
    local c = getTestingClass()()
    local cc = getChildTestingClass()()
    assert(c.getClassName() == TESTING_CLASS_NAME, "Got incorrect class name from base class, got: " .. c.getClassName())
    assert(cc.getClassName() == CHILD_TESTING_CLASS_NAME, "Got incorrect class name from child class, got: " .. cc.getClassName())
end

function tests.isClass(context)
    t_utils.testTitle(context, "Testing: Class module's isClass function works")
    local c_class = getTestingClass()
    local c_instance = c_class()
    local c_instance2 = c_class()

    local cc_class = getChildTestingClass()
    local cc_instance = cc_class()

    assert(c_instance:isClass(c_class), "instance of base class isn't recognised as such")
    assert(cc_instance:isClass(cc_class), "instance of child class isn't recognised as such")
    assert(cc_instance:isClass(c_class), "instance of child class isn't recognised as base class")

    assert(c_instance:isClass(c_instance2), "one instance of base class isn't recognised as also being the same class as another")
    assert(cc_instance:isClass(c_instance), "instance of child class isn't recognised as also being the same class as a base class instance")

end

-- tests publish-subscribe
function tests.publishSubscribe(context)
    t_utils.testTitle(context, "Testing: Class module's publish and subscribe model works")
    local sc_class = getSubscriberClass()
    local c_class = getTestingClass()
    local cc_class = getChildTestingClass()

    local c_1 = c_class(1)
    local c_2 = c_class()
    local cc_1 = cc_class(2)
    local sc_1 = sc_class(c_1)
    local sc_2 = sc_class(cc_1)

    assert(sc_1.value == 0, "How did the sc_1.value not init to 0, got: " .. sc_1.value)
    assert(sc_2.value == 0, "How did the sc_2.value not init to 0, got: " .. sc_2.value)

    -- Assert callbacks are actually set

    -- assert(c_1._subsribers[EVENTS.TEST1] and )

    -- Assert Callbacks are ran when expected
    c_1:addToSubscribers(2)

    assert(sc_1.value == 2, "sc_1.value should have become 2 when callback is called, got: " .. sc_1.value)
    assert(sc_2.value == 0, "sc_2.value shouldn't have changed from 0, got: " .. sc_2.value)

    c_2:addToSubscribers(2)

    assert(sc_1.value == 2, "sc_1.value shouldn't have changed from 2, got:" .. sc_1.value)
    assert(sc_2.value == 0, "sc_2.value shouldn't have changed from 0, got: " .. sc_2.value)

    cc_1:addToSubscribers(2)

    assert(sc_1.value == 2, "sc_1.value shouldn't have changed from 2, got:" .. sc_1.value)
    assert(sc_2.value == 2, "sc_2.value should have become 2 when callback is called, got: " .. sc_2.value)
end

-- test getter and setter property


return tests