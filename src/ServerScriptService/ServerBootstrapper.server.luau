local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Knit = require(ReplicatedStorage.Packages.Knit)

local VirusData = require(ReplicatedStorage.Modules.VirusData)
local LabUpgradesData = require(ReplicatedStorage.SharedSource.Datas.LabUpgradesData)
local EquipSlotHelper = require(ReplicatedStorage.Modules.EquipSlotHelper)
local Remotes = ReplicatedStorage.LabTycoon.Remotes

-- Wait for Superbullet/Knit initialization
-- SuperbulletServer script loads all services and calls Superbullet.Start()
local SuperbulletModule = ReplicatedStorage.Packages.Superbullet
if not SuperbulletModule:GetAttribute("SuperbulletServer_Initialized") then
	repeat task.wait() until SuperbulletModule:GetAttribute("SuperbulletServer_Initialized")
end

print("[ServerBootstrapper] Superbullet initialized, setting up handlers...")

-- Get Knit services managed by Superbullet/Knit
local PS = Knit.GetService("ProfileService")

-- Get business logic modules from ServerSource
local ServerSource = game:GetService("ServerScriptService"):FindFirstChild("ServerSource")
local VirusService
local LabUpgradeService
if ServerSource then
	local ok1, vs = pcall(require, ServerSource.Server.VirusService)
	if ok1 then VirusService = vs end
	local ok2, ls = pcall(require, ServerSource.Server.LabUpgradeService)
	if ok2 then LabUpgradeService = ls end
end

-- Roll cache for pending claims (per-player, not serialized)
local RollCache = {}

print("[ServerBootstrapper] Using Knit ProfileService and business logic modules")

-- Helper: get profile data for a player via Knit ProfileService
local function getProfileData(player)
	local _, data = PS:GetProfile(player)
	return data
end

-- Helper: change data via Knit ProfileService
local function changeData(player, path, value)
	PS:ChangeData(player, path, value)
end

-- Per-player last-roll timestamps for cooldown enforcement
local LastRollTime = {}

-- ROLL VIRUS
Remotes.RollVirus.OnServerEvent:Connect(function(player)
	local profileData = getProfileData(player)
	if not profileData then return end

	local virus
	if VirusService then
		virus = VirusService.RollForVirus(player)
	else
		local cooldown = LabUpgradesData.GetRollCooldown(profileData.LabUpgrades or {})
		local now = os.clock()
		local lastRoll = LastRollTime[player] or 0
		if now - lastRoll < cooldown then
			return
		end
		LastRollTime[player] = now
		local luckMult = profileData.RebirthLuckMultiplier or 1
		local labLuck = LabUpgradesData.GetTotalLuckBonus(profileData.LabUpgrades or {}) or 0
		local totalLuck = luckMult * (1 + labLuck)

		local roll = math.random() * 100
		local cumulative = 0
		local selectedTier = nil
		for _, tier in ipairs(VirusData.Tiers) do
			cumulative += tier.Rarity * totalLuck
			if roll <= cumulative then
				selectedTier = tier
				break
			end
		end
		if not selectedTier then selectedTier = VirusData.Tiers[#VirusData.Tiers] end

		local tierViruses = VirusData.GetVirusesByTier(selectedTier.Name)
		if #tierViruses == 0 then tierViruses = VirusData.Viruses end
		virus = tierViruses[math.random(1, #tierViruses)]

		changeData(player, {"TotalRolls"}, (profileData.TotalRolls or 0) + 1)
	end

	if virus then
		RollCache[player] = virus

		-- AUTO-ADD to inventory immediately (stackable)
		local profileData = getProfileData(player)
		if profileData then
			local inventory = profileData.VirusInventory or {}
			table.insert(inventory, virus.Name)
			changeData(player, {"VirusInventory"}, inventory)
		end

		Remotes.RollResult:FireClient(player, virus)
	end
end)

-- CLAIM VIRUS
Remotes.ClaimVirus.OnServerEvent:Connect(function(player, slotIndex)
	local virus = RollCache[player]
	if not virus then return end

	local profileData = getProfileData(player)
	if not profileData then return end

	local slots = profileData.VirusSlots or {}
	if slots[slotIndex] then return end

	slots[slotIndex] = virus.Name
	-- Inventory already updated at roll time; only update slots here
	changeData(player, {"VirusSlots"}, slots)
	RollCache[player] = nil
end)

-- BUY LAB UPGRADE
Remotes.BuyLabUpgrade.OnServerEvent:Connect(function(player, upgradeId)
	if type(upgradeId) ~= "string" then return end

	if LabUpgradeService then
		LabUpgradeService.BuyUpgrade(player, upgradeId)
	else
		local profileData = getProfileData(player)
		if not profileData then return end

		local upgrades = profileData.LabUpgrades or {}
		local levelKey = upgradeId .. "Level"
		local currentLevel = upgrades[levelKey] or 0
		local cost = LabUpgradesData.GetUpgradeCost(upgradeId, currentLevel)
		if not cost then return end

		local rp = profileData.Currencies.researchPoints or 0
		if rp < cost then return end

		changeData(player, {"Currencies", "researchPoints"}, rp - cost)
		upgrades[levelKey] = currentLevel + 1
		changeData(player, {"LabUpgrades"}, upgrades)
	end
end)

-- PURCHASE VIRUS SLOT
Remotes.PurchaseVirusSlot.OnServerEvent:Connect(function(player)
	if LabUpgradeService then
		LabUpgradeService.BuyVirusSlot(player)
	else
		local profileData = getProfileData(player)
		if not profileData then return end

		local currentSlots = profileData.VirusSlotCount or 1
		if currentSlots >= 10 then return end

		local cost = LabUpgradesData.GetSlotCost(currentSlots + 1)
		if not cost then return end

		local rp = profileData.Currencies.researchPoints or 0
		if rp < cost then return end

		changeData(player, {"Currencies", "researchPoints"}, rp - cost)
		changeData(player, {"VirusSlotCount"}, currentSlots + 1)
	end
end)

-- TOGGLE AUTO-ROLL
Remotes.ToggleAutoRoll.OnServerEvent:Connect(function(player)
	local profileData = getProfileData(player)
	if not profileData then return end

	local upgrades = profileData.LabUpgrades or {}
	upgrades.AutoRollEnabled = not upgrades.AutoRollEnabled
	changeData(player, {"LabUpgrades"}, upgrades)
end)

-- REBIRTH (VirusRebirth only - Superbullet handles other rebirth types)
Remotes.Rebirth.OnServerEvent:Connect(function(player, rebirthType)
	if rebirthType ~= "VirusRebirth" then return end

	local profileData = getProfileData(player)
	if not profileData then return end

	local currentRebirths = profileData.RebirthCount or 0

	-- Exponential cost: 1,000,000 * 1.5^rebirths
	local cost = math.floor(1000000 * (1.5 ^ currentRebirths))
	local cash = profileData.Currencies.cash or 0
	if cash < cost then return end

	local newRebirths = currentRebirths + 1

	-- Luck boost: 1 + 0.1*R + 0.2*sqrt(R)
	local newLuckMultiplier = 1 + (0.1 * newRebirths) + (0.2 * math.sqrt(newRebirths))

	-- Grant 1 skill point per rebirth
	local currentSP = (profileData.SkillTree and profileData.SkillTree.Stats and profileData.SkillTree.Stats.Skillpoints) or 0
	changeData(player, {"SkillTree", "Stats", "Skillpoints"}, currentSP + 1)

	changeData(player, {"Currencies", "cash"}, cash - cost)
	changeData(player, {"Currencies", "researchPoints"}, 0)
	changeData(player, {"LabUpgrades"}, {
		IncubatorLevel = 0,
		SterileConditionsLevel = 0,
		AutoRollLevel = 0,
		AutoRollEnabled = false,
		LabCapacityLevel = 0,
		RollSpeedLevel = 0,
	})
	changeData(player, {"VirusInventory"}, {})
	changeData(player, {"EquippedViruses"}, {})
	changeData(player, {"VirusSlots"}, {})
	changeData(player, {"VirusSlotCount"}, 1)
	changeData(player, {"VirusEarnings"}, {ResearchPoints = 0, Cash = 0})
	changeData(player, {"RebirthLuckMultiplier"}, newLuckMultiplier)
	changeData(player, {"Currencies", "dnaPoints"}, (profileData.Currencies.dnaPoints or 0) + 25)
	changeData(player, {"RebirthCount"}, newRebirths)
end)

-- GET PLAYER DATA (RemoteFunction)
if Remotes.GetPlayerData then
	Remotes.GetPlayerData.OnServerInvoke = function(player)
		local _, profileData = PS:GetProfile(player)
		return profileData
	end
end

-- GET SHOP DATA (RemoteFunction)
if Remotes.GetShopData then
	Remotes.GetShopData.OnServerInvoke = function()
		return {
			upgrades = {
				LabUpgradesData.Incubator,
				LabUpgradesData.SterileConditions,
				LabUpgradesData.AutoRoll,
			},
		}
	end
end

-- GET SKILL TREE DATA (RemoteFunction)
if Remotes.GetSkillTreeData then
	Remotes.GetSkillTreeData.OnServerInvoke = function(player)
		local _, profileData = PS:GetProfile(player)
		if not profileData then return nil end
		return {
			SkillTree = profileData.SkillTree or {},
			SkillPoints = profileData.Currencies and profileData.Currencies.skillPoints or 0,
			DNAPoints = profileData.Currencies and profileData.Currencies.dnaPoints or 0,
		}
	end
end

-- BUY SKILL NODE (RemoteEvent)
if Remotes.BuySkillNode then
	Remotes.BuySkillNode.OnServerEvent:Connect(function(player, nodeId)
		if type(nodeId) ~= "string" then return end
		local profileData = getProfileData(player)
		if not profileData then return end

		local skillTree = profileData.SkillTree or {}
		if skillTree[nodeId] then return end

		local SkillTreeData = require(ReplicatedStorage.SharedSource.Datas.SkillTreeData)
		local nodeData = SkillTreeData and SkillTreeData[nodeId]
		if not nodeData then return end

		local cost = nodeData.Cost or 0
		local currency = nodeData.Currency or "skillPoints"
		local playerCurrency = profileData.Currencies and profileData.Currencies[currency] or 0
		if playerCurrency < cost then return end

		changeData(player, {"Currencies", currency}, playerCurrency - cost)
		skillTree[nodeId] = true
		changeData(player, {"SkillTree"}, skillTree)
	end)
end

-- Helper: count total viruses currently equipped
local function countTotalEquipped(equipped)
	local total = 0
	for _, c in pairs(equipped) do total += c end
	return total
end

-- EQUIP VIRUS
Remotes.EquipVirus.OnServerEvent:Connect(function(player, virusName)
	if type(virusName) ~= "string" then return end
	local profileData = getProfileData(player)
	if not profileData then return end

	-- Enforce slot cap
	local maxSlots = EquipSlotHelper.GetMaxSlots(profileData)
	local equipped = profileData.EquippedViruses or {}
	if countTotalEquipped(equipped) >= maxSlots then return end

	-- Must own the virus
	local inventory = profileData.VirusInventory or {}
	local ownedCount = 0
	for _, vn in ipairs(inventory) do
		if vn == virusName then ownedCount += 1 end
	end
	if ownedCount == 0 then return end

	local equippedCount = equipped[virusName] or 0
	if equippedCount >= ownedCount then return end -- can't equip more than owned

	equipped[virusName] = equippedCount + 1
	changeData(player, {"EquippedViruses"}, equipped)
	Remotes.EquipmentChanged:FireClient(player, equipped)
end)

-- UNEQUIP VIRUS
Remotes.UnequipVirus.OnServerEvent:Connect(function(player, virusName)
	if type(virusName) ~= "string" then return end
	local profileData = getProfileData(player)
	if not profileData then return end

	local equipped = profileData.EquippedViruses or {}
	local equippedCount = equipped[virusName] or 0
	if equippedCount <= 0 then return end

	equippedCount -= 1
	if equippedCount == 0 then
		equipped[virusName] = nil
	else
		equipped[virusName] = equippedCount
	end
	changeData(player, {"EquippedViruses"}, equipped)
	Remotes.EquipmentChanged:FireClient(player, equipped)
end)

-- BUY LAB CAPACITY UPGRADE
Remotes.BuyLabCapacity.OnServerEvent:Connect(function(player)
	local profileData = getProfileData(player)
	if not profileData then return end

	local upgrades = profileData.LabUpgrades or {}
	local currentLevel = upgrades.LabCapacityLevel or 0
	if currentLevel >= LabUpgradesData.LabCapacity.MaxLevel then return end

	local cost = LabUpgradesData.GetUpgradeCost("LabCapacity", currentLevel)
	if not cost then return end

	local rp = profileData.Currencies.researchPoints or 0
	if rp < cost then return end

	changeData(player, {"Currencies", "researchPoints"}, rp - cost)
	upgrades.LabCapacityLevel = currentLevel + 1
	changeData(player, {"LabUpgrades"}, upgrades)
	Remotes.EquipmentChanged:FireClient(player, profileData.EquippedViruses or {})
end)

-- AUTO-EQUIP BEST
Remotes.AutoEquipBest.OnServerEvent:Connect(function(player)
	local profileData = getProfileData(player)
	if not profileData then return end

	local maxSlots = EquipSlotHelper.GetMaxSlots(profileData)

	-- Build list of all owned viruses with their RP/s value, sorted best first
	local inventory = profileData.VirusInventory or {}
	local counts = {}
	for _, vn in ipairs(inventory) do
		counts[vn] = (counts[vn] or 0) + 1
	end

	local candidates = {}
	for virusName, count in pairs(counts) do
		local vd = VirusData.GetVirusByName(virusName)
		if vd then
			for _ = 1, count do
				table.insert(candidates, {name = virusName, rp = vd.ResearchPoints or 0})
			end
		end
	end
	table.sort(candidates, function(a, b) return a.rp > b.rp end)

	-- Fill slots with best viruses
	local newEquipped = {}
	local filled = 0
	for _, c in ipairs(candidates) do
		if filled >= maxSlots then break end
		newEquipped[c.name] = (newEquipped[c.name] or 0) + 1
		filled += 1
	end

	changeData(player, {"EquippedViruses"}, newEquipped)
	Remotes.EquipmentChanged:FireClient(player, newEquipped)
end)

-- EARNINGS LOOP
-- Reads from EquippedViruses only so only equipped viruses generate income.
task.spawn(function()
	while true do
		task.wait(1)
		for _, player in ipairs(Players:GetPlayers()) do
			local _, profileData = PS:GetProfile(player)
			if not profileData then continue end

			local equipped = profileData.EquippedViruses or {}
			local rpPerSec = 0
			local cashPerSec = 0

			for virusName, count in pairs(equipped) do
				local vd = VirusData.GetVirusByName(virusName)
				if vd and count > 0 then
					rpPerSec += (vd.ResearchPoints or 0) * count
					cashPerSec += (vd.Cash or 0) * count
				end
			end

			local sterileLevel = (profileData.LabUpgrades).SterileConditionsLevel or 0
			local rpBonus = LabUpgradesData.SterileConditions.EffectPerLevel or 0.02
			rpPerSec *= (1 + sterileLevel * rpBonus)

			if rpPerSec > 0 or cashPerSec > 0 then
				changeData(player, {"Currencies", "researchPoints"}, (profileData.Currencies.researchPoints or 0) + rpPerSec)
				changeData(player, {"Currencies", "cash"}, (profileData.Currencies.cash or 0) + cashPerSec)
			end
			changeData(player, {"VirusEarnings"}, {ResearchPoints = rpPerSec, Cash = cashPerSec})
		end
	end
end)

-- AUTO-ROLL LOOP
-- Tracks per-player countdown timers. Each tick decrements by 1 second.
-- When a timer hits 0 and AutoRollEnabled is true, rolls and fires the result.
-- Does NOT overwrite RollCache so the player can still claim the result.
local AutoRollTimers = {} -- [player] = seconds remaining

task.spawn(function()
	while true do
		task.wait(1)
		for _, player in ipairs(Players:GetPlayers()) do
			local _, profileData = PS:GetProfile(player)
			if not profileData then continue end

			local upgrades = profileData.LabUpgrades or {}
			if not upgrades.AutoRollEnabled then continue end

			local autoRollLevel = upgrades.AutoRollLevel or 0
			if autoRollLevel < 1 then continue end

			local interval = LabUpgradesData.GetAutoRollInterval(upgrades)

			AutoRollTimers[player] = (AutoRollTimers[player] or interval) - 1

			if AutoRollTimers[player] <= 0 then
				AutoRollTimers[player] = interval

				-- Only auto-roll if player has a free slot available
				local slots = profileData.VirusSlots or {}
				local slotCount = profileData.VirusSlotCount or 1
				local hasFreeSlot = false
				for i = 1, slotCount do
					if not slots[i] then
						hasFreeSlot = true
						break
					end
				end
				if not hasFreeSlot then continue end

				local virus
				if VirusService then
					virus = VirusService.RollForVirus(player)
				else
					local luckMult = profileData.RebirthLuckMultiplier or 1
					local labLuck = LabUpgradesData.GetTotalLuckBonus(upgrades) or 0
					local totalRarity = 0
					local adjustedTiers = {}
					for _, tier in ipairs(VirusData.Tiers) do
						local adj = {Name = tier.Name, Rarity = tier.Rarity * luckMult * (1 + labLuck)}
						table.insert(adjustedTiers, adj)
						totalRarity += adj.Rarity
					end
					local roll = math.random() * totalRarity
					local cumulative = 0
					local selectedTier = adjustedTiers[#adjustedTiers]
					for _, tier in ipairs(adjustedTiers) do
						cumulative += tier.Rarity
						if roll <= cumulative then
							selectedTier = tier
							break
						end
					end
					local tierViruses = VirusData.GetVirusesByTier(selectedTier.Name)
					if #tierViruses == 0 then tierViruses = VirusData.Viruses end
					virus = tierViruses[math.random(1, #tierViruses)]
				end

				if virus then
					-- Auto-add to inventory immediately (stackable)
					local pd = getProfileData(player)
					if pd then
						local inv = pd.VirusInventory or {}
						table.insert(inv, virus.Name)
						changeData(player, {"VirusInventory"}, inv)
					end
					RollCache[player] = virus
					Remotes.RollResult:FireClient(player, virus)
				end
			end
		end
	end
end)


-- PLAYER LIFECYCLE
Players.PlayerRemoving:Connect(function(player)
	RollCache[player] = nil
	AutoRollTimers[player] = nil
end)

-- CHECK ROLL COOLDOWN (RemoteFunction)
if Remotes.CheckRollCooldown then
	Remotes.CheckRollCooldown.OnServerInvoke = function(player)
		if VirusService then
			local profileData = getProfileData(player)
			local cooldown = profileData and LabUpgradesData.GetRollCooldown(profileData.LabUpgrades or {}) or 2
			return {
				isOnCooldown = VirusService.IsPlayerOnCooldown(player),
				remainingTime = VirusService.GetRemainingCooldown(player),
				cooldownDuration = cooldown,
			}
		else
			-- Fallback to old system
			local profileData = getProfileData(player)
			if not profileData then return {isOnCooldown = false, remainingTime = 0} end
			local cooldown = LabUpgradesData.GetRollCooldown(profileData.LabUpgrades or {})
			local now = os.clock()
			local lastRoll = LastRollTime[player] or 0
			local timeSinceLastRoll = now - lastRoll
			local isOnCooldown = timeSinceLastRoll < cooldown
			local remainingTime = isOnCooldown and (cooldown - timeSinceLastRoll) or 0
			return {isOnCooldown = isOnCooldown, remainingTime = remainingTime, cooldownDuration = cooldown}
		end
	end
end

print("[ServerBootstrapper] All LabTycoon handlers connected!")
