local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local SPRINT_MULTIPLIER = 1.5
local DEFAULT_WALK_SPEED = 16

local humanoid: Humanoid? = nil
local baseWalkSpeed = DEFAULT_WALK_SPEED
local sprinting = false

local function getSprintSpeed()
	return math.max(baseWalkSpeed * SPRINT_MULTIPLIER, baseWalkSpeed)
end

local function applyWalkSpeed()
	if not humanoid then return end
	humanoid.WalkSpeed = sprinting and getSprintSpeed() or baseWalkSpeed
end

local function setSprinting(enabled: boolean)
	if sprinting == enabled then return end
	sprinting = enabled
	applyWalkSpeed()
end

local function bindCharacter(character: Model)
	humanoid = character:WaitForChild("Humanoid") :: Humanoid
	baseWalkSpeed = humanoid.WalkSpeed > 0 and humanoid.WalkSpeed or DEFAULT_WALK_SPEED
	applyWalkSpeed()

	humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
		if not humanoid then return end
		local expectedSprintSpeed = getSprintSpeed()
		if sprinting and math.abs(humanoid.WalkSpeed - expectedSprintSpeed) < 0.05 then return end
		if not sprinting and math.abs(humanoid.WalkSpeed - baseWalkSpeed) < 0.05 then return end

		baseWalkSpeed = humanoid.WalkSpeed
		applyWalkSpeed()
	end)
end

local function createMobileSprintButton()
	if not UserInputService.TouchEnabled then return end
	if player.PlayerGui:FindFirstChild("SprintGui") then return end

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "SprintGui"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.Parent = player:WaitForChild("PlayerGui")

	local button = Instance.new("TextButton")
	button.Name = "SprintButton"
	button.AnchorPoint = Vector2.new(1, 1)
	button.Size = UDim2.new(0, 48, 0, 48)
	button.Position = UDim2.new(1, -24, 1, -120)
	button.BackgroundColor3 = Color3.fromRGB(28, 30, 38)
	button.BackgroundTransparency = 0.08
	button.BorderSizePixel = 1
	button.BorderColor3 = Color3.fromRGB(185, 190, 205)
	button.Text = "🏃"
	button.TextColor3 = Color3.new(1, 1, 1)
	button.TextSize = 25
	button.Font = Enum.Font.GothamBold
	button.AutoButtonColor = false
	button.ZIndex = 50
	button.Parent = screenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = button

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(235, 238, 245)
	stroke.Thickness = 1
	stroke.Transparency = 0.25
	stroke.Parent = button

	local function refreshButton()
		button.BackgroundColor3 = sprinting and Color3.fromRGB(45, 130, 75) or Color3.fromRGB(28, 30, 38)
		stroke.Color = sprinting and Color3.fromRGB(140, 255, 180) or Color3.fromRGB(235, 238, 245)
	end

	button.MouseButton1Click:Connect(function()
		setSprinting(not sprinting)
		refreshButton()
	end)

	refreshButton()
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
	if gameProcessed then return end
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		setSprinting(true)
	end
end)

UserInputService.InputEnded:Connect(function(input)
	if input.KeyCode == Enum.KeyCode.LeftShift or input.KeyCode == Enum.KeyCode.RightShift then
		setSprinting(false)
	end
end)

if player.Character then
	bindCharacter(player.Character)
end
player.CharacterAdded:Connect(bindCharacter)

createMobileSprintButton()
