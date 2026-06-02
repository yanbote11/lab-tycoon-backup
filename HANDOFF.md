# Lab Tycoon — AI Handoff File
# Update this file at the end of every session.
# Paste the contents into any AI to instantly resume work.

## Project
- Game: Virus RNG Lab Tycoon (Roblox)
- Engine: Roblox Studio (Luau)
- Framework: Mixed — direct LabTycoon.Remotes + Knit services/controllers
- Backup: C:\Users\yanbo\OneDrive\Desktop\virus-rng-simulator\src\
- DataStore key: OriginalData1 — DO NOT CHANGE

## Owners
- UI/Rolling: Yanbo (you)
- World/Map: Partner
- Shared systems: coordinate before editing

## Core Loop
Server roll → inventory (stackable) → equip → earnings → upgrades/rebirth/DNA

## Hard Rules
- Never trust client for rewards, RNG, currency, inventory, purchases
- Never change DataStore name or ProfileStore schema without migration plan
- Never change product/gamepass IDs
- Never map Rojo to a live folder unless all children exported and tested
- Make small testable changes only
- Fix bugs before adding features

## Exported Scripts (in src/)
| File | Studio Location |
|---|---|
| src\ServerScriptService\ServerBootstrapper.server.luau | ServerScriptService.ServerBootstrapper |
| src\ServerScriptService\ServerSource\Server\VirusService.luau | ServerScriptService.ServerSource.Server.VirusService |
| src\ServerScriptService\ServerSource\Server\LabUpgradeService.luau | ServerScriptService.ServerSource.Server.LabUpgradeService |
| src\StarterGui\LabTycoonUI\UILogic.client.luau | StarterGui.LabTycoonUI.UILogic |
| src\ReplicatedStorage\SharedSource\Datas\ProfileTemplate.luau | ReplicatedStorage.SharedSource.Datas.ProfileTemplate |
| src\ReplicatedStorage\SharedSource\Datas\LabUpgradesData.luau | ReplicatedStorage.SharedSource.Datas.LabUpgradesData |

## Not Yet Exported (still Studio-only)
- VirusData (missing from Explorer — investigate)
- ClientSource controllers (VirusController, LabUpgradeController, DataController)

## Last Session
Date: 2026-06-01
Done:
- Set up git repo in project folder
- Exported 6 core scripts to src/
- First git commit successful
- Claude Desktop can auto-read/write scripts from Studio

Next:
- Find and export missing VirusData and client controllers
- Push backup to GitHub for remote access
- Set up AI handoff workflow (this file)

## Remotes (in ReplicatedStorage.LabTycoon.Remotes)
- RollVirus
- RollResult
- EquipVirus
- UnequipVirus
- EquipmentChanged

## Backup Workflow
1. Tell Claude Desktop: "do a backup"
2. In PowerShell: cd "C:\Users\yanbo\OneDrive\Desktop\virus-rng-simulator" && git add -A && git commit -m "backup: auto snapshot"

## Session Log
| Date | AI Used | What Was Done |
|---|---|---|
| 2026-06-01 | Claude | Rojo backup setup, git init, first snapshot |
