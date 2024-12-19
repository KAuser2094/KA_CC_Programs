local function class()
    local cls = {}
    cls.__index = cls


    function cls:new(...)
        local instance = setmetatable({}, cls)
        if instance.init then
            instance:init(...)
        end
        return instance
    end

    setmetatable(cls, {
        __call = function(_, ...)
            return cls:new(...)
        end
    })

    return cls
end

return class