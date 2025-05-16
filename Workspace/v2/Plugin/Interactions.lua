-- @ScriptType: ModuleScript

---------------------------------------------------
-- GLOBALS
local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")
local ChangeHistoryService = game:GetService("ChangeHistoryService")
local Functions = require(script.Parent.Functions)
local Interactions = {}
---------------------------------------------------

-- INITIALIZATION
local plugin

function Interactions.Init(pluginVar)
	plugin = pluginVar
end
---------------------------------------------------

-- FUNCTION DECLARATIONS

----> Push selected scripts to specified repository & branch
function Interactions.pushToGitHub(pushButton)
	local scripts = Functions.getSelectedScripts()
	local url = "https://api.github.com/repos/" .. plugin:GetSetting("REPOSITORY") .. "/contents/"

	if next(scripts) == nil then
		warn("No scripts selected!")
		pushButton.ImageLabel.ImageColor3 = Color3.fromRGB(248, 81, 73)
		return
	end

	ChangeHistoryService:SetWaypoint("Before GitHub Push")

	for name, data in pairs(scripts) do
		local filePath = Functions.getScriptPath(data.Object)
		local fileUrl = url .. filePath
		local scriptWithMetadata = "-- @ScriptType: " .. data.Class .. "\n" .. data.Source
		
		local requestBody = {
			message = "Updated " .. filePath,
			content = Functions.to_base64(scriptWithMetadata),
			branch = plugin:GetSetting("BRANCH"),
			sha = Functions.getFileSHA(filePath) or Interactions.getLatestCommitSHA()
		}

		local headers = {
			["Authorization"] = "token " .. plugin:GetSetting("TOKEN"),
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

		if response.Success then
			if plugin:GetSetting("OUTPUT_ENABLED") then
				print("Pushed: ", filePath)
			end
			pushButton.ImageLabel.ImageColor3 = Color3.fromRGB(63, 185, 80)
		else
			warn("Failed to push: ", filePath)
			warn("Response: ", response.Body)
			pushButton.ImageLabel.ImageColor3 = Color3.fromRGB(248, 81, 73)
		end

		ChangeHistoryService:SetWaypoint("After GitHub Push")
	end
end

----> Pull entire repository from GitHub and import it to Studio
function Interactions.pullFromGitHub(pullButton)

	ChangeHistoryService:SetWaypoint("Before GitHub Pull")	

	local contents = Functions.getRepoContents("", pullButton)
	if contents then
		--local rootFolder = Instance.new("Folder")
		--local directory = string.split(plugin:GetSetting("REPOSITORY"), "/")
		--rootFolder.Name = directory[2]
		--rootFolder.Parent = workspace

		Functions.createStructure(workspace, contents, pullButton)
	else
		return
	end

	ChangeHistoryService:SetWaypoint("After GitHub Pull")	
	return
end

----> Delete file
function Interactions.deleteFile(filePath, sha)
	local HttpService = game:GetService("HttpService")
	local url = "https://api.github.com/repos/".. plugin:GetSetting("REPOSITORY") .. "/contents/" .. filePath

	local requestBody = HttpService:JSONEncode({
		message = "Deleted " .. filePath,
		sha = sha,
		branch = plugin:GetSetting("BRANCH")
	})

	local headers = {
		["Authorization"] = "token " .. plugin:GetSetting("TOKEN"),
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

	if response.Success then
		if plugin:GetSetting("OUTPUT_ENABLED") then
			print("Successfully deleted " .. filePath)
		end
		return true
	else
		warn("Failed to delete file: " .. response.Body)
		return nil
	end
end

----> Retrieves and returns a list of branches in the repository
function Interactions.listBranches()
	local url = "https://api.github.com/repos/".. plugin:GetSetting("REPOSITORY") .. "/branches"
	local headers = { ["Authorization"] = "token " .. plugin:GetSetting("TOKEN") }

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "GET",
			Headers = headers
		})
	end)

	if response.Success then
		local branches = game:GetService("HttpService"):JSONDecode(response.Body)
		if plugin:GetSetting("OUTPUT_ENABLED") then print(branches) end
		return branches
	else
		warn("Failed to list branches: " .. response.Body)
		return nil
	end
end

----> Get information (sha) about the latest commit on the specified branch
function Interactions.getLatestCommitSHA()
	local HttpService = game:GetService("HttpService")
	local url = "https://api.github.com/repos/" .. plugin:GetSetting("REPOSITORY") .. "/branches/" .. plugin:GetSetting("BRANCH")

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "GET",
			Headers = {
				["Authorization"] = "token " .. plugin:GetSetting("TOKEN"),
				["Accept"] = "application/vnd.github.v3+json"
			}
		})
	end)

	assert(success, "Failed to get latest commit SHA:"..response.Body)
	local data = HttpService:JSONDecode(response.Body)
	if data then return data.sha end
end

----> Create a new branch based on the specified commit
function Interactions.createBranch(branchName, baseSha)
	local HttpService = game:GetService("HttpService")
	local url = "https://api.github.com/repos/".. plugin:GetSetting("REPOSITORY") .. "/git/refs"

	local requestBody = HttpService:JSONEncode({
		ref = "refs/heads/" .. branchName,
		sha = baseSha
	})

	local headers = {
		["Authorization"] = "token " .. plugin:GetSetting("TOKEN"),
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

	if response.Success then
		if plugin:GetSetting("OUTPUT_ENABLED") then
			print("Successfully created branch: " .. branchName)
		end
		return true
	else
		warn("Failed to create branch: " .. response.Body)
		return nil
	end
end

return Interactions
