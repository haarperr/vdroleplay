local hasBus = false
local hasBox = false
local postBus
local destBlip
local completedRoute = false
local box
local type
local destination
local salary = 0
local amount = 1
local tempAmount = 0
local i = 1

local location = {
    {x = 17.61454, y = -13.85908, z = 70.31082},
    {x = -6.60725, y = -74.39146, z = 61.87486},
    {x = 66.50694, y = -255.8588, z = 52.35387},
    {x = 8.75, y = -243.16, z = 47.66},
    {x = -40.71, y= -58.78, z = 64.01},
    {x = -149.93, y = 123.86, z = 70.23},
    {x = -239.62, y = 205.817, z = 83.87},
    {x = -413.77, y = 220.39, z = 83.43},
    {x = -516.63, y = 433.49, z = 97.81},
    {x = -401.31, y = 427.53, z = 112.41},

}

local tableCount = 0
for _ in pairs(location) do tableCount = tableCount + 1 end

local postalBlip = AddBlipForCoord(68.66113, 122.0776, 79.14216)
SetBlipSprite(postalBlip, 67)
SetBlipColour(postalBlip, 29)
SetBlipScale(postalBlip, 0.9)
SetBlipDisplay(postalBlip, 3)

BeginTextCommandSetBlipName("STRING")
AddTextComponentString("GoPostal")
EndTextCommandSetBlipName(postalBlip)

Citizen.CreateThread(function()
        while true do
            local pcoords = GetEntityCoords(PlayerPedId())
            local distance = Vdist(pcoords.x, pcoords.y, pcoords.z, 68.66113, 122.0776, 79.14216)

            if distance <= 10 then
                local marker =
                    DrawMarker(2, 68.66113, 122.0776, 79.14216, 0, 0, 0, 0, 0, 0, 0.25, 0.15, 0.15, 255, 0, 0, 200, false, false, false, true)
            end

            if distance <= 5 then
                if not hasBus then
                    DrawText3Ds(68.66113, 122.0776, 79.5, "~g~E ~w~- Haal postbus")

                    if IsControlJustPressed(0, 46) then
                        hasBus = true
                        ped = PlayerPedId()
                        p = GetEntityCoords(PlayerPedId())
                        heading = GetEntityHeading(PlayerPedId())

                        model = GetHashKey("Boxville2")
                        RequestModel(model)

                        while not HasModelLoaded(model) do
                            Citizen.Wait(1)
                        end

                        vehicle = CreateVehicle(model, p.x, p.y, p.z, 158.5, true, false)
                        SetPedIntoVehicle(ped, vehicle, -1)
                        SetModelAsNoLongerNeeded(vehicle)

                        postBus = GetVehiclePedIsIn(PlayerPedId(), false)

                        destBlip = AddBlipForCoord(location[i].x, location[i].y, location[i].z)
                        SetBlipSprite(destBlip, 1)
                        SetBlipColour(destBlip, 26)
                        SetBlipScale(destBlip, 0.9)
                        SetBlipRoute(destBlip, true)

                        amount = math.random(3)
                    end
                else
                    DrawText3Ds(68.66113, 122.0776, 79.5, "~g~E ~w~- Lever postbus in")

                    if IsControlJustPressed(0, 46) then
                        local currentvehicle = GetVehiclePedIsIn(PlayerPedId(), false)

                        if GetEntityModel(currentvehicle) == GetHashKey("Boxville2") then
                            SetEntityAsMissionEntity(currentvehicle, true, true)
                            DeleteVehicle(currentvehicle)
                            RemoveBlip(destBlip)
                            SetBlipRoute(postalBlip, false)
                            hasBus = false

                            if salary > 0 then
                                msg("Success", "Je hebt " .. salary .. " euro verdient!", 0, 255, 0)
                                salary = 0
                                completedRoute = false
                                i = 1
                            else 
                                msg("Zucht", "Je hebt niet eens één bezorging gedaan, dan krijg je ook geen geld van me", 255, 0, 0) 
                            end
                        else
                            msg("Error", "Je bent niet met een postbus gekomen, denk je dat ik gek ben? Ga je postbus halen, hij staat op je kaart!", 255, 0, 0)
                            busPos = GetEntityCoords(postBus)
                            busBlip = AddBlipForCoord(busPos.x, busPos.y, busPos.z)
                            SetBlipSprite(busBlip, 67)
                            SetBlipScale(busBlip, 0.8)
                            SetBlipRoute(busBlip, true)
                            SetBlipRouteColour(busBlip, 4)
                        end
                    end
                end 
            end

            if not IsPedInAnyVehicle(PlayerPedId(), false) and postBus ~= nil then
                busPosX, busPosY, busPosZ = GetOffsetFromEntityInWorldCoords(postBus, 0.0, -4.0, 0.0)
                busPos = GetOffsetFromEntityInWorldCoords(postBus, 0.0, -4.0, 0.0)
                busHeading = GetEntityHeading(postBus)
                distanceToBus = Vdist(pcoords.x, pcoords.y, pcoords.z, busPosX, busPosY, busPosZ)
                distanceToDoor = Vdist(pcoords.x, pcoords.y, pcoords.z, location[i].x, location[i].y, location[i].z)
                
                if distanceToBus <= 3 and distanceToDoor <= 50 and hasBox == false and completedRoute == false then
                    text = DrawText3Ds(busPosX, busPosY, busPosZ, "~g~E ~w~- Pak een doos met post")               
                    if IsControlJustPressed(0, 46) then
                        hasBox = true
                        type = math.random(8)


                        if type == 1 then
                            if not HasModelLoaded('hei_prop_heist_box') then
                                loadProp('hei_prop_heist_box')
                            end

                            box = CreateObject(GetHashKey('hei_prop_heist_box'), pcoords.x, pcoords.y, pcoords.z+0.2,  true,  true, true)
	                        AttachEntityToEntity(box, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 60309), 0.025, 0.08, 0.255, -145.0, 290.0, 0.0, true, true, false, true, 1, true)
                            SetModelAsNoLongerNeeded(box)
                        
                            TriggerEvent("holdbox", -1)
                        end

                        if type ~= 1 then
                            if not HasModelLoaded('prop_cs_rolled_paper') then
                                loadProp('prop_cs_rolled_paper')
                            end

                            box = CreateObject(GetHashKey('prop_cs_rolled_paper'), pcoords.x, pcoords.y+0.2, pcoords.z+0.5,  true,  true, true)
                            AttachEntityToEntity(box, PlayerPedId(), GetPedBoneIndex(PlayerPedId(), 28422), -0.01, 0.01, -0.03, 145.0, 270.0, 0.0, true, true, false, true, 1, true)
                            SetModelAsNoLongerNeeded(box)
                        
                            TriggerEvent("holdnews", -1)
                        end
                        
                        Wait(10)
                    end
                end

                if hasBox and distanceToDoor <= 2 and completedRoute == false then
                    DrawText3Ds(location[i].x, location[i].y, location[i].z, "~g~E ~w~- Lever een doos met post af")
                    if IsControlJustPressed(0, 46) then
                        tempAmount = tempAmount + 1

                        loadAnim("amb@bagels@male@walking@")
                        TaskPlayAnim(PlayerPedId(), "amb@bagels@male@walking@", "static", 4.0, 1.0, -1, 1, 0, 0, 0, 0 )
                        RemoveAnimDict("amb@bagels@male@walking@")

                        Citizen.Wait(1000)
                        ClearPedTasks(PlayerPedId())
                        Citizen.Wait(10)

                        if type == 1 then
                            DeleteEntity(box)
                            TriggerEvent("box", -1)
                            Citizen.Wait(2000)
                        end

                        if type ~= 1 then
                            TriggerEvent("news", -1)
                            Citizen.Wait(1500)
                        end
                        
                        if box ~= nil then
                            DeleteEntity(box)
                        end
                        ClearPedTasks(PlayerPedId())
                        FreezeEntityPosition(PlayerPedId(), false)

                        if type == 1 then
                            salary = salary + 100
                        else 
                            salary = salary + 30
                        end

                        hasBox = false
                    end
                end
            end

            if amount == tempAmount then
                amount = math.random(3)
                tempAmount = 0

                if i ~= tableCount then
                    i = i + 1
                    msg("Success", "Je hebt hier alles bezorgd, ga naar het volgende adres", 0, 255, 0)
                    RemoveBlip(destBlip)

                    destBlip = AddBlipForCoord(location[i].x, location[i].y, location[i].z)
                    SetBlipSprite(destBlip, 1)
                    SetBlipColour(destBlip, 26)
                    SetBlipScale(destBlip, 0.9)
                    SetBlipRoute(destBlip, true)
                else 
                    msg("Success", "Je hebt alle adressen gehad, ga nu terug naar het depot", 0, 255, 0)
                    RemoveBlip(destBlip)
                    SetBlipRoute(postalBlip, true)
                    completedRoute = true
                end

            end

            Citizen.Wait(0)
        end
    end
)

function loadAnim(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(500)
	end
end

function loadProp(model)
	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Citizen.Wait(500)
	end
end

RegisterNetEvent("box")
AddEventHandler("box", function()
    Citizen.CreateThread(function()
        loadAnim("anim@mp_fireworks")
        TaskPlayAnim(PlayerPedId(), "anim@mp_fireworks", "place_firework_3_box", 4.0, 1.0, -1, 1, 0, 0, 0, 0 )
        RemoveAnimDict("anim@mp_fireworks")
    end)
end)

RegisterNetEvent("news")
AddEventHandler("news", function()
    Citizen.CreateThread(function()
        loadAnim("random@mugging1")
        TaskPlayAnim(PlayerPedId(), "random@mugging1", "pickup_low", 4.0, 1.0, -1, 1, 0, 0, 0, 0 )
        RemoveAnimDict("random@mugging1")
    end)
end)

RegisterNetEvent("holdbox")
AddEventHandler("holdbox", function()
    Citizen.CreateThread(function()
        loadAnim("anim@heists@box_carry@")
        TaskPlayAnim(PlayerPedId(), "anim@heists@box_carry@", "idle", 4.0, 1.0, -1, 49, 0, 0, 0, 0 )
        RemoveAnimDict("anim@heists@box_carry@")
    end)
end)

RegisterNetEvent("holdnews")
AddEventHandler("holdnews", function()
    Citizen.CreateThread(function()
        loadAnim("amb@world_human_drinking@coffee@male@base")
        TaskPlayAnim(PlayerPedId(), "amb@world_human_drinking@coffee@male@base", "base", 4.0, 1.0, -1, 49, 0, 0, 0, 0 )
        RemoveAnimDict("amb@world_human_drinking@coffee@male@base")
    end)
end)
