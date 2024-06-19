
function ConsistentGetClosestObject(position, modelName, range, iteration, timesFound)
    if not iteration then iteration = 0 end
    if not timesFound then timesFound = 0 end
    if iteration>=10 then print("Didnt find: ", modelName) return nil end
    Wait(10)
    local entity = GetClosestObjectOfType(position.x, position.y, position.z, range, GetHashKey(modelName), false, false, false)
    Wait(10)
    if entity==0 then
        Wait(50)
        return ConsistentGetClosestObject(position, modelName, range, iteration+1, timesFound)
    else
        timesFound+=1
        if timesFound>=3 then print("Found: ", modelName,  " ", entity) return entity
        else return ConsistentGetClosestObject(position, modelName, range, iteration, timesFound) end
    end
end
function ConsistentDeleteObject(modelName, entity, iteration)
    if not iteration then iteration = 0 end
    if iteration>=5 then return nil end
    SetEntityAsMissionEntity(entity, false, false)
    DeleteObject(entity)
    Wait(50)
    if DoesEntityExist(entity) and entity~=0 and entity~=nil then
        ConsistentDeleteObject(modelName, entity, iteration+1)
    else
        print("Delete executed for ", modelName, " ", entity)
    end
end

RegisterNetEvent("jack-objectspawner_lib:client:registerExistingObject", function (modelName, position, completeFunc) -- createIfCantFind
    local entity = ConsistentGetClosestObject(position, modelName, 0.5)
    if entity == 0 or entity==nil then
        warn("Could not find entity for model : " .. modelName .." Ensure the modelname is correct for the existing prop.")
        RequestModel(GetHashKey(modelName))
        while not HasModelLoaded(GetHashKey(modelName)) do
            Wait(0)
        end
        entity = CreateObject(GetHashKey(modelName), position.x, position.y, position.z, true, true, true)
        Wait(1)
        if position.w~=nil then
            SetEntityHeading(entity, position.w)
        end
        print("Created object (defunk): " .. modelName)
    end
    if not NetworkGetEntityIsNetworked(entity) then
        NetworkRegisterEntityAsNetworked(entity)
    end
    FreezeEntityPosition(entity, true)
    completeFunc(entity)
end)
RegisterNetEvent("jack-objectspawner_lib:client:registerExistingObjectWithRotation", function (modelName, position, rotation, completeFunc) -- createIfCantFind
    local entity = ConsistentGetClosestObject(position, modelName, 0.5)
    if entity == 0 or entity==nil then
        warn("Could not find entity for model : " .. modelName .." Ensure the modelname is correct for the existing prop.")
        RequestModel(GetHashKey(modelName))
        while not HasModelLoaded(GetHashKey(modelName)) do
            Wait(0)
        end
        entity = CreateObject(GetHashKey(modelName), position.x, position.y, position.z, true, true, true)
        Wait(1)
        SetEntityRotation(entity, rotation.x, rotation.y, rotation.z, 2, true)
        print("Created object (defunk): " .. modelName)
    end
    SetEntityRotation(entity, rotation.x, rotation.y, rotation.z, 2, true)
    if not NetworkGetEntityIsNetworked(entity) then
        NetworkRegisterEntityAsNetworked(entity)
    end
    FreezeEntityPosition(entity, true)
    completeFunc(entity)
end)

RegisterNetEvent("jack-objectspawner_lib:client:deleteObject", function (modelName, position)
    print("Deleting ", modelName, "...")
    local entity = ConsistentGetClosestObject(position, modelName, 0.5)
    if entity~=0 and entity~=nil then
        ConsistentDeleteObject(modelName, entity)
    end
end)
RegisterNetEvent("jack-objectspawner_lib:client:deleteAllPropsInArea", function (modelName, position, complete)
    print("Searching for  ", modelName, "...")
    local entity = ConsistentGetClosestObject(position, modelName, 10.0)
    if entity~=0 and entity~=nil then
        ConsistentDeleteObject(modelName, entity)
    end
    complete()
end)


RegisterNetEvent("jack-objectspawner_lib:client:createObject", function(modelName, position, completeFunc)
    print("Called to create: " , modelName)
    local entity = ConsistentGetClosestObject(position, modelName, 0.2)
    if entity == 0 or entity==nil then
        RequestModel(GetHashKey(modelName))
        while not HasModelLoaded(GetHashKey(modelName)) do
            Wait(0)
        end
        entity = CreateObject(GetHashKey(modelName), position.x, position.y, position.z, true, true, true)
        Wait(1)
        
        if not NetworkGetEntityIsNetworked(entity) then
            NetworkRegisterEntityAsNetworked(entity)
        end
        
        if position.w~=nil then
            SetEntityRotation(entity, 0.0, 0.0, position.w, 2, true)
        end
        FreezeEntityPosition(entity, true)
        print("Created object: " .. modelName)
    else
        warn("Object: " .. modelName .. " already exists..")
    end
    completeFunc(entity)
end)
RegisterNetEvent("jack-objectspawner_lib:client:createObjectWithRotation", function(modelName, position, rotation, completeFunc)
    print("Called to create: " , modelName)
    local entity = ConsistentGetClosestObject(position, modelName, 0.2)
    if entity == 0 or entity==nil then
        RequestModel(GetHashKey(modelName))
        while not HasModelLoaded(GetHashKey(modelName)) do
            Wait(0)
        end
        entity = CreateObject(GetHashKey(modelName), position.x, position.y, position.z, true, true, true)
        Wait(1)
        
        if not NetworkGetEntityIsNetworked(entity) then
            NetworkRegisterEntityAsNetworked(entity)
        end
        
      
        SetEntityRotation(entity, rotation.x, rotation.y, rotation.z, 2, true)
    
        FreezeEntityPosition(entity, true)
        print("Created object: " .. modelName)
    else
        warn("Object: " .. modelName .. " already exists..")
    end
    completeFunc(entity)
end)

RegisterNetEvent("jack-objectspawner_lib:client:setDoorState", function(doorName, model, pos, lock)
    local entity = 0
    if not IsDoorRegisteredWithSystem(doorName) then
        print("Add door " .. doorName .." to system")
        entity = GetClosestObjectOfType(pos.x, pos.y, pos.z, 5.0, GetHashKey(model), false, false, false)
        Wait(1)
        if entity~=0 then
            local exactCoords = GetEntityCoords(entity)
            AddDoorToSystem(doorName, GetHashKey(model), exactCoords.x, exactCoords.y, exactCoords.z, false, false, false)
        else
            warn("Could not find door ", doorName, " near position: ", pos)
        end

    end
    Wait(1)
    print("Set door " .. doorName .. " state: " , lock and "4" or "0")
    DoorSystemSetDoorState(doorName, lock and 4 or 3, false, true)
end)



-- object placing view for deving?
RegisterCommand('testPlaceObject',function(source, args, rawCommand)
    local objectName = args[1] or "prop_bench_01a"
    local playerPed = PlayerPedId()
    local offset = GetOffsetFromEntityInWorldCoords(playerPed, 0, 1.0, 0)

    local model = joaat(objectName)
    lib.requestModel(model, 5000)

    local object = CreateObject(model, offset.x, offset.y, offset.z, false, false, false)

    local objectPositionData = exports["jack-objectspawn_lib"]:useGizmo(object) --export for the gizmo. just pass an object handle to the function.
    
    print(json.encode(objectPositionData, { indent = true }))
    DeleteEntity(objectPositionData.handle)
end, false)
