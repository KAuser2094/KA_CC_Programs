-- Just some random functions that I often use

-- TRY REQUIRE (will keep trying different paths and only fail after trying all)
-- Usage: `local invMod = tryRequire({ "inventory", "KA_CC_Programs/inventory" })`
local function tryRequire(paths)
	local errorMsgs = {}
	for _, path in ipairs(paths) do
		local success, module = pcall(require, path)
		if success then
			return module
		else
			table.insert(errorMsgs, "Failed to require from '" .. path .. "': " .. module)
		end
	end
	error(table.concat(errorMsgs, "\n"))
end

local function isInList(list, value)
	for _, v in ipairs(list) do
		if v == value then
			return true
		end
	end
	return false
end

function shallowCopy(original)
	local copy = {}
	for key, value in pairs(original) do
		copy[key] = value
	end
	return copy
end

local function gatherFunctions(tbl)
	local functions = {}
	for key, value in pairs(tbl) do
		if type(value) == "function" then
			functions[key] = value
		end
	end
	return functions
end
