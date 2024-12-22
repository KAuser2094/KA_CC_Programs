local fs = _G.fs
local textutils = _G.textutils

local e = require "KA_CC.modules.expect"

local utils = {} -- A bunch of random functions that I don't want to make a single file for

-- Some functions taken for "https://github.com/kepler155c/opus/blob/4104750539695affeb6518947b53ef0c5ba372fb/sys/modules/opus/util.lua" 
-- (Comments will say...most are rewritten, or there was an obviously standard way of writing them)

-- Taken from opus (I don't want to deal with the matching)
function utils.getVersion()
	local version

	if _G._CC_VERSION then
		version = tonumber(_G._CC_VERSION:match('[%d]+%.?[%d][%d]'))
	end
	if not version and _G._HOST then
		version = tonumber(_G._HOST:match('[%d]+%.?[%d][%d]'))
	end

	return version or 1.7
end

-- Taken from opus (I don't want to deal with the matching)
function utils.getMinecraftVersion()
	local mcVersion = _G._MC_VERSION or 'unknown'
	if _G._HOST then
		local version = _G._HOST:match('%S+ %S+ %((%S.+)%)')
		if version then
			mcVersion = version:match('Minecraft (%S+)') or version
		end
	end
	return mcVersion
end


function utils.sign(number)
	e.expectNumber("utils.sign,number", number)
    if number == 0 then
        return 0
    end
    return number > 0 and 1 or -1
end

function utils.clamp(number, lb, ub)
	e.expectNumber("utils.clamp.number", number)
	e.expectNumber("utils.clamp.lb", lb)
	e.expectNumber("utils.clamp.ub", ub)

    number = number > lb and number or lb
    number = number < ub and number or ub
    return number
end

-- http://lua-users.org/wiki/SimpleRound
function utils.round(num, numDecimalPlaces)
	e.expectNumber("utils.round.num", num)
	e.expectNumber("utils.round.numDecimalPlaces", numDecimalPlaces)

	local mult = 10^(numDecimalPlaces or 0)
	return utils.sign(num) * math.floor(math.abs(num) * mult + 0.5) / mult
end

function utils.randomFloat(lb, ub)
	e.expectNumber("utils.randomFloat.lb", lb)
	e.expectNumber("utils.randomFloat.ub", ub)
	local lb2 = lb or 0
	local ub2 = ub or 1
	return (ub2-lb2) * math.random() + lb2
end

function utils.clearTable(tbl)
	e.expectTable("utils.clearTable.tbl", tbl)
    for key,_ in pairs(tbl) do
        tbl[key] = nil
    end
end

function utils.isEmptyTable(tbl)
	e.expectTable("utils.isEmptyTable.tbl", tbl)
    return not next(tbl)
end

function utils.getKeyAtValue(tbl, value)
	e.expectTable("utils.getKeyAtValue.tbl", tbl)
	e.expectAny("utils.getKeyAtValue.value", value)
    for key, v in pairs(tbl) do
        if v == value then
            return key
        end
    end
end

function utils.getKeys(tbl)
	e.expectTable("utils.getKeys.tbl", tbl)
    local keys = {}
    for k,_ in pairs(tbl) do
        table.insert(tbl, k)
    end
    return keys
end

function utils.shallowMerge(tbl, other)
	e.expectTable("utils.shallowMerge.tbl", tbl)
	e.expectTable("utils.shallowMerge.other", other)
    for key, value in pairs(other) do
        tbl[key] = value
    end
    return tbl
end

function utils.deepMerge(tbl, other)
	e.expectTable("utils.deepMerge.tbl", tbl)
	e.expectTable("utils.deepMerge.other", other)
    for key, value in pairs(other) do
        if type(value) == 'table' then
            tbl[key] = tbl[key] or {}
            utils.deepMerge(tbl[key],value)
        else
            tbl[key] = value
        end
    end
end

function utils.transpose(tbl)
	e.expectTable("utils.transpose.tbl", tbl)
    local t_tbl = {}
    for key, value in pairs(tbl) do
        t_tbl[value] = key
    end
    return t_tbl
end

function utils.hasValue(tbl, value)
	e.expectTable("utils.hasValue.tbl", tbl)
	e.expectAny("utils.hasValue.value", value)
	return utils.containsValue(tbl, value) -- Both functions names make sense
end

function utils.containsValue(tbl, value)
	e.expectTable("utils.containsValue.tbl", tbl)
	e.expectAny("utils.containsValue.value", value)
    for key, v in pairs(tbl) do
        if v == value then
            return key
        end
    end
end

function utils.partialFunction(func, arg1)
	e.expectCallable("utils.partialFunction.func", func)
	-- arg1 isn't at all mandatory
	local partial =  function (...)
		return func(arg1, ...)
	end

	return partial
end

function utils.hasSubset(tbl, subset)
	e.expectTable("utils.hasSubset.tbl", tbl)
	e.expectTable("utils.hasSubset.subset", subset)
	local func = utils.partialFunction(utils.hasValue, tbl)
	return utils.all(subset, func)
end

function utils.shallowCopy(tbl)
	e.expectTable("utils.shallowCopy.tbl", tbl)
    local copy = {}
    for key, value in pairs(tbl) do
        copy[key] = value
    end
    return copy
end

function utils.deepCopy(tbl)
	e.expectTable("utils.deepCopy.tbl", tbl)
    local copy = {}
    for key, value in pairs(tbl) do
        if type(value) == 'table' then
            copy[key] = utils.deepCopy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

-- http://snippets.luacode.org/?p=snippets/Filter_a_table_in-place_119
function utils.filterInplace(tbl, filter_func) -- this is a weird way to do it... might change later
	e.expectTable("utils.filterInplace.tbl", tbl)
	e.expectCallable("utils.filterInplace.filter_func", filter_func)
	local j = 1

	for i = 1,#tbl do
		local v = tbl[i]
		if filter_func(v) then
			tbl[j] = v
			j = j + 1
		end
	end

	while tbl[j] ~= nil do
		tbl[j] = nil
		j = j + 1
	end

	return tbl
end

function utils.filter(tbl, filter_func) -- this is a weird way to do it... might change later
	e.expectTable("utils.filter.tbl", tbl)
	e.expectCallable("utils.filter.filter_func", filter_func)
    local filtered_tbl = {}

    for key, value in pairs(tbl) do
        if filter_func(value) then
            filtered_tbl[key] = value
        end
    end

	return filtered_tbl
end

function utils.filterIndex(i_tbl, filter_func)
	e.expectTable("utils.filterIndex.tbl", tbl)
	e.expectCallable("utils.filterIndex.filter_func", filter_func)
    local filtered_tbl = {}

    for _, value in ipairs(i_tbl) do
        if filter_func(value) then
			table.insert(filtered_tbl, value)
        end
    end

	return filtered_tbl
end

function utils.reduce(tbl, reduce_func, initial)
	e.expectTable("utils.reduce.tbl", tbl)
	e.expectCallable("utils.reduce.reduce_func", reduce_func)
	local accumulated = initial or 0
	for _, value in pairs(tbl) do
		accumulated = reduce_func(accumulated, value)
	end
	return accumulated
end

function utils.size(tbl)
	if type(tbl) == 'table' then
		return #tbl -- why
	end
	return 0
end

function utils.removeDuplicates(i_tbl)
	e.expectTable("utils.removeDuplicates.i_tbl", i_tbl)
    local seen = {} 
    local result = {}

    for _, value in ipairs(i_tbl) do
        if not seen[value] then
            seen[value] = true
            table.insert(result, value)
        end
    end

    return result
end


-- Taken from opus
local function isArray(value)
	-- dubious
	return type(value) == "table" and (value[1] or next(value) == nil)
end

-- Taken from opus
function utils.removeByValue(t, _e)
	e.expectTable("utils.removeByValue.t", t)
	e.expectAny("utils.removeByValue._e", _e)
	for k,v in pairs(t) do
		if v == _e then
			if isArray(t) then
				table.remove(t, k)
			else
				t[k] = nil
			end
			break
		end
	end
end

function utils.any(tbl, func)
	e.expectTable("utils.any.tbl", tbl)
	e.expectCallable("utils.any.func", func)
	for _, value in pairs(tbl) do
		if func(value) then
			return true
		end
	end
end

function utils.all(tbl, func)
	e.expectTable("utils.all.tbl", tbl)
	e.expectCallable("utils.all.func", func)
	return utils.every(tbl, func) -- Both names make sense
end

function utils.every(tbl, func)
	e.expectTable("utils.every.tbl", tbl)
	e.expectCallable("utils.every.func", func)
	for _, value in pairs(tbl) do
		if not func(value) then
			return false
		end
	end
	return true
end

-- http://stackoverflow.com/questions/15706270/sort-a-table-in-lua
function utils.spairs(t, order)
	e.expectTable("utils.spairs.t", t)
	e.optionalCallable("utils.spairs.order", order)
	local keys = utils.getKeys(t)

	-- if order function given, sort by it by passing the table and keys a, b,
	-- otherwise just sort the keys
	if order then
		table.sort(keys, function(a,b) return order(t[a], t[b]) end)
	else
		table.sort(keys)
	end

	-- return the iterator function
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

-- Taken from opus
function utils.first(t, order)
	e.expectTable("utils.first.t", t)
	e.optionalCallable("utils.first.order", order)
	local keys = utils.getKeys(t)
	if order then
		table.sort(keys, function(a,b) return order(t[a], t[b]) end)
	else
		table.sort(keys)
	end
	return keys[1], t[keys[1]]
end

function utils.readFile(file_name, flags)
	e.expectString("utils.readFile.file_name", file_name)
	e.optionalString("utils.readFile.flags", flags)
	local file = fs.open(file_name, flags or "r")
	if file then
		local contents = file.readAll()
		file.close()
		return contents
	end
end

-- taken from opus
function utils.writeFile(fname, data, flags)
	e.expectString("utils.writeFile.fname", fname)
	e.expectAny("utils.writeFile.data", data)
	e.optionalString("utils.writeFile.flags", flags)

	if fs.exists(fname) then
		local diff = #data - fs.getSize(fname)
		if diff > 0 then
			if fs.getFreeSpace(fs.getDir(fname)) < diff then
				error('Insufficient disk space for ' .. fname)
			end
		end
	end

	local file = io.open(fname, flags or "w")
	if not file then
		error('Unable to open ' .. fname, 2)
	end
	file:write(data)
	file:close()
end

-- taken from opus
function utils.readLines(fname)
	e.expectString("utils.readLines.fname", fname)
	local file = fs.open(fname, "r")
	if file then
		local t = {}
		local line = file.readLine()
		while line do
			table.insert(t, line)
			line = file.readLine()
		end
		file.close()
		return t
	end
end

-- taken from opus
function utils.writeLines(fname, lines)
	e.expectString("utils.writeLines.fname", fname)
	e.expectTable("utils.writeLines.lines", lines)
	local file = fs.open(fname, 'w')
	if file then
		for _,line in ipairs(lines) do
			file.writeLine(line)
		end
		file.close()
		return true
	end
end

-- taken from opus
function utils.readTable(fname)
	e.expectString("utils.readTable.fname", fname)
	local t = utils.readFile(fname)
	if t then
		return textutils.unserialize(t)
	end
end

-- taken from opus
function utils.writeTable(fname, data)
	e.expectString("utils.writeTable.fname", fname)
	e.expectTable("utils.writeTable.data", data)
	utils.writeFile(fname, textutils.serialize(data))
end

-- taken from opus
function utils.loadTable(fname)
	e.expectString("utils.loadTable.fname", fname)
	local fc = utils.readFile(fname)
	if not fc then
		return false, 'Unable to read file'
	end
	local s, m = loadstring('return ' .. fc, fname)
	if s then
---@diagnostic disable-next-line: cast-local-type -- Why are you like this
		s, m = pcall(s)
		if s then
			return m
		end
	end
	return s, m
end

-- taken from opus START:
function utils.insertString(str, istr, pos)
	e.expectString("utils.insertString.str", str)
	e.expectString("utils.insertString.istr", istr)
	e.expectNumber("utils.insertString.pos", pos)
	return str:sub(1, pos - 1) .. istr .. str:sub(pos)
end

function utils.split(str, pattern)
	e.expectString("utils.split.str", str)
	e.optionalString("utils.split.pattern", pattern)

	if not str or type(str) ~= 'string' then error('utils.split: Invalid parameters', 2) end
	pattern = pattern or "(.-)\n"
	local t = {}
	local function helper(line) table.insert(t, line) return "" end
	helper((str:gsub(pattern, helper)))
	return t
end

function utils.matches(str, pattern)
	e.expectString("utils.matches.str", str)
	e.optionalString("utils.matches.pattern", pattern)
	pattern = pattern or '%S+'
	local t = { }
	for s in str:gmatch(pattern) do
		 table.insert(t, s)
	end
	return t
end

function utils.startsWith(s, match)
	e.expectString("utils.startsWith.s", s)
	e.expectString("utils.startsWith.match", match)
	return string.sub(s, 1, #match) == match
end

-- TODO: Type these
local function wrap(text, max, lines)
	local index = 1
	repeat
		if #text <= max then
			table.insert(lines, text)
			text = ''
		elseif text:sub(max+1, max+1) == ' ' then
			table.insert(lines, text:sub(index, max))
			text = text:sub(max + 2)
		else
			local x = text:sub(1, max)
			local s = x:match('(.*) ') or x
			text = text:sub(#s + 1)
			table.insert(lines, s)
		end
		text = text:match('^%s*(.*)')
	until not text or #text == 0
	return lines
end

function utils.wordWrap(str, limit)
	local lines = { }

	for _,line in ipairs(utils.split(str)) do
		wrap(line, limit, lines)
	end

	return lines
end
-- taken from opus END

-- http://snippets.luacode.org/?p=snippets/trim_whitespace_from_string_76
function utils.trim(s)
	e.expectString("utils.trim.s", s)
	return s:find('^%s*$') and '' or s:match('^%s*(.*%S)')
end

-- trim whitespace from left end of string
function utils.triml(s)
	e.expectString("utils.triml.s", s)
	return s:match('^%s*(.*)')
end

-- trim whitespace from right end of string
function utils.trimr(s)
	e.expectString("utils.trimr.s", s)
	return s:find('^%s*$') and '' or s:match('^(.*%S)')
end
-- end http://snippets.luacode.org/?p=snippets/trim_whitespace_from_string_76

return utils