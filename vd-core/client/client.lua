TriggerEvent('chat:addSuggestion', '/giveitem', 'Give an item to a player', {
    { name="id", help="The ID of the target player" },
    { name="item", help="The item you want to give" },
    { name="quantity", help="How many you want to give of that item" }
})

Citizen.CreateThread(function() 
    while true do
        HideHudComponentThisFrame(19)
        DisableControlAction(1, 37, false)
        Wait(0)
    end
end)



--Scoreboard
Citizen.CreateThread(function() 
    isControlBeingHeld = false;

    while true do
        if IsControlPressed(0, 212) then
            isControlBeingHeld = true;

            if isControlBeingHeld then
                closestPlayers = VDCore.GetClosestPlayers()

                for i in pairs(closestPlayers) do
                    local playerid = closestPlayers[i] 
                    local target = GetPlayerPed(playerid)
                    local id = GetPlayerServerId(playerid)
                    local tx, ty, tz = table.unpack(GetEntityCoords(target))
                    
                    VDCore.DrawText3Ds(tx, ty, tz + 1, '[' .. id .. ']')
                end
            end
        end

        if IsControlJustReleased(0, 212) then 
            isControlBeingHeld = false;
        end
         
        Wait(0)
    end
end)

--Making player ragdoll
Citizen.CreateThread(function() 
    while true do
        if VDCore.isRagdoll == true then
            SetPedToRagdoll(PlayerPedId(), 1000, 1000, 0, false, false, false)
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
AddEventHandler('vd-core:notify', function(msg) 
    SendNUIMessage({
        type = 'notify',
        message = msg
    })
end)
