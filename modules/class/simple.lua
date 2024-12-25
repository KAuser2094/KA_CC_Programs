-- A simpler class implementation I know works (mostly for tests, but could be for other stuff that obviously don't need the extra stuff)

-- From http://lua-users.org/wiki/SimpleLuaClasses

-- MAYBE: Add the bare minimum so this is considered a class still by other code (expect and the normal class itself)

local function class(name)
    local cls = {}

    cls.__className = name
    

    -- CONSTRUCTOR
    function cls:new(...)
        local instance = setmetatable({}, cls)
        if instance.init then
            instance:init(...)
        end
        return instance
    end

    -- MAKE TABLE CALLABLE
    setmetatable(cls, {
        __call = function(_, ...)
            return cls:new(...)
        end,
    })

    -- SET THE FALLBACK TO TABLE ITSELF SO THE INSTANCE METHODS WORK
    cls.__index = cls

-- RETURNS
    return cls
end

return class