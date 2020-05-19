RegisterNetEvent('vd-inventory:server:giveItem')
AddEventHandler('vd-inventory:server:giveItem', function(target, item, quantity) 
    TriggerClientEvent('vd-inventory:client:giveItem', tonumber(target), item, quantity)
end)