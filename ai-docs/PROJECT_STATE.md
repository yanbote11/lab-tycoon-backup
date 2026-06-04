# PROJECT_STATE.md

## Current Status

Project: Roblox Luau **Virus RNG / Lab Tycoon simulator**

The game is playable and in a feature-stable state after four development pieces.

Core systems currently implemented:

- Rolling system
  - Manual roll
  - Auto-roll
- Modifier system
- Modifier-aware virus inventory
- Modifier-aware equip / unequip with slot system
- Virus world display
- Modifier-aware data saving via ProfileService
- Lab upgrades
- Rebirth / DNA system
- Chambers UI
- Daily quests
- Black Market / serum buffs
- Friend Boost
- Offline earnings
- Collection rewards
- Skill tree
- Server roll broadcast
- 2x Luck event

---

## Latest Completed Work

### Piece 4 — Modifier System

Piece 4 added a full modifier system on top of the stable Piece 3 baseline.

New systems added in Piece 4:

- Added `ReplicatedStorage.Modules.ModificationData`.
- Added 8 modifier types:
  - Normal
  - Mutant
  - Evolved
  - Adapted
  - Hybrid
  - Armored
  - Aggressive
  - Omega Strain
- Added server-side modifier rolling after every base virus roll.
- Added luck-scaled modifier chances using the same luck multiplier as base virus rolling.
- Added modifier-aware inventory entries.
- Added modifier-aware stack keys.
- Added modifier-aware equip / unequip.
- Added modifier-aware earnings.
- Added per-modifier collection tracking.
- Added modifier filter tabs to the Collection / Index page.
- Added modifier badge and multiplier display to roll results.
- Added modifier-aware server broadcasts.
- Added save migration so old string inventory entries are treated as `Normal`.

Final modifier visuals were intentionally deferred until base virus models exist.

### 2x Luck Event

Added a server-authoritative 2x Luck event system.

Current behavior:

- Event runs every hour.
- Event lasts 10 minutes.
- Luck event schedule uses UTC internally.
- Player-facing wording should say “every hour” without promising a timezone.
- Luck event banner/UI should be tested on mobile.

---

## Current Stable State

Virus RNG is now in a **modifier-integrated feature-stable state after Piece 4**.

The modifier system is integrated into:

- Manual rolling
- Auto rolling
- Inventory
- Equip / Unequip
- Equipped slots
- Virus collection
- Online earnings
- Offline earnings
- Quest rewards
- Black Market scaling
- Auto Equip Best
- Roll result UI
- Server broadcast UI
- Collection / Index UI

No intentional changes were made to:

- Base virus roll structure
- Existing player save compatibility
- Existing player inventory compatibility
- Existing equipped virus compatibility
- Core server-authoritative roll flow

---

## Current Stable Backup

```txt
VirusRNG_[LATEST_WORKING_BACKUP_NAME]
