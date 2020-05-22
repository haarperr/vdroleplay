local isInTrunk = false
local droppedItems = {

}

Citizen.CreateThread(function() 
    while true do
        for i,v in pairs(droppedItems) do
            x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))
            distance = GetDistanceBetweenCoords(x, y, z, droppedItems[i].x, droppedItems[i].y, droppedItems[i].z, true)
            if distance < 10 then
                DrawMarker(2, droppedItems[i].x, droppedItems[i].y, droppedItems[i].z, 0, 0, 0, 0, 0, 0, 0.25, 0.15, 0.15, 125, 0, 0, 180, false, false, false, true)
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

RegisterNUICallback('dropItem', function(data) 
    local stash = {x = "0.0", y = "0.0", z = "0.0", contents = "", id = "", occupied = true}
    stash.contents = data.contents
    stash.id = data.id

    if(not IsPedInAnyVehicle(PlayerPedId(), true) and isInTrunk == false) then
        stash.x, stash.y, stash.z = table.unpack(GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.5, -0.6))

        RequestAnimDict("random@mugging1")
	    while not HasAnimDictLoaded("random@mugging1") do
		    Citizen.Wait(50)
        end
    
        TaskPlayAnim(PlayerPedId(), "random@mugging1", "pickup_low", 4.0, 1.0, -1, 8, 0, 0, 0, 0 )
        RemoveAnimDict("random@mugging1")
    elseif IsPedInAnyVehicle(PlayerPedId(), true) and data.id ~= GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)) and not isInTrunk then
        stash.x, stash.y, stash.z = table.unpack(GetOffsetFromEntityInWorldCoords(GetVehiclePedIsIn(PlayerPedId(), false), 0.0, 0.5, -0.6))
    end

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

    if(isInTrunk) then 
        SetVehicleDoorShut(VDCore.getClosestVehicle(5.0), 5, false)
    end

    isInTrunk = false
end)

RegisterNUICallback('saveInventory', function(data) 
    print(VDCore.PlayerData.citizenID)
    TriggerServerEvent('vd-inventory:server:saveInventory', VDCore.PlayerData.citizenID, data.contents)
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

RegisterCommand('clearinv', function() 
    SendNUIMessage({
        type = "clearInventory"
    })
end)

RegisterNUICallback('error', function(data) 
    VDCore.chatNotify('error', data.message)
end)

RegisterNetEvent('vd-inventory:client:clearInv')
AddEventHandler('vd-inventory:client:clearInv', function() 
    SendNUIMessage({
        type = "clearInventory"
    })
end)

RegisterNetEvent('vd-inventory:client:updateStash')
AddEventHandler('vd-inventory:client:updateStash', function(stashIndex, occupation, contents) 
    droppedItems[stashIndex].occupied = occupation
    droppedItems[stashIndex].contents = contents
end)

RegisterNetEvent('vd-inventory:client:getInventory')
AddEventHandler('vd-inventory:client:getInventory', function(contents) 
    SendNUIMessage({
        type = "setInventory",
        contents = contents
    })
end)

RegisterNetEvent('vd-inventory:client:registerInventory')
AddEventHandler('vd-inventory:client:registerInventory', function(contents) 
    SendNUIMessage({
        type = "registerInventory"
    })
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
            Wait(100)
            local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
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

            if(closestDroppedItemDistance ~= nil and closestDroppedItemIndex ~= nil and not IsPedInAnyVehicle(PlayerPedId(), true)) and GetVehicleNumberPlateText(VDCore.getClosestVehicle(5.0)) == nil then 
                if closestDroppedItemDistance <= 5 then 
                    SendNUIMessage({
                        type = 'showInv',
                        inventoryData = droppedItems[closestDroppedItemIndex]
                    })
                    TriggerServerEvent('vd-inventory:client:updateStash', closestDroppedItemIndex, true, droppedItems[closestDroppedItemIndex].contents)
                else
                    SendNUIMessage({
                        type = 'showInv',
                        inventoryData = ''
                    })
                end
            else 
                if IsPedInAnyVehicle(PlayerPedId(), true) then
                    local index
                    for i,v in pairs(droppedItems) do
                        if droppedItems[i].id == "GL" .. GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false)) then
                            index = i
                            break
                        end
                    end

                    if index ~= nil then
                        SendNUIMessage({
                            type = 'showInv',
                            inventoryData = droppedItems[index],
                            vehicleData = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false))
                        })
                        TriggerServerEvent('vd-inventory:client:updateStash', index, true, droppedItems[index].contents)
                    else
                        SendNUIMessage({
                            type = 'showInv',
                            inventoryData = '',
                            vehicleData = GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId(), false))
                        })
                    end
                else 
                    if GetVehicleNumberPlateText(VDCore.getClosestVehicle(5.0)) ~= nil then 
                        x1,y1,z1 = table.unpack(GetOffsetFromEntityInWorldCoords(VDCore.getClosestVehicle(5.0), 0.0, -3.0, 0.0))
                        x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
                        distance = GetDistanceBetweenCoords(x, y, z, x1, y1, z1, true)
                        print(distance)

                        if(distance <= 2) then
                            SetVehicleDoorOpen(VDCore.getClosestVehicle(5.0), 5, false, false)

                            local index
                            for i,v in pairs(droppedItems) do
                                if droppedItems[i].id == "TR" .. GetVehicleNumberPlateText(VDCore.getClosestVehicle(5.0)) then
                                    index = i
                                    break
                                end
                            end

                            if index ~= nil then
                                SendNUIMessage({
                                    type = 'showInv',
                                    inventoryData = droppedItems[index],
                                    vehiclePlate = GetVehicleNumberPlateText(VDCore.getClosestVehicle(5.0))
                                })
                                TriggerServerEvent('vd-inventory:client:updateStash', index, true, droppedItems[index].contents)
                            else 
                                SendNUIMessage({
                                    type = 'showInv',
                                    inventoryData = '',
                                    vehiclePlate = GetVehicleNumberPlateText(VDCore.getClosestVehicle(5.0))
                                })
                            end

                            isInTrunk = true
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
                end
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