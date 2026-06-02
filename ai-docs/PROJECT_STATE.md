# PROJECT_STATE.md

## Current Stable State

Project: Roblox Luau **Virus RNG / Lab Tycoon simulator**

The game is playable, stable through **Piece 5 rolling polish**, and under active development.

Core systems expected to remain intact:

- Rolling system
- Virus inventory
- Equip / Unequip
- Virus world display
- Data saving / profile flow
- Lab upgrades
- Rebirth / DNA systems
- Chambers UI

Recent work stabilized performance, polished core UI, added virus visual identity metadata, improved DNA tree presentation, and added temporary rarity-scaled roll reveal suspense.

No intentional changes were made to:

- Save data schema
- Virus odds
- Rewards
- Inventory data
- Cooldown validation
- Server-authoritative roll logic

## Completed Work

### Piece 3 — Safe UI Polish

- Improved main roll UI.
- Improved stat and currency display.
- Improved Chambers rows.
- Improved button styling.
- Improved compact UI layout.
- Added shared static UI palette/helpers in `UILogic`.
- Added Quick Roll UI injection when the authored frame is missing.
- Added Auto Equip Best button in virus inventory UI.
- Added compact virus display updates after rolls.

### Piece 4 — Virus Visual Identity / DNA UI

- Added `ReplicatedStorage.Modules.VirusVisualIdentity`.
- Centralized virus visual metadata, lore, mutation classifications, rarity styling, asset plans, and image-generation prompts.
- Kept gameplay virus data centralized in `ReplicatedStorage.Modules.VirusData`.
- Updated Lab UI so Quick Roll and Virus Slot appear as separate uniform upgrade cards.
- Visually capped Chamber UI at 10 terrain slots.
- Improved virus hover tooltips for longer titles/descriptions.
- Hid internal visual metadata such as theme/glow from players.
- Updated DNA tree presentation:
  - Styled title bar
  - DNA-themed nodes/connectors
  - Header summary of bonuses gained from spent SP
  - Luck Boost II matches tree styling
  - Removed invalid strength/agility/intelligence header stats

### Piece 5 — Rolling Presentation Polish

- Roll button gives pre-roll feedback.
- Rolling state shows lightweight scanning feedback.
- Server result is received normally.
- Client delays final display with rarity-scaled roulette/suspense animation.
- Final result reveal uses rarity-scaled glow, flash, particle, and camera shake rules where allowed.
- Temporary roll effects clean up after completion.
- Mobile receives reduced visual intensity.

### Performance Stabilization

- Removed client-side world display polling.
- Shifted world display updates to server-side equipment commit events.
- Reduced world virus display visual cost.
- Disabled excessive tycoon/display lighting.
- Removed Superbullet logging spam when backend is unavailable.
- Disabled heavy construction unlock animation/effect path.
- Fixed Chambers/inventory UI rendering issues.

## Current Priorities

1. Fix `My Tycoon` asset structure so it contains the expected `Tycoon` folder.
2. Re-test world virus display after the tycoon asset structure is fixed.
3. Playtest changed UI and roll reveal behavior in Roblox Studio.
4. Validate desktop, mobile, and tablet UI/performance.
5. Resolve current git/source state issues before major work.
6. Generate/import real virus artwork and assign asset IDs in `VirusVisualIdentity`.
7. Add real rarity-based audio assets for roll anticipation and reveal.
8. Replace manual lab upgrade card positioning with a reusable layout system.
9. Prepare higher-rarity reveal polish without adding permanent or heavy effects.

## Known Issues

### Asset / Template Issues

- `My Tycoon` asset is missing the expected `Tycoon` folder.
- `CollectorGui` template is missing and skipped safely.
- Optional GUI templates are missing:
  - `TycoonGui`
  - `CurrencyGui`
  - `RebirthGui`
  - `LevelSystemUI`
  - `NotifierGui`
- Existing unrelated missing-template/backend warnings may appear in playtest output.

### Performance / UI Issues

- World virus display needs retesting after tycoon asset repair.
- Some systems may still use polling loops.
- Mobile performance has not been fully tested.
- Top currency UI may need mobile-specific layout refinement.
- Lab upgrade cards are manually positioned.
- High-rarity reveal effects are lightweight and not final cinematic assets.

### Art / Audio Issues

- Virus artwork is placeholder metadata only.
- Real virus artwork needs to be generated/imported.
- Asset IDs need to be assigned in `VirusVisualIdentity`.
- Roll sound hooks exist, but sound asset IDs are not assigned.

### Git / Source Issues

- `VirusArtConfig.luau` git/source state needs cleanup.
- Canonical script extension/source policy needs confirmation:
  - `.lua`
  - `.luau`

## Important Current Scripts

Primary scripts/modules to inspect when continuing development:

- `ReplicatedStorage.ClientSource.Client.RollEffects`
- `StarterGui.LabTycoonUI.UILogic`
- `ReplicatedStorage.Modules.VirusVisualIdentity`
- `ReplicatedStorage.Modules.VirusData`
- `ServerScriptService.ServerSource.Server.VirusService`
- `ServerScriptService.ServerBootstrapper`
- `ServerScriptService.LabPlotAndVirusWorldService`
- `StarterPlayer.StarterPlayerScripts.WorldVirusDisplayController`
- `ServerScriptService.ServerSource.Server.TycoonService.Components.Others.TycoonAssigner`
- `ReplicatedStorage.SharedSource.Datas.SkillTreeData.Trees.VirusLab`
- `ReplicatedStorage.ClientSource.Client.SkillTreeController.Components.Others.StatsDisplay`

## Source of Truth

Roblox Studio live project is the current source of truth.

Primary active gameplay virus data:

```txt
ReplicatedStorage.Modules.VirusData
