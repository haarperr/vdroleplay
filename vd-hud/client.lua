VDCore = nil

Citizen.CreateThread(function() 
    local minimap = RequestScaleformMovie("minimap")
    local seatbeltFixed = false
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)
    while true do
        Citizen.InvokeNative(0xF6E48914C7A8694E, minimap, 'SETUP_HEALTH_ARMOUR')
        Citizen.InvokeNative(0xC3D0841A0CC546A6,3)
        Citizen.InvokeNative(0xC6796A8FFA375E53 )
        HideHudComponentThisFrame(7)
        HideHudComponentThisFrame(9)

        -- print(GetEntityRotation(GetVehiclePedIsIn(PlayerPedId(), false)))
        if IsPedInAnyVehicle(PlayerPedId(), false) then 
            local rotX, rotY, rotZ = table.unpack(GetEntityRotation(GetVehiclePedIsIn(PlayerPedId(), false)))
            if rotX < -90 then 
                DisableControlAction(1, 71, true)--[[INPUT_VEH_ACCELERATE]]
                DisableControlAction(1, 59, true)--[[INPUT_VEH_MOVE_LR]]
                DisableControlAction(1, 63, true)--[[INPUT_VEH_MOVE_LEFT_ONLY]]
                DisableControlAction(1, 64, true)--[[INPUT_VEH_MOVE_RIGHT_ONLY]]
                DisableControlAction(1, 72, true)--[[INPUT_VEH_BRAKE]]
            end
        end

        if(IsControlJustPressed(0, 47)) then 
            SendNUIMessage({
                type = 'toggleSeatbelt'
            })
            seatbeltFixed = not seatbeltFixed
            print(seatbeltFixed)
        end

        if IsPedInAnyVehicle(PlayerPedId(), false) then
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            local currentVehicleHealth = GetVehicleBodyHealth(veh)  
            print(lastVehicleHP)
            print(currentVehicleHealth)

            if lastVehicleHP then
                local vehicleHPDifference = lastVehicleHP - currentVehicleHealth
                if not seatbeltFixed then 
                    if vehicleHPDifference > 75 then
                        ejectFromVehicle()
                        print('test')
                    end
                elseif vehicleHPDifference > 125 then
                    ejectFromVehicle()
                end
            end

            lastVehicleHP = GetVehicleBodyHealth(veh)
        end

        Wait(0)
    end
end)

Citizen.CreateThread(function() 
    local zones = { ['AIRP'] = "Los Santos International Airport", ['ALAMO'] = "Alamo Sea", ['ALTA'] = "Alta", ['ARMYB'] = "Fort Zancudo", ['BANHAMC'] = "Banham Canyon Dr", ['BANNING'] = "Banning", ['BEACH'] = "Vespucci Beach", ['BHAMCA'] = "Banham Canyon", ['BRADP'] = "Braddock Pass", ['BRADT'] = "Braddock Tunnel", ['BURTON'] = "Burton", ['CALAFB'] = "Calafia Bridge", ['CANNY'] = "Raton Canyon", ['CCREAK'] = "Cassidy Creek", ['CHAMH'] = "Chamberlain Hills", ['CHIL'] = "Vinewood Hills", ['CHU'] = "Chumash", ['CMSW'] = "Chiliad Mountain State Wilderness", ['CYPRE'] = "Cypress Flats", ['DAVIS'] = "Davis", ['DELBE'] = "Del Perro Beach", ['DELPE'] = "Del Perro", ['DELSOL'] = "La Puerta", ['DESRT'] = "Grand Senora Desert", ['DOWNT'] = "Downtown", ['DTVINE'] = "Downtown Vinewood", ['EAST_V'] = "East Vinewood", ['EBURO'] = "El Burro Heights", ['ELGORL'] = "El Gordo Lighthouse", ['ELYSIAN'] = "Elysian Island", ['GALFISH'] = "Galilee", ['GOLF'] = "GWC and Golfing Society", ['GRAPES'] = "Grapeseed", ['GREATC'] = "Great Chaparral", ['HARMO'] = "Harmony", ['HAWICK'] = "Hawick", ['HORS'] = "Vinewood Racetrack", ['HUMLAB'] = "Humane Labs and Research", ['JAIL'] = "Bolingbroke Penitentiary", ['KOREAT'] = "Little Seoul", ['LACT'] = "Land Act Reservoir", ['LAGO'] = "Lago Zancudo", ['LDAM'] = "Land Act Dam", ['LEGSQU'] = "Legion Square", ['LMESA'] = "La Mesa", ['LOSPUER'] = "La Puerta", ['MIRR'] = "Mirror Park", ['MORN'] = "Morningwood", ['MOVIE'] = "Richards Majestic", ['MTCHIL'] = "Mount Chiliad", ['MTGORDO'] = "Mount Gordo", ['MTJOSE'] = "Mount Josiah", ['MURRI'] = "Murrieta Heights", ['NCHU'] = "North Chumash", ['NOOSE'] = "N.O.O.S.E", ['OCEANA'] = "Pacific Ocean", ['PALCOV'] = "Paleto Cove", ['PALETO'] = "Paleto Bay", ['PALFOR'] = "Paleto Forest", ['PALHIGH'] = "Palomino Highlands", ['PALMPOW'] = "Palmer-Taylor Power Station", ['PBLUFF'] = "Pacific Bluffs", ['PBOX'] = "Pillbox Hill", ['PROCOB'] = "Procopio Beach", ['RANCHO'] = "Rancho", ['RGLEN'] = "Richman Glen", ['RICHM'] = "Richman", ['ROCKF'] = "Rockford Hills", ['RTRAK'] = "Redwood Lights Track", ['SANAND'] = "San Andreas", ['SANCHIA'] = "San Chianski Mountain Range", ['SANDY'] = "Sandy Shores", ['SKID'] = "Mission Row", ['SLAB'] = "Stab City", ['STAD'] = "Maze Bank Arena", ['STRAW'] = "Strawberry", ['TATAMO'] = "Tataviam Mountains", ['TERMINA'] = "Terminal", ['TEXTI'] = "Textile City", ['TONGVAH'] = "Tongva Hills", ['TONGVAV'] = "Tongva Valley", ['VCANA'] = "Vespucci Canals", ['VESP'] = "Vespucci", ['VINE'] = "Vinewood", ['WINDF'] = "Ron Alternates Wind Farm", ['WVINE'] = "West Vinewood", ['ZANCUDO'] = "Zancudo River", ['ZP_ORT'] = "Port of South Los Santos", ['ZQ_UAR'] = "Davis Quartz" }
    while true do
        while VDCore == nil do 
            TriggerEvent('vd-core:getSharedObject', function(obj) VDCore = obj end)
            Wait(50)
        end
        
        local x,y,z = table.unpack(GetEntityCoords(PlayerPedId()))
        local road, crossingRoad = GetStreetNameAtCoord(x, y, z)    

        SendNUIMessage({
            type = 'setValues',
            healthAmount = GetEntityHealth(PlayerPedId()),
            armorAmount = GetPedArmour(PlayerPedId()),
            foodAmount = VDCore.Game.GetBodyStatus().foodAmount,
            waterAmount = VDCore.Game.GetBodyStatus().waterAmount,
            stressAmount = VDCore.Game.GetBodyStatus().stressAmount,
            oxygenAmount = GetPlayerUnderwaterTimeRemaining(PlayerId()),
            maxHealth = GetEntityMaxHealth(PlayerPedId()),

            isInVehicle = IsPedInAnyVehicle(PlayerPedId(), false),
            fuelLevel = GetVehiclePedIsIn(PlayerPedId(), false) == 0 and 0 or GetVehicleFuelLevel(GetVehiclePedIsIn(PlayerPedId(), false)),
            kilometerSpeed = GetEntitySpeed(GetVehiclePedIsIn(PlayerPedId(), false)) * 3.6,
            time = GetClockHours() .. ":" .. GetClockMinutes(),

            currentRoad = GetStreetNameFromHashKey(road),
            crossingRoad = GetStreetNameFromHashKey(crossingRoad),
            currentZone = zones[GetNameOfZone(x, y, z)]
        })

        Citizen.Wait(200)
    end
end)

function ejectFromVehicle() 
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    local coords = GetOffsetFromEntityInWorldCoords(veh, 1.0, 0.0, 1.0)         
    local veloc = vector3(GetEntityForwardX(veh), GetEntityForwardY(veh), 0.0)

    SetEntityCoords(PlayerPedId(), coords)
    Citizen.Wait(1)
    print(veloc)
    SetPedToRagdoll(PlayerPedId(), 5511, 5511, 0, 0, 0, 0)
    SetEntityVelocity(PlayerPedId(), veloc.x*50, veloc.y*50, GetEntityVelocity(veh).z)
    SmashVehicleWindow(veh, 6)
end