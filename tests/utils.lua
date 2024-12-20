local native = _G.peripheral

local utils = {}

function utils.getProvider(context)
    return native.wrap(context["provider"])
end

function utils.getNameAndWrappedFromType(context, type)
    local found = { native.find(type) }

    local wrapped = found[1]

    if context["provider"] and native.getName(wrapped) == context["provider"] then
        wrapped = found[2]
    end

    assert(wrapped, "Was unable to get a peripheral of the given type: " .. type .. ". Are the flags for this test correct?")

    return native.getName(wrapped), wrapped
end

function utils.testTitle(context, ...)
    if context["testTitle"] then
        print(...)
    end
end

function utils.verbosePrint(context, ...)
    if context["verbose"] then
        print(...)
    end
end


return utils