
--Meant to be used during runtime
RegisterNetEvent("jack-objectspawner_lib:client:spawnObject", function(modelName, position, isNetworked, isPersistent, setRotation, hasCollisions, hasPhysics, entityInteractionZone)
    if position==nil then position = GetEntityCoords(PlayerPedId()) end
    RequestModel(GetHashKey(modelName))
    while not HasModelLoaded(GetHashKey(modelName)) do
        Wait(0)
    end
    local objectHandle = CreateObject(GetHashKey(modelName), position.x, position.y, position.z, isNetworked, true, false)
    SetEntityRotation(objectHandle, setRotation.x, setRotation.y, setRotation.z, 2,false)
    SetEntityCollision(objectHandle, hasCollisions, true)
    SetEntityHasGravity(objectHandle, hasPhysics)
    if entityInteractionZone~=nil then
        
    end
    if isPersistent then
        --Add to json to track them after server close and reopen
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
end)
