-- LabTycoon UI Logic
-- Handles all UI interactions and updates
-- Uses direct RemoteEvents (no Superbullet dependency)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)

local VirusData = require(ReplicatedStorage.Modules.VirusData)
local LabUpgradesData = require(ReplicatedStorage.SharedSource.Datas.LabUpgradesData)

-- These are populated after Superbullet initializes (see wait block below)
local VirusController
local LabUpgradeController

local Remotes = ReplicatedStorage.LabTycoon.Remotes

print("UILogic: Script started, controllers required")

-- Get Knit controllers (non-blocking, will be nil until Knit starts)
local DataController_OK, DataController = pcall(function() return Knit:GetController("DataController") end)
DataController = DataController_OK and DataController or nil
local CurrencyController_OK, CurrencyController = pcall(function() return Knit:GetController("CurrencyController") end)
CurrencyController = CurrencyController_OK and CurrencyController or nil
local SkillTreeController_OK, SkillTreeController = pcall(function() return Knit:GetController("SkillTreeController") end)
SkillTreeController = SkillTreeController_OK and SkillTreeController or nil

local player = Players.LocalPlayer
local gui = script.Parent
local main = gui:WaitForChild("MainContainer")

-- Helper: find deep child
local function find(name, parent)
	parent = parent or main
	return parent:FindFirstChild(name, true)
end

-- Constants
local FONT_BOLD = Enum.Font.GothamBold
local FONT_MED = Enum.Font.GothamMedium
local FONT = Enum.Font.Gotham
local EquipSlotHelper = require(ReplicatedStorage.Modules.EquipSlotHelper)

local function getEffectiveSlotProfile()
	local data = DataController and DataController.Data or {}
	local profile = table.clone(data)
	local upgrades = table.clone(data.LabUpgrades or {})
	local controllerUpgrades = VirusController and VirusController.LabUpgrades or nil
	local labControllerUpgrades = LabUpgradeController and LabUpgradeController.LabUpgrades or nil
	upgrades.LabCapacityLevel = math.max(
		upgrades.LabCapacityLevel or 0,
		controllerUpgrades and controllerUpgrades.LabCapacityLevel or 0,
		labControllerUpgrades and labControllerUpgrades.LabCapacityLevel or 0
	)
	profile.LabUpgrades = upgrades
	profile.VirusSlotCount = math.max(
		type(profile.VirusSlotCount) == "number" and profile.VirusSlotCount or 1,
		VirusController and VirusController.VirusSlotCount or 1,
		LabUpgradeController and LabUpgradeController.VirusSlotCount or 1
	)
	return profile
end

local function getEffectiveMaxSlots()
	return EquipSlotHelper.GetMaxSlots(getEffectiveSlotProfile())
end

-- Currency update
local function updateCurrencies()
	if not CurrencyController then return end
	local data = DataController and DataController.Data or {}

	local cashLabel = find("CashLabel")
	local rpLabel = find("RPLabel")
	local dnaLabel = find("DNALabel")
	local rebirthLabel = find("RebirthLabel")

	if cashLabel then
		local v = cashLabel:FindFirstChild("Value")
		if v then
			v.Text = tostring(math.floor(CurrencyController:GetCurrency("cash") or 0))
		end
	end

	if rpLabel then
		local v = rpLabel:FindFirstChild("Value")
		if v then
			v.Text = tostring(math.floor(CurrencyController:GetCurrency("researchPoints") or 0))
		end
	end

	if dnaLabel then
		local v = dnaLabel:FindFirstChild("Value")
		if v then
			v.Text = tostring(math.floor(CurrencyController:GetCurrency("dnaPoints") or 0))
		end
	end

	if rebirthLabel then
		local v = rebirthLabel:FindFirstChild("Value")
		if v then
			v.Text = tostring(math.floor(CurrencyController:GetCurrency("rebirths") or 0))
		end
	end
end

-- Update stats panel
local function updateStats()
	if not VirusController then return end
	local data = DataController and DataController.Data or {}
	if not data then return end

	local sc = find("StatsContent")
	if not sc then return end

	local luckStat = sc:FindFirstChild("LuckStat")
	if luckStat then
		luckStat.Text = "Luck Bonus: +" .. string.format("%.1f", VirusController:GetLuckPercent()) .. "%"
	end

	local rpStat = sc:FindFirstChild("RPSecStat")
	if rpStat then
		rpStat.Text = "RP/sec: " .. tostring(math.floor(VirusController.TotalEarningsRP or 0))
	end

	local cashStat = sc:FindFirstChild("CashSecStat")
	if cashStat then
		cashStat.Text = "Cash/sec: $" .. tostring(math.floor(VirusController.TotalEarningsCash or 0))
	end

	local rollsStat = sc:FindFirstChild("TotalRollsStat")
	if rollsStat then
		rollsStat.Text = "Total Rolls: " .. tostring(data.TotalRolls or 0)
	end

	local virusStat = sc:FindFirstChild("VirusCountStat")
	if virusStat then
		virusStat.Text = "Viruses: " .. tostring(#(data.VirusInventory or {}))
	end

	local rbMult = sc:FindFirstChild("RebirthMultStat")
	if rbMult then
		rbMult.Text = string.format("Rebirth Mult: %.2fx", data.RebirthLuckMultiplier or 1)
	end
end

-- Update virus slots display
local function updateSlots()
	if not VirusController then return end
	local slotCount = math.min(getEffectiveMaxSlots(), 10)
	local slots = VirusController.VirusSlots or {}

	for i = 1, 10 do
		local slot = find("Slot" .. i)
		if not slot then continue end

		local icon = slot:FindFirstChild("VirusIcon")
		local claimBtn = slot:FindFirstChild("ClaimButton")
		local numLbl = slot:FindFirstChild("SlotNumber")

		slot.Visible = (i <= slotCount)

		if i <= slotCount then
			local virusName = slots[i]
			if virusName then
				if icon then
					local vd = VirusData.GetVirusByName(virusName)
					if vd then
						local td = VirusData.GetTierData(vd.Tier)
						icon.TextColor3 = td and td.Color or Color3.new(1,1,1)
					end
				end
				if claimBtn then claimBtn.Visible = false end
				if numLbl then numLbl.Text = virusName end
				slot.BackgroundColor3 = Color3.fromRGB(40, 60, 40)
				slot.BorderColor3 = Color3.fromRGB(60, 120, 60)
			else
				if icon then icon.TextColor3 = Color3.new(1,1,1) end
				if numLbl then numLbl.Text = "Slot " .. i end
				slot.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
				slot.BorderColor3 = Color3.fromRGB(60, 60, 80)

				if VirusController.LastRollResult and claimBtn then
					claimBtn.Visible = true
				elseif claimBtn then
					claimBtn.Visible = false
				end
			end
		end
	end
end

-- Update upgrade displays
local function updateUpgrades()
	if not VirusController then return end
	local upgrades = VirusController.LabUpgrades or {}

	-- Incubator
	local incubatorFrame = find("Incubator")
	if incubatorFrame then
		local lvl = incubatorFrame:FindFirstChild("Level")
		local btn = incubatorFrame:FindFirstChild("BuyButton")
		if btn then
			local level = upgrades.IncubatorLevel or 0
			if lvl then lvl.Text = "Level: " .. level .. " / 50 (+ " .. string.format("%.0f", level * 5) .. "% luck)" end
			local cost = LabUpgradesData.GetUpgradeCost("Incubator", level)
			if level >= 50 then
				btn.Text = "MAXED"
				btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			else
				btn.Text = "Buy (" .. tostring(cost) .. " RP)"
			end
		end
	end

	-- Sterile Conditions
	local sterileFrame = find("SterileConditions")
	if sterileFrame then
		local lvl = sterileFrame:FindFirstChild("Level")
		local btn = sterileFrame:FindFirstChild("BuyButton")
		if btn then
			local level = upgrades.SterileConditionsLevel or 0
			if lvl then lvl.Text = "Level: " .. level .. " / 30 (+ " .. string.format("%.0f", level * 2) .. "% RP)" end
			local cost = LabUpgradesData.GetUpgradeCost("SterileConditions", level)
			if level >= 30 then
				btn.Text = "MAXED"
				btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			else
				btn.Text = "Buy (" .. tostring(cost) .. " RP)"
			end
		end
	end

	-- Auto Roll
	local autoFrame = find("AutoRoll")
	if autoFrame then
		local lvl = autoFrame:FindFirstChild("Level")
		local btn = autoFrame:FindFirstChild("BuyButton")
		if btn then
			local level = upgrades.AutoRollLevel or 0
			if lvl then lvl.Text = "Level: " .. level .. " / 20 (every " .. string.format("%.1f", LabUpgradesData.GetAutoRollInterval(upgrades)) .. "s)" end
			local cost = LabUpgradesData.GetUpgradeCost("AutoRoll", level)
			if level >= 20 then
				btn.Text = "MAXED"
				btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			else
				btn.Text = "Buy (" .. tostring(cost) .. " RP)"
			end
		end
	end

	-- Quick Roll
	local quickFrame = find("QuickRoll")
	if quickFrame then
		local lvl = quickFrame:FindFirstChild("Level")
		local btn = quickFrame:FindFirstChild("BuyButton")
		if btn then
			local level = upgrades.QuickRollLevel or 0
			if lvl then 
				local currentCooldown = LabUpgradesData.GetRollCooldown(upgrades)
				lvl.Text = "Level: " .. level .. " / 20 (cooldown: " .. string.format("%.1f", currentCooldown) .. "s)" 
			end
			local cost = LabUpgradesData.GetUpgradeCost("QuickRoll", level)
			if level >= 20 then
				btn.Text = "MAXED"
				btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
			else
				btn.Text = "Buy (" .. tostring(cost) .. " RP)"
			end
		end
	end

	-- Slot purchase
	local slotFrame = find("VirusSlot")
	if slotFrame then
		local current = slotFrame:FindFirstChild("Current")
		local btn = slotFrame:FindFirstChild("BuyButton")
		if current then
			current.Text = "Terrain Chambers: " .. tostring(math.min(getEffectiveMaxSlots(), 10)) .. " / 10"
		end
		if btn then
			local profile = getEffectiveSlotProfile()
			local level = (profile.LabUpgrades and profile.LabUpgrades.LabCapacityLevel) or 0
			local legacyLevel = math.max(0, (tonumber(profile.VirusSlotCount) or 1) - 1)
			level = math.max(level, legacyLevel)
			local cost = LabUpgradesData.GetUpgradeCost("LabCapacity", level)
			if level < LabUpgradesData.LabCapacity.MaxLevel and cost then
				btn.Text = "Buy (" .. tostring(cost) .. " RP)"
				btn.Active = true
			else
				btn.Text = "MAXED"
				btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
				btn.Active = false
			end
		end
	end

	-- Auto-roll toggle
	local arf = find("AutoRollToggle")
	if arf then
		local lbl = arf:FindFirstChild("Label")
		local btn = arf:FindFirstChild("ToggleButton")
		local autoRollLevel = upgrades.AutoRollLevel or 0
		if autoRollLevel < 1 then
			if lbl then lbl.Text = "Auto Roll: Buy upgrade first!" end
			if btn then
				btn.Text = "LOCKED"
				btn.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
				btn.Active = false
			end
		else
			local enabled = VirusController.AutoRollEnabled or false
			if lbl then lbl.Text = "Auto Roll: " .. (enabled and "Enabled" or "Disabled") end
			if btn then
				btn.Text = enabled and "DISABLE" or "ENABLE"
				btn.BackgroundColor3 = enabled and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(0, 150, 50)
				btn.Active = true
			end
		end
	end
end

-- Update rebirth display
local function updateRebirth()
	local data = DataController and DataController.Data or {}
	if not data then return end

	local currentRebirths = data.RebirthCount or 0

	-- Exponential cost: $1,000,000 * 1.5^rebirths
	local cost = math.floor(1000000 * (1.5 ^ currentRebirths))

	-- Luck after next rebirth: 1 + 0.1*R + 0.2*sqrt(R)
	local nextR = currentRebirths + 1
	local nextLuck = 1 + (0.1 * nextR) + (0.2 * math.sqrt(nextR))

	local multLbl = find("Multiplier")
	if multLbl then
		local currentLuck = data.RebirthLuckMultiplier or 1
		multLbl.Text = string.format("Current Luck Multiplier: %.2fx", currentLuck)
	end

	local countLbl = find("Count")
	if countLbl then
		countLbl.Text = "Total Rebirths: " .. tostring(currentRebirths)
	end

	local btn = find("RebirthButton")
	if btn then
		local cash = CurrencyController and CurrencyController:GetCurrency("cash") or 0
		local costStr
		if cost >= 1000000 then
			costStr = string.format("$%.2fM", cost / 1000000)
		else
			costStr = "$" .. tostring(cost)
		end
		btn.Text = string.format("REBIRTH (%s)\nNext Luck: %.2fx", costStr, nextLuck)
		btn.BackgroundColor3 = cash >= cost and Color3.fromRGB(200, 50, 50) or Color3.fromRGB(80, 40, 40)
	end
end

local lastRolledVirusData = nil

local function updateCompactVirusDisplay(virusData)
	local compactUI = gui:FindFirstChild("CompactUI")
	if not compactUI then return end

	local compactRollBtn = compactUI:FindFirstChild("CompactRollButton")
	if not compactRollBtn then return end

	local virusFrame = compactUI:FindFirstChild("CompactVirusDisplay")
	if not virusData then
		if virusFrame then virusFrame.Visible = false end
		return
	end

	local tierData = VirusData.GetTierData(virusData.Tier)
	local tierColor = tierData and tierData.Color or Color3.new(1,1,1)

	if not virusFrame then
		virusFrame = Instance.new("Frame")
		virusFrame.Name = "CompactVirusDisplay"
		virusFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
		virusFrame.BorderSizePixel = 1
		virusFrame.ZIndex = compactRollBtn.ZIndex
		virusFrame.Parent = compactUI
		Instance.new("UICorner", virusFrame).CornerRadius = UDim.new(0, 6)

		local iconLbl = Instance.new("TextLabel")
		iconLbl.Name = "VirusIcon"
		iconLbl.BackgroundTransparency = 1
		iconLbl.Text = "V"
		iconLbl.TextSize = 18
		iconLbl.Font = FONT_BOLD
		iconLbl.TextXAlignment = Enum.TextXAlignment.Center
		iconLbl.TextYAlignment = Enum.TextYAlignment.Center
		iconLbl.ZIndex = virusFrame.ZIndex + 1
		iconLbl.Parent = virusFrame

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Name = "VirusName"
		nameLbl.BackgroundTransparency = 1
		nameLbl.TextSize = 12
		nameLbl.Font = FONT_BOLD
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.TextYAlignment = Enum.TextYAlignment.Center
		nameLbl.TextScaled = true
		nameLbl.TextWrapped = true
		nameLbl.ZIndex = virusFrame.ZIndex + 1
		nameLbl.Parent = virusFrame

		local textSizeLimit = Instance.new("UITextSizeConstraint")
		textSizeLimit.MaxTextSize = 12
		textSizeLimit.MinTextSize = 8
		textSizeLimit.Parent = nameLbl

		local rarityLbl = Instance.new("TextLabel")
		rarityLbl.Name = "VirusRarity"
		rarityLbl.BackgroundTransparency = 1
		rarityLbl.TextSize = 10
		rarityLbl.Font = FONT_MED
		rarityLbl.TextXAlignment = Enum.TextXAlignment.Left
		rarityLbl.TextYAlignment = Enum.TextYAlignment.Center
		rarityLbl.TextScaled = true
		rarityLbl.TextWrapped = true
		rarityLbl.ZIndex = virusFrame.ZIndex + 1
		rarityLbl.Parent = virusFrame

		local raritySizeLimit = Instance.new("UITextSizeConstraint")
		raritySizeLimit.MaxTextSize = 10
		raritySizeLimit.MinTextSize = 7
		raritySizeLimit.Parent = rarityLbl
	end

	virusFrame.AnchorPoint = compactRollBtn.AnchorPoint
	virusFrame.Size = compactRollBtn.Size
	virusFrame.Position = UDim2.new(
		compactRollBtn.Position.X.Scale,
		compactRollBtn.Position.X.Offset,
		compactRollBtn.Position.Y.Scale - compactRollBtn.Size.Y.Scale,
		compactRollBtn.Position.Y.Offset - compactRollBtn.Size.Y.Offset
	)
	virusFrame.BorderColor3 = tierColor
	virusFrame.Visible = true

	local iconLbl = virusFrame:FindFirstChild("VirusIcon")
	if iconLbl then
		iconLbl.Size = UDim2.new(0, 30, 1, 0)
		iconLbl.Position = UDim2.new(0, 4, 0, 0)
		iconLbl.TextColor3 = tierColor
	end

	local nameLbl = virusFrame:FindFirstChild("VirusName")
	if nameLbl then
		nameLbl.Size = UDim2.new(1, -40, 0.5, -1)
		nameLbl.Position = UDim2.new(0, 36, 0, 2)
		nameLbl.Text = virusData.Name
		nameLbl.TextColor3 = tierColor
	end

	local rarityLbl = virusFrame:FindFirstChild("VirusRarity")
	if rarityLbl then
		rarityLbl.Size = UDim2.new(1, -40, 0.5, -3)
		rarityLbl.Position = UDim2.new(0, 36, 0.5, 0)
		rarityLbl.Text = virusData.Tier .. " | 1 in " .. tostring(math.floor(1/virusData.NumericalRarity))
		rarityLbl.TextColor3 = tierColor:Lerp(Color3.new(1,1,1), 0.25)
	end
end

-- Display roll result
local function showRollResult(virusData)
	if not virusData then return end
	lastRolledVirusData = virusData

	local display = find("VirusDisplay")
	if not display then return end

	local nameLbl = display:FindFirstChild("VirusName")
	local descLbl = display:FindFirstChild("VirusDescription")
	local rarityLbl = display:FindFirstChild("VirusRarity")
	local rewardLbl = display:FindFirstChild("VirusRewards")

	local tierData = VirusData.GetTierData(virusData.Tier)
	local tierColor = tierData and tierData.Color or Color3.new(1,1,1)

	if nameLbl then
		nameLbl.Text = virusData.Name
		nameLbl.TextColor3 = tierColor
	end
	if descLbl then
		descLbl.Text = virusData.Description
	end
	if rarityLbl then
		rarityLbl.Text = "[" .. virusData.Tier .. "]"
		rarityLbl.TextColor3 = tierColor
	end
	if rewardLbl then
		rewardLbl.Text = "DNA: +" .. (virusData.DNAPoints or 0) .. " | RP: +" .. (virusData.ResearchPoints or 0) .. " | $" .. (virusData.Cash or 0) .. " | 1 in " .. tostring(math.floor(1/virusData.NumericalRarity))
	end

	local rollBtn = find("RollButton")
	if rollBtn then
		rollBtn.Text = "ROLL AGAIN"
	end

	updateCompactVirusDisplay(virusData)
	updateSlots()
end

-- ============================================================================
-- Wait for profile data before connecting UI
-- ============================================================================

-- Wait for Knit to be ready and profile loaded
print("UILogic: waiting for DataController.Data...")

-- Wait for Superbullet client to finish initializing before requiring controllers
local SuperbulletModule = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Superbullet")
if not SuperbulletModule:GetAttribute("SuperbulletClient_Initialized") then
	repeat task.wait(0.1) until SuperbulletModule:GetAttribute("SuperbulletClient_Initialized")
end

-- Now safe to require controllers
VirusController = require(ReplicatedStorage.ClientSource.Client.VirusController)
LabUpgradeController = require(ReplicatedStorage.ClientSource.Client.LabUpgradeController)

-- Wire VirusController data updates through ProfileService (the reliable path)
local ok_ps, ProfileService = pcall(function() return Knit.GetService("ProfileService") end)
if ok_ps and ProfileService then
	VirusController:ConnectToDataUpdates(ProfileService)
end

-- Re-fetch Knit controllers now that Superbullet is ready
local ok1, dc = pcall(function() return Knit.GetController("DataController") end)
DataController = ok1 and dc or DataController
local ok2, cc = pcall(function() return Knit.GetController("CurrencyController") end)
CurrencyController = ok2 and cc or CurrencyController
local ok3, sc = pcall(function() return Knit.GetController("SkillTreeController") end)
SkillTreeController = ok3 and sc or SkillTreeController

-- Wait until profile data is loaded
if DataController and DataController.WaitUntilProfileLoaded then
	DataController:WaitUntilProfileLoaded()
else
	repeat task.wait(0.5) until DataController and DataController.Data
end

-- Initialize from profile
VirusController:RefreshFromProfile()
LabUpgradeController:RefreshFromProfile()

print("UILogic: Profile loaded, initializing UI")

-- ============================================================================
-- CONNECTIONS
-- ============================================================================

-- ============================================================================
-- VIRUSES PAGE
-- ============================================================================

local virusSortBestFirst = true
local virusTooltip = nil

local TIER_ORDER = {
	Transcendent = 8, Celestial = 7, Mythic = 6,
	Legendary = 5, Epic = 4, Rare = 3, Uncommon = 2, Common = 1
}

local function cleanSortNumber(value)
	local n = tonumber(value) or 0
	if n ~= n then return 0 end
	return n
end

local function getVirusSortScore(vd)
	return cleanSortNumber(vd.ResearchPoints), cleanSortNumber(vd.Cash), cleanSortNumber(vd.DNAPoints), cleanSortNumber(TIER_ORDER[vd.Tier])
end

local function destroyTooltip()
	if virusTooltip then
		virusTooltip:Destroy()
		virusTooltip = nil
	end
end

local function showVirusTooltip(parentGui, vd, td, x, y)
	destroyTooltip()
	local tip = Instance.new("Frame")
	tip.Name = "VirusTooltip"
	tip.Size = UDim2.new(0, 200, 0, 120)
	tip.Position = UDim2.new(0, x + 12, 0, y - 10)
	tip.BackgroundColor3 = Color3.fromRGB(15, 15, 30)
	tip.BorderSizePixel = 1
	tip.BorderColor3 = td and td.Color or Color3.new(1,1,1)
	tip.ZIndex = 20
	tip.Parent = parentGui
	Instance.new("UICorner", tip).CornerRadius = UDim.new(0, 6)

	local lines = {
		{text = vd.Name, color = td and td.Color or Color3.new(1,1,1), bold = true},
		{text = "[" .. vd.Tier .. "]", color = td and td.Color or Color3.new(0.8,0.8,0.8)},
		{text = vd.Description, color = Color3.fromRGB(200,200,200), wrap = true},
		{text = "RP/s: " .. tostring(vd.ResearchPoints), color = Color3.fromRGB(100,200,255)},
		{text = "Cash/s: $" .. tostring(vd.Cash), color = Color3.fromRGB(100,255,100)},
		{text = "DNA: " .. tostring(vd.DNAPoints), color = Color3.fromRGB(255,215,0)},
		{text = "Rarity: 1 in " .. tostring(math.floor(1/vd.NumericalRarity)), color = Color3.fromRGB(255, 255, 100)},
	}
	local yOff = 6
	for _, line in ipairs(lines) do
		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -10, 0, line.wrap and 30 or 16)
		lbl.Position = UDim2.new(0, 5, 0, yOff)
		lbl.BackgroundTransparency = 1
		lbl.Text = line.text
		lbl.TextColor3 = line.color
		lbl.TextSize = line.bold and 13 or 11
		lbl.Font = line.bold and FONT_BOLD or FONT
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextWrapped = line.wrap or false
		lbl.ZIndex = 21
		lbl.Parent = tip
		yOff += lbl.Size.Y.Offset + 3
	end
	tip.Size = UDim2.new(0, 200, 0, yOff + 6)
	virusTooltip = tip
end

local function getLocalMaxSlots()
	return getEffectiveMaxSlots()
end

local function countLocalEquipped(equipped)
	local total = 0
	for _, c in pairs(equipped) do total += c end
	return total
end

local slotCounterLabel = nil -- updated by rebuildVirusList
local selectedChamberSlot = 1
local rebuildVirusList

local function getSlotAssignment(slotMap, index)
	if typeof(slotMap) ~= "table" then return nil end
	local virusName = slotMap[index] or slotMap[tostring(index)]
	return type(virusName) == "string" and virusName or nil
end

local function hasSlotAssignments(slotMap)
	if typeof(slotMap) ~= "table" then return false end
	for i = 1, 10 do
		if getSlotAssignment(slotMap, i) then
			return true
		end
	end
	return false
end

local function buildFallbackSlotsFromEquipped(equipped, maxSlots)
	local terrainSlots = math.min(maxSlots, 10)
	local entries = {}
	for virusName, count in pairs(equipped or {}) do
		local vd = VirusData.GetVirusByName(virusName)
		if vd then
			local score = (vd.ResearchPoints or 0) * 1000000 + (vd.Cash or 0) * 1000 + (vd.DNAPoints or 0)
			for _ = 1, tonumber(count) or 0 do
				table.insert(entries, {name = virusName, score = score})
			end
		end
	end
	table.sort(entries, function(a, b)
		if a.score ~= b.score then return a.score > b.score end
		return a.name < b.name
	end)
	local slots = {}
	for i, entry in ipairs(entries) do
		if i > terrainSlots then break end
		slots[i] = entry.name
	end
	return slots
end

local function updateChamberSelector(maxSlots, equippedSlots)
	local virusesPage = find("VirusesPage")
	if not virusesPage then return end
	local selector = virusesPage:FindFirstChild("ChamberSelector")
	if not selector then return end

	local terrainSlots = math.min(maxSlots, 10)
	selectedChamberSlot = math.clamp(selectedChamberSlot, 1, math.max(terrainSlots, 1))

	for _, child in ipairs(selector:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local buttonWidth = 96
	for i = 1, terrainSlots do
		local virusName = getSlotAssignment(equippedSlots, i)
		local selected = i == selectedChamberSlot
		local btn = Instance.new("TextButton")
		btn.Name = "Chamber" .. i
		btn.Size = UDim2.new(0, buttonWidth - 6, 1, -4)
		btn.Position = UDim2.new(0, (i - 1) * buttonWidth, 0, 2)
		btn.BackgroundColor3 = selected and Color3.fromRGB(57, 161, 255) or Color3.fromRGB(28, 40, 66)
		btn.BorderSizePixel = 0
		btn.Text = "Chamber " .. i .. "\n" .. (virusName or "Empty")
		btn.TextColor3 = Color3.new(1, 1, 1)
		btn.TextSize = 10
		btn.TextWrapped = true
		btn.Font = selected and FONT_BOLD or FONT_MED
		btn.ZIndex = 6
		btn.Parent = selector
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
		btn.MouseButton1Click:Connect(function()
			selectedChamberSlot = i
			if rebuildVirusList then
				rebuildVirusList()
			end
		end)
	end

	if selector:IsA("ScrollingFrame") then
		selector.CanvasSize = UDim2.new(0, math.max(terrainSlots * buttonWidth, selector.AbsoluteSize.X), 0, 0)
	end
end

rebuildVirusList = function()
	local vl = find("VirusList")
	if not vl then return end

	for _, c in ipairs(vl:GetChildren()) do
		if c:IsA("Frame") or c:IsA("TextButton") then c:Destroy() end
	end
	destroyTooltip()

	local data = DataController and DataController.Data or {}
	local inv = data.VirusInventory or {}
	local equipped = data.EquippedViruses or {}
	local equippedSlots = data.EquippedVirusSlots or {}
	local maxSlots = getLocalMaxSlots()
	if not hasSlotAssignments(equippedSlots) then
		equippedSlots = buildFallbackSlotsFromEquipped(equipped, maxSlots)
	end
	local terrainSlots = math.min(maxSlots, 10)
	local usedSlots = countLocalEquipped(equipped)
	selectedChamberSlot = math.clamp(selectedChamberSlot, 1, math.max(terrainSlots, 1))
	local selectedSlotVirus = getSlotAssignment(equippedSlots, selectedChamberSlot)
	updateChamberSelector(maxSlots, equippedSlots)

	-- Update slot counter label if it exists
	if slotCounterLabel then
		slotCounterLabel.Text = "Slots: " .. usedSlots .. " / " .. maxSlots
		slotCounterLabel.TextColor3 = usedSlots >= maxSlots
			and Color3.fromRGB(255, 100, 100)
			or  Color3.fromRGB(150, 255, 150)
	end

	local counts = {}
	for _, vn in ipairs(inv) do
		counts[vn] = (counts[vn] or 0) + 1
	end

	local sorted = {}
	local insertIndex = 0
	for virusName, count in pairs(counts) do
		local vd = VirusData.GetVirusByName(virusName)
		if vd then
			insertIndex += 1
			local rp, cash, dna, tier = getVirusSortScore(vd)
			table.insert(sorted, {
				name = virusName,
				count = count,
				vd = vd,
				sortIndex = insertIndex,
				sortScore = rp * 1000000000 + cash * 1000000 + dna * 1000 + tier,
			})
		end
	end
	table.sort(sorted, function(a, b)
		if a.sortScore ~= b.sortScore then
			if virusSortBestFirst then
				return a.sortScore > b.sortScore
			end
			return a.sortScore < b.sortScore
		end

		if a.name ~= b.name then
			return a.name < b.name
		end

		return a.sortIndex < b.sortIndex
	end)

	local ROW_H = 38
	local y = 0
	for _, entry in ipairs(sorted) do
		local virusName = entry.name
		local count = entry.count
		local vd = entry.vd
		local td = VirusData.GetTierData(vd.Tier)
		local tierColor = td and td.Color or Color3.new(1,1,1)
		local equippedCount = equipped[virusName] or 0
		local selectedContainsThis = selectedSlotVirus == virusName
		local selectedSlotIsFilled = selectedSlotVirus ~= nil
		local canAssignToSelected = selectedChamberSlot <= terrainSlots and (selectedContainsThis or equippedCount < count) and (selectedSlotIsFilled or usedSlots < terrainSlots)

		local row = Instance.new("Frame")
		row.Name = "VirusRow_" .. virusName
		row.Size = UDim2.new(1, -10, 0, ROW_H)
		row.Position = UDim2.new(0, 5, 0, y)
		row.BackgroundColor3 = equippedCount > 0
			and Color3.fromRGB(20, 40, 20)
			or  Color3.fromRGB(25, 25, 40)
		row.BorderSizePixel = 0
		row.Parent = vl
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 4)

		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(0, 4, 1, 0)
		bar.BackgroundColor3 = tierColor
		bar.BorderSizePixel = 0
		bar.Parent = row
		Instance.new("UICorner", bar).CornerRadius = UDim.new(0, 4)

		local nameLbl = Instance.new("TextLabel")
		nameLbl.Size = UDim2.new(0, 155, 1, 0)
		nameLbl.Position = UDim2.new(0, 10, 0, 0)
		nameLbl.BackgroundTransparency = 1
		nameLbl.Text = virusName .. (count > 1 and (" x"..count) or "")
		nameLbl.TextColor3 = tierColor
		nameLbl.TextSize = 12
		nameLbl.Font = FONT_MED
		nameLbl.TextXAlignment = Enum.TextXAlignment.Left
		nameLbl.Parent = row

		if equippedCount > 0 then
			local badge = Instance.new("TextLabel")
			badge.Size = UDim2.new(0, 60, 0, 14)
			badge.Position = UDim2.new(0, 10, 0.5, -7)
			badge.BackgroundColor3 = Color3.fromRGB(0, 160, 60)
			badge.BorderSizePixel = 0
			badge.Text = "EQUIPPED" .. (equippedCount > 1 and (" x"..equippedCount) or "")
			badge.TextColor3 = Color3.new(1,1,1)
			badge.TextSize = 9
			badge.Font = FONT_BOLD
			badge.ZIndex = 3
			badge.Parent = row
			Instance.new("UICorner", badge).CornerRadius = UDim.new(0, 3)
			nameLbl.Position = UDim2.new(0, 76, 0, 0)
			nameLbl.Size = UDim2.new(0, 90, 1, 0)
		end

		local btnW = 54
		local unequipBtn = Instance.new("TextButton")
		unequipBtn.Name = "ClearButton"
		unequipBtn.Size = UDim2.new(0, btnW, 0, 22)
		unequipBtn.Position = UDim2.new(1, -(btnW*2 + 8), 0.5, -11)
		local canUnequip = equippedCount > 0
		unequipBtn.BackgroundColor3 = canUnequip and Color3.fromRGB(180,50,50) or Color3.fromRGB(60,60,60)
		unequipBtn.Text = selectedContainsThis and "Clear" or "Remove"
		unequipBtn.TextColor3 = Color3.new(1,1,1)
		unequipBtn.TextSize = 11
		unequipBtn.Font = FONT_MED
		unequipBtn.Active = canUnequip
		unequipBtn.AutoButtonColor = canUnequip
		unequipBtn.Parent = row
		Instance.new("UICorner", unequipBtn).CornerRadius = UDim.new(0, 4)

		local equipBtn = Instance.new("TextButton")
		equipBtn.Name = "ShowButton"
		equipBtn.Size = UDim2.new(0, btnW, 0, 22)
		equipBtn.Position = UDim2.new(1, -(btnW + 4), 0.5, -11)
		equipBtn.BackgroundColor3 = selectedContainsThis and Color3.fromRGB(57,161,255) or (canAssignToSelected and Color3.fromRGB(0,140,60) or Color3.fromRGB(60,60,60))
		equipBtn.Text = selectedContainsThis and "Shown" or (canAssignToSelected and (selectedSlotIsFilled and "Replace" or "Show") or (usedSlots >= terrainSlots and "Full" or "Max"))
		equipBtn.TextColor3 = Color3.new(1,1,1)
		equipBtn.TextSize = 11
		equipBtn.Font = FONT_MED
		equipBtn.Active = canAssignToSelected and not selectedContainsThis
		equipBtn.AutoButtonColor = canAssignToSelected and not selectedContainsThis
		equipBtn.Parent = row
		Instance.new("UICorner", equipBtn).CornerRadius = UDim.new(0, 4)

		equipBtn.MouseButton1Click:Connect(function()
			if not canAssignToSelected or selectedContainsThis then return end
			Remotes.EquipVirus:FireServer(virusName, selectedChamberSlot)
			task.wait(0.15)
			rebuildVirusList()
		end)
		unequipBtn.MouseButton1Click:Connect(function()
			if not canUnequip then return end
			Remotes.UnequipVirus:FireServer(virusName, selectedContainsThis and selectedChamberSlot or nil)
			task.wait(0.15)
			rebuildVirusList()
		end)

		row.MouseEnter:Connect(function()
			local absPos = row.AbsolutePosition
			showVirusTooltip(gui, vd, td, absPos.X + row.AbsoluteSize.X, absPos.Y)
		end)
		row.MouseLeave:Connect(function() destroyTooltip() end)

		y += ROW_H + 4
	end

	if vl:IsA("ScrollingFrame") then
		vl.CanvasSize = UDim2.new(0, 0, 0, y + 8)
	end
end

-- Listen for server equipment changes
Remotes.EquipmentChanged.OnClientEvent:Connect(function(newEquipped, newSlots, newLabUpgrades)
	local data = DataController and DataController.Data or {}
	data.EquippedViruses = newEquipped
	if typeof(newSlots) == "table" then
		data.EquippedVirusSlots = newSlots
	end
	if typeof(newLabUpgrades) == "table" then
		data.LabUpgrades = newLabUpgrades
		if VirusController then
			VirusController.LabUpgrades = newLabUpgrades
		end
		if LabUpgradeController then
			LabUpgradeController.LabUpgrades = newLabUpgrades
		end
	end
	rebuildVirusList()
	updateSlots()
	updateUpgrades()
	updateStats()
end)

-- Tab switching
local tabBar = find("TabBar")
if tabBar then
	local pages = {
		["CultivateTab"] = "CultivatePage",
		["VirusesTab"] = "VirusesPage",
		["Lab UpgradesTab"] = "UpgradesPage",
		["DNA TreeTab"] = "DNATreePage",
		["RebirthTab"] = "RebirthPage",
	}

	for _, btn in ipairs(tabBar:GetChildren()) do
		if btn:IsA("TextButton") then
			btn.MouseButton1Click:Connect(function()
				local ca = find("ContentArea")
				if ca then
					for _, child in ipairs(ca:GetChildren()) do
						if child:IsA("Frame") then
							child.Visible = false
						end
					end
				end

				local pageName = pages[btn.Name]
				if pageName then
					local page = find(pageName)
					if page then page.Visible = true end
				end

				for _, tb in ipairs(tabBar:GetChildren()) do
					if tb:IsA("TextButton") then
						tb.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
					end
				end
				btn.BackgroundColor3 = Color3.fromRGB(60, 60, 100)

				updateSlots()
				updateUpgrades()
				updateRebirth()
				updateStats()

				if btn.Name == "VirusesTab" then
					rebuildVirusList()
				end

				if btn.Name == "DNA TreeTab" then
					-- DNA TreeTab click does NOT auto-open the tree.
					-- User must click the OpenTreeButton on the tab to open it.
				end
			end)
		end
	end
end

-- Inject toolbar buttons into VirusesPage (sort, chamber counter, auto-fill)
local virusesPage = find("VirusesPage")
if virusesPage then
	local title = virusesPage:FindFirstChild("Title")
	if title and title:IsA("TextLabel") then
		title.Text = "Plot Chamber Display"
	end

	if not virusesPage:FindFirstChild("ChamberHint") then
		local hint = Instance.new("TextLabel")
		hint.Name = "ChamberHint"
		hint.Size = UDim2.new(1, -20, 0, 34)
		hint.Position = UDim2.new(0, 10, 0, 34)
		hint.BackgroundTransparency = 1
		hint.Text = "Pick a chamber slot, then show or replace the virus that appears on that chamber in your plot."
		hint.TextColor3 = Color3.fromRGB(154, 171, 198)
		hint.TextSize = 12
		hint.Font = FONT_MED
		hint.TextWrapped = true
		hint.TextXAlignment = Enum.TextXAlignment.Left
		hint.ZIndex = 5
		hint.Parent = virusesPage
	end
end
if virusesPage and not virusesPage:FindFirstChild("SortToggleBtn") then
	-- Sort toggle
	local sortBtn = Instance.new("TextButton")
	sortBtn.Name = "SortToggleBtn"
	sortBtn.Size = UDim2.new(0, 168, 0, 28)
	sortBtn.Position = UDim2.new(1, -178, 0, 154)
	sortBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 80)
	sortBtn.Text = "Sort: Best > Worst"
	sortBtn.TextColor3 = Color3.new(1,1,1)
	sortBtn.TextSize = 11
	sortBtn.Font = FONT_MED
	sortBtn.ZIndex = 5
	sortBtn.Parent = virusesPage
	Instance.new("UICorner", sortBtn).CornerRadius = UDim.new(0, 4)
	sortBtn.MouseButton1Click:Connect(function()
		virusSortBestFirst = not virusSortBestFirst
		sortBtn.Text = virusSortBestFirst and "Sort: Best > Worst" or "Sort: Worst > Best"
		rebuildVirusList()
	end)

	-- Auto-fill best viruses into plot chambers
	local autoBtn = Instance.new("TextButton")
	autoBtn.Name = "AutoEquipBtn"
	autoBtn.Size = UDim2.new(0, 168, 0, 30)
	autoBtn.Position = UDim2.new(1, -178, 0, 118)
	autoBtn.BackgroundColor3 = Color3.fromRGB(0, 120, 180)
	autoBtn.Text = "Auto-Fill Chambers"
	autoBtn.TextColor3 = Color3.new(1,1,1)
	autoBtn.TextSize = 11
	autoBtn.Font = FONT_BOLD
	autoBtn.ZIndex = 5
	autoBtn.Parent = virusesPage
	Instance.new("UICorner", autoBtn).CornerRadius = UDim.new(0, 4)
	autoBtn.MouseButton1Click:Connect(function()
		Remotes.AutoEquipBest:FireServer()
		task.wait(0.2)
		rebuildVirusList()
	end)

	-- Terrain chamber selector
	local chamberSelector = Instance.new("ScrollingFrame")
	chamberSelector.Name = "ChamberSelector"
	chamberSelector.Size = UDim2.new(1, -20, 0, 40)
	chamberSelector.Position = UDim2.new(0, 10, 0, 74)
	chamberSelector.BackgroundColor3 = Color3.fromRGB(12, 18, 32)
	chamberSelector.BackgroundTransparency = 0.08
	chamberSelector.BorderSizePixel = 0
	chamberSelector.ScrollBarThickness = 3
	chamberSelector.ScrollingDirection = Enum.ScrollingDirection.X
	chamberSelector.VerticalScrollBarInset = Enum.ScrollBarInset.None
	chamberSelector.HorizontalScrollBarInset = Enum.ScrollBarInset.None
	chamberSelector.ZIndex = 5
	chamberSelector.Parent = virusesPage
	Instance.new("UICorner", chamberSelector).CornerRadius = UDim.new(0, 6)

	-- Slot counter label
	local slotLbl = Instance.new("TextLabel")
	slotLbl.Name = "SlotCounterLabel"
	slotLbl.Size = UDim2.new(0, 140, 0, 26)
	slotLbl.Position = UDim2.new(0, 10, 0, 126)
	slotLbl.BackgroundTransparency = 1
	slotLbl.Text = "Slots: 0 / 5"
	slotLbl.TextColor3 = Color3.fromRGB(150, 255, 150)
	slotLbl.TextSize = 12
	slotLbl.Font = FONT_BOLD
	slotLbl.TextXAlignment = Enum.TextXAlignment.Left
	slotLbl.ZIndex = 5
	slotLbl.Parent = virusesPage
	slotCounterLabel = slotLbl

	-- Push VirusList down to make room for the chamber selector and toolbar
	local vl = find("VirusList")
	if vl then
		vl.Position = UDim2.new(0, 10, 0, 188)
		vl.Size = UDim2.new(1, -20, 1, -198)
	end
end

-- Roll button
local rollBtn = find("RollButton")
if rollBtn then
	local cooldownActive = false
	local cooldownEndTime = 0
	local cooldownUpdateThread = nil
	
	local function updateCooldownDisplay()
		if cooldownActive then
			local remaining = cooldownEndTime - tick()
			if remaining > 0 then
				rollBtn.Text = string.format("COOLDOWN: %.1fs", remaining)
				rollBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
				rollBtn.Active = false
				return
			else
				-- Cooldown finished
				cooldownActive = false
				rollBtn.Text = "ROLL"
				rollBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
				rollBtn.Active = true
			end
		else
			rollBtn.Text = "ROLL"
			rollBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
			rollBtn.Active = true
		end
	end
	
	local function updateCooldownLoop()
		while cooldownActive do
			updateCooldownDisplay()
			task.wait(0.1)
		end
	end

	local function beginCooldown(duration: number)
		cooldownActive = true
		cooldownEndTime = tick() + math.max(duration, 0.1)
		updateCooldownDisplay()
		if cooldownUpdateThread then
			task.cancel(cooldownUpdateThread)
		end
		cooldownUpdateThread = task.spawn(updateCooldownLoop)
	end

	local function checkCooldown(): (boolean, number)
		local success, response = pcall(function()
			return Remotes.CheckRollCooldown:InvokeServer()
		end)
		if not success then
			cooldownActive = false
			updateCooldownDisplay()
			warn("[UILogic] CheckRollCooldown failed: " .. tostring(response))
			return false, 0
		end

		if response and response.isOnCooldown and response.remainingTime > 0 then
			beginCooldown(response.remainingTime)
			return false, response.remainingTime
		end

		return true, (response and response.cooldownDuration) or 2
	end
	
	rollBtn.MouseButton1Click:Connect(function()
		if cooldownActive then return end

		local canRoll, cooldownDuration = checkCooldown()
		if not canRoll then return end

		beginCooldown(cooldownDuration)
		rollBtn.Text = "ROLLING..."
		rollBtn.Active = false
		VirusController:RollVirus()
	end)
end

-- Roll completed signal
VirusController.RollCompleted:Connect(function(virusData)
	showRollResult(virusData)
	local rollBtn = find("RollButton")
	if rollBtn then
		rollBtn.Active = true
	end
	updateCompactVirusDisplay(virusData)
end)

-- Slot claim buttons
for i = 1, 10 do
	local slot = find("Slot" .. i)
	if slot then
		local claimBtn = slot:FindFirstChild("ClaimButton")
		if claimBtn then
			claimBtn.MouseButton1Click:Connect(function()
				VirusController:ClaimVirus(i)
				claimBtn.Visible = false
				updateSlots()
				updateCurrencies()
				updateStats()
			end)
		end
	end
end

-- Upgrade buy buttons
local function setupUpgradeButton(frameName, upgradeId)
	local frame = find(frameName)
	if not frame then return end
	local btn = frame:FindFirstChild("BuyButton")
	if not btn then return end

	btn.MouseButton1Click:Connect(function()
		LabUpgradeController:BuyUpgrade(upgradeId)
		updateUpgrades()
		updateCurrencies()
	end)
end

setupUpgradeButton("Incubator", "Incubator")
setupUpgradeButton("SterileConditions", "SterileConditions")
setupUpgradeButton("AutoRoll", "AutoRoll")
setupUpgradeButton("QuickRoll", "QuickRoll")

-- Lab Capacity upgrade button (if an authored frame exists, wire it;
-- otherwise inject a button into the UpgradesPage programmatically)
local lcFrame = find("LabCapacity")
if lcFrame then
	local btn = lcFrame:FindFirstChild("BuyButton")
	if btn then
		btn.MouseButton1Click:Connect(function()
			local d = DataController and DataController.Data
			local upgrades = d and d.LabUpgrades or {}
			local currentLevel = upgrades.LabCapacityLevel or 0
			local cost = LabUpgradesData.GetUpgradeCost("LabCapacity", currentLevel)
			local rp = CurrencyController and CurrencyController:GetCurrency("researchPoints") or (d and d.Currencies and d.Currencies.researchPoints) or 0
			local canAfford = cost ~= nil and rp >= cost and currentLevel < LabUpgradesData.LabCapacity.MaxLevel
			Remotes.BuyLabCapacity:FireServer()
			if canAfford then
				if d then
					d.LabUpgrades = d.LabUpgrades or {}
					d.LabUpgrades.LabCapacityLevel = math.min((d.LabUpgrades.LabCapacityLevel or 0) + 1, LabUpgradesData.LabCapacity.MaxLevel)
				end
				if VirusController then
					VirusController.LabUpgrades = VirusController.LabUpgrades or {}
					VirusController.LabUpgrades.LabCapacityLevel = math.min((VirusController.LabUpgrades.LabCapacityLevel or 0) + 1, LabUpgradesData.LabCapacity.MaxLevel)
				end
				if LabUpgradeController then
					LabUpgradeController.LabUpgrades = LabUpgradeController.LabUpgrades or {}
					LabUpgradeController.LabUpgrades.LabCapacityLevel = math.min((LabUpgradeController.LabUpgrades.LabCapacityLevel or 0) + 1, LabUpgradesData.LabCapacity.MaxLevel)
				end
			end
			task.wait(0.2)
			updateSlots()
			updateUpgrades()
			updateCurrencies()
			rebuildVirusList()
		end)
	end
else
	-- Inject dynamically at bottom of UpgradesPage
	local upgPage = find("UpgradesPage")
	if upgPage and not upgPage:FindFirstChild("LabCapacityRow") then
		local row = Instance.new("Frame")
		row.Name = "LabCapacityRow"
		row.Size = UDim2.new(1, -10, 0, 50)
		row.Position = UDim2.new(0, 5, 1, -60)
		row.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
		row.BorderSizePixel = 0
		row.Parent = upgPage
		Instance.new("UICorner", row).CornerRadius = UDim.new(0, 6)

		local lbl = Instance.new("TextLabel")
		lbl.Size = UDim2.new(1, -120, 1, 0)
		lbl.Position = UDim2.new(0, 8, 0, 0)
		lbl.BackgroundTransparency = 1
		lbl.TextXAlignment = Enum.TextXAlignment.Left
		lbl.TextColor3 = Color3.new(1,1,1)
		lbl.TextSize = 12
		lbl.Font = FONT_MED
		lbl.TextWrapped = true
		lbl.Parent = row

		local buyBtn = Instance.new("TextButton")
		buyBtn.Size = UDim2.new(0, 110, 0, 28)
		buyBtn.Position = UDim2.new(1, -114, 0.5, -14)
		buyBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
		buyBtn.TextColor3 = Color3.new(1,1,1)
		buyBtn.TextSize = 11
		buyBtn.Font = FONT_BOLD
		buyBtn.Parent = row
		Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0, 4)

		local function refreshLabCapBtn()
			local d = DataController and DataController.Data or {}
			local upgrades = d.LabUpgrades or {}
			local controllerUpgrades = VirusController and VirusController.LabUpgrades or {}
			local labControllerUpgrades = LabUpgradeController and LabUpgradeController.LabUpgrades or {}
			local level = math.max(upgrades.LabCapacityLevel or 0, controllerUpgrades.LabCapacityLevel or 0, labControllerUpgrades.LabCapacityLevel or 0)
			local maxLevel = LabUpgradesData.LabCapacity.MaxLevel
			local maxSlots = math.min(getEffectiveMaxSlots(), 10)
			if level >= maxLevel then
				lbl.Text = "Lab Capacity (MAX)\nEquip slots: " .. maxSlots
				buyBtn.Text = "MAXED"
				buyBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
				buyBtn.Active = false
			else
				local cost = LabUpgradesData.GetUpgradeCost("LabCapacity", level)
				lbl.Text = "Lab Capacity Lv" .. level .. "\nEquip slots: " .. maxSlots .. " (+1 next)"
				buyBtn.Text = "Buy (" .. cost .. " RP)"
				buyBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
				buyBtn.Active = true
			end
		end
		refreshLabCapBtn()

		buyBtn.MouseButton1Click:Connect(function()
			local d = DataController and DataController.Data
			local upgrades = d and d.LabUpgrades or {}
			local currentLevel = upgrades.LabCapacityLevel or 0
			local cost = LabUpgradesData.GetUpgradeCost("LabCapacity", currentLevel)
			local rp = CurrencyController and CurrencyController:GetCurrency("researchPoints") or (d and d.Currencies and d.Currencies.researchPoints) or 0
			local canAfford = cost ~= nil and rp >= cost and currentLevel < LabUpgradesData.LabCapacity.MaxLevel
			Remotes.BuyLabCapacity:FireServer()
			if canAfford then
				if d then
					d.LabUpgrades = d.LabUpgrades or {}
					d.LabUpgrades.LabCapacityLevel = math.min((d.LabUpgrades.LabCapacityLevel or 0) + 1, LabUpgradesData.LabCapacity.MaxLevel)
				end
				if VirusController then
					VirusController.LabUpgrades = VirusController.LabUpgrades or {}
					VirusController.LabUpgrades.LabCapacityLevel = math.min((VirusController.LabUpgrades.LabCapacityLevel or 0) + 1, LabUpgradesData.LabCapacity.MaxLevel)
				end
				if LabUpgradeController then
					LabUpgradeController.LabUpgrades = LabUpgradeController.LabUpgrades or {}
					LabUpgradeController.LabUpgrades.LabCapacityLevel = math.min((LabUpgradeController.LabUpgrades.LabCapacityLevel or 0) + 1, LabUpgradesData.LabCapacity.MaxLevel)
				end
			end
			task.wait(0.2)
			refreshLabCapBtn()
			updateSlots()
			updateCurrencies()
			rebuildVirusList()
		end)
	end
end

-- Virus slot purchase
local slotFrame = find("VirusSlot")
if slotFrame then
	local btn = slotFrame:FindFirstChild("BuyButton")
	if btn then
		btn.MouseButton1Click:Connect(function()
			local d = DataController and DataController.Data
			local profile = getEffectiveSlotProfile()
			local upgrades = profile.LabUpgrades or {}
			local currentLevel = math.max(upgrades.LabCapacityLevel or 0, math.max(0, (tonumber(profile.VirusSlotCount) or 1) - 1))
			local cost = LabUpgradesData.GetUpgradeCost("LabCapacity", currentLevel)
			local rp = CurrencyController and CurrencyController:GetCurrency("researchPoints") or (d and d.Currencies and d.Currencies.researchPoints) or 0
			local canAfford = cost ~= nil and rp >= cost and currentLevel < LabUpgradesData.LabCapacity.MaxLevel
			LabUpgradeController:BuyVirusSlot()
			if canAfford then
				local newLevel = currentLevel + 1
				if d then
					d.LabUpgrades = d.LabUpgrades or {}
					d.LabUpgrades.LabCapacityLevel = newLevel
					d.VirusSlotCount = newLevel + 1
				end
				if VirusController then
					VirusController.LabUpgrades = VirusController.LabUpgrades or {}
					VirusController.LabUpgrades.LabCapacityLevel = newLevel
					VirusController.VirusSlotCount = newLevel + 1
				end
				if LabUpgradeController then
					LabUpgradeController.LabUpgrades = LabUpgradeController.LabUpgrades or {}
					LabUpgradeController.LabUpgrades.LabCapacityLevel = newLevel
					LabUpgradeController.VirusSlotCount = newLevel + 1
				end
			end
			task.wait(0.2)
			updateUpgrades()
			updateCurrencies()
			updateSlots()
			rebuildVirusList()
		end)
	end
end

-- Auto-roll toggle
local arf = find("AutoRollToggle")
if arf then
	local toggleBtn = arf:FindFirstChild("ToggleButton")
	if toggleBtn then
		toggleBtn.MouseButton1Click:Connect(function()
			VirusController:ToggleAutoRoll()
			task.wait(0.2)
			updateUpgrades()
		end)
	end
end

-- DNA Tree button
local openTreeBtn = find("OpenTreeButton")
if openTreeBtn then
	openTreeBtn.MouseButton1Click:Connect(function()
		if SkillTreeController then
			SkillTreeController:OpenTree("VirusLab")
		end
	end)
end

-- ============================================================================
-- MINIMIZE / EXPAND toggle
-- ============================================================================
local mainContainer = main
local compactUI = gui:FindFirstChild("CompactUI")

-- Minimize: hide full UI, show compact roll-only UI
local minBtn = find("MinimizeButton")
if minBtn then
	minBtn.MouseButton1Click:Connect(function()
		if mainContainer then mainContainer.Visible = false end
		if compactUI then compactUI.Visible = true end
		updateCompactVirusDisplay(lastRolledVirusData)
	end)
end

-- Expand: hide compact UI, show full UI
if compactUI then
	local expandBtn = compactUI:FindFirstChild("ExpandButton")
	if expandBtn then
		expandBtn.MouseButton1Click:Connect(function()
			if compactUI then compactUI.Visible = false end
			if mainContainer then mainContainer.Visible = true end
		end)
	end

	-- Compact roll button (same behavior as main RollButton)
	local compactRollBtn = compactUI:FindFirstChild("CompactRollButton")
	if compactRollBtn then
		local compactRolling = false
		local cooldownActive = false
		local compactRollConn = nil
		local compactCooldownUpdateThread = nil
		
		local function updateCompactCooldownDisplay()
			if cooldownActive then
				local remaining = compactCooldownEndTime - tick()
				if remaining > 0 then
					compactRollBtn.Text = string.format("COOLDOWN: %.1fs", remaining)
					compactRollBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
					compactRollBtn.Active = false
					return
				else
					-- Cooldown finished
					cooldownActive = false
					compactRollBtn.Text = "ROLL"
					compactRollBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
					compactRollBtn.Active = true
				end
			else
				compactRollBtn.Text = "ROLL"
				compactRollBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 50)
				compactRollBtn.Active = true
			end
		end
		
		local function updateCompactCooldownLoop()
			while cooldownActive do
				updateCompactCooldownDisplay()
				task.wait(0.1)
			end
		end

		local function beginCompactCooldown(duration: number)
			cooldownActive = true
			compactCooldownEndTime = tick() + math.max(duration, 0.1)
			updateCompactCooldownDisplay()
			if compactCooldownUpdateThread then
				task.cancel(compactCooldownUpdateThread)
			end
			compactCooldownUpdateThread = task.spawn(updateCompactCooldownLoop)
		end

		local function checkCompactCooldown(): (boolean, number)
			local success, response = pcall(function()
				return Remotes.CheckRollCooldown:InvokeServer()
			end)
			if not success then
				cooldownActive = false
				updateCompactCooldownDisplay()
				warn("[UILogic] CheckRollCooldown failed: " .. tostring(response))
				return false, 0
			end

			if response and response.isOnCooldown and response.remainingTime > 0 then
				beginCompactCooldown(response.remainingTime)
				return false, response.remainingTime
			end

			return true, (response and response.cooldownDuration) or 2
		end
		
		compactRollBtn.MouseButton1Click:Connect(function()
			if compactRolling or cooldownActive then return end

			local canRoll, cooldownDuration = checkCompactCooldown()
			if not canRoll then return end

			beginCompactCooldown(cooldownDuration)
			compactRolling = true
			compactRollBtn.Text = "ROLLING..."
			compactRollBtn.Active = false
			VirusController:RollVirus()
			-- Clean previous connection and make a new one-shot via disconnect pattern
			if compactRollConn then
				compactRollConn:Disconnect()
			end
			compactRollConn = VirusController.RollCompleted:Connect(function(...)
				compactRollBtn.Text = "ROLL"
				compactRollBtn.Active = true
				compactRolling = false
				-- Self-disconnect after first fire
				if compactRollConn then
					compactRollConn:Disconnect()
					compactRollConn = nil
				end
			end)
		end)
	end
end

-- Rebirth button (uses existing LabTycoon.Remotes.Rebirth)
local rebirthBtn = find("RebirthButton")
if rebirthBtn then
	rebirthBtn.MouseButton1Click:Connect(function()
		Remotes.Rebirth:FireServer("VirusRebirth", 1)
		task.wait(0.5)
		updateRebirth()
		updateCurrencies()
		updateStats()
		updateSlots()
		updateUpgrades()
	end)
end

-- Listen for currency updates
if CurrencyController and CurrencyController.CurrencyUpdated then
	CurrencyController.CurrencyUpdated:Connect(function()
		updateCurrencies()
		updateRebirth()
		updateUpgrades()
	end)
end

-- Listen for virus controller signals
VirusController.EarningsChanged:Connect(function()
	updateStats()
end)

VirusController.SlotChanged:Connect(function()
	updateSlots()
	updateStats()
end)

VirusController.SlotCountChanged:Connect(function()
	updateSlots()
	updateUpgrades()
end)

VirusController.LabUpgradeChanged:Connect(function()
	updateUpgrades()
	updateCurrencies()
end)

-- Periodic update loop
task.spawn(function()
	while true do
		task.wait(1)
		updateCurrencies()
		updateStats()
		updateSlots()
		updateUpgrades()
		updateRebirth()
	end
end)

-- Inject QuickRoll upgrade frame if it doesn't exist
local upgPage = find("UpgradesPage")
if upgPage and not upgPage:FindFirstChild("QuickRoll") then
	local quickFrame = Instance.new("Frame")
	quickFrame.Name = "QuickRoll"
	quickFrame.Size = UDim2.new(1, -10, 0, 50)
	quickFrame.Position = UDim2.new(0, 5, 0, 200) -- Position after AutoRoll
	quickFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 40)
	quickFrame.BorderSizePixel = 0
	quickFrame.Parent = upgPage
	Instance.new("UICorner", quickFrame).CornerRadius = UDim.new(0, 6)

	local lbl = Instance.new("TextLabel")
	lbl.Size = UDim2.new(1, -120, 1, 0)
	lbl.Position = UDim2.new(0, 8, 0, 0)
	lbl.BackgroundTransparency = 1
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.TextColor3 = Color3.new(1,1,1)
	lbl.TextSize = 12
	lbl.Font = FONT_MED
	lbl.TextWrapped = true
	lbl.Parent = quickFrame
	lbl.Text = "Quick Roll"

	local buyBtn = Instance.new("TextButton")
	buyBtn.Size = UDim2.new(0, 110, 0, 28)
	buyBtn.Position = UDim2.new(1, -114, 0.5, -14)
	buyBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
	buyBtn.TextColor3 = Color3.new(1,1,1)
	buyBtn.TextSize = 11
	buyBtn.Font = FONT_BOLD
	buyBtn.Parent = quickFrame
	Instance.new("UICorner", buyBtn).CornerRadius = UDim.new(0, 4)

	local function refreshQuickRollBtn()
		local d = DataController and DataController.Data or {}
		local upgrades = d.LabUpgrades or {}
		local level = upgrades.QuickRollLevel or 0
		if level >= 20 then
			lbl.Text = "Quick Roll (MAX)\nCooldown: 0.5s"
			buyBtn.Text = "MAXED"
			buyBtn.BackgroundColor3 = Color3.fromRGB(60,60,60)
			buyBtn.Active = false
		else
			local currentCooldown = LabUpgradesData.GetRollCooldown(upgrades)
			local cost = LabUpgradesData.GetUpgradeCost("QuickRoll", level)
			lbl.Text = "Quick Roll Lv" .. level .. "\nCooldown: " .. string.format("%.1f", currentCooldown) .. "s"
			buyBtn.Text = "Buy (" .. cost .. " RP)"
			buyBtn.BackgroundColor3 = Color3.fromRGB(0, 130, 200)
			buyBtn.Active = true
		end
	end
	refreshQuickRollBtn()

	buyBtn.MouseButton1Click:Connect(function()
		LabUpgradeController:BuyUpgrade("QuickRoll")
		task.wait(0.2)
		refreshQuickRollBtn()
		updateCurrencies()
	end)
end

-- Initial refresh
updateCurrencies()
updateStats()
updateSlots()
updateUpgrades()
updateRebirth()

print("LabTycoon UI Logic started!")

