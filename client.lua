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

    local vehicleCoords = GetEntityCoords(vehicle)
    local distance = #(playerCoords - vehicleCoords)

    if distance <= 5.0 then
        if IsPedInAnyVehicle(playerPed, false) then
            uiOpen = true
            SetNuiFocus(true, true)
            SendNUIMessage({ action = 'open', raceIndex = raceIndex, wagers = race.wagers })
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
    if not IsPedInAnyVehicle(ped, false) then
        print("^1[printvehmods]^0 You must be in a vehicle!")
        return
    end

    local vehicle = GetVehiclePedIsIn(ped, false)
    SetVehicleModKit(vehicle, 0)

    local mods = {}
    for i = 0, 49 do
        local modIndex = GetVehicleMod(vehicle, i)
        if modIndex >= 0 then
            local label = GetModTextLabel(vehicle, i, modIndex)
            local name = GetLabelText(label)
            mods[i] = name ~= "NULL" and name or ("Mod " .. i .. " index " .. modIndex)
        end
    end

    local livery = GetVehicleLivery(vehicle)
    if livery >= 0 then
        mods.livery = livery
    end

    local colors = {GetVehicleColours(vehicle)}
    mods.primaryColor = colors[1]
    mods.secondaryColor = colors[2]
    local extraColors = {GetVehicleExtraColours(vehicle)}
    mods.pearlescent = extraColors[1]
    mods.wheelColor = extraColors[2]
    mods.windowTint = GetVehicleWindowTint(vehicle)
    mods.plateIndex = GetVehicleNumberPlateTextIndex(vehicle)
    mods.wheelType = GetVehicleWheelType(vehicle)

    print("^2--- VEHICLE MODS ---^0")
    for k, v in pairs(mods) do
        print(("%s: %s"):format(tostring(k), tostring(v)))
    end

    TriggerEvent('chat:addMessage', {
        args = { '^2[printvehmods]^0 Vehicle mods printed to F8 console.' },
        color = { 0, 255, 0 }
    })
end)