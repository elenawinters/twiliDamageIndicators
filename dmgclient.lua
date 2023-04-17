-- TODO: Test OneSync Legacy and OneSync Infinity functionality on both FiveM and RedM 
-- Status: Issues with RedM OneSync Infinity. OneSync Legacy still needs to be tested.

-- Issues: When running, the damage text kinda wobbles up and down. I'm not sure if I can fix this, but I'mma try

TrackedEntities = {}

-- OffsetModes = {'default', 'jitter', 'fly'}

BUILD = GetGameBuildNumber()
GAME = GetGameName()

tobool = {['true'] = true, ['false'] = false}

RegisterCommand('dmghud', function(source, args)
    SetNuiFocus(true, true)
    SendNUIMessage({showdmgmenu = true})
end, false)

RegisterNUICallback('cancel', function()
    SetNuiFocus(false, false)
    SendNUIMessage({showdmgmenu = false})
end)


RegisterNUICallback('dynamicfadestatus', function(data)
    Settings['dynamic_fade'] = data.dynamicfade
end)

RegisterNUICallback('ignorevehiclestatus', function(data)
    Settings['ignore_vehicles'] = data.vehicleignore
end)

RegisterNUICallback('fadespeedstatus', function(data)
    Settings['fade_speed'] = data.fadespeed
end)

RegisterNUICallback('localdmgstatus', function(data)
    Settings['local_damage'] = data.localdmg
end)

RegisterNUICallback('precisionstatus', function(data)
    Settings['precision'] = data.precision
end)

RegisterCommand('testfont', function(source, args)
    Settings['render_font'] = tonumber(args[1])
    TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0},
        multiline = true,
        args = {"Debug", "Pbttt testing font number ".. Settings['render_font']}
    })
end, false)

RegisterCommand('testoffset', function(source, args)
    Settings['offset_intensity'] = tonumber(args[1])
    TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0},
        multiline = true,
        args = {"Debug", "Random offset intensity is now ".. Settings['offset_intensity']}
    })
end, false)


-- RegisterCommand('testmode', function(source, args)
--     Settings['offset_mode'] = args[1]
--     TriggerEvent('chat:addMessage', {
--         color = { 255, 0, 0},
--         multiline = true,
--         args = {"Debug", "Random offset intensity is now ".. Settings['offset_mode']}
--     })
-- end, false)


-- RegisterCommand('testspeed', function(source, args)
--     Settings['offset_mode_fly_speed'] = tonumber(args[1])
--     TriggerEvent('chat:addMessage', {
--         color = { 255, 0, 0},
--         multiline = true,
--         args = {"Debug", "Random offset intensity is now ".. Settings['offset_mode_fly_speed']}
--     })
-- end, false)




function round(num, prec)
    if prec == nil then
        prec = Settings['precision']
    end
    if prec and prec > 0 then
      local mult = 10^prec
      return math.floor(num * mult + 0.5) / mult
    end
    return math.floor(num + 0.5)
end



function RandomOffset(position, intensity)  -- this is getting progressively more complex
    if math.random(2) == 1 then position.x = position.x + -math.random()/intensity else position.x = position.x + math.random()/intensity end
    if math.random(2) == 1 then position.y = position.y + -math.random()/intensity else position.y = position.y + math.random()/intensity end
    return position
end


function CalculateRicochet(victim)
    local weapon_impact_at = GetPedLastWeaponImpactCoord(GetPlayerPed(-1))
    local car_vector = GetEntityForwardVector(victim)
    local angle = 45
end


function DrawDamageText(position, value, color, size, rate, entity)
    Citizen.CreateThread(function()
        local is_render_dynamic = Settings['dynamic_fade']
        if rate == nil then
            rate = Settings['fade_speed']
        end
        -- checks if the timeout is true
        local offsetIntensity = Settings['offset_intensity']
        local positionOffsetBase = RandomOffset({x=0, y=0}, offsetIntensity)
        -- local offsetIntensity = Settings['offset_intensity']
        -- if math.random(2) == 1 then positionOffset.x = -math.random()/offsetIntensity else positionOffset.x = math.random()/offsetIntensity end
        -- if math.random(2) == 1 then positionOffset.y = -math.random()/offsetIntensity else positionOffset.y = math.random()/offsetIntensity end
        -- local currentAlpha = math.floor(math.random(127)) + 127
        local fadeCounter = 255
        local currentAlpha = fadeCounter
        -- local perspectiveScale = 4
        local scaleMultiplier = size or 1
        local font = Settings['render_font']
        local textOutline = true
        local positionOffset = positionOffsetBase
        while currentAlpha > 0 do
            Citizen.Wait(0)
            -- local camPos = GetFinalRenderedCamCoord()
            local onScreen, _x, _y = GetScreenCoordFromWorldCoord(position.x, position.y, position.z)
            if IsEntityAPed(entity) and GetEntityHealth(entity) == 0 then  -- this jitters the damage number when you kill a ped
                positionOffset = RandomOffset(positionOffset, offsetIntensity * 10)
            end
            -- if Settings['offset_mode'] == 'jitter' then
            --     positionOffset = RandomOffset(positionOffset, offsetIntensity * 10)
            -- elseif Settings['offset_mode'] == 'float' then  -- this is complex
            --     -- https://math.stackexchange.com/questions/604324/find-a-point-n-distance-away-from-a-specified-point-in-a-given-direction
            --     local angle = math.atan2(positionOffset.x, positionOffset.y) - math.atan2(_x, _y)

            --     positionOffset.x = positionOffset.x + math.cos(angle) * Settings['offset_mode_fly_speed']
            --     positionOffset.y = positionOffset.y + math.sin(angle) * Settings['offset_mode_fly_speed']
            --     onScreen = true -- compromise for legacy fly
            -- elseif Settings['offset_mode'] == 'fly' then
            --     if fadeCounter == 255 then  -- this will always be the first tick, and we can calculate ricochet if we are on the first tick
            --         print('WIP')
            --     end
            --     -- GOAL - Get 3D world space positions for these 
            --     -- Basically, we're gonna do a 3d simulation for an invisible object that is the origin of the 2d text
            --     -- I'm probably really in over my head with this one.

            --     -- This might be scrapped
            --     print('Function not yet implemented')
            -- end
            -- local distance = GetDistanceBetweenCoords(camPos.x, camPos.y, camPos.z, position.x, position.y, position.xyz.z, 1)
            -- local scale = (1 / distance) * (perspectiveScale) * (1 / GetFinalRenderedCamFov()) * 75

            if onScreen then
                if GAME == 'fivem' then
                    SetTextScale(tonumber(scaleMultiplier * 0.0), tonumber(0.35 * scaleMultiplier))
                    -- SetTextScale(0.0, scale)
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
            if is_render_dynamic == false then  -- people who use a static fade want it to update instantly
                rate = Settings['fade_speed']
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
            print('Removed '.. ent .. ' from tracking list')  -- i've never seen this run. i need to do some more testing to see if it ever will
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
    local playerPed = PlayerPedId()
    local camCoord = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(0)

    local rayHandle = StartShapeTestRay(camCoord, camCoord + RotationToDirection(camRot) * 1000, -1, playerPed)
    local _status, _hit, endCoords, _surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

    return endCoords, entityHit

end

-- CEventEntityDamaged

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
                -- Colors likely need to be adjusted. TODO: Add a color wheel to the settings menu for all color related settings
                DrawDamageText(GetPedBoneCoords(victim, 0xFE2C), writhe_says[math.random(#writhe_says)], Settings['color']['entity_writhe'], 0.75)
                Citizen.Wait(500)
            end
        end)

    end)

    -- Future plans
    -- use CEventDamage to get damage done to you and damage you do to locals
    -- Tell server that you did that
    -- Server will tell other clients
    -- This way a desync cannot occur due to the networked entity damage.
    -- This still isn't ideal though
    -- This will happen with the JavaScript rewrite

    -- use GetWeaponTimeBetweenShots to get dynamic fade speed per weapon
    -- use log 0.7 (x) to get Fade Speed from TimeBetweenShots. If output is below 0.1, keep it at 0.1. Refine later
    AddEventHandler('gameEventTriggered', function (eventName, data)
        if eventName == 'CEventNetworkEntityDamage' then  -- network events are unreliable with multiple players
            local victim = data[1]
            local suspect = data[2]
            
            -- victim ~= GetVehiclePedIsIn(PlayerPedId(), false)
            if suspect ~= PlayerPedId() and victim ~= PlayerPedId() and Settings['local_damage'] == true then
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
            local weaponHash = data[5 + offset]
            local isMelee = data[10 + offset]
            local damageType = data[11 + offset]

            -- Would it be funny to render blood drop emotes twice a second for ten seconds when the below is true?
            -- Yes.
            -- Am I gonna do it...?
            -- Yes, when I clean up everything. It'll be an easter egg that can be toggled
            -- print('victimDied? '.. victimDied)

            local position, entity = RaycastFromPlayer()
            if entity ~= victim then
                if IsEntityAPed(victim) then
                    if victimDied and GetPedCauseOfDeath(victim) == 0 then
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

            local fadeRate = Settings['fade_speed']
            if isMelee == 0 and Settings['dynamic_fade'] then
                fadeRate = math.log(GetWeaponTimeBetweenShots(weaponHash), 0.7)
                if fadeRate <= 1 then
                    fadeRate = 1
                end
                if fadeRate == 1e309 then  -- infinities MONKAS
                    fadeRate = 5
                end
            end

            skip_damage_render = false
            if Settings['ignore_vehicles'] then
                if IsEntityAVehicle(victim) then
                    skip_damage_render = true
                end
            end

            local dmg = CalculateHealthLost(victim)
            if not skip_damage_render then
                if IsEntityAPed(victim) and IsPedFatallyInjured(victim) and dmg.h ~= 0 then
                    DrawDamageText(position, round(-dmg.h + 100), Settings['color']['damage_entity'], 1, fadeRate, victim)
                else
                    DrawDamageText(position, round(-dmg.h), Settings['color']['damage_entity'], 1, fadeRate, victim)
                end

                if dmg.a ~= 0 then
                    DrawDamageText(position, round(-dmg.a), Settings['color']['damage_armor'], 1, fadeRate, victim)
                end
            end

            if damageType == 93 then
                DrawDamageText(position, 'Pop!', Settings['color']['damage_vehicle_ding'], 0.5, fadeRate, victim) -- tire damage
            elseif damageType == 116 then  -- 117 is exhaust pipe? im not certain. shows up when shooting the Pheonix's exhaust pipes
                DrawDamageText(position, 'Ding!', Settings['color']['damage_vehicle_ding'], 0.5, fadeRate, victim)  -- general vehicle damage
            elseif damageType == 120 or damageType == 121 or damageType == 122 then
                DrawDamageText(position, 'Smash!', Settings['color']['damage_vehicle_ding'], 0.5, fadeRate, victim)  -- window damage
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
        if suspect ~= PlayerPedId() and victim ~= PlayerPedId() and Settings['local_damage'] == true then
            return  -- if i'm not a victim or suspect, and I only want to show my damage, return
        end

        if Settings['ignore_vehicles'] then
            if IsEntityAVehicle(victim) then
                return
            end
        end

        -- TODO: OneSync causes issues relating to the activation of the Game Event. We need to fix it.
        -- Basically, if a horse isn't visible but dead, it'll despawn, but when it gets back into view, it'll spawn and die, triggering the event.
        -- Oddity: It only seems to happen with horses that were attached to a carriage.

        -- Potential Solution: Take advantage of TrackedEntities, with a simple data value of alive = true or false

        -- Interesting to note: In Armadillo, the body pits corpses are spawned in as peds and then killed.
        -- Workaround: Check for those specific models and don't render if they are the entity.
        -- This could also be a OneSync thing, but I have yet to test that.

        local position, entity = RaycastFromPlayer()

        if entity ~= victim then
            local is_ped, bone = GetPedLastDamageBone(victim)
            if is_ped == 1 then
                position = GetPedBoneCoords(victim, bone)
            else
                position = defaultPosition
            end
        end

        DrawDamageText(position, round(-value), Settings['color']['damage_entity'], 1, 1, victim)

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
