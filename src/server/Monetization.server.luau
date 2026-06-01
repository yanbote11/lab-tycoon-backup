-- src/server/Monetization.server.luau
-- Handles all Robux purchases: GamePasses and Developer Products.
-- Keep this in its own script to stay organized.

local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VirusConfig = require(ReplicatedStorage:WaitForChild("VirusConfig"))

-- Reference the player cache from Main.server.luau via a shared module
-- In a real project, move playerCache to a shared ServerStorage module.
-- For now this script hooks in via _G (only use within server scripts).
-- TODO: Refactor to use a ServerStorage DataManager module.

-- ─── GamePass purchase handler ───────────────────────────────────────────────

MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player: Player, passId: number, purchased: boolean)
	if not purchased then return end

	-- Find which pass this is
	for passName, id in pairs(VirusConfig.GAMEPASS_IDS) do
		if id == passId and id ~= 0 then
			-- Update player cache (Main.server.luau manages playerCache)
			-- This fires the shared event so Main can handle the cache update
			local updateEvent = ReplicatedStorage:FindFirstChild("GrantGamepass")
			if updateEvent then
				updateEvent:Fire(player, passName)
			end
			print(string.format("[Monetization] %s purchased gamepass: %s", player.Name, passName))
			return
		end
	end
end)

-- ─── Developer Product purchase handler ─────────────────────────────────────

MarketplaceService.ProcessReceipt = function(receiptInfo)
	local player = Players:GetPlayerByUserId(receiptInfo.PlayerId)
	if not player then
		-- Player left — re-process next time they join
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local productId = receiptInfo.ProductId

	-- Find product
	for productName, id in pairs(VirusConfig.PRODUCT_IDS) do
		if id == productId and id ~= 0 then
			local grantEvent = ReplicatedStorage:FindFirstChild("GrantProduct")
			if grantEvent then
				grantEvent:Fire(player, productName)
			end
			print(string.format("[Monetization] %s purchased product: %s", player.Name, productName))
			return Enum.ProductPurchaseDecision.PurchaseGranted
		end
	end

	-- Unknown product — still grant to avoid double-charging
	warn("[Monetization] Unknown productId: " .. tostring(productId))
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

-- ─── Check gamepasses on join ────────────────────────────────────────────────
-- Verify existing passes in case player bought before this session

Players.PlayerAdded:Connect(function(player: Player)
	task.wait(3) -- wait for Main.server.luau to load player data first

	for passName, passId in pairs(VirusConfig.GAMEPASS_IDS) do
		if passId ~= 0 then
			local success, hasPass = pcall(function()
				return MarketplaceService:UserOwnsGamePassAsync(player.UserId, passId)
			end)
			if success and hasPass then
				local grantEvent = ReplicatedStorage:FindFirstChild("GrantGamepass")
				if grantEvent then
					grantEvent:Fire(player, passName)
				end
			end
		end
	end
end)

print("[VirusRNG] Monetization handler loaded")
