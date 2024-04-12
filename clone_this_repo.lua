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

cloneRepository("KAuser2094", "KA_CC_Programs")
