VDCore = nil
godmodeEnabled = false

while VDCore == nil do 
    TriggerEvent('vd-core:getSharedObject', function(obj) VDCore = obj end)
end

_menuPool = NativeUI.CreatePool()
mainMenu = NativeUI.CreateMenu("Admin Menu", "", 1400, 100, 'shopui_title_sm_hangar', 'shopui_title_sm_hangar')
_menuPool:Add(mainMenu)

function addAdminOptions(menu)
    local adminOptionsMenu = _menuPool:AddSubMenu(menu, "Admin Options", '', true, true)
    adminOptionsMenu.Title:Text("Admin Options")

    local selfOptionsMenu = _menuPool:AddSubMenu(adminOptionsMenu, "Self Options", '', true, true)
    adminOptionsMenu.Title:Text("Self Options")

    local noclipItem = NativeUI.CreateItem("Noclip", "")
    noclipItem:RightLabel('~m~OFF')
    noclipItem.Activated = function() 
        if noclipItem:RightLabel() == '~m~OFF' then 
            noclipItem:RightLabel('~w~ON')
        else 
            noclipItem:RightLabel('~m~OFF')
        end
    end

    local reviveItem = NativeUI.CreateItem("Revive", "")
    reviveItem.Activated = function() 
        VDCore.Revive(PlayerPedId())
    end

    local invisibilityItem = NativeUI.CreateItem("Invisible", "")
    invisibilityItem:RightLabel('~m~OFF')
    invisibilityItem.Activated = function() 
        if invisibilityItem:RightLabel() == '~m~OFF' then 
            invisibilityItem:RightLabel('~w~ON')
            SetEntityVisible(PlayerPedId(), false)
        else 
            invisibilityItem:RightLabel('~m~OFF')
            SetEntityVisible(PlayerPedId(), true)
        end
    end

    local godmodeItem = NativeUI.CreateItem("Godmode", "")
    godmodeItem:RightLabel('~m~OFF')
    godmodeItem.Activated = function() 
        if godmodeItem:RightLabel() == '~m~OFF' then 
            godmodeItem:RightLabel('~w~ON')
            godmodeEnabled = true
        else 
            godmodeItem:RightLabel('~m~OFF')
            godmodeEnabled = false
        end
    end

    local showPlayernamesItem = NativeUI.CreateItem("Show Playernames", "")
    showPlayernamesItem:RightLabel('~m~OFF')
    showPlayernamesItem.Activated = function() 
        if showPlayernamesItem:RightLabel() == '~m~OFF' then 
            showPlayernamesItem:RightLabel('~w~ON')
            VDCore.togglePlayernames()
        else 
            showPlayernamesItem:RightLabel('~m~OFF')
            VDCore.togglePlayernames()
        end
    end

    selfOptionsMenu:AddItem(noclipItem)
    selfOptionsMenu:AddItem(godmodeItem)
    selfOptionsMenu:AddItem(invisibilityItem)
    selfOptionsMenu:AddItem(reviveItem)
    adminOptionsMenu:AddItem(showPlayernamesItem)
end

function addPlayerManagement(menu)
    local pOptionsMenu = _menuPool:AddSubMenu(menu, "Player Options", '', true, true)
    pOptionsMenu.Title:Text("Player Options")

    allPlayers = VDCore.GetPlayers()
    for i,v in pairs(allPlayers) do
        local id = GetPlayerServerId(allPlayers[i])
        local playerName = GetPlayerName(allPlayers[i])
        local playerMenu = _menuPool:AddSubMenu(pOptionsMenu, "#" .. id .. " | " .. playerName, "", true, true)



        local gotoPlayerItem = NativeUI.CreateItem("Go to player", '')
        gotoPlayerItem.Activated = function() 
            VDCore.Game.Notify('Teleported to ' .. playerName)
        end

        local bringPlayerItem = NativeUI.CreateItem("Bring player", '')
        bringPlayerItem.Activated = function() 
            VDCore.Game.Notify('Brought ' .. playerName)
        end

        local clothingItem = NativeUI.CreateItem("Give clothing menu", '')
        clothingItem.Activated = function() 
            VDCore.Game.Notify('Gave clothing menu to ' .. playerName)
        end

        playerMenu:AddItem(gotoPlayerItem)
        playerMenu:AddItem(bringPlayerItem)
        playerMenu:AddItem(clothingItem)
    end
end

function addTeleportOptions(menu) 
    local tpOptionsMenu = _menuPool:AddSubMenu(menu, "Teleport Options", '', true, true)
    tpOptionsMenu.Title:Text("Teleport Options")
end

addPlayerManagement(mainMenu)
addTeleportOptions(mainMenu)
addAdminOptions(mainMenu)
_menuPool:RefreshIndex()

RegisterCommand('admin', function() 
    mainMenu:Visible(not mainMenu:Visible())
end, false)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        _menuPool:MouseControlsEnabled (false);
        _menuPool:MouseEdgeEnabled (false);
        _menuPool:ControlDisablingEnabled(false);
        _menuPool:ProcessMenus()

        if godmodeEnabled then 
            SetPlayerInvincible(PlayerId(), true)
        end
    end
end)


