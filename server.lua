local QBCore = exports['qb-core']:GetCoreObject()

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        print('mnc-timetrials started successfully.')
    end
end)

RegisterNetEvent('mnc-timetrials:server:chargeWager', function(wager)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    if Player.Functions.RemoveMoney('bank', wager, 'timetrial-wager') then
        print(('Player %s wagered $%s'):format(Player.PlayerData.name, wager))
        -- Notify client that wager was accepted
        TriggerClientEvent('mnc-timetrials:client:wagerAccepted', src, wager)
    else
        TriggerClientEvent('ox_lib:notify', src, {
            title = 'Wager Error',
            description = 'Not enough money in your bank account to place the wager.',
            type = 'error'
        })
    end
end)

RegisterNetEvent('mnc-timetrials:server:payout', function(amount)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    Player.Functions.AddMoney('bank', amount, 'timetrial-win')
    TriggerClientEvent('ox_lib:notify', src, {
        title = 'Race Payout',
        description = 'You received $' .. amount .. ' in your bank account for winning!',
        type = 'success'
    })
end)

