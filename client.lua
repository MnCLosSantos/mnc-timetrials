local QBCore = exports['qb-core']:GetCoreObject()

local uiOpen = false
local cooldownActive = false
local cooldownEndTime = 0
local currentSelectedRace = 1
local isRaceOngoing = false

local spawnedVehicles = {}
local vehiclesSpawned = false
local raceVehicleBlips = {}

local function CreateVehicleSpawnBlips()
    for i, race in ipairs(Config.Races) do
        if race.vehicleSpawn then
            local blip = AddBlipForCoord(race.vehicleSpawn.x, race.vehicleSpawn.y, race.vehicleSpawn.z)
            SetBlipSprite(blip, 611) -- Race flag icon, you can choose another if you want
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 3) -- Green color (change if you want)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(race.name .. " ")
            EndTextCommandSetBlipName(blip)

            raceVehicleBlips[i] = blip
        end
    end
end


local function IsCooldownActive()
    if not cooldownActive then return false end
    local timeLeft = cooldownEndTime - GetGameTimer()
    if timeLeft <= 0 then
        cooldownActive = false
        return false
    end
    return true, timeLeft
end

local function SpawnRaceVehicle(vehicleModel, coords, mods)
    local model = GetHashKey(vehicleModel)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(100) end

    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, true, false)
    if DoesEntityExist(vehicle) then
	    		
        -- Vehicle state	
        SetModelAsNoLongerNeeded(model)
        SetEntityAsMissionEntity(vehicle, true, true)
		SetVehicleLights(vehicle, 2)
        SetVehicleEngineOn(vehicle, true, true, true)
        SetVehicleFuelLevel(vehicle, 100.0)
        SetVehicleDirtLevel(vehicle, 0)
        SetVehicleUndriveable(vehicle, false)
        SetVehicleDoorsLocked(vehicle, 1)
        SetVehicleNeedsToBeHotwired(vehicle, false)
        SetVehicleHasBeenOwnedByPlayer(vehicle, false)

        -- Apply Mods
        if mods then
            SetVehicleModKit(vehicle, 0)
            -- Enable xenon headlights
			
        ToggleVehicleMod(vehicle, 22, true)

        if mods.headlights then
        SetVehicleXenonLightsColor(vehicle, mods.headlights)
        end
           
-- Wheels
if mods.wheelType and mods.rimIndex then
    SetVehicleWheelType(vehicle, mods.wheelType)
    SetVehicleMod(vehicle, 23, mods.rimIndex, false) -- Front wheels
    SetVehicleMod(vehicle, 24, mods.rimIndex, false) -- Rear wheels (mostly for bikes)
end


            -- Suspension
            if mods.suspension and GetNumVehicleMods(vehicle, 15) > 0 then
                SetVehicleMod(vehicle, 15, mods.suspension, false)
            else
                print("Suspension not available for:", vehicleModel)
            end

            -- Spoiler
            if mods.spoiler and GetNumVehicleMods(vehicle, 0) > 0 then
                SetVehicleMod(vehicle, 0, mods.spoiler, false)
            end

            -- Livery (dual method)
            if mods.livery then
                local liveryMods = GetNumVehicleMods(vehicle, 48)
                local standardLiveries = GetVehicleLiveryCount(vehicle)

                print("Vehicle:", vehicleModel, " | Mod 48 Liveries:", liveryMods, "| Standard Liveries:", standardLiveries)

                if liveryMods > 0 then
                    SetVehicleMod(vehicle, 48, mods.livery, false)
                    print("Applied livery via SetVehicleMod(48, "..mods.livery..")")
                end

                if standardLiveries > 0 then
                    SetVehicleLivery(vehicle, mods.livery)
                    print("Applied livery via SetVehicleLivery("..mods.livery..")")
                end
				
				-- Engine upgrade (mod type 11)
if mods.engine and GetNumVehicleMods(vehicle, 11) > 0 then
    SetVehicleMod(vehicle, 11, mods.engine, false)
end

-- Transmission upgrade (mod type 13)
if mods.transmission and GetNumVehicleMods(vehicle, 13) > 0 then
    SetVehicleMod(vehicle, 13, mods.transmission, false)
end

-- Turbo (mod toggle 18)
if mods.turbo ~= nil then
    ToggleVehicleMod(vehicle, 18, mods.turbo)
end

-- Brakes (mod type 12)
if mods.brakes and GetNumVehicleMods(vehicle, 12) > 0 then
    SetVehicleMod(vehicle, 12, mods.brakes, false)
end

-- Set Colors
if mods.primaryColor then
    SetVehicleColours(vehicle, mods.primaryColor, mods.secondaryColor or mods.primaryColor)
end
if mods.pearlescent or mods.wheelColor then
    SetVehicleExtraColours(vehicle, mods.pearlescent or 0, mods.wheelColor or 0)
end

-- Window Tint
if mods.windowTint then
    SetVehicleWindowTint(vehicle, mods.windowTint)
end

-- Plates
if mods.plateIndex then
    SetVehicleNumberPlateTextIndex(vehicle, mods.plateIndex)
end

-- Hood
if mods.hood and GetNumVehicleMods(vehicle, 7) > 0 then
    SetVehicleMod(vehicle, 7, mods.hood, false)
end

-- Skirts
if mods.skirts and GetNumVehicleMods(vehicle, 3) > 0 then
    SetVehicleMod(vehicle, 3, mods.skirts, false)
end

-- Front Bumper
if mods.frontBumper and GetNumVehicleMods(vehicle, 1) > 0 then
    SetVehicleMod(vehicle, 1, mods.frontBumper, false)
end

-- Rear Bumper
if mods.rearBumper and GetNumVehicleMods(vehicle, 2) > 0 then
    SetVehicleMod(vehicle, 2, mods.rearBumper, false)
end

				
				-- Neon Lights
                if mods.neon then
                    SetVehicleNeonLightEnabled(vehicle, 0, true)
                    SetVehicleNeonLightEnabled(vehicle, 1, true)
                    SetVehicleNeonLightEnabled(vehicle, 2, true)
                    SetVehicleNeonLightEnabled(vehicle, 3, true)
                    SetVehicleNeonLightsColour(vehicle, mods.neon[1], mods.neon[2], mods.neon[3])
                end
            end
        end

        return vehicle
    end

    return nil
end

local function HandlePressEInteraction(vehicle, targetConfig, raceIndex)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if uiOpen then
                Citizen.Wait(500)
            else
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local vehicleCoords = GetEntityCoords(vehicle)
                local dist = #(playerCoords - vehicleCoords)

                if dist <= 5.0 then
                    SetTextComponentFormat("STRING")
                    AddTextComponentString("Press ~INPUT_CONTEXT~ to open " .. targetConfig.label)
                    DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                    if IsControlJustReleased(0, 38) then
                        if IsPedInAnyVehicle(playerPed, false) then
                            TriggerEvent('mnc-timetrials:client:openUIWithRace', raceIndex)
                        else
                            TriggerEvent('ox_lib:notify', {
                                title = 'Midnight Club',
                                description = 'You must be inside a vehicle to access the race UI.',
                                type = 'error'
                            })
                        end
                    end
                else
                    Citizen.Wait(500)
                end
            end
        end
    end)
end

RegisterNetEvent('mnc-timetrials:client:spawnVehicles', function()
    if vehiclesSpawned then return end
    vehiclesSpawned = true

    for i, race in ipairs(Config.Races) do
        local vehicle = SpawnRaceVehicle(race.vehicleModel, race.vehicleSpawn, race.mods)
        if vehicle then
            spawnedVehicles[i] = vehicle

-- Spawn ped if configured
if race.ped then
    local modelHash = GetHashKey(race.ped.model)
    RequestModel(modelHash)
    while not HasModelLoaded(modelHash) do Wait(50) end

    local ped = CreatePed(4, modelHash, race.ped.coords.x, race.ped.coords.y, race.ped.coords.z - 1.0, race.ped.coords.w, false, true)
    SetEntityAsMissionEntity(ped, true, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    SetPedFleeAttributes(ped, 0, false)
    SetPedDiesWhenInjured(ped, false)
    FreezeEntityPosition(ped, true)

    -- Phone prop setup
    local phoneModel = GetHashKey("prop_phone_ing")
    RequestModel(phoneModel)
    while not HasModelLoaded(phoneModel) do Wait(50) end
    local boneIndex = GetPedBoneIndex(ped, 28422) -- Right hand bone
    local phone = CreateObject(phoneModel, 1.0, 1.0, 1.0, true, true, false)
    -- Adjust offsets here to position the phone nicely in hand:
    local xOff, yOff, zOff = 0.02, 0.02, -0.02
    local xRot, yRot, zRot = 0.0, 0.0, 0.0

    AttachEntityToEntity(phone, ped, boneIndex, xOff, yOff, zOff, xRot, yRot, zRot, true, true, false, true, 1, true)

    -- Play random animation from config
    local animSet = race.ped.animationSet
    if animSet and animSet.dict and animSet.anims and #animSet.anims > 0 then
        RequestAnimDict(animSet.dict)
        while not HasAnimDictLoaded(animSet.dict) do Wait(50) end

        local anim = animSet.anims[math.random(1, #animSet.anims)]
        TaskPlayAnim(ped, animSet.dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
    end
end



            if Config.UsePressE then
                HandlePressEInteraction(vehicle, race.target, i)
            elseif Config.UseTarget then
                exports['qb-target']:AddTargetEntity(vehicle, {
                    options = {
                        {
                            event = 'mnc-timetrials:client:openUIWithRace',
                            icon = race.target.icon,
                            label = race.target.label,
                            raceIndex = i
                        }
                    },
                    distance = race.target.distance
                })
            end
        end
    end

    CreateVehicleSpawnBlips() -- Make sure this line is here!
end)


CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(100) end
    if NetworkIsHost() then
        TriggerEvent('mnc-timetrials:client:spawnVehicles')
    end
end)

RegisterNetEvent('mnc-timetrials:client:openUIWithRace', function(raceIndex)
    if uiOpen then return end
    local race = Config.Races[raceIndex]
    if not race then return end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local vehicle = spawnedVehicles[raceIndex]

    if not vehicle or not DoesEntityExist(vehicle) then
        TriggerEvent('ox_lib:notify', {
            title = 'Midnight Club',
            description = 'Race vehicle not available.',
            type = 'error'
        })
        return
    end

    local vehicleCoords = GetEntityCoords(vehicle)
    local distance = #(playerCoords - vehicleCoords)

    if distance <= 5.0 then
        if IsPedInAnyVehicle(playerPed, false) then
            uiOpen = true
            SetNuiFocus(true, true)
            SendNUIMessage({ action = 'open', raceIndex = raceIndex })
            currentSelectedRace = raceIndex
        else
            TriggerEvent('ox_lib:notify', {
                title = 'Midnight Club',
                description = 'You must be inside a vehicle to access the race UI.',
                type = 'error'
            })
        end
    else
        TriggerEvent('ox_lib:notify', {
            title = 'Midnight Club',
            description = 'You are not close enough to the race vehicle.',
            type = 'error'
        })
    end
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    uiOpen = false
    cb('ok')
end)

local function StartTimeTrial(wager, raceIndex)
    if cooldownActive then return end

    local race = Config.Races[raceIndex]
    local startTime = GetGameTimer()
    SetNewWaypoint(race.endPoint.x, race.endPoint.y)

    -- Get time modifier for wager
    local timeModifier = 0
    if race.wagerTimeModifiers and race.wagerTimeModifiers[wager] then
        timeModifier = race.wagerTimeModifiers[wager]
    end

    -- Calculate adjusted max time
    local adjustedMaxTime = race.maxTime - timeModifier
    if adjustedMaxTime < 0 then
        adjustedMaxTime = 0 -- prevent negative maxTime
    end

    local playerPed = PlayerPedId()
    local startCoords = GetEntityCoords(playerPed)

    for i = 10, 1, -1 do
        if i <= 1 then
            local currentCoords = GetEntityCoords(PlayerPedId())
            if #(currentCoords - startCoords) > 10.0 then
                TriggerEvent('ox_lib:notify', {
                    title = 'Jumped Start',
                    description = 'You moved too early, or were too far away so the Race has been canceled.',
                    type = 'error'
                })
				isRaceOngoing = false
                return
            end
        end

        TriggerEvent('ox_lib:notify', {
            title = 'Time Trial',
            description = tostring(i),
            type = 'inform',
            position = 'center-right'
        })

        PlaySoundFrontend(-1, "3_2_1", "HUD_MINI_GAME_SOUNDSET", true)
        Wait(1000)
    end

    TriggerEvent('ox_lib:notify', {
        title = 'Time Trial',
        description = 'GO!',
        type = 'success',
        position = 'center-right'
    })

    StartAudioScene("FBI_HEIST_H5_MUTE_AMBIENCE_SCENE")
    PlaySoundFrontend(-1, "TIMER_STOP", "HUD_MINI_GAME_SOUNDSET", true)

    CreateThread(function()
        while true do
            Wait(500)
            local coords = GetEntityCoords(PlayerPedId())
            local elapsedTime = (GetGameTimer() - startTime) / 1000

            if elapsedTime > adjustedMaxTime then
                TriggerEvent('ox_lib:notify', {
                    title = 'Time Trial Failed',
                    description = ('You took too long! Time: %.2f seconds. Allowed: %.2f seconds'):format(elapsedTime, adjustedMaxTime),
                    type = 'error'
                })
                cooldownActive = true
                cooldownEndTime = GetGameTimer() + race.cooldown
				isRaceOngoing = false
                break
            end

            if #(coords - vector3(race.endPoint.x, race.endPoint.y, race.endPoint.z)) < 10.0 then
                if elapsedTime <= adjustedMaxTime then
                    TriggerEvent('ox_lib:notify', {
                        title = 'Time Trial Complete',
                        description = ('You beat the time in %.2f seconds!'):format(elapsedTime),
                        type = 'success'
                    })
                    TriggerServerEvent('mnc-timetrials:server:payout', wager * 2)
                else
                    TriggerEvent('ox_lib:notify', {
                        title = 'Time Trial Failed',
                        description = ('You finished in %.2f seconds — too slow!'):format(elapsedTime),
                        type = 'error'
                    })
                end

                cooldownActive = true
                cooldownEndTime = GetGameTimer() + race.cooldown
				isRaceOngoing = false
                break
            end
        end
    end)
end


RegisterNUICallback('selectWager', function(data, cb)
    local wager = tonumber(data.wager)
    local raceIndex = tonumber(data.raceIndex) or 1

    local active, timeLeft = IsCooldownActive()
    if active then
        local minutes = math.floor(timeLeft / 60000)
        local seconds = math.floor((timeLeft % 60000) / 1000)
        TriggerEvent('ox_lib:notify', {
            title = 'Time Trial Cooldown',
            description = ('Wait %d:%02d before starting again.'):format(minutes, seconds),
            type = 'error'
        })
        cb('ok')
        return
    end

if isRaceOngoing then
    TriggerEvent('ox_lib:notify', {
        title = 'Race In Progress',
        description = 'You already have a race in progress!',
        type = 'error'
    })
    return -- prevent starting another race
end

isRaceOngoing = true


    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    if vehicle == 0 or not IsPedInAnyVehicle(playerPed, false) then
        TriggerEvent('ox_lib:notify', {
            title = 'Time Trial',
            description = 'You must be in a vehicle to start.',
            type = 'error'
        })
        cb('ok')
        return
    end

    local race = Config.Races[raceIndex]
    if race.allowedClasses then
        local vehClass = GetVehicleClass(vehicle)

        local classNames = {
            [0] = "Compacts", [1] = "Sedans", [2] = "SUVs", [3] = "Coupes",
            [4] = "Muscle", [5] = "Sports Classics", [6] = "Sports", [7] = "Super",
            [8] = "Motorcycles", [9] = "Off-road", [10] = "Industrial", [11] = "Utility",
            [12] = "Vans", [13] = "Cycles", [14] = "Boats", [15] = "Helicopters",
            [16] = "Planes", [17] = "Service", [18] = "Emergency", [19] = "Military",
            [20] = "Commercial", [21] = "Trains"
        }

        local isAllowed = false
        for _, class in ipairs(race.allowedClasses) do
            if class == vehClass then
                isAllowed = true
                break
            end
        end

        if not isAllowed then
            local allowedStr = ""
            for _, class in ipairs(race.allowedClasses) do
                allowedStr = allowedStr .. string.format("[%d] %s, ", class, classNames[class] or "Unknown")
            end
            allowedStr = allowedStr:sub(1, -3)

            TriggerEvent('ox_lib:notify', {
                title = 'Time Trial',
                description = ('Your vehicle is class [%d] %s. Required: %s'):format(
                    vehClass,
                    classNames[vehClass] or "Unknown",
                    allowedStr
                ),
                type = 'error'
            })

            isRaceOngoing = false
            cb('ok')
            return
        end
    end

    currentSelectedRace = raceIndex
    TriggerServerEvent('mnc-timetrials:server:chargeWager', wager)
    cb('ok')
end)


RegisterNetEvent('mnc-timetrials:client:wagerAccepted', function(wager)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not vehicle or vehicle == 0 then
        TriggerEvent('ox_lib:notify', {
            title = 'Time Trial',
            description = 'You must be in a vehicle to start.',
            type = 'error'
        })
        return
    end

    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    uiOpen = false

    local race = Config.Races[currentSelectedRace]
    if not race then return end

    SetNewWaypoint(race.startPoint.x, race.startPoint.y)
    TriggerEvent('ox_lib:notify', {
        title = 'Wager Placed',
        description = 'Drive to the start point to begin your race!',
        type = 'inform'
    })

    CreateThread(function()
        while true do
            Wait(1000)
            local coords = GetEntityCoords(PlayerPedId())
            if #(coords - vector3(race.startPoint.x, race.startPoint.y, race.startPoint.z)) < 8.0 then
                StartTimeTrial(wager, currentSelectedRace)
                break
            end
        end
    end)
end)

RegisterCommand("listallwheels", function()
    local ped = PlayerPedId()
    if not IsPedInAnyVehicle(ped, false) then
        print("^1[listallwheels]^0 You must be in a vehicle!")
        return
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    SetVehicleModKit(vehicle, 0)

    local wheelTypeLabels = {
        [0] = "Sport",
        [1] = "Muscle",
        [2] = "Lowrider",
        [3] = "SUV",
        [4] = "Offroad",
        [5] = "Tuner",
        [6] = "Bike",
        [7] = "High End",
        [8] = "Benny's Originals",
        [9] = "Benny's Bespoke",
        [10] = "Open Wheel",
        [11] = "Street",
        [12] = "Track"
    }

    print("^2--- ALL WHEEL TYPES AND RIMS ---^0")
    for wheelType = 0, 12 do
        SetVehicleWheelType(vehicle, wheelType)
        local totalRims = GetNumVehicleMods(vehicle, 23)

        print(("^3[%d] %s^0 → %d rims"):format(wheelType, wheelTypeLabels[wheelType] or "Unknown", totalRims))

        for i = 0, totalRims - 1 do
            local label = GetModTextLabel(vehicle, 23, i)
            local name = GetLabelText(label)
            print(("   [%02d] %s"):format(i, name))
        end
    end

    TriggerEvent('chat:addMessage', {
        args = { '^2[listallwheels]^0 All rim names printed to F8 console.' },
        color = { 0, 255, 0 }
    })
end)


