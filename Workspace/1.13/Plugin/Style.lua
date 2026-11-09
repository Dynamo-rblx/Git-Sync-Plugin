const Camera = workspace.CurrentCamera

local Style = {}

local plugin: Plugin

local function createTooltip(position: Vector2, text: string): Frame
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