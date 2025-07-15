Config = {}

-- Time (in milliseconds) players have to reach the race start after interaction
-- Do not change unless you update the notification logic accordingly
Config.RaceStartTimeout = 60000

-- Interaction settings:
-- If true, use qb-target zones for starting races
Config.UseTarget = false

-- If true, show "Press E to interact" prompts instead of using qb-target
Config.UsePressE = true

-- Time Trial Races list
Config.Races = {
    {
        name = "Hectors Time Trial",
        notifyTitle = "Hector", -- Optional name shown in notifications

        -- Proximity taunts before the race
        proximityNotifies = {
            "Your ride looks slow, better step it up!",
            "Ready to lose? This car doesn't stand a chance.",
            "Get out of here with that shit!",
            "You wanna race that car? Creep back to the garage in that peice of shit and come back another time.",
            "That ride is a joke to the car scene!",
            "Your car choice is... interesting.",
            "Feel the speed or not in your case.",
            "This is a race car you aint got shit on me!",
            "Come on, prove me wrong!",
            "Race or walk. Your choice mate, even though your better off walking with that ride."
        },

        -- Spawned vehicle details
        vehicleModel = 'calico',
        vehicleSpawn = vector4(-1585.34, -1059.93, 13.02, 3.57),

        -- Race start and end locations
        startPoint = vector4(-1618.01, -972.74, 13.02, 319.04),
        endPoint = vector4(-1233.53, -81.94, 42.64, 62.36),

        -- Race parameters
        maxTime = 55.0, -- seconds
        cooldown = 10000, -- 10 seconds for testing use "cooldown = 20 * 60 * 1000"

        -- Wager tiers (difficulty scaling)
        wagers = {
            {
                amount = 2000,          -- buyin amount
                name = "Easy",          -- difficulty scale
                timeModifier = 0,       -- take X amount of seconds off maxTime
                payout = 4000,          -- payout amount
                paymentType = "cash",   -- patment type cash, bank or crypto
                rewardItem = { name = "tunerchip", amount = 1 }, -- item reward
				-- requiredItem = { name = "phone", amount = 1 }, -- item required to start race
                requiredRaces = 3       -- races to complete to get item reward
            },
            {
                amount = 4000,
                name = "Medium",
                timeModifier = 2,
                payout = 8000,
                paymentType = "cash",
                rewardItem = { name = "turbo", amount = 1 },
                requiredRaces = 4
            },
            {
                amount = 5,
                name = "Hard",
                timeModifier = 4,
                payout = 10,
                paymentType = "crypto",
                rewardItem = { name = "vipracepass", amount = 1 },
                requiredRaces = 5
            },
            {
                amount = 20,
                name = "Extreme",
                timeModifier = 8,
                payout = 40,
                paymentType = "crypto",
                rewardItem = { name = "tunerdrive", amount = 1 },
                requiredItem = { name = "vipracepass", amount = 1 },
                requiredRaces = 6
            }
        },

        -- Restrict race to vehicle classes (0 = Compacts)
        allowedClasses = { 0 },

        -- Vehicle modifications (optional)
        mods = {
            -- Wheel category (0-12):
            -- 0=Sport, 1=Muscle, 2=Lowrider, 3=SUV, 4=Offroad,
            -- 5=Tuner, 6=Bike, 7=High End, 8=Mod, 9=Open Wheel,
            -- 10=Street, 11=Track, 12=Benny's Originals
            wheelType = 11,

            -- Rim index: depends on wheelType, values typically 0–25+ depending on type
            rimIndex = 3,

            -- Suspension: 0=Stock, 1=Lowered, 2=Street, 3=Sport, 4=Competition
            suspension = 3,

            -- Livery index (0–n depending on vehicle model)
            livery = 5,

            -- Visual mods (0–n varies by car, avarage 10):
            spoiler = 5,
            hood = 5,
            skirts = 3,
            frontBumper = 6,
            rearBumper = 0,

            -- Colors (from helper.txt List):
            -- primaryColor/secondaryColor/pearlescent/wheelColor: 0–160
            primaryColor = 18,      -- e.g. 18 = Dark Green
            secondaryColor = 141,   -- e.g. 141 = Hot Pink
            pearlescent = 111,      -- e.g. 111 = Ultra Blue
            wheelColor = 10,        -- e.g. 10 = Black

            -- Window Tints:
            -- 0=None, 1=Pure Black, 2=Dark Smoke, 3=Light Smoke, 4=Stock, 5=Limo
            windowTint = 1,

            -- Plate types:
            -- 0=Blue/White, 1=Yellow/Black, 2=Yellow/Blue, 3=Blue/White 2,
            -- 4=Blue/White 3, 5=North Yankton, 6=SA Exempt, 7=Government,
            -- 8=Air Force, 9=SA Exempt 2, 10=Liberty City, 11=White Plate, 12=Black Plate
            plateIndex = 10,

            -- Neon light color (RGB): applies to all sides
            neon = {255, 0, 255}, -- Purple (neon must be enabled elsewhere)

            -- Headlights (Xenon colors):
            -- 0=White, 1=Blue, 2=Electric Blue, 3=Mint Green, 4=Lime Green,
            -- 5=Yellow, 6=Golden Shower, 7=Orange, 8=Red, 9=Pink,
            -- 10=Hot Pink, 11=Purple, 12=Blacklight
            headlights = 9,

            -- Performance Mods:
            -- 0=Stock, 1=Street, 2=Sport, 3=Race
            engine = 2,
            transmission = 2,
            brakes = 2,

            -- Turbo enabled
            turbo = true
        },

        -- Optional NPC and animation
        ped = {
            model = "s_m_y_xmech_02",
            coords = vector4(-1587.1, -1059.18, 13.02, 355.52),
            animationSet = {
                dict = "cellphone@",
                anims = {
                    "cellphone_call_listen_base"
                }
            }
        },

        -- qb-target settings
        target = {
            label = 'Hectors Time Trial',
            icon = 'fas fa-car',
            distance = 3.5
        }
    },
    {
        name = "Race 2",
        vehicleModel = 'banshee',
        vehicleSpawn = vector4(-657.68, -1708.96, 24.23, 205.07),
        startPoint = vector4(-678.67, -1642.11, 24.03, 43.26),
        endPoint = vector4(-1273.53, -191.62, 41.51, 37.99),
        maxTime = 65.0,
        cooldown = 20 * 60 * 1000,
        wagers = {
            { amount = 5000, name = "Easy", timeModifier = 0, payout = 10000, paymentType = "bank", rewardItem = { name = "lockpick", amount = 2 } },
            { amount = 10000, name = "Medium", timeModifier = 2, payout = 20000, paymentType = "cash", rewardItem = { name = "advancedlockpick", amount = 1 } },
            { amount = 20000, name = "Hard", timeModifier = 4, payout = 40000, paymentType = "bank", rewardItem = { name = "tunerchip", amount = 1 } },
            { amount = 40000, name = "Extreme", timeModifier = 8, payout = 80000, paymentType = "bank", rewardItem = { name = "nitrous", amount = 1 }, requiredItem = { name = "vipracepass", amount = 1 } }
        },
        allowedClasses = { 4 },
        mods = {
            wheelType = 6,
            suspension = 2,
            livery = 1,
            spoiler = 2,
            neon = {255, 0, 255},
            headlights = 7,
            engine = 2,
            transmission = 2,
            brakes = 2,
            turbo = true
        },
        target = {
            label = 'Time Trial 2',
            icon = 'fas fa-car',
            distance = 3.5
        }
    },
    {
        name = "Race 3",
        vehicleModel = 'sultan2',
        vehicleSpawn = vector4(-1417.09, -254.26, 46.38, 263.85),
        startPoint = vector4(-1540.21, -193.31, 54.72, 42.85),
        endPoint = vector4(-2218.28, 1062.57, 195.06, 49.84),
        maxTime = 60.0,
        cooldown = 20 * 60 * 1000,
        wagers = {
            { amount = 5000, name = "Easy", timeModifier = 0, payout = 10000, paymentType = "bank", rewardItem = { name = "lockpick", amount = 2 } },
            { amount = 10000, name = "Medium", timeModifier = 2, payout = 20000, paymentType = "cash", rewardItem = { name = "advancedlockpick", amount = 1 } },
            { amount = 20000, name = "Hard", timeModifier = 4, payout = 40000, paymentType = "bank", rewardItem = { name = "tunerchip", amount = 1 } },
            { amount = 40000, name = "Extreme", timeModifier = 8, payout = 80000, paymentType = "bank", rewardItem = { name = "nitrous", amount = 1 }, requiredItem = { name = "vipracepass", amount = 1 } }
        },
        allowedClasses = { 3 },
        mods = {
            wheelType = 7,
            suspension = 2,
            livery = 2,
            spoiler = 5,
            neon = {255, 0, 255},
            headlights = 7,
            engine = 2,
            transmission = 2,
            brakes = 2,
            turbo = true
        },
        target = {
            label = 'Time Trial 3',
            icon = 'fas fa-car',
            distance = 3.5
        }
    },
    {
        name = "Race 4",
        vehicleModel = 'vstr',
        vehicleSpawn = vector4(1714.76, 3784.69, 34.04, 307.34),
        startPoint = vector4(1630.17, 3758.9, 34.18, 130.08),
        endPoint = vector4(1673.0, 4820.01, 41.39, 7.35),
        maxTime = 65.0,
        cooldown = 20 * 60 * 1000,
        wagers = {
            { amount = 5000, name = "Easy", timeModifier = 0, payout = 10000, paymentType = "bank", rewardItem = { name = "lockpick", amount = 2 } },
            { amount = 10000, name = "Medium", timeModifier = 2, payout = 20000, paymentType = "cash", rewardItem = { name = "advancedlockpick", amount = 1 } },
            { amount = 20000, name = "Hard", timeModifier = 4, payout = 40000, paymentType = "bank", rewardItem = { name = "tunerchip", amount = 1 } },
            { amount = 40000, name = "Extreme", timeModifier = 8, payout = 80000, paymentType = "bank", rewardItem = { name = "nitrous", amount = 1 }, requiredItem = { name = "vipracepass", amount = 1 } }
        },
        allowedClasses = { 1 },
        mods = {
            wheelType = 0,
            suspension = 1,
            livery = 2,
            spoiler = 2,
            neon = {255, 0, 255},
            headlights = 7,
            engine = 2,
            transmission = 2,
            brakes = 2,
            turbo = true
        },
        target = {
            label = 'Time Trial 4',
            icon = 'fas fa-car',
            distance = 3.5
        }
    }
}