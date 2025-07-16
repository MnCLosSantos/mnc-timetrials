<img width="1024" height="1024" alt="image" src="https://github.com/user-attachments/assets/4dc19d64-6bcb-4264-ae2a-652fdac64034" />

Midnight Club Los Santos Time Trials 🏎️💨
Overview 🌟
Midnight Club Los Santos Time Trials is a FiveM resource for GTA V that lets players dive into thrilling time trial races with customizable wagers, vehicle restrictions, and epic rewards! 🎮 Players interact with race vehicles to open a slick UI, pick wager tiers (Easy, Medium, Hard, Extreme), and burn rubber to beat the clock. 🚗💥
Key Features 🔥

Dynamic UI 🎨: Sleek HTML-based interface for picking wagers and race details.
Race Mechanics ⏱️: Time-based races with start/finish markers and vehicle class restrictions.
Vehicle Customization 🛠️: Spawn race cars with custom mods (wheels, colors, performance boosts).
Wager System 💰: Bet cash, bank, or crypto with scaling difficulty and rewards.
Cooldown System ⏳: Prevents race spamming with configurable cooldowns.
Proximity Notifications 🗣️: NPCs taunt players near race vehicles with spicy messages.
Interaction Options 🖱️: Use "Press E" prompts or qb-target to start races.
Debug Commands 🛡️: Handy tools to tweak vehicle mods and blacklist OP cars.

Dependencies 🛠️

QBCore Framework 📦: Powers player data, notifications, and vehicle spawning.
ox_lib 📢: Handles notifications.
qb-target (Optional) 🎯: Needed if Config.UseTarget is enabled.

Installation 🚀

Drop the resource folder (e.g., mnc-timetrials) into your FiveM server's resources directory. 📂
Add ensure ox_lib, ensure qb-core, and (if used) ensure qb-target to server.cfg. ⚙️
Add ensure mnc-timetrials to server.cfg. ✅
Tweak config.lua to customize races, vehicles, and settings. ✏️
Restart the server or run refresh and start mnc-timetrials. 🔄

Usage 🎮

Starting a Race 🏁:

Roll up to a race vehicle (marked with a blip). 📍
Press E (if Config.UsePressE = true) or use qb-target (if Config.UseTarget = true) within 3.5 meters. 🖱️
You need to be in a vehicle; some races require specific ones (e.g., kanjo for Hector's Time Trial). 🚘


Race UI 🖥️:

Pick a wager (Easy, Medium, Hard, Extreme) to kick off the race. 🎰
Wagers may need cash, bank, crypto, or items (e.g., vipracepass for Extreme). 💸
Close the UI with the Close button or Escape. 🚪


Racing 🏎️:

Hit the start point within 60 seconds (Config.RaceStartTimeout). ⏰
Race to the finish within the time limit (adjusted by wager timeModifier). 🏆
Win to score payouts and items; lose and face a cooldown (10s for testing or 20min). 🎁


Debug Commands 🔍:These commands are for server admins to fine-tune the script. Run them in-game with admin/developer permissions (check your QBCore setup). 🛡️

/listallwheels 🛞:

Purpose: Shows all wheel types and rim indices for your current vehicle.
When to Use: When setting up Config.Races.mods to pick valid wheelType (0–12) and rimIndex values.
How to Use: Jump into the vehicle (e.g., kanjo), type /listallwheels in chat, and check the output for wheel categories (e.g., 11 = Track) and rims.
Example Output: "Wheel Type 11 (Track): Rims 0–25 available."
Use Case: Ensures wheelType = 11, rimIndex = 1 is valid for Hector's Time Trial. ✅


/printvehmods 🎨:

Purpose: Dumps all current vehicle mods (visual/performance) to the console.
When to Use: To copy exact mod settings for Config.Races.mods to match in-game setups.
How to Use: Get in the vehicle, apply mods (e.g., via mod shop), type /printvehmods, and copy the output (e.g., primaryColor, turbo) to config.lua.
Example Output: { wheelType = 7, suspension = 2, primaryColor = 90, turbo = true, ... }.
Use Case: Perfect for setting up mods like calico in Race 2 (e.g., primaryColor = 18, neon = {255, 0, 255}). 🖌️


/listfastestvehicles 🚀:

Purpose: Lists the top 10 fastest vehicles per class (0–21) based on fully upgraded top speed.
When to Use: To update Config.BlacklistedVehicles and block overpowered vehicles.
How to Use: Type /listfastestvehicles in chat. The output lists vehicles per class (e.g., Class 0: weevil at 123.00 mph).
Example Output: "Class 0 (Compacts): weevil (123.00 mph), brioso2 (115.50 mph), ..."
Use Case: Helps maintain Config.BlacklistedVehicles (e.g., banning weevil for Class 0 races). 🚫





Configuration ⚙️
The config.lua is your playground for customizing races. Key sections include:
General Settings 🛠️

Config.RaceStartTimeout: 60000ms (1min) to reach the start point. ⏲️
Config.UseTarget: false (enable qb-target if true). 🎯
Config.UsePressE: true (shows "Press E" prompts). 🅴

Blacklisted Vehicles 🚫

Config.BlacklistedVehicles: Blocks top 10 fastest vehicles per class (0–21) to keep races fair.
Example: Class 0 (Compacts) bans weevil (123.00 mph). 🐞
Use /listfastestvehicles to refresh this list. 🔄



Races 🏁
Config.Races defines four races with:

name: Race name (e.g., "Hectors Time Trial"). 📛
notifyTitle: NPC name for notifications (e.g., "Hector"). 🗣️
requiredVehicle: Specific vehicle needed (e.g., kanjo for Race 1). 🚗
proximityNotifies: Taunts near race vehicles (e.g., "Your ride looks slow!"). 😈
vehicleModel: Spawned vehicle (e.g., kanjo, calico, sultan2, vstr). 🚘
vehicleSpawn, startPoint, endPoint: vector4 coordinates and headings. 📍
maxTime: Race duration (60–75 seconds). ⏱️
cooldown: Post-race cooldown (10s for testing or 20min). ⏳
wagers: Tiers with amount, name, timeModifier, payout, paymentType, rewardItem, requiredItem, requiredRaces. 💰
allowedClasses: Allowed vehicle classes (e.g., {0} for Compacts). 🏎️
mods: Vehicle mods (wheels, colors, performance). 🎨
ped: NPC details (model, coords, animations) for Race 1. 🧍
target: qb-target settings (label, icon, distance). 🎯

Vehicle Modifications 🛞

wheelType: 0–12 (e.g., 11 = Track). 🛞
rimIndex, suspension, livery, spoiler, etc.: Visual/performance mods. 🔧
primaryColor, secondaryColor, pearlescent, wheelColor: 0–160. 🌈
windowTint: 0–5 (e.g., 3 = Light Smoke). 🪟
plateIndex: 0–12 (e.g., 9 = SA Exempt 2). 📜
neon: RGB colors (e.g., {255, 0, 255} for purple). 💡
headlights: Xenon colors (0–12). 💡
engine, transmission, brakes: 0–3 (e.g., 3 = Race). ⚡
turbo: true/false. 🚀

Use /printvehmods to grab mod settings. 📋
Customizing 🎨

Add New Races 🏁:

Copy a race table in Config.Races, update name, vehicleModel, coordinates, etc.
Example:{
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




Modify Wagers 💸:

Tweak amount, payout, timeModifier, or add requiredItem/rewardItem.
Example: Add a wager for 10 crypto:{ amount = 10, name = "Insane", timeModifier = 10, payout = 20, paymentType = "crypto" }




Update Vehicle Mods 🛠️:

Use /printvehmods to copy mod indices.
Example: Set wheelType = 7 (High End) and primaryColor = 141 (Hot Pink). 🌸




Notes 📝

Verify vehicle models (e.g., kanjo, calico) exist in your server. ✅
Test coordinates in-game to avoid spawning glitches. 📍
Balance maxTime and timeModifier for race distance and difficulty. ⚖️
Use short cooldowns (e.g., 10000ms) for testing, then switch to 20min (1200000ms). ⏳
