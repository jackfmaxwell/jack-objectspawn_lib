function ValueExists(tbl, value)
    for i = 1, #tbl do
        if tbl[i][1] == value[1] and tbl[i][2] == value[2] then
            return true
        end
    end
    return false
end
function IsModelADoor(value)
    for _, model in ipairs(Config.SpawnedDoorModels) do
        if model == value then
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

RegisterNetEvent("jack-objectspawner_lib:server:setEntityRotationRPC", function (entityNetID, heading, rotation)
    TriggerClientEvent("jack-objectspawner_lib:client:setEntityRotation", -1, entityNetID, heading, rotation)
end)

lib.callback.register("jack-objectspawner_lib:server:doesDedicatdHostKnowEntity", function(source, dedicatedHost, entityNetID)
    print("does dedicated host: ", dedicatedHost, " know about entity: " , entityNetID)
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
        creatingQueue[key]=nil
        alreadyCreated[key]=nil
        --print("deleted ", entityNetID, " ", modelName)
        return true
    else
        --print("didnt find entity for ", entityNetID, " a ", modelName)
        return false
    end
end)

lib.callback.register("jack-objectspawner_lib:server:createObject", function(source, modelName, position)
    local key = modelName..position.x..position.y..position.z
    if alreadyCreated[key]~=nil then
       -- print("already created ", modelName)
        local entity = NetworkGetEntityFromNetworkId(alreadyCreated[key])
        Wait(10)
        if (entity == 0 or entity==nil) or GetHashKey(modelName)~=GetEntityModel(entity) then
            --doesnt exist anymore!
            --print(modelName , " doesnt exist anymore")
            alreadyCreated[key] = nil
            creatingQueue[key] = true
            local doorflag = IsModelADoor(modelName)
            print(modelName, " is door? : ", doorflag)
            local newEntity = CreateObject(GetHashKey(modelName), position.x, position.y, position.z, true, true, doorflag)
            while not DoesEntityExist(newEntity) do
                Wait(10)
            end
            while NetworkGetNetworkIdFromEntity(newEntity)==0 or NetworkGetNetworkIdFromEntity(newEntity)==nil do
                Wait(10)
            end
            local createdObjectNetID = NetworkGetNetworkIdFromEntity(newEntity)
            --print("Created "..modelName.." with netID: ", createdObjectNetID)
            alreadyCreated[key] = createdObjectNetID
            creatingQueue[key]=nil
        end
        return alreadyCreated[key]
    end
    if creatingQueue[key]~=nil then
        while creatingQueue[key]~=nil do
            Wait(500)
        end
        --print('waited for created queue : ', alreadyCreated[key])
        return alreadyCreated[key]
    end
    creatingQueue[key] = true
    local doorflag = IsModelADoor(modelName)
    print(modelName, " is door? : ", doorflag)
    local entity = CreateObjectNoOffset(GetHashKey(modelName), position.x, position.y, position.z, true, true, doorflag)
    while not DoesEntityExist(entity) do
        Wait(10)
    end
    local createdObjectNetID = NetworkGetNetworkIdFromEntity(entity)
    alreadyCreated[key] = createdObjectNetID
    print("Created "..modelName.." with netID: ", createdObjectNetID)
    creatingQueue[key]=nil
    return createdObjectNetID
end)

RegisterNetEvent("jack-objectspawner_lib:server:setDoorState", function(doorName, model, pos, lock)
    --entity = CreateObject(GetHashKey(modelName), position.x, position.y, position.z, true, true, true) HERE?
   -- print("set door state RPC")
    TriggerClientEvent("jack-objectspawner_lib:client:setDoorStateRPC",-1, doorName, model, pos, lock)
end)

lib.addCommand('bankConfigEditor', {
    help = 'dev',
    restricted = 'group.admin'
}, function(source, args, raw)
    TriggerClientEvent("jack-objectspawner_lib:client:showObjectRaycast", tonumber(source))
end)

lib.addCommand('testPrintAllObjects', {
    help = 'dev',
    params = {
        {
            name = 'deleteprops',
            type = 'number',
            help = 'Delete props?',
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    print("delete props: ", args.deleteprops)
    local numberNetObjects = 0
    for _, entity in ipairs(GetAllObjects()) do
        local netID = NetworkGetNetworkIdFromEntity(entity)
        if netID~=0 and netID ~=nil then
            numberNetObjects+=1
            if args.deleteprops==1 then
                DeleteEntity(entity)
            end
            print(netID)
        end
    end
    print("Number net objects: ", numberNetObjects)

    local numberNetPeds = 0
    for _, entity in ipairs(GetAllPeds()) do
        local netID = NetworkGetNetworkIdFromEntity(entity)
        if netID~=0 and netID ~=nil then
            numberNetPeds +=1
        end
    end
    print("Number net peds: ", numberNetPeds)

    local numberNetVehicles = 0
    for _, entity in ipairs(GetAllVehicles()) do
        local netID = NetworkGetNetworkIdFromEntity(entity)
        if netID~=0 and netID ~=nil then
            numberNetVehicles +=1
        end
    end
    print("Number net vehicles: ", numberNetVehicles)
end)