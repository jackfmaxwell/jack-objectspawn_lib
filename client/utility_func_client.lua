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

function IDExists(id)
    if id~=0 and id~=nil then return true
    else return false end
end
function IAmDedicatedHost(dedicatedHostNum)
    return tonumber(dedicatedHostNum)==GetPlayerServerId(PlayerId())
end

function GetNetIDFromEntity(entity, model)
    if not model then model="unknown" end
    if IDExists(entity) then
        local timer = Config.FindIDExpectedExecutionTime
        CreateThread(function()
            while timer>=-50 do
                timer-=1
                Wait(1)
            end
        end)
        if NetworkGetEntityIsNetworked(entity) then
            while not IDExists(NetworkGetNetworkIdFromEntity(entity)) and timer>0 do
                Wait(Config.LoopTime)
            end
            local foundNetID = NetworkGetNetworkIdFromEntity(entity)
            if IDExists(foundNetID) then
                print("[GetNetIdFromEntity]: Found net: ", NetworkGetNetworkIdFromEntity(entity))
                return NetworkGetNetworkIdFromEntity(entity)
            else
                warn("\n[GetNetIDFromEntity]: Failed to find NetID for: " .. model.."\n")
                return nil
            end
        else
            NetworkRegisterEntityAsNetworked(entity)
            while not IDExists(NetworkGetNetworkIdFromEntity(entity)) and timer>0 do
                Wait(Config.LoopTime)
            end
            local foundNetID = NetworkGetNetworkIdFromEntity(entity)
            if IDExists(foundNetID) then
                print("[GetNetIdFromEntity]: Found net: ", NetworkGetNetworkIdFromEntity(entity))
                return NetworkGetNetworkIdFromEntity(entity)
            else
                warn("\n[GetNetIDFromEntity]: Failed to find NetID for: " .. model.."\n")
                return nil
            end
        end
    else
        warn("\n[GetNetIDFromEntity]: None entity id: " .. model.."\n")
        return nil
    end
end
function GetEntityFromNetID(netID, model)
    if not model then model="unknown" end
    if IDExists(netID) then
        local timer = Config.FindIDExpectedExecutionTime
        CreateThread(function()
            while timer>=-50 do
                timer-=1
                Wait(1)
            end
        end)
        while (NetworkGetEntityFromNetworkId(netID) == nil or NetworkGetEntityFromNetworkId(netID) == 0) and timer>0 do
            Wait(Config.LoopTime)
        end
        local foundEntity = NetworkGetEntityFromNetworkId(netID)
        if not IDExists(foundEntity) then
            warn("Failed to find Entity for: ".. model.."\n")
            return nil
        end
        return foundEntity
    else
        return nil
    end
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

function ConsistentGetClosestObject(data)
    local position = data.position
    local modelName = data.modelName
    local dontSearchPastRange = data.dontSearchPastRange
    local ignoreList = data.ignoreList
    if not position then
        error("[ConsistentGetClosestObject]: NO POSITION FOR: ".. (modelName or "unknown"))
    end
    dontSearchPastRange = tonumber(dontSearchPastRange)
    if not dontSearchPastRange then
        dontSearchPastRange = 200
    end
    local objectPool = GetGamePool("CObject")
    local position = vector3(position.x, position.y, position.z)
    local possibleObjects = {}
    for i=0, #objectPool do
        if GetEntityModel(objectPool[i])==GetHashKey(modelName) then
            local ignore = false
            if ignoreList then
                for _, ignoreEnt in ipairs(ignoreList) do
                    if objectPool[i]==ignoreEnt then
                        ignore = true
                    end
                end
            end
            if not ignore then
                local entityCoords = GetEntityCoords(objectPool[i])
                if #(position-entityCoords) < (dontSearchPastRange) then
                    table.insert(possibleObjects, {obj=objectPool[i], dist=#(position-entityCoords)})
                end
            end
        end
    end
    if #possibleObjects>0 then
        local closestObj = possibleObjects[1].obj
        local closestObjDist = possibleObjects[1].dist
        for _, data in ipairs(possibleObjects) do
            if data.dist<closestObjDist and data.dist<dontSearchPastRange then
                closestObj = data.obj
                closestObjDist=data.dist
            end
        end
        return closestObj
    end
    return nil
end

function ConsistentDeleteObject(modelName, entity)
    if IDExists(entity) then
        SetEntityAsMissionEntity(entity, true, true)
        Wait(10)
        DeleteObject(entity)
        Wait(50) --Wait for delete to process
    end
end
