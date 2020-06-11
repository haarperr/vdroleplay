local isDoingAction = false
local isCancelled = false

RegisterNetEvent('vd-progressbar:client:startProgressBar')
AddEventHandler('vd-progressbar:client:startProgressBar', function(title, duration, cb) 
    if isDoingAction == false then 
        SendNUIMessage({
            type = 'progressBar',
            title = title,
            duration = duration * 1000
        })
        isDoingAction = true
    else 
        VDCore.Game.Notify('Je bent al met iets bezig!')
        return
    end

    while(isDoingAction) do 
        Wait(0)
    end

    if not isCancelled then 
        VDCore.consumeLatestUsedItem()
    end

    cb(isCancelled)
    isCancelled = false
end)

RegisterNUICallback('finishAction', function(data, cb) 
    isDoingAction = false
end)

RegisterNUICallback('cancelAction', function(data, cb) 
    isCancelled = true
    isDoingAction = false
end)

Citizen.CreateThread(function() 
    while true do 
        if(isDoingAction) then 
            if IsControlJustPressed(0, 200) or IsControlJustPressed(0, 194) then 
                SendNUIMessage({
                    type = 'cancelProgressBar'
                })
            end
        end
        Wait(0)
    end
end)


