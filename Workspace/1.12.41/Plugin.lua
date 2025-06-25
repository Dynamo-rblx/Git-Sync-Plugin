-- @ScriptType: Script
--!native

-- By Roller_Bott
---------------------------------------------------]
-- TODO --

--| ISSUES |--

--| URGENT |--
--> Let user choose file path to push to

--| OTHER |--
--> Revamp GUI:
----> [Animations]
----> [Fullscreen mode]
----> [Splashscreen]
----> [Tutorial]
----> [Checkbox settings for more detail]
----> [Dropdowns and topbar navigation option]
----> [Commission UI artist?]
--> Use flow charts to plan
--> Find a development team

---------------------------------------------------]
task.wait(1.5) ------------------------------------]
---------------------------------------------------]

-- VERSION CHECK
local success, info = pcall(function() return game:GetService("MarketplaceService"):GetProductInfo(138677233030370, Enum.InfoType.Asset) end)

if success then
	local current_upd = info.Description
	local current_upd_header = current_upd:match("Version:%s*v[%d%.-]+")

	if current_upd_header then
		current_upd_info = current_upd_header:match("v[%d%.-]+")

		if current_upd_info ~= script:GetAttribute("v") then
			warn("VERSION CHECK FAILED: "..current_upd_info.." ~= "..script:GetAttribute("v").."!")
			task.delay(3, function() warn("🔴 A new version of GitSync is available! Please update your plugin as soon as possible! 🔴") end)
		else
			task.delay(3, function() warn("🟢 Your GitSync plugin is up-to-date! 🟢") end)
		end
	end
else
	warn("Failed to retrieve product info. Please make sure your plugin is up-to-date.")
end

-- GLOBALS
local toolbar = plugin:CreateToolbar("GitSync")
local mainBTN = toolbar:CreateButton("Push/Pull/Update", "Push, Pull, and Update Selected Scripts to and from GitHub", "rbxassetid://120039353796013", "Action Menu")
local settingsBTN = toolbar:CreateButton("Settings", "Configure GitSync Settings", "rbxassetid://140418971118966", "Settings")
local infoBTN = toolbar:CreateButton("Info", "Help, Source Code, and more!", "rbxassetid://76424011275500", "Information")

local mouse = plugin:GetMouse()

local isOpenMain = false
local isOpenSettings = false
local isOpenInfo = false

local waiting = false
local waitTime = 1

local Config = script.Configuration

Gitsync = require(script.Data)

----> Only retrieve attributes once this way, and store them globally
----> ex. Colors.Blue
for name, v in pairs(Config:GetAttributes()) do
	local data = string.split(name, "_")
	if not Gitsync[data[1]] then Gitsync[data[1]] = {} end
	Gitsync[data[1]][data[2]] = v
end

Gitsync.Loaded = true ----> Stop yielding module threads

local CoreGui = game:GetService("CoreGui")
local Interactions = require(script.Interactions)
local Functions = require(script.Functions)
local Style = require(script.Style)
---------------------------------------------------

-- SETTINGS
local repo_init = plugin:GetSetting("REPOSITORY") or ""
plugin:SetSetting("REPOSITORY", repo_init)

local token_init = plugin:GetSetting("TOKEN") or ""
plugin:SetSetting("TOKEN", token_init)

local branch_init = plugin:GetSetting("BRANCH") or "main"
plugin:SetSetting("BRANCH", branch_init)
local past_branch = branch_init

local outputEnabled_init = plugin:GetSetting("OUTPUT_ENABLED") or true
plugin:SetSetting("OUTPUT_ENABLED", outputEnabled_init)

local pull_target_init = plugin:GetSetting("PULL_TARGET") or workspace
plugin:SetSetting("PULL_TARGET", pull_target_init)
---------------------------------------------------

-- INITIALIZATION
Style.Init(plugin)
Functions.Init(plugin)
Interactions.Init(plugin)
---------------------------------------------------

-- PLUGIN INTERFACE SETUP
----> Find UI
local ui = script:FindFirstChild("GitSyncUI")
local settingsui = script:FindFirstChild("SettingsUI")
local infoui = script:FindFirstChild("InfoUI")

assert(ui, "Main UI not found in the script!")
assert(settingsui, "Settings UI not found in the script!")
assert(infoui, "Info UI not found in the script!")

----> Initialize widgets
local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 300, 200, 300, 200)
local explorer_widget = plugin:CreateDockWidgetPluginGui("GitHubSyncExplorer", widgetInfo)
local explorer_frame = script.ExplorerWindow:Clone()
explorer_widget.Title = "Git Explorer - "..plugin:GetSetting("BRANCH")
explorer_frame.Parent = explorer_widget
explorer_frame.Size = UDim2.fromScale(1,1)

----> Put temporary plugin UI templates in CoreUI
local uiClone, settingsuiClone, infouiClone = ui:Clone(), settingsui:Clone(), infoui:Clone()
uiClone.Enabled = false; settingsuiClone.Enabled = false; infouiClone.Enabled = false;
uiClone.Parent = CoreGui; settingsuiClone.Parent = CoreGui; infouiClone.Parent = CoreGui;

----> Connect functions to remote UI
mainBTN.Click:Connect(function() isOpenMain = not(isOpenMain); uiClone.Enabled = isOpenMain; end)
settingsBTN.Click:Connect(function() isOpenSettings = not(isOpenSettings); settingsuiClone.Enabled = isOpenSettings; end)
infoBTN.Click:Connect(function() isOpenInfo = not(isOpenInfo); infouiClone.Enabled = isOpenInfo; end)

----> Connect function for unloading behavior
plugin.Unloading:Connect(function()
	if uiClone then uiClone:Destroy(); end
	if settingsuiClone then settingsuiClone:Destroy(); end
	if infouiClone then infouiClone:Destroy(); end
end)

----> Initialize UI input behavior
local frame = uiClone.Frame
local settingsFrame = settingsuiClone.Frame
local infoFrame = infouiClone.Frame

local pushButton = frame.PushBTN
local pullButton = frame.PullBTN
local loadRepoButton = frame.ViewRepoBTN
local loadBranchesButton = settingsFrame.LoadBranches
local refreshButton = frame.RefreshBTN

local settingBTN_template = settingsFrame.ScrollingFrame.template

local repoBox, tokenBox, branchBox = frame.repoBOX, frame.tokenBOX, settingsFrame.branchBOX
repoBox.Text, tokenBox.Text, branchBox.Text = repo_init, token_init, branch_init

----> Make UI frames draggable
Style.makeDraggable(frame); Style.makeDraggable(settingsFrame); Style.makeDraggable(infoFrame);

----> Set up close-window functionality
frame.Close.MouseButton1Click:Connect(function() isOpenMain = not(isOpenMain); uiClone.Enabled = isOpenMain; end)
settingsFrame.Close.MouseButton1Click:Connect(function() isOpenSettings = not(isOpenSettings); settingsuiClone.Enabled = isOpenSettings; end)
infoFrame.Close.MouseButton1Click:Connect(function() isOpenInfo = not(isOpenInfo); infouiClone.Enabled = isOpenInfo; end)

----> Make window refresh button functional
refreshButton.MouseButton1Click:Connect(function()
	if waiting then return end
	waiting = true
	mouse.Icon = "rbxasset://SystemCursors/Busy"
	for i, widget: DockWidgetPluginGui in pairs(Gitsync.ActiveExplorerWidgets) do widget:Destroy(); Gitsync.ActiveExplorerWidgets[i] = nil; end
	Functions.populateExplorer(explorer_frame.ScrollingFrame, "")
	if plugin:GetSetting("OUTPUT_ENABLED") then print("Refreshed explorer window") end
	waiting = false
	mouse.Icon = "rbxasset://SystemCursors/Arrow"
end)

----> Make branch list load button functional
loadBranchesButton.MouseButton1Click:Connect(function()
	--print("e")
	for _, item in pairs(settingsFrame.ScrollingFrame:GetChildren()) do
		if not (item:IsA("GuiButton") and item ~= settingBTN_template) then continue end
		item:Destroy() ----> Clear list of branches
	end

	for _, branch in pairs(Interactions.listBranches()) do
		local temp =  settingBTN_template:Clone() ----> Make a new button
		temp.Text = branch.name
		temp.Parent = settingsFrame.ScrollingFrame

		temp.MouseButton1Click:Connect(function()
			settingsFrame.branchBOX.Text = branch.name
			plugin:SetSetting("BRANCH", branch.name)
		end)

		temp.Visible = true
	end

	for i, widget: DockWidgetPluginGui in pairs(Gitsync.ActiveExplorerWidgets) do widget:Destroy(); Gitsync.ActiveExplorerWidgets[i] = nil; end
	Functions.populateExplorer(explorer_frame.ScrollingFrame, "")
end)

----> Make push system functional
pushButton.MouseButton1Click:Connect(function()
	if waiting then return end
	waiting = true
	mouse.Icon = "rbxasset://SystemCursors/Busy"
	pushButton.ImageLabel.ImageColor3 = Color3.fromRGB(88, 166, 255)

	if plugin:GetSetting("REPOSITORY") == "" or plugin:GetSetting("TOKEN") == "" then
		warn("Enter both the repository name and token")
		pushButton.ImageLabel.ImageColor3 = Gitsync.Colors.Red
		return
	end

	if not Functions.confirm("push") then return end


	--local repoText = repoBox.Text
	--local tokenText = tokenBox.Text
	--if repoText ~= "" and tokenText ~= "" then
	--	plugin:SetSetting("REPOSITORY", repoText)
	--	plugin:SetSetting("TOKEN", tokenText)

	Interactions.pushToGitHub(pushButton)

	for i, widget: DockWidgetPluginGui in pairs(Gitsync.ActiveExplorerWidgets) do widget:Destroy(); Gitsync.ActiveExplorerWidgets[i] = nil; end
	Functions.populateExplorer(explorer_frame.ScrollingFrame, "")

	--local existing = Interactions.listBranches()
	--for _, branch in pairs(existing) do
	--	local temp =  settingBTN_template:Clone()
	--	temp.Text = branch.name
	--	temp.Parent = settingsFrame.ScrollingFrame

	--	temp.MouseButton1Click:Connect(function()
	--		settingsFrame.branchBOX.Text = branch.name
	--		plugin:SetSetting("BRANCH", settingsFrame.branchBOX.Text)
	--	end)

	--	temp.Visible = true
	--end


	task.wait(waitTime)

	pushButton.ImageLabel.Image = ui.push.Value
	pushButton.ImageLabel.ImageColor3 = Gitsync.Colors.White

	waiting = false
	mouse.Icon = "rbxasset://SystemCursors/Arrow"
end)

----> Make pull system functional
pullButton.MouseButton1Click:Connect(function()
	if waiting then return end

	waiting = true
	mouse.Icon = "rbxasset://SystemCursors/Busy"

	if plugin:GetSetting("REPOSITORY") == "" or plugin:GetSetting("TOKEN") == "" then
		warn("Enter both the repository name and token")
		pushButton.ImageLabel.ImageColor3 = Gitsync.Colors.Red
		return
	end

	if not Functions.confirm("pull") then waiting=false; return end

	pullButton.ImageLabel.ImageColor3 = Gitsync.Colors.Blue

	--local repoText = repoBox.Text
	--local tokenText = tokenBox.Text

	--if not (repoText ~= "" and tokenText ~= "") then
	--	warn("Enter both the repository name and token")
	--	pullButton.ImageLabel.ImageColor3 = Gitsync.Colors.Red
	--end

	--plugin:SetSetting("REPOSITORY", repoText)
	--plugin:SetSetting("TOKEN", tokenText)

	Interactions.pullFromGitHub(pullButton)

	--Functions.populateExplorer(explorer_frame.ScrollingFrame, "")

	--for _, indicator in settingsFrame.ScrollingFrame:GetChildren() do if indicator:IsA("GuiButton") then indicator:Destroy() end end

	--for _, branch in pairs(Interactions.listBranches()) do
	--	local temp = settingBTN_template:Clone()
	--	temp.Text = branch.name
	--	temp.Parent = settingsFrame.ScrollingFrame

	--	temp.MouseButton1Click:Connect(function()
	--		settingsFrame.branchBOX.Text = branch.name
	--		plugin:SetSetting("BRANCH", settingsFrame.branchBOX.Text)
	--	end)

	--	temp.Visible = true
	--end

	task.wait(waitTime)


	pullButton.ImageLabel.Image = ui.pull.Value
	pullButton.ImageLabel.ImageColor3 = Gitsync.Colors.White

	waiting = false
	mouse.Icon = "rbxasset://SystemCursors/Arrow"
end)

----> Make repository explorer functional
loadRepoButton.MouseButton1Click:Connect(function()
	local repoText = repoBox.Text
	local tokenText = tokenBox.Text
	if not (repoText ~= "" and tokenText ~= "") then warn("Enter both repository name and token.") end
	explorer_widget.Enabled = true

	for i, v in pairs(explorer_frame.ScrollingFrame:GetChildren()) do
		if v:IsA("UIListLayout") then continue end
		v:Destroy()
	end

	for i, widget: DockWidgetPluginGui in pairs(Gitsync.ActiveExplorerWidgets) do widget:Destroy(); Gitsync.ActiveExplorerWidgets[i] = nil; end
	Functions.populateExplorer(explorer_frame.ScrollingFrame, "")
end)

----> Update repo and token inputs
repoBox.Text = string.rep("*", #repoBox.Text)
tokenBox.Text = string.rep("*", #tokenBox.Text)

repoBox.Focused:Connect(function()
	repoBox.Text = plugin:GetSetting("REPOSITORY")
end)

tokenBox.Focused:Connect(function()
	tokenBox.Text = plugin:GetSetting("TOKEN")
end)

repoBox.FocusLost:Connect(function()
	plugin:SetSetting("REPOSITORY", repoBox.Text)
	repoBox.Text = string.rep("*", #repoBox.Text)
end)

tokenBox.FocusLost:Connect(function()
	plugin:SetSetting("TOKEN", tokenBox.Text)
	tokenBox.Text = string.rep("*", #tokenBox.Text)
end)

----> Show tooltip when needed
branchBox.Focused:Connect(function()
	settingsFrame.branchCreateTip.Visible = true
end)

----> Make branch choosing functional
branchBox.FocusLost:Connect(function(enter, reason)
	settingsFrame.branchCreateTip.Visible = false
	local branchName = branchBox.Text
	local branchExists = false

	for i, info in ipairs(Interactions.listBranches()) do if info.name == branchName then branchExists = true; break; end end

	if not branchExists then
		local sha = Interactions.getLatestCommitSHA()

		if not sha then return end

		if not(Interactions.createBranch(branchName, sha)) then
			plugin:SetSetting("BRANCH", "main")
			warn("Attempt to create branch \""..branchName.."\" failed")
		else
			plugin:SetSetting("BRANCH", branchName)
			if plugin:GetSetting("OUTPUT_ENABLED") then print("Branch \""..branchName.."\" has been created successfully") end
		end
	end

	for _, item in pairs(settingsFrame.ScrollingFrame:GetChildren()) do
		if not (item:IsA("GuiButton") and item ~= settingBTN_template) then continue end
		item:Destroy() ----> Clear list of branches
	end

	for _, branch in pairs(Interactions.listBranches()) do
		local temp =  settingBTN_template:Clone() ----> Make a new button
		temp.Text = branch.name
		temp.Parent = settingsFrame.ScrollingFrame

		temp.MouseButton1Click:Connect(function()
			settingsFrame.branchBOX.Text = branch.name
			plugin:SetSetting("BRANCH", branch.name)

			while waiting do task.wait(.01) end

			waiting = true

			for i, widget: DockWidgetPluginGui in pairs(Gitsync.ActiveExplorerWidgets) do widget:Destroy(); Gitsync.ActiveExplorerWidgets[i] = nil; end
			Functions.populateExplorer(explorer_frame.ScrollingFrame, "")

			waiting = false

			if plugin:GetSetting("OUTPUT_ENABLED") then print("Refreshed explorer window") end
		end)

		temp.Visible = true
	end
end)

----> Make toggle output setting functional
settingsFrame.PrintToggle.MouseButton1Click:Connect(function()
	plugin:SetSetting("OUTPUT_ENABLED", not(plugin:GetSetting("OUTPUT_ENABLED")))
end)
---------------------------------------------------
-- RUNTIME CODE
while task.wait(.05) do	----> 20 cycles per second
	----> Update repository explorer window title
	explorer_widget.Title = "Git Explorer - "..plugin:GetSetting("BRANCH")

	----> Update branch list

	if not (plugin:GetSetting("BRANCH") == past_branch) then
		past_branch = plugin:GetSetting("BRANCH")
		while waiting do task.wait(.01) end

		waiting = true

		for i, widget: DockWidgetPluginGui in pairs(Gitsync.ActiveExplorerWidgets) do widget:Destroy(); Gitsync.ActiveExplorerWidgets[i] = nil; end
		Functions.populateExplorer(explorer_frame.ScrollingFrame, "")

		waiting = false
	end

	----> Update selected scripts list
	local scripts = Functions.getSelectedScripts()

	for i, v in pairs(frame:WaitForChild("ScrollingFrame"):GetChildren()) do
		if not(scripts[v.Name]) and v ~= frame.ScrollingFrame.template and v:IsA("TextLabel") then
			v:Destroy()
		end
	end

	for name, data in pairs(scripts) do
		local scr_frm = frame.ScrollingFrame

		if not(scr_frm:FindFirstChild(name)) then
			local temp = frame.ScrollingFrame.template:Clone()
			temp.Name = name
			temp.Text = name
			temp.Parent = frame.ScrollingFrame
			temp.Visible = true
		end

	end

	----> Update settings widget display
	if plugin:GetSetting("OUTPUT_ENABLED") and settingsuiClone.Enabled then
		settingsFrame.PrintToggle.TextColor3 = Gitsync.Colors.Green
		settingsFrame.PrintToggle.Text = "Printing All Output"
	else
		settingsFrame.PrintToggle.TextColor3 = Gitsync.Colors.Red
		settingsFrame.PrintToggle.Text = "Printing Only Errors"
	end
end
---------------------------------------------------