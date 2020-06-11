defaultBlastCooldown = 1 -- cooldown in minutes

ATMs = {
    { x = 147.67, y = -1035.81, z = 29.34, isThermiteActive = false },
    { x = 111.12, y = -775.293, z = 31.43, isThermiteActive = false }
}

groundMoney = {}

currentBlastCooldown = 0 

cash = 0 

RegisterCommand('pos', function() 
    print(GetEntityCoords(PlayerPedId()))
    print(GetEntityHeading(PlayerPedId()))
    VDCore.chatNotify('normal', 'Je hebt ' .. cash .. ' euro cash')
    VDCore.Game.Notify('Lolzxd', 'green')

end, false)

local function getClosestATM() 
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)

    local closestATMDistance
    local closestATMIndex 
    for i,v in pairs(ATMs) do
        local x,y,z
        if IsPedInAnyVehicle(PlayerPedId(), false) then
            x,y,z = table.unpack(GetOffsetFromEntityInWorldCoords(veh, 0.0, 2.5, 0.0))
        else 
            x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
        end

        local distance = GetDistanceBetweenCoords(x, y, z, ATMs[i].x, ATMs[i].y, ATMs[i].z, true)
        if(closestATMDistance == nil or closestATMDistance > distance) then
            closestATMIndex = i
            closestATMDistance = distance
        end
    end

    return closestATMDistance,closestATMIndex 
end

local function getClosestMoneyOnGround() 
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)

    local closestGroundMoneyDistance
    local closestGroundMoneyIndex 
    for i,v in pairs(groundMoney) do
        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))

            local distance = GetDistanceBetweenCoords(x, y, z, groundMoney[i].x, groundMoney[i].y, groundMoney[i].z, true)
            if(closestGroundMoneyDistance == nil or closestGroundMoneyDistance > distance) then
                closestGroundMoneyIndex = i
                closestGroundMoneyDistance = distance
            end
        end
    end

    return closestGroundMoneyDistance, closestGroundMoneyIndex 
end

Citizen.CreateThread(function() 
    while true do
        currentBlastCooldown = currentBlastCooldown - 1
        Wait(60000)
    end
end)

Citizen.CreateThread(function()  
    lastVehicleHP = false
    while true do 
        for i,v in pairs(groundMoney) do 
            local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
            if GetDistanceBetweenCoords(x, y, z, groundMoney[i].x, groundMoney[i].y, groundMoney[i].z, true) <= 10 then        
                DrawMarker(27, groundMoney[i].x, groundMoney[i].y, groundMoney[i].z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 0, 255, 0, 255, false)

                if GetDistanceBetweenCoords(x, y, z, groundMoney[i].x, groundMoney[i].y, groundMoney[i].z, true) <= 2 then
                    VDCore.World.DrawText3Ds(groundMoney[i].x, groundMoney[i].y, groundMoney[i].z + 0.2, "~g~E ~w~- Raap geld op")
                end
            end
        end

        if IsControlJustPressed(0, 38) and not IsPedInAnyVehicle(PlayerPedId(), false) then 
            closestGroundMoneyDistance, closestGroundMoneyIndex = getClosestMoneyOnGround()
            if(closestGroundMoneyDistance ~= nil) then
                if closestGroundMoneyDistance <= 2 then 
                    VDCore.playAnim("random@mugging1", "pickup_low", -1, 1)

                    VDCore.startProgressbar("GELD PAKKEN", 1, function(wasCancelled) 
                        if not wasCancelled then 
                            VDCore.Game.Notify("Je hebt " .. groundMoney[closestGroundMoneyIndex].value .. "euro opgepakt")
                            cash = cash + groundMoney[closestGroundMoneyIndex].value
                            table.remove(groundMoney, closestGroundMoneyIndex)
                            ClearPedTasks(PlayerPedId())
                        end
                    end)
                end
            end
        end

        if IsPedInAnyVehicle(PlayerPedId(), false) then
            if GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), false), -1) == PlayerPedId() then
                local veh = GetVehiclePedIsIn(PlayerPedId(), false)
                local currentVehicleHealth = GetVehicleBodyHealth(veh)
                local x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(veh, 0.0, 2.5, 0.0))
                

                if lastVehicleHP then
                    local vehicleHPDifference = lastVehicleHP - currentVehicleHealth
                    if vehicleHPDifference > 20 then 
                        local closestATMDistance,closestATMIndex = getClosestATM()
                        
                        if closestATMDistance ~= nil and closestATMDistance <= 1 then 
                            if ATMs[closestATMIndex].isThermiteActive == true then
                                SetVehicleEngineHealth(veh, 0)
                                SetVehicleBodyHealth(veh, 0)
                                SetVehicleEngineOn(veh, false, false)

                                if GetEntityHeading(PlayerPedId()) > 180 then 
                                    ApplyForceToEntity(veh, 0, x, y - 10.0, z, 0, 0, 0, 0, false, true, true, false, true)
                                else 
                                    ApplyForceToEntity(veh, 0, x, y + 10.0, z, 0, 0, 0, 0, false, true, true, false, true)
                                end

                                AddExplosion(x, y, z, 'EXPLOSION_GRENADE', 0, true, true, true)
                                AddExplosion(x, y, z, 'EXPLOSION_BZGAS', 0, true, false, false)
                                
                                TriggerServerEvent('qb-atmrobbery:server:updateATM', closestATMIndex) 
                                TriggerServerEvent('qb-atmrobbery:server:createGroundMoney', GetOffsetFromEntityInWorldCoords(veh, 0.0, -2.5, 0.0), closestATMIndex)
                            end
                        end
                    end
                end

                lastVehicleHP = GetVehicleBodyHealth(veh)
            end
        else 
            lastVehicleHP = false 
        end
        Wait(0)
    end
end)

RegisterNetEvent('qb-atmrobbery:client:plantThermite')
AddEventHandler('qb-atmrobbery:client:plantThermite', function() 
    if not IsPedInAnyVehicle(PlayerPedId(), false) then
        local closestATMDistance,closestATMIndex = getClosestATM()
        if closestATMDistance ~= nil and closestATMDistance <= 2 then
            if currentBlastCooldown <= 0 then
                if ATMs[closestATMIndex].isThermiteActive == false then
                    VDCore.startProgressbar("THERMIET PLANTEN", 5, function(wasCancelled) 
                        if not wasCancelled then 
                            TriggerServerEvent('qb-atmrobbery:server:updateATM', closestATMIndex)
                            VDCore.Game.Notify("Je hebt thermite geplant op de ATM")
                        end
                    end)
                else 
                    VDCore.Game.Notify("Er zit al thermiet op deze ATM")
                end
            else 
                VDCore.Game.Notify("Je kan op het moment geen plofkraak plegen")
            end
        end
    else 
        VDCore.chatNotify('error', "Je kan niet in een voertuig zitten!")
    end
end)

RegisterNetEvent('qb-atmrobbery:client:updateATM')
AddEventHandler('qb-atmrobbery:client:updateATM', function(ATMIndex) 
    if ATMs[ATMIndex].isThermiteActive == false then
        ATMs[ATMIndex].isThermiteActive = true
    else 
        ATMs[ATMIndex].isThermiteActive = false
    end

    currentBlastCooldown = defaultBlastCooldown
end)

RegisterNetEvent('qb-atmrobbery:client:createGroundMoney')
AddEventHandler('qb-atmrobbery:client:createGroundMoney', function(loc, ATMIndex) 
    local x,y,z = table.unpack(loc)
    for i=0, 30 do
        local found,groundZ = GetGroundZFor_3dCoord(ATMs[ATMIndex].x, ATMs[ATMIndex].y, ATMs[ATMIndex].z, 0)
        local newGroundMoney = {x = x + (math.random(-100, 100) / 10), y = y + (math.random(-30, 0) / 10), z = groundZ + 0.1, value = math.random(20, 250)}
        table.insert(groundMoney, newGroundMoney)
    end
end)