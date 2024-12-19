-- FROM MY OLD REPO, SHOULD BE REDONE LATER

local http = _G.http
local fs = _G.fs
local textutils = _G.textutils


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

local function cloneRepoFolder(gitRedoCloneTree, owner, repo, targetRootFolder, path)
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
				-- Here so you can redo this clone without calling api again (so if file structure hasn't changed).
				table.insert(gitRedoCloneTree, {
					content = content,
					filePath = filePath,
				})
				--
			elseif content.type == "dir" then
				local newFolderPath = fs.combine(currentFolderPath, content.name)
				fs.makeDir(newFolderPath)
				print("Made new directory: " .. newFolderPath)
				cloneRepoFolder(gitRedoCloneTree, owner, repo, targetRootFolder, path .. "/" .. content.name)
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
	local gitRedoCloneTree = {}
	cloneRepoFolder(gitRedoCloneTree, owner, repo, targetRootFolder)
	local filePath = fs.combine(targetRootFolder .. "/_git", "redoCloneTree.lua")
	local file = fs.open(filePath, "w")
	file.write("return " .. textutils.serialise(gitRedoCloneTree))
	file.close()
end

local function getCommitHashFromAPI(owner, repo)
	local apiUrl = "https://api.github.com/repos/" .. owner .. "/" .. repo .. "/commits/master"
	local response = http.get(apiUrl)
	if response then
		local data = response.readAll()
		response.close()
		local commitInfo = textutils.unserialiseJSON(data)
		if commitInfo and commitInfo.sha then
			return commitInfo.sha
		end
	end
	return nil
end

local function saveCommitHash(owner, repo, targetRootFolder)
	local commitHash = getCommitHashFromAPI(owner, repo)
	if commitHash then
		local filePath = fs.combine(targetRootFolder .. "/_git", "hash.lua")
		local file = fs.open(filePath, "w")
		file.write('return "' .. commitHash .. '"')
		file.close()
	end
end

local function loadSavedCommitHash(targetRootFolder)
	local filePath = targetRootFolder .. "/_git/hash"
	if fs.exists(filePath .. ".lua") then
		local success, value = pcall(require, filePath)
		if not success then
			return nil
		end
		return value
	end
	return nil
end

local function loadSavedRedoCloneTree(targetRootFolder)
	local filePath = targetRootFolder .. "/_git/redoCloneTree"
	print("Looking at " .. filePath)
	if fs.exists(filePath .. ".lua") then
		local success, value = pcall(require, filePath)
		if not success then
			print("Failed require")
			return nil
		end
		return value
	end
	print("Failed exists")
	return nil
end

local git_usage_text = {
	help = "git.lua help (optional <command>)",
	clone = "git.lua clone <owner> <repo> (optional <targetFolder>)",
	reclone = "git.lua reclone <folder_of_repo>, NOTE: must have used `clone` which saves `_git/redoCloneTree.lua`",
}

function git.reclone(...)
	local args = { ... }
	if #args == 1 then
		local repoFolder = args[1]
		local redoTree = loadSavedRedoCloneTree(repoFolder)
		if not redoTree then
			print("Could not find: " .. repoFolder .. "/_git/redoCloneTree.lua")
			print("Aborting...")
			return
		end
		if fs.exists(repoFolder .. "/_git/hash.lua") then
			fs.delete(repoFolder .. "/_git/hash.lua")
			print("Deleted saved hash as it may be out of date")
		end

		for _, file in ipairs(redoTree) do
			if fs.exists(file.filePath) then
				fs.delete(file.filePath)
			end
			downloadFile(file.content.download_url, file.filePath)
		end
		print("Done re-downloading all files cloned from previous clone")
	else
		print("Usage: " .. git_usage_text["reclone"])
	end
end

function git.clone(...)
	local args = { ... }
	if #args == 2 or #args == 3 then
		local owner, repo = args[1], args[2]
		local target = args[3] or repo
		local savedHash = loadSavedCommitHash(target)
		local currentHash = getCommitHashFromAPI(owner, repo)
		if savedHash and savedHash == currentHash then
			print("Repository already up to date. Aborting clone.")
			return
		end
		cloneRepository(owner, repo, target)
		saveCommitHash(owner, repo, target)
	else
		print("Usage: " .. git_usage_text["clone"])
	end
end

function git.help(...)
	local args = { ... }
	if #args == 0 then
		print("KA's git.lua usage:")
		print("---")
		print("Help: " .. git_usage_text["help"])
		print("---")
		print("Clone: " .. git_usage_text["clone"])
		print("---")
		return
	end
	local command = args[1]
	if not git[command] then
		return
	end
	print(command .. " usage:")
	print(git_usage_text[command])
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
	func(unpack(args))
end

if pcall(debug.getlocal, 4, 1) then
	main(...)
else
	-- Used as module
	return git
end