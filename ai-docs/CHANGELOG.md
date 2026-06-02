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
