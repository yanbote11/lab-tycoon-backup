# ARCHITECTURE.md

## Overview

Virus RNG is a Roblox RNG/Tycoon game.

Players can:

- Roll viruses
- Roll virus modifiers
- Collect viruses and modifier variants
- Equip viruses
- Display equipped viruses in the world
- Earn currencies boosted by virus stats and modifier multipliers
- Buy upgrades
- Complete daily quests
- Use Black Market buffs
- Receive Friend Boost bonuses
- Earn offline income
- Rebirth for long-term progression

---

## Latest Architecture Change

### Piece 4 — Modifier System Integration

Piece 4 added a modifier layer on top of the existing virus rolling system.

The modifier system affects:

- Roll results
- Inventory entries
- Collection progress
- Equip / Unequip
- Equipped slots
- Online earnings
- Offline earnings
- Quest rewards
- Black Market scaling
- Auto Equip Best
- Roll result UI
- Server broadcast UI
- Collection / Index UI

The modifier system does **not** replace the base virus rolling system.

The base roll still chooses the virus first.  
The modifier roll happens after the base virus is chosen.

Current roll flow:

```txt
Player requests roll
Server validates cooldown/cost
Server rolls base virus
Server rolls modifier using luckMultiplier
Server grants rewards with modifier multiplier
Server saves inventory entry
Server updates VirusCollection
Server sends RollResult payload to client
Client displays virus + modifier result
