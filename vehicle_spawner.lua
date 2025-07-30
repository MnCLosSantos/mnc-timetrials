-- Table to track spawned entities per race
local spawnedEntities = {}

-- Function to cleanup all existing race entities (brute force method)
local function CleanupAllRaceEntities()
    local allVehicles = GetAllVehicles()
    local allPeds = GetAllPeds()
    
    for raceIndex, race in ipairs(Config.Races) do
        if race.vehicleSpawn and race.ped and race.ped.coords then
            local spawnCoords = vector3(race.vehicleSpawn.x, race.vehicleSpawn.y, race.vehicleSpawn.z)
            local pedCoords = vector3(race.ped.coords.x, race.ped.coords.y, race.ped.coords.z)
            
            -- Clean up vehicles near spawn point
            for _, vehicle in ipairs(allVehicles) do
                if DoesEntityExist(vehicle) then
                    local vehicleCoords = GetEntityCoords(vehicle)
                    local distance = #(vehicleCoords - spawnCoords)
                    if distance < 5.0 then
                        local model = GetEntityModel(vehicle)
                        local expectedModel = GetHashKey(race.vehicleModel)
                        if model == expectedModel then
                            DeleteEntity(vehicle)
                            print(string.format("Cleaned up orphaned vehicle for race %d: %s", raceIndex, race.name))
                        end
                    end
                end
            end
            
            -- Clean up peds near spawn point
            for _, ped in ipairs(allPeds) do
                if DoesEntityExist(ped) then
                    local pedEntityCoords = GetEntityCoords(ped)
                    local distance = #(pedEntityCoords - pedCoords)
                    if distance < 5.0 then
                        local model = GetEntityModel(ped)
                        local expectedModel = GetHashKey(race.ped.model)
                        if model == expectedModel then
                            DeleteEntity(ped)
                            print(string.format("Cleaned up orphaned ped for race %d: %s", raceIndex, race.name))
                        end
                    end
                end
            end
        end
    end
end

-- Function to spawn vehicle and ped for a race
local function SpawnRaceEntities(raceIndex)
    local race = Config.Races[raceIndex]
    if not race or not race.vehicleSpawn or not race.vehicleModel or not race.ped or not race.ped.model or not race.ped.coords then
        print(string.format("Error: Invalid race configuration for raceIndex %d: %s", raceIndex, json.encode(race or {})))
        TriggerClientEvent('ox_lib:notify', -1, {
            title = 'Time Trial',
            description = 'Invalid race configuration for ' .. (race and race.name or 'race ' .. raceIndex) .. '.',
            type = 'error',
            duration = 5000
        })
        return
    end

    if spawnedEntities[raceIndex] then
        print(string.format("Warning: Entities already spawned for raceIndex %d", raceIndex))
        return
    end

    local vehicleHash = GetHashKey(race.vehicleModel)
    local spawnCoords = vector3(race.vehicleSpawn.x, race.vehicleSpawn.y, race.vehicleSpawn.z)
    local heading = race.vehicleSpawn.w or 0.0

    local vehicleNetId = CreateVehicleServerSetter(vehicleHash, 'automobile', spawnCoords.x, spawnCoords.y, spawnCoords.z, heading)
    if vehicleNetId == 0 then
        print(string.format("Error: Failed to spawn vehicle for raceIndex %d, model: %s", raceIndex, race.vehicleModel))
        TriggerClientEvent('ox_lib:notify', -1, {
            title = 'Time Trial',
            description = 'Failed to spawn vehicle for ' .. (race and race.name or 'race ' .. raceIndex) .. '.',
            type = 'error',
            duration = 5000
        })
        return
    end

    local pedHash = GetHashKey(race.ped.model)
    local pedCoords = vector3(race.ped.coords.x, race.ped.coords.y, race.ped.coords.z)
    local pedHeading = race.ped.coords.w or heading
    local ped = CreatePed(4, pedHash, pedCoords.x, pedCoords.y, pedCoords.z, pedHeading, true, true)
    local pedNetId = NetworkGetNetworkIdFromEntity(ped)

    if pedNetId == 0 then
        print(string.format("Error: Failed to spawn ped for raceIndex %d, model: %s", raceIndex, race.ped.model))
        local allVehicles = GetAllVehicles()
        for _, vehicle in ipairs(allVehicles) do
            if DoesEntityExist(vehicle) then
                local vehicleCoords = GetEntityCoords(vehicle)
                local distance = #(vehicleCoords - spawnCoords)
                if distance < 5.0 and GetEntityModel(vehicle) == vehicleHash then
                    DeleteEntity(vehicle)
                    print(string.format("Cleaned up vehicle due to ped spawn failure for raceIndex %d", raceIndex))
                end
            end
        end
        TriggerClientEvent('ox_lib:notify', -1, {
            title = 'Time Trial',
            description = 'Failed to spawn ped for ' .. (race and race.name or 'race ' .. raceIndex) .. '.',
            type = 'error',
            duration = 5000
        })
        return
    end

    spawnedEntities[raceIndex] = {
        vehicleNetId = vehicleNetId,
        pedNetId = pedNetId,
        lastSpawnTime = GetGameTimer()
    }

    print(string.format("Spawned vehicle and ped for raceIndex %d: vehicleNetId=%d, pedNetId=%d, race: %s", raceIndex, vehicleNetId, pedNetId, race.name))

    TriggerClientEvent('mnc-timetrials:client:configureRaceEntities', -1, vehicleNetId, pedNetId, raceIndex)
end

-- Function to cleanup entities
local function CleanupRaceEntities(raceIndex)
    if not spawnedEntities[raceIndex] then return end

    local race = Config.Races[raceIndex]
    local spawnCoords = vector3(race.vehicleSpawn.x, race.vehicleSpawn.y, race.vehicleSpawn.z)
    local pedCoords = vector3(race.ped.coords.x, race.ped.coords.y, race.ped.coords.z)

    local allVehicles = GetAllVehicles()
    for _, vehicle in ipairs(allVehicles) do
        if DoesEntityExist(vehicle) then
            local vehicleCoords = GetEntityCoords(vehicle)
            local distance = #(vehicleCoords - spawnCoords)
            if distance < 5.0 and GetEntityModel(vehicle) == GetHashKey(race.vehicleModel) then
                DeleteEntity(vehicle)
                print(string.format("Cleaned up vehicle for raceIndex %d", raceIndex))
            end
        end
    end

    local allPeds = GetAllPeds()
    for _, ped in ipairs(allPeds) do
        if DoesEntityExist(ped) then
            local pedCoordsCurrent = GetEntityCoords(ped)
            local distance = #(pedCoordsCurrent - pedCoords)
            if distance < 5.0 and GetEntityModel(ped) == GetHashKey(race.ped.model) then
                DeleteEntity(ped)
                print(string.format("Cleaned up ped for raceIndex %d", raceIndex))
            end
        end
    end

    spawnedEntities[raceIndex] = nil
    TriggerClientEvent('mnc-timetrials:client:cleanupRaceEntities', -1, raceIndex)
end

-- Function to check for players and ensure entities
local function CheckPlayerProximityAndConfigure()
    for raceIndex, entities in pairs(spawnedEntities) do
        local race = Config.Races[raceIndex]
        if race and race.ped and race.ped.coords then
            local pedCoords = vector3(race.ped.coords.x, race.ped.coords.y, race.ped.coords.z)
            local pedFound = false
            local allPeds = GetAllPeds()
            for _, ped in ipairs(allPeds) do
                if DoesEntityExist(ped) then
                    local pedCoordsCurrent = GetEntityCoords(ped)
                    local distance = #(pedCoordsCurrent - pedCoords)
                    if distance < 5.0 and GetEntityModel(ped) == GetHashKey(race.ped.model) then
                        pedFound = true
                        break
                    end
                end
            end

            if pedFound then
                local players = GetPlayers()
                for _, playerId in ipairs(players) do
                    local playerPed = GetPlayerPed(playerId)
                    local playerCoords = GetEntityCoords(playerPed)
                    local distance = #(playerCoords - pedCoords)
                    if distance < 50.0 then
                        TriggerClientEvent('mnc-timetrials:client:configureRaceEntities', playerId, entities.vehicleNetId, entities.pedNetId, raceIndex)
                        print(string.format("Triggered animation configuration for player %s near race %d: %s", playerId, raceIndex, race.name))
                    end
                end
            else
                if GetGameTimer() - (entities.lastSpawnTime or 0) > 30000 then
                    print(string.format("Ped missing for race %d, respawning entities", raceIndex))
                    CleanupRaceEntities(raceIndex)
                    SpawnRaceEntities(raceIndex)
                end
            end
        end
    end
end

-- Spawn entities for all races on resource start
AddEventHandler('onResourceStart', function(resource)
    if resource == GetCurrentResourceName() then
        print("Starting mnc-timetrials resource...")
        
        print("Cleaning up any existing race entities...")
        CleanupAllRaceEntities()
        
        Wait(1000)
        
        print("Spawning new entities...")
        for raceIndex, race in ipairs(Config.Races) do
            print(string.format("Attempting to spawn entities for raceIndex %d: %s", raceIndex, race.name))
            SpawnRaceEntities(raceIndex)
            Wait(500)
        end

        CreateThread(function()
            while true do
                CheckPlayerProximityAndConfigure()
                Wait(60000)
            end
        end)
    end
end)

-- Cleanup on resource stop
AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        print("Stopping mnc-timetrials resource, cleaning up entities...")
        for raceIndex, _ in pairs(spawnedEntities) do
            CleanupRaceEntities(raceIndex)
        end
    end
end)