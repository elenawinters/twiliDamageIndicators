ShowHealth = false


function DrawTextOnScreen(text, xPosition, yPosition)
    SetTextFont(0)
    SetTextScale(1.0, 0.4)
    -- SetTextColour(color['r'], color['g'], color['b'], color['a'])
    SetTextOutline()
    BeginTextCommandDisplayText("STRING");
    AddTextComponentSubstringPlayerName(text);
    EndTextCommandDisplayText(xPosition, yPosition);


end

RegisterCommand('showhealth', function(source, args)
    renderVehicleHealth()
    TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0},
        multiline = true,
        args = {"Client", "Showing vehicle health."}
    })
end, false)

RegisterCommand('hidehealth', function(source, args)
    ShowHealth = false
    TriggerEvent('chat:addMessage', {
        color = { 255, 0, 0},
        multiline = true,
        args = {"Client", "Hiding vehicle health."}
    })
end, false)

function Round(number, places)  -- http://lua-users.org/wiki/SimpleRound
    local mult = 10^(places or 0)
    return math.floor(number * mult + 0.5) / mult
end

-- heli engine. white smoke below 900, cutting out below 600, gray smoke below 500 (use 400 for display, or dont include), failure below 200
-- aero vehicles in general: 900 yellow, 600 orange, 300 red, 200 black
-- https://github.com/TomGrobbe/vMenu/blob/master/vMenu/FunctionsController.cs
-- https://github.com/TomGrobbe/vMenu/blob/master/vMenu/CommonFunctions.cs
-- https://forum.cfx.re/t/how-to-use-colors-in-lua-scripting/458
-- cars and motorcycles: hiss & smoke below 400, sputtering below 300, engine degradation (delayed) below 100, fire below 0, explosion below 0 if moving
-- TODO: DO BOATS AND SUBMARINES

HealthValues = {  -- always y, o, r, m for this struct
    air = {y=900, o=600, r=300, m=200},
    land = {y=400, o=300, r=100, m=0}  -- boats also use this
  }

function GetHealthString(health, vehicle_type)
    local color = nil
    if health < HealthValues[vehicle_type]['m'] then
        color = 'm' -- dark grey
    elseif health < HealthValues[vehicle_type]['r'] then
        color = 'r'
    elseif health < HealthValues[vehicle_type]['o'] then
        color = 'o'
    elseif health < HealthValues[vehicle_type]['y'] then
        color = 'y'
    else
        color = 'g'
    end
    -- if health < HealthValues[vehicle_type]['y'] then
    --     color = 'y'
    -- elseif health < HealthValues[vehicle_type]['o'] then
    --     color = 'o'
    -- elseif health < HealthValues[vehicle_type]['r'] then
    --     color = 'r'
    -- elseif health < HealthValues[vehicle_type]['m'] then
    --     color = 'm' -- dark grey
    -- else
    --     color = 'g'
    -- end
        
    return "~" .. color .. "~" .. health
end


function renderVehicleHealth()
    ShowHealth = true
    Citizen.CreateThread(function ()
        while ShowHealth == true do
            local veh = GetVehiclePedIsIn(PlayerPedId(), false)
            local vclass = GetVehicleClass(veh)
            local vtype = 'land'
            if vclass == 15 or vclass == 16 then
                vtype = 'air'
            end
            if veh ~= 0 then
                local offset = 0
                if vclass == 15 then
                    DrawTextOnScreen(string.rep("~n~", 1) .. "Main Rotor health: " .. GetHealthString(Round(GetHeliMainRotorHealth(veh), 2), vtype), 0.5, 0.0)
                    DrawTextOnScreen(string.rep("~n~", 2) .. "Tail Boom health: " .. GetHealthString(Round(GetHeliTailBoomHealth(veh), 2), vtype), 0.5, 0.0)
                    DrawTextOnScreen(string.rep("~n~", 3) .. "Tail Rotor health: " .. GetHealthString(Round(GetHeliTailRotorHealth(veh), 2), vtype), 0.5, 0.0)
                    offset = 3
                end
                DrawTextOnScreen(string.rep("~n~", offset + 1) .. "Engine health: " .. GetHealthString(Round(GetVehicleEngineHealth(veh), 2), vtype), 0.5, 0.0);
                DrawTextOnScreen(string.rep("~n~", offset + 2) .. "Body health: " .. GetHealthString(Round(GetVehicleBodyHealth(veh), 2), vtype), 0.5, 0.0);
                DrawTextOnScreen(string.rep("~n~", offset + 3) .. "Tank health: " .. GetHealthString(Round(GetVehiclePetrolTankHealth(veh), 2), vtype), 0.5, 0.0)
            end

            Citizen.Wait(0)
        end
    end)
end
