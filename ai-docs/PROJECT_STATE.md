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

Virus RNG has completed performance stabilization, safe UI polish, and visual identity improvements for viruses, Chambers, Lab upgrades, and the DNA tree.

Gameplay odds, rewards, inventory data, and save data were not intentionally changed.

## Recent Completed Work

### Performance Stabilization

Completed changes:

- Removed client-side world display polling.
- Shifted world display updates to server-side equipment commit events.
- Reduced world virus display visual cost.
- Disabled excessive tycoon/display lighting.
- Removed Superbullet logging spam when backend is unavailable.
- Disabled heavy construction unlock animation/effect path.
- Fixed Chambers / inventory UI rendering issues.

### Safe UI Polish

Completed changes:

- Added shared static UI palette and helpers in `UILogic`.
- Improved main roll UI.
- Improved stat and currency display.
- Improved Chambers rows.
- Improved button styling.
- Improved compact UI layout.
- Added Quick Roll UI injection when the authored frame is missing.
- Added Auto Equip Best button in virus inventory UI.
- Added compact virus display updates after rolls.

Important restriction:

- No new `RenderStepped` logic was added.
- No particles were added.
- No looping animations were added.
- No heavy repeated-card visual effects were added.

### Virus Visual Identity / DNA UI

Completed changes:

- Added `ReplicatedStorage.Modules.VirusVisualIdentity`.
- Centralized virus visual metadata, lore, mutation classifications, rarity styling, asset plans, and image-generation prompts.
- Kept active gameplay virus data centralized in `ReplicatedStorage.Modules.VirusData`.
- Updated Lab UI so Quick Roll and Virus Slot appear as separate uniform upgrade cards.
- Visually capped Chamber UI at 10 terrain slots.
- Updated DNA tree with:
  - Styled title bar
  - DNA-themed nodes/connectors
  - Header summary of unlocked DNA bonuses

## Current Priorities

1. Fix `My Tycoon` asset structure so it contains the expected `Tycoon` folder.
2. Re-test world virus display after the tycoon asset structure is fixed.
3. Resolve current git state issues before continuing major work.
4. Playtest changed UI scripts in Roblox Studio.
5. Validate all updated UI on desktop and mobile/tablet Studio emulator.
6. Generate/import real virus artwork and assign asset IDs in `VirusVisualIdentity`.
7. Replace manual upgrade card positioning with a reusable layout system.
8. Prepare lightweight selected-preview/reveal effects for higher-rarity viruses.
9. Continue to the next development piece only after approval.

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
- Optional missing UI/assets still produce unrelated warnings in console.

### Performance / UI Issues

- Some systems may still use polling loops.
- World virus display may need additional optimization.
- Mobile performance has not been fully tested.
- Top currency UI may need mobile-specific layout refinement.
- Lab upgrade cards are manually positioned.
- DNA tree bonus summary depends on a client-side skill bonus map.
- Secret/Divine heavy reveal effects are not implemented.

### Art / Visual Identity Issues

- Virus artwork is still placeholder metadata only.
- Real virus artwork needs to be generated/imported.
- Asset IDs need to be assigned in `VirusVisualIdentity`.

### Git / Repo Issues

- Dirty git state with mixed staged and unstaged changes.
- `VirusArtConfig.luau` is staged but missing from the working tree and removed from Rojo mapping.
- Need to confirm canonical script extension/source: `.lua` vs `.luau`.

## Important Current Scripts

Primary scripts/modules to inspect when continuing development:

- `StarterGui.LabTycoonUI.UILogic`
- `ServerScriptService.ServerBootstrapper`
- `ServerScriptService.LabPlotAndVirusWorldService`
- `StarterPlayer.StarterPlayerScripts.WorldVirusDisplayController`
- `ServerScriptService.ServerSource.Server.TycoonService.Components.Others.TycoonAssigner`
- `ReplicatedStorage.Modules.VirusData`
- `ReplicatedStorage.Modules.VirusVisualIdentity`
- `ReplicatedStorage.SharedSource.Datas.SkillTreeData.Trees.VirusLab`
- `ReplicatedStorage.ClientSource.Client.SkillTreeController.Components.Others.StatsDisplay`

## Source of Truth

Roblox Studio live project is the current source of truth.

Active gameplay virus data:

```txt
ReplicatedStorage.Modules.VirusData
# PROJECT_STATE.md

## Current Stable State

Virus RNG is stable through Piece 5 rolling polish.

Completed systems:
- Piece 3 safe UI polish.
- Piece 4 Virus Visual Identity support.
- Piece 5 rolling presentation polish.

The rolling system remains server-authoritative. Roll odds, reward granting, inventory updates, save data, and cooldown validation were not changed.

Current roll presentation:
- Roll button gives pre-roll feedback.
- Rolling state shows lightweight scanning feedback.
- Server result is received normally.
- Client delays final display with a rarity-scaled roulette/suspense animation.
- Final result reveal uses rarity-scaled glow, flash, particle, and camera shake rules where allowed.
- Temporary roll effects clean up after completion.
- Mobile receives reduced visual intensity.

DNA tree UI is stable:
- Header displays bonuses gained from spent SP.
- Luck Boost II matches the tree styling.
- Invalid strength/agility/intelligence header stats were removed.

Virus chamber/UI state:
- Chamber slot display respects the 10-slot max.
- Virus hover tooltips wrap longer titles/descriptions.
- Internal visual metadata such as theme/glow is hidden from players.

## Current Priorities

1. Test Piece 5 rolling flow in Roblox Studio on desktop and mobile.
2. Add real rarity-based audio assets for roll anticipation and reveal.
3. Prepare higher-rarity reveal polish without adding permanent or heavy effects.

## Known Issues

- Roll sound hooks exist but sound asset IDs are not assigned.
- Virus artwork remains placeholder/planned.
- High-rarity reveal effects are lightweight and not final cinematic assets.
- Existing unrelated missing-template/backend warnings may appear in playtest output.

## Current Source of Truth

Live Roblox Studio project is the source of truth.

Relevant current scripts:
- `ReplicatedStorage.ClientSource.Client.RollEffects`
- `StarterGui.LabTycoonUI.UILogic`
- `ReplicatedStorage.Modules.VirusVisualIdentity`
- `ReplicatedStorage.Modules.VirusData`
- `ServerScriptService.ServerSource.Server.VirusService`

Do not modify `ARCHITECTURE.md` unless a major system is added, removed, or fundamentally changed.
