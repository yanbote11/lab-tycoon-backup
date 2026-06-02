# HANDOFF.md — virus-rng-simulator Backup Reference

## Repo
https://github.com/yanbote11/lab-tycoon-backup

## Local Path
`C:\Users\yanbo\OneDrive\Desktop\virus-rng-simulator`

## Instructions for AI
1. Read every script in the table below from Roblox Studio using MCP (`script_read`)
2. Write each one to its `Local Path` under `src\`
3. Run:
   ```
   cd "C:\Users\yanbo\OneDrive\Desktop\virus-rng-simulator"
   git add -A
   git commit -m "backup: auto snapshot"
   git push
   ```

---

## Exported Scripts

| Studio Path (MCP) | Local Path (under src\) | Type |
|---|---|---|
| `ServerScriptService.SuperbulletServerLogger` | `ServerScriptService/SuperbulletServerLogger.server.lua` | Script |
| `ServerScriptService.SuperbulletServer` | `ServerScriptService/SuperbulletServer.server.lua` | Script |
| `ServerScriptService.LevelSystemTesters` | `ServerScriptService/LevelSystemTesters.server.lua` | Script |
| `ServerScriptService.ServerBootstrapper` | `ServerScriptService/ServerBootstrapper.server.lua` | Script |
| `ServerScriptService.LabPlotAndVirusWorldService` | `ServerScriptService/LabPlotAndVirusWorldService.server.lua` | Script |
| `StarterPlayer.StarterPlayerScripts.SuperbulletClientLogger` | `StarterPlayer/StarterPlayerScripts/SuperbulletClientLogger.client.lua` | LocalScript |
| `StarterPlayer.StarterPlayerScripts.SuperbulletClient` | `StarterPlayer/StarterPlayerScripts/SuperbulletClient.client.lua` | LocalScript |
| `StarterPlayer.StarterPlayerScripts.SprintController` | `StarterPlayer/StarterPlayerScripts/SprintController.client.lua` | LocalScript |
| `StarterPlayer.StarterPlayerScripts.WorldVirusDisplayController` | `StarterPlayer/StarterPlayerScripts/WorldVirusDisplayController.client.lua` | LocalScript |
| `StarterGui.LabTycoonUI.UILogic` | `StarterGui/LabTycoonUI/UILogic.client.lua` | LocalScript |

---

## Notes
- Workspace scripts (DoorsScript, Fan, Head scripts) are auto-generated from `ServerStorage.LabTycoonAssets` — do NOT back up individually
- Superbullet logger scripts only run in Studio (guarded by `RunService:IsStudio()`)
- Git remote: `https://github.com/yanbote11/lab-tycoon-backup`
