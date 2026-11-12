-- @ScriptType: ModuleScript
-- @ScriptType: ModuleScript
---------------------------------------------------
-- GLOBALS

const ScriptEditorService = game:GetService("ScriptEditorService")
const ReflectionService = game:GetService("ReflectionService")
const EncodingService = game:GetService("EncodingService")
const HttpService = game:GetService("HttpService")
const TestService = game:GetService("TestService")
const Selection = game:GetService("Selection")
const CoreGui = game:GetService("CoreGui")

--const customProperties = require("./RbxDom/customProperties")
--const RbxDom = require("./RbxDom")
const Gitsync = require("./Data")

local selectedScripts, Functions, scriptsSeen, entries = {}, {}, {}, 0

---------------------------------------------------
-- INITIALIZATION
local plugin: Plugin

function Functions.Init(pluginVar)
	plugin = pluginVar
end

---------------------------------------------------
-- FUNCTION DECLARATIONS
--> Act 1 of Initialize the freaking SHA or die trying. >:(
function Functions.initPlaceholder()
	local body = {
		message = "Initialize repository w/ placeholder",
		content = "Initialized by GitSync Plugin\n",
		branch = plugin:GetSetting(Gitsync.Settings.BRANCH) or "main"
	}

	local headers = {
		["Authorization"] = "token " .. plugin:GetSetting(Gitsync.Settings.TOKEN),
		["Accept"] = "application/vnd.github.v3+json"
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = "/contents/"..HttpService:UrlEncode("README.md"),
			Method = "PUT",
			Headers = headers,
			Body = HttpService:JSONEncode(body)
		})
	end)

	if not success then return false end

	if response.StatusCode == 200 or response.StatusCode == 201 then return response end
	return false
end

--> Act 2 of Initialize the freaking SHA or die trying. >:(

--> Final Act of Initialize the freaking SHA or die trying. >:(
function Functions.initializeSHA()
	local url = "/git/refs/heads/"..(plugin:GetSetting(Gitsync.Settings.BRANCH) or "main")
	local headers = {
		["Authorization"] = "token " .. plugin:GetSetting(Gitsync.Settings.TOKEN),
		["Accept"] = "application/vnd.github.v3+json"
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "GET",
			Headers = headers
		})
	end)

	if success and response.StatusCode == 200 then
		return HttpService:JSONDecode(response.Body).object.sha
	end

	local take2 = Functions.initPlaceholder()
	if take2 then
		Functions.getFileSHA()

		local success, response = pcall(function()
			return HttpService:RequestAsync({
				Url = url,
				Method = "GET",
				Headers = headers
			})
		end)

		if success and response.StatusCode == 200 then
			return HttpService:JSONDecode(response.Body).object.sha
		end


	end
end

----> Disconnect connections
function Functions.Disconnect(target: any) : nil
	for tag, cxn: RBXScriptConnection in Gitsync.Connections do
		if tostring(tag) ~= tostring(target) then return end
		cxn:Disconnect()
		Gitsync.Connections[tag] = nil
	end
end

----> Clip metadata (@ScriptType: ..., @RunContext: ...) from script source
function Functions.clipMetadata(source: string | Script | ModuleScript | LocalScript) : string
	if type(source) ~= "string" then source = ScriptEditorService:GetEditorSource(source) end

	local lines = source:split("\n")
	local newSource = ""
	local nextLine = true

	for i, line in pairs(lines) do
		if not (line:match("%-%- @ScriptType: (.+)") or line:match("%-%- @RunContext: (%d+)")) and nextLine then
			newSource = newSource.."\n"..line
		elseif not nextLine then
			if not line:match("%-%- @RunContext: (%d+)") then
				newSource = newSource.."\n"..line
				nextLine = true
			end
		else
			nextLine = false
		end
	end

	return newSource
end

----> Confirmation pop-up
function Functions.confirm(attempt: string): boolean
	local widgetInfo = DockWidgetPluginGuiInfo.new(
		Enum.InitialDockState.Float, true, false, 300, 200, 353,194
	)
	local confirm_widget = plugin:CreateDockWidgetPluginGuiAsync("GitHubSyncConfirmer", widgetInfo)
	confirm_widget.Title = "Git Confirm - "..attempt.." - "..plugin:GetSetting(Gitsync.Settings.BRANCH)
	local confirm_frame = script.Parent.ConfirmWindow:Clone()
	confirm_frame.Parent = confirm_widget
	confirm_frame.Size = UDim2.fromScale(1,1)

	confirm_frame.Warning.Text = "Are you sure you want to "..attempt.."?"
	local c,d,e : RBXScriptSignal
	local result

	local function cleanup()
		if c then c:Disconnect() end   
		if d then d:Disconnect() end
		if e then e:Disconnect() end   

		task.delay(.6, function()
			confirm_widget:Destroy()
		end)
	end

	c = confirm_frame.Confirm.MouseButton1Click:Connect(function()
		confirm_frame.Warning.Text = "Attempt to "..attempt.." confirmed."
		confirm_frame.Warning.TextColor3 = Gitsync.Colors.Green
		cleanup()
		result = true
	end)
	d = confirm_frame.Cancel.MouseButton1Click:Connect(function()
		confirm_frame.Warning.Text = "Attempt to "..attempt.." cancelled."
		confirm_frame.Warning.TextColor3 = Gitsync.Colors.Red
		cleanup()
		result = false
	end)	
	e = confirm_widget:BindToClose(function()
		cleanup()
		result = false
	end)

	repeat task.wait() until result or result == false
	return result
end

---> Clean the string up for pushing
--function Functions.cleanupString(str: string)
-- like http encode but for this
--end

----> Get absolute path of object using slashes instead of periods
function Functions.getFullNameFormatted(object: Instance) --> Modified from Roblox docs
	local result = object.Name
	object = object.Parent
	while object and object ~= game do
		result = object.Name .. "/" .. result
		object = object.Parent
	end
	return result
end

----> Get path of script instance (up to Services)
function Functions.getScriptPath(scriptFile: BaseScript)	
	return Functions.getFullNameFormatted(scriptFile) .. ".lua"
end

----> Return the contents of a repository
function Functions.getRepoContents(path: string, pullButton: GuiButton)
	local url = "https://api.github.com/repos/" .. plugin:GetSetting(Gitsync.Settings.REPOSITORY) .. "/contents/" .. (path or "") .."?ref="..plugin:GetSetting(Gitsync.Settings.BRANCH)
	local headers = {
		["Authorization"] = "token " .. plugin:GetSetting(Gitsync.Settings.TOKEN),
		["Accept"] = "application/vnd.github.v3+json"
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "GET",
			Headers = headers
		})
	end)

	if success and response.Success then
		return HttpService:JSONDecode(response.Body)
	else
		warn("Failed to fetch repository contents.")
		--print(pullButton)
		if pullButton then pullButton.ImageLabel.ImageColor3 = Gitsync.Colors.Red end
		return nil
	end
end

----> Create & return a rectangular button in repository viewer
function Functions.createEntry(name: string, parentFrame: Frame, isFolder: boolean) : TextLabel
	local entry = script.templatefileindicator:Clone()

	entry.template.Text = name
	entry.Name = name

	if isFolder then
		entry.template.Text = "<b>"..name.."</b>"
		entry.template.TextColor3 = Gitsync.Colors.Blue
	end

	entry.LayoutOrder = entries
	entry.Visible = true
	entry.Parent = parentFrame
	entry.ZIndex = parentFrame.ZIndex + 1
	entries += 1

	return entry
end

----> A helper handle creating a script
local function createScript(sourceCode: string | {string}, item: any, parent: Instance): (BaseScript,string)
	local firstLine, secondLine
	if type(sourceCode) == "string" then
		firstLine = sourceCode:match("^(.-)\n")
		secondLine = sourceCode:gsub("^(.-)\n","",1):match("^(.-)\n")
	else
		firstLine = sourceCode[1]:match("^(.-)\n")
		secondLine = sourceCode[1]:gsub("^(.-)\n","",1):match("^(.-)\n")
	end

	local scriptType, RunContext
	--A first line may not have \n or exist at all, same for the second
	if firstLine ~= nil then
		scriptType = firstLine:match("%-%- @ScriptType: (.+)") or "Script"
	else
		scriptType = "Script"
	end
	if secondLine ~= nil then
		RunContext = tonumber(secondLine:match("%-%- @RunContext: (%d+)"))
	end
	local scriptInstance = Instance.new(scriptType)

	scriptInstance.Name = item.name:gsub("%.lua$", "")
	scriptInstance.Name = scriptInstance.Name:gsub("%.luau$", "")
	ScriptEditorService:UpdateSourceAsync(scriptInstance, function()
		return Functions.clipMetadata(sourceCode)
	end)
	if RunContext then
		scriptInstance.RunContext = RunContext
	end
	scriptInstance.Parent = parent

	return scriptInstance, scriptType
end

function Functions.updateScript(scriptInstance, sourceCode: string): boolean
	local scriptType = sourceCode:match("^%-%- @ScriptType: ([^\r\n]+)")

	if scriptType and scriptType ~= scriptInstance.ClassName then
		warn(`Type mismatch | {scriptType} ≠ {scriptInstance.ClassName} | Cannot update {scriptInstance:GetFullName()}`)
		return false
	end

	local RunContext = sourceCode:match("^[^\n]*\n%-%- @RunContext: (%d+)")

	ScriptEditorService:UpdateSourceAsync(scriptInstance, function()
		return Functions.clipMetadata(sourceCode)
	end)

	if scriptInstance:IsA("Script") and RunContext then
		scriptInstance.RunContext = tonumber(RunContext)
	end

	return true
end


----> Populate explorer window (repository viewer) with entries
function Functions.populateExplorer(parentFrame: Frame, path: string) : ()
	local contents = Functions.getRepoContents(path)

	for i, v in parentFrame:GetChildren() do if not v:IsA("UIListLayout") then v:Destroy() end end

	if not contents then return end

	Gitsync.CurrentPath = path or ""
	for _, item in ipairs(contents) do
		local isFolder = (item.type == "dir")
		local entry = Functions.createEntry(item.name, parentFrame, isFolder)

		if isFolder then
			-- Note: Removed window creation for each folder, there may be a reason to not do this
			-- This is done to allow using the explorer the same as you would use the Roblox explorer
			entry.MouseButton1Click:Connect(function()
				local explorer_widget = parentFrame.Parent.Parent
				explorer_widget.Title = "Git Explorer - "..item.name

				Gitsync.CurrentPath = item.path
				Functions.populateExplorer(parentFrame, item.path)
			end)

		else
			entry.MouseButton1Click:Connect(function()	
				local scriptInstance, _ = createScript(
					Functions.fromBase64(HttpService:JSONDecode((HttpService:GetAsync(item.url, true, {["Authorization"] = "token " .. plugin:GetSetting(Gitsync.Settings.TOKEN),["Accept"] = "application/vnd.github.v3+json"}))).content),
					item,
					TestService
				)

				-- Attempt to open in the native Roblox script editor
				local success, err = ScriptEditorService:OpenScriptDocumentAsync(scriptInstance, {
					Temporary = true,
					--InitialReadOnlyReasons = {"Gitsync doesn't save scripts opened via Explorer"} -- This was causing problems for some reason with my studio version
				})
				if success then
					local scriptDocument = ScriptEditorService:FindScriptDocument(scriptInstance)
					local connection
					connection = ScriptEditorService.TextDocumentDidClose:Connect(function(oldDocument: ScriptDocument)
						if oldDocument == scriptDocument then
							scriptInstance:Destroy()
							connection:Disconnect()
						end
					end)
				else
					print(`Failed to open script document: {err}`)
					scriptInstance:Destroy()
				end
			end)
		end
	end
end

----> Generate a folder instance structure (directory) in parent by recursively searching repository directory
function Functions.createStructure(parent: any, contents: any, pullButton: GuiButton) : ()
	local new_directiories: {Folder} = {}
	local tOE = plugin:GetSetting(Gitsync.Settings.OUTPUTENABLED)

	for _, item in pairs(contents) do
		-- changed bc nesting w/ service names would break ↓
		local notService = not (parent == workspace and item.path == item.name and game:FindFirstChild(item.name)) 
		if item.type == "dir" then
			if tOE then if notService then print("dir") else print("service") end end

			local folder: any

			if notService then
				folder = Instance.new("Folder")
				folder.Name, folder.Parent = item.name, parent
				table.insert(new_directiories, folder)
			else folder = game[item.name] end

			local subContents = Functions.getRepoContents(item.path)
			if subContents then Functions.createStructure(folder, subContents, pullButton) end

		elseif item.type == "file" and (item.name:match("%.lua$") or item.name:match("%.luau$")) then

			local fileData = Functions.getRepoContents(item.path)
			if fileData and fileData.content then
				local sourceCode = Functions.fromBase64(fileData.content, item.name)

				local scriptInstance, scriptType = createScript(sourceCode, item, parent)
				scriptInstance:SetAttribute("GitSyncRepository", plugin:GetSetting(Gitsync.Settings.REPOSITORY))
				scriptInstance:SetAttribute("GitSyncPath", item.path)

				Selection:Set({scriptInstance})
				if tOE then print("Created new script: " .. scriptInstance.Name .. " (" .. scriptType .. ")") end
				if pullButton then pullButton.ImageLabel.ImageColor3 = Gitsync.Colors.Green end
			end
		end
	end

	-- Put the files in their folders
	for _, folder in pairs(new_directiories) do	
		for _, v in pairs(folder.Parent:GetChildren()) do
			if not(v:IsA("ModuleScript") or v:IsA("Script") or v:IsA("LocalScript")) then continue end
			if v.Name ~= folder.Name then continue end

			for _, item in pairs(folder:GetChildren()) do
				item.Parent = v
			end

			folder:Destroy()
		end
	end

	return
end

----> Retrieves latest commit data of specified file path
function Functions.getFileSHA(filePath: string) : string | nil
	local HttpService = game:GetService("HttpService")
	local url = "https://api.github.com/repos/" .. plugin:GetSetting(Gitsync.Settings.REPOSITORY) .. "/contents/" .. filePath.."?ref="..plugin:GetSetting(Gitsync.Settings.BRANCH)

	local headers = {
		["Authorization"] = "token " .. plugin:GetSetting(Gitsync.Settings.TOKEN),
		["Accept"] = "application/vnd.github.v3+json"
	}

	local success, response = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "GET",
			Headers = headers
		})
	end)

	if response.Success then
		local data = HttpService:JSONDecode(response.Body)
		return data.sha -- Update
	else
		return nil -- Make new file
	end
end

----> Recursive search a directory and document scripts found
function Functions.scanFolder(folder: Instance, path: string) : boolean
	for _, obj in ipairs(folder:GetChildren()) do
		if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
			if obj:IsA("Script") then
				scriptsSeen[obj.Name] = {["Source"] = ScriptEditorService:GetEditorSource(obj), ["Class"] = obj.ClassName, ["RunContext"] = obj.RunContext, ["Object"] = obj}
			else
				scriptsSeen[obj.Name] = {["Source"] = ScriptEditorService:GetEditorSource(obj), ["Class"] = obj.ClassName, ["Object"] = obj}
			end
		end

		if #obj:GetChildren() > 0 then
			Functions.scanFolder(obj, path .. obj.Name .. "/")
		end
	end

	return true
end

----> Get scripts selected by developer and recursively search folders that are descendants of the selected instances
function Functions.getSelectedScripts() : {BaseScript}
	local selected = Selection:Get()
	scriptsSeen = {}

	for _, obj in ipairs(selected) do
		if obj:IsA("Script") or obj:IsA("LocalScript") or obj:IsA("ModuleScript") then
			if obj:IsA("Script") then
				scriptsSeen[obj.Name] = {["Source"] = ScriptEditorService:GetEditorSource(obj), ["Class"] = obj.ClassName, ["RunContext"] = obj.RunContext, ["Object"] = obj}
			else
				scriptsSeen[obj.Name] = {["Source"] = ScriptEditorService:GetEditorSource(obj), ["Class"] = obj.ClassName, ["Object"] = obj}
			end
		end

		if #obj:GetChildren() > 0 then
			Functions.scanFolder(obj, obj.Name .. "/")
		end
	end

	return scriptsSeen
end

----> Convert data from base 10 to base 64
function Functions.toBase64(data: any) : string
	return buffer.tostring(EncodingService:Base64Encode(buffer.fromstring(data)))
end

----> Convert data from base 64 to base 10
function Functions.fromBase64(data: any, name: string?) : string
	data = data:gsub("%s", "") 
	return buffer.tostring(EncodingService:Base64Decode(buffer.fromstring(data)))
end

-- I updated those functions and while they work I'm unhappy with the current result
-- So I didn't actually implement them into the plugin
-- Also note that RbxDom is a library taken from Rojo, eg.  https://github.com/rojo-rbx/rbx-dom/tree/master/rbx_dom_lua


--function Functions.writeProperties(): (boolean,string)
--	local instancesTable = {}

--	local selected = Selection:Get()
--	for _, item in ipairs(selected) do
--		local properties = ReflectionService:GetPropertiesOfClass(item.ClassName)
--		local defaultClass = Instance.new(item.ClassName)

--		instancesTable[item.ClassName] = {}
--		local superClasses = {}

--		for i, ReflectedProperty in pairs(properties) do
--			-- This should filter out many "unnecessary" properties
--			if not ReflectedProperty.Serialized then continue end
--			if ReflectedProperty.Display.Category == "Permissions" then
--				continue
--			end
--			if ReflectedProperty.Permits.Write == false or ReflectedProperty.Permits.Read == false then
--				continue
--			end

--			local value
--			local success1 = pcall(function()
--				value = item[ReflectedProperty.Name]
--			end)

--			if not success1 then continue end
--			table.insert(superClasses, ReflectedProperty.Owner)

--			if defaultClass[ReflectedProperty.Name] == value then
--				continue
--			end

--			--A lot of types are JSONEncoded as null(or incorrectly) :(
--			local success2, encodedValue = RbxDom.EncodedValue.encodeNaive(value)

--			if success2 then
--				instancesTable[item.ClassName][ReflectedProperty.Name] = encodedValue
--			else
--				return false, encodedValue
--			end
--		end

--		--Certain things that need serialization can't be obtained via ReflectionService
--		for _, superClass in ipairs(superClasses) do
--			if customProperties[superClass] then
--				for key1, property in customProperties[superClass] do
--					local success1, value = property.read(item)
--					if not success1 then print(value) continue end

--					local success2, encodedValue
--					if typeof(value) == "table" then
--						local len = 0
--						for _, _ in pairs(value) do
--							len += 1
--						end

--						if len == 0 then continue end

--						instancesTable[item.ClassName][key1] = {}

--						for key2, value in pairs(value) do
--							success2, encodedValue = RbxDom.EncodedValue.encodeNaive(value)
--							if success2 then
--								instancesTable[item.ClassName][key1][key2] = encodedValue
--							else
--								return false, encodedValue
--							end
--						end

--						continue
--					else
--						success2, encodedValue = RbxDom.EncodedValue.encodeNaive(value)
--					end

--					if success2 then
--						instancesTable[item.ClassName][key1] = encodedValue
--					else
--						return false, encodedValue
--					end
--				end
--			end
--		end

--		defaultClass:Destroy()
--	end

--	-- Write the table to a module script, this is so it's very easy to work with(just require it)
--	local storedData = Instance.new("ModuleScript")
--	storedData.Name = "StoredData"

--	storedData.Source = "local t = {}\nt.data = '" .. HttpService:JSONEncode(instancesTable) .. "'\nreturn t"
--	storedData.Parent = plugin

--	return true,""
--end

--local function readProperties(): (boolean,string)
--	for _, selected in ipairs(Selection:Get()) do
--		if not selected:IsA("ModuleScript") then continue end

--		local json = require(selected) --The module returns a JSON as a string

--		for className, instance in pairs(HttpService:JSONDecode(json.data)) do
--			local newInstance = Instance.new(className)

--			for property, value in pairs(instance) do
--				local newValue = {}
--				if typeof(value) == "table" then 
--					--Dictionaries and tables need to be processed differently
--					--If value[1] exists then it's a table
--					if value[1] then
--						for key2, value in ipairs(value) do
--							local success, decodedValue = RbxDom.EncodedValue.decode(value)
--							if success then
--								newValue[key2] = decodedValue
--							else
--								return false, decodedValue
--							end
--						end
--					else
--						for key2, value in pairs(value) do
--							local success, decodedValue
--							pcall(function() 
--								success, decodedValue = RbxDom.EncodedValue.decode(value)
--							end)
--							if success then
--								newValue[key2] = decodedValue
--							else
--								--No need to decode(already a primitive type)
--								newValue[key2] = value
--							end
--						end
--					end
--				end

--				local success, descriptor = RbxDom.writeProperty(newInstance, property, newValue)
--				if not success then
--					local success1, decodedValue = RbxDom.EncodedValue.decode(newValue)
--					if success1 then
--						newInstance[property] = decodedValue
--					else
--						return false, decodedValue
--					end
--				end
--			end
--			--TODO: implement this properly
--			newInstance.Parent = workspace
--		end
--	end

--	return true, ""
--end

return Functions
---------------------------------------------------