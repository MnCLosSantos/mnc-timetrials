local QBCore = exports['qb-core']:GetCoreObject()

local uiOpen = false
local cooldownActive = false
local cooldownEndTime = 0
local currentSelectedRace = 1
local isRaceOngoing = false
local selectedVehiclePlate = nil
local startFinishProps = {}
local lastNotifyTime = 0
local notifyCooldown = 25000 
local lastMessages = {}
local currentRaceCount = 0
local currentRequiredRaces = 0

local spawnedVehicles = {}
local vehiclesSpawned = false
local raceVehicleBlips = {}

local function CreateVehicleSpawnBlips()
    for i, race in ipairs(Config.Races) do
        if race.vehicleSpawn then
            local blip = AddBlipForCoord(race.vehicleSpawn.x, race.vehicleSpawn.y, race.vehicleSpawn.z)
            SetBlipSprite(blip, 611)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, 0.8)
            SetBlipColour(blip, 3)
            SetBlipAsShortRange(blip, true)

            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(race.name .. " ")
            EndTextCommandSetBlipName(blip)

            raceVehicleBlips[i] = blip
        end
    end
end

local function SpawnStartFinishProp(coords, heading)
    local model = "prop_start_finish_line_01"
    local hash = GetHashKey(model)
    RequestModel(hash)
    while not HasModelLoaded(hash) do Wait(10) end

    local obj = CreateObject(hash, coords.x, coords.y, coords.z - 1.0, true, false, false)
    SetEntityAsMissionEntity(obj, true, true)
    SetEntityHeading(obj, heading)
    FreezeEntityPosition(obj, true)

    local dict = "core"
    local fxName = "exp_grd_flare"
    RequestNamedPtfxAsset(dict)
    while not HasNamedPtfxAssetLoaded(dict) do Wait(10) end
    UseParticleFxAssetNextCall(dict)

    local leftFx = StartParticleFxLoopedOnEntity(fxName, obj, -8.2, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)
    UseParticleFxAssetNextCall(dict)
    local rightFx = StartParticleFxLoopedOnEntity(fxName, obj, 8.2, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false)

    return { object = obj, leftFx = leftFx, rightFx = rightFx }
end

local function RemoveStartFinishProp(propTable)
    if propTable.leftFx then StopParticleFxLooped(propTable.leftFx, false) end
    if propTable.rightFx then StopParticleFxLooped(propTable.rightFx, false) end
    if DoesEntityExist(propTable.object) then DeleteEntity(propTable.object) end
end

local function SpawnRaceMarkers(race)
    local startCoords = vector3(race.startPoint.x, race.startPoint.y, race.startPoint.z)
    local finishCoords = vector3(race.endPoint.x, race.endPoint.y, race.endPoint.z)
    local startHeading = 0.0
    local finishHeading = 0.0

    startFinishProps.start = SpawnStartFinishProp(startCoords, startHeading)
    startFinishProps.finish = SpawnStartFinishProp(finishCoords, finishHeading)
end

local function RemoveRaceMarkers()
    if startFinishProps.start then
        RemoveStartFinishProp(startFinishProps.start)
        startFinishProps.start = nil
    end
    if startFinishProps.finish then
        RemoveStartFinishProp(startFinishProps.finish)
        startFinishProps.finish = nil
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

        if mods then
            SetVehicleModKit(vehicle, 0)
            ToggleVehicleMod(vehicle, 22, true)

            if mods.headlights then
                SetVehicleXenonLightsColor(vehicle, mods.headlights)
            end

            if mods.wheelType and mods.rimIndex then
                SetVehicleWheelType(vehicle, mods.wheelType)
                SetVehicleMod(vehicle, 23, mods.rimIndex, false)
                SetVehicleMod(vehicle, 24, mods.rimIndex, false)
            end

            if mods.suspension and GetNumVehicleMods(vehicle, 15) > 0 then
                SetVehicleMod(vehicle, 15, mods.suspension, false)
            else
                print("Suspension not available for:", vehicleModel)
            end

            if mods.spoiler and GetNumVehicleMods(vehicle, 0) > 0 then
                SetVehicleMod(vehicle, 0, mods.spoiler, false)
            end

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
            end

            if mods.engine and GetNumVehicleMods(vehicle, 11) > 0 then
                SetVehicleMod(vehicle, 11, mods.engine, false)
            end

            if mods.transmission and GetNumVehicleMods(vehicle, 13) > 0 then
                SetVehicleMod(vehicle, 13, mods.transmission, false)
            end

            if mods.brakes and GetNumVehicleMods(vehicle, 12) > 0 then
                SetVehicleMod(vehicle, 12, mods.brakes, false)
            end

            if mods.turbo ~= nil then
                ToggleVehicleMod(vehicle, 18, mods.turbo)
            end

            if mods.primaryColor then
                SetVehicleColours(vehicle, mods.primaryColor, mods.secondaryColor or mods.primaryColor)
            end
            if mods.pearlescent or mods.wheelColor then
                SetVehicleExtraColours(vehicle, mods.pearlescent or 0, mods.wheelColor or 0)
            end

            if mods.windowTint then
                SetVehicleWindowTint(vehicle, mods.windowTint)
            end

            if mods.plateIndex then
                SetVehicleNumberPlateTextIndex(vehicle, mods.plateIndex)
            end

            if mods.hood and GetNumVehicleMods(vehicle, 7) > 0 then
                SetVehicleMod(vehicle, 7, mods.hood, false)
            end

            if mods.skirts and GetNumVehicleMods(vehicle, 3) > 0 then
                SetVehicleMod(vehicle, 3, mods.skirts, false)
            end

            if mods.frontBumper and GetNumVehicleMods(vehicle, 1) > 0 then
                SetVehicleMod(vehicle, 1, mods.frontBumper, false)
            end

            if mods.rearBumper and GetNumVehicleMods(vehicle, 2) > 0 then
                SetVehicleMod(vehicle, 2, mods.rearBumper, false)
            end

            if mods.neon then
                SetVehicleNeonLightEnabled(vehicle, 0, true)
                SetVehicleNeonLightEnabled(vehicle, 1, true)
                SetVehicleNeonLightEnabled(vehicle, 2, true)
                SetVehicleNeonLightEnabled(vehicle, 3, true)
                SetVehicleNeonLightsColour(vehicle, mods.neon[1], mods.neon[2], mods.neon[3])
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
                    AddTextComponentString("Press ~INPUT_CONTEXT~ to enter " .. targetConfig.label)
                    DisplayHelpTextFromStringLabel(0, 0, 1, -1)

                    if IsControlJustReleased(0, 38) then
                        if IsPedInAnyVehicle(playerPed, false) then
                            TriggerEvent('mnc-timetrials:client:openUIWithRace', raceIndex)
                        else
                            TriggerEvent('ox_lib:notify', {
                                title = 'Midnight Club',
                                description = 'You must be inside a vehicle to access the race UI.',
                                type = 'error',
                                duration = 5000
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

                local phoneModel = GetHashKey("prop_phone_ing")
                RequestModel(phoneModel)
                while not HasModelLoaded(phoneModel) do Wait(50) end
                local boneIndex = GetPedBoneIndex(ped, 28422)
                local phone = CreateObject(phoneModel, 1.0, 1.0, 1.0, true, true, false)
                local xOff, yOff, zOff = 0.02, 0.02, -0.02
                local xRot, yRot, zRot = 0.0, 0.0, 0.0
                AttachEntityToEntity(phone, ped, boneIndex, xOff, yOff, zOff, xRot, yRot, zRot, true, true, false, true, 1, true)

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

    CreateVehicleSpawnBlips()
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
            type = 'error',
            duration = 5000
        })
        return
    end

    -- Apply livery to the vehicle (mod type 48, livery index 2)
    if DoesEntityExist(vehicle) then
        local liveryCount = GetVehicleLiveryCount(vehicle)
        if liveryCount > 2 then
            SetVehicleMod(vehicle, 48, 2) -- Apply livery index 2
        end
    end

    local vehicleCoords = GetEntityCoords(vehicle)
    local distance = #(playerCoords - vehicleCoords)

    if distance <= 5.0 then
        if IsPedInAnyVehicle(playerPed, false) then
            uiOpen = true
            SetNuiFocus(true, true)
            SendNUIMessage({
                action = 'open',
                raceIndex = raceIndex,
                wagers = race.wagers,
                maxTime = race.maxTime,
                raceName = race.name
            })
            currentSelectedRace = raceIndex
        else
            TriggerEvent('ox_lib:notify', {
                title = 'Midnight Club',
                description = 'You must be inside a vehicle to access the race UI.',
                type = 'error',
                duration = 5000
            })
        end
    else
        TriggerEvent('ox_lib:notify', {
            title = 'Midnight Club',
            description = 'You are not close enough to the race vehicle.',
            type = 'error',
            duration = 5000
        })
    end
end)

RegisterNUICallback('close', function(_, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    uiOpen = false
    cb('ok')
end)

RegisterNetEvent('mnc-timetrials:client:setRaceCount', function(raceCount, requiredRaces)
    currentRaceCount = raceCount or 0 -- Ensure raceCount is 0 if nil
    currentRequiredRaces = requiredRaces or 5 -- Fallback to 5 if not specified
    print(('[mnc-timetrials:client:setRaceCount] Race count set to %d/%d for race %d'):format(currentRaceCount, currentRequiredRaces, currentSelectedRace))
end)

local function StartTimeTrial(wagerData, raceIndex)
    if cooldownActive then return end

    local race = Config.Races[raceIndex]
    local startTime = GetGameTimer()
    SetNewWaypoint(race.endPoint.x, race.endPoint.y)

    local timeModifier = wagerData.timeModifier or 0
    local adjustedMaxTime = race.maxTime - timeModifier
    if adjustedMaxTime < 0 then
        adjustedMaxTime = 0
    end

    local playerPed = PlayerPedId()
    local startCoords = GetEntityCoords(playerPed)
    local startVehicle = GetVehiclePedIsIn(playerPed, false)
    local startPlate = GetVehicleNumberPlateText(startVehicle)

    if not selectedVehiclePlate or startPlate ~= selectedVehiclePlate then
        TriggerEvent('ox_lib:notify', {
            title = 'Time Trial Cancelled',
            description = 'You switched vehicles after placing your wager. Race cancelled.',
            type = 'error',
            duration = 5000
        })
        isRaceOngoing = false
        cooldownActive = true
        cooldownEndTime = GetGameTimer() + race.cooldown
        RemoveRaceMarkers()
        return
    end

    -- Request race completion count from server
    TriggerServerEvent('mnc-timetrials:server:getRaceCount', raceIndex, wagerData.amount)

    for i = 10, 1, -1 do
        if i <= 1 then
            local currentCoords = GetEntityCoords(PlayerPedId())
            if #(currentCoords - startCoords) > 10.0 then
                TriggerEvent('ox_lib:notify', {
                    title = 'Jumped Start',
                    description = 'You moved too early, or were too far away so the Race has been canceled.',
                    type = 'error',
                    duration = 5000
                })
                isRaceOngoing = false
                RemoveRaceMarkers()
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
            Wait(1000) -- Check every second
            local coords = GetEntityCoords(PlayerPedId())
            local elapsedTime = (GetGameTimer() - startTime) / 1000

            -- Request race count update every second
            TriggerServerEvent('mnc-timetrials:server:getRaceCount', raceIndex, wagerData.amount)

            if elapsedTime > adjustedMaxTime then
                TriggerEvent('ox_lib:notify', {
                    title = 'Time Trial Failed',
                    description = ('You took too long! Time: %.2f seconds. Allowed: %.2f seconds'):format(elapsedTime, adjustedMaxTime),
                    type = 'error',
                    duration = 5000
                })
                RemoveRaceMarkers()
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
                        type = 'success',
                        duration = 5000
                    })
                    TriggerServerEvent('mnc-timetrials:server:payout', wagerData, raceIndex)
                else
                    TriggerEvent('ox_lib:notify', {
                        title = 'Time Trial Failed',
                        description = ('You finished in %.2f seconds — too slow!'):format(elapsedTime),
                        type = 'error',
                        duration = 5000
                    })
                end

                cooldownActive = true
                cooldownEndTime = GetGameTimer() + race.cooldown
                isRaceOngoing = false
                RemoveRaceMarkers()
                break
            end
        end
    end)
end

CreateThread(function()
    while true do
        Wait(10000)
        local playerPed = PlayerPedId()
        if IsPedInAnyVehicle(playerPed, false) then
            local playerCoords = GetEntityCoords(playerPed)

            for i, vehicle in pairs(spawnedVehicles) do
                if DoesEntityExist(vehicle) then
                    local vehicleCoords = GetEntityCoords(vehicle)
                    local dist = #(playerCoords - vehicleCoords)

                    print(("Proximity check: dist to race vehicle %d is %.2f"):format(i, dist))

                    if dist <= 10.0 then
                        local now = GetGameTimer()
                        if now - lastNotifyTime > notifyCooldown then
                            local race = Config.Races[i]
                            if race and race.proximityNotifies and #race.proximityNotifies > 0 then
                                lastMessages[i] = lastMessages[i] or {}

                                local function pickMessage()
                                    local tries = 0
                                    local msg
                                    repeat
                                        msg = race.proximityNotifies[math.random(#race.proximityNotifies)]
                                        tries = tries + 1
                                        if tries > 20 then break end
                                    until countOccurrences(lastMessages[i], msg) < 5
                                    return msg
                                end

                                function countOccurrences(tbl, val)
                                    local count = 0
                                    for _, v in ipairs(tbl) do
                                        if v == val then
                                            count = count + 1
                                        end
                                    end
                                    return count
                                end

                                local message = pickMessage()
                                local title = race.notifyTitle or "Midnight Club"

                                table.insert(lastMessages[i], message)
                                if #lastMessages[i] > 5 then
                                    table.remove(lastMessages[i], 1)
                                end

                                TriggerEvent('ox_lib:notify', {
                                    title = title,
                                    description = message,
                                    type = 'inform',
                                    position = 'top-right',
                                    duration = 15000
                                })

                                print("Notification sent: " .. message)

                                lastNotifyTime = now
                            end
                        end
                    end
                end
            end
        end
    end
end)

RegisterNUICallback('selectWager', function(data, cb)
    print(('[mnc-timetrials:client:selectWager] Received wager=%s, raceIndex=%s'):format(tostring(data.wager), tostring(data.raceIndex)))
    local wagerAmount = tonumber(data.wager)
    local raceIndex = tonumber(data.raceIndex) or 1
    local active, timeLeft = IsCooldownActive()
    if active then
        local minutes = math.floor(timeLeft / 60000)
        local seconds = math.floor((timeLeft % 60000) / 1000)
        TriggerEvent('ox_lib:notify', {
            title = 'Time Trial Cooldown',
            description = ('Wait %d:%02d before starting again.'):format(minutes, seconds),
            type = 'error',
            duration = 5000
        })
        cb('ok')
        return
    end

    if isRaceOngoing then
        TriggerEvent('ox_lib:notify', {
            title = 'Race In Progress',
            description = 'You already have a race in progress!',
            type = 'error',
            duration = 5000
        })
        cb('ok')
        return
    end

    isRaceOngoing = true

    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    selectedVehiclePlate = GetVehicleNumberPlateText(vehicle)

    if vehicle == 0 or not IsPedInAnyVehicle(playerPed, false) then
        TriggerEvent('ox_lib:notify', {
            title = 'Time Trial',
            description = 'You must be in a vehicle to start.',
            type = 'error',
            duration = 5000
        })
        isRaceOngoing = false
        cb('ok')
        return
    end

    local race = Config.Races[raceIndex]
    if not race then
        TriggerEvent('ox_lib:notify', {
            title = 'Time Trial',
            description = 'Invalid race selected.',
            type = 'error',
            duration = 5000
        })
        isRaceOngoing = false
        cb('ok')
        return
    end

    local wagerData = nil
    for _, wager in ipairs(race.wagers) do
        if wager.amount == wagerAmount then
            wagerData = wager
            break
        end
    end

    if not wagerData then
        TriggerEvent('ox_lib:notify', {
            title = 'Time Trial',
            description = 'Invalid wager amount selected.',
            type = 'error',
            duration = 5000
        })
        isRaceOngoing = false
        cb('ok')
        return
    end

    -- Check if a specific vehicle is required
    local vehicleModel = GetEntityModel(vehicle)
    local vehicleName = GetDisplayNameFromVehicleModel(vehicleModel):lower()
    if race.requiredVehicle and vehicleName ~= race.requiredVehicle:lower() then
        TriggerEvent('ox_lib:notify', {
            title = 'Time Trial',
            description = 'This race requires a specific vehicle: ' .. race.requiredVehicle,
            type = 'error',
            duration = 5000
        })
        isRaceOngoing = false
        cb('ok')
        return
    end

    -- Check if vehicle is blacklisted, but bypass if it matches requiredVehicle
    local isBlacklisted = false
    if not race.requiredVehicle or vehicleName ~= race.requiredVehicle:lower() then
        if Config.BlacklistedVehicles and race.allowedClasses then
            for _, class in ipairs(race.allowedClasses) do
                if Config.BlacklistedVehicles[class] then
                    for _, blacklistedVehicle in ipairs(Config.BlacklistedVehicles[class]) do
                        if vehicleName == blacklistedVehicle then
                            isBlacklisted = true
                            break
                        end
                    end
                end
                if isBlacklisted then break end
            end
        end
    end

    if isBlacklisted then
        TriggerEvent('ox_lib:notify', {
            title = 'Time Trial',
            description = 'This vehicle is blacklisted for this race due to its high performance.',
            type = 'error',
            duration = 5000
        })
        isRaceOngoing = false
        cb('ok')
        return
    end

    print(('[mnc-timetrials:client:selectWager] Sending wagerData for race %d: %s'):format(raceIndex, json.encode(wagerData)))

    local vehClass = GetVehicleClass(vehicle)
    local isAllowed = false
    if race.allowedClasses then
        for _, class in ipairs(race.allowedClasses) do
            if class == vehClass then
                isAllowed = true
                break
            end
        end
    end

    if not isAllowed then
        local classNames = {
            [0] = "Compacts", [1] = "Sedans", [2] = "SUVs", [3] = "Coupes",
            [4] = "Muscle", [5] = "Sports Classics", [6] = "Sports", [7] = "Super",
            [8] = "Motorcycles", [9] = "Off-road", [10] = "Industrial", [11] = "Utility",
            [12] = "Vans", [13] = "Cycles", [14] = "Boats", [15] = "Helicopters",
            [16] = "Planes", [17] = "Service", [18] = "Emergency", [19] = "Military",
            [20] = "Commercial", [21] = "Trains"
        }
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
            type = 'error',
            duration = 5000
        })

        isRaceOngoing = false
        cb('ok')
        return
    end

    currentSelectedRace = raceIndex
    TriggerServerEvent('mnc-timetrials:server:chargeWager', wagerData)
    SpawnRaceMarkers(race)
    cb('ok')
end)

RegisterNetEvent('mnc-timetrials:client:wagerAccepted', function(wagerData)
    local vehicle = GetVehiclePedIsIn(PlayerPedId(), false)
    if not vehicle or vehicle == 0 then
        TriggerEvent('ox_lib:notify', {
            title = 'Time Trial',
            description = 'You must be in a vehicle to start.',
            type = 'error',
            duration = 5000
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
        description = 'Drive to the start point within 1 minute to begin your race!',
        type = 'inform',
        duration = 5000
    })

    CreateThread(function()
        local waitStartTime = GetGameTimer()
        local raceStartVec = vector3(race.startPoint.x, race.startPoint.y, race.startPoint.z)

        while true do
            Wait(1000)

            if GetGameTimer() - waitStartTime > 60000 then
                TriggerEvent('ox_lib:notify', {
                    title = 'Race Cancelled',
                    description = 'You took too long to reach the start point.',
                    type = 'error',
                    duration = 5000
                })
                RemoveRaceMarkers()
                isRaceOngoing = false
                local waypointBlip = GetFirstBlipInfoId(8)
                if DoesBlipExist(waypointBlip) then
                    RemoveBlip(waypointBlip)
                end
                return
            end

            local coords = GetEntityCoords(PlayerPedId())
            if #(coords - raceStartVec) < 8.0 then
                StartTimeTrial(wagerData, currentSelectedRace)
                break
            end
        end
    end)
end)

RegisterNetEvent('mnc-timetrials:client:cancelRace', function()
    isRaceOngoing = false
    RemoveRaceMarkers()
    local waypointBlip = GetFirstBlipInfoId(8)
    if DoesBlipExist(waypointBlip) then
        RemoveBlip(waypointBlip)
    end
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
    uiOpen = false
    TriggerEvent('ox_lib:notify', {
        title = 'Race Cancelled',
        description = 'The race was cancelled due to insufficient funds or missing items.',
        type = 'error',
        duration = 5000
    })
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

RegisterCommand("printvehmods", function()
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped, false)
    if veh == 0 then
        print("You are not in a vehicle.")
        return
    end

    local function GetColorValue(index)
        return index or 0
    end

    local mods = {
        wheelType = GetVehicleWheelType(veh),
        rimIndex = GetVehicleMod(veh, 23),
        suspension = GetVehicleMod(veh, 15),
        livery = GetVehicleLivery(veh),
        spoiler = GetVehicleMod(veh, 0),
        hood = GetVehicleMod(veh, 7),
        skirts = GetVehicleMod(veh, 3),
        frontBumper = GetVehicleMod(veh, 1),
        rearBumper = GetVehicleMod(veh, 2),
    }

    -- Colors
    local primary, secondary = GetVehicleColours(veh)
    local pearlescent, wheelColor = GetVehicleExtraColours(veh)
    mods.primaryColor = GetColorValue(primary)
    mods.secondaryColor = GetColorValue(secondary)
    mods.pearlescent = GetColorValue(pearlescent)
    mods.wheelColor = GetColorValue(wheelColor)

    -- Other
    mods.windowTint = GetVehicleWindowTint(veh)
    mods.plateIndex = GetVehicleNumberPlateTextIndex(veh)

    -- Neon lights
    local r, g, b = GetVehicleNeonLightsColour(veh)
    mods.neon = {r, g, b}

    -- Headlights
    mods.headlights = GetVehicleHeadlightsColour(veh)

    -- Performance mods
    mods.engine = GetVehicleMod(veh, 11)
    mods.transmission = GetVehicleMod(veh, 13)
    mods.brakes = GetVehicleMod(veh, 12)
    mods.turbo = IsToggleModOn(veh, 18)

    -- Output: matching the format you gave with all comments
    print([[
        -- Vehicle modifications (optional)
        mods = {
            -- Wheel category (0-12):
            -- 0=Sport, 1=Muscle, 2=Lowrider, 3=SUV, 4=Offroad,
            -- 5=Tuner, 6=Bike, 7=High End, 8=Mod, 9=Open Wheel,
            -- 10=Street, 11=Track, 12=Benny's Originals
            wheelType = ]] .. mods.wheelType .. [[,

            -- Rim index: depends on wheelType, values typically 0–25+ depending on type
            rimIndex = ]] .. mods.rimIndex .. [[,

            -- Suspension: 0=Stock, 1=Lowered, 2=Street, 3=Sport, 4=Competition
            suspension = ]] .. mods.suspension .. [[,

            -- Livery index (0–n depending on vehicle model)
            livery = ]] .. mods.livery .. [[,

            -- Visual mods (0–n varies by car, avarage 10):
            spoiler = ]] .. mods.spoiler .. [[,
            hood = ]] .. mods.hood .. [[,
            skirts = ]] .. mods.skirts .. [[,
            frontBumper = ]] .. mods.frontBumper .. [[,
            rearBumper = ]] .. mods.rearBumper .. [[,

            -- Colors (from helper.txt List):
            -- primaryColor/secondaryColor/pearlescent/wheelColor: 0–160
            primaryColor = ]] .. mods.primaryColor .. [[,      -- e.g. 18 = Dark Green
            secondaryColor = ]] .. mods.secondaryColor .. [[,   -- e.g. 141 = Hot Pink
            pearlescent = ]] .. mods.pearlescent .. [[,      -- e.g. 111 = Ultra Blue
            wheelColor = ]] .. mods.wheelColor .. [[,        -- e.g. 10 = Black

            -- Window Tints:
            -- 0=None, 1=Pure Black, 2=Dark Smoke, 3=Light Smoke, 4=Stock, 5=Limo
            windowTint = ]] .. mods.windowTint .. [[,

            -- Plate types:
            -- 0=Blue/White, 1=Yellow/Black, 2=Yellow/Blue, 3=Blue/White 2,
            -- 4=Blue/White 3, 5=North Yankton, 6=SA Exempt, 7=Government,
            -- 8=Air Force, 9=SA Exempt 2, 10=Liberty City, 11=White Plate, 12=Black Plate
            plateIndex = ]] .. mods.plateIndex .. [[,

            -- Neon light color (RGB): applies to all sides
            neon = {]] .. mods.neon[1] .. [[, ]] .. mods.neon[2] .. [[, ]] .. mods.neon[3] .. [[}, -- Purple (neon must be enabled elsewhere)

            -- Headlights (Xenon colors):
            -- 0=White, 1=Blue, 2=Electric Blue, 3=Mint Green, 4=Lime Green,
            -- 5=Yellow, 6=Golden Shower, 7=Orange, 8=Red, 9=Pink,
            -- 10=Hot Pink, 11=Purple, 12=Blacklight
            headlights = ]] .. mods.headlights .. [[,

            -- Performance Mods:
            -- 0=Stock, 1=Street, 2=Sport, 3=Race
            engine = ]] .. mods.engine .. [[,
            transmission = ]] .. mods.transmission .. [[,
            brakes = ]] .. mods.brakes .. [[,

            -- Turbo enabled
            turbo = ]] .. tostring(mods.turbo) .. [[
        
		},
    ]])
end)

RegisterCommand("listfastestvehicles", function()
    local QBCore = exports['qb-core']:GetCoreObject()

    -- Speed data from provided Config.BlacklistedVehicles
    local vehicleSpeeds = {
        -- Compacts (Class 0)
        ["weevil"] = {speed = 123.00, name = "Weevil", class = 0},
        ["brioso2"] = {speed = 115.50, name = "Brioso 300", class = 0},
        ["kanjo"] = {speed = 114.25, name = "Kanjo SJ", class = 0},
        ["issi7"] = {speed = 112.75, name = "Issi Classic", class = 0},
        ["club"] = {speed = 112.50, name = "Club", class = 0},
        ["asbo"] = {speed = 110.00, name = "Asbo", class = 0},
        ["brioso"] = {speed = 108.25, name = "Brioso R/A", class = 0},
        ["panto"] = {speed = 107.50, name = "Panto", class = 0},
        ["dilettante"] = {speed = 106.50, name = "Dilettante", class = 0},
        ["issi2"] = {speed = 104.25, name = "Issi", class = 0},
        -- Sedans (Class 1)
        ["schafter4"] = {speed = 123.50, name = "Schafter LWB (Armored)", class = 1},
        ["schafter3"] = {speed = 123.25, name = "Schafter V12", class = 1},
        ["tailgater2"] = {speed = 122.00, name = "Tailgater S", class = 1},
        ["glendale2"] = {speed = 119.50, name = "Glendale Custom", class = 1},
        ["warrener2"] = {speed = 118.75, name = "Warrener HKR", class = 1},
        ["cinquemila"] = {speed = 117.50, name = "Cinquemila", class = 1},
        ["deity"] = {speed = 117.25, name = "Deity", class = 1},
        ["stafford"] = {speed = 116.00, name = "Stafford", class = 1},
        ["primo2"] = {speed = 115.75, name = "Primo Custom", class = 1},
        ["tailgater"] = {speed = 115.25, name = "Tailgater", class = 1},
        -- SUVs (Class 2)
        ["astron"] = {speed = 119.00, name = "Astron", class = 2},
        ["baller7"] = {speed = 118.75, name = "Baller ST", class = 2},
        ["novak"] = {speed = 118.50, name = "Novak", class = 2},
        ["jubilee"] = {speed = 118.25, name = "Jubilee", class = 2},
        ["granger2"] = {speed = 117.75, name = "Granger 3600LX", class = 2},
        ["toros"] = {speed = 117.50, name = "Toros", class = 2},
        ["xls2"] = {speed = 117.25, name = "XLS (Armored)", class = 2},
        ["cavalcade2"] = {speed = 116.75, name = "Cavalcade", class = 2},
        ["rebla"] = {speed = 116.50, name = "Rebla GTS", class = 2},
        ["baller4"] = {speed = 116.25, name = "Baller LE LWB", class = 2},
        -- Coupes (Class 3)
        ["zion3"] = {speed = 117.75, name = "Zion Classic", class = 3},
        ["previon"] = {speed = 115.50, name = "Previon", class = 3},
        ["futo2"] = {speed = 115.25, name = "Futo GTX", class = 3},
        ["sultan"] = {speed = 115.00, name = "Sultan", class = 3},
        ["sentinel3"] = {speed = 114.75, name = "Sentinel Classic", class = 3},
        ["futo"] = {speed = 114.50, name = "Futo", class = 3},
        ["sultan2"] = {speed = 114.25, name = "Sultan RS Classic", class = 3},
        ["windsor2"] = {speed = 113.50, name = "Windsor Drop", class = 3},
        ["feltzer2"] = {speed = 112.75, name = "Feltzer", class = 3},
        ["windsor"] = {speed = 112.50, name = "Windsor", class = 3},
        -- Muscle (Class 4)
        ["dominator3"] = {speed = 131.00, name = "Dominator ASP", class = 4},
        ["impaler"] = {speed = 130.25, name = "Impaler", class = 4},
        ["sabregt2"] = {speed = 129.75, name = "Sabre Turbo Custom", class = 4},
        ["yosemite"] = {speed = 129.25, name = "Yosemite", class = 4},
        ["gauntlet5"] = {speed = 127.50, name = "Gauntlet Classic Custom", class = 4},
        ["dominator7"] = {speed = 126.75, name = "Dominator GTX", class = 4},
        ["dominator"] = {speed = 126.50, name = "Dominator", class = 4},
        ["dukes"] = {speed = 126.25, name = "Dukes", class = 4},
        ["blade"] = {speed = 125.75, name = "Blade", class = 4},
        ["faction"] = {speed = 125.50, name = "Faction", class = 4},
        -- Sports Classics (Class 5)
        ["toreador"] = {speed = 135.25, name = "Toreador", class = 5},
        ["italirsx"] = {speed = 135.00, name = "Itali RSX", class = 5},
        ["rapidgt3"] = {speed = 134.75, name = "Rapid GT Classic", class = 5},
        ["retinue2"] = {speed = 134.50, name = "Retinue Mk II", class = 5},
        ["cheetah2"] = {speed = 134.25, name = "Cheetah Classic", class = 5},
        ["gt500"] = {speed = 134.00, name = "GT500", class = 5},
        ["torero"] = {speed = 133.75, name = "Torero", class = 5},
        ["casco"] = {speed = 133.50, name = "Casco", class = 5},
        ["coquette3"] = {speed = 133.25, name = "Coquette BlackFin", class = 5},
        ["stingergt"] = {speed = 133.00, name = "Stinger GT", class = 5},
        -- Sports (Class 6)
        ["pariah"] = {speed = 136.00, name = "Pariah", class = 6},
        ["italigto"] = {speed = 135.50, name = "Itali GTO", class = 6},
        ["jester4"] = {speed = 135.25, name = "Jester RR", class = 6},
        ["elegy2"] = {speed = 134.75, name = "Elegy RH8", class = 6},
        ["neo"] = {speed = 134.50, name = "Neo", class = 6},
        ["sultan3"] = {speed = 134.25, name = "Sultan RS", class = 6},
        ["comet5"] = {speed = 134.00, name = "Comet SR", class = 6},
        ["calico"] = {speed = 133.75, name = "Calico GTF", class = 6},
        ["schlagen"] = {speed = 133.50, name = "Schlagen GT", class = 6},
        ["jugular"] = {speed = 133.25, name = "Jugular", class = 6},
        -- Super (Class 7)
        ["deveste"] = {speed = 140.50, name = "Deveste Eight", class = 7},
        ["adder"] = {speed = 140.25, name = "Adder", class = 7},
        ["krieger"] = {speed = 140.00, name = "Krieger", class = 7},
        ["emerus"] = {speed = 139.75, name = "Emerus", class = 7},
        ["thrax"] = {speed = 139.50, name = "Thrax", class = 7},
        ["zorrusso"] = {speed = 139.25, name = "Zorrusso", class = 7},
        ["taipan"] = {speed = 139.00, name = "Taipan", class = 7},
        ["tigon"] = {speed = 138.75, name = "Tigon", class = 7},
        ["entity2"] = {speed = 138.50, name = "Entity XXR", class = 7},
        ["tezeract"] = {speed = 138.25, name = "Tezeract", class = 7},
        -- Motorcycles (Class 8)
        ["hakuchou2"] = {speed = 157.50, name = "Hakuchou Drag", class = 8},
        ["shotaro"] = {speed = 155.25, name = "Shotaro", class = 8},
        ["vortex"] = {speed = 154.75, name = "Vortex", class = 8},
        ["bati2"] = {speed = 154.50, name = "Bati 801RR", class = 8},
        ["bati"] = {speed = 154.25, name = "Bati 801", class = 8},
        ["defiler"] = {speed = 154.00, name = "Defiler", class = 8},
        ["hakuchou"] = {speed = 153.75, name = "Hakuchou", class = 8},
        ["carbonrs"] = {speed = 153.50, name = "Carbon RS", class = 8},
        ["double"] = {speed = 153.25, name = "Double-T", class = 8},
        ["akuma"] = {speed = 153.00, name = "Akuma", class = 8},
        -- Off-road (Class 9)
        ["brawler"] = {speed = 117.75, name = "Brawler", class = 9},
        ["kamacho"] = {speed = 116.75, name = "Kamacho", class = 9},
        ["riata"] = {speed = 116.50, name = "Riata", class = 9},
        ["sandking"] = {speed = 116.25, name = "Sandking XL", class = 9},
        ["sandking2"] = {speed = 116.00, name = "Sandking SWB", class = 9},
        ["trophytruck"] = {speed = 115.75, name = "Trophy Truck", class = 9},
        ["desertraid"] = {speed = 115.50, name = "Desert Raid", class = 9},
        ["bf400"] = {speed = 115.25, name = "BF400", class = 9},
        ["rancherxl"] = {speed = 115.00, name = "Rancher XL", class = 9},
        ["rebel2"] = {speed = 114.75, name = "Rebel", class = 9},
        -- Industrial (Class 10)
        ["mixer2"] = {speed = 108.50, name = "Mixer", class = 10},
        ["mixer"] = {speed = 108.25, name = "Mixer", class = 10},
        ["rubble"] = {speed = 108.00, name = "Rubble", class = 10},
        ["tiptruck2"] = {speed = 107.75, name = "Tipper", class = 10},
        ["tiptruck"] = {speed = 107.50, name = "Tipper", class = 10},
        ["guardian"] = {speed = 107.25, name = "Guardian", class = 10},
        ["bulldozer"] = {speed = 100.00, name = "Dozer", class = 10},
        -- Utility (Class 11)
        ["tractor2"] = {speed = 95.00, name = "Fieldmaster", class = 11},
        ["tractor"] = {speed = 90.00, name = "Tractor", class = 11},
        ["utillitruck3"] = {speed = 89.75, name = "Utility Truck", class = 11},
        ["utillitruck2"] = {speed = 89.50, name = "Utility Truck (Flatbed)", class = 11},
        ["utillitruck"] = {speed = 89.25, name = "Utility Truck (Large)", class = 11},
        ["dune"] = {speed = 89.00, name = "Dune Buggy", class = 11},
        ["caddy3"] = {speed = 88.75, name = "Caddy (Bunker)", class = 11},
        ["caddy2"] = {speed = 88.50, name = "Caddy (Civilian)", class = 11},
        ["caddy"] = {speed = 88.25, name = "Caddy", class = 11},
        ["forklift"] = {speed = 88.00, name = "Forklift", class = 11},
        -- Vans (Class 12)
        ["speedo4"] = {speed = 115.25, name = "Speedo Custom", class = 12},
        ["bison"] = {speed = 114.75, name = "Bison", class = 12},
        ["rumpo3"] = {speed = 114.50, name = "Rumpo Custom", class = 12},
        ["burrito3"] = {speed = 114.25, name = "Burrito", class = 12},
        ["youga2"] = {speed = 114.00, name = "Youga Classic", class = 12},
        ["youga3"] = {speed = 113.75, name = "Youga Classic 4x4", class = 12},
        ["rumpo"] = {speed = 113.50, name = "Rumpo", class = 12},
        ["burrito"] = {speed = 113.25, name = "Burrito", class = 12},
        ["youga"] = {speed = 113.00, name = "Youga", class = 12},
        ["pony"] = {speed = 112.75, name = "Pony", class = 12},
        -- Cycles (Class 13)
        ["bmx"] = {speed = 30.00, name = "BMX", class = 13},
        ["cruiser"] = {speed = 30.00, name = "Cruiser", class = 13},
        ["scorcher"] = {speed = 29.00, name = "Scorcher", class = 13},
        ["tribike"] = {speed = 29.00, name = "Whippet Race Bike", class = 13},
        ["tribike2"] = {speed = 29.00, name = "Endurex Race Bike", class = 13},
        ["tribike3"] = {speed = 29.00, name = "Tri-Cycles Race Bike", class = 13},
        ["fixter"] = {speed = 28.00, name = "Fixter", class = 13},
        -- Boats (Class 14)
        ["longfin"] = {speed = 122.00, name = "Longfin", class = 14},
        ["kurtz31"] = {speed = 115.50, name = "Kurtz 31 Patrol Boat", class = 14},
        ["weaponizeddinghy"] = {speed = 115.25, name = "Weaponized Dinghy", class = 14},
        ["toro2"] = {speed = 115.00, name = "Toro", class = 14},
        ["toro"] = {speed = 114.75, name = "Toro", class = 14},
        ["speedo"] = {speed = 114.50, name = "Speeder", class = 14},
        ["jetmax"] = {speed = 114.25, name = "Jetmax", class = 14},
        ["squalo"] = {speed = 114.00, name = "Squalo", class = 14},
        ["suntrap"] = {speed = 113.75, name = "Suntrap", class = 14},
        ["tropic"] = {speed = 113.50, name = "Tropic", class = 14},
        -- Helicopters (Class 15)
        ["akula"] = {speed = 157.25, name = "Akula", class = 15},
        ["hunter"] = {speed = 156.75, name = "FH-1 Hunter", class = 15},
        ["annihilator2"] = {speed = 156.50, name = "Annihilator Stealth", class = 15},
        ["sparrow"] = {speed = 156.25, name = "Sparrow", class = 15},
        ["seasparrow"] = {speed = 156.00, name = "Sea Sparrow", class = 15},
        ["havok"] = {speed = 155.75, name = "Havok", class = 15},
        ["supervolito2"] = {speed = 155.50, name = "SuperVolito Carbon", class = 15},
        ["supervolito"] = {speed = 155.25, name = "SuperVolito", class = 15},
        ["swift2"] = {speed = 155.00, name = "Swift Deluxe", class = 15},
        ["swift"] = {speed = 154.75, name = "Swift", class = 15},
        -- Planes (Class 16)
        ["hydra"] = {speed = 209.25, name = "Hydra", class = 16},
        ["lazer"] = {speed = 208.75, name = "P-996 LAZER", class = 16},
        ["pyro"] = {speed = 208.50, name = "Pyro", class = 16},
        ["starling"] = {speed = 208.25, name = "LF-22 Starling", class = 16},
        ["molotok"] = {speed = 208.00, name = "V-65 Molotok", class = 16},
        ["nokota"] = {speed = 207.75, name = "P-45 Nokota", class = 16},
        ["seabreeze"] = {speed = 207.50, name = "Seabreeze", class = 16},
        ["rogue"] = {speed = 207.25, name = "Rogue", class = 16},
        ["strikeforce"] = {speed = 207.00, name = "B-11 Strikeforce", class = 16},
        ["howard"] = {speed = 206.75, name = "Howard NX-25", class = 16},
        -- Service (Class 17)
        ["bus"] = {speed = 107.25, name = "Bus", class = 17},
        ["airbus"] = {speed = 107.00, name = "Airport Bus", class = 17},
        ["taxi"] = {speed = 106.75, name = "Taxi", class = 17},
        ["tourbus"] = {speed = 106.50, name = "Tour Bus", class = 17},
        ["trash2"] = {speed = 106.25, name = "Trashmaster", class = 17},
        ["trash"] = {speed = 106.00, name = "Trashmaster", class = 17},
        ["coach"] = {speed = 105.75, name = "Coach", class = 17},
        ["rentbus"] = {speed = 105.50, name = "Rental Shuttle Bus", class = 17},
        ["brickade"] = {speed = 105.25, name = "Brickade", class = 17},
        ["brickade2"] = {speed = 105.00, name = "Brickade 6x6", class = 17},
        -- Emergency (Class 18)
        ["fbi"] = {speed = 118.75, name = "FIB", class = 18},
        ["fbi2"] = {speed = 118.50, name = "FIB SUV", class = 18},
        ["police3"] = {speed = 118.25, name = "Police Interceptor", class = 18},
        ["police2"] = {speed = 118.00, name = "Police Cruiser (Stanier)", class = 18},
        ["sheriff"] = {speed = 117.75, name = "Sheriff Cruiser", class = 18},
        ["sheriff2"] = {speed = 117.50, name = "Sheriff SUV", class = 18},
        ["police"] = {speed = 117.25, name = "Police Cruiser (Buffalo)", class = 18},
        ["pranger"] = {speed = 117.00, name = "Park Ranger", class = 18},
        ["police4"] = {speed = 116.75, name = "Unmarked Cruiser", class = 18},
        ["ambulance"] = {speed = 116.50, name = "Ambulance", class = 18},
        -- Military (Class 19)
        ["barracks"] = {speed = 110.00, name = "Barracks", class = 19},
        ["barracks3"] = {speed = 109.75, name = "Barracks Semi", class = 19},
        ["crusader"] = {speed = 109.50, name = "Crusader", class = 19},
        ["rhino"] = {speed = 90.00, name = "Rhino Tank", class = 19},
        ["barrage"] = {speed = 89.75, name = "Barrage", class = 19},
        ["chernobog"] = {speed = 89.50, name = "Chernobog", class = 19},
        ["khanjali"] = {speed = 89.25, name = "TM-02 Khanjali", class = 19},
        ["scarab"] = {speed = 89.00, name = "Apocalypse Scarab", class = 19},
        ["scarab2"] = {speed = 88.75, name = "Future Shock Scarab", class = 19},
        ["scarab3"] = {speed = 88.50, name = "Nightmare Scarab", class = 19},
        -- Commercial (Class 20)
        ["hauler"] = {speed = 108.75, name = "Hauler", class = 20},
        ["packer"] = {speed = 108.50, name = "Packer", class = 20},
        ["phantom"] = {speed = 108.25, name = "Phantom", class = 20},
        ["benson"] = {speed = 108.00, name = "Benson", class = 20},
        ["mule4"] = {speed = 107.75, name = "Mule Custom", class = 20},
        ["mule3"] = {speed = 107.50, name = "Mule", class = 20},
        ["mule"] = {speed = 107.25, name = "Mule", class = 20},
        ["pounder"] = {speed = 107.00, name = "Pounder", class = 20},
        ["stockade"] = {speed = 106.75, name = "Stockade", class = 20},
        ["flatbed"] = {speed = 106.50, name = "Flatbed", class = 20},
        -- Trains (Class 21)
        ["freight"] = {speed = 0.00, name = "Freight Train", class = 21},
        ["freightcar"] = {speed = 0.00, name = "Freight Car", class = 21},
        ["freightcont1"] = {speed = 0.00, name = "Freight Container 1", class = 21},
        ["freightcont2"] = {speed = 0.00, name = "Freight Container 2", class = 21},
        ["freightgrain"] = {speed = 0.00, name = "Freight Grain Car", class = 21},
        ["tankercar"] = {speed = 0.00, name = "Tanker Car", class = 21}
    }

    -- Category to class mapping
    local categoryToClass = {
        ["compacts"] = 0,
        ["sedans"] = 1,
        ["suvs"] = 2,
        ["coupes"] = 3,
        ["muscle"] = 4,
        ["sportsclassics"] = 5,
        ["sports"] = 6,
        ["super"] = 7,
        ["motorcycles"] = 8,
        ["offroad"] = 9,
        ["industrial"] = 10,
        ["utility"] = 11,
        ["vans"] = 12,
        ["cycles"] = 13,
        ["boats"] = 14,
        ["helicopters"] = 15,
        ["planes"] = 16,
        ["service"] = 17,
        ["emergency"] = 18,
        ["military"] = 19,
        ["commercial"] = 20,
        ["trains"] = 21
    }

    -- Class names for output
    local classNames = {
        [0] = "Compacts",
        [1] = "Sedans",
        [2] = "SUVs",
        [3] = "Coupes",
        [4] = "Muscle",
        [5] = "Sports Classics",
        [6] = "Sports",
        [7] = "Super",
        [8] = "Motorcycles",
        [9] = "Off-road",
        [10] = "Industrial",
        [11] = "Utility",
        [12] = "Vans",
        [13] = "Cycles",
        [14] = "Boats",
        [15] = "Helicopters",
        [16] = "Planes",
        [17] = "Service",
        [18] = "Emergency",
        [19] = "Military",
        [20] = "Commercial",
        [21] = "Trains"
    }

    -- Collect vehicles by class
    local vehiclesByClass = {}
    for i = 0, 21 do
        vehiclesByClass[i] = {}
    end

    -- Try to access QBShared.Vehicles
    local QBShared = QBCore.Shared or {}
    local vehicles = QBShared.Vehicles

    if vehicles then
        for model, data in pairs(vehicles) do
            local category = data.category and data.category:lower() or "unknown"
            local class = categoryToClass[category]
            if class then
                local speedData = vehicleSpeeds[model] or {speed = 100.00, name = data.name}
                table.insert(vehiclesByClass[class], {
                    model = model,
                    name = data.name, -- Use name from vehicles.lua
                    speed = speedData.speed
                })
            end
        end
    else
        -- Fallback: Use vehicleSpeeds data if QBShared.Vehicles is unavailable
        TriggerEvent('chat:addMessage', {
            args = { '^1[listfastestvehicles]^0 Warning: QBShared.Vehicles not found. Using fallback data.' },
            color = { 255, 0, 0 }
        })
        for model, data in pairs(vehicleSpeeds) do
            local class = data.class
            table.insert(vehiclesByClass[class], {
                model = model,
                name = data.name,
                speed = data.speed
            })
        end
    end

    -- Sort and format output
    local output = "-- Blacklisted vehicles (top 10 fastest per class based on top speed, fully upgraded where applicable)\n"
    output = output .. "Config.BlacklistedVehicles = {\n"

    for class = 0, 21 do
        -- Sort vehicles by speed (descending)
        table.sort(vehiclesByClass[class], function(a, b) return a.speed > b.speed end)

        -- Get top 10 (or all if fewer)
        local topVehicles = {}
        for i = 1, math.min(10, #vehiclesByClass[class]) do
            topVehicles[i] = vehiclesByClass[class][i]
        end

        -- Format class section
        output = output .. string.format("    -- %s (Class %d)\n", classNames[class], class)
        output = output .. string.format("    [%d] = {\n", class)
        for i, veh in ipairs(topVehicles) do
            local speedStr = (class == 13 or class == 21) and "limited speed data" or string.format("%.2f mph", veh.speed)
            output = output .. string.format("        \"%s\",%s-- %s (%s)\n", veh.model, string.rep(" ", 15 - #veh.model), veh.name, speedStr)
        end
        if #topVehicles < 10 and (class == 10 or class == 13 or class == 21) then
            output = output .. string.format("        -- Only %d vehicles available in %s class\n", #topVehicles, classNames[class])
        end
        output = output .. "    },\n"
    end

    output = output .. "}\n"

    -- Print to console
    print(output)

    -- Notify user
    TriggerEvent('chat:addMessage', {
        args = { '^2[listfastestvehicles]^0 Top 10 fastest vehicles per class printed to F8 console.' },
        color = { 0, 255, 0 }
    })
end)