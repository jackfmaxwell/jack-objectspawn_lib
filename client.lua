function VectorLength3D(vec)
    local x = vec.x
    local y = vec.y
    local z = vec.z
    return math.sqrt(x * x + y * y + z * z)
end

function ConsistentGetClosestObject(position, modelName, range, range2, iteration, timesFound)
    if not iteration then iteration = 0 end
    if not timesFound then timesFound = 0 end
    if not range2 then range2=range end
    if iteration>=3 then return nil end
    local entity = GetClosestObjectOfType(position.x, position.y, position.z, range, GetHashKey(modelName), false, false, false)
    Wait(10) --let GetClosestObjectOfType return
    if entity==0 then --didnt find anything. wait some time and then try again
        Wait(10)
        return ConsistentGetClosestObject(position, modelName, range2, nil, (iteration+1), timesFound)
    else --found it
        timesFound+=1
        if timesFound>=1 then return entity
        else return ConsistentGetClosestObject(position, modelName, range2, nil, iteration+1, timesFound) end
    end
end
function ConsistentDeleteObject(modelName, entity, iteration)
    if not iteration then iteration = 0 end
    if iteration>=3 then warn("Couldnt delete ", modelName) return nil end --tried 3 times didnt work, give up
    SetEntityAsMissionEntity(entity, false, false)
    DeleteObject(entity)
    Wait(50) --Wait for delete to process
    if DoesEntityExist(entity) and entity~=0 and entity~=nil then --Still exists? try again
        print("Deleted ", modelName, " but still exists")
        ConsistentDeleteObject(modelName, entity, iteration+1)
    else
        print(GetPlayerServerId(PlayerId()), " deleted ", modelName)
    end
end

RegisterNetEvent("jack-objectspawner_lib:client:registerExistingObject", function (sourceCreator, modelName, position, completeFunc) -- createIfCantFind
    local entity = ConsistentGetClosestObject(position, modelName, 0.2, 1.5)
    if entity == 0 or entity==nil then
        TriggerServerEvent("jack-objectspawner_lib:server:createObject", tonumber(sourceCreator), modelName, position)
        --Wait until object is created
        local timeToWait=2*1000
        while timeToWait>0 and (entity==0 or entity==nil) do
            entity = ConsistentGetClosestObject(position, modelName, 0.2, 1.5)
            timeToWait-=100
            Wait(100)
        end
        --out of time or we know the entity now
        if entity~=0 and entity~=nil then
            print("RegisterExisting ", modelName, " after waiting on ", sourceCreator)
            if completeFunc then
                completeFunc(entity)
            end
        else
            warn("Could not find ", modelName, " after waiting for ", sourceCreator, "'s creation\n")
            RequestModel(GetHashKey(modelName))
            while not HasModelLoaded(GetHashKey(modelName)) do
                Wait(0)
            end
            entity = CreateObject(GetHashKey(modelName), position.x, position.y, position.z, true, true, true)
            Wait(1)
            if position.w~=nil then
                SetEntityHeading(entity, position.w)
            end
            if not NetworkGetEntityIsNetworked(entity) then
                NetworkRegisterEntityAsNetworked(entity)
            end
            FreezeEntityPosition(entity, true)
            print("RegisterExisting ", modelName, " after creating from ", GetPlayerServerId(PlayerId()))
            if completeFunc then
                completeFunc(entity)
            end
        end
    else
        print("RegisterExisting ", modelName, " entity: ", entity)
        if completeFunc then
            completeFunc(entity)
        end
    end
end)
--this one works to set rotation for everyone.
RegisterNetEvent("jack-objectspawner_lib:client:registerExistingObjectWithRotation", function (sourceCreator, modelName, position, rotation, completeFunc) -- createIfCantFind
    local entity = ConsistentGetClosestObject(position, modelName, 0.2, 1.5)
    if entity == 0 or entity==nil then
        warn("(Rot) Could not find entity for model : " .. modelName .." Ensure the modelname is correct for the existing prop.")
        --if entity doesnt exist ask dedicated host to create it
        TriggerServerEvent("jack-objectspawner_lib:server:createObjectWithRotation", tonumber(sourceCreator), modelName, position, rotation)
        --Wait until object is created
        local timeToWait=2*1000
        while timeToWait>0 and (entity==0 or entity==nil) do
            entity = ConsistentGetClosestObject(position, modelName, 0.2, 1.5)
            timeToWait-=100
            Wait(100)
        end
        --out of time or we know the entity now
        if entity~=0 and entity~=nil then
            print("(Rot) RegisterExisting ", modelName, " after waiting on ", sourceCreator)
            if completeFunc then
                completeFunc(entity)
            end
        else
            warn("(Rot) Could not find ", modelName, " after waiting for ", sourceCreator, "'s creation\n")
            RequestModel(GetHashKey(modelName))
            while not HasModelLoaded(GetHashKey(modelName)) do
                Wait(0)
            end
            entity = CreateObject(GetHashKey(modelName), position.x, position.y, position.z, true, true, true)
            Wait(1)
            SetEntityRotation(entity, rotation.x, rotation.y, rotation.z, 2, true)
            if not NetworkGetEntityIsNetworked(entity) then
                NetworkRegisterEntityAsNetworked(entity)
            end
            FreezeEntityPosition(entity, true)
            print("(Rot) RegisterExisting ", modelName, " after creating from ", GetPlayerServerId(PlayerId()))
            if completeFunc then
                completeFunc(entity)
            end
        end
    else
        print("(Rot) RegisterExisting ", modelName)
        if completeFunc then
            completeFunc(entity)
        end
    end
end)
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

RegisterNetEvent("jack-objectspawner_lib:client:deleteObject", function (modelName, position)
    local entity = ConsistentGetClosestObject(position, modelName, 0.2, 1.5)
    if entity~=0 and entity~=nil then
        ConsistentDeleteObject(modelName, entity)
    end
end)
RegisterNetEvent("jack-objectspawner_lib:client:deleteAllPropsInArea", function (modelName, position, complete)
    local entity = ConsistentGetClosestObject(position, modelName, 10.0)
    while entity~=0 and entity~=nil do
        ConsistentDeleteObject(modelName, entity)
        Wait(10)
        entity = ConsistentGetClosestObject(position, modelName, 10.0)
    end
    print("Deleted all ", modelName, " props")
    if complete then
        complete()
    end
end)

local creatingQueue = {}
RegisterNetEvent("jack-objectspawner_lib:client:createObject", function(modelName, position, completeFunc)
    if ValueExists(creatingQueue, {modelName, position}) then
        print(GetPlayerServerId(PlayerId()), " is already creating ", modelName)
        return
    end
    table.insert(creatingQueue, {modelName, position})
    local entity = ConsistentGetClosestObject(position, modelName, 0.2, 1.5)
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
    else
        warn("Object: " .. modelName .. " already exists..")
    end
    print("Created ", modelName)
    if completeFunc then
        completeFunc(entity)
    end

    local index = IndexOf(creatingQueue, {modelName, position})
    if index then
        table.remove(creatingQueue, index)
    end
end)

--Create with rotation needs to RPC the setentity rotation?
RegisterNetEvent("jack-objectspawner_lib:client:createObjectWithRotation", function(modelName, position, rotation, completeFunc)
    if ValueExists(creatingQueue, {modelName, position}) then
        print(GetPlayerServerId(PlayerId()), " is already (Rot) creating ", modelName)
        return
    end
    table.insert(creatingQueue, {modelName, position})
    local entity = ConsistentGetClosestObject(position, modelName, 0.2, 1.5)
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
    else
        warn("Object: " .. modelName .. " already exists..")
    end
    print("(Rot) Created ", modelName)
    if completeFunc then
        completeFunc(entity)
    end
    local index = IndexOf(creatingQueue, {modelName, position})
    if index then
        table.remove(creatingQueue, index)
    end
end)

RegisterNetEvent("jack-objectspawner_lib:client:setDoorState", function(doorName, model, pos, lock)
    local entity = ConsistentGetClosestObject(pos, model, 0.2, 1.5)
    Wait(1)
    if not IsDoorRegisteredWithSystem(doorName) then
        print("Add door " .. doorName .." to system")
        if entity~=0 then
            local exactCoords = GetEntityCoords(entity)
            AddDoorToSystem(doorName, GetHashKey(model), exactCoords.x, exactCoords.y, exactCoords.z, false, false, false)
        else
            warn("Could not find door ", doorName, " near position: ", pos)
        end

    end
    Wait(1)
    print("Set door " .. doorName .. " state: " , lock and "4" or "3")
    DoorSystemSetDoorState(doorName, lock and 4 or 3, false, true)
    if not lock then
        print("unfreeeze ", entity)
        FreezeEntityPosition(entity, false)
    end
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
