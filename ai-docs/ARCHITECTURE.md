# Virus RNG Architecture

## Overview

Virus RNG is a Roblox RNG/Tycoon game.

Players:

- Roll viruses
- Collect viruses
- Equip viruses
- Display viruses in the world
- Earn currencies
- Buy upgrades
- Rebirth for progression

---

## Core Systems

### Data System

Responsible for:

- Loading player data
- Saving player data
- Currency storage
- Inventory storage
- Upgrade storage

### Rolling System

Responsible for:

- Virus rolls
- Luck calculations
- Rarity calculations

### Inventory System

Responsible for:

- Owned viruses
- Equip / Unequip
- Inventory UI

### Virus World Display

Responsible for:

- Showing equipped viruses
- Animating displayed viruses

### UI System

Responsible for:

- Currency display
- Inventory display
- Upgrades
- Rebirth

---

## Performance Rules

Avoid:

- New RenderStepped loops
- Frequent polling loops
- Full UI rebuilds

Prefer:

- Events
- Signals
- Incremental updates
