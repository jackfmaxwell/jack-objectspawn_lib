function EntityIDExists(id)
    if id~=0 and id~=nil then return true
    else return false end
end


RegisterNetEvent("jack-objectspawner_lib:server:setEntityRotationRPC", function (entityNetID, heading, rotation)
    local entity = NetworkGetEntityFromNetworkId(entityNetID)
    if heading~=nil then
        SetEntityHeading(NetworkGetEntityFromNetworkId(entityNetID), heading)
    end
    if rotation~=nil then
        SetEntityRotation(NetworkGetEntityFromNetworkId(entityNetID), rotation.x, rotation.y, rotation.z, 2, true)
    end
    TriggerClientEvent("jack-objectspawner_lib:client:setEntityRotation", -1, entityNetID, heading, rotation)
end)

lib.callback.register("jack-objectspawner_lib:server:doesDedicatdHostKnowEntity", function(source, dedicatedHost, entityNetID)
    if Config.DebugPoly then print("does dedicated host: ", dedicatedHost, " know about entity: " , entityNetID) end
    local result = lib.callback.await("jack-objectspawner_lib:client:doesEntityExist", dedicatedHost, entityNetID)
    return result
end)

--create queue, and already created
local alreadyCreated = {}
local creatingQueue = {}

lib.callback.register("jack-objectspawner_lib:server:deleteObject", function(source, entityNetID, modelName)
    if entityNetID==nil or entityNetID==0 then print("object doesnt have netid") return false end
    local entity = NetworkGetEntityFromNetworkId(entityNetID)
    if entity~=nil and entity~=0 then
        local position = GetEntityCoords(entity)
        local modelName = GetEntityModel(entity)
        local key = modelName..position.x..position.y..position.z
        DeleteEntity(entity)
        TriggerClientEvent("jack-objectspawner_lib:client:deleteEntityRPC", -1, entityNetID)
        creatingQueue[key]=nil
        alreadyCreated[key]=nil
        if Config.DebugPoly then print("deleted ", entityNetID, " ", modelName) end
        return true
    else
        if Config.DebugPoly then print("didnt find entity for ", entityNetID, " a ", modelName) end
        return false
    end
end)

lib.callback.register("jack-objectspawner_lib:server:createObject", function(source, modelName, position)
    local key = modelName
    if position then
        key = key .. position.x..position.y..position.z
    end
    if Config.DebugPoly then print(modelName, " key: ", key) end
    if alreadyCreated[key]~=nil then
       -- print("already created ", modelName)
        local entity = NetworkGetEntityFromNetworkId(tonumber(alreadyCreated[key]))
        if Config.DebugPoly then print("model ", modelName, " entity: ", entity) end
        if (entity == 0 or entity==nil) or GetHashKey(modelName)~=GetEntityModel(entity) then
            --doesnt exist anymore!
            if Config.DebugPoly then print(modelName , " doesnt exist anymore") end
            TriggerClientEvent("jack-objectspawner_lib:client:deleteEntityRPC", -1, tonumber(alreadyCreated[key]))
            alreadyCreated[key] = nil
            creatingQueue[key] = true
            local doorflag = IsModelADoor(modelName)
            if Config.DebugPoly then  print(modelName, " is door? : ", doorflag) end
            local newEntity = CreateObjectNoOffset(GetHashKey(modelName), position.x, position.y, position.z, true, true, doorflag)
            while not DoesEntityExist(newEntity) do
                Wait(10)
            end
            while NetworkGetNetworkIdFromEntity(newEntity)==0 or NetworkGetNetworkIdFromEntity(newEntity)==nil do
                Wait(10)
            end
            local createdObjectNetID = NetworkGetNetworkIdFromEntity(newEntity)
            if Config.DebugPoly then print("Created "..modelName.." with netID: ", createdObjectNetID) end
            alreadyCreated[key] = createdObjectNetID
            creatingQueue[key]=nil
        end
        if Config.DebugPoly then print("return found ", modelName) end
        return alreadyCreated[key]
    end
    if creatingQueue[key]~=nil then
        while creatingQueue[key]~=nil do
            Wait(500)
        end
        if Config.DebugPoly then print('waited for created queue : ', alreadyCreated[key]) end
        return alreadyCreated[key]
    end
    creatingQueue[key] = true
    local doorflag = IsModelADoor(modelName)
    if Config.DebugPoly then print(modelName, " is door? : ", doorflag) end
    local entity = CreateObjectNoOffset(GetHashKey(modelName), position.x, position.y, position.z, true, true, doorflag)
    while not DoesEntityExist(entity) do
        Wait(10)
    end
    local createdObjectNetID = NetworkGetNetworkIdFromEntity(entity)
    alreadyCreated[key] = createdObjectNetID
    if Config.DebugPoly then print("Created "..modelName.." with netID: ", createdObjectNetID) end
    creatingQueue[key]=nil
    return createdObjectNetID
end)

RegisterNetEvent("jack-objectspawner_lib:server:setDoorState", function(doorName, model, pos, lock)
    --entity = CreateObject(GetHashKey(modelName), position.x, position.y, position.z, true, true, true) HERE?
   -- print("set door state RPC")
    TriggerClientEvent("jack-objectspawner_lib:client:setDoorStateRPC",-1, doorName, model, pos, lock)
end)