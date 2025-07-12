Config = {}

-- If true, players must use qb-target. If false, "Press E" should be true instead.
Config.UseTarget = false

-- Enables "Press E to interact" logic instead of qb-target.
Config.UsePressE = true

-- List of time trial races. Add as many as you want with the same structure.
Config.Races = {
    {
        -- Display name of the race (appears in blips and UI)
        name = "Hectors Time Trial",

        -- Model name of the vehicle to spawn (must be a valid GTA spawn name, e.g., 'calico')
        vehicleModel = 'calico',

        -- Where the vehicle spawns (vector4(x, y, z, heading))
        vehicleSpawn = vector4(-1585.34, -1059.93, 13.02, 3.57),

        -- Start position where the countdown begins
        startPoint = vector4(-1618.01, -972.74, 13.02, 319.04),

        -- End point for the race (must be within 10m to complete)
        endPoint = vector4(-1233.53, -81.94, 42.64, 62.36),

        -- Maximum allowed time (in seconds) to complete the race
        maxTime = 55.0,

        -- Cooldown before the player can retry (in milliseconds)
        -- Example: 25 minutes = 25 * 60 * 1000
        cooldown = 25 * 60 * 1000,
		
		-- The value below is how many seconds to subtract from the base maxTime for that wager. If a wager is not defined here, the base maxTime is used. This lets you make races harder for higher wagers.
		wagerTimeModifiers = {
            [5000] = 0,      -- no change for 5000 wager
            [10000] = 2,     -- subtract 2 seconds for 10000 wager
            [20000] = 4,     -- subtract 2 seconds for 20000 wager
            [40000] = 8      -- subtract 4 seconds for 40000 wager
        },
		
		-- Only allow specific classes
		allowedClasses = { 0 }, -- Allowed classes:
        -- 0: Compacts          ✅ (allowed)
        -- 1: Sedans
        -- 2: SUVs
        -- 3: Coupes
        -- 4: Muscle
        -- 5: Sports Classics
        -- 6: Sports      
        -- 7: Super       
        -- 8: Motorcycles
        -- 9: Off-road
        -- 10: Industrial
        -- 11: Utility
        -- 12: Vans
        -- 13: Cycles
        -- 14: Boats
        -- 15: Helicopters
        -- 16: Planes
        -- 17: Service
        -- 18: Emergency
        -- 19: Military
        -- 20: Commercial
        -- 21: Trains


        -- Optional vehicle customization/modification options
        mods = {
            -- RIM AND WHEEL SETTINGS
            wheelType = 11,      -- Wheel category (0-12). Examples:
                                -- 0=Sport, 5=Tuner, 11=Street, 12=Track
            rimIndex = 3,        -- Specific rim in the selected category (check helper.txt)

            -- SUSPENSION: 0 (stock) to 4 (lowest)
            suspension = 3,

            -- Livery index (varies per car model) - applies both SetVehicleLivery and mod 48
            livery = 5,

            -- Visual Mods (indexes vary per vehicle, usually 0-10):
            spoiler = 5,
            hood = 5,
            skirts = 3,
            frontBumper = 6,
            rearBumper = 0,

            -- COLOR SETTINGS
            primaryColor = 18,      -- Use values from (helper.txt) list
            secondaryColor = 141,   -- Use same list
            pearlescent = 111,      -- Use same list
            wheelColor = 10,        -- Use same list

            -- WINDOW TINTS
            -- 0=None, 1=Pure Black, 2=Dark Smoke, 3=Light Smoke, 4=Stock, 5=Limo
            windowTint = 1,

            -- Plate style index (0–12)
            -- 0=Blue/White, 1=Yellow/Black, etc.
            plateIndex = 10,

            -- NEON LIGHTS (RGB color)
            neon = {255, 0, 255},   -- Enable all 4 sides

            -- Headlight Xenon color
            -- 0=White, 1=Blue, ..., 12=Blacklight, 13–31 (custom)
            headlights = 9,

            -- PERFORMANCE MODS
            -- 0=Stock, 1=Level 1, 2=Level 2, 3=Max
            engine = 2,
            transmission = 2,
            brakes = 2,

            -- Turbo (true = on, false = off)
            turbo = true
        },

        -- OPTIONAL: A ped that appears near the car with an animation
        ped = {
            model = "s_m_y_xmech_02",     -- Ped model name
            coords = vector4(-1587.1, -1059.18, 13.02, 355.52), -- Spawn position
            animationSet = {
                dict = "cellphone@",
                anims = {
                    "cellphone_call_listen_base"
                    -- Add more animations here
                }
            }
        },

        -- Settings for qb-target or proximity interaction
        target = {
            label = 'Talk to hector',       -- Label for target
            icon = 'fas fa-car',          -- Icon (if using qb-target)
            distance = 3.5                -- Max interaction range (1.0 to ~5.0)
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
		wagerTimeModifiers = {
            [5000] = 0,      -- no change for 5000 wager
            [10000] = 2,     -- subtract 2 seconds 
            [20000] = 4,     
            [40000] = 8      
        },
		allowedClasses = { 4 },
        mods = {
            wheels = 6,
            suspension = 2,
            livery = 1,
            spoiler = 2,
			neon = {255, 0, 255},
			headlights = 7,
			engine = 2,           
            transmission = 2,     
			brakes = 2,            
            turbo = true,          
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
		wagerTimeModifiers = {
            [5000] = 0,      -- no change for 5000 wager
            [10000] = 2,     -- subtract 2 seconds 
            [20000] = 4,     
            [40000] = 8      
        },
		allowedClasses = { 3 },
        mods = {
            wheels = 7,
            suspension = 2,
            livery = 2,
            spoiler = 5,
			neon = {255, 0, 255},
			headlights = 7,
			engine = 2,           
            transmission = 2,      
			brakes = 2,             
            turbo = true,           
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
		wagerTimeModifiers = {
            [5000] = 0,      -- no change for 5000 wager
            [10000] = 2,     -- subtract 2 seconds 
            [20000] = 4,     
            [40000] = 8      
        },
		allowedClasses = { 1 },
        mods = {
            wheels = 0,
            suspension = 1,
            livery = 2,
            spoiler = 2,
			neon = {255, 0, 255},
			headlights = 7,
			engine = 2,            
            transmission = 2,      
			brakes = 2,            
            turbo = true,          
        },
        target = {
            label = 'Time Trial 4',
            icon = 'fas fa-car',
            distance = 3.5
        }
    }
}
