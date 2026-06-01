# 🦠 Virus RNG Simulator

A Slime RNG-style idle collector on Roblox. Roll for rare virus strains, build a lab empire, chase the 1-in-5-million Divine.

---

## Quick Start (Do this in order)

### 1. Install tools
```bash
# Install Node.js from nodejs.org first, then:
npm install -g rojo
```

### 2. Install Rojo plugin in Roblox Studio
- Open Roblox Studio
- Go to Plugins → Manage Plugins → search "Rojo" → install
- Enable HTTP Requests: File → Game Settings → Security → Allow HTTP Requests ✓

### 3. Set up Claude Code
```bash
# Install Claude Code (needs Anthropic API key)
npm install -g @anthropic-ai/claude-code

# Add Roblox Studio MCP (optional but powerful — do this after Week 2)
claude mcp add robloxstudio -- npx -y robloxstudio-mcp@latest
```

### 4. Clone and sync
```bash
cd virus-rng-simulator
rojo serve
```
Then in Roblox Studio: click the Rojo plugin → Connect.
Your `src/` files now live-sync into Studio.

### 5. Run Claude Code
```bash
claude
```
Claude will read `CLAUDE.md` automatically and know it's building a Roblox Luau project.

---

## Project Structure

```
virus-rng-simulator/
├── CLAUDE.md                        ← Claude Code context (read this first)
├── README.md                        ← This file
├── default.project.json             ← Rojo mapping
└── src/
    ├── server/
    │   ├── Main.server.luau         ← Player data, DNA ticks, roll logic
    │   └── Monetization.server.luau ← Robux purchases
    ├── client/
    │   └── UI.client.luau           ← Roll button, DNA display, popups
    └── shared/
        ├── VirusConfig.luau         ← All game data (rarities, upgrades, IDs)
        └── PlayerData.luau          ← Data schema, save/load helpers
```

---

## Who Does What

| Task | Person |
|------|--------|
| Running Claude Code, fixing Luau scripts, DataStores | Dev A (scripter) |
| Building lab map in Studio, making virus assets, UI layout | Dev B (builder) |
| Playtesting, TikTok content, update planning | Both |

---

## Before You Can Earn Robux

1. Create GamePasses on [create.roblox.com](https://create.roblox.com) → Monetization
2. Create Developer Products for consumables
3. Replace the `0` placeholder IDs in `src/shared/VirusConfig.luau`:
   ```luau
   VirusConfig.GAMEPASS_IDS = {
       autoRoll = 123456789,  -- paste real ID here
       vipLab   = 987654321,
   }
   ```

---

## Useful Claude Code Prompts (copy-paste these)

```
"Add an auto-roll system to Main.server.luau that fires RollVirus automatically
 every (1 / player.rollSpeed) seconds for players who own the autoRoll gamepass"

"Write a Luau ModuleScript called UpgradeCalculator in ReplicatedStorage that
 takes an upgradeType and currentLevel and returns the DNA cost for the next level
 using the formula from VirusConfig.UPGRADES"

"Fix this Roblox Studio error: [paste error here]"

"Add a leaderboard using OrderedDataStore that tracks top 10 players by
 total DNA ever earned, updated every 60 seconds"
```

---

## Week-by-Week Build Plan

| Week | Goal |
|------|------|
| 1 | Setup — Rojo, Claude Code, CLAUDE.md, blank project |
| 2 | Core roll system — 7 rarities, luck multiplier |
| 3 | Lab & passive DNA income — DataStore saving |
| 4 | Upgrades shop — Luck, Roll Speed, Capacity, Rebirth |
| 5 | Virus Index — discoverable dex, unlock zones |
| 6 | Monetization — GamePasses, Developer Products, playtest |
| 7 | Visual polish — particles, sound, leaderboard |
| 8 | Launch — public, TikTok post, DevForum post |
| 9 | Post-launch — fix top bugs, new viruses, game codes |
| 10 | First event — Summer Outbreak, 3 exclusive viruses |

---

## Revenue (realistic)

| Phase | Estimate |
|-------|----------|
| Month 1 launch | $200 – $800 |
| Month 2–3 with updates | $500 – $3,000 |
| Month 6+ with events | $2,000 – $10,000/mo |

Roblox takes 30%. DevEx rate ~$0.0035/Robux. Need 30,000 earned Robux minimum to cash out.
