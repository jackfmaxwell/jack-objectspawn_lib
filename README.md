# Object Spawner Library Resource

This is an object spawner library meant to be used by your scripts during runtime as a way to have more consistent object creation, deletion, and existence. 

Note this also contains my entity view tool for bank script and a UI for bank config creation (wip). Please remove if unneeded

![image](https://github.com/jackfmaxwell/jack-objectspawn_lib/assets/34254615/e99165d5-4b74-4383-b00c-acfcccf458bb)

#### 

Entity view is modified from https://github.com/qbcore-framework/qb-adminmenu (GPL 3.0)

Gizmos is modified from https://github.com/Demigod916/object_gizmo (GPL 3.0)


Checkout my tebex store:
https://jack-scripts.tebex.io/


***

### No Dependencies (in runtime)

The entity view dev tool pictured above requires ox lib for the lib menus when saving to config

***

### Available methods
#### Register Existing Object
###### Register Existing Object
*"jack-objectspawner_lib:client:registerExistingObject"*

**Params**:
- modelName (must be string version of name, not hashkey)
- position (Can be vector3 or vector4)
- completeFunc (Inline function that is called with entity as argument when event is complete)

**Description**:
Finds an existing entity with modelName at position. If the entity is not found then ask server to create it, then return that created entity.

**Example Use**:

        TriggerEvent("jack-objectspawner_lib:client:registerExistingObject", Config.Banks[CurrentBank]["objects"]["vaultDoor"]["model"], vaultPos, function(vault)
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

###### Register Existing Object Do Not Create
*"jack-objectspawner_lib:client:registerExistingObject_DoNotCreate"*

**Params**:
- modelName (must be string version of name, not hashkey)
- position (Can be vector3 or vector4)
- completeFunc (Inline function that is called with entity as argument when event is complete)
  
**Description**:
Finds the entity with modelName at position and calls completeFunc(entity) when complete

**Example Use**:

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
  
###### Register Existing Object With Rotation
*"jack-objectspawner_lib:client:registerExistingObjectWithRotation"*

**Params**:
- modelName (must be string version of name, not hashkey)
- position (Can be vector3 or vector4)
- rotation (vector3, if only have heading can pass it through the .w of a position vector and leave rotation nil)
- completeFunc (Inline function that is called with entity as argument when event is complete)

**Description**:
Finds an existing entity with modelName at position. If the entity is not found then ask server to create it and apply a rotation to the created object, then return that created entity.
Rotation is applied through an RPC ("jack-objectspawner_lib:server:setEntityRotationRPC" -> "jack-objectspawner_lib:client:setEntityRotation")

**Example Use**:

        TriggerEvent("jack-objectspawner_lib:client:registerExistingObjectWithRotation", model, pos, rot, function(entity)
                local id = exports.ox_target:addEntity(
                    NetworkGetNetworkIdFromEntity(entity),
                    {
                        icon="fa-solid fa-shield-alt",
                        label="Hit Teller Panic",
                        name=CurrentBank.."panicButton",
                        distance = 1.5,
                        canInteract = function()
                            return true
                        end,
                        onSelect = function ()
                                --implementation
                        end,
                    }
                )
            end)

#### Delete Object
###### Delete Object
*"jack-objectspawner_lib:client:deleteObject"*

**Params**:
- modelName (must be string version of name, not hashkey)
- position (Can be vector3 or vector4)

**Description**:
Finds an existing object with modelName and position. If it exists and is networked, tell the server to delete it. If it is not networked, try to delete it locally. 

**Example Use**:

        TriggerEvent("jack-objectspawner_lib:client:deleteObject", modelName, position)

###### Delete All Props In Area
*"jack-objectspawner_lib:client:deleteAllPropsInArea"*

**Params**:
- dedicatedHostNum (int) (Specific variable for my bank script. You will see its use in description. Ideally this function is not highly coupled, I will revisit this)
- modelName (must be string version of name, not hashkey)
- position (Can be vector3 or vector4)
- completeFunc (Inline function that is called with entity as argument when event is complete)
  
**Description**:
Finds an existing entity with model and position. We enter a loop where we repeatedly try a deletion and then check again if there are still any props in this area with this model. 

If the found entity is networked. 
        If we are the dedicated host
                Tell the server to delete the object, if the server deletion failed then reduce an attempt counter (only 3 attempts)
        If we are not the dedicated host
                Leave the object. In the bank script players can walk into the bank and will need to delete any local props but not delete the newly created synced props that the dedicated host created initally. So instead we ask the dedicated host (using number to call their client) if they are aware of this entity by this netID. 
                        If they are not, we can delete it because its just strangely networked but only appearing for us.
                        If they are, do not touch it, this is the entity we will use for our interactions (in bank script)
The entity found is not networked.
        Try a local deletion and reset the failed attempts counter.

After loop completes. Ask if the entity still exists
        If so, we failed to delete all the props, try one last local attempt
        If not, success

**Example Use**:

        local numberOfReturns = #possibleLeftoverProps
        --spot in vault is an arbitray spot, I check with a distance of 40.0 so it should be good to start anywhere in bank
        for i, propname in ipairs(possibleLeftoverProps) do
            TriggerEvent("jack-objectspawner_lib:client:deleteAllPropsInArea", iamDedicatedHost, propname, spotInVault, function()
                numberOfReturns-=1
                if numberOfReturns <= 0 then
                    continue=true
                end
            end)
        end

        --this block allows me to stall until all the props are delete
        local timer = 20*1000
        while timer>0 do
            if continue then break end
            Wait(1) --stop execution until props are all deleted
            timer-=1
        end

***

### Dev Tools / Debugging

Entity view tool

Gizmos

Save to clipboard

***

### Performance
#### IDLE
![alt text](image.png)
#### ACTIVE (Only active while script is creating objects and initializing zones)
