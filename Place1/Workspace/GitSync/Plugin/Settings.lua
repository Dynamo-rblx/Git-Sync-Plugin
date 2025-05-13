-- @ScriptType: ModuleScript
-- Basically useless rn
-- Kind of replaced with plugin.GetSettings
-- Need to fully replace w/ plugin.GetSettings for efficiency

local Settings = {}

Settings.outputEnabled = false
Settings.Branch = "main"
--Settings.Paused = false

Settings.PushFrom = {
	["Options"] = {"Selected","Exisiting", "All"} :: table<string>,
	["Default"] = 1 :: number,
	["Current"] = 1 :: number,
	["Max"] = 3 :: number
}

Settings.PullTo = {
	["Options"] = {"Selected","Exisiting", "All"} :: table<string>,
	["Default"] = 1 :: number,
	["Current"] = 1 :: number,
	["Max"] = 3 :: number
}

function Settings.SetBranch(newbranch: string)
	Settings.Branch = newbranch
end

--function Settings.TogglePause()
--	Settings.Paused = not(Settings.Paused)
--	return Settings.Paused
--end

--function Settings.IsPaused()
--	return Settings.Paused
--end

function Settings.ToggleOutputEnabled(): boolean
	Settings.outputEnabled = not(Settings.outputEnabled)
	return Settings.outputEnabled
end

function Settings.SetOutputEnabled(bool: boolean): boolean
	Settings.outputEnabled = bool
	return Settings.outputEnabled
end

function Settings.GetOutputEnabled(): boolean
	return Settings.outputEnabled
end

function Settings.ResetBranch()
	Settings.Branch = "main"
end

function Settings.Init()
	Settings.PullTo.Current = Settings.PullTo.Default
	Settings.PushFrom.Current = Settings.PushFrom.Default
	--Settings.Paused = false
	Settings.Branch = "main"
	return Settings
end

return Settings.Init()