VDCore = {}
VDCore.PlayerData = {}
VDCore.PlayerData.firstName = ''
VDCore.PlayerData.lastName = ''
VDCore.PlayerData.birthDate = ''
VDCore.PlayerData.gender = ''
VDCore.PlayerData.nationality = ''
VDCore.PlayerData.job = ''
VDCore.PlayerData.cashAmount = ''
VDCore.PlayerData.bankAmount = ''
VDCore.PlayerData.phoneNumber = ''
VDCore.PlayerData.accountNumber = ''
VDCore.PlayerData.citizenID = ''

VDCore.DrawText3Ds = function(x, y, z, text)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

VDCore.DrawText2D = function(x, y, text)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextScale(0.6, 0.6)
    SetTextCentre(true)
    SetTextColour(255, 255, 255, 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    EndTextCommandDisplayText(x, y)
end

VDCore.Notify = function(msg)
    if msg ~= nil then
        TriggerEvent('vd-core:notify', msg)
    end
end

VDCore.loadAnim = function(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(500)
	end
end

VDCore.getClosestVehicle = function(radius) 
    local pos = GetEntityCoords(GetPlayerPed(-1))
    local entityWorld = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, radius, 0.0)   
    local rayHandle = CastRayPointToPoint(pos.x, pos.y, pos.z, entityWorld.x, entityWorld.y, entityWorld.z, 10, GetPlayerPed(-1), 0)
    local _, _, _, _, vehicleHandle = GetRaycastResult(rayHandle)

    --print(vehicleHandle)
    --print(GetVehicleNumberPlateText(vehicleHandle))
    return vehicleHandle
end

VDCore.isRagdoll = false
VDCore.setPedRagdoll = function(bool) 
    if bool then
        VDCore.isRagdoll = true
    else 
        VDCore.isRagdoll = false
    end
end

VDCore.revive = function(ped)
    VDCore.isDead = false
    ClearPedTasksImmediately(ped)
    ClearPedBloodDamage(ped)
    SetEntityInvincible(ped, false)
end

VDCore.GetPlayers = function()
    local players = {}

    for i = 0, 31 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end

VDCore.GetClosestPlayers = function()
    local players = VDCore.GetPlayers()
    local range = 20
    local closestPlayers = {}
    local ply = GetPlayerPed(-1)
    local plyCoords = GetEntityCoords(ply, 0)

    for index, value in ipairs(players) do
        local target = GetPlayerPed(value)
        local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
        local distance = GetDistanceBetweenCoords(targetCoords['x'], targetCoords['y'], targetCoords['z'], plyCoords['x'], plyCoords['y'], plyCoords['z'], true)
        if(distance < range) then
            table.insert(closestPlayers, value)
        end
    end

    return closestPlayers
end

VDCore.tablesize = function(table) 
    local size = 0
    for _ in pairs(table) do size = size + 1 end

    return size
end

VDCore.table_has_value = function(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end

    return false
end

VDCore.sendMessage = function(title, text, r, g, b)
    TriggerEvent('chat:addMessage', {
        args = {title, text},
        template = '<div style="padding: 1.5%; padding-left: 2%; font-size: 90%; display: inline-block; padding-right: 2%; margin-top: 10px; margin-right: 10px; float: left; background-color: rgba(' .. r .. ',' .. g .. ',' .. b .. ', 0.8); text-indent: 0px; box-sizing: border-box; border-radius: 7px;"> <b>{0}</b> {1}</div>',
        multiline = true
    })
end

VDCore.chatNotify = function(type, message)
    if type == 'error' then
        VDCore.sendMessage('ERROR:', message, 174, 34, 34)
    elseif type == 'normal' then
        VDCore.sendMessage('SYSTEM:', message, 215, 122, 16)
    end
end

RegisterNetEvent('vd-multicharacter:recieveCurrentPlayerData')
AddEventHandler('vd-multicharacter:recieveCurrentPlayerData', function(data) 
    VDCore.PlayerData = {}
    VDCore.PlayerData.firstName = data.firstName
    VDCore.PlayerData.lastName = data.lastName
    VDCore.PlayerData.birthDate = data.birthDate
    VDCore.PlayerData.gender = data.gender
    VDCore.PlayerData.nationality = data.nationality
    VDCore.PlayerData.job = data.job
    VDCore.PlayerData.cashAmount = data.cashAmount
    VDCore.PlayerData.bankAmount = data.bankAmount
    VDCore.PlayerData.phoneNumber = data.phoneNumber
    VDCore.PlayerData.accountNumber = data.accountNumber
    VDCore.PlayerData.citizenID = data.citizenID
end)

RegisterNetEvent('vd-core:recievePermissionData')
AddEventHandler('vd-core:recievePermissionData', function(data) 
    
end)