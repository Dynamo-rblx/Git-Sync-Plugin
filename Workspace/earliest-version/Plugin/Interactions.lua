-- @ScriptType: ModuleScript
local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")

--- BEGIN CODE ---

local Interactions = {}

local Functions = require(script.Parent.Functions)

local Settings = require(script.Parent.Settings)





function Interactions.pushToGitHub(repo, token, pushButton)
	local scripts = Functions.getSelectedScripts()
	local url = "https://api.github.com/repos/" .. repo .. "/contents/"

	if next(scripts) == nil and Settings.PushFrom.Current == 1 then
		warn("No scripts selected!")
		pushButton.ImageLabel.ImageColor3 = Color3.fromRGB(248, 81, 73)
		return
	end
	
	ChangeHistoryService:SetWaypoint("Before GitHub Push")
	
	for name, data in pairs(scripts) do
		local filePath = Functions.getScriptPath(data.Object)
		local fileUrl = url .. filePath


		local scriptWithMetadata = "-- @ScriptType: " .. data.Class .. "\n" .. data.Source

		-- Get SHA if the file exists
		local sha = Functions.getFileSHA(repo, token, filePath)

		local requestBody = {
			message = "Updated " .. filePath,
			content = Functions.to_base64(scriptWithMetadata),
			branch = Settings.Branch
		}

		-- Include SHA only if the file exists (GitHub requires this)
		if sha then
			requestBody.sha = sha
		end

		local headers = {
			["Authorization"] = "token " .. token,
			["Accept"] = "application/vnd.github.v3+json"
		}

		local success, response = pcall(function()
			return HttpService:RequestAsync({
				Url = fileUrl,
				Method = "PUT",
				Headers = headers,
				Body = HttpService:JSONEncode(requestBody)
			})
		end)

		if success then
			print("Pushed: " .. filePath)
			print("Response: ", response) -- Debugging response
			pushButton.ImageLabel.ImageColor3 = Color3.fromRGB(63, 185, 80)
		else
			warn("Failed to push: " .. filePath)
			warn(response)
			pushButton.ImageLabel.ImageColor3 = Color3.fromRGB(248, 81, 73)
		end
		
		ChangeHistoryService:SetWaypoint("After GitHub Push")
	end
end










function Interactions.pullFromGitHub(repo, token, pullButton)
	
	ChangeHistoryService:SetWaypoint("Before GitHub Pull")	
	
	local contents = Functions.getRepoContents(repo, token, "", pullButton)
	if contents then
		local rootFolder = Instance.new("Folder")
		local directory = string.split(repo, "/")
		rootFolder.Name = directory[2]
		rootFolder.Parent = workspace
		
		--print(repo)
		--print(contents)
		--print(token)
		--print(rootFolder.Name)
		
		Functions.createStructure(rootFolder, 
			contents, 
			repo, 
			token, pullButton)
	else
		return
	end
	
	ChangeHistoryService:SetWaypoint("After GitHub Pull")	
	return
	--local url = "https://api.github.com/repos/" .. repo .. "/contents/"

	--local selectedObjects = Selection:Get()
	--local scriptContainer = game:GetService("ServerScriptService") -- Default location

	---- If user has selected a parent, use it
	--if #selectedObjects > 0 then
	--	scriptContainer = selectedObjects[1] -- First selected object
	--end

	---- Fetch file list from GitHub
	--local success, response = pcall(function()
	--	return HttpService:GetAsync(url, true, {
	--		["Authorization"] = "token " .. token,
	--		["Accept"] = "application/vnd.github.v3+json"
	--	})
	--end)

	--if not success then
	--	warn("Failed to fetch file list from GitHub:", response)
	--	pullButton.ImageLabel.ImageColor3 = Color3.fromRGB(248, 81, 73)
	--	return
	--end

	--local files = HttpService:JSONDecode(response)
	
	--ChangeHistoryService:SetWaypoint("Before GitHub Pull")
	
	--for _, file in ipairs(files) do
	--	if file.name:match("%.lua$") then -- Only pull .lua files
	--		local fileName = file.name:gsub("%.lua$", "") -- Remove .lua extension
	--		local fileUrl = url .. file.name

	--		local scriptExists = false
	--		for _, obj in ipairs(selectedObjects) do
	--			if obj:IsA("Script") or obj:IsA("ModuleScript") or obj:IsA("LocalScript") then
	--				if obj.Name == fileName then
	--					scriptExists = true
	--					break
	--				end
	--			end
	--		end

	--		-- Fetch script content
	--		local fileSuccess, fileResponse = pcall(function()
	--			return HttpService:GetAsync(fileUrl, true, {
	--				["Authorization"] = "token " .. token,
	--				["Accept"] = "application/vnd.github.v3+json"
	--			})
	--		end)

	--		if fileSuccess then
	--			local fileData = HttpService:JSONDecode(fileResponse)
	--			if fileData and fileData.content then
	--				local scriptUrl = fileData.download_url
	--				local filePath = fileData.path
					
	--				local scriptContent = Functions.from_base64(fileData.content)
			
	--				-- Extract the first line
	--				local firstLine, remainingContent = scriptContent:match("^(.-)\n") or "", ""

	--				-- Get the script type from the comment
	--				local scriptType = firstLine:match("%-%- @ScriptType: (.+)")

	--				-- Default to ModuleScript if no type found
	--				if not scriptType then
	--					scriptType = "Script"
	--					remainingContent = scriptContent
	--				end
					
	--				-- Extract folder path and script name
	--				local folderPath, scriptName = filePath:match("^(.*)/([^/]+)%.lua$")
	--				local parentFolder = scriptContainer

	--				if folderPath then
	--					parentFolder = Functions.ensureFolderExists(folderPath, parentFolder)
	--				end
					
	--				if scriptExists then
	--					-- Update existing script
	--					for _, obj in ipairs(selectedObjects) do
	--						if obj:IsA("Script") or obj:IsA("ModuleScript") or obj:IsA("LocalScript") then
	--							if obj.Name == fileName then
	--								obj.Source = scriptContent
	--								print("Updated script:", fileName)
	--								break
	--							end
	--						end
	--					end
	--				else
	--					-- Create new script
	--					local newScript

	--					if scriptType == "Script" then
	--						newScript = Instance.new("Script")
	--					elseif scriptType == "LocalScript" then
	--						newScript = Instance.new("LocalScript")
	--					elseif scriptType == "ModuleScript" then
	--						newScript = Instance.new("ModuleScript")
	--					else
	--						warn("Unknown script type for " .. fileName .. ". Defaulting to Script.")
	--						newScript = Instance.new("Script")
	--					end

	--					newScript.Name = fileName
	--					newScript.Source = remainingContent
	--					newScript.Parent = parentFolder
	--					print("Created new script: " .. newScript.Name .. " (" .. scriptType .. ")")
						
	--				end
					
	--				pullButton.ImageLabel.ImageColor3 = Color3.fromRGB(63, 185, 80)
	--			else
	--				warn("Failed to decode content for:", fileName)
	--				pullButton.ImageLabel.ImageColor3 = Color3.fromRGB(248, 81, 73)
	--			end
	--		else
	--			warn("Failed to fetch:", fileName, fileResponse)
	--			pullButton.ImageLabel.ImageColor3 = Color3.fromRGB(248, 81, 73)
	--		end
	--	end
	--end
	
	--ChangeHistoryService:SetWaypoint("After GitHub Pull")	
end





function Interactions.deleteFile(owner, repo, filePath, sha, token)
	local HttpService = game:GetService("HttpService")
	local url = "https://api.github.com/repos/" .. owner .. "/" .. repo .. "/contents/" .. filePath

	local requestBody = HttpService:JSONEncode({
		message = "Deleted " .. filePath,
		sha = sha, -- The SHA of the file
		branch = Settings.Branch
	})

	local headers = {
		["Authorization"] = "token " .. token,
		["Accept"] = "application/vnd.github.v3+json"
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "DELETE",
			Headers = headers,
			Body = requestBody
		})
	end)

	if success then
		print("Successfully deleted " .. filePath)
		return true
	else
		warn("Failed to delete file: " .. response)
		return nil
	end
end





function Interactions.listBranches(repo, token)
	local url = "https://api.github.com/repos/".. repo .. "/branches"
	local headers = { ["Authorization"] = "token " .. token }

	local success, response = pcall(function()
		return game:GetService("HttpService"):GetAsync(url, true, headers)
	end)

	if success then
		local branches = game:GetService("HttpService"):JSONDecode(response)
		for _, branch in ipairs(branches) do
			print("Branch: " .. branch.name)
		end
		return branches
	else
		warn("Failed to list branches: " .. response)
		return nil
	end
end





function Interactions.getLatestCommitSHA(repo, branch, token)
	local HttpService = game:GetService("HttpService")
	local url = "https://api.github.com/repos/" .. repo .. "/branches/" .. branch

	local success, response = pcall(function()
		return HttpService:GetAsync(url, true, {
			["Authorization"] = "token " .. token,
			["Accept"] = "application/vnd.github.v3+json"
		})
	end)

	if success then
		local data = HttpService:JSONDecode(response)
		if data and data.commit and data.commit.sha then
			return data.commit.sha
		end
	else
		warn("Failed to get latest commit SHA:", response)
		return nil
	end
end





function Interactions.createBranch(repo, branchName, baseSha, token)
	local HttpService = game:GetService("HttpService")
	local url = "https://api.github.com/repos/".. repo .. "/git/refs"

	local requestBody = HttpService:JSONEncode({
		ref = "refs/heads/" .. branchName,
		sha = baseSha
	})

	local headers = {
		["Authorization"] = "token " .. token,
		["Accept"] = "application/vnd.github.v3+json"
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "POST",
			Headers = headers,
			Body = requestBody
		})
	end)

	if success then
		print("Successfully created branch: " .. branchName)
		return true
	else
		warn("Failed to create branch: " .. response)
		return nil
	end
end

return Interactions
