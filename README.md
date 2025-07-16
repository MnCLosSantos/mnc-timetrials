# Midnight Club Los Santos Time Trials 🏎️

A FiveM resource for GTA V that lets players race against the clock in customizable time trials with wagers, vehicle restrictions, and rewards. 🚗

## Features 🌟
- **Sleek UI**: HTML interface to pick wagers (Easy, Medium, Hard, Extreme). 🎨
- **Races**: Time-based challenges with start/finish markers. ⏱️
- **Custom Vehicles**: Spawn race cars with mods (wheels, colors, turbo). 🛠️
- **Wagers**: Bet cash, bank, or crypto for payouts and items. 💰
- **Cooldowns**: Prevent spamming with adjustable timers. ⏳
- **NPC Taunts**: Funny messages near race vehicles. 🗣️
- **Interactions**: Use "Press E" or `qb-target` to start races. 🖱️
- **Debug Tools**: Commands to tweak vehicles and settings. 🔍

## Requirements 📋
- **QBCore Framework**: For player data and notifications.
- **ox_lib**: For notifications.
- **qb-target** (Optional): If `Config.UseTarget` is enabled.

## Setup 🚀
1. Add the `mnc-timetrials` folder to your server's `resources` directory. 📂
2. Add to `server.cfg`:
   - `ensure ox_lib`
   - `ensure qb-core`
   - `ensure qb-target` (if using)
   - `ensure mnc-timetrials`
3. Edit `config.lua` to customize races and settings. ✏️
4. Restart the server or run `refresh` and `start mnc-timetrials`. 🔄

## How to Play 🎮
1. **Start a Race** 🏁:
   - Find a race vehicle (marked by a blip). 📍
   - Press **E** (if `Config.UsePressE = true`) or use `qb-target` (if `Config.UseTarget = true`). 🖱️
   - You need a vehicle; some races require a specific one (e.g., `kanjo`). 🚘

2. **Race UI** 🖥️:
   - Choose a wager (Easy, Medium, Hard, Extreme). 🎰
   - Pay with cash, bank, crypto, or items (e.g., `vipracepass`). 💸
   - Close with **Close** button or **Escape**. 🚪

3. **Race** 🏎️:
   - Reach the start point in 60 seconds. ⏰
   - Hit the finish line before the time limit (adjusted by wager difficulty). 🏆
   - Win for payouts/items; lose and wait out a cooldown (10s for testing, 20min default). 🎁

4. **Debug Commands** 🔧:
   Use these in-game (with admin permissions) to customize the script:
   - **`/listallwheels`** 🛞:
     - **What**: Lists wheel types (0–12) and rims for your vehicle.
     - **When**: To set `wheelType` and `rimIndex` in `config.lua`.
     - **How**: Enter a vehicle (e.g., `kanjo`), type `/listallwheels` in chat.
     - **Example**: "Wheel Type 11 (Track): Rims 0–25."
     - **Why**: Ensures valid wheel settings (e.g., `wheelType = 11, rimIndex = 1`).
   - **`/printvehmods`** 🎨:
     - **What**: Shows all vehicle mods (colors, turbo, etc.).
     - **When**: To copy mods for `Config.Races.mods`.
     - **How**: Mod a vehicle, type `/printvehmods`, copy the output.
     - **Example**: `{ wheelType = 7, primaryColor = 90, turbo = true }`.
     - **Why**: Sets up mods like `calico` (e.g., `neon = {255, 0, 255}`).
   - **`/listfastestvehicles`** 🚀:
     - **What**: Lists top 10 fastest vehicles per class (0–21).
     - **When**: To update `Config.BlacklistedVehicles`.
     - **How**: Type `/listfastestvehicles` in chat.
     - **Example**: "Class 0: weevil (123.00 mph), brioso2 (115.50 mph)."
     - **Why**: Blocks overpowered vehicles (e.g., `weevil` in Class 0).

## Configuration ⚙️
Edit `config.lua` to tweak the script:

### General Settings
- `Config.RaceStartTimeout`: 60s to reach the start point. ⏲️
- `Config.UseTarget`: `false` (use `qb-target` if `true`). 🎯
- `Config.UsePressE`: `true` (shows "Press E" prompts). 🅴

### Blacklisted Vehicles 🚫
- `Config.BlacklistedVehicles`: Bans top 10 fastest vehicles per class (e.g., `weevil` for Compacts). Use `/listfastestvehicles` to update.

### Races 🏁
Four races with:
- `name`: Race name (e.g., "Hectors Time Trial"). 📛
- `notifyTitle`: NPC name (e.g., "Hector"). 🗣️
- `requiredVehicle`: Specific car (e.g., `kanjo` for Race 1). 🚗
- `proximityNotifies`: Taunts (e.g., "Your ride looks slow!"). 😈
- `vehicleModel`: Spawned car (e.g., `kanjo`, `calico`). 🚘
- `vehicleSpawn`, `startPoint`, `endPoint`: Coordinates. 📍
- `maxTime`: Race time (60–75s). ⏱️
- `cooldown`: Wait time (10s or 20min). ⏳
- `wagers`: Bet options (amount, difficulty, payout, items). 💰
- `allowedClasses`: Allowed vehicle classes (e.g., `{0}` for Compacts). 🏎️
- `mods`: Vehicle mods (wheels, colors, etc.). 🎨
- `ped`: NPC for Race 1 (model, coords, animations). 🧍
- `target`: `qb-target` settings (label, icon, distance). 🎯

### Vehicle Mods 🛞
- `wheelType`: 0–12 (e.g., 11 = Track). 🛞
- `rimIndex`, `suspension`, `livery`, etc.: Visual/performance mods. 🔧
- `primaryColor`, etc.: 0–160 (colors). 🌈
- `windowTint`: 0–5 (e.g., 3 = Light Smoke). 🪟
- `plateIndex`: 0–12 (e.g., 9 = SA Exempt 2). 📜
- `neon`: RGB (e.g., `{255, 0, 255}` for purple). 💡
- `headlights`: 0–12 (xenon colors). 💡
- `engine`, etc.: 0–3 (e.g., 3 = Race). ⚡
- `turbo`: `true`/`false`. 🚀

Use `/printvehmods` to copy mod settings. 📋

## Customization 🎨
1. **Add Races** 🏁:
   - Copy a race in `Config.Races`, update `name`, `vehicleModel`, etc.
   - Example:
     ```lua
     {
         name = "New Race",
         vehicleModel = "jester",
         vehicleSpawn = vector4(x, y, z, h),
         startPoint = vector4(x, y, z, h),
         endPoint = vector4(x, y, z, h),
         maxTime = 70.0,
         cooldown = 20 * 60 * 1000,
         wagers = { ... },
         allowedClasses = { 6 },
         mods = { ... }
     }
     ```

2. **Tweak Wagers** 💸:
   - Adjust `amount`, `payout`, or add items.
   - Example:
     ```lua
     { amount = 10, name = "Insane", timeModifier = 10, payout = 20, paymentType = "crypto" }
     ```

3. **Update Mods** 🛠️:
   - Use `/printvehmods` for accurate mod values.
   - Example: Set `wheelType = 7`, `primaryColor = 141`. 🌸

4. **Adjust UI** 🖥️:
   - Edit `html/style.css` to move/resize UI.
   - Example:
     ```css
     #main-menu { top: 10%; left: 10%; }
     ```

## Tips 📝
- Check vehicle models (e.g., `kanjo`) exist in your server. ✅
- Test coordinates to avoid spawn issues. 📍
- Balance `maxTime` and `timeModifier` for fair races. ⚖️
- Use short cooldowns (10000ms) for testing, 20min (1200000ms) for live. ⏳
