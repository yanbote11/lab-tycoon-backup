# CHANGELOG.md

## 2026-06-02

### Added

- Added AI documentation system:
  - `HANDOFF.md`
  - `PROJECT_STATE.md`
  - `ARCHITECTURE.md`
  - `AI_RULES.md`
  - `CHANGELOG.md`
- Added lightweight shared UI styling helpers in `StarterGui.LabTycoonUI.UILogic`:
  - Static palette
  - Corner helper
  - Label helper
  - Button helper
  - Card helper
  - One-time UI polish pass
- Added functional UI logic for Lab Capacity display and purchase paths.
- Added Quick Roll UI injection when the authored frame is missing.
- Added Auto Equip Best button in virus inventory UI.
- Added compact virus display updates after rolls.

### Changed

- Improved AI onboarding process.
- Updated main roll UI styling.
- Updated currency/stat display styling.
- Updated Chambers / inventory row styling.
- Updated compact / minimized UI styling.
- Reworked `UILogic` toward direct RemoteEvents / Knit controller usage.
- Updated slot count calculation to use effective combined profile data.
- Chambers UI now handles:
  - Sparse inventory data
  - Count-map inventory data
  - Table entries with `Name`
- Superbullet logger now disables logging for the playtest when backend is unreachable.
- Tycoon unlock presentation now skips the expensive client construction animation/effect path.
- Removed `VirusArtConfig` from Rojo project mapping.
- Removed `ServerBootstrapper` environment lighting / post-processing initialization.

### Fixed

- Fixed stale `reportedEquippedByPlayer` reference in `LabPlotAndVirusWorldService`.
- Fixed Chambers list rendering empty despite saved inventory existing.
- Fixed Chambers toolbar controls that could appear without connected handlers.
- Fixed missing virus definitions displaying as broken / empty inventory rows.
- Fixed repeated Superbullet HTTP failure log spam during Studio testing.
- Added safe guards for missing tycoon asset folders / templates.
- Improved roll cooldown handling and failure warnings.
- Improved compact roll connection cleanup.
- Improved upgrade button max / locked states.
- Reduced dependency on missing or deleted visual config module.

### Performance Improvements

- Removed client world-display polling.
- Removed old world display client-to-server equipment echo behavior.
- Replaced world display polling with server-side equipment commit sync.
- Reduced world virus visual complexity.
- Disabled tycoon spotlights.
- Reduced display lighting.
- Removed Superbullet warning pulse tween loop.
- Reduced UI safety refresh frequency.
- Removed heavy UI animation / glassmorphism styling pass.
- Removed server bootstrap lighting / effects initialization.
- Avoided adding new `RenderStepped` logic, particles, looping UI animations, or heavy repeated-card styling.

### Notes

- Roblox Studio remains the source of truth.
- Local ZIP backups are used as the rollback system.
- World virus display still needs to be re-tested after fixing the `My Tycoon` asset structure.
- Missing optional GUI templates still produce warnings but are safely skipped.
- UI refresh loop remains active and should be profiled after playtest.
- `VirusArtConfig.luau` is currently staged as added but deleted in the working tree.
- No architecture documentation update is required unless the team decides the UI rewrite or source extension policy is a major system change.
# CHANGELOG.md

## 2026-06-02

### Today's Additions
- Added `VirusVisualIdentity` module for centralized virus presentation metadata.
- Added lore, mutation classifications, rarity visual rules, asset plans, and image-generation prompts for all active viruses.
- Added visual rarity aliases for existing tiers: Celestial as Secret, Transcendent as Divine.
- Added DNA tree title bar and bonus summary display.
- Added/normalized authored Quick Roll lab upgrade card.

### Changes
- Roll result, compact virus display, inventory rows, and chamber hover tooltips now use visual identity metadata.
- Chamber hover tooltips now show player-facing lore and rewards only.
- DNA tree header now shows bonuses gained from unlocked DNA nodes.
- DNA tree colors, connectors, node template, info panel, and close button were restyled.
- Lab upgrade cards now appear in order: Incubator, Sterile Conditions, Auto Roll, Quick Roll, Virus Slot, Auto Roll toggle.
- Luck Boost II now matches the standard DNA tree node style.

### Fixes
- Fixed chamber slot counter showing uncapped max slots such as `10 / 11`.
- Fixed Virus Slot card being hidden by Quick Roll.
- Fixed long virus tooltip text overflowing outside the border.
- Fixed DNA tree missing title/stats bar warning.
- Removed internal theme/glow/hover metadata from player-facing tooltip text.

### Performance Improvements
- Kept virus identity changes data-driven and static.
- Avoided new particles, permanent glow systems, heavy VFX, and visual loops.
- Compact/list virus styling avoids gradients where unnecessary.
- Tooltip sizing runs only on hover.

### Notes
- No save data, virus odds, rewards, or inventory schema were changed.
- No rolling effects, encyclopedia expansion, inventory expansion, or world decorations were added.
- `ARCHITECTURE.md` does not need changes; no major system was added, removed, or fundamentally restructured.
# CHANGELOG.md

## Today's Additions

- Added rarity-scaled roll suspense animation before final virus reveal.
- Added roulette-style virus name cycling with deceleration.
- Added progress/lock-in presentation before showing the final roll result.
- Added mobile-reduced roulette step counts.
- Added expected reveal delay helper for compact UI timing.

## Changes

- Main roll result flow now waits for suspense animation before displaying the final virus.
- Main roll button now shows `REVEALING...` and stays disabled during reveal suspense.
- Compact roll button now also stays in `REVEALING...` until the suspense window completes.
- Existing reveal effects remain modular and temporary.

## Fixes

- Fixed roll results feeling instant.
- Fixed roll effects ending too quickly.
- Fixed compact roll UI returning to `ROLL` before the visual reveal completed.
- Verified temporary roll visual cleanup after a live roll.

Earlier session fixes:
- Fixed DNA tree header to show earned SP bonuses.
- Fixed Luck Boost II styling mismatch.
- Fixed chamber tooltip overflow for longer virus names/descriptions.
- Removed internal theme/glow metadata from player-facing virus hover text.
- Fixed chamber slot display showing `10/11` when max is 10.
- Restored lab virus slot upgrade visibility and Quick Roll visual consistency.

## Performance Improvements

- Roll visuals remain client-side only.
- No roll odds, rewards, save data, or server validation changed.
- No permanent particle systems added.
- No always-running roll visual loops added.
- Temporary UI/effect objects are cleaned up after reveal.
- Mobile fallback reduces roulette workload.

## Notes

- Roll audio hooks are present but still need real sound asset IDs.
- High-rarity reveal polish should remain capped, temporary, and mobile-reduced.
- Do not proceed to Piece 6 until Piece 5 is approved after Studio testing.
# CHANGELOG.md

## 2026-06-02

### Today's Additions

- Added `VirusVisualIdentity` module for centralized virus presentation metadata.
- Added lore, mutation classifications, rarity visual rules, asset plans, and image-generation prompts.
- Added rarity-scaled roll suspense animation before final virus reveal.
- Added roulette-style virus name cycling with deceleration.
- Added Quick Roll UI injection when authored UI is missing.
- Added Auto Equip Best button in virus inventory UI.
- Added DNA tree title bar and unlocked bonus summary display.

### Changes

- World virus display updates now sync from server equipment commit events instead of client polling.
- Roll result flow now waits for reveal suspense before showing the final virus.
- Main and compact roll buttons show revealing state until reveal completes.
- Roll result, compact display, inventory rows, and chamber tooltips use visual identity metadata.
- Lab upgrade cards now separate Quick Roll and Virus Slot cards.
- Chamber UI visually caps terrain slots at 10.
- Superbullet logging is disabled or reduced when backend is unavailable in Studio.
- Expensive tycoon construction unlock visuals are skipped.
- `VirusArtConfig` was removed from Rojo project mapping.

### Fixes

- Fixed stale `reportedEquippedByPlayer` reference in `LabPlotAndVirusWorldService`.
- Fixed Chambers list rendering empty despite saved inventory.
- Fixed missing virus definitions creating broken inventory rows.
- Fixed chamber slot counter showing uncapped values.
- Fixed Virus Slot card visibility conflict with Quick Roll.
- Fixed chamber tooltip overflow.
- Fixed compact roll UI returning to `ROLL` before reveal completion.
- Fixed repeated Superbullet HTTP/log spam during Studio testing.
- Added safe guards for missing tycoon folders and optional GUI templates.

### Performance Improvements

- Removed client-side world display polling.
- Reduced world virus display visual complexity.
- Disabled excessive tycoon/display lighting.
- Removed heavy construction animation/effect path.
- Reduced UI safety refresh frequency.
- Avoided new permanent `RenderStepped` logic, polling loops, particles, or looping UI animations.
- Reveal effects are temporary client-side UI work and use reduced mobile workload.

### Notes

- Roblox Studio remains the source of truth.
- No save data schema, virus odds, rewards, or inventory schema were intentionally changed.
- World virus display still needs retesting after `My Tycoon` asset structure is fixed.
- Missing optional GUI templates still produce warnings but are safely skipped.
- Mobile/tablet validation is still needed.
- Roll audio hooks exist but need real sound asset IDs.
- `ARCHITECTURE.md` does not need updates because no major system was added, removed, or fundamentally restructured.
- 
# CHANGELOG.md

## 2026-06-03

### Additions
- Added lightweight static lab/biohazard environmental polish in organized `EnvironmentalPolish` folders.
- Added prompt-driven lab entrance doors for tycoon lab buildings.
- Added `LabEntranceDoorController` for centralized door prompt/tween handling.
- Added `FootstepSoundSilencer` to mute default Roblox running/climbing footstep audio.

### Changes
- Repositioned and aligned lab buildings, home pads, and start markers so building rows line up with roads.
- Limited `Open Lab` BillboardGui visibility distance.
- Updated roll VFX/audio handling to use capped, temporary effects.
- Updated particle emitter helper with clamped/mobile-scaled emit counts.
- Updated sound helper with bounded load wait and cleanup.

### Fixes
- Fixed building placement issues where labs were partially in the road.
- Fixed misaligned house/building row.
- Fixed blue door panes blocking player entry.
- Fixed excessive across-map lab label visibility.
- Fixed `TycoonSounds` initialization typo.
- Fixed annoying fuzzy movement/footstep audio from default character sounds.

### Performance Improvements
- No permanent particles added.
- No new every-frame remotes added.
- Roll sounds are capped, debounced, and cleaned up.
- Roll particles are capped and reduced on mobile.
- Door logic uses prompts/tweens instead of loops.
- Environmental polish is static, anchored, low-count, and script-free.
- Temporary character sound connection is cleaned on respawn.

### Notes
- Final cleanup pass made no additional edits.
- Manual testing still recommended for every door, mobile UI, auto-roll button, rejoin persistence, and high-rarity reveal behavior.
- No architecture document update required.

## 2026-06-03

### Virus Roster Expansion
- Expanded the canonical active roster in `ReplicatedStorage.Modules.VirusData` from 20 to exactly 50 unique virus/disease types.
- Added 30 new stylized collectible entries across existing rarity tiers only: Common, Uncommon, Rare, Epic, Legendary, Mythic, and Celestial.
- Preserved all existing virus names for save-data compatibility.
- Kept the active virus schema unchanged: `Name`, `Tier`, `Description`, `DNAPoints`, `ResearchPoints`, `Cash`, and `NumericalRarity`.
- Converted `ReplicatedStorage.LabTycoon.Modules.VirusData` into a compatibility wrapper generated from the canonical roster so duplicate data sources cannot drift.
- Confirmed collection total resolves to 50 from `#VirusData.Viruses`.
- Confirmed new entries use existing tier styling, fallback visual identity, and world-display fallback shapes without adding heavy assets or effects.

### Safety Notes
- No save data schema, rolling system, inventory system, collection system, or world display system rewrite was performed.
- Virus identity remains based on saved virus name strings.
- No new rarity tiers, polling loops, RenderStepped loops, permanent particle systems, or heavy models were added.
# CHANGELOG.md

## Today’s Additions
- Added Collection selected-virus persistence so details remain visible across UI refreshes.

## Changes
- Roll/Cultivate tab now resets shared content scroll to the top and disables scrolling while active.
- Collection detail panel is rendered outside the scrolling content area so it remains visible while the collection list is scrolled.

## Fixes
- Fixed Roll tab inheriting Collection tab scroll position.
- Fixed Collection detail appearing outside the user’s visible area after scrolling.
- Fixed Collection detail resetting to “Select a virus” shortly after selecting a virus.

## Performance Improvements
- Avoided adding polling or continuous UI update loops.
- Collection detail restore uses lightweight state and only runs during collection rebuilds.

## Notes
- No architecture changes were made.
- Existing missing optional GUI/template warnings remain unchanged.
# Virus RNG Changelog

## 2026-06-04

### Added

- `ServerScriptService.LuckEventService` (new Script):
  - Server-authoritative 2x Luck event, active every hour at :00 for 10 minutes (UTC).
  - Creates `LuckEventBridge` BindableFunction in ServerScriptService at runtime.
  - Creates `ReplicatedStorage.LabTycoon.Remotes.LuckEventStatus` RemoteEvent at runtime.
  - Sets `VirusService.EventLuckMultiplier` (1 or 2) every second via task loop.
  - Broadcasts full event state to all clients on state change and every 5 seconds.
  - Fires current state to late-joining players after a 2-second wait.
- `VirusController.EventLuckMultiplier` field — cached client-side event multiplier, kept current by `LuckEventStatus` listener.
- `setupLuckEventUI()` in `UILogic` — small event banner (ScreenGui, `ResetOnSpawn=false`):
  - Active: green banner "⚡ 2x Luck Event Active!" + "Ends in MM:SS".
  - Inactive: muted banner "Next 2x Luck in H:MM:SS".
  - Heartbeat-driven text-only updates; no layout rebuilds; proper connection cleanup.

### Changes

- `VirusService.GetEffectiveLuck` — multiplies final luck by `VirusService.EventLuckMultiplier`; also reads `LuckEventBridge` directly as authoritative fallback.
- `ServerBootstrapper` — added `getEventLuckMult()` helper (reads `LuckEventBridge`); applied to all 4 fallback inline luck sites: manual roll virus, manual roll modifier, auto-roll virus, auto-roll modifier.
- `VirusController.GetLuckPercent()` — multiplies by `EventLuckMultiplier` so the stats panel reflects active luck event.
- `UILogic` inventory sort (`rebuildVirusList`) — sort score now uses `ModificationData.ApplyStat`-applied stats (effective RP, Cash, DNA) instead of base stats plus a flat modifier bonus. Modified viruses now sort correctly relative to unmodified viruses.
- `VirusVisualIdentity.LoreByVirus` — all 50 virus descriptions updated to standardized format: what the disease is, worldwide case count (WHO/CDC), fatality rate. Fictional viruses labelled as fictional. Previously only 20 of 50 viruses had lore entries.

### Fixes

- Fixed inventory sort: modified viruses were never correctly ranked against unmodified viruses because the modifier was added as a flat score bonus rather than multiplied into the actual stats.
- Fixed `VirusController` module crash: `EventLuckMultiplier` field assignment and listener `do..end` block were injected before `local VirusController = {}` was defined, causing a nil-index error on load that broke all UI tabs.
- Fixed luck event not applying to modifier rolls in `ServerBootstrapper` inline path.
- Fixed stats panel ("Luck Bonus") not reflecting active luck event.
- Fixed `GetEffectiveLuck` potential miss on first tick before `LuckEventService` loop sets the field.

### Performance

- No negative performance impacts.
- Luck event loop: 1s tick, arithmetic only; broadcasts at most every 5s.
- Sort fix is same O(n) complexity; `ApplyStat` replaces a simple multiply.

### Notes

- Luck event multiplier is never saved to player data.
- Luck event stacking: `FinalLuck = RebirthMult * LabBonus * CollectionLuck * (1 + SkillLuck) * (1 + SerumBonus + FriendBoost) * EventMult`.
- Client only receives display state from `LuckEventStatus`; all luck math is server-side.
- Auto-roll fallback path still does not include `ExternalLuckBonus` — pre-existing gap, not introduced this session.
- `My Tycoon` asset structure fix still pending; world virus display not re-tested.

## 2026-06-02

### Added

- AI documentation system: HANDOFF.md, PROJECT_STATE.md, ARCHITECTURE.md, AI_RULES.md, CHANGELOG.md.
- Lightweight shared UI styling helpers in `StarterGui.LabTycoonUI.UILogic`.

### Changes

- Updated main roll UI, currency/stat display, Chambers/inventory row, and compact UI styling.
- Chambers UI handles sparse, count-map, and named-entry inventory formats.
- Superbullet logger disables when backend unreachable.
- Tycoon unlock presentation skips expensive client construction animation path.

### Fixes

- Fixed stale `reportedEquippedByPlayer` reference in `LabPlotAndVirusWorldService`.
- Fixed Chambers list rendering empty despite saved inventory existing.
- Fixed Chambers toolbar controls appearing without handlers.
- Fixed missing virus definitions showing as broken inventory rows.
- Fixed repeated Superbullet HTTP failure log spam during Studio testing.
- Added safeguards for missing tycoon asset folders and templates.

### Performance

- Removed client world-display polling.
- Replaced with server-side equipment commit sync.
- Reduced world virus visual complexity.
- Disabled tycoon spotlights and excess display lighting.
- Removed Superbullet warning pulse tween loop.
- Reduced UI safety refresh frequency.
