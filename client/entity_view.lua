
local function DisplayObjectDetails(entity)
    local posX = 0.60
    local posY = 0.02
    local count = 5+4
    local titleSpacing    = 0.05
    local textSpacing     = 0.028
    local titeLeftMargin  = 0.05
    local paddingTop      = 0.02
    local paddingLeft     = 0.005
    local rectWidth       = 0.18
    local heightOfContent = (((count) * textSpacing) + titleSpacing) / count
    local rectHeight      = ((count - 1) * heightOfContent) + paddingTop
    DrawRect(posX + (rectWidth / 2), posY + ((rectHeight / 2) - posY / 2), rectWidth, rectHeight, 11, 11, 11, 200)
  
    local entityModel = GetEntityModel(entity)
    local modelName = Entities[entityModel] or entityModel
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextDropshadow(1.0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextColour(255, 255, 255, 215)
    SetTextJustification(1)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName(modelName)
    SetTextScale(0.50, 0.50)
    EndTextCommandDisplayText(posX + titeLeftMargin, posY)
    posY = posY + titleSpacing
  
  
    local entityCoords = GetEntityCoords(entity)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextDropshadow(1.0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextColour(255, 255, 255, 215)
    SetTextJustification(1)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName("Coords: "..entityCoords)
    SetTextScale(0.35, 0.35)
    EndTextCommandDisplayText(posX + paddingLeft, posY)
    posY = posY + textSpacing
    
  
    local rot = GetEntityRotation(entity)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextDropshadow(1.0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextColour(255, 255, 255, 215)
    SetTextJustification(1)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName("Rotation: "..rot)
    SetTextScale(0.35, 0.35)
    EndTextCommandDisplayText(posX + paddingLeft, posY)
    posY = posY + textSpacing
  
    local heading = GetEntityHeading(entity)
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextDropshadow(1.0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextColour(255, 255, 255, 215)
    SetTextJustification(1)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName("Heading: "..heading)
    SetTextScale(0.35, 0.35)
    EndTextCommandDisplayText(posX + paddingLeft, posY)
    posY = posY + textSpacing
  
    local netID = "Not networked"
    if NetworkGetEntityIsNetworked(entity) then
      netID = NetworkGetNetworkIdFromEntity(entity)
    end
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextDropshadow(1.0, 0, 0, 0, 255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextColour(255, 255, 255, 215)
    SetTextJustification(1)
    BeginTextCommandDisplayText('STRING')
    AddTextComponentSubstringPlayerName("NetID: "..netID)
    SetTextScale(0.35, 0.35)
    EndTextCommandDisplayText(posX + paddingLeft, posY)
    posY = posY + titleSpacing
    
  
    local entityType = GetEntityType(entity)
    if entityType==1 then --Peds
        if GetEntityScript(entity)=="jack-ai_lib" then
            local state = Entity(entity).state.hostageState
            local index = Entity(entity).state.index
            local bank = Entity(entity).state.bank
            local tasks = Entity(entity).state.task
            local currentTask = tasks[1]
            local TaskName = "IDLE"
            if currentTask~=nil then TaskName = currentTask.TASK end
            SetTextScale(0.35, 0.35)
            SetTextFont(4)
            SetTextDropshadow(1.0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextColour(255, 255, 255, 215)
            SetTextJustification(1)
            BeginTextCommandDisplayText('STRING')
            AddTextComponentSubstringPlayerName("State: "..(state or "NIL"))
            SetTextScale(0.35, 0.35)
            EndTextCommandDisplayText(posX + paddingLeft, posY)
            posY = posY + textSpacing
            SetTextScale(0.35, 0.35)
            SetTextFont(4)
            SetTextDropshadow(1.0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextColour(255, 255, 255, 215)
            SetTextJustification(1)
            BeginTextCommandDisplayText('STRING')
            AddTextComponentSubstringPlayerName("Index: "..index)
            SetTextScale(0.35, 0.35)
            EndTextCommandDisplayText(posX + paddingLeft, posY)
            posY = posY + textSpacing
            SetTextScale(0.35, 0.35)
            SetTextFont(4)
            SetTextDropshadow(1.0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextColour(255, 255, 255, 215)
            SetTextJustification(1)
            BeginTextCommandDisplayText('STRING')
            AddTextComponentSubstringPlayerName("Bank: "..bank)
            SetTextScale(0.35, 0.35)
            EndTextCommandDisplayText(posX + paddingLeft, posY)
            posY = posY + textSpacing
            SetTextScale(0.35, 0.35)
            SetTextFont(4)
            SetTextDropshadow(1.0, 0, 0, 0, 255)
            SetTextEdge(1, 0, 0, 0, 255)
            SetTextColour(255, 255, 255, 215)
            SetTextJustification(1)
            BeginTextCommandDisplayText('STRING')
            AddTextComponentSubstringPlayerName("Task: " ..TaskName)
            SetTextScale(0.35, 0.35)
            EndTextCommandDisplayText(posX + paddingLeft, posY)
            posY = posY + textSpacing
        end
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextDropshadow(1.0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextColour(255, 255, 255, 215)
        SetTextJustification(1)
        BeginTextCommandDisplayText('STRING')
        AddTextComponentSubstringPlayerName("Entity: "..entity)
        SetTextScale(0.35, 0.35)
        EndTextCommandDisplayText(posX + paddingLeft, posY)
        posY = posY + textSpacing
    end
    if entityType==2 then --Vehicles
    end
    if entityType==3 then --Object, Door, pickup
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextDropshadow(1.0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextColour(255, 255, 255, 215)
        SetTextJustification(1)
        BeginTextCommandDisplayText('STRING')
        AddTextComponentSubstringPlayerName("Press F to use gizmos")
        SetTextScale(0.35, 0.35)
        EndTextCommandDisplayText(posX + paddingLeft, posY)
        posY = posY + textSpacing

        if IsControlJustReleased(2, 145) then
            --need to know name of object in config
            exports["jack-objectspawn_lib"]:useGizmo(entity)
        end

        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextDropshadow(1.0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextColour(255, 255, 255, 215)
        SetTextJustification(1)
        BeginTextCommandDisplayText('STRING')
        AddTextComponentSubstringPlayerName("Press G to save to Config")
        SetTextScale(0.35, 0.35)
        EndTextCommandDisplayText(posX + paddingLeft, posY)
        posY = posY + textSpacing

        if IsControlJustReleased(2, 183) then
            --need to know name of object in config
            --save object details to config
            local input = lib.inputDialog('Config Object', {
                {type = 'input', label = 'Object index', description = 'Ex: policeClosedProps', required = true},
                {type = 'input', label = 'Sub index (if necessary)', description = 'Ex: doorTape'},
            })
            if input then
                print(input[1])
                print(input[2])
                --tell config editor script to save this info
                TriggerEvent("jack-bankrobbery:client:saveObjectDetailsToConfig", entity, input[1], input[2])
            end
        end

        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextDropshadow(1.0, 0, 0, 0, 255)
        SetTextEdge(1, 0, 0, 0, 255)
        SetTextColour(255, 255, 255, 215)
        SetTextJustification(1)
        BeginTextCommandDisplayText('STRING')
        AddTextComponentSubstringPlayerName("Press H to Copy Model Name")
        SetTextScale(0.35, 0.35)
        EndTextCommandDisplayText(posX + paddingLeft, posY)
        posY = posY + textSpacing
        if IsControlJustReleased(2, 74) then
            lib.setClipboard(modelName)
            lib.notify({
                title="Copied "..modelName.." to clipboard!",
                description="",
                type='success',
                showDuration=false,
              })
        end
    end
  end

  local RotationToDirection = function(rotation)
    local adjustedRotation = {
        x = (math.pi / 180) * rotation.x,
        y = (math.pi / 180) * rotation.y,
        z = (math.pi / 180) * rotation.z
    }
    local direction = {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)),
        z = math.sin(adjustedRotation.x)
    }
    return direction
  end
  
  local function RayCastGamePlayCamera(distance)
    local currentCam = false
    if not IsGameplayCamRendering() then
      currentCam = GetRenderingCam()
    end
  
    local camRot = not currentCam and GetGameplayCamRot(2) or GetCamRot(currentCam, 2)
    local camPos = not currentCam and GetGameplayCamCoord() or GetCamCoord(currentCam)
    local direction = RotationToDirection(camRot)
    local destination = {
      x = camPos.x + direction.x * distance,
      y = camPos.y + direction.y * distance,
      z = camPos.z + direction.z * distance
    }
    local _, b, c, _, e = GetShapeTestResult(StartShapeTestRay(camPos.x, camPos.y, camPos.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, c, e
  end
  
  local objectRaycastEnabled = false
  local hitObject
  local rayColor = {r=255,g=255,b=255,a=0.4}
  RegisterNetEvent("jack-objectspawner_lib:client:showObjectRaycast", function(bankTable)
    objectRaycastEnabled = not objectRaycastEnabled
    CreateThread(function()
      while objectRaycastEnabled do
        local pos = GetEntityCoords(PlayerPedId())
        local hit, endCoords, entityHit = RayCastGamePlayCamera(1000.0)
        DrawLine(pos.x, pos.y, pos.z, endCoords.x, endCoords.y, endCoords.z, rayColor.r, rayColor.g, rayColor.b, rayColor.a)
        DrawSphere(endCoords.x, endCoords.y, endCoords.z, 0.05, rayColor.r, rayColor.g, rayColor.b, 0.5)
        Wait(20)
        if hit and (IsEntityAVehicle(entityHit) or IsEntityAPed(entityHit) or IsEntityAnObject(entityHit)) then
          hitObject = entityHit
          rayColor = { r = 0, g = 255, b = 0, a = 0.7 }
          DisplayObjectDetails(hitObject)
        else
            hitObject = nil
            rayColor = { r = 255, g = 255, b = 255, a = 0.4 }
        end
      end
    end)
  end)
  