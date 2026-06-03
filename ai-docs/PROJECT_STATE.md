# PROJECT_STATE.md

## Current Stable State

Project: Roblox Luau **Virus RNG / Lab Tycoon simulator**

Virus RNG is stable after the **Piece 9 VFX/audio and final cleanup pass**.

Core systems verified in Roblox Studio:

- Rolling system
- Inventory data updates
- Equip / Unequip
- Collection UI presence
- Lab doors
- Building alignment
- Temporary effect cleanup

Recent work aligned the lab buildings and roads, added lightweight static lab/biohazard polish, and added prompt-driven lab entrance doors.

Recent VFX/audio work keeps roll effects:

- Lightweight
- Capped
- Mobile-aware
- Cleaned after use

Default Roblox movement footstep audio was silenced with an event-driven client script.

No intentional changes have been made to:

- Save data schema
- Virus odds
- Rewards
- Inventory data
- Cooldown validation
- Server-authoritative roll logic

## Completed Work

### Performance Stabilization

- Removed client-side world display polling.
- Shifted world display updates to server-side equipment commit events.
- Reduced world virus display visual cost.
- Disabled excessive tycoon/display lighting.
- Removed Superbullet logging spam when backend is unavailable.
- Disabled heavy construction unlock animation/effect path.
- Fixed Chambers/inventory UI rendering issues.

### Safe UI Polish

- Improved main roll UI.
- Improved stat and currency display.
- Improved Chambers rows.
- Improved button styling.
- Improved compact UI layout.
- Added shared static UI palette/helpers in `UILogic`.
- Added Quick Roll UI injection when the authored frame is missing.
- Added Auto Equip Best button in virus inventory UI.
- Added compact virus display updates after rolls.

### Virus Visual Identity / DNA UI

- Added `ReplicatedStorage.Modules.VirusVisualIdentity`.
- Centralized virus visual metadata, lore, mutation classifications, rarity styling, asset plans, and image-generation prompts.
- Kept gameplay virus data centralized in `ReplicatedStorage.Modules.VirusData`.
- Updated Lab UI so Quick Roll and Virus Slot appear as separate uniform upgrade cards.
- Visually capped Chamber UI at 10 terrain slots.
- Improved virus hover tooltips for longer titles/descriptions.
- Hid internal visual metadata such as theme/glow from players.
- Improved DNA tree presentation.

### Rolling Presentation Polish

- Roll button gives pre-roll feedback.
- Rolling state shows lightweight scanning feedback.
- Server result is received normally.
- Client delays final display with rarity-scaled roulette/suspense animation.
- Final result reveal uses rarity-scaled glow, flash, particle, and camera shake rules where allowed.
- Temporary roll effects clean up after completion.
- Mobile receives reduced visual intensity.

### World / Lab Polish

- Aligned lab buildings and roads.
- Added lightweight static lab/biohazard polish.
- Added prompt-driven lab entrance doors.
- Verified lab doors and building alignment in Studio.

### VFX / Audio Cleanup

- Added lightweight capped roll VFX/audio behavior.
- Kept roll effects mobile-aware.
- Ensured temporary effects clean up after use.
- Silenced default Roblox movement footstep audio with an event-driven client script.

## Current Priorities

1. Complete manual Studio QA:
   - Test all doors from both sides.
   - Test auto-roll button.
   - Test mobile emulator.
   - Test rejoin persistence.
2. Resolve known missing GUI/template warnings if those systems are still intended.
3. Confirm FPS and memory stability during rolling and UI use before continuing development.
4. Continue development only after the current stable state is verified.

## Known Issues

- `My Tycoon` asset is missing the expected `Tycoon` folder.
- Optional GUI/templates are missing or disabled:
  - `TycoonGui`
  - `CurrencyGui`
  - `RebirthGui`
  - `LevelSystemUI`
  - Collector billboard
- Superbullet backend warning appears when the local backend is not running.
- `SceneAnalysisService` was disabled during final audit, so deep render/memory analysis was unavailable.
- Full mobile validation still needs to be completed.
- Full rejoin persistence test still needs to be completed.

## Source of Truth

The live Roblox Studio place is the source of truth.

Existing documentation should be treated as guidance unless it conflicts with the live project.

If documentation conflicts with Studio, notify the user before making changes.

Primary active gameplay virus data:

```txt
ReplicatedStorage.Modules.VirusData
