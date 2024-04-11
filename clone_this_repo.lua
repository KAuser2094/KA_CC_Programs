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

local function cloneRepoFolder(owner, repo, path)
	path = path or ""
	local currentFolderPath = fs.combine(repo, path)
	local apiUrl = "https://api.github.com/repos/" .. owner .. "/" .. repo .. "/contents/" .. path
	local response = http.get(apiUrl)
	if response then
		local contents = textutils.unserializeJSON(response.readAll())
		response.close()
		for _, content in ipairs(contents) do
			if content.type == "file" then
				local filePath = fs.combine(currentFolderPath, content.name)
				downloadFile(content.download_url, filePath)
			elseif content.type == "dir" then
				local newFolderPath = fs.combine(currentFolderPath, content.name)
				fs.makeDir(newFolderPath)
				print("Made new directory: " .. newFolderPath)
				cloneRepoFolder(owner, repo, content.name)
			else
				print(content.name .. " is a " .. content.type .. " type which was not expected")
			end
		end
		print("Folder cloned successfully: " .. owner .. "/" .. repo .. "/" .. path)
	else
		print("Failed to access repo:" .. owner .. "/" .. repo .. "/" .. path)
	end
end

local function cloneRepository(owner, repo)
	print("Cloning github repository: " .. owner .. "/" .. repo)
	local folderName = repo
	if fs.exists(folderName) then
		fs.delete(folderName) -- Delete preexisting folder with the same name
		print("Deleted old copy of repo")
	end
	fs.makeDir(folderName)
	cloneRepoFolder(owner, repo)
end

cloneRepository("KAuser2094", "KA_CC_Programs")

-- You can also run :
-- pastebin run UMDCamCR`
-- which will just call:
-- shell.run("wget run https://raw.githubusercontent.com/KAuser2094/KA_CC_Programs/master/clone_this_repo.lua")
-- or you know...run the wget command directly.
