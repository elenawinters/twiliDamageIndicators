-- TODO: Test OneSync Legacy and OneSync Infinity functionality on both FiveM and RedM

trackedPeds = {}  -- only used in GTAV currently

DmgDyn = false
DmgFade = 5
DmgME = true
Precision = 2  -- fractional precision

BUILD = GetGameBuildNumber()
GAME = GetGameName()

tobool = {["true"] = true, ["false"] = false}
-- DamageTypes = {93, 116, 117, 120, 121, 122}  -- DamageTypes for GTAV; this is unused

-- RegisterCommand('dmgme', function(source, args)
--     DmgME = true
--     TriggerEvent('chat:addMessage', {
--         color = { 255, 0, 0},
--         multiline = true,
--         args = {"Client", "Only showing damage from me!"}
--     })
-- end, false)

-- RegisterCommand('dmgall', function(source, args)
--     DmgME = false
--     TriggerEvent('chat:addMessage', {
--         color = { 255, 0, 0},
--         multiline = true,
--         args = {"Client", "Showing all damage!"}
--     })
-- end, false)

-- RegisterCommand('dmgprec', function(source, args)
--     Precision = tonumber(args[1])
--     TriggerEvent('chat:addMessage', {
--         color = { 255, 0, 0},
--         multiline = true,
--         args = {"Client", "Precision set to " .. args[1] .."!"}
--     })
-- end, false)


-- RegisterCommand('dmgfade', function(source, args)
--     DmgFade = tonumber(args[1])
--     TriggerEvent('chat:addMessage', {
--         color = { 255, 0, 0},
--         multiline = true,
--         args = {"Client", "Damage text fading speed set to " .. args[1] .. "!"}
--     })
-- end, false)


-- RegisterNUICallback('change', function(data)
--     NUI_status = false
--     TriggerServerEvent('cd_easytime:ForceUpdate', data.values)
--     if data.savesettings then
--         print('Saving Settings - please wait 2 seconds ...')
--         Wait(2000)
--         TriggerServerEvent('cd_easytime:SaveSettings')
--         print('Settings Saved.')
--     end
-- end)


RegisterCommand('dmghud', function(source, args)
    SetNuiFocus(true, true)
    SendNUIMessage({showdmgmenu = true})
end, false)

RegisterNUICallback('cancel', function()
    SetNuiFocus(false, false)
    SendNUIMessage({showdmgmenu = false})
end)


RegisterNUICallback('dynamicfadestatus', function(data)
    DmgDyn = tobool[data.dynamicfade]
end)

RegisterNUICallback('fadespeedstatus', function(data)
    DmgFade = tonumber(data.fadespeed)
end)

RegisterNUICallback('localdmgstatus', function(data)
    DmgME = tobool[data.localdmg]
end)

RegisterNUICallback('precisionstatus', function(data)
    Precision = tonumber(data.precision)
end)


function round(num, prec)  -- fp stands for fractional precision
    if prec == nil then
        prec = Precision
    end
    if prec and prec > 0 then
      local mult = 10^prec
      return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
  end

-- function round(num, numDecimalPlaces)
--     local mult = 10^(numDecimalPlaces or 0)
--     return math.floor(num * mult + 0.5) / mult
-- end

-- trackedPeds[GetPlayerPed()] = {health=100, armor=100}
-- trackedPeds[GetPlayerPed()].armor = 2

function DrawDamageText(position, value, color, size, rate)
    Citizen.CreateThread(function()
        if rate == nil then
            rate = DmgFade
        end
        -- checks if the timeout is true
        local positionOffset = {x=0, y=0}
        if math.random(2) == 1 then positionOffset.x = -math.random()/50 else positionOffset.x = math.random()/50 end
        if math.random(2) == 1 then positionOffset.y = -math.random()/50 else positionOffset.y = math.random()/50 end
        -- local currentAlpha = math.floor(math.random(127)) + 127
        local fadeCounter = 255
        local currentAlpha = fadeCounter
        local perspectiveScale = 4
        local scaleMultiplier = size or 1
        local font = 0
        local textOutline = true
        while currentAlpha > 0 do
            Citizen.Wait(0)
            local onScreen, _x, _y = GetScreenCoordFromWorldCoord(position.x, position.y, position.z)
            local p = GetFinalRenderedCamCoord()
            local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, position.x, position.y, position.xyz.z, 1)
            local scale = (1 / distance) * (perspectiveScale)
            local fov = (1 / GetGameplayCamFov()) * 75
            scale = scale * fov
            if onScreen then

                if GAME == 'fivem' then
                    SetTextScale(tonumber(scaleMultiplier * 0.0), tonumber(0.35 * scaleMultiplier))
                    SetTextFont(font)
                    SetTextProportional(true)
                    SetTextColour(color[1], color[2], color[3], currentAlpha)
                    if (textOutline) == true then SetTextOutline() end;
                    BeginTextCommandDisplayText("STRING")

                    SetTextCentre(true)
                    AddTextComponentSubstringPlayerName(value)
                    EndTextCommandDisplayText(_x + positionOffset.x, _y + positionOffset.y)
                elseif GAME == 'redm' then
                    local vstr = CreateVarString(10, "LITERAL_STRING", tostring(value))  -- the game will crash if VALUE is not a string
                    SetTextColor(color[1], color[2], color[3], currentAlpha)
                    SetTextScale(tonumber(scaleMultiplier * 0.0), tonumber(0.35 * scaleMultiplier))
                    SetTextFontForCurrentCommand(font)
                    SetTextCentre(true)

                    DisplayText(vstr, _x + positionOffset.x, _y + positionOffset.y)
                end
            end
            fadeCounter = fadeCounter - rate
            currentAlpha = round(fadeCounter, 0)
        end
    end)
end

function IndexOf(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return i
        end
    end
    return nil
end

TrackedEntities = {}

function MergeVehicleHealths(veh)
    local wheel_healths = 0
    -- print(GetVehicleNumberOfWheels(veh))
    for i=1,GetVehicleNumberOfWheels(veh) do
        -- print(i)
        wheel_healths = wheel_healths + GetVehicleWheelHealth(veh, i)
    end
    local heli_healths = 0
    if GetVehicleClass(veh) == 15 then  -- if vehicle is helicopter, get it's health stats
        heli_healths = GetHeliMainRotorHealth(veh) + GetHeliTailBoomHealth(veh) + GetHeliTailRotorHealth(veh)
    end
    return GetVehicleBodyHealth(veh) + GetVehicleEngineHealth(veh) + GetVehiclePetrolTankHealth(veh) + wheel_healths + heli_healths
end

function TrackEntityHealth()
    entities = GetActivePlayers()
    for k, v in ipairs(GetGamePool('CPed')) do
        table.insert(entities, v)
    end
    for k, v in ipairs(GetGamePool('CVehicle')) do
        table.insert(entities, v)
    end
    for i, ent in ipairs(entities) do
        if IsEntityAPed(ent) then
            if GAME == 'fivem' then
                TrackedEntities[ent] = {h = GetEntityHealth(ent), a = GetPedArmour(ent)}
            else
                TrackedEntities[ent] = {h = GetEntityHealth(ent), a = 0}
            end
        elseif IsEntityAVehicle(ent) then
            TrackedEntities[ent] = {h = MergeVehicleHealths(ent), a = 0}
        end
    end
    for i, ent in ipairs(TrackedEntities) do
        if entities[ent] == nil and TrackedEntities[ent] then
            table.remove(TrackedEntities, IndexOf(TrackedEntities, ent))
            print('Removed '.. ent .. ' from tracking list')
        end
    end
end

if GAME == 'fivem' then
    Citizen.CreateThread(function ()
        while true do
            Citizen.Wait(1000)  -- update every second.
            TrackEntityHealth()
        end
    end)
end

function CalculateHealthLost(ent)
    local health = 0
    local armor = 0
    if IsEntityAPed(ent) then
        health = TrackedEntities[ent].h - GetEntityHealth(ent)
        TrackedEntities[ent].h = GetEntityHealth(ent)
        -- print(health)
        armor = TrackedEntities[ent].a - GetPedArmour(ent)
        TrackedEntities[ent].a = GetPedArmour(ent)
    elseif IsEntityAVehicle(ent) then
        health = TrackedEntities[ent].h - MergeVehicleHealths(ent)
        TrackedEntities[ent].h = MergeVehicleHealths(ent)
    else
        health = 0
    end
    return {h = health, a = armor}
end

-- function prototype()
--     xyz = GetEntityCoords(PlayerPedId())
--     DrawDamageText(xyz)
-- end

local function RotationToDirection(deg)
    local rad_x = deg['x'] * 0.0174532924
    local rad_z = deg['z'] * 0.0174532924

    local dir_x = -math.sin(rad_z) * math.cos(rad_x)
    local dir_y = math.cos(rad_z) * math.cos(rad_x)
    local dir_z = math.sin(rad_x)
    local dir = vector3(dir_x, dir_y, dir_z)
    return dir
end

local function RaycastFromPlayer()
    -- Results of the raycast
    local hit = false
    local endCoords = nil
    local surfaceNormal = nil
    local entityHit = nil

    local playerPed = PlayerPedId()
    local camCoord = GetFinalRenderedCamCoord()
    local camRot = GetGameplayCamRot(0)

    local rayHandle = StartShapeTestRay(camCoord, camCoord + RotationToDirection(camRot) * 1000, -1, playerPed)
    local status, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

    return endCoords, entityHit

    -- return hit, endCoords, surfaceNormal, entityHit
end

-- CEventEntityDamaged

local red = {224, 50, 50}

if GAME == 'fivem' then
    -- AddEventHandler('CEventEntityDamaged', function (entities, eventEntity, args)
    --     print("CEventEntityDamaged \neventEnt: "..eventEntity.."\nentities: "..json.encode(entities).."\nargs: "..json.encode(args))
    --     -- print('Start of dump')
    --     -- for iter = 1, 8 - 1 do
    --     --     print(args[iter])
    --     -- end
    --     -- print('End of dump')
    -- end)

    local writhe_says = {'Ouch!', 'Ow!', 'Ugh!'}
    AddEventHandler('CEventWrithe', function (args)  -- EXPAND
        Citizen.CreateThread(function()
            local victim = args[1]
            while IsPedFatallyInjured(victim) == false do
                DrawDamageText(GetPedBoneCoords(victim, 0xFE2C), writhe_says[math.random(#writhe_says)], {169, 0, 0}, 0.75)
                Citizen.Wait(500)
            end
        end)

    end)

    -- use GetWeaponTimeBetweenShots to get dynamic fade speed per weapon
    AddEventHandler('gameEventTriggered', function (eventName, data)
        if eventName == 'CEventNetworkEntityDamage' then  -- network events are unreliable with multiple players
            local victim = data[1]
            local suspect = data[2]
            
            -- victim ~= GetVehiclePedIsIn(PlayerPedId(), false)
            if suspect ~= PlayerPedId() and victim ~= PlayerPedId() and DmgME == true then
                return
            end
    
            local offset = 0
            
            -- i'll document these eventually
            -- reference https://forum.cfx.re/t/b2060-b2189-game-event-ceventnetworkentitydamage-not-working-as-expected/1922652/8?u=elenaberry
            if BUILD >= 2060 then -- unknown bool introduced (undocumented)
                offset = offset + 1
                if BUILD >= 2189 then -- another unknown bool (undocumented)
                    offset = offset + 1
                end
            end
    
            local victimDied = data[4 + offset]
            -- local weaponHash = data[5 + offset]  -- we don't use this
            -- local isMelee = data[10 + offset]
            local damageType = data[11 + offset]

            -- print('victimDied? '.. victimDied)

            local position, entity = RaycastFromPlayer()
            -- print(GetPedLastDamageBone(victim))
            if entity ~= victim then
                if IsEntityAPed(victim) then
                    if IsPedFatallyInjured(victim) and GetPedCauseOfDeath(victim) == 0 then
                        position = GetPedBoneCoords(victim, 0x60F1)  -- spine2
                    else
                        local success, bone = GetPedLastDamageBone(victim)
                        if success then  -- a valid bone was found, good job!
                            position = GetPedBoneCoords(victim, bone)
                        else
                            position = GetPedBoneCoords(victim, 0x60F1)  -- spine2
                        end
                    end
                else
                    position = GetEntityCoords(victim)  -- this needs to be set somehow
                end
            end

            -- if position.x == 0 and position.y == 0 and position.z == 0 then
            --     position = GetEntityCoords(victim)
            -- end
    
            -- dmg = GetWeaponDamage(GetSelectedPedWeapon(attacker), 0)
            local dmg = CalculateHealthLost(victim)
            -- print('Health Lost: '.. dmgh)
            -- dmg = GetWeaponDamage(weaponHash, 0)
            -- DrawDamageText(GetEntityCoords(victim), math.floor(-dmg), {255, 0, 0}, 1)
            -- {224, 50, 50}
            if IsEntityAPed(victim) and IsPedFatallyInjured(victim) and dmg.h ~= 0 then
                DrawDamageText(position, round(-dmg.h + 100), red, 1)
            else
                DrawDamageText(position, round(-dmg.h), red, 1)
            end
            local blue = {93, 182, 229}
            if dmg.a ~= 0 then
                DrawDamageText(position, round(-dmg.a), blue, 1)
            end
            -- print('Victim ' .. victim)
            -- print('Attacker ' .. attacker)
            -- print(attacker .. ' attacked ' .. victim .. ' with damage type ' .. damageType)
            -- old values 173, 216, 230
            local grey = {154, 154, 154}
            if damageType == 93 then
                DrawDamageText(position, 'Pop!', grey, 0.5) -- tire damage
                -- print('pop!')
            elseif damageType == 116 then  -- 117 is exhaust pipe? im not certain. shows up when shooting the Pheonix's exhaust pipes
                DrawDamageText(position, 'Ding!', grey, 0.5)  -- general vehicle damage
                -- print('ding!')
            elseif damageType == 120 or damageType == 121 or damageType == 122 then
                DrawDamageText(position, 'Smash!', grey, 0.5)  -- window damage
                -- print('smash!')
            elseif damageType == 0 then
                return
            -- else
            --     print('Unknown damageType. Please report what you shot to the developer of this script: '.. damageType)
            --     DrawDamageText(position, 'Unknown! (' .. damageType .. ')', {0, 255, 0}, 0.8)
    
            end
    
    
        end
        
        
    end)
elseif GAME == 'redm' then  -- RedM doesn't have the `gameEventTriggered` handler
    function RenderStepRDR3(victim, suspect, defaultPosition, value)  -- there is a return, and if you return in the above Thread, it exits the thread
        if suspect ~= PlayerPedId() and victim ~= PlayerPedId() and DmgME == true then
            return  -- if i'm not a victim or suspect, and I only want to show my damage, return
        end

        local position, entity = RaycastFromPlayer()

        if entity ~= victim then
            local is_ped, bone = GetPedLastDamageBone(victim)
            if is_ped == 1 then
                position = GetPedBoneCoords(victim, bone)
            else
                position = defaultPosition
            end
        end

        DrawDamageText(position, round(-value), red, 1)

    end
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)

            local size = GetNumberOfEvents(0)
            if size > 0 then
                for i = 0, size - 1 do
                    local eventAtIndex = GetEventAtIndex(0, i)
                    if eventAtIndex == 402722103 then  -- EVENT_ENTITY_DAMAGED
                    -- if eventAtIndex == -1315570756 then  -- EVENT_NETWORK_DAMAGE_ENTITY
                        local eventDataSize = 9
                        local eventDataStruct = DataView.ArrayBuffer(8*eventDataSize)  -- not a fan of using DataView here. i'll rewrite it someday
                        for iter = 0, eventDataSize - 1 do
                            eventDataStruct:SetInt32(8*iter, 0)
                        end
                        
                        -- eventDataStruct:SetInt32(0, 0)  -- 0
                        -- eventDataStruct:SetInt32(8, 0)  -- 1
                        -- eventDataStruct:SetInt32(8*2, 0)  -- 2
                        -- eventDataStruct:SetInt32(8*3, 0)  -- 3
                        -- eventDataStruct:SetInt32(8*4, 0)  -- 4
                        -- eventDataStruct:SetInt32(8*5, 0)  -- 5
                        -- eventDataStruct:SetInt32(8*6, 0)  -- 6
                        -- eventDataStruct:SetInt32(8*7, 0)  -- 7
                        -- eventDataStruct:SetInt32(8*8, 0)  -- 8

                        -- local eventDataExists = GetEventData(0, i, eventDataStruct:Buffer(), eventDataSize)  -- doesn't work?

                        local eventDataExists = Citizen.InvokeNative(0x57EC5FA4D4D6AFCA, 0, i, eventDataStruct:Buffer(), eventDataSize)  --GetEventData
                        if eventDataExists then
                            local victim = eventDataStruct:GetInt32(0)
                            local suspect = eventDataStruct:GetInt32(8)
                            local position = vector3(eventDataStruct:GetFloat32(8*6), eventDataStruct:GetFloat32(8*7), eventDataStruct:GetFloat32(8*8))
                            local value = eventDataStruct:GetFloat32(32)

                            RenderStepRDR3(victim, suspect, position, value)
                        end

                    end
                end
            end
        end
    end)

end
