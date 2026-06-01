-- LabUpgradesData.lua
-- Upgrade definitions for the virus lab tycoon
-- Purchased with Research Points

local LabUpgradesData = {
	Incubator = {
		Name = "Incubator Upgrade",
		Description = "Improve incubation conditions for better virus growth",
		Id = "Incubator",
		BaseCost = 500,
		CostMultiplier = 1.8,
		MaxLevel = 50,
		EffectPerLevel = 0.05, -- +5% luck per level
		EffectType = "Luck",
	},
	SterileConditions = {
		Name = "Sterile Conditions",
		Description = "Reduce contamination risk - viruses produce more Research Points",
		Id = "SterileConditions",
		BaseCost = 750,
		CostMultiplier = 2.0,
		MaxLevel = 30,
		EffectPerLevel = 0.02, -- +2% RP per level
		EffectType = "ResearchMultiplier",
	},
	AutoRoll = {
		Name = "Auto Roll",
		Description = "Automatically roll for new virus strains every few seconds",
		Id = "AutoRoll",
		BaseCost = 2000,
		CostMultiplier = 2.2,
		MaxLevel = 20,
		EffectPerLevel = 1, -- reduces interval by 1 second per level
		EffectType = "AutoRollInterval",
		BaseInterval = 10, -- starts at 10 seconds
		MinInterval = 1,
	},
	LabCapacity = {
		Name = "Lab Capacity",
		Description = "Expand your lab to equip more viruses at once (+1 slot per level)",
		Id = "LabCapacity",
		BaseCost = 1500,
		CostMultiplier = 2.5,
		MaxLevel = 10, -- base 5 + up to 10 more = 15 max from lab
		EffectPerLevel = 1, -- +1 equip slot per level
		EffectType = "EquipSlots",
	},
}

LabUpgradesData.LabCapacity = {
	Name = "Lab Capacity",
	Description = "Expand your lab to equip more viruses simultaneously (+1 slot per level)",
	Id = "LabCapacity",
	BaseCost = 1000,
	CostMultiplier = 2.5,
	MaxLevel = 10,
	EffectPerLevel = 1, -- +1 equip slot per level
	EffectType = "EquipSlots",
}

LabUpgradesData.QuickRoll = {
	Name = "Quick Roll",
	Description = "Reduce manual roll cooldown time (2s ? 0.5s over 20 levels)",
	Id = "QuickRoll",
	BaseCost = 1000,
	CostMultiplier = 2.1,
	MaxLevel = 20,
	BaseCooldown = 2.0, -- starts at 2 seconds
	CooldownReduction = 0.0789, -- (2 - 0.5) / 19 ˜ 0.0789s per level
	MinCooldown = 0.5, -- minimum 0.5 seconds
	EffectType = "RollCooldown",
}

LabUpgradesData.RollSpeed = {
	Name = "Roll Speed",
	Description = "Reduce manual roll cooldown (-0.2s per level, min 1s)",
	Id = "RollSpeed",
	BaseCost = 800,
	CostMultiplier = 2.0,
	MaxLevel = 5,
	BaseCooldown = 2,
	CooldownReduction = 0.2, -- seconds removed per level
	MinCooldown = 1,
	EffectType = "RollCooldown",
}

-- Virus slot purchases (separate from lab upgrades)
local VirusSlotCosts = {}
for i = 2, 10 do
	VirusSlotCosts[i] = math.floor(1000 * (2.5 ^ (i - 2)))
end

function LabUpgradesData.GetSlotCost(slotNumber)
	return VirusSlotCosts[slotNumber] or nil
end

function LabUpgradesData.GetUpgradeCost(upgradeId, currentLevel)
	local upgrade = LabUpgradesData[upgradeId]
	if not upgrade then return nil end
	return math.floor(upgrade.BaseCost * (upgrade.CostMultiplier ^ currentLevel))
end

function LabUpgradesData.GetTotalLuckBonus(labUpgrades)
	local incubatorLevel = labUpgrades.IncubatorLevel or 0
	return incubatorLevel * LabUpgradesData.Incubator.EffectPerLevel
end

function LabUpgradesData.GetTotalRPBonus(labUpgrades)
	local sterileLevel = labUpgrades.SterileConditionsLevel or 0
	return sterileLevel * LabUpgradesData.SterileConditions.EffectPerLevel
end

function LabUpgradesData.GetAutoRollInterval(labUpgrades)
	local autoRollLevel = labUpgrades.AutoRollLevel or 0
	local interval = LabUpgradesData.AutoRoll.BaseInterval - (autoRollLevel * LabUpgradesData.AutoRoll.EffectPerLevel)
	return math.max(interval, LabUpgradesData.AutoRoll.MinInterval)
end

function LabUpgradesData.GetRollCooldown(labUpgrades)
	-- Quick Roll upgrade takes priority (20 levels: 2s -> 0.5s)
	local quickRollLevel = labUpgrades.QuickRollLevel or 0
	if quickRollLevel > 0 then
		local cd = LabUpgradesData.QuickRoll.BaseCooldown - (quickRollLevel * LabUpgradesData.QuickRoll.CooldownReduction)
		return math.max(cd, LabUpgradesData.QuickRoll.MinCooldown)
	end
	
	-- Fallback to legacy RollSpeed upgrade
	local level = labUpgrades.RollSpeedLevel or 0
	local cd = LabUpgradesData.RollSpeed.BaseCooldown - (level * LabUpgradesData.RollSpeed.CooldownReduction)
	return math.max(cd, LabUpgradesData.RollSpeed.MinCooldown)
end

function LabUpgradesData.GetLabCapacityBonus(labUpgrades)
	local level = labUpgrades.LabCapacityLevel or 0
	return level * LabUpgradesData.LabCapacity.EffectPerLevel
end

return LabUpgradesData
