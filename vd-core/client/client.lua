alwaysShowPlayernames = false
foodAmount = 100
waterAmount = 100
stressAmount = 0

--VDCore.Game.togglePlayernames
VDCore.togglePlayernames = function()
    alwaysShowPlayernames = not alwaysShowPlayernames
end

VDCore.Game.GetBodyStatus = function()
    return { foodAmount = foodAmount, waterAmount = waterAmount, stressAmount = stressAmount }
end

VDCore.Game.SetBodyStatus = function(food, water, stress) 
    if foodAmount ~= nil then 
        foodAmount = food
    end

    if waterAmount ~= nil then 
        waterAmount = water
    end

    if stressAmount ~= nil then 
        stressAmount = stress
    end
end 

--Scoreboard
Citizen.CreateThread(function() 
    local isControlBeingHeld = false;

    while true do
        if IsControlPressed(0, 212) or alwaysShowPlayernames then
            isControlBeingHeld = true;

            if isControlBeingHeld or alwaysShowPlayernames then
                closestPlayers = VDCore.GetClosestPlayers()

                for i in pairs(closestPlayers) do
                    local playerid = closestPlayers[i] 
                    local target = GetPlayerPed(playerid)
                    local id = GetPlayerServerId(playerid)
                    local tx, ty, tz = table.unpack(GetEntityCoords(target))
                    
                    if not alwaysShowPlayernames then
                        VDCore.World.DrawText3Ds(tx, ty, tz + 1, '[' .. id .. ']')
                    else
                        VDCore.World.DrawText3Ds(tx, ty, tz + 1, '[' .. id .. '] ' .. GetPlayerName(closestPlayers[i]))
                    end
                end
            end
        end

        if IsControlJustReleased(0, 212) then 
            isControlBeingHeld = false;
        end
         
        Wait(0)
    end
end)

Citizen.CreateThread(function() 
    while true do 
        local PlayerData = VDCore.PlayerData.GetPlayerData()

        SetDiscordAppId(721459908830167101)
        SetRichPresence()

        SetDiscordRichPresenceAsset('big')
        SetDiscordRichPresenceAssetText("VDCore Custom Framework")

        Citizen.Wait(5000)
    end
end)

Citizen.CreateThread(function() 
    while true do
        foodAmount = foodAmount - math.random(10)
        waterAmount = waterAmount - math.random(10)

        Wait(60000)
    end
end)

Citizen.CreateThread(function() 
    while true do
        if foodAmount <= 0 or waterAmount <= 0 and not VDCore.isDead then 
            VDCore.Game.KillPlayer(GetPlayerServerId(PlayerId()))
            VDCore.Game.SetBodyStatus(100, 100, 0)
        end

        if VDCore.isDead == true then
            VDCore.loadAnim("mini@cpr@char_b@cpr_def")
            TaskPlayAnim(PlayerPedId(), "mini@cpr@char_b@cpr_def", "cpr_pumpchest_idle", 4.0, 1.0, -1, 1, 0, 0, 0, 0 )
            RemoveAnimDict("mini@cpr@char_b@cpr_def")
        end
    Wait(0)
    end
end)

RegisterCommand('ooc', function(source, args) 
    if VDCore.tablesize(args) > 0 then
        name = GetPlayerName(PlayerId())
        message = table.concat(args, ' ')
        closestPlayers = VDCore.GetClosestPlayers()
        closestPlayerIds = {}

        for i in pairs(closestPlayers) do
            sid = GetPlayerServerId(closestPlayers[i])
            table.insert(closestPlayerIds, sid)
        end

        TriggerServerEvent('vd-core:sendOocMessage', name, message, closestPlayerIds)
    else VDCore.chatNotify('error', ('Onjuiste argumenten (Wilde tenminste 1, kreeg @args)'):gsub('@args', VDCore.tablesize(args))) end
end, false)

RegisterCommand('clear', function()
    TriggerEvent('chat:clear')
end, false)

RegisterCommand('id', function(source, args)
    VDCore.chatNotify('normal', 'ID: ' .. GetPlayerServerId(source))
end, false)

RegisterCommand('test', function(source, args)
    VDCore.createObject('prop_boxpile_06b')
end, false)

RegisterNetEvent('vd-core:sendChatMessage')
AddEventHandler('vd-core:sendChatMessage', function(type, author, message) 
    if type == 'ooc' then 
        VDCore.sendMessage('OOC ' .. author .. ':', message, 50, 111, 176)
    else
        VDCore.chatNotify(type, message)
    end
end)

RegisterNetEvent('vd-core:notify')
AddEventHandler('vd-core:notify', function(msg, type) 
    SendNUIMessage({
        type = 'notify',
        message = msg,
        color = type
    })
end)
