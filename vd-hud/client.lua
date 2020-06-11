Citizen.CreateThread(function() 
    local minimap = RequestScaleformMovie("minimap")
    SetRadarBigmapEnabled(true, false)
    Wait(0)
    SetRadarBigmapEnabled(false, false)
    while true do
        Citizen.InvokeNative(0xF6E48914C7A8694E, minimap, 'SETUP_HEALTH_ARMOUR')
        Citizen.InvokeNative(0xC3D0841A0CC546A6,3)
        Citizen.InvokeNative(0xC6796A8FFA375E53 )

        SendNUIMessage({
            type = 'setHealth',
            amount = GetEntityHealth(PlayerPedId()),
            maxHealth = GetEntityMaxHealth(PlayerPedId())
        })

        Wait(0)
    end
end)