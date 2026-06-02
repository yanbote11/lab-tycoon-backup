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
