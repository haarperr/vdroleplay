function OnPlayerConnecting(name, setKickReason, deferrals)
    local player = source
    local steamIdentifier
    local ipadress
    local identifiers = GetPlayerIdentifiers(player)
    deferrals.defer()

    Wait(0)

    deferrals.update(string.format("Your Steam ID is being checked."))

    for _, v in pairs(identifiers) do
        if string.find(v, "steam") then
            steamIdentifier = v
            break
        end
    end

    for _, v in pairs(identifiers) do
        if string.find(v, "ip") then
            ipadress = v:gsub("ip:", "")
            break
        end
    end

    Wait(0)

    if not steamIdentifier then
        deferrals.done("You are not connected to Steam.")
    else
        deferrals.done()

        MySQL.Async.fetchAll("SELECT * FROM `vd-permissions` WHERE steam64 = @steam64", {["@steam64"] = steamIdentifier},
        function(result) 
            if result[1] == nil then
                MySQL.Async.fetchAll("INSERT INTO `vd-permissions` (name, steam64, permlevel) VALUES(@name, @steamidentifier, @permlevel)", {["@name"] = name, ["@steamidentifier"] = steamIdentifier, ["@permlevel"] = "user"}, 
                function(result) 
                    print("^2[VD-LOG] ^7Sucessfully inserted new player '" .. name .. "' into the database")
                end)
            else 
                if result[1].name ~= name then
                    MySQL.Async.fetchAll("UPDATE `vd-permissions` SET name = @name WHERE steam64 = @steam64", {['@name'] = name, ["@steam64"] = steamIdentifier}, function(result) 
                        print("^2[VD-LOG] ^7Successfully updated steam name")
                    end)
                else
                    print("^2[VD-LOG] ^7Sucessfully got player permission data")        
                end
            end
        end)
    end

    
end

AddEventHandler("playerConnecting", OnPlayerConnecting)

RegisterNetEvent('vd-core:sendOocMessage')
AddEventHandler('vd-core:sendOocMessage', function(author, message, closestPlayers) 
    for i in pairs(closestPlayers) do
        TriggerClientEvent('vd-core:sendChatMessage', closestPlayers[i], 'ooc', author, message)
    end
end)

RegisterNetEvent('vd-core:server:killPlayer')
AddEventHandler('vd-core:server:killPlayer', function(playerId) 
    TriggerClientEvent('vd-core:client:killPlayer', playerId)
end)

AddEventHandler('chatMessage', function() 
    CancelEvent() 
end)