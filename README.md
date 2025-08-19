# 🏁 Midnight Club - Time Trials with Wagers 🏆

![mnc-timetrials-logo](https://github.com/user-attachments/assets/63f7ad78-77ac-4b6c-8c82-4c24f0fc277a)


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
   - Add `ensure mnc-timetrials` to your server config.  
   - Make sure dependencies start first!

3. **Configuration:**  
   - Edit `config.lua` to set up races, buy-ins/buyouts, rewards, vehicles, NPCs, and more.
   - Customize proximity taunts, blip names, and cooldowns.

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

## 🚗 Vehicle Classes & Blacklist.

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

## 🛠️ Customization

- **Add Races:** Copy/paste a race entry in `Config.Races` and set locations, vehicles, rewards, etc.
- **Change UI:** Edit UI HTML/CSS for a custom look.
- **Tweak Difficulty:** Adjust time limits, payouts, required items, and vehicle restrictions.
- **Edit Taunts:** Make your server's races as friendly or savage as you like!

- Original Ui
<img width="1920" height="1080" alt="a-original" src="https://github.com/user-attachments/assets/a34ec35a-dd0f-4b6b-953a-ec0d781af427" />

- basic-1
<img width="1920" height="1080" alt="basic-1" src="https://github.com/user-attachments/assets/2b5a5104-6116-4621-a126-cafe034c692a" />

- basic-2
<img width="1920" height="1080" alt="basic-2" src="https://github.com/user-attachments/assets/dd43b8eb-528d-4e12-bffd-30a2b4151232" />

- basic-3
<img width="1920" height="1080" alt="basic-3" src="https://github.com/user-attachments/assets/416fd168-ef81-42ae-851e-95bc70982cb6" />

- basic-4
<img width="1920" height="1080" alt="basic-4" src="https://github.com/user-attachments/assets/885dcc65-592e-4100-b2d4-1aa32e458159" />

- simple-1
<img width="1920" height="1080" alt="simple-1" src="https://github.com/user-attachments/assets/d6fbc82c-ebdd-4ac1-b82b-009eb694fa23" />

- simple-2
<img width="1920" height="1080" alt="simple-2" src="https://github.com/user-attachments/assets/c49a17a2-37cb-4c6e-abe4-c1da750713b2" />

- simple-3
<img width="1920" height="1080" alt="simple-3" src="https://github.com/user-attachments/assets/e6fdb901-b663-4808-83d4-c48218878beb" />

- simple-4
<img width="1920" height="1080" alt="simple-4" src="https://github.com/user-attachments/assets/fd017d1b-7be4-4a96-a170-ed56889cf6b2" />


## 🙏 Credits

- Developed by **Stan Leigh**
- Inspired by classic street racing and time trial games

---

## 🆘 Support

Open a GitHub issue for help, suggestions, or bug reports!

---

**Start your engines. Bet big. Race hard. Win respect.**

--------------------------------------------------------------------------------------------------------------------------------------

| Code is accessible | Yes |
| Subscription | No |
| Support | Yes |
