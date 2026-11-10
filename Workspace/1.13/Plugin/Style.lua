-- @ScriptType: ModuleScript
const Camera = workspace.CurrentCamera

local Style = {}

local plugin: Plugin

local function createTooltip(position: Vector2, text: string): Frame
	local tooltip = Instance.new("TextLabel")
	tooltip.Name = "tooltip"
	tooltip.TextWrapped = true
	tooltip.ZIndex = 2
	tooltip.TextScaled = true
	tooltip.BackgroundColor3 = Color3.new(0.129412, 0.14902, 0.176471)
	tooltip.FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Regular, Enum.FontStyle.Normal)
	tooltip.Size = UDim2.new(0.09, 0.00, 0.05, 0.00)
	tooltip.Text = text
	tooltip.TextColor3 = Color3.new(1.00, 1.00, 1.00)
	tooltip.BackgroundTransparency = 0.10000000149011612
	tooltip.Position = UDim2.new(0.00, 287.00, 0.00, 541.00)
	tooltip.Parent = game:GetService("StarterGui"):WaitForChild("GitSyncUI")
	tooltip.Position = UDim2.new(0, position.X, 0, position.Y)

	local UICorner = Instance.new("UICorner")
	UICorner.CornerRadius = UDim.new(0.30, 0.00)
	UICorner.Parent = tooltip

	local UIPadding = Instance.new("UIPadding")
	UIPadding.PaddingBottom = UDim.new(0.10, 0.00)
	UIPadding.PaddingTop = UDim.new(0.10, 0.00)
	UIPadding.PaddingLeft = UDim.new(0.10, 0.00)
	UIPadding.PaddingRight = UDim.new(0.10, 0.00)
	UIPadding.Parent = tooltip

	local UIStroke = Instance.new("UIStroke")
	UIStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	UIStroke.StrokeSizingMode = Enum.StrokeSizingMode.ScaledSize
	UIStroke.Color = Color3.new(0.52, 0.58, 0.66)
	UIStroke.Thickness = 0.05000000074505806
	UIStroke.Transparency = 0.1899999976158142
	UIStroke.Parent = tooltip

	return tooltip
end
	local tooltip = Instance.new("TextLabel")
	tooltip.FontFace = Font.fromEnum(Enum.Font.Ubuntu)
	tooltip.TextColor3 = Color3.new(1, 1, 1)
	tooltip.BackgroundColor3 = Color3.new(0.129412, 0.14902, 0.176471)
	tooltip.TextScaled = true
	tooltip.Size = UDim2.new(0, 100, 0, 40)
	tooltip.Position = UDim2.new(0, position.X, 0, position.Y)
	tooltip.Text = text
	tooltip.Name = "tooltip"
	tooltip.ZIndex = 2

	Instance.new("UICorner", tooltip)

	return tooltip
end

function Style.Init(pluginVar)
	plugin = pluginVar
end

function Style.makeDraggable(object: Frame)
	local mouse: Mouse = plugin:GetMouse()
	local draggingConnection, previousMousePosition

	object.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		previousMousePosition = Vector2.new(mouse.X, mouse.Y)
		mouse.Icon = "rbxasset://SystemCursors/ClosedHand"
		draggingConnection = game.RunService.RenderStepped:Connect(function()
			local movement = Vector2.new(mouse.X, mouse.Y) - previousMousePosition
			object.Position += UDim2.fromOffset(movement.X, movement.Y)
			previousMousePosition = Vector2.new(mouse.X, mouse.Y)
		end)
	end)

	object.InputEnded:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then return end
		if not draggingConnection then return end
		mouse.Icon = "rbxasset://SystemCursors/Arrow"
		draggingConnection:Disconnect()
	end)
end

function Style.addTooltip(object: UIBase, text: string)
	local tooltip = nil
	object.MouseEnter:Connect(function(x: number, y:number)
		local mousePos = Vector2.new(plugin:GetMouse().X, plugin:GetMouse().Y)
		tooltip = createTooltip(mousePos, text)
		tooltip.Parent = object.Parent.Parent.Parent
	end)

	object.MouseLeave:Connect(function(input)
		if tooltip ~= nil then
			tooltip:Destroy()
		end
	end)
end

return Style