local speedfreecammove = 0.02
local speedfreecamrotate = 2.0
local FOV = 50.0
local lightintensity = 400.0
local menufreecam = false

RegisterCommand('rcpclothing', function() 
    local pedx,pedy,pedz = table.unpack(GetEntityCoords(PlayerPedId()))
    cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
    SetCamCoord(cam,pedx+0.3,pedy-2.3,pedz+0.03)
    SetCamRot(cam,-2.0,2.3,-0.03)
    RenderScriptCams(true, true, 500, true, true)
    FreezeEntityPosition(PlayerPedId(),true)
    SetCamFov(cam, 50.0)
    menufreecam = not menufreecam
    SendNUIMessage({showmenu = true})
    SetNuiFocus(true, true)
end, false)

RegisterNUICallback('close', function()
    Close()
end)

function Close()
    RenderScriptCams(false, true, 500, true, true)
    SetCamActive(cam, false)
    DestroyCam(cam, true)
    FreezeEntityPosition(PlayerPedId(),false)
    SendNUIMessage({showmenu = false})
    SetNuiFocus(false,false)
    menufreecam = false
end

function DrawText(text,x,y)
    SetTextScale(0.35,0.35)
    SetTextColor(255,255,255,255)--r,g,b,a
    SetTextCentre(true)--true,false
    SetTextDropshadow(1,0,0,0,200)--distance,r,g,b,a
    SetTextFontForCurrentCommand(0)
    DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)
end

CreateThread( function()
    while true do 
        Wait(0)
        if menufreecam then
            ClearPedTasksImmediately(PlayerPedId(),false,false)
            SetEntityHeading(PlayerPedId(),0)
            if controls then
                DrawText("CTRL + W/A/S/D - Move Camera | CTRL + Spacebar - Move Camera Up | CTRL + Shift - Move Camera Down",0.5,0.02)
                DrawText("CTRL + Q/E - Change Field Of View | CTRL + Arrow Keys - Rotate Camera | Escape - Exit",0.5,0.04)
                DrawText("CTRL + Z/X - Change Camera Movement Speed | CTRL + C/V - Change Camera Rotation Speed",0.5,0.06)
                DrawText("CTRL + H - Toggle Light | CTRL + [/] - Change Light Intensity | CTRL + T - Toggle This Text",0.5,0.08)
            end
            local pedx,pedy,pedz = table.unpack(GetEntityCoords(PlayerPedId()))
            local x,y,z = table.unpack(GetCamCoord(cam))
            if Vdist(pedx, pedy, pedz, x, y, z) > 7.0 then
                Close()
            end
            --Cam Debugging
            --local camrotx,camroty,camrotz = table.unpack(GetCamRot(cam,2))
            --local camcoordx,camcoordy,camcoordz = table.unpack(GetCamCoord(cam))
            --DrawText("Relative Coords: "..pedx-x..","..pedy-y..","..pedz-z,0.5,0.70)
            --DrawText("Cam Rotation: "..camrotx..","..camroty..","..camrotz,0.5,0.72)
            if speedfreecammove > 1.0 then
                speedfreecammove = 1.0
            end
            if speedfreecammove < 0.0 then
                speedfreecammove = 0.0
            end
            if speedfreecamrotate > 10.0 then
                speedfreecamrotate = 10.0
            end
            if speedfreecamrotate < 0.0 then
                speedfreecamrotate = 0.0
            end
            if FOV > 126.8 then
                FOV = 126.8
            end
            if FOV < 11.42 then
                FOV = 11.42
            end
            if lightintensity < 0.0 then
                lightintensity = 0.0
            end
            if controls then
                DrawText("Light Intensity (Default: 400.0): "..lightintensity,0.5,0.88)
                DrawText("Camera Field Of View (Default: 49.99 | Max: 126.8 | Min: 11.42): "..string.sub(GetCamFov(cam),1,5),0.5,0.90)
                DrawText("Camera Rotate Speed (Default: 2.0 | Max: 10.0): "..string.sub(speedfreecamrotate,1,4),0.5,0.92)
                DrawText("Camera Move Speed (Default: 0.02 | Max: 1.0): "..string.sub(speedfreecammove,1,5),0.5,0.94)
                DrawText("Camera Distance (Default: 2.31 | Max: 7.0): "..string.sub(tostring(Vdist(pedx, pedy, pedz, x, y, z)),1,4),0.5,0.96)
            end
        end
    end
end)

local t = 0
controls = true
RegisterNUICallback('T', function()
    if IsCamActive(cam) then
        if t == 0 then
            controls = false
            t = 1
        elseif t == 1 then
            controls = true
            t = 0
        end
    end
end)

local h = 0
local light = true
RegisterNUICallback('H', function()
    if IsCamActive(cam) then
        if h == 0 then
            light = false
            h = 1
        elseif h == 1 then
            light = true
            h = 0
        end
    end
end)

RegisterNUICallback('[', function()
    if IsCamActive(cam) then
        lightintensity = lightintensity - 10.0
    end
end)

RegisterNUICallback(']', function()
    if IsCamActive(cam) then
        lightintensity = lightintensity + 10.0
    end
end)

CreateThread( function()
    while true do        
        Wait(0)
        if light then
            local x,y,z = table.unpack(GetCamCoord(cam))
            --x,y,z,r,g,b,range,intensity
            DrawLightWithRange(x,y,z,255,255,255,100.0,lightintensity)
        end
    end
end)

RegisterNUICallback('Z', function()
    if IsCamActive(cam) then
        speedfreecammove = speedfreecammove - 0.001
    end
end)

RegisterNUICallback('X', function()
    if IsCamActive(cam) then
        speedfreecammove = speedfreecammove + 0.001
    end
end)

RegisterNUICallback('C', function()
    if IsCamActive(cam) then
        speedfreecamrotate = speedfreecamrotate - 0.01
    end
end)

RegisterNUICallback('V', function()
    if IsCamActive(cam) then
        speedfreecamrotate = speedfreecamrotate + 0.01
    end
end)

RegisterNUICallback('W', function()
    if IsCamActive(cam) then
        local x,y,z = table.unpack(GetCamCoord(cam))
        SetCamCoord(cam,x,y+speedfreecammove,z)
    end
end)
RegisterNUICallback('S', function()
    if IsCamActive(cam) then
        local x,y,z = table.unpack(GetCamCoord(cam))
        SetCamCoord(cam,x,y-speedfreecammove,z)
    end
end)
RegisterNUICallback('A', function()
    if IsCamActive(cam) then
        local x,y,z = table.unpack(GetCamCoord(cam))
        SetCamCoord(cam,x-speedfreecammove,y,z)
    end
end)
RegisterNUICallback('D', function()
    if IsCamActive(cam) then
        local x,y,z = table.unpack(GetCamCoord(cam))
        SetCamCoord(cam,x+speedfreecammove,y,z)
    end
end)
RegisterNUICallback('Shift', function()
    if IsCamActive(cam) then
        local x,y,z = table.unpack(GetCamCoord(cam))
        SetCamCoord(cam,x,y,z-speedfreecammove)
    end
end)
RegisterNUICallback('Space', function()
    if IsCamActive(cam) then
        local x,y,z = table.unpack(GetCamCoord(cam))
        SetCamCoord(cam,x,y,z+speedfreecammove)
    end
end)
RegisterNUICallback('Q', function()
    if IsCamActive(cam) then
        FOV = FOV + 1.0
        SetCamFov(cam, FOV)
    end
end)

RegisterNUICallback('E', function()
    if IsCamActive(cam) then
        FOV = FOV - 1.0
        SetCamFov(cam, FOV)
    end
end)

RegisterNUICallback('DownArrow', function()
    if IsCamActive(cam) then
        local x,y,z = table.unpack(GetCamRot(cam, 0))
        SetCamRot(cam,x-speedfreecamrotate,y,z,0)
    end
end)

RegisterNUICallback('UpArrow', function()
    if IsCamActive(cam) then
        local x,y,z = table.unpack(GetCamRot(cam, 0))
        SetCamRot(cam,x+speedfreecamrotate,y,z,0)
    end
end)

RegisterNUICallback('LeftArrow', function()
    if IsCamActive(cam) then
        local x,y,z = table.unpack(GetCamRot(cam, 0))
        SetCamRot(cam,x,y,z+speedfreecamrotate,0)
    end
end)

RegisterNUICallback('RightArrow', function()
    if IsCamActive(cam) then
        local x,y,z = table.unpack(GetCamRot(cam, 0))
        SetCamRot(cam,x,y,z-speedfreecamrotate,0)
    end
end)

RegisterNUICallback('Model', function(data)
    CreateThread(function()
        local hash = GetHashKey(data.model)
        local player = PlayerId()
        
        RequestModel(hash,0)
        while not HasModelLoaded(hash) do
            RequestModel(hash,0)
            Wait(0)
        end
        
        SetPlayerModel(player, hash, false)
        SetPedRandomComponentVariation(PlayerPedId(),0)
        SetModelAsNoLongerNeeded(hash)
    end)
end)

RegisterNUICallback('FacialFeature', function(data)
    local datafeature = tonumber(data.feature)
    local datavalue = tonumber(data.value)
    Citizen.InvokeNative(0x5653AB26C82938CF,PlayerPedId(),tonumber(datafeature),tonumber(datavalue))
    Citizen.InvokeNative(0xCC8CA3E88256E58F,PlayerPedId(), false, true, true, true, false) --refreshes ped
end)

RegisterNUICallback('RandomClothing', function()
    SetPedRandomComponentVariation(PlayerPedId(),0)
end)

RegisterNUICallback('BodySize', function(data)
    local datatype = tonumber(data.type)
    Citizen.InvokeNative(0x1902C4CFCC5BE57C,PlayerPedId(),tonumber(datatype))
    Citizen.InvokeNative(0xCC8CA3E88256E58F,PlayerPedId(), false, true, true, true, false) --refreshes ped
end)

RegisterNUICallback('WaistSize', function(data)
    local datatype = tonumber(data.type)
    Citizen.InvokeNative(0x1902C4CFCC5BE57C,PlayerPedId(),tonumber(datatype))
    Citizen.InvokeNative(0xCC8CA3E88256E58F,PlayerPedId(), false, true, true, true, false) --refreshes ped
end)

RegisterNUICallback('Preset', function(data)
    SetPedOutfitPreset(PlayerPedId(),tonumber(data.preset),0)
end)

RegisterNUICallback('MPPreset', function(data)
    Citizen.InvokeNative(0x283978A15512B2FE,PlayerPedId(),true)
    --layer,previous hair bool,unknown,unknown
    N_0xa5bae410b03e7371(PlayerPedId(),tonumber(data.preset),0,0,0)
end)

RegisterNUICallback('Component', function(data)
    CreateThread(function()
        local componenthash = tonumber("0x"..data.componenthash)
        local componentgrouphash = tonumber("0x"..data.componentgrouphash)
        N_0x59bd177a1a48600a(PlayerPedId(),tonumber(componentgrouphash)) --Fixes Scuff
        --Bool 1 set MP, Bool 2 MP enabled hashes, Bool 3 unknown
        Citizen.InvokeNative(0xD3A7B003ED343FD9,PlayerPedId(),tonumber(componenthash),true,true,true)
    end)
end)