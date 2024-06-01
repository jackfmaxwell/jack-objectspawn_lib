
RegisterNetEvent("jack-objectspawner_lib:client:registerExistingObject", function (modelName, position, completeFunc)
    local entity = GetClosestObjectOfType(position.x, position.y, position.z, 0.2, GetHashKey(modelName), false, false, false)
    Wait(1)
    if entity == 0 then
        error("Could not find entity for model : " .. modelName .."\n Ensure the modelname is correct for the existing prop.", 2)
        RequestModel(GetHashKey(modelName))
        while not HasModelLoaded(GetHashKey(modelName)) do
            Wait(0)
        end
        local createdObj = CreateObject(GetHashKey(modelName), position.x, position.y, position.z, true, true, false)
        Wait(1)
        if not NetworkGetEntityIsNetworked(createdObj) then
            NetworkRegisterEntityAsNetworked(createdObj)
        end
        FreezeEntityPosition(createdObj, true)
        completeFunc(createdObj)
        return
    end
    if not NetworkGetEntityIsNetworked(entity) then
        NetworkRegisterEntityAsNetworked(entity)
    end
    FreezeEntityPosition(entity, true)
    completeFunc(entity)
    return
end)
RegisterNetEvent("jack-objectspawner_lib:client:deleteObject", function (modelName, position)
    local entity = GetClosestObjectOfType(position.x, position.y, position.z, 0.2, GetHashKey(modelName), false, false, false)
    Wait(1)
    if entity~=0 then
        SetEntityAsMissionEntity(entity, false, false)
        DeleteObject(entity)
    end
end)
RegisterNetEvent("jack-objectspawner_lib:client:createObject", function(modelName, position, completeFunc)
    local entity = GetClosestObjectOfType(position.x, position.y, position.z, 0.2, GetHashKey(modelName), false, false, false)
    Wait(1)
    if entity == 0 then
        RequestModel(GetHashKey(modelName))
        while not HasModelLoaded(GetHashKey(modelName)) do
            Wait(0)
        end
        local createdObj = CreateObject(GetHashKey(modelName), position.x, position.y, position.z, true, true, false)
        Wait(1)
        if not NetworkGetEntityIsNetworked(createdObj) then
            NetworkRegisterEntityAsNetworked(createdObj)
        end
        SetEntityHeading(createdObj, position.w)
        FreezeEntityPosition(createdObj, true)
        print("Created object: " .. modelName)
        completeFunc(createdObj)
        return
    end
    warn("Object: " .. modelName .. " already exists..")
    completeFunc(entity)
    return
end)

RegisterNetEvent("jack-objectspawner_lib:client:setDoorState", function(doorName, model, pos, lock)
    if not IsDoorRegisteredWithSystem(doorName) then
        print("Add door " .. doorName .." to system")
        AddDoorToSystem(doorName, GetHashKey(model), pos.x, pos.y, pos.z, false, false, false)
    end
    Wait(1)
    print("Set door " .. doorName .. " state: " , lock and "4" or "0")
    DoorSystemSetDoorState(doorName, lock and 4 or 0, false, true)
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
end)
