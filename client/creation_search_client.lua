--Find an entity (create locally or networked if not found)
RegisterNetEvent("jack-objectspawner_lib:client:registerExistingObject", function (modelName, position, canCreateIfMissing, registerNetworked, completeFunc)
    local entity = ConsistentGetClosestObject(position, modelName)
    if not IDExists(entity) then
        if canCreateIfMissing then
            if registerNetworked then
                lib.callback("jack-objectspawner_lib:server:createObject", false, function(netID)
                    local entity = GetEntityFromNetID(netID, modelName)
                    if entity and IDExists(entity) then
                        print("\n[registerExistingObject]->[createObject]: Server creates " , modelName, ", ", netID.."\n")
                        SetEntityAsMissionEntity(entity, true, true)
                        SetNetworkIdExistsOnAllMachines(netID, true)
                        SetNetworkIdCanMigrate(netID, true)
                        NetworkSetObjectForceStaticBlend(entity, true)
                        if position.w~=nil then
                            SetEntityHeading(entity, position.w)
                        end
                        FreezeEntityPosition(entity, true)
                        if registerNetworked then
                            if not NetworkGetEntityIsNetworked(entity) then
                                NetworkRegisterEntityAsNetworked(entity)
                                local net = GetNetIDFromEntity(entity)
                                if net then
                                    SetNetworkIdExistsOnAllMachines(net, true)
                                    SetNetworkIdCanMigrate(net, true)
                                    NetworkSetObjectForceStaticBlend(entity, true)
                                    SetEntityAsMissionEntity(entity, true, true)
                                    TriggerServerEvent("jack-objectspawner_lib:server:setEntityRotationRPC", net, position.w, nil)
                                end
                            end
                        end
                        if completeFunc then
                            completeFunc(entity)
                        end
                    end
                end, modelName, position)
            else
                --create locally
                local model = joaat(modelName)
                lib.requestModel(model)

                local object = CreateObjectNoOffset(model, position.x, position.y, position.z, false, false, false)
                SetEntityAsMissionEntity(object, true, true)
                if position.w~=nil then
                    SetEntityHeading(object, position.w)
                end
                FreezeEntityPosition(object, true)
                if completeFunc then
                    completeFunc(object)
                end
            end
          
        else
            warn("\n Couldnt find entity and not creating it")
        end
    else
        if registerNetworked then
            if not NetworkGetEntityIsNetworked(entity) then
                NetworkRegisterEntityAsNetworked(entity)
                local net = GetNetIDFromEntity(entity)
                if net then
                    SetNetworkIdExistsOnAllMachines(net, true)
                    SetNetworkIdCanMigrate(net, true)
                    NetworkSetObjectForceStaticBlend(entity, true)
                    SetEntityAsMissionEntity(entity, true, true)
                    TriggerServerEvent("jack-objectspawner_lib:server:setEntityRotationRPC", net, position.w, nil)
                end
            end
        end
        FreezeEntityPosition(entity, true)
        SetEntityAsMissionEntity(entity, true, true)
        if completeFunc then
            completeFunc(entity)
        end
    end
end)


--RPC needed for client to check if dedicated host is aware of entity
lib.callback.register("jack-objectspawner_lib:client:doesEntityExist", function(entityNetID)
    local entity = GetEntityFromNetID(entityNetID)
    if not entity then return false end
    return true
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
RegisterNetEvent("jack-objectspawner_lib:client:createObject", function(modelName, position, completeFunc)
    local entity = ConsistentGetClosestObject(position, modelName)
    if not IDExists(entity) then
         --create locally
         local model = joaat(modelName)
         lib.requestModel(model)

         local object = CreateObjectNoOffset(model, position.x, position.y, position.z, false, false, false)
         SetEntityAsMissionEntity(object, true, true)
         if position.w~=nil then
             SetEntityHeading(object, position.w)
         end
         FreezeEntityPosition(object, true)
         if completeFunc then
             completeFunc(object)
         end
    else
        warn("\n[createObject]: Object: " .. modelName .. " already exists. Do not create..\n")
        if completeFunc then
            completeFunc(entity)
        end
    end
end)

