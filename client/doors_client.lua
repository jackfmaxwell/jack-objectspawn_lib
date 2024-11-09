
---DOORS
RegisterNetEvent("jack-objectspawner_lib:client:setDoorState", function(doorName, model, pos, lock)
    TriggerServerEvent("jack-objectspawner_lib:server:setDoorState", doorName, model, pos, lock)
 end)
 RegisterNetEvent("jack-objectspawner_lib:client:setDoorStateRPC", function(doorName, model, pos, lock)
     local entity = ConsistentGetClosestObject(pos, model, 0.2, 3.0)
     Wait(1)
     if not IsDoorRegisteredWithSystem(doorName) then
         if IDExists(entity) then
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
         if IDExists(entity) then
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
 