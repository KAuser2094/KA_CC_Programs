-- Define a table to store the module functions
local git = {}

local function downloadFile(url, path)
	local response = http.get(url)
	if response then
		local file = fs.open(path, "w")
		file.write(response.readAll())
		file.close()
		response.close()
		print("Downloaded: " .. path)
	else
		print("Failed to download: " .. url)
	end
end

local function cloneRepoFolder(owner, repo, targetRootFolder, path)
	path = path or ""
	local currentFolderPath = fs.combine(targetRootFolder, path)
	local apiUrl = "https://api.github.com/repos/" .. owner .. "/" .. repo .. "/contents/" .. path
	local response = http.get(apiUrl)
	if response then
		local contents = textutils.unserialiseJSON(response.readAll())
		response.close()
		for _, content in ipairs(contents) do
			if content.type == "file" then
				local filePath = fs.combine(currentFolderPath, content.name)
				downloadFile(content.download_url, filePath)
			elseif content.type == "dir" then
				local newFolderPath = fs.combine(currentFolderPath, content.name)
				fs.makeDir(newFolderPath)
				print("Made new directory: " .. newFolderPath)
				cloneRepoFolder(owner, repo, targetRootFolder, path .. "/" .. content.name)
			else
				print(content.name .. " is a " .. content.type .. " type which was not expected")
			end
		end
		print("Folder cloned successfully: " .. owner .. "/" .. repo .. "/" .. path)
	else
		print("Failed to access repo:" .. owner .. "/" .. repo .. "/" .. path)
	end
end

local function cloneRepository(owner, repo, targetRootFolder)
	print("Cloning github repository: " .. owner .. "/" .. repo)
	targetRootFolder = targetRootFolder or repo
	if fs.exists(targetRootFolder) then
		fs.delete(targetRootFolder) -- Delete preexisting folder with the same name
		print("Deleted old copy of repo")
	end
	fs.makeDir(targetRootFolder)
	cloneRepoFolder(owner, repo, targetRootFolder)
end

function git.clone(...)
	local args = { ... }
	if #args == 2 then
		local owner, repo = args[1], args[2]
		cloneRepository(owner, repo)
	elseif #args == 3 then
		local owner, repo, target = args[1], args[2], args[3]
		cloneRepository(owner, repo, target)
	else
		print("Usage: git.clone <owner> <repo> (optional <targetFolder>)")
	end
end

local function main(...)
	local args = { ... }
	local command = args[1]
	table.remove(args, 1)
	local func = git[command]
	if not func then
		print("Invalid Command")
		return
	end
	func(args)
end

if pcall(debug.getlocal, 4, 1) then
	main(...)
else
	-- Used as module
	return git
end
