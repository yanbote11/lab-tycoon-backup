-- src/server/Main.server.luau
-- Core server script: player data loading/saving, DNA income loop, remote setup.

local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")

local VirusConfig = require(ReplicatedStorage:WaitForChild("VirusConfig"))
local PlayerData = require(ReplicatedStorage:WaitForChild("PlayerData"))

-- DataStore
local playerStore = DataStoreService:GetDataStore("VirusRNG_v1")

-- In-memory cache: UserId -> data table
local playerCache: {[number]: table} = {}

-- ─── DataStore helpers ────────────────────────────────────────────────────────

local function safeGet(key: string): any
	for attempt = 1, 3 do
		local success, result = pcall(function()
			return playerStore:GetAsync(key)
		end)
		if success then return result end
		warn(string.format("[DataStore] GetAsync failed (attempt %d): %s", attempt, tostring(result)))
		task.wait(2 ^ attempt)
	end
	return nil
end

local function safeSet(key: string, value: any): boolean
	for attempt = 1, 3 do
		local success, err = pcall(function()
			playerStore:SetAsync(key, value)
		end)
		if success then return true end
		warn(string.format("[DataStore] SetAsync failed (attempt %d): %s", attempt, tostring(err)))
		task.wait(2 ^ attempt)
	end
	return false
end

-- ─── RemoteEvents / RemoteFunctions setup ────────────────────────────────────

local function getOrCreate(parent: Instance, className: string, name: string): Instance
	local existing = parent:FindFirstChild(name)
	if existing then return existing end
	local obj = Instance.new(className)
	obj.Name = name
	obj.Parent = parent
	return obj
end

local RollVirus        = getOrCreate(ReplicatedStorage, "RemoteFunction", "RollVirus")
local PurchaseUpgrade  = getOrCreate(ReplicatedStorage, "RemoteFunction", "PurchaseUpgrade")
local RebirthRequest   = getOrCreate(ReplicatedStorage, "RemoteFunction", "RebirthRequest")
local UpdateDNA        = getOrCreate(ReplicatedStorage, "RemoteEvent",    "UpdateDNA")
local SyncData         = getOrCreate(ReplicatedStorage, "RemoteEvent",    "SyncData")

-- ─── RNG Roll logic ──────────────────────────────────────────────────────────

-- Weighted random roll based on player's total luck
local function rollForVirus(totalLuck: number): table
	-- Build cumulative weight table (lower odds = rarer = higher weight target)
	-- We roll a number 1..totalWeight, find which tier it lands in
	local roll = math.random(1, math.floor(VirusConfig.RARITIES[1].odds / totalLuck))
	                              -- Simplified: roll 1..commonOdds/luck
	-- Walk rarities from rarest to most common
	for i = #VirusConfig.RARITIES, 1, -1 do
		local rarity = VirusConfig.RARITIES[i]
		local adjustedOdds = math.max(1, math.floor(rarity.odds / totalLuck))
		if math.random(1, adjustedOdds) == 1 then
			return rarity
		end
	end
	-- Fallback to common
	return VirusConfig.RARITIES[1]
end

-- ─── RemoteFunction handlers ─────────────────────────────────────────────────

RollVirus.OnServerInvoke = function(player: Player): table?
	local data = playerCache[player.UserId]
	if not data then return nil end

	local totalLuck = PlayerData.getTotalLuck(data)
	local result = rollForVirus(totalLuck)
	data.totalRolls = data.totalRolls + 1

	local alreadyHas = data.index[result.id]

	if alreadyHas then
		-- Duplicate: award Goop instead
		local goopGain = VirusConfig.GOOP_PER_DUPLICATE[result.id] or 1
		data.goop = data.goop + goopGain
	else
		-- First discovery: add to index
		data.index[result.id] = true
	end

	-- Always add to lab if capacity allows
	local deployed = #data.viruses
	if deployed < data.labCapacity then
		table.insert(data.viruses, {
			instanceId = HttpService and HttpService:GenerateGUID(false) or tostring(os.clock()),
			rarityId = result.id,
			dnaPerSec = result.dnaPerSec,
		})
	end

	-- Sync updated data to client
	SyncData:FireClient(player, data)

	return {
		rarityId = result.id,
		rarityName = result.displayName,
		virusName = result.name,
		isDuplicate = alreadyHas,
		color = { r = result.color.R, g = result.color.G, b = result.color.B },
	}
end

PurchaseUpgrade.OnServerInvoke = function(player: Player, upgradeType: string): (boolean, string)
	local data = playerCache[player.UserId]
	if not data then return false, "No data found" end

	local upgradeDef = VirusConfig.UPGRADES[upgradeType]
	if not upgradeDef then return false, "Unknown upgrade: " .. tostring(upgradeType) end

	local currentLevel = data.upgrades[upgradeType] or 0
	if currentLevel >= upgradeDef.maxLevel then
		return false, "Already at max level"
	end

	local cost = math.floor(upgradeDef.baseCost * (upgradeDef.costMultiplier ^ currentLevel))
	if data.dna < cost then
		return false, string.format("Not enough DNA (need %d, have %d)", cost, math.floor(data.dna))
	end

	-- Apply upgrade
	data.dna = data.dna - cost
	data.upgrades[upgradeType] = currentLevel + 1

	-- Apply stat change
	if upgradeType == "luck" then
		data.luck = 1 + (data.upgrades.luck * upgradeDef.increment)
	elseif upgradeType == "rollSpeed" then
		data.rollSpeed = 1 + (data.upgrades.rollSpeed * upgradeDef.increment)
	elseif upgradeType == "labCapacity" then
		data.labCapacity = 10 + (data.upgrades.labCapacity * upgradeDef.increment)
	end

	SyncData:FireClient(player, data)
	return true, "Success"
end

RebirthRequest.OnServerInvoke = function(player: Player): (boolean, string)
	local data = playerCache[player.UserId]
	if not data then return false, "No data" end

	-- Find next rebirth tier
	local nextTier = nil
	for _, tier in ipairs(VirusConfig.REBIRTH_TIERS) do
		if data.rebirthCount < #VirusConfig.REBIRTH_TIERS then
			nextTier = VirusConfig.REBIRTH_TIERS[data.rebirthCount + 1]
			break
		end
	end

	if not nextTier then return false, "Already at max rebirth" end
	if data.goop < nextTier.goopRequired then
		return false, string.format("Need %d Goop (have %d)", nextTier.goopRequired, math.floor(data.goop))
	end

	-- Apply rebirth
	data.goop = data.goop - nextTier.goopRequired
	data.rebirthCount = data.rebirthCount + 1
	data.totalRebirths = (data.totalRebirths or 0) + 1
	data.permanentLuck = (data.permanentLuck or 1) + nextTier.luckBonus

	-- Reset progress (keep permanent stats and gamepasses)
	data.dna = 0
	data.luck = 1
	data.rollSpeed = 1
	data.labCapacity = 10
	data.viruses = {}
	data.upgrades = { luck = 0, rollSpeed = 0, labCapacity = 0, dnaMultiplier = 0 }

	SyncData:FireClient(player, data)
	return true, nextTier.label
end

-- ─── Player join / leave ─────────────────────────────────────────────────────

local function onPlayerAdded(player: Player)
	local key = "player_" .. player.UserId
	local saved = safeGet(key)

	local data
	if saved then
		data = PlayerData.mergeWithDefaults(saved)
	else
		data = PlayerData.getDefault()
	end

	playerCache[player.UserId] = data

	-- Send initial data to client once character loads
	player.CharacterAdded:Connect(function()
		task.wait(0.5) -- brief wait for client scripts to init
		SyncData:FireClient(player, data)
	end)

	-- Also fire immediately if character already exists
	if player.Character then
		task.wait(0.5)
		SyncData:FireClient(player, data)
	end
end

local function onPlayerRemoving(player: Player)
	local data = playerCache[player.UserId]
	if data then
		local key = "player_" .. player.UserId
		safeSet(key, data)
		playerCache[player.UserId] = nil
	end
end

Players.PlayerAdded:Connect(onPlayerAdded)
Players.PlayerRemoving:Connect(onPlayerRemoving)

-- Handle players already in game when script loads
for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(onPlayerAdded, player)
end

-- Save all on server shutdown
game:BindToClose(function()
	for userId, data in pairs(playerCache) do
		local key = "player_" .. userId
		safeSet(key, data)
	end
end)

-- ─── DNA Income Tick (every 1 second) ───────────────────────────────────────

local DNA_TICK = 1 -- seconds between income ticks

task.spawn(function()
	while true do
		task.wait(DNA_TICK)
		for _, player in ipairs(Players:GetPlayers()) do
			local data = playerCache[player.UserId]
			if data then
				local dnaGain = PlayerData.getDNAPerSec(data, VirusConfig) * DNA_TICK
				if dnaGain > 0 then
					data.dna = data.dna + dnaGain
					UpdateDNA:FireClient(player, data.dna, data.goop)
				end
			end
		end
	end
end)

print("[VirusRNG] Server loaded successfully")
