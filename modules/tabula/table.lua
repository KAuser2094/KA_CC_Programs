-- a wrapper around normal tables to give methods
local Class = require "KA_CC.modules.tabula.class"
-- NOTE: If you need to call another Table method in another, USE DOT NOTATION FOR THE FUNCTION CALL. You cannot presume that the table passed is a tabula table
-------------------------
--------------------------------------------------
----------------------------------------------------------------------------------------------------
--- CLASS STUFF
----------------------------------------------------------------------------------------------------
local Table = Class()
local expectModule = Table._expect()
local expect, expectTable, expectAny, expectBoolean = expectModule.expect, expectModule.expectTable, expectModule.expectAny, expectModule.expectBoolean

function Table:__init(tbl)
    if tbl then
        expectTable("Table._init.tbl (Was not nil)", tbl)
        self:tableDeepMerge(tbl)
    end
end

Table.__isTabulaTable = true -- Is just here to identify class (I am not adding the whole isClass() implementation)

function Table:isTabulaTable()
    return self.__isTabulaTable -- Do Table.isTabulaTable(<MaybeIsTabulaTable>) to check another table instead  
end


----------------------------------------------------------------------------------------------------
--- PROPERTY STUFF
----------------------------------------------------------------------------------------------------

function Table:tableIsEmpty()
    expectTable("Table.tableIsEmpty.self", self)
    return Table.tableCount(self) == 0
end


function Table:tableCount()
    local count = 0
    for _,_ in pairs(self) do
        count = count + 1
    end
    return count
end



----------------------------------------------------------------------------------------------------
--- Global Table Implementations
----------------------------------------------------------------------------------------------------

--------------------------------------------------
----- Properties
--------------------------------------------------

function Table:tableGetN()
    expectTable("Table.tableGetN.self", self)
    table.getn(self)
end

function Table:tableMaxN()
    expectTable("Table.tableMaxN.self", self)
    table.maxn(self)
end

--------------------------------------------------
----- Operations
--------------------------------------------------

function Table:tableInsert(pos, value)
    expectTable("Table.tableInsert.self", self)
    local hasValue = value
    value = hasValue and value or pos
    pos = hasValue and pos or nil
    expect("Table.insert.pos", pos, "number", "nil")
    if pos then
        -- Guarenteed to have value (pos would have been set to nil)
        table.insert(self, pos, value)
    else
        expectAny("Table.inser.value", value)
        table.insert(self, value)
    end
end


function Table:tableRemove(pos)
    expectTable("Table.tableRemove.self", self)
    if pos then
        expectNumber("Table.tableRemove.pos (not nil)", pos)
    end
    table.remove(self, pos)
end


----------------------------------------------------------------------------------------------------
--- Other Table Implementations
----------------------------------------------------------------------------------------------------

--------------------------------------------------
----- Properties (may return a value or boolean)
--------------------------------------------------

function Table:tableGetKeys()
    expectTable("Table.tableGetKeys.self", self)
    local t = {}
    for k,_ in pairs(self) do
        Table.tableInsert(t, k)
    end
    return t
end


function Table:tableGetValues()
    expectTable("Table.tableGetValues.self", self)
    local t = {}
    for _,v in pairs(self) do
        Table.tableInsert(t, v)
    end
    return t
end


function Table:tableHasValue(value)
    expectTable("Table.tableHasValue.self", self)
    expectAny("Table.tableHasValue.value", value)
    for _, v in pairs(self) do
        if v == value then
            return value
        end
    end
end


function Table:tableGetKeyAtValue(value)
    expectTable("Table.tableGetKeyAtValue.self", self)
    expectAny("Table.tableGetKeyAtValue.value", value)
    for key, v in pairs(self) do
        if v == value then
            return key
        end
    end
end


function Table:tableIsSparse()
    expectTable("Table.tableIsSparse", self)
    return Table.tableGetN(self) ~= Table.tableMaxN(self)
end



function Table:tableHasOnlyIndexKeys()
    expectTable("Table.tableHasOnlyIndexKeys.self", self)
    for k,v in pairs (self) do
        if type (k) ~= "number" then
            return false
        end
    end
    return true
end


function Table:tableIsPureArray()
    expectTable("Table.tableIsPureArray.self", self)
    local isPureArray = (Table.tableHasOnlyIndexKeys(self) and (not Table.tableIsSparse(self)))
    return isPureArray
end

--------------------------------------------------
----- Set stuff
--------------------------------------------------

function Table:tableComplement(other)
    expectTable("Table.tableComplement.self", self)
    expectTable("Table.tableComplement.other", other)
    local function complement(tbl, other)
        
    end
    return
end

--------------------------------------------------
----- Copies
--------------------------------------------------

function Table:tableCopy()
    expectTable("Table.tableCopy.self", self)
    local function shallowCopy(tbl)
        local copy = {}
        for k, v in pairs(tbl) do
            copy[k] = v
        end
        return copy
    end
    local copy = shallowCopy(self)
    return Table.isTabulaTable(self) and Table(copy) or copy
end


function Table:tableDeepCopy()
    expectTable("Table.tableDeepCopy.self", self)
    local function deepCopy(tbl)
        local copy = {}
        for k,v in pairs(tbl) do
            if type(v) == "table" then
                copy[k] = deepCopy(v)
            else
                copy[k] = v
            end
        end
        return copy
    end
    local copy = deepCopy(self)
    return Table.isTabulaTable(self) and Table(copy) or copy
end


--------------------------------------------------
----- Merges
--------------------------------------------------

function Table:tableMerge(other)
    expectTable("Table.tableMerge.self", self)
    expectTable("Table.tableMerge.other", other)
    local function shallowMerge(tbl, _other)
        for k,v in pairs(_other) do
                tbl[k] = v
        end
    end
    shallowMerge(self, other)
end


function Table:tableDeepMerge(other)
    expectTable("Table.tableDeepMerge.self", self)
    expectTable("Table.tableDeepMerge.other", other)
    local function deepMerge(tbl, _other)
        for k,v in pairs(_other) do
            if type(v) == "table" then
                tbl[k] = tbl[k] or {} -- Errors if tbl[k] is not a table (or false in which case it overrides, both dumb), I am not adding extra presumptions, just make sure the shape is correct
                deepMerge(tbl[k], v)
            else
                tbl[k] = v
            end
        end
    end
    deepMerge(self, other)
end


--------------------------------------------------
----- Transforms
--------------------------------------------------

function Table:tableEmptyTable()
    expectTable("Table.tableEmptyTable.self", self)
    for k, _ in pairs(self) do
        self[k] = nil
    end
end


function Table:tableSetToTable(other)
    expectTable("Table.tableSetToTable.self", self)
    expectTable("Table.tableSetToTable.other", other)
    Table.tableEmptyTable(self)
    Table.tableMerge(other)
end


function Table:tableGetTranspose()
    expectTable("Table.tableGetTranspose.self", self)
    local t_tbl = {}
    for key, value in pairs(self) do
        t_tbl[value] = key
    end
    return t_tbl
end

function Table:tableTranspose()
    expectTable("Table.tableTranspose.self", self)
    local t_tbl = Table.tableGetTranspose(self)
    Table.tableSetToTable(self, t_tbl)
end

Table:_ProtectAllCurrentKeys()
Table:_removeProtectedKey("__init") -- Probably shouldn't be locked
----------------------------------------------------------------------------------------------------
return Table