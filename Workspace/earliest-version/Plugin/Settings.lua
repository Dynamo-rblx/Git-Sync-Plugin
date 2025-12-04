-- @ScriptType: ModuleScript
local Settings = {}

Settings.Branch = "main"

Settings.PushFrom = {
	["Options"] = {"Selected","Exisiting", "All"} :: table<string>,
	["Default"] = 1 :: number,
	["Current"] = 1 :: number,
	["Max"] = 3 ::number
}

Settings.PullTo = {
	["Options"] = {"Selected","Exisiting", "All"} :: table<string>,
	["Default"] = 1 :: number,
	["Current"] = 1 :: number,
	["Max"] = 3 ::number
}

function Settings.SetBranch(newbranch: string)
	Settings.Branch = newbranch
end

function Settings.ResetBranch()
	Settings.Branch = "main"
end

function Settings.Init()
	Settings.PullTo.Current = Settings.PullTo.Default
	Settings.PushFrom.Current = Settings.PushFrom.Default
	return Settings
end

return Settings.Init()