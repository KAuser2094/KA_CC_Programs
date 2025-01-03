local class = require "KA_CC.modules.class".Class
local extends = require "KA_CC.modules.class".MixIns.ALL

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
    local testClass = class(TESTING_CLASS_NAME, extends)

    testClass:mergeEventHookEnum(EVENTS)

    testClass.STATIC = true

    testClass:removeCaseSensitivity("STATIC")

    testClass.STATICMETHOD = function ()
        return true
    end

    testClass:removeCaseSensitivity("STATICMETHOD")

    function testClass:init(id)
        self._id = id or nil
    end

    testClass:removeCaseSensitivity("_id")

    function testClass:returnTrue()
        return true
    end

    testClass:removeCaseSensitivity("returnTrue")

    testClass:addGetter("id", function (self)
        return self._id
    end)

    testClass:addSetter("id", function (self, value)
        self._id = value
    end)

    function testClass:addToSubscribers(value)
        self:_notifyEvent(EVENTS.TEST1, value)
    end

    testClass:removeCaseSensitivity("addToSubscribers")

    return testClass
end

local function getChildTestingClass()
    local base = getTestingClass()
    local child = class(CHILD_TESTING_CLASS_NAME, base)

    function child:init(id)
        self:super(base).init(self, id)
    end

    return child
end

local function getSubscriberClass()
    local subscriber = class(SUBSCRIBER_TESTING_CLASS_NAME, extends)

    function subscriber:init(testingClass)
        self.publisher = testingClass
        self.value = 0

        self.publisher:addSubscriber(EVENTS.TEST1, function (publisher,value)
            if publisher._id and self.publisher._id and publisher._id == self.publisher._id then
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

function tests.properties(context)
    t_utils.testTitle(context, "Testing: Class module's getter and setters properties")
    local c_class = getTestingClass()
    local cc_class = getChildTestingClass()

    local c_1 = c_class(1)
    local c_2 = c_class(0)
    local cc_1 = cc_class(2)

    assert(c_1.id, "c_1.id does not exist")
    assert(c_2.id, "c_2.id does not exist")
    assert(cc_1.id, "cc_1.id does not exist")


    assert(c_1.id == 1, "getter is not working for base class")
    assert(c_2.id == 0, "getter is not working for base class 2")
    assert(cc_1.id == 2, "getter is not working for child class")

    c_1.id = 5
    cc_1.id = 10

    assert(c_1.id == 5, "base class should have changed to 5, got: " .. c_1.id)
    assert(c_2.id == 0, "2nd base class should not have id changed (0), got: " .. c_2.id)
    assert(cc_1.id == 10, "child class should have changed to 10, got: " .. cc_1.id)
end

function tests.caseSensitivity(context)
    t_utils.testTitle(context, "Testing: Class module's case sensitivity (should not have it)")
    local c_class = getTestingClass()
    local cc_class = getChildTestingClass()

    local c_1 = c_class(1)
    local cc_1 = cc_class(2)

    -- Sanity
    assert(c_1._id, "Why does c_1 not have an _id, got: " .. c_1._id)
    assert(c_1.id, "Why does c_1 not have an id, got: " .. c_1.id)
    assert(c_1.id == 1, "Why does c_1,id not equal 1, got: " .. c_1.id)
    assert(c_1.returnTrue and c_1.returnTrue(), "c_1 does not have returnTrue or it does not in fact return true")
    assert(c_1.STATIC, "c_1 does not have STATIC defined")

    assert(cc_1.id, "Why does cc_1 not have an id, got: " .. cc_1.id)
    assert(cc_1._id, "Why does cc_1 not have an _id, got: " .. cc_1._id)
    assert(cc_1.id == 2, "Why does cc_1,id not equal 2, got: " .. cc_1.id)
    assert(cc_1.returnTrue and cc_1.returnTrue(), "cc_1 does not have returnTrue or it does not in fact return true")
    assert(cc_1.STATIC, "cc_1 does not have STATIC defined")

    -- -- instance fields
    assert(c_1._ID, "c_1._ID does not exist")
    assert(cc_1._ID, "cc_1._ID does not exist")

    -- getter and setters (Note that these work by setting string keys to functions)
    assert(c_1.ID, "Why does c_1 not have an ID, got: " .. c_1.ID)
    assert(cc_1.ID, "Why does cc_1 not have an ID, got: " .. cc_1.ID)

    -- static fields
    assert(c_1.statIC, "c_1 does not have statIC defined")
    assert(cc_1.statIC, "cc_1 does not have statIC defined")

    -- static methods
    assert(c_1.StAtICMethoD, "c_1 does not have StAtICMethoD")
    assert(c_1.StAtICMethoD(), "c_1 StAtICMethoD does not in fact return true")
    assert(cc_1.StAtICMethoD, "cc_1 does not have StAtICMethoD")
    assert(cc_1.StAtICMethoD(), "cc_1 StAtICMethoD does not in fact return true")

    -- instnace methods
    assert(c_1.RETurnTRue, "c_1 does not have RETurnTRue")
    assert(c_1:RETurnTRue(), "c_1 RETurnTRue does not in fact return true")
    assert(cc_1.RETurnTRue, "cc_1 does not have RETurnTRue")
    assert(cc_1:RETurnTRue(), "cc_1 RETurnTRue does not in fact return true")
end

-- test inheritance of instance and static values/functions

return tests