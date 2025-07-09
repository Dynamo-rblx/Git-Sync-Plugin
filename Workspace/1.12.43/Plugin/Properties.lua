-- @ScriptType: ModuleScript
--!strict
--!optimize 2

--[[
Code By: @YarikSuperpro on Roblox/Github
	Source: https://github.com/YarikSuperpro/Get-all-properties-of-instance-roblox/blob/main/Code.luau
]]

local HttpService = game:GetService("HttpService")
type SecurityMethods = "None"|"LocalUserSecurity"|"NotAccessibleSecurity"|"PluginSecurity"|"RobloxScriptSecurity"|"RobloxSecurity"
type Class_Tags = {
	[number]:"CanYield"|"CustomLuaState"|"Deprecated"|"Hidden"|"NoYield"|"NotBrowsable"|"NotCreatable"|"NotReplicated"|"NotScriptable"|"PlayerReplicated"|"ReadOnly"|"Service"|"Settings"|"UserSettings"|"Yields"
}
type Thread_Safety = "ReadSafe"|"Safe"|"Unsafe"
type Capabilities = "Animation"|"Assistant"|"Audio"|"Avatar"|"Basic"|"CSG"|"CapabilityControl"|"Chat"|"CreateInstances"|"DataStore"|"Environment"|"Input"|"InternalTest"|"LegacySound"|"Network"|"Physics"|"Players"|"PluginOrOpenCloud"|"RemoteEvent"|"UI"
--------^^^^^^ is basically Enum.SecurityCapability
type Value_Type = {
	["Name"]:string;
	["Category"]:string;
}
type AllRobloxClasses = {
	[number]:{
		["Tags"]: Class_Tags?;
		["Superclass"]:string;
		["Name"]:string;
		["MemoryCategory"]:"Animation"|"GraphicsTexture"|"Gui"|"Instances"|"Internal"|"PhysicsParts"|"Script"; 
		["Members"]:{
			[number]:{
				["Capabilities"]:{
					[number]:{
						[number]:Capabilities
					}|{
						["Read"]:{
							[number]:Capabilities
						};
						["Write"]:{
							[number]:Capabilities
						}
					}	
				}?;
				["Category"]:string?;
				["MemberType"]:"Callback"|"Event"|"Function"|"Property";
				["Name"]:string;
				["Parameters"]:{
					[number]:{
						["Name"]:string;
						["Type"]:Value_Type
					}
				}?;
				["ReturnType"]:Value_Type?;
				["Security"]:SecurityMethods|{
					["Read"]:SecurityMethods|{SecurityMethods};
					["Write"]:SecurityMethods|{SecurityMethods}
				};
				["Serialization"]:{
					["CanLoad"]:boolean;
					["CanSave"]:boolean
				}?;
				["Tags"]:Class_Tags?;
				["ThreadSafety"]:Thread_Safety;
				["ValueType"]:{
					["Category"]:"Class"|"DataType"|"Enum"|"Primitive";
					["Name"]:string;
				}?;
			}
		};
	}
}
type AllRobloxEnums = {
	[number]:{
		Name:string;
		Items:{
			[number]:{Name:string;Value:number}
		};
		Tags:Class_Tags?
	}
}
type API_Dump = {
	Classes:AllRobloxClasses;
	Enums:AllRobloxEnums;
	Version:number
}

type FormattedClass = {
	[string]:string
}
type FormattedClasses = {
	[string]:FormattedClass
}
-- i think there is a few more types that i missed
local TranslateProperties:FormattedClass = {
	["bool"]="boolean";
	["int"]="number";
	["float"]="number";
	["double"]="number";
	["int32"]="number";
	["int64"]="number";
	["int16"]="number";
	["int8"]="number";
}

local success,ret = pcall(HttpService.GetAsync,HttpService,"https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/API-Dump.json")
--Im still standing ahhh loop 🔥🔥🔥
while success~=true do
	success,ret = pcall(HttpService.GetAsync,HttpService,"https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/refs/heads/roblox/API-Dump.json")
end

local Data:API_Dump = HttpService:JSONDecode(ret)

local raw_Classes:AllRobloxClasses = Data.Classes

local Enums:AllRobloxEnums = Data.Enums

local Classes:FormattedClasses = {}
for i,v in raw_Classes do
	--if v.MemoryCategory~="Instances" then continue end
	if v.Tags~=nil and (table.find(v.Tags,"NotCreatable")~=nil or table.find(v.Tags,"NotScriptable")~=nil) then continue end
	local tab:FormattedClass = {}
	local Superclass:string? = v.Name
	while Superclass~=nil do
		local search:number? = nil
		for i,v in raw_Classes do
			if v.Name==Superclass then search=i break end
		end
		if search==nil then break end
		for ii,vv in raw_Classes[search].Members do
			if vv.MemberType~="Property" then continue end
			if (type(vv.Security)=="string" and vv.Security~="None") or (type(vv.Security)=="table" and (vv.Security.Write~="None" or vv.Security.Read~="None")) then continue end
			if vv.ValueType==nil then continue end
			if vv.Tags~=nil and (table.find(vv.Tags,"ReadOnly")~=nil or table.find(vv.Tags,"NotScriptable")~=nil or table.find(vv.Tags,"Deprecated")~=nil or table.find(vv.Tags,"Hidden")~=nil or table.find(vv.Tags,"Not Replicated")~=nil) then continue end
			tab[vv.Name]=(vv.ValueType.Category=="Class" and "Instance") or (vv.ValueType.Category=="Enum" and `Enum.{vv.ValueType.Name}`) or (TranslateProperties[vv.ValueType.Name] or vv.ValueType.Name)
		end
		Superclass=raw_Classes[search].Superclass
	end
	Classes[v.Name]=tab
end
-- Man im dead 🔥🔥🔥💀
return Classes