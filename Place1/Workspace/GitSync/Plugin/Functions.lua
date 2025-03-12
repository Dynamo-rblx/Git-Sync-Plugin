-- @ScriptType: ModuleScript
local HttpService = game:GetService("HttpService")
local Selection = game:GetService("Selection")
local Settings = require(script.Parent.Settings)

local selectedScripts = {}
local entries = 0

--- BEGIN CODE ---

local Functions = {}



function Functions.confirm(pluginVar, attempt:string): boolean
	local plugin = pluginVar
	
	local widgetInfo = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float, true, false, 300, 200, 353,194
	)
	local confirm_widget = plugin:CreateDockWidgetPluginGui("GitHubSyncConfirmer", widgetInfo)
	confirm_widget.Title = "Git Confirm - "..attempt.." - "..Settings.Branch
	local confirm_frame = script.Parent.ConfirmWindow:Clone()
	confirm_frame.Parent = confirm_widget
	confirm_frame.Size = UDim2.fromScale(1,1)
	
	local confirmed = -1 -- No input
	
	local function setTrue()
		confirmed = 1 -- true
	end
	
	local function setFalse()
		confirmed = 0 -- false
	end
	
	local c, d = confirm_frame.Confirm.MouseButton1Click:Connect(setTrue), confirm_frame.Cancel.MouseButton1Click:Connect(setFalse)
	confirm_frame.Warning.Text = "Are you sure you want to "..attempt.."?"
	
	repeat task.wait() until confirmed == 1 or confirmed == 0
	c:Disconnect()
	d:Disconnect()
	
	if confirmed == 0 then
		confirm_frame.Warning.Text = "Attempt to "..attempt.." cancelled."
		confirm_frame.Warning.TextColor3 = Color3.fromRGB(248, 81, 73)
	else
		confirm_frame.Warning.Text = "Attempt to "..attempt.." confirmed."
		confirm_frame.Warning.TextColor3 = Color3.fromRGB(63, 185, 80)
	end
	
	task.wait(.6)
	
	confirm_widget:Destroy()
	
	if confirmed == 0 then
		return false
	else
		return true
	end
	
end





function Functions.getScriptPath(scriptFile)
	local path = scriptFile.Name .. ".lua"
	local parent = scriptFile.Parent
	while parent and #parent:GetChildren() > 0 do
		task.wait()
		path = parent.Name .. "/" .. path
		parent = parent.Parent
	end
	return path
end





function Functions.getRepoContents(repo, token, path, pullButton)
	local url = "https://api.github.com/repos/" .. repo .. "/contents/" .. (path or "") .."?ref="..Settings.Branch
	local headers = {
		["Authorization"] = "token " .. token,
		["Accept"] = "application/vnd.github.v3+json"
	}
	
	--print("ppullinh")
	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "GET",
			Headers = headers
		})
	end)
	
	--print(success)
	--print(response.Body)
	--print(HttpService:JSONDecode(response.Body))
	
	if success then
		--print("returnign")
		return HttpService:JSONDecode(response.Body)
	else
		warn("Failed to fetch repository contents.")
		pullButton.ImageLabel.ImageColor3 = Color3.fromRGB(248, 81, 73)
		return nil
	end
end





function Functions.createEntry(name, parentFrame:Frame, isFolder, entered)
	local entry = script.templatefileindicator:Clone()

	entry.template.Text = name
	entry.Name = name
	entry.LayoutOrder = entries

	if isFolder then
		entry.template.Text = "<b>"..entry.template.Text.."</b>"
		entry.template.TextColor3 = Color3.fromRGB(88, 166, 255)
	end

	entry.LayoutOrder = entries

	entry.MouseButton1Click:Connect(function()

	end)

	entry.Visible = true
	entry.Parent = parentFrame

	entry.ZIndex = parentFrame.ZIndex + 1

	entries += 2
	return entry
end





function Functions.getProperties(instance)
	local properties = {}
	local success, propertiesList = pcall(function()
		return instance:GetAttributes()
	end)

	if success then
		for name, value in pairs(propertiesList) do
			properties[name] = value
		end
	end
	
	local success2, classInfo = pcall(function()
		return Instance.new(instance.ClassName)
	end)

	if success2 then
		for _, property in ipairs(classInfo:GetProperties()) do
			local propName = property.Name
			local success3, propValue = pcall(function()
				return instance[propName]
			end)
			if success3 then
				properties[propName] = propValue
			end
		end
	end

	return properties
end








function Functions.populateExplorer(repo, token, parentFrame: Frame, path, plugin)
	local contents = Functions.getRepoContents(repo, token, path)

	if not contents then return end

	for _, item in ipairs(contents) do
		local isFolder = (item.type == "dir")
		local entry = Functions.createEntry(item.name, parentFrame, isFolder)

		if isFolder then
			entry.MouseButton1Click:Connect(function()
				local widgetInfo = DockWidgetPluginGuiInfo.new(
					Enum.InitialDockState.Float, false, false, 300, 200, 300, 200
				)
				local explorer_widget = plugin:CreateDockWidgetPluginGui("GitHubSyncExplorer - "..item.name..tostring(Random.new():NextNumber(-100000*10.29432, 999999*10.29432)), widgetInfo)
				explorer_widget.Title = "Git Explorer - "..item.name
				local explorer_frame = script.Parent.ExplorerWindow:Clone()
				explorer_frame.Parent = explorer_widget
				explorer_frame.Size = UDim2.fromScale(1,1)
				explorer_frame.Visible = true
				explorer_widget.Enabled = true
				-- Recursive
				Functions.populateExplorer(repo, token, explorer_frame.ScrollingFrame, item.path, plugin)

			end)

		else

			entry.MouseButton1Click:Connect(function()		
				local widgetInfo = DockWidgetPluginGuiInfo.new(
					Enum.InitialDockState.Right, false, false, 300, 200, 300, 200
				)
				local explorer_widget = plugin:CreateDockWidgetPluginGui("GitHubSyncExplorer - "..item.name..tostring(Random.new():NextNumber(-100000*10.29432, 999999*10.29432)), widgetInfo)
				explorer_widget.Title = "Git File Viewer - "..item.name
				local explorer_frame = script.Parent.ExplorerWindow:Clone()
				explorer_frame.Parent = explorer_widget
				explorer_frame.Size = UDim2.fromScale(1,1)
				explorer_frame.ScrollingFrame.BackgroundTransparency = 1
				local text = Instance.new("TextBox")
				text.ClearTextOnFocus = false
				text.Size = UDim2.fromScale(1,1)
				text.Position = UDim2.fromScale(0,0)
				text.RichText = true
				text.BackgroundTransparency = 0
				text.Text = Functions.from_base64(HttpService:JSONDecode((HttpService:GetAsync(item.url, true, {["Authorization"] = "token " .. token,["Accept"] = "application/vnd.github.v3+json"
				}))).content)
				text.Parent = explorer_frame.ScrollingFrame
				text.TextColor3 = Color3.fromRGB(255,255, 255)
				text.TextScaled = true
				text.TextWrapped = true
				local padding = Instance.new("UIPadding", text)
				padding.PaddingRight = UDim.new(0.05,0)
				padding.PaddingLeft = UDim.new(0.05,0)
				padding.PaddingTop = UDim.new(0.05,0)
				padding.PaddingBottom = UDim.new(0.05,0)

				explorer_frame.Visible = true
				explorer_widget.Enabled = true
				-- Recursive
				Functions.populateExplorer(repo, token, explorer_frame.ScrollingFrame, item.path, plugin)
			end)
		end
	end
end





function Functions.createStructure(parent, contents, repo, token, pullButton)
	for _, item in pairs(contents) do
		if item.type == "dir" then
			print("dir")
			local folder = Instance.new("Folder")
			folder.Name = item.name
			folder.Parent = parent

			local subContents = Functions.getRepoContents(repo, token, item.path)
			if subContents then

				Functions.createStructure(folder, subContents, repo, token, pullButton)
			end

		elseif item.type == "file" and item.name:match("%.lua$") then

			local fileData = Functions.getRepoContents(repo, token, item.path)
			if fileData and fileData.content then
				local sourceCode = Functions.from_base64(fileData.content)

				local firstLine = sourceCode:match("^(.-)\n")
				local scriptType = firstLine:match("%-%- @ScriptType: (.+)") or "Script"

				local scriptInstance = Instance.new(scriptType)
				scriptInstance.Name = item.name:gsub("%.lua$", "")
				scriptInstance.Source = sourceCode
				scriptInstance.Parent = parent
				
				print("Created new script: " .. scriptInstance.Name .. " (" .. scriptType .. ")")
				pullButton.ImageLabel.ImageColor3 = Color3.fromRGB(63, 185, 80)
			end
		end
	end
	return
end




	function Functions.getFileSHA(repo, token, filePath)
		local HttpService = game:GetService("HttpService")
		local url = "https://api.github.com/repos/" .. repo .. "/contents/" .. filePath

		local headers = {
			["Authorization"] = "token " .. token,
			["Accept"] = "application/vnd.github.v3+json"
		}

		local success, response = pcall(function()
			return HttpService:GetAsync(url, true, headers)
		end)

		if success then
			local data = HttpService:JSONDecode(response)
			return data.sha -- Update
		else
			return nil -- Make new file
		end
	end





	function Functions.createFolder(repo, folderPath, token)
		local url = "https://api.github.com/repos/" .. repo .. "/contents/" .. folderPath .. "/.gitkeep"

		local requestBody = HttpService:JSONEncode({
			message = "Created folder: " .. folderPath,
			content = Functions.to_base64("Placeholder file to keep folder"),
			branch = Settings.Branch
		})

		local headers = {
			["Authorization"] = "token " .. token,
			["Accept"] = "application/vnd.github.v3+json"
		}

		local success, response = pcall(function()
			return HttpService:RequestAsync({
				Url = url,
				Method = "PUT",
				Headers = headers,
				Body = requestBody
			})
		end)

		if success then
			print("Successfully created folder: " .. folderPath)
		else
			warn("Failed to create folder: " .. response)
		end
	end




	function Functions.ensureFolderExists(path, parent)
		local folderNames = string.split(path, "/")
		for _, folderName in ipairs(folderNames) do
			local existingFolder = parent:FindFirstChild(folderName)
			if not existingFolder then
				existingFolder = Instance.new("Folder")
				existingFolder.Name = folderName
				existingFolder.Parent = parent
			end
			parent = existingFolder
		end
		print("Created folder path: " .. path)
		return parent
	end




	local scriptsSeen = {}
	function Functions.scanFolder(folder, path)
		for _, obj in ipairs(folder:GetChildren()) do
			if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
				scriptsSeen[obj.Name] = {["Source"] = obj.Source, ["Class"] = obj.ClassName, ["Object"] = obj}

			end

			if #obj:GetChildren() > 0 then
				Functions.scanFolder(obj, path .. obj.Name .. "/") -- Recursive
			end
		end

		return true
	end





	function Functions.getSelectedScripts()
		local selected = Selection:Get()
		scriptsSeen = {}

		for _, obj in ipairs(selected) do
			if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
				scriptsSeen[obj.Name] = {["Source"] = obj.Source, ["Class"] = obj.ClassName, ["Object"] = obj}

			end

			if #obj:GetChildren() > 0 then

				Functions.scanFolder(obj, obj.Name .. "/")
			end
		end

		return scriptsSeen
	end





function Functions.to_base64(data) -- (XDeltaXen) - https://devforum.roblox.com/t/base64-encoding-and-decoding-in-lua/1719860
		local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
		return ((data:gsub('.', function(x) 
			local r,b='',x:byte()
			for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
			return r;
		end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
			if (#x < 6) then return '' end
			local c=0
			for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
			return b:sub(c+1,c+1)
		end)..({ '', '==', '=' })[#data%3+1])
	end





function Functions.from_base64(data) -- (XDeltaXen) - https://devforum.roblox.com/t/base64-encoding-and-decoding-in-lua/1719860
		local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
		data = string.gsub(data, '[^'..b..'=]', '')
		return (data:gsub('.', function(x)
			if (x == '=') then return '' end
			local r,f='',(b:find(x)-1)
			for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
			return r;
		end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
			if (#x ~= 8) then return '' end
			local c=0
			for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
			return string.char(c)
		end))
	end

	return Functions
