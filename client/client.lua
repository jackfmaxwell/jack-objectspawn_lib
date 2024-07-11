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

function VectorLength3D(vec)
    local x = vec.x
    local y = vec.y
    local z = vec.z
    return math.sqrt(x * x + y * y + z * z)
end

function EntityIDExists(id)
    if id~=0 and id~=nil then return true
    else return false end
end

function SerializeTable(tbl, indent, visited)
    visited = visited or {}
    indent = indent or 0
    local result = {}
    local padding = string.rep("  ", indent)

    if visited[tbl] then
        return "<circular reference>"
    end
    visited[tbl] = true

    table.insert(result, "{\n")

    for key, value in pairs(tbl) do
        local formattedKey = (type(key) == "string" and string.format("%q", key)) or (tostring(key))
        local formattedValue

        if type(value) == "table" then
            formattedValue = SerializeTable(value, indent + 1, visited)
        elseif type(value) == "string" then
            formattedValue = string.format("%q", value)
        else
            formattedValue = tostring(value)
        end

        table.insert(result, padding .. "  [" .. formattedKey .. "] = " .. formattedValue .. ",\n")
    end

    table.insert(result, padding .. "}")
    return table.concat(result)
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
        local distance = (vector3(position.x, position.y, position.z)-GetEntityCoords(entity))
        if (distance.x == 0 and distance.y==0) or range>=3.0 then
            timesFound+=1
            if timesFound>=1 then return entity
            else return ConsistentGetClosestObject(position, modelName, range2, nil, iteration+1, timesFound) end
        else
            Wait(10)
            return ConsistentGetClosestObject(position, modelName, range2, nil, (iteration+1), timesFound)
        end
    end
end
function ConsistentDeleteObject(modelName, entity, iteration)
    if not iteration then iteration = 0 end
    if iteration>=3 then warn("Couldnt local delete ", modelName) return false end --tried 3 times didnt work, give up
    SetEntityAsMissionEntity(entity, true, true)
    Wait(10)
    DeleteObject(entity)
    Wait(50) --Wait for delete to process
    if DoesEntityExist(entity) and EntityIDExists(entity) and GetEntityModel(entity)==GetHashKey(modelName) then --Still exists? try again
        ConsistentDeleteObject(modelName, entity, iteration+1)
    else
        return true
    end
end

RegisterNetEvent("jack-objectspawner_lib:client:registerExistingObject_DoNotCreate", function (modelName, position, completeFunc) -- createIfCantFind
    local entity = ConsistentGetClosestObject(position, modelName, 0.2, 1.5)
    if entity == 0 or entity==nil then
        local timeToWait=4*1000
        local range = 0.2
        local rangeIncrease=0.5
        local numberIncreases=0
        while timeToWait>0 and not EntityIDExists(entity) do
            entity = ConsistentGetClosestObject(position, modelName,range+rangeIncrease*numberIncreases)
            numberIncreases+=1
            timeToWait-=100
            Wait(100)
        end
        --out of time or we know the entity now
        if EntityIDExists(entity) then
            print("Found ", modelName, " after waiting")
            if completeFunc then
                completeFunc(entity)
            end
        else
            warn("Could not find ", modelName, " after waiting")
            if completeFunc then
                completeFunc(nil)
            end
        end
    else
        print("Found ", modelName)
        if completeFunc then
            completeFunc(entity)
        end
    end
end)
RegisterNetEvent("jack-objectspawner_lib:client:registerExistingObject", function (modelName, position, completeFunc) -- createIfCantFind
    local entity = ConsistentGetClosestObject(position, modelName, 0.2, 1.5)
    if entity == 0 or entity==nil then
        --Ask server to create
        print("Ask server to create "..modelName,"...")
        lib.callback("jack-objectspawner_lib:server:createObject", false, function(netID)
            print("Server creates " ,modelName,", ", netID)
            local timeout = 4*1000
            while (NetworkGetEntityFromNetworkId(netID) == nil or NetworkGetEntityFromNetworkId(netID) == 0) and timeout>0 do
                Wait(1000)
                timeout-=1000
            end
            local entity = NetworkGetEntityFromNetworkId(netID)
            NetworkRequestControlOfEntity(entity)
            while not NetworkHasControlOfEntity(entity) do
                Wait(1)
            end
            SetEntityAsMissionEntity(entity, true, true)
            SetNetworkIdExistsOnAllMachines(netID, true)
            SetNetworkIdCanMigrate(netID, true)
            NetworkSetObjectForceStaticBlend(entity, true)
            if position.w~=nil then
                SetEntityHeading(entity, position.w)
            end
            FreezeEntityPosition(entity, true)
            if completeFunc then
                completeFunc(entity)
            end
        end, modelName, position)
    else
        if completeFunc then
            completeFunc(entity)
        end
    end
end)
RegisterNetEvent("jack-objectspawner_lib:client:setEntityRotation", function(entityNetID, heading, rotation)
    local timeout = 4*1000
    while (NetworkGetEntityFromNetworkId(entityNetID) == nil or NetworkGetEntityFromNetworkId(entityNetID) == 0) and timeout>0 do
        Wait(1000)
        timeout-=1000
    end
    if (NetworkGetEntityFromNetworkId(entityNetID) == nil or NetworkGetEntityFromNetworkId(entityNetID) == 0) then
        return
    end
    local entity = NetworkGetEntityFromNetworkId(entityNetID)
    SetEntityAsMissionEntity(entity, true, true)
    SetNetworkIdExistsOnAllMachines(entityNetID, true)
    SetNetworkIdCanMigrate(entityNetID, true)
    NetworkSetObjectForceStaticBlend(entity, true)
    if heading~=nil then
        SetEntityHeading(NetworkGetEntityFromNetworkId(entityNetID), heading)
    end
    if rotation~=nil then
        SetEntityRotation(NetworkGetEntityFromNetworkId(entityNetID), rotation.x, rotation.y, rotation.z, 2, true)
    end
end)
--this one works to set rotation for everyone.
RegisterNetEvent("jack-objectspawner_lib:client:registerExistingObjectWithRotation", function (modelName, position, rotation, completeFunc) -- createIfCantFind
    local entity = ConsistentGetClosestObject(position, modelName, 0.2, 1.5)
    if entity == 0 or entity==nil then
        print("Ask server to create "..modelName, "...")
        lib.callback("jack-objectspawner_lib:server:createObject", false, function(netID)
            print("Server created " ,modelName,", ", netID)
            local timeout = 4*1000
            while (NetworkGetEntityFromNetworkId(netID) == nil or NetworkGetEntityFromNetworkId(netID) == 0) and timeout>0 do
                Wait(1000)
                timeout-=1000
            end
            if (NetworkGetEntityFromNetworkId(netID) == nil or NetworkGetEntityFromNetworkId(netID) == 0) then
                lib.callback("jack-objectspawner_lib:server:deleteObject", false, function(result)
                    if not result then warn("Server failed to delete  ".. modelName.. "")
                    else return TriggerEvent("jack-objectspawner_lib:client:registerExistingObjectWithRotation", modelName, position, rotation, completeFunc) end
                end, netID, modelName)
            end
            print(NetworkGetEntityFromNetworkId(netID) , " from ", netID, " for ", modelName)
            local entity = NetworkGetEntityFromNetworkId(netID)
            NetworkRequestControlOfEntity(entity)
            while not NetworkHasControlOfEntity(entity) do
                Wait(1)
            end
            SetEntityAsMissionEntity(entity, true, true)
            SetNetworkIdExistsOnAllMachines(netID, true)
            SetNetworkIdCanMigrate(netID, true)
            NetworkSetObjectForceStaticBlend(entity, true)

            TriggerServerEvent("jack-objectspawner_lib:server:setEntityRotationRPC", netID, position.w, rotation)

            FreezeEntityPosition(entity, true)
            if completeFunc then
                completeFunc(entity)
            end
        end, modelName, position)
    else
        NetworkRegisterEntityAsNetworked(entity)
        if completeFunc then
            completeFunc(entity)
        end
    end
end)

RegisterNetEvent("jack-objectspawner_lib:client:deleteObject", function (modelName, position)
    print("try delete")
    local entity = ConsistentGetClosestObject(position, modelName, 0.2, 1.5)
    if EntityIDExists(entity) then
        local tryLocal = false
        if NetworkGetEntityIsNetworked(entity) then
            local netID = NetworkGetNetworkIdFromEntity(entity)
            if NetworkDoesEntityExistWithNetworkId(netID) then
                lib.callback("jack-objectspawner_lib:server:deleteObject", false, function(result)
                    if not result then warn("Server failed to delete  ".. modelName.. "") end
                end, NetworkGetNetworkIdFromEntity(entity), modelName)
            else tryLocal=true end
        else tryLocal = true end
        if tryLocal then
            ConsistentDeleteObject(modelName, entity)
        end
    end
end)
lib.callback.register("jack-objectspawner_lib:client:doesEntityExist", function(entityNetID)
    if not EntityIDExists(entityNetID) then return false end -- just checks if id is nil or 0
    if not NetworkDoesEntityExistWithNetworkId(entityNetID) then return false end
    local entity = NetworkGetEntityFromNetworkId(entityNetID)
    Wait(1)
    if not EntityIDExists(entity) then return false end
    return true
end)
RegisterNetEvent("jack-objectspawner_lib:client:deleteAllPropsInArea", function (dedicatedHost, modelName, position, complete)
    local entity = ConsistentGetClosestObject(position, modelName, 40.0)
    local breakLoop = false
    local numberAttemptsLeft = 3
    if not EntityIDExists(entity) then
    end
    while EntityIDExists(entity) and not breakLoop and numberAttemptsLeft>0 do
        local tryLocal = false
        if NetworkGetEntityIsNetworked(entity) then
            local netID = NetworkGetNetworkIdFromEntity(entity)
            if NetworkDoesEntityExistWithNetworkId(netID) then
                if dedicatedHost then
                    lib.callback("jack-objectspawner_lib:server:deleteObject", false, function(result)
                        if not result then NetworkUnregisterNetworkedEntity(entity) numberAttemptsLeft-=1
                        else
                            Wait(50)
                            print("Server deleted ", modelName, " netID:", netID)
                            entity = ConsistentGetClosestObject(position, modelName, 40.0)
                        end
                    end, netID, modelName)
                else
                    warn("not dedicated host, dont delete networked object ", modelName,"\n")
                    --ask dedicated host if this entity is visible for them
                    --if entity is not known to them, then we should delete it
                    lib.callback("jack-objectspawner_lib:server:doesDedicatdHostKnowEntity", false, function(result)
                        if not result then
                            entity = ConsistentGetClosestObject(position, modelName, 40.0)
                            while DoesEntityExist(entity) do
                                NetworkUnregisterNetworkedEntity(entity)
                                if not ConsistentDeleteObject(modelName, entity) then break
                                else print("Backup Local deleted ", modelName) end
                                entity = ConsistentGetClosestObject(position, modelName, 40.0)
                            end
                            print("done local deleting")
                        end
                    end, dedicatedHost, netID)
                    break
                end
            else tryLocal=true end
        else tryLocal=true end
        if tryLocal then
            numberAttemptsLeft=3
            if not ConsistentDeleteObject(modelName, entity) then breakLoop=true
            else print("Local deleted ", modelName) end
            Wait(10)
            entity = ConsistentGetClosestObject(position, modelName, 40.0)
        end
        Wait(1)
    end
    if not EntityIDExists(entity) then
        print("Deleted all ".. modelName.. " props\n")
    else
        warn("Failed to delete  ".. modelName.. " breakLoop: "..(breakLoop and "true" or "false") .. " numberAttemptsLeft: "..numberAttemptsLeft .. "\n")
        if numberAttemptsLeft<=0 then
            entity = ConsistentGetClosestObject(position, modelName, 40.0)
            while DoesEntityExist(entity) do
                NetworkUnregisterNetworkedEntity(entity)
                if not ConsistentDeleteObject(modelName, entity) then break
                else print("Backup Local deleted ", modelName) end
                entity = ConsistentGetClosestObject(position, modelName, 40.0)
            end
            print("done local deleting")
         
        end
    end
    if complete then
        complete()
    end
end)


RegisterNetEvent("jack-objectspawner_lib:client:createObject", function(modelName, position, completeFunc)
    local entity = ConsistentGetClosestObject(position, modelName, 0.2, 1.5)
    if not EntityIDExists(entity) then
        lib.callback("jack-objectspawner_lib:server:createObject", false, function(netID)
            print("Server creates " ,modelName,", ", netID)
            while NetworkGetEntityFromNetworkId(netID) == nil or NetworkGetEntityFromNetworkId(netID) == 0 do
                Wait(100)
            end
            local entity = NetworkGetEntityFromNetworkId(netID)
            NetworkRequestControlOfEntity(entity)
            while not NetworkHasControlOfEntity(entity) do
                Wait(1)
            end
            print("Initialize ", modelName)
            SetEntityAsMissionEntity(entity, true, true)
            SetNetworkIdExistsOnAllMachines(netID, true)
            SetNetworkIdCanMigrate(netID, true)
            NetworkSetObjectForceStaticBlend(entity, true)

            TriggerServerEvent("jack-objectspawner_lib:server:setEntityRotationRPC", netID, position.w, nil)
            FreezeEntityPosition(entity, true)

            if completeFunc then
                completeFunc(entity)
            end
        end, modelName, position)
    else
        warn("Object: " .. modelName .. " already exists..")
        if completeFunc then
            completeFunc(entity)
        end
    end
end)

--Create with rotation needs to RPC the setentity rotation?
RegisterNetEvent("jack-objectspawner_lib:client:createObjectWithRotation", function(modelName, position, rotation, completeFunc)
    local entity = ConsistentGetClosestObject(position, modelName, 0.2, 1.5)
    if not EntityIDExists(entity) then
        lib.callback("jack-objectspawner_lib:server:createObject", false, function(netID)
            print("Server creates " ,modelName,", ", netID)
            while NetworkGetEntityFromNetworkId(netID) == nil or NetworkGetEntityFromNetworkId(netID) == 0 do
                Wait(1)
            end
            local entity = NetworkGetEntityFromNetworkId(netID)
            NetworkRequestControlOfEntity(entity)
            while not NetworkHasControlOfEntity(entity) do
                Wait(1)
            end
            print("Initialize ", modelName)
            SetEntityAsMissionEntity(entity, true, true)
            SetNetworkIdExistsOnAllMachines(netID, true)
            SetNetworkIdCanMigrate(netID, true)
            NetworkSetObjectForceStaticBlend(entity, true)

            TriggerServerEvent("jack-objectspawner_lib:server:setEntityRotationRPC", netID, position.w, rotation)

            FreezeEntityPosition(entity, true)
            if completeFunc then
                completeFunc(entity)
            end
        end, modelName, position)
    else
        warn("Object: " .. modelName .. " already exists..")
        if completeFunc then
            completeFunc(entity)
        end
    end
end)

RegisterNetEvent("jack-objectspawner_lib:client:setDoorState", function(doorName, model, pos, lock)
   TriggerServerEvent("jack-objectspawner_lib:server:setDoorState", doorName, model, pos, lock)
end)
RegisterNetEvent("jack-objectspawner_lib:client:setDoorStateRPC", function(doorName, model, pos, lock)
    local entity = ConsistentGetClosestObject(pos, model, 0.2, 3.0)
    Wait(1)
    if not IsDoorRegisteredWithSystem(doorName) then
        if EntityIDExists(entity) then
            print("Add door " .. doorName .." to system")
            local exactCoords = GetEntityCoords(entity)
            AddDoorToSystem(doorName, GetHashKey(model), exactCoords.x, exactCoords.y, exactCoords.z, false, false, false)
        else
            warn("Could not find door ", doorName, " near position: ", pos)
            if not lock then
                TriggerEvent("jack-objectspawner_lib:client:deleteObject", model, pos)
            end
        end
    end
    Wait(1)
    DoorSystemSetDoorState(doorName, (lock and 1 or 0), false, false)
    while lock and not IsDoorClosed(doorName) do Wait(1) end
    if not lock and model=="v_ilev_gb_teldr" then --not proper door object
        TriggerEvent("jack-objectspawner_lib:client:deleteObject", model, pos)
    end
    print("Set door " .. doorName .. " "..model .. " state: " , lock and "1" or "0")
end)

RegisterNetEvent("jack-objectspawner_lib:client:unlockIfHealthDrops", function(doorName, model, pos)
    local entity = ConsistentGetClosestObject(pos, model, 0.2, 3.0)
    Wait(1)
    if not IsDoorRegisteredWithSystem(doorName) then
        if EntityIDExists(entity) then
            print("Add door " .. doorName .." to system")
            local exactCoords = GetEntityCoords(entity)
            AddDoorToSystem(doorName, GetHashKey(model), exactCoords.x, exactCoords.y, exactCoords.z, false, false, false)
        else
            warn("Could not find door ", doorName, " near position: ", pos)
        end
    end
    CreateThread(function()
        SetEntityHealth(entity, GetEntityMaxHealth(entity))
        while true do
            Wait(5000)
            if GetEntityHealth(entity)<1000 then
                TriggerServerEvent("jack-objectspawner_lib:server:setDoorState", doorName, model, pos, false)
                break
            end
        end
    end)
end)


RegisterCommand('testPlaceObject',function(source, args, rawCommand)
    local objectName = args[1] or "prop_bench_01a"
    local playerPed = PlayerPedId()
    local offset = GetOffsetFromEntityInWorldCoords(playerPed, 0, 1.0, 0)

    local model = joaat(objectName)
    lib.requestModel(model, 5000)

    local object = CreateObject(model, offset.x, offset.y, offset.z, false, false, false)
    
    local objectPositionData = exports["jack-objectspawn_lib"]:useGizmo(object) --export for the gizmo. just pass an object handle to the function.
    local positionandrotation = {}
    positionandrotation["position"] = vector3(objectPositionData["position"].x, objectPositionData["position"].y, objectPositionData["position"].z)
    positionandrotation["rotation"] = vector3(objectPositionData["rotation"].x, objectPositionData["rotation"].y, objectPositionData["rotation"].z)
    if positionandrotation["rotation"].x ==0 and positionandrotation["rotation"].y ==0 then
        positionandrotation["rotiation"] = nil
        positionandrotation["position"] = vector4(positionandrotation["position"].x, positionandrotation["position"].y, positionandrotation["position"].z, objectPositionData["rotation"].z)
    end
    lib.setClipboard(SerializeTable(positionandrotation))
    
    lib.notify({
      title="Copied data to clipboard!",
      description="Paste in correct place in config to save",
      type='success',
      showDuration=false,
    })

    print(json.encode(positionandrotation, { indent = true }))
    DeleteEntity(objectPositionData.handle)
end, false)
