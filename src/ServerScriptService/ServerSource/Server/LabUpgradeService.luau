-- LabUpgradeService.lua
-- Handles lab upgrades purchased with Research Points (non-Superbullet module)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Knit = require(ReplicatedStorage.Packages.Knit)

local LabUpgradesData = require(ReplicatedStorage.SharedSource.Datas.LabUpgradesData)

local LabUpgradeService = {}

local _ProfileService
local function getPS()
	if not _ProfileService then
		_ProfileService = Knit.GetService("ProfileService")
	end
	return _ProfileService
end

function LabUpgradeService.BuyUpgrade(player, upgradeId)
	local ProfileService = getPS()
	local _, profileData = ProfileService:GetProfile(player)
	if not profileData then return false, "No profile" end

	local upgrade = LabUpgradesData[upgradeId]
	if not upgrade then return false, "Invalid upgrade" end

	local upgrades = profileData.LabUpgrades or {}
	local levelKey = upgradeId .. "Level"
	local currentLevel = upgrades[levelKey] or 0

	if currentLevel >= upgrade.MaxLevel then
		return false, "Max level reached!"
	end

	local cost = LabUpgradesData.GetUpgradeCost(upgradeId, currentLevel)
	if not cost then return false, "Invalid cost" end

	local rp = profileData.Currencies.researchPoints or 0
	if rp < cost then
		return false, "Not enough Research Points! Need " .. tostring(cost)
	end

	-- Spend Research Points
	ProfileService:ChangeData(player, {"Currencies", "researchPoints"}, rp - cost)

	-- Apply upgrade
	upgrades[levelKey] = currentLevel + 1
	ProfileService:ChangeData(player, {"LabUpgrades"}, upgrades)

	-- If buying first level of auto-roll, enable it
	if upgradeId == "AutoRoll" and currentLevel == 0 then
		upgrades.AutoRollEnabled = true
		ProfileService:ChangeData(player, {"LabUpgrades"}, upgrades)
	end

	return true, upgrade.Name .. " upgraded to level " .. (currentLevel + 1)
end

function LabUpgradeService.BuyVirusSlot(player)
	local ProfileService = getPS()
	local _, profileData = ProfileService:GetProfile(player)
	if not profileData then return false, "No profile" end

	local currentSlots = profileData.VirusSlotCount or 1
	local cost = LabUpgradesData.GetSlotCost(currentSlots + 1)

	if not cost then
		return false, "Max slots reached!"
	end

	local rp = profileData.Currencies.researchPoints or 0
	if rp < cost then
		return false, "Not enough Research Points! Need " .. tostring(cost)
	end

	ProfileService:ChangeData(player, {"Currencies", "researchPoints"}, rp - cost)
	ProfileService:ChangeData(player, {"VirusSlotCount"}, currentSlots + 1)

	return true, "Virus Slot " .. (currentSlots + 1) .. " unlocked!"
end

return LabUpgradeService
