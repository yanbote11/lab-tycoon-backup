-- VirusService.lua
-- Handles virus rolling logic, earnings calculations (non-Superbullet module)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local VirusData = require(ReplicatedStorage.Modules.VirusData)
local LabUpgradesData = require(ReplicatedStorage.SharedSource.Datas.LabUpgradesData)

local VirusService = {}

-- Per-player state (not serialized)
VirusService.RollCooldowns = {}
VirusService.AutoRollLoops = {}
VirusService.EarningLoops = {}
VirusService.CurrentRollResult = {} -- [player] = virusData

-- Lazy-loaded Knit service refs
local _ProfileService
local function getPS()
	if not _ProfileService then
		_ProfileService = Knit.GetService("ProfileService")
	end
	return _ProfileService
end

local _SkillTreeService
local function getSTS()
	if not _SkillTreeService then
		_SkillTreeService = Knit.GetService("SkillTreeService")
	end
	return _SkillTreeService
end

-- Calculate effective luck for a player
function VirusService.GetEffectiveLuck(player)
	local ProfileService = getPS()
	local _, profileData = ProfileService:GetProfile(player)
	if not profileData then return 1 end

	local rebirthMult = profileData.RebirthLuckMultiplier or 1
	local labBonuses = LabUpgradesData.GetTotalLuckBonus(profileData.LabUpgrades or {}) + 1

	local skillTreeService = getSTS()
	local skillLuck = skillTreeService and skillTreeService:GetStat(player, "Luck") or 0

	return rebirthMult * labBonuses * (1 + skillLuck * 0.05)
end

-- Check if player is on manual roll cooldown
function VirusService.IsPlayerOnCooldown(player)
	local playerId = tostring(player.UserId)
	local cooldownEnd = VirusService.RollCooldowns[playerId]
	if not cooldownEnd then return false end
	return tick() < cooldownEnd
end

-- Set player cooldown for manual rolls
function VirusService.SetPlayerCooldown(player, cooldownDuration)
	local playerId = tostring(player.UserId)
	VirusService.RollCooldowns[playerId] = tick() + cooldownDuration
end

-- Get remaining cooldown time for player
function VirusService.GetRemainingCooldown(player)
	local playerId = tostring(player.UserId)
	local cooldownEnd = VirusService.RollCooldowns[playerId]
	if not cooldownEnd then return 0 end
	local remaining = cooldownEnd - tick()
	return math.max(0, remaining)
end

-- Clear expired cooldowns
function VirusService.ClearExpiredCooldowns()
	local currentTime = tick()
	for playerId, cooldownEnd in pairs(VirusService.RollCooldowns) do
		if currentTime >= cooldownEnd then
			VirusService.RollCooldowns[playerId] = nil
		end
	end
end

-- Roll for a random virus based on luck using numerical rarity system
function VirusService.RollForVirus(player)
	-- Check cooldown first
	if VirusService.IsPlayerOnCooldown(player) then
		return nil, "ROLL_COOLDOWN"
	end
	
	-- Get cooldown duration from upgrades
	local ProfileService = getPS()
	local _, profileData = ProfileService:GetProfile(player)
	local cooldownDuration = 2.0 -- default 2 seconds
	if profileData and profileData.LabUpgrades then
		cooldownDuration = LabUpgradesData.GetRollCooldown(profileData.LabUpgrades)
	end
	
	-- Set cooldown
	VirusService.SetPlayerCooldown(player, cooldownDuration)
	
	local luck = VirusService.GetEffectiveLuck(player)
	
	-- Use the new numerical rarity system
	local selectedVirus = VirusData.RollVirusWithNumericalRarity(luck)
	
	-- Ensure we have a valid virus
	if not selectedVirus then
		-- Fallback to original system if something goes wrong
		warn("Numerical rarity system failed, falling back to tier system")
		local tiers = VirusData.Tiers
		local adjustedTiers = {}
		for _, tier in ipairs(tiers) do
			local adj = table.clone(tier)
			if tier.Name == "Common" then
				adj.Rarity = math.max(5, tier.Rarity / luck)
			elseif tier.Name == "Transcendent" then
				adj.Rarity = tier.Rarity * luck
			elseif tier.Name == "Celestial" then
				adj.Rarity = tier.Rarity * (luck ^ 0.8)
			elseif tier.Name == "Mythic" then
				adj.Rarity = tier.Rarity * (luck ^ 0.6)
			elseif tier.Name == "Legendary" then
				adj.Rarity = tier.Rarity * (luck ^ 0.4)
			elseif tier.Name == "Epic" then
				adj.Rarity = tier.Rarity * (luck ^ 0.25)
			elseif tier.Name == "Rare" then
				adj.Rarity = tier.Rarity * (luck ^ 0.15)
			elseif tier.Name == "Uncommon" then
				adj.Rarity = tier.Rarity * (luck ^ 0.05)
			end
			table.insert(adjustedTiers, adj)
		end

		local totalRarity = 0
		for _, tier in ipairs(adjustedTiers) do
			totalRarity += tier.Rarity
		end

		local roll = math.random() * totalRarity
		local cumulative = 0
		local selectedTier
		for _, tier in ipairs(adjustedTiers) do
			cumulative += tier.Rarity
			if roll <= cumulative then
				selectedTier = tier
				break
			end
		end

		if not selectedTier then
			selectedTier = adjustedTiers[#adjustedTiers]
		end

		local tierViruses = VirusData.GetVirusesByTier(selectedTier.Name)
		if #tierViruses == 0 then return nil end
		selectedVirus = tierViruses[math.random(1, #tierViruses)]
	end

	if profileData then
		ProfileService:ChangeData(player, {"TotalRolls"}, (profileData.TotalRolls or 0) + 1)
	end

	return selectedVirus
end

-- Calculate earnings from virus inventory
function VirusService.CalculateEarnings(player)
	local ProfileService = getPS()
	local _, profileData = ProfileService:GetProfile(player)
	if not profileData then return 0, 0 end

	local totalRP = 0
	local totalCash = 0
	local inventory = profileData.VirusInventory or {}

	local virusCounts = {}
	for _, virusName in ipairs(inventory) do
		virusCounts[virusName] = (virusCounts[virusName] or 0) + 1
	end

	for virusName in pairs(virusCounts) do
		local virusData = VirusData.GetVirusByName(virusName)
		if virusData then
			local tierData = VirusData.GetTierData(virusData.Tier)
			if tierData then
				local mult = 1
				if tierData.Name == "Common" then mult = 1
				elseif tierData.Name == "Uncommon" then mult = 2
				elseif tierData.Name == "Rare" then mult = 5
				elseif tierData.Name == "Epic" then mult = 15
				elseif tierData.Name == "Legendary" then mult = 40
				elseif tierData.Name == "Mythic" then mult = 100
				elseif tierData.Name == "Celestial" then mult = 300
				elseif tierData.Name == "Transcendent" then mult = 1000
				end

				local skillTreeService = getSTS()
				local rpMult = 1 + (skillTreeService and skillTreeService:GetStat(player, "ResearchMultiplier") or 0) * 0.1
				local cashMult = 1 + (skillTreeService and skillTreeService:GetStat(player, "CashMultiplier") or 0) * 0.1

				local labUpgrades = profileData.LabUpgrades or {}
				local sterileBonus = LabUpgradesData.GetTotalRPBonus(labUpgrades) or 0
				rpMult += sterileBonus

				totalRP += (virusData.ResearchPoints or 5) * mult * rpMult
				totalCash += (virusData.Cash or 10) * mult * cashMult
			end
		end
	end

	return math.floor(totalRP / 5), math.floor(totalCash / 5)
end

-- Periodic cleanup of expired cooldowns
spawn(function()
	while true do
		task.wait(60) -- Clean every minute
		VirusService.ClearExpiredCooldowns()
	end
end)

return VirusService
