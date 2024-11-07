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
function IsModelADoor(value)
    for _, model in ipairs(Config.SpawnedDoorModels) do
        if model == value then
            return true
        end
    end
    return false
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

function ConsistentGetClosestObject(position, modelName)
    local objectPool = GetGamePool("CObject")
    for i=0, #objectPool do
        if #(position-GetEntityCoords(objectPool[i]) < 1 then
            return objectPool[i]
        end
    end
end
function ConsistentDeleteObject(modelName, entity, position)
    if EntityIDExists(entity) then
        SetEntityAsMissionEntity(entity, true, true)
        Wait(10)
        DeleteObject(entity)
        Wait(50) --Wait for delete to process
        if EntityIDExists(ConsistentGetClosestObject(position, modeName)) then
            --Ask server to attempt
        end
    end
end

RegisterNetEvent("jack-objectspawner_lib:client:registerExistingObject_DoNotCreate", function (modelName, position, completeFunc) -- createIfCantFind
    local entity = ConsistentGetClosestObject(position, modelName, 0.2, 1.5)
    if entity == 0 or entity==nil then
        Wait(1000)
        local maxTimeToWait=10*1000
        local distanceRange = {0.2, 5.0}
        local timeBetweenChecks = 1000
        local startRange = 0.2
        local currentTime = 0
        while currentTime<maxTimeToWait and not EntityIDExists(entity) do
            local percentageCompleteTime = currentTime/maxTimeToWait
            local newRange = startRange +
            distanceRange[1] + (distanceRange[2]-distanceRange[1])*percentageCompleteTime
            entity = ConsistentGetClosestObject(position, modelName, newRange)
            print(entity)
            currentTime+=timeBetweenChecks
            Wait(timeBetweenChecks)
        end
        print("After searching: ", entity)
        --out of time or we know the entity now
        if EntityIDExists(entity) then
            --print("Found ", modelName, " after waiting")
            print("\n[registerExistingObject_DoNotCreate]: Found after waiting " ,modelName,"\n")
            if completeFunc then
                completeFunc(entity)
            end
        else
            warn("\n[registerExistingObject_DoNotCreate]: Could not find ", modelName, " after waiting\n")
            if completeFunc then
                completeFunc(nil)
            end
        end
    else
        --print("Found ", modelName)
        print("\n[registerExistingObject_DoNotCreate]: Found " ,modelName, ", ", entity,"\n")
        if completeFunc then
            completeFunc(entity)
        end
    end
end)
function IAmDedicatedHost(dedicatedHostNum)
    return tonumber(dedicatedHostNum)==GetPlayerServerId(PlayerId())
end

local totalTime = 1000
local loopTime = 50
function GetNetIDFromEntity(entity, model)
    if not model then model="unknown" end
    if EntityIDExists(entity) then
        if NetworkGetEntityIsNetworked(entity) then
            local timeout=totalTime
            local success, result = pcall(function ()
                while not NetworkGetEntityIsNetworked(entity) and timeout>0 do
                    Wait(loopTime)
                    timeout-=loopTime
                end
                if timeout<=0 then
                    return nil
                else
                    return NetworkGetNetworkIdFromEntity(entity)
                end
            end)
            if not success then
                warn("\n[GetNetIDFromEntity]: Failed to find NetID for: " .. model.."\n")
                return nil
            else
                return result
            end
        else
            return nil
        end
    else
        return nil
    end
end
function GetEntityFromNetID(netID, model)
    if not model then model="unknown" end
    if EntityIDExists(netID) then
        local timeout = totalTime
        local attempts = 2
        local success, result = pcall(function ()
            while (NetworkGetEntityFromNetworkId(netID) == nil or NetworkGetEntityFromNetworkId(netID) == 0) and timeout>0 and attempts>0 do
                Wait(loopTime)
                timeout-=loopTime
                attempts-=1
            end
            if timeout<=0 then
                return nil
            else
                return NetworkGetEntityFromNetworkId(netID)
            end
        end)
        if not success then
            warn("Failed to find Entity for: ".. model.."\n")
            return nil
        end
        return result
    else
        return nil
    end
end
RegisterNetEvent("jack-objectspawner_lib:client:registerExistingObject", function (modelName, position, completeFunc) -- createIfCantFind
    local entity = ConsistentGetClosestObject(position, modelName, 0.2, 1.5)
    if entity == 0 or entity==nil then
        --Ask server to create
        --print("Ask server to create "..modelName,"...")
        lib.callback("jack-objectspawner_lib:server:createObject", false, function(netID)
            local entity = GetEntityFromNetID(netID, modelName)
            if entity and EntityIDExists(entity) then
                print("\n[registerExistingObject]->[createObject]: Server creates " , modelName, ", ", netID.."\n")
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
            end
        end, modelName, position)
    else
        print("\n[registerExistingObject]: Already found " ,modelName,"\n")
        if completeFunc then
            completeFunc(entity)
        end
    end
end)
RegisterNetEvent("jack-objectspawner_lib:client:setEntityRotation", function(entityNetID, heading, rotation)
    local entity = GetEntityFromNetID(entityNetID)
    if entity then
        SetEntityAsMissionEntity(entity, true, true)
        SetNetworkIdExistsOnAllMachines(entityNetID, true)
        SetNetworkIdCanMigrate(entityNetID, true)
        NetworkSetObjectForceStaticBlend(entity, true)
        if heading~=nil then
            SetEntityHeading(entity, heading)
        end
        if rotation~=nil then
            SetEntityRotation(entity, rotation.x, rotation.y, rotation.z, 2, true)
        end
    end
end)
RegisterNetEvent("jack-objectspawner_lib:client:deleteEntity", function(entityNetID)
    local entity = GetEntityFromNetID(entityNetID)
    if entity then
        SetEntityAsMissionEntity(entity, true, true)
        SetNetworkIdExistsOnAllMachines(entityNetID, true)
        SetNetworkIdCanMigrate(entityNetID, true)
        NetworkSetObjectForceStaticBlend(entity, true)
        DeleteEntity(entity)
    end
end)
--this one works to set rotation for everyone.
RegisterNetEvent("jack-objectspawner_lib:client:registerExistingObjectWithRotation", function (modelName, position, rotation, completeFunc) -- createIfCantFind
    local entity = ConsistentGetClosestObject(position, modelName, 0.2, 1.5)
    if entity == 0 or entity==nil then
        --print("Ask server to create "..modelName, "...")
        lib.callback("jack-objectspawner_lib:server:createObject", false, function(netID)
            --print("Server created " ,modelName,", ", netID)
            local entity = GetEntityFromNetID(netID, modelName)
            if not entity then
                lib.callback("jack-objectspawner_lib:server:deleteObject", false, function(result)
                    if not result then warn("\n[registerExistingObjectWithRotation]->[createObject]->[deleteObject]: Server failed to delete  ".. modelName.. "\n")
                    else return TriggerEvent("jack-objectspawner_lib:client:registerExistingObjectWithRotation", modelName, position, rotation, completeFunc) end
                end, netID, modelName)
            end
            local entity = GetEntityFromNetID(netID, modelName)
            if entity then
                print("\n[registerExistingObject]->[createObject]: Server creates " ,modelName,", ", netID.."\n")
                NetworkRequestControlOfEntity(entity)

                SetEntityAsMissionEntity(entity, true, true)
                SetNetworkIdExistsOnAllMachines(netID, true)
                SetNetworkIdCanMigrate(netID, true)
                NetworkSetObjectForceStaticBlend(entity, true)
                TriggerServerEvent("jack-objectspawner_lib:server:setEntityRotationRPC", netID, position.w, rotation)
                FreezeEntityPosition(entity, true)
            end
            if completeFunc then
                completeFunc(entity)
            end
        end, modelName, position)
    else
        print("\n[registerExistingObjectWithRotation]: Already found " ,modelName,"\n")
        NetworkRegisterEntityAsNetworked(entity)
        if completeFunc then
            completeFunc(entity)
        end
    end
end)

RegisterNetEvent("jack-objectspawner_lib:client:deleteObject", function (modelName, position)
    --print("try delete ", modelName)
    local entity = ConsistentGetClosestObject(position, modelName, 0.2, 1.5)
    if EntityIDExists(entity) then
        local netID = GetNetIDFromEntity(entity, modelName)
        if netID then
            lib.callback("jack-objectspawner_lib:server:deleteObject", false, function(result)
                if not result then warn("\n[deleteObject]: Server failed to delete  ".. modelName.. "\n") end
            end, netID, modelName)
        else
            ConsistentDeleteObject(modelName, entity)
        end
    else
        --print("entity doesnt exist")
    end
end)
lib.callback.register("jack-objectspawner_lib:client:doesEntityExist", function(entityNetID)
    local entity = GetEntityFromNetID(entityNetID)
    if not entity then return false end
    return true
end)
RegisterNetEvent("jack-objectspawner_lib:client:deleteAllPropsInArea", function (dedicatedHostNum, modelName, position, complete)
    local entity = ConsistentGetClosestObject(position, modelName, 40.0)
    local breakLoop = false
    local numberAttemptsLeft = 3
    if EntityIDExists(entity) and entity then
        while EntityIDExists(entity) and not breakLoop and numberAttemptsLeft>0 do
            local netID = GetNetIDFromEntity(entity, modelName)
            if IAmDedicatedHost(dedicatedHostNum) then
                lib.callback("jack-objectspawner_lib:server:deleteObject", false, function(result)
                    if not result then
                        NetworkUnregisterNetworkedEntity(entity)
                        ConsistentDeleteObject(modelName, entity)
                        numberAttemptsLeft-=1
                    else
                        Wait(50)
                        print("\n[deleteAllPropsInArea]: Server deleted ", modelName, " netID:", netID)
                        entity = ConsistentGetClosestObject(position, modelName, 40.0) --fIND NEXT OBJECT
                        numberAttemptsLeft=3
                    end
                end, netID, modelName)
            else
                --warn("not dedicated host (",dedicatedHostNum,"), dont delete networked object ", modelName,"\n")
                --ask dedicated host if this entity is visible for them
                --if entity is not known to them, then we should delete it
                lib.callback("jack-objectspawner_lib:server:doesDedicatdHostKnowEntity", false, function(result)
                    if not result then --Dedicated host not aware of this object, try local delete
                        entity = ConsistentGetClosestObject(position, modelName, 40.0)
                        if entity and DoesEntityExist(entity) then
                            NetworkUnregisterNetworkedEntity(entity)
                            ConsistentGetClosestObject(position, modelName, 40.0)
                        end
                    end
                end, tonumber(dedicatedHostNum), netID)
                break
            end
            Wait(1)
        end
    end
    if not EntityIDExists(entity) then
        --print("Deleted all ".. modelName.. " props\n")
    else
        warn("\n[deleteAllPropsInArea]: Failed to delete  ".. modelName.. " breakLoop: "..(breakLoop and "true" or "false") .. " numberAttemptsLeft: "..numberAttemptsLeft .. "\n")
        if numberAttemptsLeft<=0 then
            entity = ConsistentGetClosestObject(position, modelName, 40.0)
            if entity and DoesEntityExist(entity) then
                NetworkUnregisterNetworkedEntity(entity)
                ConsistentGetClosestObject(position, modelName, 40.0)
            end
            --print("done local deleting")
         
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
            local entity = GetEntityFromNetID(netID, modelName)
            if entity then
                print("\n[client:createObject]->[server:createObject]: Create " ,modelName, ", ",netID,"\n")
                NetworkRequestControlOfEntity(entity)

                --print("Initialize ", modelName)
                SetEntityAsMissionEntity(entity, true, true)
                --SetNetworkIdExistsOnAllMachines(netID, true)
                --SetNetworkIdCanMigrate(netID, true)
                NetworkSetObjectForceStaticBlend(entity, true)
                TriggerServerEvent("jack-objectspawner_lib:server:setEntityRotationRPC", netID, position.w, nil)
                FreezeEntityPosition(entity, true)
            end
            if completeFunc then
                completeFunc(entity)
            end
        end, modelName, position)
    else
        warn("\n[createObject]: Object: " .. modelName .. " already exists. Do not create..\n")
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
            local entity = GetEntityFromNetID(netID, modelName)
            if entity then
                NetworkRequestControlOfEntity(entity)

                -- print("Initialize ", modelName)
                 SetEntityAsMissionEntity(entity, true, true)
                 SetNetworkIdExistsOnAllMachines(netID, true)
                 SetNetworkIdCanMigrate(netID, true)
                 NetworkSetObjectForceStaticBlend(entity, true)
                 TriggerServerEvent("jack-objectspawner_lib:server:setEntityRotationRPC", netID, position.w, rotation)
                 FreezeEntityPosition(entity, true)
            end
            if completeFunc then
                completeFunc(entity)
            end
        end, modelName, position)
    else
        warn("\n[createObjectWithRotation]: Object: " .. modelName .. " already exists. Do not create..\n")
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
            --print("Add door " .. doorName .." to system")
            local exactCoords = GetEntityCoords(entity)
            AddDoorToSystem(doorName, GetHashKey(model), exactCoords.x, exactCoords.y, exactCoords.z, false, false, false)
        else
            warn("\n[setDoorStateRPC]: Could not find door ", doorName, " near position: ", pos.."\n")
            if not lock then
                TriggerEvent("jack-objectspawner_lib:client:deleteObject", model, pos)
            end
        end
    end
    Wait(1)
    DoorSystemSetDoorState(doorName, (lock and 1 or 0), false, false)
    DoorSystemSetOpenRatio(doorName, (0.0), true, true)
    local timer = 3000
    while lock and not IsDoorClosed(doorName) and timer>0 do Wait(30) timer-=30 end
    if not lock and IsModelADoor(model) then
        TriggerEvent("jack-objectspawner_lib:client:deleteObject", model, pos)
    end
    --print("Set door " .. doorName .. " "..model .. " state: " , lock and "1" or "0")
end)

RegisterNetEvent("jack-objectspawner_lib:client:unlockIfHealthDrops", function(doorName, model, pos)
    local entity = ConsistentGetClosestObject(pos, model, 0.2, 3.0)
    Wait(1)
    if not IsDoorRegisteredWithSystem(doorName) then
        if EntityIDExists(entity) then
            --print("Add door " .. doorName .." to system")
            local exactCoords = GetEntityCoords(entity)
            AddDoorToSystem(doorName, GetHashKey(model), exactCoords.x, exactCoords.y, exactCoords.z, false, false, false)
        else
            --warn("Could not find door ", doorName, " near position: ", pos)
        end
    end
    CreateThread(function()
        SetEntityHealth(entity, GetEntityMaxHealth(entity))
        while true do
            Wait(1000*5)
            if GetEntityHealth(entity)<1000 then
                TriggerServerEvent("jack-objectspawner_lib:server:setDoorState", doorName, model, pos, false)
                break
            end
        end
    end)
end)


/*
RegisterCommand('testPlaceObject',function(source, args, rawCommand)
    local start = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 1.0, 0)
    local offset = vector3(0,0,0)
    for i=1, 10, 1 do
        for j=1, 5, 1 do
            offset = vector3(i*0.25, j*0.25, 0)
            lib.callback("jack-objectspawner_lib:server:createObject", false, function(netID)
                print("received: ", netID)
            end, "v_ilev_gb_teldr", (start+offset))
        end
    end
    start = (start+offset+vector3(0,0,3))
    
    for i=1, 10, 1 do
        for j=1, 5, 1 do
            offset = vector3(i*0.25, j*0.25, 0)
            lib.callback("jack-objectspawner_lib:server:createObject", false, function(netID)
                print("received: ", netID)
            end, "v_ilev_gb_teldr", (start+offset))
        end
    end
    start = (start+offset+vector3(0,0,3))
    
    for i=1, 10, 1 do
        for j=1, 5, 1 do
            offset = vector3(i*0.25, j*0.25, 0)
            lib.callback("jack-objectspawner_lib:server:createObject", false, function(netID)
                print("received: ", netID)
            end, "v_ilev_gb_teldr", (start+offset))
        end
    end
    start = (start+offset+vector3(0,0,3))

    for i=1, 10, 1 do
        for j=1, 5, 1 do
            offset = vector3(i*0.25, j*0.25, 0)
            lib.callback("jack-objectspawner_lib:server:createObject", false, function(netID)
                print("received: ", netID)
            end, "v_ilev_gb_teldr", (start+offset))
        end
    end
end, false)
*/


RegisterNetEvent("jack-objectspawner_lib:client:testPlaceObject", function(modelName)
    print("place object")
    local objectName = modelName or "prop_bench_01a"
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
end)