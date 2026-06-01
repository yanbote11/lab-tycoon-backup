-- src/shared/PlayerData.luau
-- Player data schema and deep-copy utility. Used by server to init new players.

local PlayerData = {}

-- Default data for a brand new player
function PlayerData.getDefault(): table
	return {
		dna = 0,
		goop = 0,
		luck = 1,                 -- current effective luck (base + upgrades)
		permanentLuck = 1,        -- luck from rebirths (persists across rebirths)
		rollSpeed = 1,            -- auto-rolls per second when auto-roll pass active
		labCapacity = 10,         -- max viruses deployed in lab
		rebirthCount = 0,
		viruses = {},             -- array of {instanceId, rarityId, dnaPerSec}
		index = {},               -- set: rarityId -> true (discovered rarities)
		upgrades = {
			luck = 0,
			rollSpeed = 0,
			labCapacity = 0,
			dnaMultiplier = 0,
		},
		gamepasses = {
			autoRoll = false,
			vipLab = false,
			premiumLab = false,
		},
		activeLuckBoosts = {},    -- array of {multiplier, expiresAt}
		totalRolls = 0,
		totalRebirths = 0,
		joinDate = os.time(),
	}
end

-- Deep copy a table (safe for storing/cloning player data)
function PlayerData.deepCopy(original: table): table
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			copy[k] = PlayerData.deepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

-- Merge saved data with defaults (handles new fields added in updates)
function PlayerData.mergeWithDefaults(saved: table): table
	local defaults = PlayerData.getDefault()
	local merged = PlayerData.deepCopy(defaults)
	for k, v in pairs(saved) do
		if type(v) == "table" and type(merged[k]) == "table" then
			for subK, subV in pairs(v) do
				merged[k][subK] = subV
			end
		else
			merged[k] = v
		end
	end
	return merged
end

-- Calculate total luck multiplier from all sources
function PlayerData.getTotalLuck(data: table): number
	local base = data.luck or 1
	local permanent = data.permanentLuck or 1
	local boostTotal = 1

	local now = os.time()
	if data.activeLuckBoosts then
		for _, boost in ipairs(data.activeLuckBoosts) do
			if boost.expiresAt > now then
				boostTotal = boostTotal * boost.multiplier
			end
		end
	end

	return base * permanent * boostTotal
end

-- Calculate total DNA per second from deployed viruses
function PlayerData.getDNAPerSec(data: table, VirusConfig: table): number
	local total = 0
	local dnaMultLevel = (data.upgrades and data.upgrades.dnaMultiplier) or 0
	local dnaMultBonus = 1 + (dnaMultLevel * VirusConfig.UPGRADES.dnaMultiplier.increment)

	if data.gamepasses and data.gamepasses.premiumLab then
		dnaMultBonus = dnaMultBonus * 1.5
	end
	if data.gamepasses and data.gamepasses.vipLab then
		dnaMultBonus = dnaMultBonus * 2
	end

	for _, virus in ipairs(data.viruses or {}) do
		local rarityData = VirusConfig.RARITY_BY_ID[virus.rarityId]
		if rarityData then
			total = total + (rarityData.dnaPerSec * dnaMultBonus)
		end
	end

	return total
end

return PlayerData
