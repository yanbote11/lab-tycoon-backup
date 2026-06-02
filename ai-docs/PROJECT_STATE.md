# PROJECT_STATE.md

## Current Stable State

Project: Roblox Luau **Virus RNG / Lab Tycoon simulator**

The game is playable and under active development.

Core gameplay systems currently implemented and expected to remain intact:

- Rolling system
- Virus inventory
- Equip / Unequip
- Virus world display
- Data saving / profile flow
- Lab upgrades
- Rebirth / DNA systems
- Chambers UI

The project is currently in a **performance-stabilized state** after Piece 2 and a safe UI polish pass in Piece 3.

## Recent Completed Work

### Piece 2 — Lag and Bug Fixes

Piece 2 focused on reducing lag and stabilizing core behavior.

Completed changes:

- Removed client-side world display polling.
- Shifted world display updates to server-side equipment commit events.
- Reduced world virus display visual cost.
- Disabled excessive tycoon/display lighting.
- Removed Superbullet logging spam when backend is unavailable.
- Disabled heavy construction unlock animation/effect path.
- Fixed Chambers / inventory UI rendering issues.

### Piece 3 — Safe UI Polish

Piece 3 focused only on safe visual improvements.

Completed changes:

- Added shared static UI palette and helpers in `UILogic`.
- Improved main roll UI.
- Improved stat and currency display.
- Improved Chambers rows.
- Improved button styling.
- Improved compact UI layout.

Important restriction:

- No new `RenderStepped` logic was added.
- No particles were added.
- No looping animations were added.
- No heavy repeated-card visual effects were added.

## Current Priorities

1. Fix `My Tycoon` asset structure so it contains the expected `Tycoon` folder.
2. Re-test world virus display after the tycoon asset structure is fixed.
3. Resolve current git state issues before continuing major work.
4. Playtest changed UI scripts in Roblox Studio.
5. Run mobile/tablet UI testing in Studio emulator.
6. Continue to Piece 4 only after approval.

## Known Issues

### Asset / Template Issues

- `My Tycoon` asset is missing the expected `Tycoon` folder.
- `CollectorGui` template is missing and currently skipped safely.
- Optional GUI templates are missing:
  - `TycoonGui`
  - `CurrencyGui`
  - `RebirthGui`
  - `LevelSystemUI`
  - `NotifierGui`

### Performance / UI Issues

- Some systems may still use polling loops.
- World virus display may need additional optimization.
- Mobile performance has not been fully tested.
- Top currency UI may need mobile-specific layout refinement.

### Git / Repo Issues

- Dirty git state with mixed staged and unstaged changes.
- `VirusArtConfig.luau` is staged but missing from the working tree and removed from Rojo mapping.
- Need to confirm canonical script extension/source: `.lua` vs `.luau`.

## Important Current Scripts

Primary scripts to inspect when continuing development:

- `StarterGui.LabTycoonUI.UILogic`
- `ServerScriptService.ServerBootstrapper`
- `ServerScriptService.LabPlotAndVirusWorldService`
- `StarterPlayer.StarterPlayerScripts.WorldVirusDisplayController`
- `ServerScriptService.ServerSource.Server.TycoonService.Components.Others.TycoonAssigner`
- `ReplicatedStorage.Modules.VirusData`

## Source of Truth

Roblox Studio live project is the current source of truth.

Local source path:

```txt
C:\Users\yanbo\OneDrive\Desktop\virus-rng-simulator\src
