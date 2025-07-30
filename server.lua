local QBCore = exports['qb-core']:GetCoreObject()
local currentWagers = {} -- Initialize the table to store active wagers

-- Check if a money type is valid in QBCore
local function IsValidMoneyType(moneyType)
    local validTypes = { 'cash', 'bank' }
    if QBCore.Config.Money.MoneyTypes[moneyType] then
        table.insert(validTypes, moneyType)
        return true
    end
    return false
end

-- Initialize or get player's race completion count
local function GetRaceCompletionCount(Player, raceIndex, wagerAmount)
    local raceData = Player.PlayerData.metadata.timetrials_races or {}
    raceData[raceIndex] = raceData[raceIndex] or {}
    raceData[raceIndex][tostring(wagerAmount)] = raceData[raceIndex][tostring(wagerAmount)] or 0 -- Initialize to 0 if not set
    return raceData[raceIndex][tostring(wagerAmount)]
end

-- Increment player's race completion count
local function IncrementRaceCompletionCount(Player, raceIndex, wagerAmount)
    local raceData = Player.PlayerData.metadata.timetrials_races or {}
    raceData[raceIndex] = raceData[raceIndex] or {}
    raceData[raceIndex][tostring(wagerAmount)] = (raceData[raceIndex][tostring(wagerAmount)] or 0) + 1
    Player.Functions.SetMetaData('timetrials_races', raceData)
    return raceData[raceIndex][tostring(wagerAmount)]
end

-- Reset player's race completion count for a specific race and wager
local function ResetRaceCompletionCount(Player, raceIndex, wagerAmount)
    local raceData = Player.PlayerData.metadata.timetrials_races or {}
    raceData[raceIndex] = raceData[raceIndex] or {}
    raceData[raceIndex][tostring(wagerAmount)] = 0
    Player.Functions.SetMetaData('timetrials_races', raceData)
    print('[mnc-timetrials:server:ResetRaceCompletionCount] Reset race count for player ' .. Player.PlayerData.citizenid .. ' for race ' .. raceIndex .. ' wager ' .. wagerAmount)
end

RegisterServerEvent('mnc-timetrials:server:getRaceCount', function(raceIndex, wagerAmount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        print('[mnc-timetrials:server:getRaceCount] Error: Player not found for source ' .. src)
        return
    end

    local raceCount = GetRaceCompletionCount(Player, raceIndex, wagerAmount)
    local raceConfig = Config.Races[raceIndex]
    if not raceConfig then
        print('[mnc-timetrials:server:getRaceCount] Error: Invalid race index ' .. raceIndex)
        return
    end

    local requiredRaces = 0
    for _, wager in ipairs(raceConfig.wagers) do
        if wager.amount == wagerAmount then
            requiredRaces = wager.requiredRaces or 5 -- Fallback to 5 if not specified
            break
        end
    end

    print('[mnc-timetrials:server:getRaceCount] Player ' .. Player.PlayerData.citizenid .. ' has ' .. raceCount .. '/' .. requiredRaces .. ' races for race ' .. raceIndex .. ' wager ' .. wagerAmount)
    TriggerClientEvent('mnc-timetrials:client:setRaceCount', src, raceCount, requiredRaces)
end)

RegisterServerEvent('mnc-timetrials:server:chargeWager', function(wagerData)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        print('[mnc-timetrials:server:chargeWager] Error: Player not found for source ' .. src)
        TriggerClientEvent('mnc-timetrials:client:cancelRace', src)
        return
    end

    print('[mnc-timetrials:server:chargeWager] Processing wager for player ' .. Player.PlayerData.citizenid .. ': ' .. json.encode(wagerData))

    -- Validate wager amount
    if wagerData.amount < 0 or wagerData.amount > 100000 then
        print('[mnc-timetrials:server:chargeWager] Error: Invalid wager amount ' .. wagerData.amount .. ' for player ' .. Player.PlayerData.citizenid)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Time Trial',
            description = 'Wager amount must be between 0 and 100,000.',
            type = 'error',
            duration = 5000
        })
        TriggerClientEvent('mnc-timetrials:client:cancelRace', src)
        return
    end

    -- Handle free wagers (amount = 0)
    if wagerData.amount == 0 then
        print('[mnc-timetrials:server:chargeWager] Free wager accepted for player ' .. Player.PlayerData.citizenid)
        currentWagers[src] = wagerData -- Store the wager data for this player
        print('[mnc-timetrials:server:chargeWager] Stored wager for player ' .. Player.PlayerData.citizenid .. ': ' .. json.encode(wagerData))
        TriggerClientEvent('mnc-timetrials:client:wagerAccepted', src, wagerData)
        return
    end

    -- Validate payment type
    local paymentType = wagerData.paymentType
    if not paymentType or not (paymentType == 'cash' or paymentType == 'bank' or paymentType == 'crypto') then
        print('[mnc-timetrials:server:chargeWager] Error: Invalid payment type ' .. tostring(paymentType) .. ' for player ' .. Player.PlayerData.citizenid)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Time Trial',
            description = 'Invalid payment type selected.',
            type = 'error',
            duration = 5000
        })
        TriggerClientEvent('mnc-timetrials:client:cancelRace', src)
        return
    end

    -- Check if crypto is supported, fallback to bank if not
    if paymentType == 'crypto' and not IsValidMoneyType('crypto') then
        print('[mnc-timetrials:server:chargeWager] Error: Crypto money type not supported for player ' .. Player.PlayerData.citizenid .. ', falling back to bank')
        paymentType = 'bank'
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Time Trial',
            description = 'Crypto payments are not available, using bank instead.',
            type = 'inform',
            duration = 5000
        })
    end

    -- Check for required item if specified
    if wagerData.requiredItem then
        local item = Player.Functions.GetItemByName(wagerData.requiredItem.name)
        if not item or item.amount < wagerData.requiredItem.amount then
            print('[mnc-timetrials:server:chargeWager] Error: Player ' .. Player.PlayerData.citizenid .. ' lacks required item ' .. wagerData.requiredItem.name .. ' (required: ' .. wagerData.requiredItem.amount .. ', has: ' .. (item and item.amount or 0) .. ')')
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Time Trial',
                description = 'You need ' .. wagerData.requiredItem.amount .. 'x ' .. wagerData.requiredItem.name .. ' to start this race.',
                type = 'error',
                duration = 5000
            })
            TriggerClientEvent('mnc-timetrials:client:cancelRace', src)
            return
        end
    end

    -- Check player balance and attempt to remove money
    local balance = Player.PlayerData.money[paymentType] or 0
    if balance < wagerData.amount then
        print('[mnc-timetrials:server:chargeWager] Error: Player ' .. Player.PlayerData.citizenid .. ' has insufficient ' .. paymentType .. ' (has: ' .. balance .. ', needed: ' .. wagerData.amount .. ')')
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Time Trial',
            description = 'You do not have enough ' .. (paymentType == 'crypto' and 'Crypto' or paymentType:gsub("^%l", string.upper)) .. ' (have: ' .. (paymentType == 'crypto' and balance or '$' .. balance) .. ', need: ' .. (paymentType == 'crypto' and wagerData.amount or '$' .. wagerData.amount) .. ').',
            type = 'error',
            duration = 5000
        })
        TriggerClientEvent('mnc-timetrials:client:cancelRace', src)
        return
    end

    local moneyRemoved = Player.Functions.RemoveMoney(paymentType, wagerData.amount, 'Time Trial Wager')
    print('[mnc-timetrials:server:chargeWager] Attempted to remove ' .. wagerData.amount .. ' ' .. paymentType .. ' from player ' .. Player.PlayerData.citizenid .. ': ' .. (moneyRemoved and 'Success' or 'Failed'))

    if not moneyRemoved then
        currentWagers[src] = nil -- Clear wager if payment fails
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Time Trial',
            description = 'Failed to process ' .. (paymentType == 'crypto' and 'Crypto' or paymentType:gsub("^%l", string.upper)) .. ' payment. Contact an admin.',
            type = 'error',
            duration = 5000
        })
        TriggerClientEvent('mnc-timetrials:client:cancelRace', src)
        return
    end

    -- After successful wager processing, store wager data
    currentWagers[src] = wagerData -- Store the wager data for this player
    print('[mnc-timetrials:server:chargeWager] Stored wager for player ' .. Player.PlayerData.citizenid .. ': ' .. json.encode(wagerData))

    -- Remove required item if applicable
    if wagerData.requiredItem then
        Player.Functions.RemoveItem(wagerData.requiredItem.name, wagerData.requiredItem.amount)
        print('[mnc-timetrials:server:chargeWager] Removed ' .. wagerData.requiredItem.amount .. 'x ' .. wagerData.requiredItem.name .. ' from player ' .. Player.PlayerData.citizenid)
    end

    TriggerClientEvent('mnc-timetrials:client:wagerAccepted', src, wagerData)
end)

RegisterServerEvent('mnc-timetrials:server:payout', function(wagerData, raceIndex)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then
        print('[mnc-timetrials:server:payout] Error: Player not found for source ' .. src)
        return
    end

    print('[mnc-timetrials:server:payout] Processing payout for player ' .. Player.PlayerData.citizenid .. ': ' .. json.encode(wagerData) .. ' for race ' .. raceIndex)

    -- Validate payout amount
    if wagerData.payout < 0 then
        print('[mnc-timetrials:server:payout] Error: Invalid payout amount ' .. wagerData.payout .. ' for player ' .. Player.PlayerData.citizenid)
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Time Trial',
            description = 'Invalid payout amount configured.',
            type = 'error',
            duration = 5000
        })
        return
    end

    -- Increment race completion count
    local raceCount = IncrementRaceCompletionCount(Player, raceIndex, wagerData.amount)
    print('[mnc-timetrials:server:payout] Player ' .. Player.PlayerData.citizenid .. ' completed race ' .. raceIndex .. ' with wager ' .. wagerData.amount .. '. Total completions: ' .. raceCount)

    -- Get required races for this wager
    local requiredRaces = wagerData.requiredRaces or 5 -- Fallback to 5 if not specified

    -- Process payout
    if wagerData.payout > 0 then
        local paymentType = wagerData.paymentType
        if paymentType == 'crypto' and not IsValidMoneyType('crypto') then
            print('[mnc-timetrials:server:payout] Error: Crypto money type not supported for player ' .. Player.PlayerData.citizenid .. ', falling back to bank')
            paymentType = 'bank'
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Time Trial',
                description = 'Crypto payments are not available, using bank for payout.',
                type = 'inform',
                duration = 5000
            })
        end

        local moneyAdded = Player.Functions.AddMoney(paymentType, wagerData.payout, 'Time Trial Payout')
        print('[mnc-timetrials:server:payout] Attempted to add ' .. wagerData.payout .. ' ' .. paymentType .. ' to player ' .. Player.PlayerData.citizenid .. ': ' .. (moneyAdded and 'Success' or 'Failed'))

        if not moneyAdded then
            print('[mnc-timetrials:server:payout] Error: Failed to add ' .. wagerData.payout .. ' ' .. paymentType .. ' to player ' .. Player.PlayerData.citizenid)
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Time Trial',
                description = 'Failed to process payout. Contact an admin.',
                type = 'error',
                duration = 5000
            })
            return
        end

        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Time Trial Payout',
            description = ('You won %s!'):format(paymentType == 'crypto' and wagerData.payout .. ' Crypto' or '$' .. wagerData.payout),
            type = 'success',
            duration = 5000
        })
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Time Trial Payout',
            description = 'No cash payout for this race.',
            type = 'inform',
            duration = 5000
        })
    end

    -- Process reward item if required races are met
    if wagerData.rewardItem and raceCount >= requiredRaces then
        local itemAdded = Player.Functions.AddItem(wagerData.rewardItem.name, wagerData.rewardItem.amount)
        print('[mnc-timetrials:server:payout] Attempted to add ' .. wagerData.rewardItem.amount .. 'x ' .. wagerData.rewardItem.name .. ' to player ' .. Player.PlayerData.citizenid .. ': ' .. (itemAdded and 'Success' or 'Failed'))
        if itemAdded then
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Time Trial Reward',
                description = 'You received ' .. wagerData.rewardItem.amount .. 'x ' .. wagerData.rewardItem.name .. ' after completing ' .. raceCount .. '/' .. requiredRaces .. ' races!',
                type = 'success',
                duration = 5000
            })
            -- Reset race count after reward is given
            ResetRaceCompletionCount(Player, raceIndex, wagerData.amount)
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = 'Time Trial',
                description = 'Failed to add reward item. Contact an admin.',
                type = 'error',
                duration = 5000
            })
        end
    elseif wagerData.rewardItem then
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Time Trial Progress',
            description = 'You have completed ' .. raceCount .. '/' .. requiredRaces .. ' races for this wager. Complete ' .. (requiredRaces - raceCount) .. ' more to earn ' .. wagerData.rewardItem.amount .. 'x ' .. wagerData.rewardItem.name .. '!',
            type = 'inform',
            duration = 5000
        })
    end

    -- Clear wager data after payout
    currentWagers[src] = nil
    print('[mnc-timetrials:server:payout] Cleared wager data for player source ' .. src)
end)

-- Server callback to initialize player data
QBCore.Functions.CreateCallback('mnc-timetrials:server:initPlayer', function(source, cb)
    local Player = QBCore.Functions.GetPlayer(source)
    if not Player then
        cb({success = false})
        return
    end
    local citizenId = Player.PlayerData.citizenid
    raceCounts[citizenId] = Player.PlayerData.metadata['racecounts'] or {}
    cb({success = true})
end)

-- Event to handle player disconnect
AddEventHandler('playerDropped', function()
    local src = source
    currentWagers[src] = nil
    print('[mnc-timetrials:server:playerDropped] Cleared wager data for player source ' .. src)
end)

-- Initialize players when they connect
AddEventHandler('playerConnecting', function()
    local src = source
    QBCore.Functions.CreateCallback('mnc-timetrials:server:initPlayer', src, function(result)
        if result.success then
            print(('Initialized race data for player %d'):format(src))
        end
    end)
end)