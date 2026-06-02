local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
local VirusData = require(ReplicatedStorage:WaitForChild("Modules"):WaitForChild("VirusData"))
local remotes = ReplicatedStorage:WaitForChild("LabTycoon"):WaitForChild("Remotes")

local equipmentChangedRemote = remotes:WaitForChild("EquipmentChanged")
local tycoons = Workspace:WaitForChild("Tycoons")
local assignedByPlayer: {[Player]: Model} = {}
local reportedEquippedByPlayer: {[Player]: {[string]: number}} = {}
local lastRenderedSignatureByPlayer: {[Player]: string} = {}
local profileService = nil

local TIER_ORDER = {
	Common = 1,
	Uncommon = 2,
	Rare = 3,
	Epic = 4,
	Legendary = 5,
	Mythic = 6,
	Celestial = 7,
	Transcendent = 8,
}

local function getProfileService()
	if profileService then
		return profileService
	end
	local superbulletModule = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Superbullet")
	if not superbulletModule:GetAttribute("SuperbulletServer_Initialized") then
		repeat task.wait(0.1) until superbulletModule:GetAttribute("SuperbulletServer_Initialized")
	end
	local ok, service = pcall(function()
		return Knit.GetService("ProfileService")
	end)
	if ok then
		profileService = service
	end
	return profileService
end

local function getProfileData(player: Player)
	local service = getProfileService()
	if not service then
		return nil
	end
	local ok, _, data = pcall(function()
		return service:GetProfile(player)
	end)
	if ok then
		return data
	end
	return nil
end

local VIRUS_SHAPES = {
	["Common Cold"] = {spikes = 8, rings = 1, pulse = 0.90},
	["Hay Fever"] = {spikes = 12, rings = 1, pulse = 0.80},
	["Stomach Bug"] = {spikes = 10, rings = 2, pulse = 0.75},
	Flu = {spikes = 14, rings = 1, pulse = 0.95},
	["Strep Throat"] = {spikes = 16, rings = 2, pulse = 0.88},
	["Pink Eye"] = {spikes = 10, rings = 3, pulse = 0.82},
	SARS = {spikes = 18, rings = 2, pulse = 1.05},
	Rabies = {spikes = 20, rings = 1, pulse = 1.10},
	Tuberculosis = {spikes = 12, rings = 3, pulse = 0.92},
	Ebola = {spikes = 22, rings = 2, pulse = 1.15},
	HIV = {spikes = 16, rings = 4, pulse = 1.00},
	MERS = {spikes = 18, rings = 3, pulse = 1.08},
	["COVID-19 Modified"] = {spikes = 24, rings = 3, pulse = 1.18},
	Marburg = {spikes = 22, rings = 4, pulse = 1.12},
	["Chimera Virus"] = {spikes = 28, rings = 4, pulse = 1.25},
	["Crimson Plague"] = {spikes = 26, rings = 5, pulse = 1.22},
	["Omega Strain"] = {spikes = 30, rings = 5, pulse = 1.30},
	["Nexus Virus"] = {spikes = 32, rings = 5, pulse = 1.34},
	["The Cure"] = {spikes = 20, rings = 6, pulse = 1.38},
	["Genesis Code"] = {spikes = 34, rings = 6, pulse = 1.42},
}

local function getSortedTycoons(): {Model}
	local list = {}
	for _, child in ipairs(tycoons:GetChildren()) do
		if child:IsA("Model") and tonumber(child.Name) then
			table.insert(list, child)
		end
	end
	table.sort(list, function(a, b)
		return tonumber(a.Name) < tonumber(b.Name)
	end)
	return list
end

local function isTycoonTaken(tycoon: Model): boolean
	for _, assigned in pairs(assignedByPlayer) do
		if assigned == tycoon then
			return true
		end
	end
	return false
end

local function getPlayerTycoon(player: Player): Model?
	local assigned = assignedByPlayer[player]
	if assigned and assigned.Parent then
		return assigned
	end
	local attr = player:GetAttribute("AssignedTycoonNumber")
	if attr then
		local tycoon = tycoons:FindFirstChild(tostring(attr))
		if tycoon and tycoon:IsA("Model") then
			assignedByPlayer[player] = tycoon
			return tycoon
		end
	end
	return nil
end

local function assignTycoon(player: Player): Model?
	local existing = getPlayerTycoon(player)
	if existing then
		return existing
	end
	for _, tycoon in ipairs(getSortedTycoons()) do
		if not isTycoonTaken(tycoon) then
			assignedByPlayer[player] = tycoon
			local tycoonNumber = tonumber(tycoon.Name)
			player:SetAttribute("AssignedTycoonNumber", tycoonNumber)
			tycoon:SetAttribute("OwnerUserId", player.UserId)
			tycoon:SetAttribute("OwnerName", player.DisplayName)
			local label = tycoon:FindFirstChild("PlotLabel", true)
			if label and label:IsA("BillboardGui") then
				local text = label:FindFirstChildWhichIsA("TextLabel", true)
				if text then
					text.Text = player.DisplayName .. "'s Lab"
				end
			end
			return tycoon
		end
	end
	return nil
end

local function spawnAtTycoon(player: Player, character: Model)
	local tycoon = assignTycoon(player)
	if not tycoon then
		return
	end
	local spawn = tycoon:FindFirstChild("AssignedSpawn")
	local root = character:WaitForChild("HumanoidRootPart", 8)
	if spawn and spawn:IsA("BasePart") and root then
		root.CFrame = spawn.CFrame + Vector3.new(0, 4, 0)
	end
end

local function flattenEquipped(equipped: {[string]: number}): {string}
	local list = {}
	for virusName, count in pairs(equipped or {}) do
		for _ = 1, math.max(0, count) do
			table.insert(list, virusName)
		end
	end
	table.sort(list, function(a, b)
		local av = VirusData.GetVirusByName(a)
		local bv = VirusData.GetVirusByName(b)
		local ar = av and av.ResearchPoints or 0
		local br = bv and bv.ResearchPoints or 0
		if ar ~= br then
			return ar > br
		end
		local at = av and TIER_ORDER[av.Tier] or 0
		local bt = bv and TIER_ORDER[bv.Tier] or 0
		if at ~= bt then
			return at > bt
		end
		return a < b
	end)
	return list
end

local function clearSlot(slot: Instance)
	for _, child in ipairs(slot:GetChildren()) do
		if child.Name == "DisplayedVirus" then
			child:Destroy()
		end
	end
end

local function makeBillboard(parent: Instance, adornee: BasePart, virusName: string, tier: string, tierColor: Color3, rarity: number)
	local label = Instance.new("BillboardGui")
	label.Name = "VirusLabel"
	label.Size = UDim2.new(0, 170, 0, 54)
	label.StudsOffset = Vector3.new(0, 7.65, 0)
	label.AlwaysOnTop = true
	label.MaxDistance = 150
	label.Adornee = adornee
	label.Parent = parent

	local text = Instance.new("TextLabel")
	text.BackgroundColor3 = Color3.fromRGB(10, 14, 20)
	text.BackgroundTransparency = 0.12
	text.BorderSizePixel = 0
	text.Size = UDim2.fromScale(1, 1)
	text.Text = virusName .. "\n" .. tier .. " | 1 in " .. tostring(math.floor(1 / rarity))
	text.TextColor3 = tierColor
	text.TextScaled = true
	text.TextWrapped = true
	text.Font = Enum.Font.GothamBold
	text.Parent = label

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 6)
	corner.Parent = text

	local stroke = Instance.new("UIStroke")
	stroke.Color = tierColor
	stroke.Thickness = 1.25
	stroke.Transparency = 0.15
	stroke.Parent = text
end

local function createVirusVisual(slot: Instance, virusName: string)
	local anchor = slot:FindFirstChild("VirusAnchor")
	local virus = VirusData.GetVirusByName(virusName)
	if not anchor or not anchor:IsA("BasePart") or not virus then
		return
	end
	local tierData = VirusData.GetTierData(virus.Tier)
	local tierColor = tierData and tierData.Color or Color3.new(1, 1, 1)
	local shape = VIRUS_SHAPES[virusName] or {spikes = 12, rings = 2, pulse = 1}

	local model = Instance.new("Model")
	model.Name = "DisplayedVirus"
	model:SetAttribute("VirusName", virusName)
	model.Parent = slot

	local cf = anchor.CFrame
	local core = Instance.new("Part")
	core.Name = "Core"
	core.Shape = Enum.PartType.Ball
	core.Size = Vector3.new(4.35, 4.35, 4.35) * shape.pulse
	core.CFrame = cf
	core.Color = tierColor
	core.Material = Enum.Material.Neon
	core.Transparency = 0.03
	core.Anchored = true
	core.CanCollide = false
	core.Parent = model
	model.PrimaryPart = core

	local shell = Instance.new("Part")
	shell.Name = "GlassShell"
	shell.Shape = Enum.PartType.Ball
	shell.Size = core.Size + Vector3.new(1.2, 1.2, 1.2)
	shell.CFrame = cf
	shell.Color = tierColor:Lerp(Color3.new(1, 1, 1), 0.4)
	shell.Material = Enum.Material.Glass
	shell.Transparency = 0.58
	shell.Anchored = true
	shell.CanCollide = false
	shell.Parent = model

	for i = 1, shape.spikes do
		local angle = (math.pi * 2 / shape.spikes) * i
		local spike = Instance.new("Part")
		spike.Name = "Spike"
		spike.Size = Vector3.new(0.48, 0.48, 2.48 + (i % 3) * 0.14)
		spike.CFrame = cf * CFrame.Angles(0, angle, math.rad((i % 5) * 18)) * CFrame.new(0, 0, -3.375 * shape.pulse)
		spike.Color = tierColor:Lerp(Color3.new(1, 1, 1), 0.12)
		spike.Material = Enum.Material.Neon
		spike.Transparency = 0.08
		spike.Anchored = true
		spike.CanCollide = false
		spike.Parent = model
	end

	for i = 1, shape.rings do
		local ring = Instance.new("Part")
		ring.Name = "OrbitRing"
		ring.Shape = Enum.PartType.Cylinder
		ring.Size = Vector3.new(0.12, 6.45 + i * 0.375, 6.45 + i * 0.375)
		ring.CFrame = cf * CFrame.Angles(math.rad(90), math.rad(i * 30), math.rad(i * 18))
		ring.Color = tierColor:Lerp(Color3.new(1, 1, 1), 0.25)
		ring.Material = Enum.Material.Neon
		ring.Transparency = 0.48
		ring.Anchored = true
		ring.CanCollide = false
		ring.Parent = model
	end

	local light = Instance.new("PointLight")
	light.Name = "VirusGlow"
	light.Color = tierColor
	light.Brightness = 1.1
	light.Range = 21
	light.Parent = core

	makeBillboard(model, core, virusName, virus.Tier, tierColor, virus.NumericalRarity)
end

local function getSlotAssignment(slotMap, index: number): string?
	if typeof(slotMap) ~= "table" then
		return nil
	end
	local virusName = slotMap[index] or slotMap[tostring(index)]
	if type(virusName) == "string" then
		return virusName
	end
	return nil
end

local function refreshWorldDisplay(player: Player)
	local tycoon = getPlayerTycoon(player)
	if not tycoon then
		return
	end
	local slotsFolder = tycoon:FindFirstChild("VirusDisplaySlots")
	if not slotsFolder then
		return
	end
	local profileData = getProfileData(player)
	local slotMap = profileData and profileData.EquippedVirusSlots
	local equippedList = nil
	if typeof(slotMap) ~= "table" then
		equippedList = flattenEquipped((profileData and profileData.EquippedViruses) or reportedEquippedByPlayer[player] or {})
	end
	for i = 1, 10 do
		local slot = slotsFolder:FindFirstChild("Slot" .. i)
		if slot then
			clearSlot(slot)
			local virusName = getSlotAssignment(slotMap, i) or (equippedList and equippedList[i])
			if virusName then
				createVirusVisual(slot, virusName)
			end
		end
	end
end

local function getEquippedSignature(equipped: {[string]: number}?, slotMap): string
	local parts = {}
	for i = 1, 10 do
		local virusName = getSlotAssignment(slotMap, i)
		if virusName then
			table.insert(parts, "slot" .. tostring(i) .. "=" .. virusName)
		end
	end
	if #parts == 0 then
		for virusName, count in pairs(equipped or {}) do
			table.insert(parts, virusName .. ":" .. tostring(count))
		end
	end
	table.sort(parts)
	return table.concat(parts, "|")
end

local function syncEquipment(player: Player, force: boolean?)
	local profileData = getProfileData(player)
	local equipped = (profileData and profileData.EquippedViruses) or reportedEquippedByPlayer[player] or {}
	local slotMap = profileData and profileData.EquippedVirusSlots
	local signature = getEquippedSignature(equipped, slotMap)
	if force or lastRenderedSignatureByPlayer[player] ~= signature then
		lastRenderedSignatureByPlayer[player] = signature
		refreshWorldDisplay(player)
	end
end

Players.PlayerAdded:Connect(function(player)
	assignTycoon(player)
	player.CharacterAdded:Connect(function(character)
		spawnAtTycoon(player, character)
	end)
	if player.Character then
		spawnAtTycoon(player, player.Character)
	end
	task.defer(syncEquipment, player, true)
end)

Players.PlayerRemoving:Connect(function(player)
	local tycoon = assignedByPlayer[player]
	if tycoon then
		tycoon:SetAttribute("OwnerUserId", nil)
		tycoon:SetAttribute("OwnerName", nil)
		local label = tycoon:FindFirstChild("PlotLabel", true)
		if label and label:IsA("BillboardGui") then
			local text = label:FindFirstChildWhichIsA("TextLabel", true)
			if text then
				text.Text = "Open Lab"
			end
		end
	end
	assignedByPlayer[player] = nil
	reportedEquippedByPlayer[player] = nil
	lastRenderedSignatureByPlayer[player] = nil
end)

equipmentChangedRemote.OnServerEvent:Connect(function(player, equipped)
	if typeof(equipped) == "table" then
		reportedEquippedByPlayer[player] = equipped
	end
	syncEquipment(player, true)
end)

task.spawn(function()
	while true do
		task.wait(0.75)
		for _, player in ipairs(Players:GetPlayers()) do
			syncEquipment(player, false)
		end
	end
end)

for _, player in ipairs(Players:GetPlayers()) do
	task.spawn(function()
		assignTycoon(player)
		if player.Character then
			spawnAtTycoon(player, player.Character)
		end
		player.CharacterAdded:Connect(function(character)
			spawnAtTycoon(player, character)
		end)
		syncEquipment(player, true)
	end)
end
