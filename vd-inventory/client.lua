local droppedItems = {

}

Citizen.CreateThread(function() 
    while true do
        for i,v in pairs(droppedItems) do
            x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
            distance = GetDistanceBetweenCoords(x, y, z, droppedItems[i].x + 0.8, droppedItems[i].y, droppedItems[i].z, true)
            if distance < 10 then
                DrawMarker(2, droppedItems[i].x + 0.8, droppedItems[i].y, droppedItems[i].z - 0.5, 0, 0, 0, 0, 0, 0, 0.25, 0.15, 0.15, 125, 0, 0, 180, false, false, false, false)
            end
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

RegisterNUICallback('dropItem', function(data) 
    local stash = {x = "", y = "", z = "", contents = "", id = "", occupied = true}
    stash.x, stash.y, stash.z = table.unpack(GetEntityCoords(PlayerPedId()))
    stash.contents = data.contents
    stash.id = data.id
    TriggerServerEvent('vd-inventory:server:dropItem', stash)
end)

RegisterNUICallback('closeInv', function(data) 
    SetNuiFocus(false, false)

    local index
    if(data.stashID ~= 0) then
        for i,v in pairs(droppedItems) do
            if droppedItems[i].id == data.stashID then
                index = i
                break
            end
        end
        TriggerServerEvent('vd-inventory:server:updateStash', index, false, data.contents)
    end
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

RegisterNetEvent('vd-inventory:client:updateStash')
AddEventHandler('vd-inventory:client:updateStash', function(stashIndex, occupation, contents) 
    droppedItems[stashIndex].occupied = occupation
    droppedItems[stashIndex].contents = contents
end)


RegisterNetEvent('vd-inventory:client:giveItem') 
AddEventHandler('vd-inventory:client:giveItem', function(item, quantity) 
    SendNUIMessage({
        type = "giveItem",
        item = item,
        quantity = tonumber(quantity)
    })
end)

RegisterNetEvent('vd-inventory:client:dropItem') 
AddEventHandler('vd-inventory:client:dropItem', function(stash)
    table.insert(droppedItems, stash)
end)

Citizen.CreateThread(function() 
    while true do
        if IsDisabledControlJustPressed(1, 37) then -- tab
            local closestDroppedItemDistance
            local closestDroppedItemIndex 
            for i,v in pairs(droppedItems) do
                local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
                local distance = GetDistanceBetweenCoords(x, y, z, droppedItems[i].x, droppedItems[i].y, droppedItems[i].z, true)
                if(closestDroppedItemDistance == nil or closestDroppedItemDistance > distance) then
                    closestDroppedItemIndex = i
                    closestDroppedItemDistance = distance
                end
            end

            Wait(250) -- Wait so the inventory doesn't open and directly close again

            if(closestDroppedItemDistance ~= nil and closestDroppedItemIndex ~= nil) then 
                if closestDroppedItemDistance <= 5 then 
                    SendNUIMessage({
                        type = 'showInv',
                        inventoryData = droppedItems[closestDroppedItemIndex]
                    })
                    TriggerServerEvent('vd-inventory:server:setStashOccupation', closestDroppedItemIndex, true)
                else 
                    SendNUIMessage({
                        type = 'showInv',
                        inventoryData = ''
                    })
                end
            else 
                SendNUIMessage({
                    type = 'showInv',
                    inventoryData = ''
                })
            end

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