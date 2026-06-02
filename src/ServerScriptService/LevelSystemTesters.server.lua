-- Level System Tester Parts
-- Creates testing parts in Workspace for server-side level testing
-- Per the original Level System plan

if true then return end -- Comment this line to enable the level system tester

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Superbullet = require(ReplicatedStorage.Packages.Superbullet)

-- Wait for Superbullet to start
repeat
	task.wait()
until Superbullet.OnStart
Superbullet.OnStart():await()

-- Get LevelService
local LevelService = Superbullet.GetService("LevelService")

-- Cooldown tracking (per-player)
local playerCooldowns = {}
local COOLDOWN_TIME = 2 -- seconds

-- Helper function to check cooldown
local function isOnCooldown(player, partName)
	local playerData = playerCooldowns[player.UserId]
	if not playerData then
		playerCooldowns[player.UserId] = {}
		return false
	end

	local lastUse = playerData[partName]
	if not lastUse then
		return false
	end

	return (tick() - lastUse) < COOLDOWN_TIME
end

-- Helper function to set cooldown
local function setCooldown(player, partName)
	if not playerCooldowns[player.UserId] then
		playerCooldowns[player.UserId] = {}
	end
	playerCooldowns[player.UserId][partName] = tick()
end

-- Create tester folder
local testerFolder = workspace:FindFirstChild("LevelSystem_Testers")
if not testerFolder then
	testerFolder = Instance.new("Folder")
	testerFolder.Name = "LevelSystem_Testers"
	testerFolder.Parent = workspace
end

-- Clear existing parts
testerFolder:ClearAllChildren()

-- Tester part configurations
local testerConfigs = {
	-- Row 1 - Basic EXP (z = 0)
	{
		name = "+1_EXP",
		color = Color3.fromRGB(100, 255, 100),
		position = Vector3.new(10, 5, 0),
		action = function(player)
			LevelService:AddExp(player, 1, "levels")
			print(string.format("[LevelTester] %s gained 1 EXP", player.Name))
		end,
	},
	{
		name = "+100_EXP",
		color = Color3.fromRGB(100, 200, 255),
		position = Vector3.new(15, 5, 0),
		action = function(player)
			LevelService:AddExp(player, 100, "levels")
			print(string.format("[LevelTester] %s gained 100 EXP", player.Name))
		end,
	},
	{
		name = "+EnoughToLevel",
		color = Color3.fromRGB(255, 200, 100),
		position = Vector3.new(20, 5, 0),
		action = function(player)
			local levelData = LevelService:GetAllTypesData(player)
			if levelData and levelData.levels then
				local needed = levelData.levels.MaxExp - levelData.levels.Exp + 1
				LevelService:AddExp(player, needed, "levels")
				print(string.format("[LevelTester] %s gained %d EXP (enough to level)", player.Name, needed))
			else
				print(string.format("[LevelTester] Could not get level data for %s", player.Name))
			end
		end,
	},
	{
		name = "-1_EXP",
		color = Color3.fromRGB(255, 100, 100),
		position = Vector3.new(25, 5, 0),
		action = function(player)
			LevelService:LoseExp(player, 1, "levels")
			print(string.format("[LevelTester] %s lost 1 EXP", player.Name))
		end,
	},
	-- Row 2 - Level Management (z = 12)
	{
		name = "Reset_Level",
		color = Color3.fromRGB(255, 69, 0),
		position = Vector3.new(10, 5, 12),
		action = function(player)
			LevelService:ResetLevel(player, "levels")
			print(string.format("[LevelTester] Reset Level for %s", player.Name))
		end,
	},
	{
		name = "Set_Level_50",
		color = Color3.fromRGB(200, 100, 255),
		position = Vector3.new(15, 5, 12),
		action = function(player)
			LevelService:SetLevel(player, 50, "levels")
			print(string.format("[LevelTester] Set %s to level 50", player.Name))
		end,
	},
	{
		name = "Set_Max_Level",
		color = Color3.fromRGB(255, 0, 255),
		position = Vector3.new(20, 5, 12),
		action = function(player)
			local LevelingConfig = require(ReplicatedStorage.SharedSource.Datas.LevelingConfig)
			local maxLevel = LevelingConfig.Types.levels.MaxLevel or 100
			LevelService:SetLevel(player, maxLevel, "levels")
			print(string.format("[LevelTester] Set %s to MAX level %d", player.Name, maxLevel))
		end,
	},
	{
		name = "Show_Level_Info",
		color = Color3.fromRGB(0, 255, 255),
		position = Vector3.new(25, 5, 12),
		action = function(player)
			local levelData = LevelService:GetAllTypesData(player)
			if levelData then
				print(string.format("=== [LevelTester] Level Info for %s ===", player.Name))
				for typeName, typeData in pairs(levelData) do
					print(string.format(
						"  %s: Level %d | EXP %d/%d | MaxLevel: %s",
						typeName,
						typeData.Level,
						typeData.Exp,
						typeData.MaxExp,
						tostring(typeData.MaxLevel or "none")
					))
				end
				print("=================================")
			end
		end,
	},
}

-- Create tester parts
for _, config in pairs(testerConfigs) do
	local part = Instance.new("Part")
	part.Name = config.name
	part.Size = Vector3.new(4, 6, 4)
	part.Position = config.position
	part.Color = config.color
	part.Material = Enum.Material.SmoothPlastic
	part.Anchored = true
	part.CanCollide = true
	part.Parent = testerFolder

	local billboardGui = Instance.new("BillboardGui")
	billboardGui.Size = UDim2.new(0, 200, 0, 50)
	billboardGui.AlwaysOnTop = true
	billboardGui.Adornee = part
	billboardGui.Parent = part

	local textLabel = Instance.new("TextLabel")
	textLabel.Size = UDim2.new(1, 0, 1, 0)
	textLabel.BackgroundTransparency = 1
	textLabel.Text = config.name
	textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	textLabel.TextSize = 18
	textLabel.TextStrokeTransparency = 0
	textLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	textLabel.Font = Enum.Font.SourceSansBold
	textLabel.Parent = billboardGui

	part.Touched:Connect(function(hit)
		local humanoid = hit.Parent:FindFirstChild("Humanoid")
		if humanoid then
			local touchPlayer = Players:GetPlayerFromCharacter(hit.Parent)
			if touchPlayer then
				if isOnCooldown(touchPlayer, config.name) then
					return
				end
				setCooldown(touchPlayer, config.name)

				local success, err = pcall(config.action, touchPlayer)
				if not success then
					print(string.format("[LevelTester] Error with %s: %s", config.name, err))
				end
			end
		end
	end)
end

-- Create instruction sign
local signPart = Instance.new("Part")
signPart.Name = "Instructions"
signPart.Size = Vector3.new(8, 6, 1)
signPart.Position = Vector3.new(0, 5, 6)
signPart.Color = Color3.fromRGB(100, 100, 100)
signPart.Material = Enum.Material.Concrete
signPart.Anchored = true
signPart.CanCollide = false
signPart.Parent = testerFolder

local signGui = Instance.new("SurfaceGui")
signGui.Face = Enum.NormalId.Front
signGui.Parent = signPart

local instructionLabel = Instance.new("TextLabel")
instructionLabel.Size = UDim2.new(1, 0, 1, 0)
instructionLabel.BackgroundTransparency = 1
instructionLabel.Text = [[LEVEL SYSTEM TESTERS

Row 1 - Basic EXP (levels):
  Green: +1 EXP
  Blue: +100 EXP
  Orange: Level up amount
  Red: -1 EXP

Row 2 - Level Management:
  Orange-Red: Reset Level
  Purple: Set Level to 50
  Magenta: Set to Max Level
  Cyan: Show Level Info

2 second cooldown per player]]

instructionLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
instructionLabel.TextScaled = true
instructionLabel.Font = Enum.Font.SourceSans
instructionLabel.TextWrapped = true
instructionLabel.Parent = signGui

print("[LevelTester] Level System tester parts created in Workspace/LevelSystem_Testers")
print("[LevelTester] Touch the parts to test level functionality!")

-- Clean up cooldowns when players leave
Players.PlayerRemoving:Connect(function(player)
	playerCooldowns[player.UserId] = nil
end)
