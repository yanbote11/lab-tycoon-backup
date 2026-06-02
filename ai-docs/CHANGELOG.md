# Virus RNG Changelog

## 2026-06-02

### Added

- AI documentation system
- HANDOFF.md
- PROJECT_STATE.md
- ARCHITECTURE.md
- AI_RULES.md

### Changed

- Improved AI onboarding process

### Notes

- Local ZIP backups used as rollback system
- Roblox Studio remains source of truth
# CHANGELOG.md

## 2026-06-02

### Additions

- Added lightweight shared UI styling helpers in `StarterGui.LabTycoonUI.UILogic`:
  - Static palette
  - Corner helper
  - Label helper
  - Button helper
  - Card helper
  - One-time UI polish pass

### Changes

- Updated main roll UI styling.
- Updated currency/stat display styling.
- Updated Chambers/inventory row styling.
- Updated compact/minimized UI styling.
- Chambers UI now handles sparse inventory data, count-map inventory data, and table entries with `Name`.
- Superbullet logger now disables logging for the playtest when backend is unreachable.
- Tycoon unlock presentation now skips expensive client construction animation/effect path.

### Fixes

- Fixed stale `reportedEquippedByPlayer` reference in `LabPlotAndVirusWorldService`.
- Fixed Chambers list rendering empty despite saved inventory existing.
- Fixed Chambers toolbar controls that could appear without connected handlers.
- Fixed missing virus definitions displaying as broken/empty inventory rows.
- Fixed repeated Superbullet HTTP failure log spam during Studio testing.
- Added safe guards for missing tycoon asset folders/templates.

### Performance Improvements

- Removed client world-display polling.
- Removed old world display client-to-server equipment echo behavior.
- Replaced world display polling with server-side equipment commit sync.
- Reduced world virus visual complexity.
- Disabled tycoon spotlights.
- Reduced display lighting.
- Removed Superbullet warning pulse tween loop.
- Reduced UI safety refresh frequency.
- Avoided new RenderStepped logic, particles, looping UI animations, and heavy repeated-card styling.

### Notes

- World virus display still needs re-test after fixing the `My Tycoon` asset structure.
- Missing optional GUI templates still produce warnings but are safely skipped.
- No architecture documentation update is required; no major system was added, removed, or fundamentally redesigned.
