-- @ScriptType: ModuleScript
local data = {
	Connections = {} :: {RBXScriptConnection};
	
	ActiveExplorerWidgets = {} :: {DockWidgetPluginGui};
	
	Colors = {
		Blue = Color3.fromRGB(88, 166, 255),
		Green = Color3.fromRGB(63, 185, 80),
		Red = Color3.fromRGB(248, 81, 73),
		White = Color3.fromRGB(255, 255, 255)
	};
	
	Settings = {
		BRANCH = "BRNCH",
		OUTPUTENABLED = "OE",
		REPOSITORY = "REPO",
		TOKEN = "TKN",
	};
}

-- sigh...
--for name, v in pairs(script.Configuration:GetAttributes()) do
--	local dir = string.split(name, "_")
--	if not data[dir[1]] then data[dir[1]] = {} end
--	data[dir[1]][dir[2]] = v
--end

return data
