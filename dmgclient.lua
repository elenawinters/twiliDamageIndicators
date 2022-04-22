trackedPeds = {}
DmgFade = 5

-- trackedPeds[GetPlayerPed()] = {health=100, armor=100}
-- trackedPeds[GetPlayerPed()].armor = 2

function DrawDamageText(position, value, color, size)
    Citizen.CreateThread(function()
        -- checks if the timeout is true
        local positionOffset = {x=0, y=0}
        if math.random(2) == 1 then positionOffset.x = -math.random()/50 else positionOffset.x = math.random()/50 end
        if math.random(2) == 1 then positionOffset.y = -math.random()/50 else positionOffset.y = math.random()/50 end
        -- local currentAlpha = math.floor(math.random(127)) + 127
        local currentAlpha = 255
        local perspectiveScale = 4
        local scaleMultiplier = size or 1
        local font = 0
        local textOutline = true
        while currentAlpha > 0 do
            Citizen.Wait(0)
            local onScreen, _x, _y = World3dToScreen2d(position.x, position.y, position.z)
            local p = GetGameplayCamCoords()
            local distance = GetDistanceBetweenCoords(p.x, p.y, p.z, position.x, position.y, position.xyz.z, 1)
            local scale = (1 / distance) * (perspectiveScale)
            local fov = (1 / GetGameplayCamFov()) * 75
            scale = scale * fov
            if onScreen then
                SetTextScale(tonumber(scaleMultiplier * 0.0), tonumber(0.35 * scaleMultiplier))
                SetTextFont(font)
                SetTextProportional(true)

                SetTextColour(color[1], color[2], color[3], currentAlpha)

                if (textOutline) == true then SetTextOutline() end;
                SetTextEntry("STRING")
                SetTextCentre(true)
                AddTextComponentString(value)
                DrawText(_x + positionOffset.x, _y + positionOffset.y)
                -- DrawText(_x, _y)
            end
            currentAlpha = currentAlpha - DmgFade  -- this is normally set to 3. set to 1 for demonstation
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
            TrackedEntities[ent] = {h = GetEntityHealth(ent), a = GetPedArmour(ent)}
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

Citizen.CreateThread(function ()
    while true do
      Citizen.Wait(1000)  -- update every second.
      TrackEntityHealth()
    end
end)

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
    local camCoord = GetGameplayCamCoord()
    local camRot = GetGameplayCamRot(0)

    local rayHandle = StartShapeTestRay(camCoord, camCoord + RotationToDirection(camRot) * 1000, -1, playerPed)
    local status, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(rayHandle)

    return endCoords, entityHit

    -- return hit, endCoords, surfaceNormal, entityHit
end


DmgME = true

RegisterCommand('dmgme', function(source, args)
    DmgME = true
    TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0},
        multiline = true,
        args = {"Client", "Only showing damage from me!"}
    })
end, false)

RegisterCommand('dmgall', function(source, args)
    DmgME = false
    TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0},
        multiline = true,
        args = {"Client", "Showing all damage!"}
    })
end, false)


RegisterCommand('dmgfade', function(source, args)
    DmgFade = tonumber(args[1])
    TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0},
        multiline = true,
        args = {"Client", "Damage text fading speed set to " .. args[1] .. "!"}
    })
end, false)

-- There are some issues with damage events being triggered reliably.
-- My future plan is to use CEventEntityDamage to see if it triggers for the helicopter parts taking damage. It doesn't appear to update Network Damage
-- Another option is to move the below code into it's own function, and call it in the TrackEntityHealth loop too, so that it properly updates.

BUILD = GetGameBuildNumber()
DamageTypes = {93, 116, 117, 120, 121, 122}

AddEventHandler('gameEventTriggered', function (eventName, data)
    if eventName == 'CEventNetworkEntityDamage' then
        local victim = data[1]
        local attacker = data[2]
        -- victim ~= GetVehiclePedIsIn(PlayerPedId(), false)
        if attacker ~= PlayerPedId() and victim ~= PlayerPedId() and DmgME == true then
            return
        end

        local offset = 0
        
        -- reference https://forum.cfx.re/t/b2060-b2189-game-event-ceventnetworkentitydamage-not-working-as-expected/1922652/8?u=elenaberry
        if BUILD >= 2060 then -- unknown bool introduced (undocumented)
            offset = offset + 1
            if BUILD >= 2189 then -- another unknown bool (undocumented)
                offset = offset + 1
            end
        end

        -- local victimDied = data[4 + offset]
        -- local weaponHash = data[5 + offset]  -- we don't use this
        -- local isMelee = data[10 + offset]
        local damageType = data[11 + offset]

        local position, entity = RaycastFromPlayer()
        -- print(GetPedLastDamageBone(victim))
        if entity ~= victim then
            local is_ped, bone = GetPedLastDamageBone(victim)
            if is_ped == 1 then
                position = GetPedBoneCoords(victim, bone)
            else
                position = GetEntityCoords(victim)
            end
        end

        -- dmg = GetWeaponDamage(GetSelectedPedWeapon(attacker), 0)
        local dmg = CalculateHealthLost(victim)
        -- print('Health Lost: '.. dmgh)
        -- dmg = GetWeaponDamage(weaponHash, 0)
        -- DrawDamageText(GetEntityCoords(victim), math.floor(-dmg), {255, 0, 0}, 1)
        -- {224, 50, 50}
        local red = {224, 50, 50}
        if IsEntityAPed(victim) and IsPedFatallyInjured(victim) and dmg.h ~= 0 then
            DrawDamageText(position, math.floor(-dmg.h + 100), red, 1)
        else
            DrawDamageText(position, math.floor(-dmg.h), red, 1)
        end
        local blue = {93, 182, 229}
        if dmg.a ~= 0 then
            DrawDamageText(position, math.floor(-dmg.a), blue, 1)
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
  
