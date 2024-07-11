# Object Spawner Library Resource

This is an object spawner library meant to be used by your scripts during runtime as a way to have more consistent object creation, deletion, and existence. 

![image](https://github.com/jackfmaxwell/jack-objectspawn_lib/assets/34254615/e99165d5-4b74-4383-b00c-acfcccf458bb)


### No Dependencies

### Available methods
#### Register Existing Object
#### Register Existing Object
"jack-objectspawner_lib:client:registerExistingObject" 
Params:
- modelName, position, completeFunc
Description:
Finds an existing entity with modelName at position. If the entity is not found then ask server to create it, then return that created entity.

Example Use:
    TriggerEvent("jack-objectspawner_lib:client:registerExistingObject", dedicatedHostNetID, Config.Banks[CurrentBank]["objects"]["vaultDoor"]["model"], vaultPos, function(vault)
              local openRotation = Config.Banks[CurrentBank]["objects"]["vaultDoor"]["openHeading"]
              local closeRotation = Config.Banks[CurrentBank]["objects"]["vaultDoor"]["closeHeading"]
              if setLocked then
                  warn("SET VAULT LOCKED\n\n")
                  TriggerServerEvent("jack-bankrobbery:server:setVaultDoorHeading", NetworkGetNetworkIdFromEntity(vault), closeRotation)
                  SetEntityHeading(vault, closeRotation)
              else
                  warn("SET VAULT OPEN\n\n")
                  TriggerServerEvent("jack-bankrobbery:server:setVaultDoorHeading",  NetworkGetNetworkIdFromEntity(vault), openRotation)
                  SetEntityHeading(vault, openRotation)
              end
          end)

#### Register Existing Object Do Not Create
"jack-objectspawner_lib:client:registerExistingObject_DoNotCreate" 
Params:
- modelName, position, completeFunc
Description:
Finds the entity with modelName at position and calls completeFunc(entity) when complete

Example Use:

    TriggerEvent("jack-objectspawner_lib:client:registerExistingObject_DoNotCreate", model, pos, function(innerGate)
      local id = exports.ox_target:addSphereZone({
                    coords = pos,
                    radius = 0.5,
                    debug = Config.DebugPoly,
                    options = {
                        {
                            items="thermite",
                            name="plantExposiveinnerGate"..CurrentBank,
                            canInteract = function()
                                return true
                            end,
                            onSelect = function ()
                                --implementation
                            end,
                            icon="fa-solid fa-vault",
                            label="Plant explosive",
                        }
                    
                    }
                })
    end)
  



### Dev Tools / Debugging

Entity view tool
Gizmos
Save to clipboard

### Performance
#### IDLE
![image](https://github.com/jackfmaxwell/jack-objectspawn_lib/assets/34254615/5fce9626-2392-42e5-bce3-cfb371ae9b56)
#### ACTIVE (Only active while script is creating objects and initializing zones


