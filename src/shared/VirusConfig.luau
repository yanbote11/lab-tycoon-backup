-- src/shared/VirusConfig.luau
-- Central config for all virus data. Required by both server and client.

local VirusConfig = {}

-- 7 rarity tiers with weighted roll odds and income
VirusConfig.RARITIES = {
	{
		id = "common",
		name = "Basic Virus",
		displayName = "Common",
		odds = 10,           -- 1 in 10
		dnaPerSec = 1,
		color = Color3.fromRGB(180, 180, 180),
		glowColor = Color3.fromRGB(220, 220, 220),
		particleCount = 5,
	},
	{
		id = "uncommon",
		name = "Mutant Strain",
		displayName = "Uncommon",
		odds = 50,           -- 1 in 50
		dnaPerSec = 5,
		color = Color3.fromRGB(80, 200, 120),
		glowColor = Color3.fromRGB(100, 255, 150),
		particleCount = 10,
	},
	{
		id = "rare",
		name = "Toxic Variant",
		displayName = "Rare",
		odds = 500,          -- 1 in 500
		dnaPerSec = 30,
		color = Color3.fromRGB(60, 120, 220),
		glowColor = Color3.fromRGB(80, 160, 255),
		particleCount = 20,
	},
	{
		id = "epic",
		name = "Bio-Weapon Strain",
		displayName = "Epic",
		odds = 5000,         -- 1 in 5,000
		dnaPerSec = 200,
		color = Color3.fromRGB(160, 60, 220),
		glowColor = Color3.fromRGB(200, 80, 255),
		particleCount = 35,
	},
	{
		id = "legendary",
		name = "Omega Pathogen",
		displayName = "Legendary",
		odds = 50000,        -- 1 in 50,000
		dnaPerSec = 2000,
		color = Color3.fromRGB(255, 160, 0),
		glowColor = Color3.fromRGB(255, 200, 50),
		particleCount = 60,
	},
	{
		id = "mythic",
		name = "Alien Contagion",
		displayName = "Mythic",
		odds = 500000,       -- 1 in 500,000
		dnaPerSec = 25000,
		color = Color3.fromRGB(255, 40, 40),
		glowColor = Color3.fromRGB(255, 80, 80),
		particleCount = 100,
	},
	{
		id = "divine",
		name = "The Singularity",
		displayName = "Divine",
		odds = 5000000,      -- 1 in 5,000,000
		dnaPerSec = 500000,
		color = Color3.fromRGB(255, 215, 0),
		glowColor = Color3.fromRGB(255, 255, 100),
		particleCount = 200,
	},
}

-- Build a lookup by id for O(1) access
VirusConfig.RARITY_BY_ID = {}
for _, rarity in ipairs(VirusConfig.RARITIES) do
	VirusConfig.RARITY_BY_ID[rarity.id] = rarity
end

-- Upgrade costs and increments
VirusConfig.UPGRADES = {
	luck = {
		baseCost = 100,         -- DNA cost for level 1
		costMultiplier = 2.5,   -- each level costs 2.5x more
		increment = 0.25,       -- +0.25x luck per level
		maxLevel = 50,
	},
	rollSpeed = {
		baseCost = 500,
		costMultiplier = 3,
		increment = 0.5,        -- +0.5 rolls/sec per level
		maxLevel = 20,
	},
	labCapacity = {
		baseCost = 200,
		costMultiplier = 2,
		increment = 5,          -- +5 slots per level
		maxLevel = 30,
	},
	dnaMultiplier = {
		baseCost = 1000,
		costMultiplier = 4,
		increment = 0.1,        -- +10% DNA income per level
		maxLevel = 40,
	},
}

-- Rebirth thresholds and rewards
VirusConfig.REBIRTH_TIERS = {
	{ goopRequired = 1000,   luckBonus = 0.5,  label = "Rebirth I" },
	{ goopRequired = 5000,   luckBonus = 1.0,  label = "Rebirth II" },
	{ goopRequired = 20000,  luckBonus = 2.0,  label = "Rebirth III" },
	{ goopRequired = 100000, luckBonus = 5.0,  label = "Rebirth IV" },
	{ goopRequired = 500000, luckBonus = 8.0,  label = "Rebirth V (Prestige)" },
}

-- Goop earned per duplicate roll (scales with rarity)
VirusConfig.GOOP_PER_DUPLICATE = {
	common = 1,
	uncommon = 3,
	rare = 15,
	epic = 75,
	legendary = 400,
	mythic = 2500,
	divine = 20000,
}

-- Gamepass IDs (replace with real IDs from Creator Hub)
VirusConfig.GAMEPASS_IDS = {
	autoRoll = 0,
	vipLab = 0,
	premiumLab = 0,
}

-- Developer Product IDs (replace after creating in Creator Hub)
VirusConfig.PRODUCT_IDS = {
	luckBoost2x = 0,
	luckyPotionPack = 0,
	rebirthSkip = 0,
	mutationBundle = 0,
}

-- Luck boost amounts from Robux products
VirusConfig.PRODUCT_LUCK_BOOSTS = {
	luckBoost2x = { multiplier = 2, duration = 3600 },     -- 1 hour
	luckyPotionPack = { multiplier = 5, duration = 600 },  -- 10 minutes x5
}

return VirusConfig
