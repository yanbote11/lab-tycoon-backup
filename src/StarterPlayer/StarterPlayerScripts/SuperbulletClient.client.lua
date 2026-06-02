local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ClientSource = ReplicatedStorage:WaitForChild("ClientSource")
local SuperbulletModule = ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Superbullet")
local Superbullet = require(SuperbulletModule)

-- STEP 1: Load controllers FIRST so they're registered.
-- This lets other scripts (like UILogic) call GetController() without erroring.
local diagErrors = {}
local loadedCount = 0

for _, module in pairs(ClientSource:GetDescendants()) do
	if module:IsA("ModuleScript") and module.Name:match("Controller$") then
		local ok, err = pcall(require, module)
		if not ok then
			table.insert(diagErrors, module.Name .. ": " .. tostring(err))
			task.spawn(error, "[Superbullet] Failed to load " .. module:GetFullName() .. ": " .. tostring(err))
		else
			loadedCount += 1
		end
	end
end

-- STEP 2: Call Start() IMMEDIATELY to set 'started = true'.
-- This allows other scripts to call GetController/GetService.
-- The Init phase may yield waiting for Services folder, but that's fine.
Superbullet.Start():andThen(function()
	SuperbulletModule:SetAttribute("SuperbulletClient_Initialized", true)
end):catch(function(err)
	warn("[SuperbulletClient] Start failed: " .. tostring(err))
	SuperbulletModule:SetAttribute("SuperbulletClient_Initialized", true)
end)

-- STEP 3: Now wait for the server to finish initializing.
-- This ensures the Services folder exists so Init promises can resolve.
-- We do this AFTER Start() so 'started' is true for other scripts.
repeat
	task.wait(0.5)
until SuperbulletModule:GetAttribute("SuperbulletServer_Initialized") == true

-- Safety net: if Start() still hasn't resolved within 30 seconds of server init,
-- force it (shouldn't happen since Services folder now exists)
task.delay(30, function()
	if not SuperbulletModule:GetAttribute("SuperbulletClient_Initialized") then
		warn("[SuperbulletClient] Start() safety timeout -- forcing initialization")
		SuperbulletModule:SetAttribute("SuperbulletClient_Initialized", true)
	end
end)
