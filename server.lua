--When health is 0 interaction

--Zone interaciton

--State bag initilization

--Physics?
--Pickupable? (Inventory/Carry)
--Interactable when carried?
--Droppable if carry?

lib.callback.register('jack-objectspawner_lib:server:spawnObject', function(source, modelName, position, rotation, networked, saveToDB)
    --request model and has model loaded are only available on client. Do we need to do it from server? If so just use client callback
    RequestModel(GetHashKey(modelName))
    while not HasModelLoaded(GetHashKey(modelName)) do
        Citizen.Wait(1)
    end
    return 0 --return the 
end)