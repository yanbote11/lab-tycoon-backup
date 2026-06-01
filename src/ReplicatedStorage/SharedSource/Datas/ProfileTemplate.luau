-- Roblox Services
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Datas
local SkillTreeSettings = require(ReplicatedStorage.SharedSource.Datas.SkillTreeSettings)
local CurrencySettings = require(ReplicatedStorage.SharedSource.Datas.CurrencySettings)
local RebirthSettings = require(ReplicatedStorage.SharedSource.Datas.RebirthSettings)
local BuildProfileTemplate_ForLevel = require(ReplicatedStorage.SharedSource.Utilities.Levels.BuildProfileTemplate_ForLevel)

-- Module
local ProfileTemplate = {}

-- Initialize default Skill Tree data
-- Uses configuration from SkillTreeSettings.Defaults
ProfileTemplate.SkillTree = {
	Stats = SkillTreeSettings.Defaults.Stats,
	UnlockedSkills = SkillTreeSettings.Defaults.UnlockedSkills,
}

-- Initialize Leveling data from LevelingConfig
ProfileTemplate.Leveling = BuildProfileTemplate_ForLevel.GenerateLevelingData()

ProfileTemplate.Rebirths = {}
for _, rebirthType in ipairs(RebirthSettings.GetTypeIds()) do
	ProfileTemplate.Rebirths[rebirthType] = RebirthSettings.BuildProfileDefaults(rebirthType)
end

-- Add all currencies from settings with their default values
ProfileTemplate.Currencies = {}
for _, currency in ipairs(CurrencySettings.Currencies) do
	ProfileTemplate.Currencies[currency.Id] = currency.DefaultValue
end

-- Tycoon System fields
-- Virus Lab System fields
ProfileTemplate.VirusInventory = {}		-- Array of virus names owned by player
ProfileTemplate.EquippedViruses = {}		-- { [virusName] = countEquipped } viruses generating income
ProfileTemplate.VirusSlots = {}		-- { [slotIndex] = virusName or nil }
ProfileTemplate.VirusSlotCount = 1	-- Number of unlocked virus slots
ProfileTemplate.VirusEarnings = {	-- Per-second earnings from active viruses
	ResearchPoints = 0,
	Cash = 0,
}
ProfileTemplate.RebirthCount = 0
ProfileTemplate.RebirthLuckMultiplier = 1
ProfileTemplate.TotalRolls = 0

-- Lab upgrades purchased with Research Points
ProfileTemplate.LabUpgrades = {
	IncubatorLevel = 0,
	SterileConditionsLevel = 0,
	AutoRollLevel = 0,
	AutoRollEnabled = false,
	LabCapacityLevel = 0,
	RollSpeedLevel = 0,
}

ProfileTemplate.TycoonResetOrders = {}
ProfileTemplate.TycoonProgress = {
	["My Tycoon"] = {},
}
ProfileTemplate.CurrentTycoon = "My Tycoon"
ProfileTemplate.UncollectedCash = {
	["My Tycoon"] = 0,
}
ProfileTemplate.CashGainPerSecond = {
	["My Tycoon"] = 1,
}

return ProfileTemplate
