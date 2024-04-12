-- LZH Reactor allows you to make a reactor that is just fuel and LZH condensors to stop explosions.
-- It will constantly monitor the durability of the LZH condensors and fuel cells and control the reactor and machine buffers to manage it.
-- According to the settings, it will stop the reactor and replace the condensors when durabilties reach a certain threshold percent.
-- Machines:
-- Reactor (with 6 chambers)
-- 4 Machine Buffers (Near-Depleted Cells Out, Full Cells In, Near Broken LZH out, Full LZH in)
-- Run the LZH_Reactor_set_settings.lua file to change the settings of the reactor.
-- Run this file to start the program.

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
-- Table with setting info
local settings = tryRequire({
	"KA_CC_Programs/reactor/LZH_Reactor_settings", -- from home
	"reactor/LZH_Reactor_settings", -- from KA_CC_Programs
	"LZH_Reactor_settings", -- from here
})
-- Helper Function
local reactor = tryRequire({
	"KA_CC_Programs/reactor", -- from home
	"reactor", -- from KA_CC_Programs
  "../reactor" -- from here
	"init.lua", -- also from here but cursed
})

local commands = {}

local function commands.start()
  -- TODO
end

local function commands.settings()
  -- TODO
end

local function main(...)
	local args = { ... }
	if #args == 1 then
		local command = args[1]
    if commands[command] then
      commands[command]()
    else
      print("Invalid command: " .. command)
      print("Usage: LZH_Reactor <command>")
      print("Commands: `start`, `settings`")
    end
	else
		print("Usage: LZH_Reactor <command>")
    print("Commands: `start`, `settings`")
	end
end

if pcall(debug.getlocal, 4, 1) then
	main(...)
end