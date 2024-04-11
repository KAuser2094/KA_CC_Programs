local http = require("http")

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
	local apiUrl = "https://api.github.com/repos/" .. owner .. "/" .. repo .. "/contents/"
	local response = http.get(apiUrl)
	if response then
		local contents = textutils.unserializeJSON(response.readAll())
		for _, content in ipairs(contents) do
			if content.type == "file" then
				downloadFile(content.download_url, content.name)
			end
		end
		response.close()
	else
		print("Failed to access repository: " .. owner .. "/" .. repo)
	end
end
