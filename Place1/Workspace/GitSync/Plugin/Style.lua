-- @ScriptType: ModuleScript
local Style = {}

local plugin

function Style.Init(pluginVar)
	plugin = pluginVar
end

function Style.makeDraggable(object: Frame)

	local function mousePos()
		local mouse = plugin:GetMouse()
		return Vector2.new(mouse.X, mouse.Y)
	end

	local draggingConnection

	local previousMousePosition

	object.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then

			previousMousePosition = mousePos()

			draggingConnection = game["Run Service"].RenderStepped:Connect(function()

				local movement = mousePos() - previousMousePosition
				object.Position += UDim2.fromOffset(movement.X, movement.Y)

				previousMousePosition = mousePos()
			end)

		end
	end)

	object.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then

			if draggingConnection then
				draggingConnection:Disconnect()
			end

		end
	end)
end

return Style