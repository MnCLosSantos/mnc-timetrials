<img width="1024" height="1024" alt="image" src="https://github.com/user-attachments/assets/4dc19d64-6bcb-4264-ae2a-652fdac64034" />

# Midnight Club: (Time Trials)

A QBCore-based racing script for FiveM featuring solo wager-based time trials with high-stakes rewards,  vehicle mods, race class restrictions, and optional NPC/target interaction.

---

## Features

### ✨ Immersive Experience

* **Blip-based vehicle spawns** for each race.
* **Start/Finish line props** with synchronized particle effects.
* **Neon-lit, pre-modded vehicles** tailored per race.
* **Randomized proximity NPC quotes** for added atmosphere.

### ⛽ Race Mechanics

* Solo, **player-triggered time trials**.
* **Wager system**: bet against the clock, earn cash,crypto and items if you succeed.
* **Cooldown system** prevents spam starts.
* Vehicle **class restrictions** and validation.
* Automatically **detects vehicle switching** and cancels race if tampered.

### 🚗 Vehicle Mod Support

* Full vehicle mod application per race entry, supporting:

  * Wheel type and rim selection
  * Performance upgrades (engine, transmission, turbo, brakes)
  * Visual mods (hoods, bumpers, skirts, livery, colors)
  * Lighting: neon & xenon with configurable colors
  * Plate & tint styles

### 🕹️ Interaction Methods

* Configurable interaction: either **Press E** proximity detection or **qb-target** integration.
* Optional **race NPCs with animations**

### 🌟 UI & UX

* Integrated **NUI race UI** with selectable wagers.
* HUD countdown with sounds & notifications.
* Blip & waypoint management.
* Proximity-based race tips/quotes.

---

## Commands

### `/listallwheels`

* Prints all available rim styles across all wheel types for current vehicle.

### `/printvehmods`

* Logs current vehicle's applied mods for config use.

---

## Installation

1. Add the script to your resource folder.
2. Add `ensure mnc-timetrials` to your `server.cfg`.
3. Configure races in `Config.Races`.
4. Adjust mod templates for race vehicles if desired.

---

## Dependencies

* [qb-core](https://github.com/qbcore-framework/qb-core) inventory/banking/core
* [ox\_lib](https://overextended.dev)
* Optionally: [qb-target](https://github.com/qbcore-framework/qb-target) if `UseTarget` enabled. and qb-crypto (if crypto not found uses bank)

---

## Configuration

Edit the `Config.Races` structure to define:

* `vehicleModel`: Vehicle used in the race.
* `mods`: Table of modifications applied to vehicle your in (see `printvehmods` output).
* `startPoint`, `endPoint`: Vector3 race start/end.
* `maxTime`: Time limit.
* `cooldown`: Post-race cooldown in ms.
* `wagers`: Table of wager tiers (amount, timeModifier, payout).
* `allowedClasses`: Vehicle class whitelist.
* `ped`: (Optional) NPC model, animationSet.
* `target`: Icon, label, distance for target mode.

---

## Development Notes

* Fully modular and extensible.
* Compatible with multiplayer FiveM environments.
* Future-ready for leaderboard/stat tracking or custom race paths.

---

## Support

For help or contributions, contact the script author or refer to the F8 console logs for debug messages, including:

* Mod application logs
* Livery/extra availability
* Proximity checks
* Wager selection traces

---

**Midnight Club: Pinkslips** — High Stakes. Fast Laps. No Mercy.
