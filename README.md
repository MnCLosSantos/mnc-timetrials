# 🏁 Midnight Club - Time Trials with Wagers 🏆
![mnc-timetrials-logo](https://github.com/user-attachments/assets/a81ce027-10fd-4325-a813-0b12a847dd35)
## 🚦 Overview

Welcome to **Midnight Club Time Trials** – bring the thrill of wager-based racing to your FiveM server! Challenge players to beat the clock, risk their cash, bank, or crypto, and unlock exclusive rewards! Fully compatible with QBCore, packed with customization, immersive UI, and plenty of racing attitude.  
**Get started, get paid, get respect.**

---

## ✨ Features

- 🏎️ **Multiple Custom Races** – Set up unique routes, vehicles, and challenges in `config.lua`.
- 💸 **Buy-ins & Payouts** – Race for **cash**, **bank**, or **crypto**. The bigger the buy-in, the bigger the rewards!
- 🎁 **Rewards & Required Items** – Win items for completing race streaks and require special items for entry (e.g., VIP Race Pass).
- 🚫 **Vehicle Restrictions & Blacklist** – Limit races to certain vehicles or classes, block the fastest cars for fair play.
- 🕹️ **Dynamic UI** – Vibrant, pulsing race info overlay; customizable and movable.
- 👤 **NPC & Vehicle Spawns** – Each race can spawn a character and a display vehicle at the start point.
- 🔔 **Proximity Taunts** – Get hyped or roasted as you approach races!
- 🕹️ **Flexible Interaction** – Supports both "Press E" prompts and (optional) **qb-target** integration.
- ⏱️ **Cooldowns & Progress Tracking** – Prevent spam, track your wins, and earn streak rewards.
- 🛠️ **Easy Commands** – Admin commands for quick setup and cleanup (see below).
- ⚙️ **Easy Setup & Expansion** – All configuration in one file, add races in minutes!

---

## 📝 Setup

1. **Dependencies:**  
   - QBCore Framework  
   - ox_lib  
   - oxmysql

2. **Installation:**  
   - Place the folder in your `resources` directory.  
   - Add `ensure midnightclub-timetrials` to your server config.  
   - Make sure dependencies start first!

3. **Configuration:**  
   - Edit `config.lua` to set up races, buy-ins/buyouts, rewards, vehicles, NPCs, and more.
   - Customize proximity taunts, blip names, UI positions, and cooldowns.

---

## 💰 Buy-ins, Payouts, Rewards & Required Items

Each race offers **multiple wager tiers**.  
Players choose their buy-in (cash, bank, or crypto) and receive payouts plus progress toward item rewards!

### Example Wager Tier (from `config.lua`):

```lua
wagers = {
    {
        amount = 2000,          -- 💵 Buy-in
        name = "Easy",          -- Difficulty
        timeModifier = 0,       -- Time bonus
        payout = 4000,          -- 🤑 Payout
        paymentType = "cash",   -- Type: cash/bank/crypto
        rewardItem = { name = "tunerchip", amount = 1 }, -- 🎁 Item reward
        requiredItem = { name = "phone", amount = 1 },   -- 🛡️ Required to enter
        requiredRaces = 3       -- ✨ Complete streak for item
    },
    -- ...more tiers!
}
```

- **Required Items:** Some races need special items (e.g. VIP Race Pass).
- **Rewards:** Win cash, crypto, or exclusive items after a set number of wins.
- **Progress:** Race completion tracked per player, per wager.

---

## 🚗 Vehicle Classes & Blacklist

- Restrict races to certain vehicle classes (e.g. only Compacts).
- Automatically block the top 10 fastest cars in each class for balanced competition.
- Set a **required vehicle model** for themed races!
- **Blacklist & Classes** are fully customizable in `config.lua`.

---

## 🎮 Commands & Usage

- **Start a Race:**  
  Drive to a race marker, press **E** or use the qb-target zone to open the UI.
- **Select Wager:**  
  Choose your buy-in, see the time limit, and accept the challenge.
- **Complete the Race:**  
  Beat the clock to win your payout and progress toward item rewards!
- **Admin Commands:**  
  Cleanup or respawn NPCs and vehicles by restarting the resource.

---

## 📦 File Structure

| File                      | Purpose                                      |
|---------------------------|----------------------------------------------|
| `client.lua`              | Player logic, UI, controls, events           |
| `server.lua`              | Wagers, payouts, race progress, anti-cheat   |
| `config.lua`              | All race, reward, vehicle & NPC settings     |
| `vehicle_spawner.lua`     | NPC/vehicle spawn & cleanup (server)         |
| `vehicle_spawner_client.lua` | NPC/vehicle spawn (client)                |
| `fxmanifest.lua`          | Resource manifest, dependencies              |
| `html/`                   | UI assets (customizable)                     |

---

## 🛠️ Customization

- **Add Races:** Copy/paste a race entry in `Config.Races` and set locations, vehicles, rewards, etc.
- **Change UI:** Edit UI HTML/CSS for a custom look.
- **Tweak Difficulty:** Adjust time limits, payouts, required items, and vehicle restrictions.
- **Edit Taunts:** Make your server's races as friendly or savage as you like!

---

## 🙏 Credits

- Developed by **Midnight Club**
- Inspired by classic street racing and time trial games

---

## 🆘 Support

Open a GitHub issue for help, suggestions, or bug reports!

---

**Start your engines. Bet big. Race hard. Win respect.**
