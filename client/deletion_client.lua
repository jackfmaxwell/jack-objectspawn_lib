
RegisterNetEvent("jack-objectspawner_lib:client:deleteAllPropsInArea", function (dedicatedHostNum, modelName, position, complete)
    local timer = Config.DeletetionExpectedExecutionTime
    CreateThread(function()
        while timer>=-50 do
            timer-=1
            Wait(1)
        end
    end)
    local entity = ConsistentGetClosestObject(position, modelName)
    if IDExists(entity) and entity then
        while IDExists(entity) and (timer>0) do
            if NetworkGetEntityIsNetworked(entity) then
                local netID = GetNetIDFromEntity(entity, modelName)
                if IAmDedicatedHost(dedicatedHostNum) then
                    lib.callback("jack-objectspawner_lib:server:deleteObject", false, function(result)
                        if not result then
                            NetworkUnregisterNetworkedEntity(entity)
                            ConsistentDeleteObject(modelName, entity)
                        else
                            print("\n[deleteAllPropsInArea]: Server deleted ", modelName, " netID:", netID)
                        end
                    end, netID, modelName)
                else
                    --warn("not dedicated host (",dedicatedHostNum,"), dont delete networked object ", modelName,"\n")
                    --ask dedicated host if this entity is visible for them
                    --if entity is not known to them, then we should delete it
                    lib.callback("jack-objectspawner_lib:server:doesDedicatdHostKnowEntity", false, function(result)
                        if not result then --Dedicated host not aware of this object, try local delete
                            NetworkUnregisterNetworkedEntity(entity)
                            ConsistentDeleteObject(modelName, entity)
                        end
                    end, tonumber(dedicatedHostNum), netID)
                    break
                end
            else
                ConsistentDeleteObject(modelName, entity)
            end
            entity = ConsistentGetClosestObject(position, modelName)
            Wait(Config.LoopTime)
        end
    end

    if not IDExists(entity) then
        print("\n[deleteAllPropsInArea]: Deleted all ".. modelName.. " props\n")
    else
        warn("\n[deleteAllPropsInArea]: Entity ("..entity..") exists after delete attempts\n")
    end
    if complete then
        complete()
    end
end)
RegisterNetEvent("jack-objectspawner_lib:client:deleteObject", function (modelName, position)
    local entity = ConsistentGetClosestObject(position, modelName)
    if IDExists(entity) then
        ConsistentDeleteObject(modelName, entity)
    end
end)


RegisterNetEvent("jack-objectspawner_lib:client:deleteEntityRPC", function(entityNetID)
    local entity = GetEntityFromNetID(entityNetID)
    if entity then
        SetEntityAsMissionEntity(entity, true, true)
        NetworkSetObjectForceStaticBlend(entity, true)
        DeleteEntity(entity)

        SetNetworkIdExistsOnAllMachines(entityNetID, true)
        SetNetworkIdCanMigrate(entityNetID, true)
    end
end)