# PROJECT_STATE.md

## Current Status

Project: Roblox Luau **Virus RNG / Lab Tycoon simulator**

The game is playable and under active development.

Core systems currently implemented:

- Rolling system
- Modifier system
- Modifier-aware virus inventory
- Modifier-aware equip / unequip
- Virus world display
- Modifier-aware data saving
- Upgrades
- Rebirth
- Daily quests
- Black Market + Buffs
- Friend Boost
- Offline earnings
- Collection / Index UI with modifier filter tabs

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

---

## Current Stable State

Virus RNG is now in a **modifier-integrated state after Piece 4**.

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

## Current Priorities

1. Fix `My Tycoon` asset structure so it contains the expected `Tycoon` folder.
2. Test the modifier system in Roblox Studio play mode:
   - Roll viruses
   - Confirm modifiers can roll
   - Confirm modifier odds scale with luck
   - Confirm Normal rolls still work
   - Confirm modified viruses save correctly
   - Confirm legacy Normal viruses still load correctly
   - Equip modified viruses
   - Unequip modified viruses
   - Confirm equipped stack keys work
   - Confirm income multipliers apply
   - Confirm collection tracking works per modifier
   - Confirm modifier filter tabs display correct progress
   - Confirm `OmegaStrain` and `Aggressive` broadcasts trigger
3. Run mobile/tablet UI testing in Studio emulator.
4. Add final visual modifier variants once base virus models exist.
5. Continue to Piece 5 only after approval.

---

## Known Issues

- `My Tycoon` asset is missing the expected `Tycoon` folder.
- `CollectorGui` template is missing and safely skipped.
- Optional GUI templates are missing and safely skipped.
- Modifier visual variants are not implemented yet.
- Final base virus models/visuals are still deferred.
- Collection / Index UI needs mobile testing because modifier filter tabs add more UI density.

---

## Modifier System Summary

### Modifier Roll Order

Modifiers are rolled rarest-first.

| Id | Display Name | Stat Multiplier | Base 1-in | Min 1-in |
|---|---:|---:|---:|---:|
| `OmegaStrain` | Omega Strain | 30.00x | 10,000 | 2,500 |
| `Aggressive` | Aggressive | 15.00x | 2,500 | 600 |
| `Armored` | Armored | 8.00x | 1,200 | 300 |
| `Hybrid` | Hybrid | 5.00x | 600 | 150 |
| `Adapted` | Adapted | 3.50x | 300 | 75 |
| `Evolved` | Evolved | 2.50x | 150 | 40 |
| `Mutant` | Mutant | 1.75x | 75 | 20 |
| `Normal` | Normal | 1.00x | fallback | — |

### Modifier Luck Formula

```lua
effectiveOneIn = math.max(MinOneInChance, BaseOneInChance / luckMultiplier)
