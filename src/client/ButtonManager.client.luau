local TweenService = game:GetService("TweenService")

local HOVER_COLOR = Color3.fromRGB(0, 170, 255)
local CLICK_FLASH_COLOR = Color3.fromRGB(200, 230, 255)
local FLASH_SPEED = 0.1

local function setupButton(button)
	if not (button:IsA("TextButton") or button:IsA("ImageButton")) then return end

	button.AutoButtonColor = false

	local stroke = button:FindFirstChildOfClass("UIStroke") or Instance.new("UIStroke")
	stroke.Color = HOVER_COLOR
	stroke.Thickness = 2
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Enabled = false
	stroke.Parent = button

	-- Hover (Maus) & Selection (Controller/Keyboard)
	button.MouseEnter:Connect(function() stroke.Enabled = true end)
	button.MouseLeave:Connect(function() stroke.Enabled = false end)
	button.SelectionGained:Connect(function() stroke.Enabled = true end)
	button.SelectionLost:Connect(function() stroke.Enabled = false end)

	-- Klick-Effekt
	button.Activated:Connect(function()
		local originalColor = button.BackgroundColor3
		button.BackgroundColor3 = CLICK_FLASH_COLOR

		task.wait(FLASH_SPEED)

		TweenService:Create(button, TweenInfo.new(FLASH_SPEED), {BackgroundColor3 = originalColor}):Play()
	end)
end

local playerGui = game.Players.LocalPlayer:WaitForChild("PlayerGui")

for _, descendant in pairs(playerGui:GetDescendants()) do
	setupButton(descendant)
end

playerGui.DescendantAdded:Connect(setupButton)