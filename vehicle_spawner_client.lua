-- Table to track phone props locally per race
local phoneProps = {}

RegisterNetEvent('mnc-timetrials:client:configureRaceEntities', function(vehicleNetId, pedNetId, raceIndex)
    local race = Config.Races[raceIndex]
    if not race then
        TriggerEvent('ox_lib:notify', {
            title = 'Time Trial',
            description = 'Invalid race configuration.',
            type = 'error',
            duration = 5000
        })
        return
    end

    local timeout = GetGameTimer() + 5000
    local vehicle, ped

    while GetGameTimer() < timeout do
        if NetworkDoesNetworkIdExist(vehicleNetId) then
            vehicle = NetworkGetEntityFromNetworkId(vehicleNetId)
        end
        if NetworkDoesNetworkIdExist(pedNetId) then
            ped = NetworkGetEntityFromNetworkId(pedNetId)
        end
        if vehicle and ped then break end
        Wait(100)
    end

    if ped and DoesEntityExist(ped) and race.ped and race.ped.animationSet then
        local modelHash = GetEntityModel(ped)
        SetEntityAsMissionEntity(ped, true, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        SetPedFleeAttributes(ped, 0, false)
        SetPedDiesWhenInjured(ped, false)
        FreezeEntityPosition(ped, true)

        if phoneProps[raceIndex] and DoesEntityExist(phoneProps[raceIndex]) then
            DeleteEntity(phoneProps[raceIndex])
            print(string.format("Cleaned up existing phone prop for race %d", raceIndex))
            phoneProps[raceIndex] = nil
        end

        local pedCoords = GetEntityCoords(ped)
        local phoneModel = GetHashKey("prop_phone_ing")
        local nearbyObjects = GetGamePool('CObject')
        for _, object in ipairs(nearbyObjects) do
            if DoesEntityExist(object) and GetEntityModel(object) == phoneModel then
                local objCoords = GetEntityCoords(object)
                local distance = #(pedCoords - objCoords)
                if distance < 7.0 or IsEntityAttachedToEntity(object, ped) then
                    DeleteEntity(object)
                    print(string.format("Cleaned up stray phone prop near ped for race %d", raceIndex))
                end
            end
        end

        RequestModel(phoneModel)
        while not HasModelLoaded(phoneModel) do Wait(50) end
        local phone = CreateObject(phoneModel, 1.0, 1.0, 1.0, true, true, false)
        local boneIndex = GetPedBoneIndex(ped, 28422)
        local xOff, yOff, zOff = 0.02, 0.02, -0.02
        local xRot, yRot, zRot = 0.0, 0.0, 0.0
        AttachEntityToEntity(phone, ped, boneIndex, xOff, yOff, zOff, xRot, yRot, zRot, true, true, false, true, 1, true)
        phoneProps[raceIndex] = phone
        print(string.format("Spawned phone prop for ped in race %d", raceIndex))

        local animSet = race.ped.animationSet
        if animSet and animSet.dict and animSet.anims and #animSet.anims > 0 then
            RequestAnimDict(animSet.dict)
            while not HasAnimDictLoaded(animSet.dict) do Wait(50) end

            local anim = animSet.anims[math.random(1, #animSet.anims)]
            TaskPlayAnim(ped, animSet.dict, anim, 8.0, -8.0, -1, 1, 0, false, false, false)
        end
    end
end)

RegisterNetEvent('mnc-timetrials:client:cleanupRaceEntities', function(raceIndex)
    local race = Config.Races[raceIndex]
    if race and race.ped and race.ped.coords then
        if phoneProps[raceIndex] and DoesEntityExist(phoneProps[raceIndex]) then
            DeleteEntity(phoneProps[raceIndex])
            print(string.format("Cleaned up tracked phone prop for race %d", raceIndex))
            phoneProps[raceIndex] = nil
        end

        local pedCoords = vector3(race.ped.coords.x, race.ped.coords.y, race.ped.coords.z)
        local phoneModel = GetHashKey("prop_phone_ing")
        local nearbyObjects = GetGamePool('CObject')
        for _, object in ipairs(nearbyObjects) do
            if DoesEntityExist(object) and GetEntityModel(object) == phoneModel then
                local objCoords = GetEntityCoords(object)
                local distance = #(pedCoords - objCoords)
                if distance < 7.0 then
                    DeleteEntity(object)
                    print(string.format("Cleaned up stray phone prop during race cleanup for race %d", raceIndex))
                end
            end
        end
    end

    TriggerEvent('ox_lib:notify', {
        title = 'Time Trial',
        description = 'Race entities for ' .. (Config.Races[raceIndex].name or 'race') .. ' cleaned up.',
        type = 'inform',
        duration = 5000
    })
end)