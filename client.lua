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
local raceVehicleBlips = {}

-- UI variables
local raceUITimeStart = 0
local raceUIMaxTime = 0
local raceUIName = ""
local raceUIActive = false
local aiProgress = 0
local uiPosX = 0.02
local uiPosY = 0.08

-- Simple 2D text drawing function
local function DrawText2D(x, y, text, scale, r, g, b, a)
    SetTextFont(1)
    SetTextProportional(true)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextOutline()
    BeginTextCommandDisplayText("STRING")
    AddTextComponentSubstringPlayerName(text)
    EndTextCommandDisplayText(x, y)
end

-- UI rendering thread with pulsing color text and movable UI
local function DrawRaceUI()
    CreateThread(function()
        while raceUIActive do
            Wait(0)
            local currentTime = (GetGameTimer() - raceUITimeStart) / 1000
            local playerPed = PlayerPedId()
            local playerCoords = GetEntityCoords(playerPed)
            local race = Config.Races[currentSelectedRace]
            local endCoords = vector3(race.endPoint.x, race.endPoint.y, race.endPoint.z)
            local playerDistance = #(playerCoords - endCoords)
            
            local aiTimeRatio = currentTime / raceUIMaxTime
            local aiDistance = aiTimeRatio * playerDistance
            local gap = playerDistance - aiDistance
            local gapStr = gap >= 0 and string.format("+%.2f m", gap) or string.format("%.2f m", gap)
            local position = gap >= 0 and "1st" or "2nd"
            
            local time = GetGameTimer() / 1000
            local pulse = math.abs(math.sin(time * 2))
            local colors = {
                {255, 105, 180},
                {148, 0, 211},
                {0, 0, 255},
                {0, 255, 255}
            }
            local colorIndex = math.floor((pulse * #colors) % #colors) + 1
            local nextColorIndex = colorIndex % #colors + 1
            local lerp = (pulse * #colors) % 1
            local r = math.floor(colors[colorIndex][1] + (colors[nextColorIndex][1] - colors[colorIndex][1]) * lerp)
            local g = math.floor(colors[colorIndex][2] + (colors[nextColorIndex][2] - colors[colorIndex][2]) * lerp)
            local b = math.floor(colors[colorIndex][3] + (colors[nextColorIndex][3] - colors[colorIndex][3]) * lerp)
            
            DrawText2D(uiPosX, uiPosY, "Race: " .. raceUIName, 0.6, r, g, b, 255)
            DrawText2D(uiPosX, uiPosY + 0.10, string.format("Time to Beat: %.3f s", raceUIMaxTime), 0.6, r, g, b, 255)
            DrawText2D(uiPosX, uiPosY + 0.20, "Position: " .. position, 0.6, r, g, b, 255)
            DrawText2D(uiPosX, uiPosY + 0.25, "Gap: " .. gapStr, 0.6, r, g, b, 255)
            DrawText2D(uiPosX, uiPosY + 0.30, string.format("Current Time: %.3f s", currentTime), 0.6, r, g, b, 255)

            if IsControlPressed(0, 21) then
                if IsControlJustPressed(0, 27) then
                    uiPosY = math.max(0.0, uiPosY - 0.01)
                elseif IsControlJustPressed(0, 173) then
                    uiPosY = math.min(1.0, uiPosY + 0.01)
                elseif IsControlJustPressed(0, 174) then
                    uiPosX = math.max(0.0, uiPosX - 0.01)
                elseif IsControlJustPressed(0, 175) then
                    uiPosX = math.min(1.0, uiPosX + 0.01)
                end
            end
        end
    end)
end

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

local function HandlePressEInteraction(race, raceIndex)
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            if uiOpen then
                Citizen.Wait(500)
            else
                local playerPed = PlayerPedId()
                local playerCoords = GetEntityCoords(playerPed)
                local interactionCoords = vector3(race.interactionPoint.x, race.interactionPoint.y, race.interactionPoint.z)
                local radius = race.interactionPoint.w
                local dist = #(playerCoords - interactionCoords)

                if dist <= radius then
                    SetTextComponentFormat("STRING")
                    AddTextComponentString("Press ~INPUT_CONTEXT~ to enter " .. race.target.label)
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
    for i, race in ipairs(Config.Races) do
        if Config.UsePressE then
            HandlePressEInteraction(race, i)
        elseif Config.UseTarget then
            exports['qb-target']:AddCircleZone('raceInteraction' .. i, vector3(race.interactionPoint.x, race.interactionPoint.y, race.interactionPoint.z), race.interactionPoint.w, {
                name = 'raceInteraction' .. i,
                debugPoly = false,
                useZ = true,
            }, {
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

    CreateVehicleSpawnBlips()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        RemoveRaceMarkers()
        for i = 1, #Config.Races do
            if Config.UseTarget then
                exports['qb-target']:RemoveZone('raceInteraction' .. i)
            end
        end
        for _, blip in pairs(raceVehicleBlips) do
            if DoesBlipExist(blip) then
                RemoveBlip(blip)
            end
        end
        raceVehicleBlips = {}
    end
end)

CreateThread(function()
    while not NetworkIsSessionStarted() do Wait(100) end
    TriggerEvent('mnc-timetrials:client:spawnVehicles')
end)

RegisterNetEvent('mnc-timetrials:client:openUIWithRace', function(raceIndex)
    if uiOpen then return end
    local race = Config.Races[raceIndex]
    if not race then return end

    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    local interactionCoords = vector3(race.interactionPoint.x, race.interactionPoint.y, race.interactionPoint.z)
    local radius = race.interactionPoint.w
    local distance = #(playerCoords - interactionCoords)

    print(('[mnc-timetrials:client:openUIWithRace] Distance to race %d interaction point: %.2f (radius: %.2f)'):format(raceIndex, distance, radius))

    if distance <= radius then
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
            description = 'You are not close enough to the race interaction point.',
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
    currentRaceCount = raceCount or 0
    currentRequiredRaces = requiredRaces or 5
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

    raceUITimeStart = GetGameTimer()
    raceUIMaxTime = adjustedMaxTime
    raceUIName = race.name
    raceUIActive = true
    aiProgress = 0
    DrawRaceUI()

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
            Wait(1000)
            local coords = GetEntityCoords(PlayerPedId())
            local elapsedTime = (GetGameTimer() - startTime) / 1000

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
                raceUIActive = false
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
                raceUIActive = false
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

            for i, race in ipairs(Config.Races) do
                local interactionCoords = vector3(race.interactionPoint.x, race.interactionPoint.y, race.interactionPoint.z)
                local radius = race.interactionPoint.w
                local dist = #(playerCoords - interactionCoords)

                print(('[mnc-timetrials:client:proximityCheck] Distance to race %d interaction point: %.2f (radius: %.2f)'):format(i, dist, radius))

                if dist <= radius then
                    local now = GetGameTimer()
                    if now - lastNotifyTime > notifyCooldown then
                        if race.proximityNotifies and #race.proximityNotifies > 0 then
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
                raceUIActive = false
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
    raceUIActive = false
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