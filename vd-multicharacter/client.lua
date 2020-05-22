VDCore = {}

local charCam
function EnableCharUI() 
    pid = PlayerPedId()

    DisableControlAction(1, 29, true)

    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
    charCam = cam
    RenderScriptCams(true, 1, 0, true, true)

    local rotx, roty, rotz = 0.0, 0.0, -39.740
	local camX, camY, camZ = 3061.670, 2116.9899, 2.71193
	local camF = 50.0
	
    SetCamCoord(cam, camX, camY, camZ)
    SetCamRot(cam, rotx, roty, rotz)
    SetCamFov(cam, camF)

    SetEntityCoords(pid, 3062.98, 2118.556, 1.55463, false, false, false, true)
    SetEntityHeading(pid, 138.7183)
    FreezeEntityPosition(pid, true)

    SendNUIMessage({
        type = "charUI",
        show = true
    })

    TriggerServerEvent('vd-multicharacter:getPlayerData', GetPlayerServerId(PlayerId()), GetPlayerName(PlayerId()))

    SetNuiFocus(true, true)
end

function DisableCharUI() 
    FreezeEntityPosition(pid, false)
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "charUI",
        show = false
    })
    RenderScriptCams(false, 1, 0,  true,  true)
    DestroyCam(charCam, false)
end

RegisterCommand('char', function() 
    EnableCharUI()
    TriggerEvent('vd-inventory:client:clearInv')
end, false)

RegisterCommand('off', function() 
    SetNuiFocus(false, false)
end, false)

AddEventHandler('playerSpawned', function() 
    Wait(10)
    EnableCharUI()
end)

RegisterNUICallback("confirmChar", function(charData) 
    TriggerServerEvent('vd-multicharacter:insertPlayerData', charData)
    Wait(500)
    TriggerServerEvent('vd-multicharacter:getPlayerData', GetPlayerServerId(PlayerId()), GetPlayerName(PlayerId()))
end)

RegisterNUICallback('error', function() 
    VDCore.Notify('FILL IN ALL FIELDS >:(')
end)

RegisterNUICallback("playChar", function(data) 
    TriggerServerEvent('vd-multicharacter:getCurrentPlayerData', GetPlayerServerId(PlayerId()), data.charSlot)
    DisableCharUI()
    SetEntityCoords(PlayerPedId(), 195.08, -933.82, 30.68, false, false, false, true)
    Wait(500)
    TriggerServerEvent('vd-inventory:server:getInventory', VDCore.PlayerData.citizenID)
end)

RegisterNUICallback("deleteChar", function(data) 
    TriggerServerEvent('vd-multicharacter:deleteCharacter', data.charSlot)
    Wait(500)
    TriggerServerEvent('vd-multicharacter:getPlayerData', GetPlayerServerId(PlayerId()), GetPlayerName(PlayerId()))
end)

RegisterNetEvent('vd-multicharacter:sendPlayerData')
AddEventHandler('vd-multicharacter:sendPlayerData', function(data) 
    SendNUIMessage({
        type = "charInfo",
        playerData = data
    })
end)