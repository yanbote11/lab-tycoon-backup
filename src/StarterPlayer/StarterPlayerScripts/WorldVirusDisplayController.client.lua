local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Knit = require(ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Knit"))
local remotes = ReplicatedStorage:WaitForChild("LabTycoon"):WaitForChild("Remotes")
local equipmentChanged = remotes:WaitForChild("EquipmentChanged")

local DataController = nil
local lastSignature = ""

local function signature(equipped, slots)
	local parts = {}
	for i = 1, 10 do
		local virusName = slots and (slots[i] or slots[tostring(i)])
		if type(virusName) == "string" then
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

local function getEquipped()
	local data = DataController and DataController.Data
	return data and data.EquippedViruses or {}
end

local function getEquippedSlots()
	local data = DataController and DataController.Data
	return data and data.EquippedVirusSlots or {}
end

local function report(force)
	local equipped = getEquipped()
	local slots = getEquippedSlots()
	local sig = signature(equipped, slots)
	if force or sig ~= lastSignature then
		lastSignature = sig
		equipmentChanged:FireServer(equipped)
	end
end

local function waitForClientData()
	local superbulletModule = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Superbullet")
	if not superbulletModule:GetAttribute("SuperbulletClient_Initialized") then
		repeat task.wait(0.1) until superbulletModule:GetAttribute("SuperbulletClient_Initialized")
	end
	local ok, controller = pcall(function()
		return Knit.GetController("DataController")
	end)
	if ok then
		DataController = controller
	end
	if DataController and DataController.WaitUntilProfileLoaded then
		DataController:WaitUntilProfileLoaded()
	end
end

task.spawn(function()
	waitForClientData()
	report(true)
	while true do
		task.wait(1)
		report(false)
	end
end)

equipmentChanged.OnClientEvent:Connect(function(newEquipped, newSlots)
	local data = DataController and DataController.Data
	if data and typeof(newEquipped) == "table" then
		data.EquippedViruses = newEquipped
	end
	if data and typeof(newSlots) == "table" then
		data.EquippedVirusSlots = newSlots
	end
	report(true)
end)
