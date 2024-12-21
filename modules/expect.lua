-- An extension of cc.expect but it also allows you to use classes
local type = type
local select = select

local native = require "cc.expect"

local function expect(index, value, ...)
    local t = type(value)
    local className = (t == "table" and value.isClass) and value:getClassName() or nil -- is a class
    if className then
        -- Do the check with class first
        local all_classes = value:getAllClassNames()
        for i = 1, select('#', ...) do
            local other = select(i, ...) -- get the ith in the ...
            local other_name = (type(other) == "table" and other.isClass) and other._className or (type(other) == "string" and other or nil)
            if (other_name and value:isClass(other_name)) then return value end
        end
    end
    return native.expect(index, value, ...)
end

return {
    expect = expect,
}