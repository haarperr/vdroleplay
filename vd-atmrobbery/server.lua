RegisterNetEvent('vd-atmrobbery:server:updateATM')
AddEventHandler('vd-atmrobbery:server:updateATM', function(ATMIndex) 
    TriggerClientEvent('vd-atmrobbery:client:updateATM', -1, ATMIndex)
end)

RegisterNetEvent('vd-atmrobbery:server:updateGroundMoney')
AddEventHandler('vd-atmrobbery:server:updateGroundMoney', function(groundMoney) 
    TriggerClientEvent('vd-atmrobbery:client:updateGroundMoney', -1, groundMoney)
end)
