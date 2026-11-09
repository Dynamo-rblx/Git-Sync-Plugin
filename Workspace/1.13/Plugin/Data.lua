-- @ScriptType: ModuleScript
local data = {
	Connections = {} :: {RBXScriptConnection};
	
	CurrentPath = "";
	
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

return data
