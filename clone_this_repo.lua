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

local function cloneRepository(owner, repo)
	-- Fetch repository contents
	local apiUrl = "https://api.github.com/repos/" .. owner .. "/" .. repo .. "/contents/"
	local response = http.get(apiUrl)
	if response then
		-- Create a folder with the repository name
		local folderName = repo
		if fs.exists(folderName) then
			fs.delete(folderName) -- Delete preexisting folder with the same name
			print("Deleted old copy of repo")
		end
		fs.makeDir(folderName)
		-- Actually download the git repo
		local contents = textutils.unserializeJSON(response.readAll())
		for _, content in ipairs(contents) do
			if content.type == "file" then
				-- Create directories if necessary
				-- Download files into the repository folder
				downloadFile(content.download_url, content.name)
			end
		end
		response.close()
		print("Repository cloned successfully: " .. owner .. "/" .. repo)
	else
		print("Failed to access repository: " .. owner .. "/" .. repo)
	end
end

cloneRepository("KAuser2094", "KA_CC_Programs")
