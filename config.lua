Config = {}

-- Time (in milliseconds) players have to reach the race start after interaction
-- Do not change unless you update the notification logic accordingly
Config.RaceStartTimeout = 60000

-- Interaction settings:
-- If true, use qb-target zones for starting races
Config.UseTarget = false

-- If true, show "Press E to interact" prompts instead of using qb-target
Config.UsePressE = true

-- Blacklisted vehicles (top 10 fastest per class based on top speed, fully upgraded where applicable)
Config.BlacklistedVehicles = {
    -- Compacts (Class 0)
    [0] = {
        "weevil",       -- Weevil (123.00 mph)
        "brioso2",      -- Brioso 300 (115.50 mph)
        "kanjo",        -- Kanjo (114.25 mph)
        "issi7",        -- Issi Classic (112.75 mph)
        "club",         -- Club (112.50 mph)
        "asbo",         -- Asbo (110.00 mph)
        "brioso",       -- Brioso R/A (108.25 mph)
        "panto",        -- Panto (107.50 mph)
        "dilettante",   -- Dilettante (106.50 mph)
        "issi2"         -- Issi (104.25 mph)
    },
    -- Sedans (Class 1)
    [1] = {
        "schafter4",    -- Schafter LWB (Armored) (123.50 mph)
        "schafter3",    -- Schafter V12 (123.25 mph)
        "tailgater2",   -- Tailgater S (122.00 mph)
        "glendale2",    -- Glendale Custom (119.50 mph)
        "warrener2",    -- Warrener HKR (118.75 mph)
        "cinquemila",   -- Cinquemila (117.50 mph)
        "deity",        -- Deity (117.25 mph)
        "stafford",     -- Stafford (116.00 mph)
        "primo2",       -- Primo Custom (115.75 mph)
        "tailgater"     -- Tailgater (115.25 mph)
    },
    -- SUVs (Class 2)
    [2] = {
        "astron",       -- Astron (119.00 mph)
        "baller7",      -- Baller ST (118.75 mph)
        "novak",        -- Novak (118.50 mph)
        "jubilee",      -- Jubilee (118.25 mph)
        "granger2",     -- Granger 3600LX (117.75 mph)
        "toros",        -- Toros (117.50 mph)
        "xls2",         -- XLS (Armored) (117.25 mph)
        "cavalcade2",   -- Cavalcade (116.75 mph)
        "rebla",        -- Rebla GTS (116.50 mph)
        "baller4"       -- Baller LE LWB (116.25 mph)
    },
    -- Coupes (Class 3)
    [3] = {
        "zion3",        -- Zion Classic (117.75 mph)
        "previon",      -- Previon (115.50 mph)
        "futo2",        -- Futo GTX (115.25 mph)
        "sultan",       -- Sultan (115.00 mph)
        "sentinel3",    -- Sentinel Classic (114.75 mph)
        "futo",         -- Futo (114.50 mph)
        "sultan2",      -- Sultan RS Classic (114.25 mph)
        "windsor2",     -- Windsor Drop (113.50 mph)
        "feltzer2",     -- Feltzer (112.75 mph)
        "windsor"       -- Windsor (112.50 mph)
    },
    -- Muscle (Class 4)
    [4] = {
        "dominator3",   -- Dominator ASP (131.00 mph)
        "impaler",      -- Impaler (130.25 mph)
        "sabregt2",     -- Sabre Turbo Custom (129.75 mph)
        "yosemite",     -- Yosemite (129.25 mph)
        "gauntlet5",    -- Gauntlet Classic Custom (127.50 mph)
        "dominator7",   -- Dominator GTX (126.75 mph)
        "dominator",    -- Dominator (126.50 mph)
        "dukes",        -- Dukes (126.25 mph)
        "blade",        -- Blade (125.75 mph)
        "faction"       -- Faction (125.50 mph)
    },
    -- Sports Classics (Class 5)
    [5] = {
        "toreador",     -- Toreador (135.25 mph)
        "italirsx",     -- Itali RSX (135.00 mph)
        "rapidgt3",     -- Rapid GT Classic (134.75 mph)
        "retinue2",     -- Retinue Mk II (134.50 mph)
        "cheetah2",     -- Cheetah Classic (134.25 mph)
        "gt500",        -- GT500 (134.00 mph)
        "torero",       -- Torero (133.75 mph)
        "casco",        -- Casco (133.50 mph)
        "coquette3",    -- Coquette BlackFin (133.25 mph)
        "stingergt"     -- Stinger GT (133.00 mph)
    },
    -- Sports (Class 6)
    [6] = {
        "pariah",       -- Pariah (136.00 mph)
        "italigto",     -- Itali GTO (135.50 mph)
        "jester4",      -- Jester RR (135.25 mph)
        "elegy2",       -- Elegy RH8 (134.75 mph)
        "neo",          -- Neo (134.50 mph)
        "sultan3",      -- Sultan RS (134.25 mph)
        "comet5",       -- Comet SR (134.00 mph)
        "calico",       -- Calico GTF (133.75 mph)
        "schlagen",     -- Schlagen GT (133.50 mph)
        "jugular"       -- Jugular (133.25 mph)
    },
    -- Super (Class 7)
    [7] = {
        "deveste",      -- Deveste Eight (140.50 mph)
        "adder",        -- Adder (140.25 mph)
        "krieger",      -- Krieger (140.00 mph)
        "emerus",       -- Emerus (139.75 mph)
        "thrax",        -- Thrax (139.50 mph)
        "zorrusso",     -- Zorrusso (139.25 mph)
        "taipan",       -- Taipan (139.00 mph)
        "tigon",        -- Tigon (138.75 mph)
        "entity2",      -- Entity XXR (138.50 mph)
        "tezeract"      -- Tezeract (138.25 mph)
    },
    -- Motorcycles (Class 8)
    [8] = {
        "hakuchou2",    -- Hakuchou Drag (157.50 mph)
        "shotaro",      -- Shotaro (155.25 mph)
        "vortex",       -- Vortex (154.75 mph)
        "bati2",        -- Bati 801RR (154.50 mph)
        "bati",         -- Bati 801 (154.25 mph)
        "defiler",      -- Defiler (154.00 mph)
        "hakuchou",     -- Hakuchou (153.75 mph)
        "carbonrs",     -- Carbon RS (153.50 mph)
        "double",       -- Double-T (153.25 mph)
        "akuma"         -- Akuma (153.00 mph)
    },
    -- Off-road (Class 9)
    [9] = {
        "brawler",      -- Brawler (117.75 mph)
        "kamacho",      -- Kamacho (116.75 mph)
        "riata",        -- Riata (116.50 mph)
        "sandking",     -- Sandking XL (116.25 mph)
        "sandking2",    -- Sandking SWB (116.00 mph)
        "trophytruck",  -- Trophy Truck (115.75 mph)
        "desertraid",   -- Desert Raid (115.50 mph)
        "bf400",        -- BF400 (115.25 mph)
        "rancherxl",    -- Rancher XL (115.00 mph)
        "rebel2"        -- Rebel (114.75 mph)
    },
    -- Industrial (Class 10)
    [10] = {
        "mixer2",       -- Mixer (108.50 mph)
        "mixer",        -- Mixer (108.25 mph)
        "rubble",       -- Rubble (108.00 mph)
        "tiptruck2",    -- Tipper (107.75 mph)
        "tiptruck",     -- Tipper (107.50 mph)
        "guardian",     -- Guardian (107.25 mph)
        "bulldozer"     -- Dozer (100.00 mph, limited data)
        -- Only 7 vehicles available in Industrial class
    },
    -- Utility (Class 11)
    [11] = {
        "tractor2",     -- Fieldmaster (95.00 mph)
        "tractor",      -- Tractor (90.00 mph)
        "utillitruck3", -- Utility Truck (89.75 mph)
        "utillitruck2", -- Utility Truck (Flatbed) (89.50 mph)
        "utillitruck",  -- Utility Truck (Large) (89.25 mph)
        "dune",         -- Dune Buggy (89.00 mph)
        "caddy3",       -- Caddy (Bunker) (88.75 mph)
        "caddy2",       -- Caddy (Civilian) (88.50 mph)
        "caddy",        -- Caddy (88.25 mph)
        "forklift"      -- Forklift (88.00 mph)
    },
    -- Vans (Class 12)
    [12] = {
        "speedo4",      -- Speedo Custom (115.25 mph)
        "bison",        -- Bison (114.75 mph)
        "rumpo3",       -- Rumpo Custom (114.50 mph)
        "burrito3",     -- Burrito (114.25 mph)
        "youga2",       -- Youga Classic (114.00 mph)
        "youga3",       -- Youga Classic 4x4 (113.75 mph)
        "rumpo",        -- Rumpo (113.50 mph)
        "burrito",      -- Burrito (113.25 mph)
        "youga",        -- Youga (113.00 mph)
        "pony"          -- Pony (112.75 mph)
    },
    -- Cycles (Class 13)
    [13] = {
        "bmx",          -- BMX (limited speed data, ~30 mph)
        "cruiser",      -- Cruiser (~30 mph)
        "scorcher",     -- Scorcher (~29 mph)
        "tribike",      -- Whippet Race Bike (~29 mph)
        "tribike2",     -- Endurex Race Bike (~29 mph)
        "tribike3",     -- Tri-Cycles Race Bike (~29 mph)
        "fixter"        -- Fixter (~28 mph)
        -- Only 7 vehicles available in Cycles class
    },
    -- Boats (Class 14)
    [14] = {
        "longfin",      -- Longfin (122.00 mph)
        "kurtz31",      -- Kurtz 31 Patrol Boat (115.50 mph)
        "weaponizeddinghy", -- Weaponized Dinghy (115.25 mph)
        "toro2",        -- Toro (115.00 mph)
        "toro",         -- Toro (114.75 mph)
        "speedo",       -- Speeder (114.50 mph)
        "jetmax",       -- Jetmax (114.25 mph)
        "squalo",       -- Squalo (114.00 mph)
        "suntrap",      -- Suntrap (113.75 mph)
        "tropic"        -- Tropic (113.50 mph)
    },
    -- Helicopters (Class 15)
    [15] = {
        "akula",        -- Akula (157.25 mph)
        "hunter",       -- FH-1 Hunter (156.75 mph)
        "annihilator2", -- Annihilator Stealth (156.50 mph)
        "sparrow",      -- Sparrow (156.25 mph)
        "seasparrow",   -- Sea Sparrow (156.00 mph)
        "havok",        -- Havok (155.75 mph)
        "supervolito2", -- SuperVolito Carbon (155.50 mph)
        "supervolito",  -- SuperVolito (155.25 mph)
        "swift2",       -- Swift Deluxe (155.00 mph)
        "swift"         -- Swift (154.75 mph)
    },
    -- Planes (Class 16)
    [16] = {
        "hydra",        -- Hydra (209.25 mph)
        "lazer",        -- P-996 LAZER (208.75 mph)
        "pyro",         -- Pyro (208.50 mph)
        "starling",     -- LF-22 Starling (208.25 mph)
        "molotok",      -- V-65 Molotok (208.00 mph)
        "nokota",       -- P-45 Nokota (207.75 mph)
        "seabreeze",    -- Seabreeze (207.50 mph)
        "rogue",        -- Rogue (207.25 mph)
        "strikeforce",  -- B-11 Strikeforce (207.00 mph)
        "howard"        -- Howard NX-25 (206.75 mph)
    },
    -- Service (Class 17)
    [17] = {
        "bus",          -- Bus (107.25 mph)
        "airbus",       -- Airport Bus (107.00 mph)
        "taxi",         -- Taxi (106.75 mph)
        "tourbus",      -- Tour Bus (106.50 mph)
        "trash2",       -- Trashmaster (106.25 mph)
        "trash",        -- Trashmaster (106.00 mph)
        "coach",        -- Coach (105.75 mph)
        "rentbus",      -- Rental Shuttle Bus (105.50 mph)
        "brickade",     -- Brickade (105.25 mph)
        "brickade2"     -- Brickade 6x6 (105.00 mph)
    },
    -- Emergency (Class 18)
    [18] = {
        "fbi",          -- FIB (118.75 mph)
        "fbi2",         -- FIB SUV (118.50 mph)
        "police3",      -- Police Interceptor (118.25 mph)
        "police2",      -- Police Cruiser (Stanier) (118.00 mph)
        "sheriff",      -- Sheriff Cruiser (117.75 mph)
        "sheriff2",     -- Sheriff SUV (117.50 mph)
        "police",       -- Police Cruiser (Buffalo) (117.25 mph)
        "pranger",      -- Park Ranger (117.00 mph)
        "police4",      -- Unmarked Cruiser (116.75 mph)
        "ambulance"     -- Ambulance (116.50 mph)
    },
    -- Military (Class 19)
    [19] = {
        "barracks",     -- Barracks (110.00 mph)
        "barracks3",    -- Barracks Semi (109.75 mph)
        "crusader",     -- Crusader (109.50 mph)
        "rhino",        -- Rhino Tank (90.00 mph, limited data)
        "barrage",      -- Barrage (89.75 mph)
        "chernobog",    -- Chernobog (89.50 mph)
        "khanjali",     -- TM-02 Khanjali (89.25 mph)
        "scarab",       -- Apocalypse Scarab (89.00 mph)
        "scarab2",      -- Future Shock Scarab (88.75 mph)
        "scarab3"       -- Nightmare Scarab (88.50 mph)
    },
    -- Commercial (Class 20)
    [20] = {
        "hauler",       -- Hauler (108.75 mph)
        "packer",       -- Packer (108.50 mph)
        "phantom",      -- Phantom (108.25 mph)
        "benson",       -- Benson (108.00 mph)
        "mule4",        -- Mule Custom (107.75 mph)
        "mule3",        -- Mule (107.50 mph)
        "mule",         -- Mule (107.25 mph)
        "pounder",      -- Pounder (107.00 mph)
        "stockade",     -- Stockade (106.75 mph)
        "flatbed"       -- Flatbed (106.50 mph)
    },
    -- Trains (Class 21)
    [21] = {
        "freight",      -- Freight Train (limited speed data)
        "freightcar",   -- Freight Car
        "freightcont1", -- Freight Container 1
        "freightcont2", -- Freight Container 2
        "freightgrain", -- Freight Grain Car
        "tankercar"     -- Tanker Car
        -- Only 6 vehicles available in Trains class
    }
}

-- -------------------------------------------------------------------------------- --                   
--                                                                                  --  
--         CONFIG RACES BELOW USE COMMANDS TO MAKE SCRIPT SUIT YOUR SERVER           -- 
--                                                                                  --  
-- -------------------------------------------------------------------------------- -- 
 
Config.Races = {
    {
        name = "Hectors Time Trial", -- blip name
        notifyTitle = "Hector", -- Optional name shown in notifications
        requiredVehicle = "kanjo", -- Specific vehicle required to enter this race
        interactionPoint = vector4(-1587.1, -1059.18, 13.02, 15.0), -- Interaction point with radius for "Press E"

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
        vehicleModel = 'kanjo',
        vehicleSpawn = vector4(-1585.34, -1059.93, 13.02, 3.57),

        -- Race start and end locations
        startPoint = vector4(-1618.01, -972.74, 13.02, 319.04),
        endPoint = vector4(-1233.53, -81.94, 42.64, 62.36),

        -- Race parameters
        maxTime = 65.0, -- seconds
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
                amount = 10,
                name = "Extreme",
                timeModifier = 8,
                payout = 20,
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
            rimIndex = 1,

            -- Suspension: 0=Stock, 1=Lowered, 2=Street, 3=Sport, 4=Competition
            suspension = 1,

            -- Livery index (0–n depending on vehicle model)
            livery = -1,

            -- Visual mods (0–n varies by car, avarage 10):
            spoiler = 0,
            hood = 5,
            skirts = 0,
            frontBumper = 0,
            rearBumper = 2,

            -- Colors (from helper.txt List):
            -- primaryColor/secondaryColor/pearlescent/wheelColor: 0–160
            primaryColor = 90,      -- e.g. 18 = Dark Green
            secondaryColor = 90,   -- e.g. 141 = Hot Pink
            pearlescent = 111,      -- e.g. 111 = Ultra Blue
            wheelColor = 119,        -- e.g. 10 = Black

            -- Window Tints:
            -- 0=None, 1=Pure Black, 2=Dark Smoke, 3=Light Smoke, 4=Stock, 5=Limo
            windowTint = 3,

            -- Plate types:
            -- 0=Blue/White, 1=Yellow/Black, 2=Yellow/Blue, 3=Blue/White 2,
            -- 4=Blue/White 3, 5=North Yankton, 6=SA Exempt, 7=Government,
            -- 8=Air Force, 9=SA Exempt 2, 10=Liberty City, 11=White Plate, 12=Black Plate
            plateIndex = 9,

            -- Neon light color (RGB): applies to all sides
            neon = {0, 75, 0}, -- Purple (neon must be enabled elsewhere)

            -- Headlights (Xenon colors):
            -- 0=White, 1=Blue, 2=Electric Blue, 3=Mint Green, 4=Lime Green,
            -- 5=Yellow, 6=Golden Shower, 7=Orange, 8=Red, 9=Pink,
            -- 10=Hot Pink, 11=Purple, 12=Blacklight
            headlights = 2,

            -- Performance Mods:
            -- 0=Stock, 1=Street, 2=Sport, 3=Race
            engine = 3,
            transmission = 2,
            brakes = 2,
            -- Turbo enabled
            turbo = 1        
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
        -- qb-target/ press "E" UI settings
        target = {
            label = 'Hectors Time Trial', -- ui/target name
            icon = 'fas fa-car', -- Target icon
            distance = 3.5 -- Target distance
        }
    },
    {
        name = "Race 2",
        notifyTitle = "Time Trial",
        requiredVehicle = "calico", -- Specific vehicle required to enter this race
        -- Added: Interaction point with radius for "Press E"
        interactionPoint = vector4(-657.68, -1708.96, 24.23, 14.5), -- x, y, z, radius
        -- Added: Proximity taunts before the race
        proximityNotifies = {
            "Think that Calico can keep up? Prove it!",
            "Time Trial 2 is ready. Got the skills?",
            "Your ride looks weak, show me it’s not!",
            "Calico, huh? Let’s see it burn rubber!",
            "This race isn’t for slowpokes. You in?",
            "Race 2 awaits. Don’t choke out there!",
            "That car better be fast, or you’re done!",
            "Time to shine or crash trying!",
            "Get ready to eat dust if you’re not quick!",
            "Show me what that Calico’s got!"
        },
        vehicleModel = 'calico',
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
            wheelType = 11,
            rimIndex = 3,
            suspension = 3,
            livery = 5,
            spoiler = 5,
            hood = 5,
            skirts = 3,
            frontBumper = 6,
            rearBumper = 0,
            primaryColor = 18,
            secondaryColor = 141,
            pearlescent = 111,
            wheelColor = 10,
            windowTint = 1,
            plateIndex = 10,
            neon = {255, 0, 255},
            headlights = 10,
            engine = 2,
            transmission = 2,
            brakes = 2,
            turbo = true
        },
        -- Added: Optional NPC and animation
        ped = {
            model = "a_m_y_stlat_01",
            coords = vector4(-658.68, -1707.96, 24.23, 205.07),
            animationSet = {
                dict = "amb@world_human_leaning@male@wall@back@mobile@idle_a",
                anims = {"idle_a", "idle_b", "idle_c"}
            }
        },
        target = {
            label = 'Time Trial 2',
            icon = 'fas fa-car',
            distance = 3.5
        }
    },
    {
        name = "Downtown Dash",
        notifyTitle = "Downtown Dash",
        requiredVehicle = "elegy2",
        interactionPoint = vector4(150.25, -1030.12, 29.34, 4.5),
        proximityNotifies = {
            "Think that Elegy can handle the city streets?",
            "Downtown Dash is ready. You got what it takes?",
            "Your ride better be tuned for these tight turns!",
            "City racing ain’t easy. Prove you’re up for it!",
            "Show me that Elegy’s got some real power!",
            "Ready to burn rubber through the skyscrapers?",
            "This race will test your skills. Don’t choke!",
            "Downtown’s waiting. Let’s see some speed!",
            "That car looks fast, but are you?",
            "Hit the streets or hit the bench!"
        },
        vehicleModel = "elegy2",
        vehicleSpawn = vector4(145.67, -1028.45, 29.34, 160.23),
        startPoint = vector4(130.12, -1020.78, 29.34, 160.23),
        endPoint = vector4(-150.45, -600.89, 33.12, 340.56),
        maxTime = 70.0,
        cooldown = 20 * 60 * 1000,
        wagers = {
            { amount = 5000, name = "Easy", timeModifier = 0, payout = 10000, paymentType = "cash", rewardItem = { name = "lockpick", amount = 2 }, requiredRaces = 3 },
            { amount = 10000, name = "Medium", timeModifier = 2, payout = 20000, paymentType = "bank", rewardItem = { name = "advancedlockpick", amount = 1 }, requiredRaces = 4 },
            { amount = 20000, name = "Hard", timeModifier = 4, payout = 40000, paymentType = "crypto", rewardItem = { name = "tunerchip", amount = 1 }, requiredRaces = 5 },
            { amount = 40000, name = "Extreme", timeModifier = 8, payout = 80000, paymentType = "crypto", rewardItem = { name = "nitrous", amount = 1 }, requiredItem = { name = "vipracepass", amount = 1 }, requiredRaces = 6 }
        },
        allowedClasses = { 6 },
        mods = {
            wheelType = 7,
            rimIndex = 2,
            suspension = 3,
            livery = 1,
            spoiler = 3,
            hood = 2,
            skirts = 1,
            frontBumper = 3,
            rearBumper = 2,
            primaryColor = 12,
            secondaryColor = 12,
            pearlescent = 111,
            wheelColor = 10,
            windowTint = 2,
            plateIndex = 4,
            neon = {255, 0, 255},
            headlights = 8,
            engine = 3,
            transmission = 2,
            brakes = 2,
            turbo = true
        },
        ped = {
            model = "a_m_y_business_01",
            coords = vector4(150.25, -1030.12, 29.34, 160.23),
            animationSet = {
                dict = "cellphone@",
                anims = {"cellphone_call_listen_base"}
            }
        },
        target = {
            label = "Downtown Dash",
            icon = "fas fa-car",
            distance = 3.5
        }
    }
}
