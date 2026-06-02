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
local SkillTreeService
pcall(function()
	SkillTreeService = Knit.GetService("SkillTreeService")
end)

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

		virus = VirusData.RollVirusWithNumericalRarity(totalLuck)

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
		if upgradeId == "LabCapacity" then
			local legacyLevel = math.max(0, (tonumber(profileData.VirusSlotCount) or 1) - 1)
			currentLevel = math.max(currentLevel, legacyLevel)
		end
		local cost = LabUpgradesData.GetUpgradeCost(upgradeId, currentLevel)
		if not cost then return end

		local rp = profileData.Currencies.researchPoints or 0
		if rp < cost then return end

		changeData(player, {"Currencies", "researchPoints"}, rp - cost)
		upgrades[levelKey] = currentLevel + 1
		changeData(player, {"LabUpgrades"}, upgrades)
		if upgradeId == "LabCapacity" then
			changeData(player, {"VirusSlotCount"}, upgrades[levelKey] + 1)
		end
	end
end)

-- PURCHASE VIRUS SLOT
Remotes.PurchaseVirusSlot.OnServerEvent:Connect(function(player)
	if LabUpgradeService then
		LabUpgradeService.BuyVirusSlot(player)
	else
		local profileData = getProfileData(player)
		if not profileData then return end

		local upgrades = profileData.LabUpgrades or {}
		local legacyLevel = math.max(0, (tonumber(profileData.VirusSlotCount) or 1) - 1)
		local currentLevel = math.max(upgrades.LabCapacityLevel or 0, legacyLevel)
		if currentLevel >= LabUpgradesData.LabCapacity.MaxLevel then return end

		local cost = LabUpgradesData.GetUpgradeCost("LabCapacity", currentLevel)
		if not cost then return end

		local rp = profileData.Currencies.researchPoints or 0
		if rp < cost then return end

		local newLevel = currentLevel + 1
		upgrades.LabCapacityLevel = newLevel
		changeData(player, {"Currencies", "researchPoints"}, rp - cost)
		changeData(player, {"LabUpgrades"}, upgrades)
		changeData(player, {"VirusSlotCount"}, newLevel + 1)
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
	changeData(player, {"EquippedVirusSlots"}, {})
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

local function getOwnedCounts(profileData)
	local owned = {}
	for _, virusName in ipairs(profileData.VirusInventory or {}) do
		owned[virusName] = (owned[virusName] or 0) + 1
	end
	return owned
end

local function getSlotValue(virusName)
	local vd = VirusData.GetVirusByName(virusName)
	if not vd then return 0 end
	return (vd.ResearchPoints or 0) + ((vd.Cash or 0) * 0.5)
end

local function buildCountsFromSlots(slots, maxSlots)
	local counts = {}
	for i = 1, maxSlots do
		local virusName = slots[i] or slots[tostring(i)]
		if type(virusName) == "string" then
			counts[virusName] = (counts[virusName] or 0) + 1
		end
	end
	return counts
end

local function normalizeEquippedSlotState(profileData)
	local maxSlots = math.min(EquipSlotHelper.GetMaxSlots(profileData), 10)
	local owned = getOwnedCounts(profileData)
	local sourceSlots = profileData.EquippedVirusSlots or {}
	local slots = {}
	local counts = {}
	local hasSlotAssignments = false

	for i = 1, maxSlots do
		local virusName = sourceSlots[i] or sourceSlots[tostring(i)]
		if type(virusName) == "string" and owned[virusName] and (counts[virusName] or 0) < owned[virusName] then
			slots[i] = virusName
			counts[virusName] = (counts[virusName] or 0) + 1
			hasSlotAssignments = true
		end
	end

	if not hasSlotAssignments then
		local equipped = profileData.EquippedViruses or {}
		local candidates = {}
		for virusName, count in pairs(equipped) do
			local allowed = math.min(tonumber(count) or 0, owned[virusName] or 0)
			for _ = 1, allowed do
				table.insert(candidates, {name = virusName, value = getSlotValue(virusName)})
			end
		end
		table.sort(candidates, function(a, b)
			if a.value ~= b.value then return a.value > b.value end
			return a.name < b.name
		end)
		for i, candidate in ipairs(candidates) do
			if i > maxSlots then break end
			slots[i] = candidate.name
			counts[candidate.name] = (counts[candidate.name] or 0) + 1
		end
	end

	return slots, counts, maxSlots, owned
end

local function commitEquipment(player, slots, counts, labUpgrades)
	changeData(player, {"EquippedVirusSlots"}, slots)
	changeData(player, {"EquippedViruses"}, counts)
	Remotes.EquipmentChanged:FireClient(player, counts, slots, labUpgrades)
end

-- EQUIP VIRUS
Remotes.EquipVirus.OnServerEvent:Connect(function(player, virusName, slotIndex)
	if type(virusName) ~= "string" then return end
	local profileData = getProfileData(player)
	if not profileData then return end

	local slots, equipped, maxSlots, owned = normalizeEquippedSlotState(profileData)
	local ownedCount = owned[virusName] or 0
	if ownedCount <= 0 then return end

	local targetSlot = tonumber(slotIndex)
	if not targetSlot then
		for i = 1, maxSlots do
			if not slots[i] then
				targetSlot = i
				break
			end
		end
	end
	if not targetSlot then return end
	targetSlot = math.floor(targetSlot)
	if targetSlot < 1 or targetSlot > maxSlots then return end

	local currentVirus = slots[targetSlot]
	if currentVirus == virusName then
		commitEquipment(player, slots, equipped)
		return
	end
	if (equipped[virusName] or 0) >= ownedCount then return end

	if currentVirus then
		equipped[currentVirus] = math.max(0, (equipped[currentVirus] or 0) - 1)
		if equipped[currentVirus] == 0 then equipped[currentVirus] = nil end
	end
	slots[targetSlot] = virusName
	equipped[virusName] = (equipped[virusName] or 0) + 1
	commitEquipment(player, slots, equipped)
end)

-- UNEQUIP VIRUS
Remotes.UnequipVirus.OnServerEvent:Connect(function(player, virusName, slotIndex)
	if type(virusName) ~= "string" then return end
	local profileData = getProfileData(player)
	if not profileData then return end

	local slots, equipped, maxSlots = normalizeEquippedSlotState(profileData)
	local targetSlot = tonumber(slotIndex)
	if targetSlot then
		targetSlot = math.floor(targetSlot)
		if targetSlot < 1 or targetSlot > maxSlots then return end
		if slots[targetSlot] ~= virusName then return end
	else
		for i = 1, maxSlots do
			if slots[i] == virusName then
				targetSlot = i
				break
			end
		end
	end
	if not targetSlot then return end

	slots[targetSlot] = nil
	equipped = buildCountsFromSlots(slots, maxSlots)
	commitEquipment(player, slots, equipped)
end)

-- BUY LAB CAPACITY UPGRADE
Remotes.BuyLabCapacity.OnServerEvent:Connect(function(player)
	local profileData = getProfileData(player)
	if not profileData then return end

	local upgrades = profileData.LabUpgrades or {}
	local legacyLevel = math.max(0, (tonumber(profileData.VirusSlotCount) or 1) - 1)
	local currentLevel = math.max(upgrades.LabCapacityLevel or 0, legacyLevel)
	if currentLevel >= LabUpgradesData.LabCapacity.MaxLevel then return end

	local cost = LabUpgradesData.GetUpgradeCost("LabCapacity", currentLevel)
	if not cost then return end

	local rp = profileData.Currencies.researchPoints or 0
	if rp < cost then return end

	changeData(player, {"Currencies", "researchPoints"}, rp - cost)
	upgrades.LabCapacityLevel = currentLevel + 1
	changeData(player, {"LabUpgrades"}, upgrades)
	changeData(player, {"VirusSlotCount"}, upgrades.LabCapacityLevel + 1)
	local slots, counts = normalizeEquippedSlotState(profileData)
	commitEquipment(player, slots, counts, upgrades)
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
			local value = (vd.ResearchPoints or 0) + ((vd.Cash or 0) * 0.5)
			for _ = 1, count do
				table.insert(candidates, {name = virusName, value = value})
			end
		end
	end
	table.sort(candidates, function(a, b) return a.value > b.value end)

	-- Fill terrain chambers with best viruses
	maxSlots = math.min(maxSlots, 10)
	local newSlots = {}
	local newEquipped = {}
	local filled = 0
	for _, c in ipairs(candidates) do
		if filled >= maxSlots then break end
		filled += 1
		newSlots[filled] = c.name
		newEquipped[c.name] = (newEquipped[c.name] or 0) + 1
	end

	commitEquipment(player, newSlots, newEquipped)
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
				count = tonumber(count) or 0
				if vd and count > 0 then
					rpPerSec += (vd.ResearchPoints or 0) * count
					cashPerSec += (vd.Cash or 0) * count
				end
			end

			local labUpgrades = profileData.LabUpgrades or {}
			local sterileLevel = labUpgrades.SterileConditionsLevel or 0
			local rpBonus = LabUpgradesData.SterileConditions.EffectPerLevel or 0.02
			local rpMultiplier = 1 + sterileLevel * rpBonus
			local cashMultiplier = 1

			if SkillTreeService then
				local skillRP = SkillTreeService:GetStat(player, "ResearchMultiplier") or 0
				local skillCash = SkillTreeService:GetStat(player, "CashMultiplier") or 0
				rpMultiplier += skillRP * 0.1
				cashMultiplier += skillCash * 0.1
			end

			rpPerSec = math.floor(rpPerSec * rpMultiplier)
			cashPerSec = math.floor(cashPerSec * cashMultiplier)

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
					virus = VirusData.RollVirusWithNumericalRarity(luckMult * (1 + labLuck))
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
