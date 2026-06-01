-- src/client/UI.client.luau
-- Handles all client-side UI: roll button, DNA counter, rarity popup, upgrade shop display.
-- Never does game logic — only sends requests to server and updates display.

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Remotes
local RollVirus       = ReplicatedStorage:WaitForChild("RollVirus")
local PurchaseUpgrade = ReplicatedStorage:WaitForChild("PurchaseUpgrade")
local RebirthRequest  = ReplicatedStorage:WaitForChild("RebirthRequest")
local UpdateDNA       = ReplicatedStorage:WaitForChild("UpdateDNA")
local SyncData        = ReplicatedStorage:WaitForChild("SyncData")

-- ─── Build UI ────────────────────────────────────────────────────────────────
-- Note: In a real project Dev B would build this in Studio visually.
-- This script is the wiring layer that connects UI elements to server calls.

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "VirusRNGUI"
screenGui.ResetOnSpawn = false
screenGui.Parent = playerGui

-- DNA Counter (top center)
local dnaLabel = Instance.new("TextLabel")
dnaLabel.Name = "DNALabel"
dnaLabel.Size = UDim2.new(0, 300, 0, 50)
dnaLabel.Position = UDim2.new(0.5, -150, 0, 10)
dnaLabel.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
dnaLabel.BackgroundTransparency = 0.3
dnaLabel.TextColor3 = Color3.fromRGB(100, 255, 180)
dnaLabel.TextSize = 22
dnaLabel.Font = Enum.Font.GothamBold
dnaLabel.Text = "🧬 DNA: 0"
dnaLabel.Parent = screenGui
Instance.new("UICorner", dnaLabel).CornerRadius = UDim.new(0, 8)

-- Goop Counter
local goopLabel = Instance.new("TextLabel")
goopLabel.Name = "GoopLabel"
goopLabel.Size = UDim2.new(0, 200, 0, 40)
goopLabel.Position = UDim2.new(0.5, -100, 0, 65)
goopLabel.BackgroundColor3 = Color3.fromRGB(30, 80, 30)
goopLabel.BackgroundTransparency = 0.3
goopLabel.TextColor3 = Color3.fromRGB(150, 255, 100)
goopLabel.TextSize = 16
goopLabel.Font = Enum.Font.Gotham
goopLabel.Text = "🟢 Goop: 0"
goopLabel.Parent = screenGui
Instance.new("UICorner", goopLabel).CornerRadius = UDim.new(0, 8)

-- Roll Button (bottom center)
local rollButton = Instance.new("TextButton")
rollButton.Name = "RollButton"
rollButton.Size = UDim2.new(0, 200, 0, 70)
rollButton.Position = UDim2.new(0.5, -100, 1, -100)
rollButton.BackgroundColor3 = Color3.fromRGB(80, 0, 160)
rollButton.TextColor3 = Color3.fromRGB(255, 255, 255)
rollButton.TextSize = 24
rollButton.Font = Enum.Font.GothamBold
rollButton.Text = "🎲 ROLL"
rollButton.Parent = screenGui
Instance.new("UICorner", rollButton).CornerRadius = UDim.new(0, 12)

-- Rarity Popup (center screen, shows on rare roll)
local rarityPopup = Instance.new("Frame")
rarityPopup.Name = "RarityPopup"
rarityPopup.Size = UDim2.new(0, 400, 0, 160)
rarityPopup.Position = UDim2.new(0.5, -200, 0.4, -80)
rarityPopup.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
rarityPopup.BackgroundTransparency = 0.1
rarityPopup.Visible = false
rarityPopup.Parent = screenGui
Instance.new("UICorner", rarityPopup).CornerRadius = UDim.new(0, 16)

local popupRarity = Instance.new("TextLabel")
popupRarity.Size = UDim2.new(1, 0, 0.4, 0)
popupRarity.Position = UDim2.new(0, 0, 0.05, 0)
popupRarity.BackgroundTransparency = 1
popupRarity.TextColor3 = Color3.fromRGB(255, 220, 50)
popupRarity.TextSize = 22
popupRarity.Font = Enum.Font.GothamBold
popupRarity.Text = "LEGENDARY"
popupRarity.Parent = rarityPopup

local popupName = Instance.new("TextLabel")
popupName.Size = UDim2.new(1, 0, 0.4, 0)
popupName.Position = UDim2.new(0, 0, 0.45, 0)
popupName.BackgroundTransparency = 1
popupName.TextColor3 = Color3.fromRGB(200, 200, 200)
popupName.TextSize = 18
popupName.Font = Enum.Font.Gotham
popupName.Text = "Omega Pathogen"
popupName.Parent = rarityPopup

-- ─── Helper: format large numbers ────────────────────────────────────────────

local function formatNumber(n: number): string
	if n >= 1e12 then return string.format("%.1fT", n / 1e12)
	elseif n >= 1e9 then return string.format("%.1fB", n / 1e9)
	elseif n >= 1e6 then return string.format("%.1fM", n / 1e6)
	elseif n >= 1e3 then return string.format("%.1fK", n / 1e3)
	else return tostring(math.floor(n))
	end
end

-- ─── Rarity popup animation ──────────────────────────────────────────────────

local POPUP_THRESHOLDS = { "rare", "epic", "legendary", "mythic", "divine" }
local POPUP_THRESHOLD_SET = {}
for _, v in ipairs(POPUP_THRESHOLDS) do POPUP_THRESHOLD_SET[v] = true end

local function showRarityPopup(result: table)
	if not POPUP_THRESHOLD_SET[result.rarityId] then return end

	local color = Color3.new(result.color.r, result.color.g, result.color.b)
	rarityPopup.BackgroundColor3 = color:lerp(Color3.fromRGB(10, 10, 20), 0.7)
	popupRarity.TextColor3 = color
	popupRarity.Text = result.rarityName:upper()
	popupName.Text = result.virusName

	rarityPopup.Visible = true
	rarityPopup.BackgroundTransparency = 1

	-- Fade in
	TweenService:Create(rarityPopup, TweenInfo.new(0.3), { BackgroundTransparency = 0.1 }):Play()
	TweenService:Create(popupRarity, TweenInfo.new(0.3), { TextTransparency = 0 }):Play()

	-- Auto-hide after 3 seconds
	task.delay(3, function()
		TweenService:Create(rarityPopup, TweenInfo.new(0.5), { BackgroundTransparency = 1 }):Play()
		task.wait(0.5)
		rarityPopup.Visible = false
	end)
end

-- ─── Roll button logic ───────────────────────────────────────────────────────

local isRolling = false
local ROLL_COOLDOWN = 0.3 -- seconds between manual rolls

rollButton.MouseButton1Click:Connect(function()
	if isRolling then return end
	isRolling = true

	rollButton.Text = "Rolling..."
	rollButton.BackgroundColor3 = Color3.fromRGB(50, 0, 100)

	local result = RollVirus:InvokeServer()

	if result then
		showRarityPopup(result)
		if result.isDuplicate then
			-- brief flash to show goop gained
			rollButton.Text = "🟢 Goop!"
		else
			rollButton.Text = "✓ " .. result.rarityName
		end
	end

	task.wait(ROLL_COOLDOWN)
	rollButton.Text = "🎲 ROLL"
	rollButton.BackgroundColor3 = Color3.fromRGB(80, 0, 160)
	isRolling = false
end)

-- ─── Server event listeners ──────────────────────────────────────────────────

-- Live DNA updates every tick
UpdateDNA.OnClientEvent:Connect(function(dna: number, goop: number)
	dnaLabel.Text = "🧬 DNA: " .. formatNumber(dna)
	goopLabel.Text = "🟢 Goop: " .. formatNumber(goop)
end)

-- Full data sync (on join and after major actions)
SyncData.OnClientEvent:Connect(function(data: table)
	dnaLabel.Text = "🧬 DNA: " .. formatNumber(data.dna or 0)
	goopLabel.Text = "🟢 Goop: " .. formatNumber(data.goop or 0)
	-- TODO: Dev B wires up additional UI panels (virus index, upgrade shop, rebirth panel) here
end)

print("[VirusRNG] Client UI loaded for", player.Name)
