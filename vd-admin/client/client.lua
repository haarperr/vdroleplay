VDCore = nil

Citizen.CreateThread(function() 
    while true do 
        while VDCore == nil do 
            TriggerEvent('vd-core:getSharedObject', function(obj) VDCore = obj end)
            Citizen.Wait(50)
        end

        Citizen.Wait(0)
    end
end)

RegisterCommand('setammo', function(source, args) 
    if VDCore.tablesize(args) == 1 then
        local ammoType = GetPedAmmoTypeFromWeapon(PlayerPedId(), GetSelectedPedWeapon(PlayerPedId()))
        SetPedAmmoByType(PlayerPedId(), ammoType, tonumber(args[1]))
        VDCore.Game.Notify('Je hebt ' .. args[1] .. ' ammo ontvangen voor ' .. GetWeapontypeModel(GetSelectedPedWeapon(PlayerPedId())), 'green')
    else 
        VDCore.chatNotify('error', 'Onjuiste Argumenten')
    end
end, false)