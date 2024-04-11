-- Define a table to store the module functions
local gitClone = {}

local function gitClone.downloadFile(url, path)
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

local function gitClone.cloneRepoFolder(owner, repo, path)
	path = path or ""
	local currentFolderPath = fs.combine(repo, path)
	local apiUrl = "https://api.github.com/repos/" .. owner .. "/" .. repo .. "/contents/" .. path
	local response = http.get(apiUrl)
	if response then
		local contents = textutils.unserialiseJSON(response.readAll())
		response.close()
		for _, content in ipairs(contents) do
			if content.type == "file" then
				local filePath = fs.combine(currentFolderPath, content.name)
				gitClone.downloadFile(content.download_url, filePath)
			elseif content.type == "dir" then
				local newFolderPath = fs.combine(currentFolderPath, content.name)
				fs.makeDir(newFolderPath)
				print("Made new directory: " .. newFolderPath)
				gitClone.cloneRepoFolder(owner, repo, content.name)
			else
				print(content.name .. " is a " .. content.type .. " type which was not expected")
			end
		end
		print("Folder cloned successfully: " .. owner .. "/" .. repo .. "/" .. path)
	else
		print("Failed to access repo:" .. owner .. "/" .. repo .. "/" .. path)
	end
end

local function gitClone.cloneRepository(owner, repo)
	print("Cloning github repository: " .. owner .. "/" .. repo)
	local folderName = repo
	if fs.exists(folderName) then
		fs.delete(folderName) -- Delete preexisting folder with the same name
		print("Deleted old copy of repo")
	end
	fs.makeDir(folderName)
	gitClone.cloneRepoFolder(owner, repo)
end

local function main(...)
	local args = { ... }
	if #args == 2 then
		local owner, repo = args[1], args[2]
		gitClone.cloneRepository(owner, repo)
	else
		print("Usage: lua git_clone.lua <owner> <repo>")
	end
end

if pcall(debug.getlocal, 4, 1) then
	main(...)
else
	-- Used as module
	return gitClone
end
