Citizen.CreateThread(function() 
    while true do
        if IsDisabledControlJustPressed(1, 37) then -- tab
            Wait(250)
            SendNUIMessage({
                type = 'showInv'
            })
            SetNuiFocus(true, true)
        end

        if IsControlJustPressed(1, 157) then -- 1
            SendNUIMessage({
                type = 'quickSlot',
                slot = 1
            })
        end

        if IsControlJustPressed(1, 158) then -- 2
            SendNUIMessage({
                type = 'quickSlot',
                slot = 2
            })
        end

        if IsControlJustPressed(1, 160) then -- 3
            SendNUIMessage({
                type = 'quickSlot',
                slot = 3
            })
        end

        if IsControlJustPressed(1, 164) then -- 4
            SendNUIMessage({
                type = 'quickSlot',
                slot = 4
            })
        end

        if IsControlJustPressed(1, 165) then -- 5
            SendNUIMessage({
                type = 'quickSlot',
                slot = 5
            })
        end

        if IsControlJustPressed(1, 159) then -- 6
            SendNUIMessage({
                type = 'quickSlot',
                slot = 41
            })
        end
        Wait(0)
    end
end)

RegisterCommand('giveitem', function(source, args) 
    if(VDCore.tablesize(args) == 3) then
        TriggerServerEvent('vd-inventory:server:giveItem', args[1], args[2], args[3])
    else 
        VDCore.chatNotify('error', 'Onjuiste argumenten')
    end
end, false)

RegisterCommand('firstnamae', function() 
    print(VDCore.PlayerData.firstName)
end, false)

RegisterNUICallback('closeInv', function() 
    SetNuiFocus(false, false)
end)

RegisterNUICallback('useWeapon', function(data) 
    pid = PlayerPedId()
    animDict = 'reaction@intimidation@1h'

    if VDCore.tablesize(data.itemName) == 2 then
        weaponName = "WEAPON_" ..  data.itemName[1] .. data.itemName[2]
    elseif VDCore.tablesize(data.itemName) == 1 then 
        weaponName = "WEAPON_" ..  data.itemName[1]
    end

    weaponHash = GetHashKey(weaponName)
    bool, curWeaponHash = GetCurrentPedWeapon(pid, 1)
    GiveWeaponToPed(pid, weaponHash, 0, false, false)

    RequestAnimDict(animDict)
	  
	while not HasAnimDictLoaded(animDict) do
		Citizen.Wait(100)
    end

    print(weaponHash)
    if GetSelectedPedWeapon(pid) == -1569615261 then -- -1569615261 is voor vuisten
        TaskPlayAnim(pid, animDict, 'intro', 8.0, -8.0, 2700, 48, 0.0, false, false, false)
        Wait(500)
        SetCurrentPedWeapon(pid, weaponHash, true)
    elseif curWeaponHash == weaponHash then
        TaskPlayAnim(pid, animDict, 'outro', 8.0, -8.0, 2700, 48, 0.0, false, false, false)
        Wait(2000)
        SetCurrentPedWeapon(pid, -1569615261, true)
        RemoveWeaponFromPed(pid, weaponHash)
    else
        TaskPlayAnim(pid, animDict, 'outro', 8.0, -8.0, 2700, 48, 0.0, false, false, false)
        Wait(2000)
        TaskPlayAnim(pid, animDict, 'intro', 8.0, -8.0, 2700, 48, 0.0, false, false, false)
        Wait(500)
        SetCurrentPedWeapon(pid, weaponHash, true)
        RemoveWeaponFromPed(pid, curWeaponHash)
    end

end)

RegisterNUICallback('error', function(data) 
    VDCore.chatNotify('error', data.message)
end)

RegisterNetEvent('vd-inventory:client:giveItem') 
AddEventHandler('vd-inventory:client:giveItem', function(item, quantity) 
    SendNUIMessage({
        type = "giveItem",
        item = item,
        quantity = tonumber(quantity)
    })
end)

