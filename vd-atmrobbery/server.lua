RegisterNetEvent('qb-atmrobbery:server:updateATM')
AddEventHandler('qb-atmrobbery:server:updateATM', function(ATMIndex) 
    TriggerClientEvent('qb-atmrobbery:client:updateATM', -1, ATMIndex)
end)

RegisterNetEvent('qb-atmrobbery:server:createGroundMoney')
AddEventHandler('qb-atmrobbery:server:createGroundMoney', function(loc, ATMIndex) 
    TriggerClientEvent('qb-atmrobbery:client:createGroundMoney', -1, loc, ATMIndex)
end)
