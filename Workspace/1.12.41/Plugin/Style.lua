-- @ScriptType: ModuleScript
local Style = {}

local plugin

function Style.Init(pluginVar)
	plugin = pluginVar
end

function Style.makeDraggable(object: Frame)
	local mouse: Mouse = plugin:GetMouse()
	local draggingConnection, previousMousePosition

	object.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then

			previousMousePosition = Vector2.new(mouse.X, mouse.Y)
			mouse.Icon = "rbxasset://SystemCursors/ClosedHand"
			draggingConnection = game["Run Service"].RenderStepped:Connect(function()

				local movement = Vector2.new(mouse.X, mouse.Y) - previousMousePosition
				object.Position += UDim2.fromOffset(movement.X, movement.Y)
				previousMousePosition = Vector2.new(mouse.X, mouse.Y)
			end)

		end
	end)

	object.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			if draggingConnection then
				mouse.Icon = "rbxasset://SystemCursors/Arrow"
				draggingConnection:Disconnect()
			end

		end
	end)
end

return Style