-- @ScriptType: Script
local FrameDetect = script.Parent
local FrameMoves = script.Parent.Parent

local CurrentMousePosition
local Detected = false

FrameDetect.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		CurrentMousePosition = plugin:GetMouse()
		Detected = true
	end
end)

FrameDetect.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 then
		Detected = false
	end
end)

while task.wait() do
	if Detected then
		local MousePosition = plugin:GetMouse()
		local MoveX = CurrentMousePosition.X - MousePosition.X
		local MoveY = CurrentMousePosition.Y - MousePosition.Y
		CurrentMousePosition = MousePosition
		FrameMoves.Position = FrameMoves.Position - UDim2.new(0,MoveX,0,MoveY)
	end
end