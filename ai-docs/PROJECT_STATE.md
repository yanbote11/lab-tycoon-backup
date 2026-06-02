# Virus RNG Project State

## Current Status

The game is playable and under active development.

Core systems currently implemented:

- Rolling system
- Virus inventory
- Equip / Unequip
- Virus world display
- Data saving
- Upgrades
- Rebirth

## Current Stable Backup

VirusRNG_[LATEST_WORKING_BACKUP_NAME]

## Current Priorities

1. Reduce lag and improve performance
2. Mobile optimization
3. UI improvements
4. Additional gameplay content

## Known Issues

- Some systems still use polling loops
- World virus display may need optimization
- Mobile performance not fully tested

## Source of Truth

Current Roblox Studio project is the source of truth.

GitHub documentation should reflect Studio.

Local ZIP backups are used for rollback.

# PROJECT_STATE.md

## Current Stable State

Virus RNG is in a performance-stabilized state after Piece 2 and a safe UI polish pass in Piece 3.

Core gameplay systems remain intact:
- Rolling
- Virus inventory data
- Equipped virus state
- Saving/profile flow
- Lab upgrades
- Rebirth/DNA systems
- Chambers UI

Piece 2 focused on lag and bug fixes:
- Removed client-side world display polling.
- Shifted world display updates to server-side equipment commit events.
- Reduced world virus display visual cost.
- Disabled excessive tycoon/display lighting.
- Removed Superbullet logging spam when backend is unavailable.
- Disabled heavy construction unlock animation/effect path.
- Fixed Chambers/inventory UI rendering issues.

Piece 3 focused only on safe UI polish:
- Added a shared static UI palette and helpers in `UILogic`.
- Improved main roll UI, stat/currency display, Chambers rows, buttons, and compact UI.
- No new RenderStepped logic, particles, looping animations, or heavy repeated-card effects were added.

## Current Priorities

1. Fix `My Tycoon` asset structure so it contains the expected `Tycoon` folder.
2. Re-test world virus display after tycoon asset structure is fixed.
3. Run mobile/tablet UI testing in Studio emulator.
4. Continue to Piece 4 only after approval.

## Known Issues

- `My Tycoon` asset is missing the expected `Tycoon` folder.
- `CollectorGui` template is missing and currently skipped safely.
- Optional GUI templates are missing:
  - `TycoonGui`
  - `CurrencyGui`
  - `RebirthGui`
  - `LevelSystemUI`
  - `NotifierGui`
- Superbullet debugger logging is disabled when its backend is unreachable.
- Top currency UI may need mobile-specific layout refinement.

## Current Source Of Truth

Roblox Studio live project is the source of truth.

Important current scripts:
- `StarterGui.LabTycoonUI.UILogic`
- `ServerScriptService.ServerBootstrapper`
- `ServerScriptService.LabPlotAndVirusWorldService`
- `StarterPlayer.StarterPlayerScripts.WorldVirusDisplayController`
- `ServerScriptService.ServerSource.Server.TycoonService.Components.Others.TycoonAssigner`
- `ReplicatedStorage.Modules.VirusData`

Documentation should reflect the live Studio state after each completed piece.
