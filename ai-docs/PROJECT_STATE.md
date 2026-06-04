# PROJECT_STATE.md

## Current Stable State

Project: Roblox Luau **Virus RNG / Lab Tycoon simulator**

Virus RNG is stable in Roblox Studio with ProfileStore-backed data and the existing Knit/service flow.

The project is stable after:

- Piece 9 VFX/audio and final cleanup pass
- 50-virus roster expansion
- Targeted LabTycoon UI fixes

Core systems preserved:

- Rolling system
- Virus inventory
- Equip / Unequip
- Collection UI
- Virus world display
- Data saving / profile flow
- Lab upgrades
- Rebirth / DNA systems
- Chambers UI
- Lab doors
- Building alignment
- Temporary effect cleanup

No intentional changes have been made to:

- Save data schema
- Virus odds
- Rewards
- Inventory data
- Cooldown validation
- Server-authoritative roll logic

## Completed Work

### Performance / Stability Cleanup

- Removed client-side world display polling.
- Shifted world display updates to server-side equipment commit events.
- Reduced world virus display visual cost.
- Disabled excessive tycoon/display lighting.
- Removed Superbullet logging spam when backend is unavailable.
- Disabled heavy construction unlock animation/effect path.
- Fixed Chambers/inventory UI rendering issues.
- Ensured temporary roll effects clean up after completion.
- Silenced default Roblox movement footstep audio with an event-driven client script.

### UI Polish

- Main LabTycoon UI remains driven by:

```txt
StarterGui.LabTycoonUI.UILogic
