# Virus RNG Simulator — Claude Code Context

## Platform
You are building a **Roblox game** using **Luau** (NOT JavaScript, NOT vanilla Lua 5.1, NOT Python).
Luau is Roblox's typed superset of Lua. Always write Luau, never any other language.

---

## Project: Virus RNG Simulator
A Slime RNG-style idle collector. Players roll for rare virus strains, deploy them in a lab
to generate DNA points passively, spend DNA on Luck upgrades, and rebirth for permanent multipliers.

### Core Loop
1. Player presses Roll → RNG returns a virus rarity (Common → Divine)
2. Virus is placed in the Lab → generates DNA/sec passively while AFK
3. DNA spent on Luck, Roll Speed, Lab Capacity upgrades
4. Duplicate rolls produce Goop (secondary currency) for Rebirth
5. Rebirth resets coins/zones but grants permanent Luck multiplier
6. Seasonal events add limited-time exclusive viruses

---

## Rarity Tiers & Odds
| Tier      | Base Odds       | DNA/sec  |
|-----------|-----------------|----------|
| Common    | 1 in 10         | 1        |
| Uncommon  | 1 in 50         | 5        |
| Rare      | 1 in 500        | 30       |
| Epic      | 1 in 5,000      | 200      |
| Legendary | 1 in 50,000     | 2,000    |
| Mythic    | 1 in 500,000    | 25,000   |
| Divine    | 1 in 5,000,000  | 500,000  |

Luck is a multiplier: 2x Luck = odds halved. Max free Luck ~50x. Max paid ~200x.

---

## Architecture — CRITICAL

### Folder → Roblox Service mapping (Rojo convention)
```
src/server/   → ServerScriptService   (.server.luau files)
src/client/   → StarterPlayerScripts  (.client.luau files)
src/shared/   → ReplicatedStorage     (.luau module files)
```

### Rules
- Server scripts: game logic, DataStores, RNG rolls (never trust the client)
- Client scripts: UI updates, input handling, visual effects only
- Shared modules: constants, utility functions, virus data tables
- **All RNG happens server-side.** Client sends a roll request, server validates and responds.
- **Never do RNG on the client** — exploiters can manipulate it.

### RemoteEvents & RemoteFunctions (always in ReplicatedStorage)
- `RollVirus` — RemoteFunction: client requests roll, server returns result
- `UpdateDNA` — RemoteEvent: server fires to client to update DNA display
- `PurchaseUpgrade` — RemoteFunction: client requests upgrade, server validates + applies
- `RebirthRequest` — RemoteFunction: client requests rebirth, server validates + executes

---

## Roblox Services — always use GetService()
```luau
local Players = game:GetService("Players")
local DataStoreService = game:GetService("DataStoreService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local MarketplaceService = game:GetService("MarketplaceService")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
```

---

## DataStore Rules — ALWAYS follow these
```luau
-- Always wrap DataStore calls in pcall with retry logic
local function safeGet(store, key)
    local success, result
    for attempt = 1, 3 do
        success, result = pcall(function()
            return store:GetAsync(key)
        end)
        if success then return result end
        task.wait(2 ^ attempt) -- exponential backoff
    end
    warn("DataStore get failed after 3 attempts for key: " .. key)
    return nil
end

local function safeSet(store, key, value)
    for attempt = 1, 3 do
        local success, err = pcall(function()
            store:SetAsync(key, value)
        end)
        if success then return true end
        task.wait(2 ^ attempt)
    end
    warn("DataStore set failed after 3 attempts for key: " .. key)
    return false
end
```

---

## Player Data Schema
```luau
-- Default player data structure (stored in DataStore)
local DEFAULT_DATA = {
    dna = 0,
    goop = 0,
    luck = 1,
    rollSpeed = 1,          -- rolls per second (auto-roll)
    labCapacity = 10,       -- max viruses in lab
    rebirthCount = 0,
    permanentLuck = 1,      -- multiplier from rebirths
    viruses = {},           -- array of {id, rarity, dnaPerSec}
    index = {},             -- set of discovered rarity strings
    upgrades = {
        luck = 0,
        rollSpeed = 0,
        labCapacity = 0,
        dnaMultiplier = 0,
    },
    gamepasses = {
        autoRoll = false,
        vipLab = false,
    }
}
```

---

## Luau Code Style
```luau
-- Use type annotations
type VirusData = {
    id: string,
    rarity: string,
    dnaPerSec: number,
    color: Color3,
}

-- Use task library (not spawn/wait/delay — those are deprecated)
task.wait(1)
task.spawn(function() end)
task.delay(1, function() end)

-- Use local functions, not global
local function rollVirus(luck: number): VirusData
    -- implementation
end

-- String format for debugging
warn(string.format("Player %s rolled %s", player.Name, result.rarity))
```

---

## Monetization — GamePass & Product IDs
(Fill these in after creating items on Roblox Creator Hub)
```luau
local GAMEPASS_IDS = {
    autoRoll = 0,       -- TODO: replace with real ID
    vipLab = 0,         -- TODO: replace with real ID
    premiumLab = 0,     -- TODO: replace with real ID
}

local PRODUCT_IDS = {
    luckBoost2x = 0,    -- TODO: replace with real ID
    luckyPotionPack = 0,
    rebirthSkip = 0,
    mutationBundle = 0,
}
```

---

## What NOT to do
- NEVER use `wait()` — use `task.wait()` instead
- NEVER use `spawn()` — use `task.spawn()` instead
- NEVER do game logic in LocalScripts — server only
- NEVER trust RemoteEvent arguments from clients without validation
- NEVER use `game.Players.LocalPlayer` in a server script
- NEVER skip pcall on DataStore operations
- NEVER use `require()` on a script that hasn't loaded yet — use WaitForChild

---

## File Naming Convention (Rojo)
- `*.server.luau` — ServerScript (runs on server only)
- `*.client.luau` — LocalScript (runs on client only)  
- `*.luau` — ModuleScript (required by other scripts)

---

## Prompting Tips for This Project
When asking Claude Code for help, be specific:
- "Write a Luau ModuleScript for ReplicatedStorage called VirusConfig that exports the RARITIES table with odds and dnaPerSec for all 7 tiers"
- "Write a server script that handles the RollVirus RemoteFunction — validate the player exists, roll RNG weighted by their luck stat, return the virus data"
- "Fix this error: [paste exact error from Roblox Studio output]"
