RegisterNetEvent('vd-inventory:server:giveItem')
AddEventHandler('vd-inventory:server:giveItem', function(target, item, quantity) 
    TriggerClientEvent('vd-inventory:client:giveItem', tonumber(target), item, quantity)
end)

RegisterNetEvent('vd-inventory:server:dropItem')
AddEventHandler('vd-inventory:server:dropItem', function(stash)
    TriggerClientEvent('vd-inventory:client:dropItem', -1, stash)
end)

RegisterNetEvent('vd-inventory:server:updateStash')
AddEventHandler('vd-inventory:server:updateStash', function(stashIndex, occupation, contents) 
    TriggerClientEvent('vd-inventory:client:updateStash', -1, stashIndex, occupation, contents)
end)