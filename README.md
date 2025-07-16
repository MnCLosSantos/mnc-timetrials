<img width="1024" height="1024" alt="script logo" src="https://github.com/user-attachments/assets/f733410d-2bc2-4aa3-b01e-cc17e41b6233" />

# Midnight Club Los Santos Time Trials 🏎️

A QB-core resource for fiveM that powers thrilling time trial races with customizable buy-ins, rewards, vehicle restrictions, and robust failsafes. 🚗 Create your own races with tailored settings for an epic racing experience! 🎮

## Features 🌟
- **Sleek UI**: HTML interface to select wager tiers and view race details. 🎨
- **Race Mechanics**: Time-based races with start/finish markers. ⏱️
- **Custom Vehicles**: Spawn race cars with mods (wheels, colors, performance). 🛠️
- **Buy-ins & Rewards**: Bet cash, bank, crypto, or items with scalable payouts. 💰
- **Cooldowns**: Prevent spamming with adjustable timers. ⏳
- **NPC Taunts**: Randomized messages near race vehicles for immersion. 🗣️
- **Interactions**: Start races with "Press E" or `qb-target`. 🖱️
- **Debug Tools**: Commands to configure vehicles and blacklists. 🔍
- **Failsafes**: Timeout checks, vehicle validation, and cooldowns ensure fair play. 🛡️

## Requirements 📋
- **QBCore Framework**: Manages player data, notifications, and vehicle spawning. 📦
- **ox_lib**: Powers notifications. 📢
- **qb-target** (Optional): Needed if `Config.UseTarget` is enabled. 🎯

## Setup 🚀
1. Place the `mnc-timetrials` folder in your server's `resources` directory. 📂
2. Add to `server.cfg`:
   - `ensure ox_lib`
   - `ensure qb-core`
   - `ensure qb-target` (if using `qb-target`)
   - `ensure mnc-timetrials`
3. Edit `config.lua` to define your races, buy-ins, rewards, and settings. ✏️
4. Restart the server or run `refresh` and `start mnc-timetrials`. 🔄

## How to Play 🎮
1. **Start a Race** 🏁:
   - Approach a race vehicle (marked by a blip). 📍
   - Press **E** (if `Config.UsePressE = true`) or use `qb-target` (if `Config.UseTarget = true`) within the set distance (e.g., 3.5 meters). 🖱️
   - You must be in a vehicle; some races require a specific model. 🚘

2. **Race UI** 🖥️:
   - Choose a wager tier (e.g., Easy, Medium, Hard) with required buy-ins (cash, bank, crypto, or items). 🎰
   - Close the UI with the **Close** button or **Escape** key. 🚪

3. **Race** 🏎️:
   - Reach the start point within 60 seconds (set by `Config.RaceStartTimeout`). ⏰
   - Drive to the finish before the time limit (adjusted by wager difficulty). 🏆
   - Win to earn payouts or items; lose and hit a cooldown (e.g., 10s for testing, 20min default). 🎁

4. **Debug Commands** 🔧:
   Use these in-game with admin/developer permissions to configure the script:
   - **`/listallwheels`** 🛞:
     - **Purpose**: Lists wheel types (0–12) and rim indices for your current vehicle.
     - **When**: To set `wheelType` and `rimIndex` in `Config.Races.mods`.
     - **How**: Enter a vehicle, type `/listallwheels` in chat, and note the output (e.g., Track = 11, rims 0–25).
     - **Example Output**: "Wheel Type 11 (Track): Rims 0–25 available."
     - **Use Case**: Ensures valid wheel settings (e.g., `wheelType = 11, rimIndex = 1`). ✅
   - **`/printvehmods`** 🎨:
     - **Purpose**: Outputs all vehicle mods (visual/performance) to the console.
     - **When**: To copy mod settings for `Config.Races.mods`.
     - **How**: Modify a vehicle in-game, type `/printvehmods`, and copy the output to `config.lua`.
     - **Example Output**: `{ wheelType = 7, suspension = 2, primaryColor = 90, turbo = true }`.
     - **Use Case**: Sets up mods like neon colors or engine upgrades. 🖌️
   - **`/listfastestvehicles`** 🚀:
     - **Purpose**: Lists top 10 fastest vehicles per class (0–21) based on top speed.
     - **When**: To update `Config.BlacklistedVehicles` for fair races.
     - **How**: Type `/listfastestvehicles` in chat to see vehicles and speeds.
     - **Example Output**: "Class 0 (Compacts): weevil (123.00 mph), brioso2 (115.50 mph)."
     - **Use Case**: Blacklists overpowered vehicles (e.g., `weevil` in Class 0). 🚫

## Configuration ⚙️
The `config.lua` file lets you craft custom races with detailed settings for buy-ins, rewards, and failsafes. Below are all options.

### General Settings
- **`Config.RaceStartTimeout`** ⏲️:
  - **Description**: Time (ms) to reach the race start after selecting a wager. Acts as a failsafe to prevent stalling.
  - **Default**: `60000` (60 seconds).
  - **Example**: `Config.RaceStartTimeout = 30000` (30 seconds).
  - **Failsafe**: If the player doesn’t reach the start point in time, the race cancels, and the buy-in may be forfeited (depending on server logic).

- **`Config.UseTarget`** 🎯:
  - **Description**: Enables `qb-target` for race interactions (requires `qb-target` resource).
  - **Default**: `false` (uses "Press E" if disabled).
  - **Example**: `Config.UseTarget = true`.
  - **Failsafe**: Ensures only one interaction method is active to avoid UI conflicts.

- **`Config.UsePressE`** 🅴:
  - **Description**: Shows "Press E to interact" prompts near race vehicles.
  - **Default**: `true`.
  - **Example**: `Config.UsePressE = false`.
  - **Failsafe**: Prevents interaction overlap if both `UseTarget` and `UsePressE` are enabled.

### Blacklisted Vehicles 🚫
- **`Config.BlacklistedVehicles`**:
  - **Description**: Bans overpowered vehicles by class (0–21) to ensure fair races.
  - **Structure**: Table with class IDs as keys and arrays of vehicle model names as values.
  - **Purpose**: Prevents players from using top-speed vehicles (e.g., `weevil` in Compacts).
  - **How to Update**: Use `/listfastestvehicles` to identify fast vehicles.
  - **Example**:
    ```lua
    Config.BlacklistedVehicles = {
        [0] = {"weevil", "brioso2"}, -- Compacts
        [1] = {"schafter4", "schafter3"}, -- Sedans
        -- ... other classes
    }
    ```
  - **Classes** (0–21):
    - 0: Compacts
    - 1: Sedans
    - 2: SUVs
    - 3: Coupes
    - 4: Muscle
    - 5: Sports Classics
    - 6: Sports
    - 7: Super
    - 8: Motorcycles
    - 9: Off-road
    - 10: Industrial
    - 11: Utility
    - 12: Vans
    - 13: Cycles
    - 14: Boats
    - 15: Helicopters
    - 16: Planes
    - 17: Service
    - 18: Emergency
    - 19: Military
    - 20: Commercial
    - 21: Trains
  - **Failsafe**: The script checks the player’s vehicle against this list, preventing race starts with blacklisted models.

### Races 🏁
- **`Config.Races`**:
  - **Description**: An array of tables where you define custom races with settings for buy-ins, rewards, vehicles, and failsafes.
  - **Structure**: Each race table includes:

    - **`name`** 📛:
      - Race name for UI and blips.
      - Example: `name = "City Sprint"`.

    - **`notifyTitle`** 🗣️:
      - Optional NPC name for proximity notifications.
      - Example: `notifyTitle = "Racer Joe"`.

    - **`requiredVehicle`** 🚗:
      - Optional specific vehicle model players must use (case-insensitive).
      - Example: `requiredVehicle = "jester"`.
      - **Failsafe**: The script checks if the player’s vehicle matches, blocking invalid vehicles.

    - **`proximityNotifies`** 😈:
      - Array of taunts shown near the race vehicle.
      - Example: `proximityNotifies = {"Think you’re fast?", "Nice car, too bad it’s slow!"}`.

    - **`vehicleModel`** 🚘:
      - Model of the spawned race vehicle.
      - Example: `vehicleModel = "elegy2"`.

    - **`vehicleSpawn`** 📍:
      - `vector4` for vehicle spawn (x, y, z, heading).
      - Example: `vehicleSpawn = vector4(100.0, 200.0, 30.0, 90.0)`.

    - **`startPoint`** 📍:
      - `vector4` for race start point and heading.
      - Example: `startPoint = vector4(150.0, 250.0, 30.0, 90.0)`.

    - **`endPoint`** 📍:
      - `vector4` for race finish point and heading.
      - Example: `endPoint = vector4(300.0, 400.0, 30.0, 90.0)`.

    - **`maxTime`** ⏱️:
      - Maximum race duration (seconds).
      - Example: `maxTime = 60.0`.
      - **Failsafe**: Players failing to finish in time lose the race and buy-in.

    - **`cooldown`** ⏳:
      - Cooldown (ms) before the race can be restarted.
      - Example: `cooldown = 20 * 60 * 1000` (20 minutes).
      - **Failsafe**: Prevents spamming by locking the race after completion or failure.

    - **`wagers`** 💰:
      - Array of wager tiers defining buy-ins, difficulty, and rewards.
      - **Fields**:
        - `amount`: Buy-in cost (0 for free).
          - Example: `amount = 5000`.
        - `name`: Difficulty name (e.g., Easy, Medium, Hard).
          - Example: `name = "Easy"`.
        - `timeModifier`: Seconds subtracted from `maxTime` for difficulty.
          - Example: `timeModifier = 2`.
        - `payout`: Reward amount for winning.
          - Example: `payout = 10000`.
        - `paymentType`: Buy-in method (`cash`, `bank`, `crypto`).
          - Example: `paymentType = "bank"`.
        - `rewardItem`: Optional item reward on win.
          - Structure: `{ name = "item_name", amount = number }`.
          - Example: `rewardItem = { name = "tunerchip", amount = 1 }`.
        - `requiredItem`: Optional item required for the wager.
          - Structure: `{ name = "item_name", amount = number }`.
          - Example: `requiredItem = { name = "vipracepass", amount = 1 }`.
          - **Failsafe**: The script checks for sufficient items before starting.
        - `requiredRaces`: Number of race completions for `rewardItem`.
          - Example: `requiredRaces = 3`.
      - **Example**:
        ```lua
        wagers = {
            { amount = 5000, name = "Easy", timeModifier = 0, payout = 10000, paymentType = "bank", rewardItem = { name = "lockpick", amount = 2 }, requiredRaces = 3 },
            { amount = 10, name = "Hard", timeModifier = 4, payout = 20, paymentType = "crypto", requiredItem = { name = "vipracepass", amount = 1 } }
        }
        ```

    - **`allowedClasses`** 🏎️:
      - Array of allowed vehicle classes (0–21, see Blacklisted Vehicles).
      - Example: `allowedClasses = { 6 }` (Sports).
      - **Failsafe**: The script verifies the player’s vehicle class, blocking invalid ones.

    - **`mods`** 🎨:
      - Modifications for the spawned race vehicle.
      - **Fields**:
        - `wheelType`: Wheel category (0=Sport, 1=Muscle, ..., 11=Track, 12=Benny's Originals).
          - Example: `wheelType = 11`.
        - `rimIndex`: Rim index (0–n, depends on `wheelType`).
          - Example: `rimIndex = 1`.
        - `suspension`: Suspension level (0=Stock, 1=Lowered, ..., 4=Competition).
          - Example: `suspension = 2`.
        - `livery`: Livery index (0–n, depends on vehicle).
          - Example: `livery = -1` (default).
        - `spoiler`, `hood`, `skirts`, `frontBumper`, `rearBumper`: Visual mod indices (0–n).
          - Example: `spoiler = 0`.
        - `primaryColor`, `secondaryColor`, `pearlescent`, `wheelColor`: Color indices (0–160).
          - Example: `primaryColor = 90`.
        - `windowTint`: Tint level (0=None, 1=Pure Black, ..., 5=Limo).
          - Example: `windowTint = 3`.
        - `plateIndex`: Plate type (0=Blue/White, ..., 9=SA Exempt 2, ..., 12=Black Plate).
          - Example: `plateIndex = 9`.
        - `neon`: RGB color for neon lights (requires neon enabled).
          - Example: `neon = {255, 0, 255}` (purple).
        - `headlights`: Xenon headlight color (0=White, 1=Blue, ..., 12=Blacklight).
          - Example: `headlights = 2`.
        - `engine`, `transmission`, `brakes`: Performance mods (0=Stock, ..., 3=Race).
          - Example: `engine = 3`.
        - `turbo`: Enable turbo (`true` or `false`).
          - Example: `turbo = true`.
      - **Example**:
        ```lua
        mods = {
            wheelType = 7,
            rimIndex = 3,
            suspension = 2,
            livery = 2,
            primaryColor = 90,
            neon = {255, 0, 255},
            headlights = 7,
            engine = 3,
            turbo = true
        }
        ```

    - **`ped`** 🧍:
      - Optional NPC at the race vehicle.
      - **Fields**:
        - `model`: Ped model (e.g., `s_m_y_xmech_02`).
        - `coords`: `vector4` for ped location and heading.
        - `animationSet`: Animation dictionary and animations.
          - Structure: `{ dict = "animation_dict", anims = {"anim_name"} }`.
          - Example: `animationSet = { dict = "cellphone@", anims = {"cellphone_call_listen_base"} }`.
      - **Example**:
        ```lua
        ped = {
            model = "s_m_y_xmech_02",
            coords = vector4(100.0, 200.0, 30.0, 90.0),
            animationSet = { dict = "cellphone@", anims = {"cellphone_call_listen_base"} }
        }
        ```

    - **`target`** 🎯:
      - Settings for `qb-target` interactions (if `Config.UseTarget = true`).
      - **Fields**:
        - `label`: Interaction label in UI.
          - Example: `label = "Start Race"`.
        - `icon`: FontAwesome icon (e.g., `fas fa-car`).
        - `distance`: Interaction range (meters).
          - Example: `distance = 3.5`.
      - **Example**:
        ```lua
        target = {
            label = "Start Race",
            icon = "fas fa-car",
            distance = 3.5
        }
        ```

  - **Example Race**:
    ```lua
    Config.Races = {
        {
            name = "City Loop",
            notifyTitle = "Racer",
            requiredVehicle = "comet5",
            proximityNotifies = {"Ready to race?", "Show me your speed!"},
            vehicleModel = "comet5",
            vehicleSpawn = vector4(100.0, 200.0, 30.0, 90.0),
            startPoint = vector4(150.0, 250.0, 30.0, 90.0),
            endPoint = vector4(300.0, 400.0, 30.0, 90.0),
            maxTime = 60.0,
            cooldown = 20 * 60 * 1000,
            wagers = {
                { amount = 5000, name = "Easy", timeModifier = 0, payout = 10000, paymentType = "bank" }
            },
            allowedClasses = { 6 },
            mods = { wheelType = 7, primaryColor = 90, turbo = true },
            target = { label = "Start Race", icon = "fas fa-car", distance = 3.5 }
        }
    }
    ```

### Buy-ins 💸
Buy-ins are defined in the `wagers` table and are required to start a race:
- **Currency Buy-ins**:
  - Set via `amount` and `paymentType` (`cash`, `bank`, `crypto`).
  - Example: `{ amount = 5000, paymentType = "bank" }` requires 5,000 in bank funds.
  - **Failsafe**: The script checks if the player has sufficient funds before starting; if not, the race is blocked with a notification.
- **Item Buy-ins**:
  - Set via `requiredItem` with `{ name = "item_name", amount = number }`.
  - Example: `{ requiredItem = { name = "vipracepass", amount = 1 } }` requires 1 `vipracepass`.
  - **Failsafe**: The script verifies the player’s inventory for the required item and amount, preventing race start if missing.

### Reward Types 🎁
Rewards are defined in the `wagers` table and granted on race completion:
- **Currency Payouts**:
  - Set via `payout` and `paymentType` (`cash`, `bank`, `crypto`).
  - Example: `{ payout = 10000, paymentType = "bank" }` awards 10,000 in bank funds.
- **Item Rewards**:
  - Set via `rewardItem` with `{ name = "item_name", amount = number }`.
  - Example: `{ rewardItem = { name = "tunerchip", amount = 1 } }`.
  - Requires `requiredRaces` completions to unlock.
  - Example: `{ requiredRaces = 3 }` means 3 wins for the item.
- **Failsafe**: The script tracks race completions (`requiredRaces`) and ensures rewards are only given when conditions are met.

### Failsafes 🛡️
The script includes several failsafes to ensure smooth and fair gameplay:
- **Race Start Timeout** (`Config.RaceStartTimeout`): Cancels the race if the player doesn’t reach the start point in time, protecting against stalling.
- **Vehicle Validation** (`requiredVehicle`, `allowedClasses`): Checks the player’s vehicle against required models or classes, blocking invalid entries.
- **Blacklist Check** (`Config.BlacklistedVehicles`): Prevents overpowered vehicles from being used, ensuring balance.
- **Buy-in Validation** (`amount`, `requiredItem`): Verifies sufficient funds or items before starting, avoiding exploits.
- **Cooldown System** (`cooldown`): Locks races after completion or failure to prevent spamming.
- **Interaction Exclusivity** (`UseTarget`, `UsePressE`): Ensures only one interaction method is active to avoid conflicts.

## Customization 🎨
1. **Create New Races** 🏁:
   - Add a table to `Config.Races` with custom settings for buy-ins, vehicles, and locations.
   - Use in-game coordinates (e.g., via a coords command) for `vehicleSpawn`, `startPoint`, and `endPoint`.
   - Example:
     ```lua
     {
         name = "Highway Dash",
         vehicleModel = "pariah",
         vehicleSpawn = vector4(x, y, z, h),
         startPoint = vector4(x, y, z, h),
         endPoint = vector4(x, y, z, h),
         maxTime = 70.0,
         cooldown = 20 * 60 * 1000,
         wagers = { { amount = 10000, name = "Easy", timeModifier = 0, payout = 20000, paymentType = "cash" } },
         allowedClasses = { 6 },
         mods = { wheelType = 7, turbo = true }
     }
     ```

2. **Customize Buy-ins & Rewards** 💰:
   - Add wager tiers with `amount`, `paymentType`, or `requiredItem` for buy-ins, and `payout` or `rewardItem` for rewards.
   - Example:
     ```lua
     { amount = 20, name = "Insane", timeModifier = 10, payout = 40, paymentType = "crypto", requiredItem = { name = "vipracepass", amount = 1 }, rewardItem = { name = "nitrous", amount = 1 } }
     ```

3. **Tune Vehicle Mods** 🛠️:
   - Use `/printvehmods` to copy mod indices after customizing a vehicle in-game.
   - Example: Set `primaryColor = 141` (Hot Pink), `neon = {255, 0, 255}` (purple).

4. **Adjust UI** 🖥️:
   - Edit `html/style.css` to reposition or style UI elements (e.g., `#main-menu`).
   - Example:
     ```css
     #main-menu { top: 10%; left: 10%; width: 400px; }
     ```

## Tips 📝
- Verify vehicle models exist in your server. ✅
- Test coordinates in-game to avoid spawn issues. 📍
- Balance `maxTime` and `timeModifier` for fair difficulty. ⚖️
- Use short cooldowns (e.g., 10000ms) for testing, 20min (1200000ms) for live. ⏳
- Use `/listallwheels` and `/printvehmods` for accurate mod settings. 🔧
