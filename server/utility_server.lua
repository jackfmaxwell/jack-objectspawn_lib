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

AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then
      return
    end
    --cleanup any props we created but have lost contorl of 
    local numberNetObjects = 0
    for _, entity in ipairs(GetAllObjects()) do
        local netID = NetworkGetNetworkIdFromEntity(entity)
        if netID~=0 and netID ~=nil then
            local script = GetEntityScript(entity)
            if script~=nil then
                numberNetObjects+=1
                if script=="jack-objectspawn_lib" then
                    --DeleteEntity(entity)
                end
                
            end
        end
    end
    if numberNetObjects>80 then
        error("\n\nNET OBJECT LIMIT PASSED. CURRENT NUMBER NET OBJECTS: ".. numberNetObjects.. ".\n CRITICAL ERRORS WILL BE ENCOUNTERED AFTER PASSING LIMIT OF 80\n\n", 0)
    end
    if numberNetObjects>60 then
        warn("\n\nFound: ".. numberNetObjects.. " already existing. jack-objectspawn_lib may encounter issues when creating objects as space for new objects is low\n\n")
    end
end)



lib.addCommand('teleportToNetID', {
    help = 'dev',
    params = {
        {
            name = 'netID',
            type = 'number',
            help = 'NetID',
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    TriggerClientEvent("jack-objectspawner_lib:client:teleportToNetID", tonumber(source), args.netID)
end)


lib.addCommand('viewNetIDs', {
    help = 'dev',
    restricted = 'group.admin'
}, function(source, args, raw)
    TriggerClientEvent("jack-objectspawner_lib:client:showAllObjectEntityIDAndNetID", tonumber(source))
end)

lib.addCommand('bankConfigEditor', {
    help = 'dev',
    restricted = 'group.admin'
}, function(source, args, raw)
    TriggerClientEvent("jack-objectspawner_lib:client:showObjectRaycast", tonumber(source))
end)

lib.addCommand('testPlaceObject', {
    help = 'dev',
    params = {
        {
            name = 'model',
            type = 'string',
            help = 'Model name',
        },
    },
    restricted = 'group.admin'
}, function(source, args, raw)
    TriggerClientEvent("jack-objectspawner_lib:client:testPlaceObject", tonumber(source), args.model)
end)

lib.addCommand('showAllNetThings', {
    help = 'dev',
    restricted = 'group.admin'
}, function(source, args, raw)
    local numberNetObjects = 0
    for _, entity in ipairs(GetAllObjects()) do
        local netID = NetworkGetNetworkIdFromEntity(entity)
        if netID~=0 and netID ~=nil then
            numberNetObjects+=1
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

lib.addCommand('showNetObjectsForScripts', {
    help = 'dev',
    restricted = 'group.admin'
}, function(source, args, raw)
    local numberNetObjectsPerScript = {}
    for _, entity in ipairs(GetAllObjects()) do
        local netID = NetworkGetNetworkIdFromEntity(entity)
        if netID~=0 and netID ~=nil then
            local script = GetEntityScript(entity)
            if script~=nil then
                if numberNetObjectsPerScript[script] == nil then
                    numberNetObjectsPerScript[script] = 1
                else
                    numberNetObjectsPerScript[script] = numberNetObjectsPerScript[script]+1
                end
            end
        end
    end
    for script, number in pairs(numberNetObjectsPerScript) do
        print("\n"..script.." has "..number.." networked objects\n")
    end
end)
