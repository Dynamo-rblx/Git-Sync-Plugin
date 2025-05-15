-- @ScriptType: Script
--!strict
-- By Roller_Bott
---------------------------------------------------]
-- TODO --

--> Fix branch list display
--> Revamp GUI:
----> [Fullscreen mode]
----> [Splashscreen]
----> [Tutorial]
----> [Checkbox settings for more detail]
----> [Dropdowns and topbar navigation option]
--> Use flow charts to plan
--> Find a development team

---------------------------------------------------]
---------------------------------------------------]
---------------------------------------------------
task.wait(1.5)

-- VARIABLES
local toolbar = plugin:CreateToolbar("GitSync Testing 2")
local mainBTN = toolbar:CreateButton("Push/Pull/Update", "Push, Pull, and Update Selected Scripts to and from GitHub", "rbxassetid://10734930886", "Toggle")
local settingsBTN = toolbar:CreateButton("Settings", "Configure GitSync Settings", "rbxassetid://10734930886", "Settings")
local repo = plugin:GetSetting("REPOSITORY") or ""
plugin:SetSetting("REPOSITORY", repo)

local token = plugin:GetSetting("TOKEN") or ""
plugin:SetSetting("TOKEN", token)

local CoreGui = game:GetService("CoreGui")
---------------------------------------------------

-- SETTINGS
local branch = plugin:GetSetting("BRANCH") or "main"
plugin:SetSetting("BRANCH", branch)

local outputEnabled = plugin:GetSetting("OUTPUT_ENABLED") or true
plugin:SetSetting("OUTPUT_ENABLED", outputEnabled)

local isOpenUI = false
local isOpenSettings = false

local waiting = false
local waitTime = 1

local Interactions = require(script.Interactions)
local Functions = require(script.Functions)
local Style = require(script.Style)
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
local uiClone = ui:Clone()
uiClone.Parent = CoreGui
uiClone.Enabled = false

local settingsuiClone = settingsui:Clone()
settingsuiClone.Parent = CoreGui
settingsuiClone.Enabled = false

----> Connect functions to remote UI
mainBTN.Click:Connect(function() isOpenUI = not(isOpenUI); uiClone.Enabled = isOpenUI; end)
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

frame.Close.MouseButton1Click:Connect(function() isOpenUI = not(isOpenUI); uiClone.Enabled = isOpenUI; end)
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

				Interactions.pushToGitHub(repoText, tokenText, pushButton)
				Functions.populateExplorer(repoText, tokenText, explorer_frame.ScrollingFrame, "", plugin)

				local existing = Interactions.listBranches(repoText, tokenText)
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

				Interactions.pullFromGitHub(repoText, tokenText, pullButton)

				Functions.populateExplorer(repoText, tokenText, explorer_frame.ScrollingFrame, "", plugin)

				local existing = Interactions.listBranches(repoText, tokenText)
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

		Functions.populateExplorer(repoText, tokenText, explorer_frame.ScrollingFrame, "", plugin)
	else
		warn("Enter both repository name and token.")
	end
end)

----> Make branch choosing functional
branchBox.FocusLost:Connect(function(enter, reason)
	local repoText = repoBox.Text
	local tokenText = tokenBox.Text
	local branchName = branchBox.Text

	plugin:SetSetting("BRANCH", settingsuiClone.Frame.branchBOX.Text)

	local existing = Interactions.listBranches(repoText, tokenText)


	if not(table.find(existing, branchName)) then
		local sha = Interactions.getLatestCommitSHA(repoText, "main", tokenText)

		if not(Interactions.createBranch(repoText, branchName, sha, tokenText)) then
			plugin:SetSetting("BRANCH", "main")
		end
	end

	existing = Interactions.listBranches(repoText, tokenText)

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
			plugin:SetSetting("BRANCH", settingsuiClone.Frame.branchBOX.Text)
		end)

		temp.Visible = true
	end
end)

----> Make toggle output setting functional
settingsuiClone.Frame.PrintToggle.MouseButton1Click:Connect(function()
	plugin:SetSetting("OUTPUT_ENABLED", not(plugin:GetSetting("OUTPUT_ENABLED")))
end)
---------------------------------------------------
-- PERIODIC (RUNTIME) CODE

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