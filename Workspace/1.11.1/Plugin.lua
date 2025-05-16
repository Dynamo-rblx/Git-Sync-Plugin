-- @ScriptType: Script

--!strict
-- By Roller_Bott
---------------------------------------------------]
-- TODO --

--| ISSUES |--

--| URGENT |--
--> Let user file path to push to

--| OTHER |--
--> Revamp GUI:
----> [Animations]
----> [Fullscreen mode]
----> [Splashscreen]
----> [Tutorial]
----> [Checkbox settings for more detail]
----> [Dropdowns and topbar navigation option]
--> Use flow charts to plan
--> Find a development team

---------------------------------------------------]
task.wait(1.5) ------------------------------------]
---------------------------------------------------]

-- GLOBALS
local toolbar = plugin:CreateToolbar("GitHub Sync")
local mainBTN = toolbar:CreateButton("Push/Pull/Update", "Push, Pull, and Update Selected Scripts to and from GitHub", "rbxassetid://120039353796013", "Toggle")
local settingsBTN = toolbar:CreateButton("Settings", "Configure GitSync Settings", "rbxassetid://140418971118966", "Settings")

local isOpenMain = false
local isOpenSettings = false

local waiting = false
local waitTime = 1

local Interactions = require(script.Interactions)
local Functions = require(script.Functions)
local Style = require(script.Style)

local CoreGui = game:GetService("CoreGui")
---------------------------------------------------

-- SETTINGS
local repo = plugin:GetSetting("REPOSITORY") or ""
plugin:SetSetting("REPOSITORY", repo)

local token = plugin:GetSetting("TOKEN") or ""
plugin:SetSetting("TOKEN", token)

local branch = plugin:GetSetting("BRANCH") or "main"
plugin:SetSetting("BRANCH", branch)

local outputEnabled = plugin:GetSetting("OUTPUT_ENABLED") or true
plugin:SetSetting("OUTPUT_ENABLED", outputEnabled)

local pull_target = plugin:GetSetting("PULL_TARGET") or workspace
plugin:SetSetting("PULL_TARGET", pull_target)
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
assert(ui, "Main UI not found in the script!")
assert(settingsui, "Settings UI not found in the script!")

----> Initialize widgets
local widgetInfo = DockWidgetPluginGuiInfo.new(Enum.InitialDockState.Float, false, false, 300, 200, 300, 200)
local explorer_widget = plugin:CreateDockWidgetPluginGui("GitHubSyncExplorer", widgetInfo)
local explorer_frame = script.ExplorerWindow:Clone()
explorer_widget.Title = "Git Explorer - "..plugin:GetSetting("BRANCH")
explorer_frame.Parent = explorer_widget
explorer_frame.Size = UDim2.fromScale(1,1)

----> Put temporary plugin UI templates in CoreUI
local uiClone, settingsuiClone = ui:Clone(), settingsui:Clone()
uiClone.Parent = CoreGui; settingsuiClone.Parent = CoreGui
uiClone.Enabled = false; settingsuiClone.Enabled = false

----> Connect functions to remote UI
mainBTN.Click:Connect(function() isOpenMain = not(isOpenMain); uiClone.Enabled = isOpenMain; end)
settingsBTN.Click:Connect(function() isOpenSettings = not(isOpenSettings); settingsuiClone.Enabled = isOpenSettings; end)

----> Connect function for unloading behavior
plugin.Unloading:Connect(function()
	if uiClone then uiClone:Destroy(); end
	if settingsuiClone then settingsuiClone:Destroy(); end
end)

----> Initialize UI input behavior
local frame = uiClone.Frame
local pushButton = frame.PushBTN
local pullButton = frame.PullBTN
local loadRepoButton = frame.ViewRepoBTN
local settingBTN_template = settingsuiClone.Frame.ScrollingFrame.template

local repoBox, tokenBox, branchBox = frame.repoBOX, frame.tokenBOX, settingsuiClone.Frame.branchBOX
repoBox.Text, tokenBox.Text, branchBox.Text = repo, token, branch

----> Make UI frames draggable
Style.makeDraggable(frame); Style.makeDraggable(settingsuiClone.Frame);

----> Set up close-window functionality
frame.Close.MouseButton1Click:Connect(function() isOpenMain = not(isOpenMain); uiClone.Enabled = isOpenMain; end)
settingsuiClone.Frame.Close.MouseButton1Click:Connect(function() isOpenSettings = not(isOpenSettings); settingsuiClone.Enabled = isOpenSettings; end)

----> Make push system functional
pushButton.MouseButton1Click:Connect(function()
	if not(waiting) then
		waiting = true

		if Functions.confirm("push") then
			pushButton.ImageLabel.ImageColor3 = Color3.fromRGB(88, 166, 255)
			local repoText = repoBox.Text
			local tokenText = tokenBox.Text
			if repoText ~= "" and tokenText ~= "" then
				plugin:SetSetting("REPOSITORY", repoText)
				plugin:SetSetting("TOKEN", tokenText)

				Interactions.pushToGitHub(pushButton)
				Functions.populateExplorer(explorer_frame.ScrollingFrame, "")

				local existing = Interactions.listBranches()
				for _, branch in pairs(existing) do
					local temp =  settingBTN_template:Clone()
					temp.Text = branch.name
					temp.Parent = settingsuiClone.Frame.ScrollingFrame

					temp.MouseButton1Click:Connect(function()
						settingsuiClone.Frame.branchBOX.Text = branch.name
						plugin:SetSetting("BRANCH", settingsuiClone.Frame.branchBOX.Text)
					end)

					temp.Visible = true
				end

			else
				warn("Enter both the repository name and token")
				pushButton.ImageLabel.ImageColor3 = Color3.fromRGB(248, 81, 73)
			end

			task.wait(waitTime)

			pushButton.ImageLabel.Image = ui.push.Value
			pushButton.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		end

		waiting = false
	end
end)

----> Make pull system functional
pullButton.MouseButton1Click:Connect(function()
	if not(waiting) then
		waiting = true

		if Functions.confirm("pull") then 
			pullButton.ImageLabel.ImageColor3 = Color3.fromRGB(88, 166, 255)
			local repoText = repoBox.Text
			local tokenText = tokenBox.Text

			if repoText ~= "" and tokenText ~= "" then
				plugin:SetSetting("REPOSITORY", repoText)
				plugin:SetSetting("TOKEN", tokenText)

				Interactions.pullFromGitHub(pullButton)

				Functions.populateExplorer(explorer_frame.ScrollingFrame, "")

				local existing = Interactions.listBranches()
				for _, branch in pairs(existing) do
					local temp =  settingBTN_template:Clone()
					temp.Text = branch.name
					temp.Parent = settingsuiClone.Frame.ScrollingFrame

					temp.MouseButton1Click:Connect(function()
						settingsuiClone.Frame.branchBOX.Text = branch.name
						plugin:SetSetting("BRANCH", settingsuiClone.Frame.branchBOX.Text)
					end)

					temp.Visible = true
				end

			else
				warn("Enter both the repository name and token")
				pullButton.ImageLabel.ImageColor3 = Color3.fromRGB(248, 81, 73)
			end

			task.wait(waitTime)


			pullButton.ImageLabel.Image = ui.pull.Value
			pullButton.ImageLabel.ImageColor3 = Color3.fromRGB(255, 255, 255)
		end
		waiting = false
	end
end)

----> Make repository explorer functional
loadRepoButton.MouseButton1Click:Connect(function()
	local repoText = repoBox.Text
	local tokenText = tokenBox.Text
	if repoText ~= "" and tokenText ~= "" then
		explorer_widget.Enabled = true

		for i, v in pairs(explorer_frame.ScrollingFrame:GetChildren()) do
			if not(v:IsA("UIListLayout")) then
				v:Destroy()
			end
		end

		Functions.populateExplorer(explorer_frame.ScrollingFrame, "")
	else
		warn("Enter both repository name and token.")
	end
end)

----> Make branch choosing functional
branchBox.FocusLost:Connect(function(enter, reason)
	local branchName = branchBox.Text

	plugin:SetSetting("BRANCH", settingsuiClone.Frame.branchBOX.Text)

	local existing = Interactions.listBranches()


	if not(table.find(existing, branchName)) then
		local sha = Interactions.getLatestCommitSHA()

		if not(Interactions.createBranch(branchName, sha)) then
			plugin:SetSetting("BRANCH", "main")
		else
			plugin:SetSetting("BRANCH", branchName)
		end
	end

	existing = Interactions.listBranches()

	for _, item in pairs(settingsuiClone.Frame.ScrollingFrame:GetChildren()) do
		if item:IsA("TextButton") and item ~= settingBTN_template then
			item:Destroy()
		end
	end

	for _, branch in pairs(existing) do
		local temp =  settingBTN_template:Clone()
		temp.Text = branch.name
		temp.Parent = settingsuiClone.Frame.ScrollingFrame

		temp.MouseButton1Click:Connect(function()
			settingsuiClone.Frame.branchBOX.Text = branch.name
			plugin:SetSetting("BRANCH", branch.name)
		end)

		temp.Visible = true
	end
end)

----> Make toggle output setting functional
settingsuiClone.Frame.PrintToggle.MouseButton1Click:Connect(function()
	plugin:SetSetting("OUTPUT_ENABLED", not(plugin:GetSetting("OUTPUT_ENABLED")))
end)
---------------------------------------------------
-- RUNTIME CODE

while task.wait(.05) do	----> 20 cycles per second
	----> Update repository explorer window title
	explorer_widget.Title = "Git Explorer - "..plugin:GetSetting("BRANCH")
	
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
		settingsuiClone.Frame.PrintToggle.TextColor3 = Color3.fromRGB(63, 185, 80)
		settingsuiClone.Frame.PrintToggle.Text = "Printing All Output"
	else
		settingsuiClone.Frame.PrintToggle.TextColor3 = Color3.fromRGB(248, 81, 73)
		settingsuiClone.Frame.PrintToggle.Text = "Printing Only Errors"
	end
end
---------------------------------------------------