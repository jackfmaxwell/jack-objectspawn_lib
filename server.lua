RegisterNetEvent("jack-objectspawner_lib:server:createObjectWithRotation", function(targetNetID, modelName, position, rotation)
    print("Create w rot", modelName)
    TriggerClientEvent("jack-objectspawner_lib:client:createObjectWithRotation", tonumber(targetNetID), modelName, position, rotation)
end)

RegisterNetEvent("jack-objectspawner_lib:server:createObject", function(targetNetID, modelName, position)
    print("Create ", modelName)
    TriggerClientEvent("jack-objectspawner_lib:client:createObject", tonumber(targetNetID), modelName, position)
end)