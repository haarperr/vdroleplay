VDCore.isDead = false

--VDCore.Game.Revive
VDCore.Revive = function(ped)
    VDCore.isDead = false
    ClearPedTasksImmediately(ped)
    SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()))
    SetPlayerInvincible(PlayerId(), false)
    ClearPedBloodDamage(ped)

    VDCore.Game.SetBodyStatus(100, 100, 0)
end

local tempTimer = Config.RespawnTime
Citizen.CreateThread(function() 
    while true do
        if VDCore.isDead then
            Citizen.Wait(1000)
            tempTimer = tempTimer - 1
        else 
            tempTimer = Config.RespawnTime
        end
        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function() 
    local gotTempTime = false

    while true do
        local pid = PlayerPedId()

        if IsPedFatallyInjured(pid) and not VDCore.isDead then
            x, y, z = table.unpack(GetEntityCoords(pid))
            heading = GetEntityHeading(pid)
            VDCore.setPedRagdoll(true)

            if(GetEntityVelocity(pid)[1] == 0 and GetEntityVelocity(pid)[2] == 0 and GetEntityVelocity(pid)[3] == 0) then

                ClearPedTasksImmediately(pid)   
                NetworkResurrectLocalPlayer(x, y, z, heading, false, false)

                VDCore.setPedRagdoll(false)
                VDCore.isDead = true
                ClearPedTasksImmediately(pid)
                SetEntityHealth(pid, GetEntityMaxHealth(pid)) 
            
                VDCore.loadAnim("mini@cpr@char_b@cpr_def")
                TaskPlayAnim(PlayerPedId(), "mini@cpr@char_b@cpr_def", "cpr_pumpchest_idle", 4.0, 1.0, -1, 1, 0, 0, 0, 0 )
                RemoveAnimDict("mini@cpr@char_b@cpr_def")
            end
        end
    
        if VDCore.isDead then
            SetPlayerInvincible(PlayerId(), true)

            if tempTimer > 0 then
                VDCore.World.DrawText2D(0.49, 0.85, "RESPAWN OVER: ~b~ ".. tempTimer .." ~w~SECONDEN", 4)
            else
                VDCore.World.DrawText2D(0.49, 0.85, "HOUD ~b~E ~w~INGEDRUKT OM TE RESPAWNEN", 4)

                if IsControlPressed(0, 46) then
                    if not gotTempTime then
                        timeNow = tempTimer
                        gotTempTime = true
                    end
                    if IsControlPressed(0, 46) and tempTimer - timeNow <= -3 then
                        VDCore.Revive(PlayerPedId())
                        gotTempTime = false
                    end
                end
            end
        end
        Wait(0)
    end
end)

AddEventHandler('onClientMapStart', function()
	exports.spawnmanager:spawnPlayer()
	Citizen.Wait(2500)
	exports.spawnmanager:setAutoSpawn(false)
end)