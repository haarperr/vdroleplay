RegisterNetEvent('vd-multicharacter:getPlayerData')
AddEventHandler('vd-multicharacter:getPlayerData', function(target, playerName) 
    MySQL.Async.fetchAll("SELECT * FROM `vd-characters` WHERE name = @name", {["@name"] = playerName}, 
    function(result) 
        TriggerClientEvent('vd-multicharacter:sendPlayerData', tonumber(target), result)
    end)
end)

RegisterNetEvent('vd-multicharacter:getCurrentPlayerData')
AddEventHandler('vd-multicharacter:getCurrentPlayerData', function(target, charSlot) 
    playerName = GetPlayerName(source) 
    MySQL.Async.fetchAll("SELECT * FROM `vd-characters` WHERE name = @name AND charSlot = @charSlot", {["@name"] = playerName, ["@charSlot"] = charSlot}, 
    function(result) 
        TriggerClientEvent('vd-multicharacter:recieveCurrentPlayerData', tonumber(target), result[1])
    end)
end)

RegisterNetEvent('vd-multicharacter:insertPlayerData')
AddEventHandler('vd-multicharacter:insertPlayerData', function(charData) 
    steam64 = GetPlayerIdentifiers(source)[1]
    playerName = GetPlayerName(source)          

    if(charData.firstName ~= "Leeg" and charData.lastName ~= "Karakterslot") then
        MySQL.Async.execute("INSERT INTO `vd-characters` (name, steam64, firstName, lastName, birthDate, gender, nationality, phoneNumber, accountNumber, citizenID, charSlot) VALUES(@name, @steam64, @firstName, @lastName, @birthDate, @gender, @nationality, @phoneNumber, @accountNumber, @citizenID, @charSlot)", 
        {["@name"] = playerName, ['@steam64'] = steam64, ['@firstName'] = charData.firstName, ['@lastName'] = charData.lastName, ['@birthDate'] = charData.dateOfBirth, ['@gender'] = charData.gender,
        ['@nationality'] = charData.nationality, ['@phoneNumber'] = charData.phoneNumber, ['@accountNumber'] = charData.accountNumber, ['citizenID'] = charData.citizenID, ['charSlot'] = charData.charSlot}) 
        TriggerEvent('vd-multicharacter:getPlayerData', source, playerName)
    else 
        print("^2[VD-LOG] ^7User " .. playerName .. " tried to create a character with a forbidden name!")
    end
end)  

RegisterNetEvent('vd-multicharacter:deleteCharacter')
AddEventHandler('vd-multicharacter:deleteCharacter', function(charSlot) 
    MySQL.Async.execute("DELETE FROM `vd-characters` WHERE name = @name AND charSlot = @charSlot", {['@name'] = GetPlayerName(source), ['@charSlot'] = charSlot})
end)






