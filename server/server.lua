function ValueExists(tbl, value)
    for i = 1, #tbl do
        if tbl[i][1] == value[1] and tbl[i][2] == value[2] then
            return true
        end
    end
    return false
end
function IndexOf(tbl, value)
    for i = 1, #tbl do
        if tbl[i][1] == value[1] and tbl[i][2] == value[2] then
            return i
        end
    end
    return nil
end

RegisterNetEvent("jack-objectspawner_lib:server:createObjectWithRotation", function(targetNetID, modelName, position, rotation)
    print("Create w rot", modelName)
    TriggerClientEvent("jack-objectspawner_lib:client:createObjectWithRotation", tonumber(targetNetID), modelName, position, rotation)
end)

RegisterNetEvent("jack-objectspawner_lib:server:createObject", function(targetNetID, modelName, position)
    print("Create ", modelName)
    --entity = CreateObject(GetHashKey(modelName), position.x, position.y, position.z, true, true, true) HERE?
    TriggerClientEvent("jack-objectspawner_lib:client:createObject", tonumber(targetNetID), modelName, position)
end)

RegisterNetEvent("jack-objectspawner_lib:server:setEntityRotationRPC", function (entityNetID, heading, rotation)
    TriggerClientEvent("jack-objectspawner_lib:client:setEntityRotation", -1, entityNetID, heading, rotation)
end)

--create queue, and already created
local alreadyCreated = {}
local creatingQueue = {}

lib.callback.register("jack-objectspawner_lib:server:deleteObject", function(source, entityNetID, modelName) --sometimes bankName is string sometimes its cb
    if entityNetID==nil or entityNetID==0 then print("object doesnt have netid") return false end
    local entity = NetworkGetEntityFromNetworkId(entityNetID)
    if entity~=nil and entity~=0 then
        local position = GetEntityCoords(entity)
        local modelName = GetEntityModel(entity)
        local key = modelName..position.x..position.y..position.z
        DeleteEntity(entity)
        creatingQueue[key]=nil
        alreadyCreated[key]=nil
        print("deleted ", entityNetID, " ", modelName)
        return true
    else
        print("didnt find entity for ", entityNetID, " a ", modelName)
        return false
    end
end)

lib.callback.register("jack-objectspawner_lib:server:createObject", function(source, modelName, position) --sometimes bankName is string sometimes its cb
    local key = modelName..position.x..position.y..position.z
    if alreadyCreated[key]~=nil then
        print("already created ", modelName)
        local entity = NetworkGetEntityFromNetworkId(alreadyCreated[key])
        if (entity == 0 or entity==nil) or GetHashKey(modelName)~=GetEntityModel(entity) then
            --doesnt exist anymore!
            alreadyCreated[key]=nil
            creatingQueue[key] = true
            local newEntity = CreateObjectNoOffset(GetHashKey(modelName), position.x, position.y, position.z, true, true, false)
            while not DoesEntityExist(newEntity) do
                Wait(1)
            end
            local createdObjectNetID = NetworkGetNetworkIdFromEntity(newEntity)
            print("Created "..modelName.." with netID: ", createdObjectNetID, " at ", position)
            alreadyCreated[key] = createdObjectNetID
            creatingQueue[key]=nil
        end
        return alreadyCreated[key]
    end
    if creatingQueue[key]~=nil then
        while creatingQueue[key]~=nil do
            Wait(500)
        end
        print('waited for created queue : ', alreadyCreated[key])
        return alreadyCreated[key]
    end
    creatingQueue[key] = true
    local entity = CreateObjectNoOffset(GetHashKey(modelName), position.x, position.y, position.z, true, true, false)
    while not DoesEntityExist(entity) do
        Wait(1)
    end
    local createdObjectNetID = NetworkGetNetworkIdFromEntity(entity)
    alreadyCreated[key] = createdObjectNetID
    print("Created "..modelName.." with netID: ", createdObjectNetID)
    creatingQueue[key]=nil
    return createdObjectNetID
end)

RegisterNetEvent("jack-objectspawner_lib:server:setDoorState", function(doorName, model, pos, lock)
    --entity = CreateObject(GetHashKey(modelName), position.x, position.y, position.z, true, true, true) HERE?
    TriggerClientEvent("jack-objectspawner_lib:client:setDoorStateRPC",-1, doorName, model, pos, lock)
end)

lib.addCommand('bankConfigEditor', {
    help = 'dev',
    restricted = 'group.admin'
}, function(source, args, raw)
    TriggerClientEvent("jack-objectspawner_lib:client:showObjectRaycast", tonumber(source))
end)