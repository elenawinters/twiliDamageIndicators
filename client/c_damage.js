// JAVASCRIPT REWRITE
// I want the ability to do more things, and LUA is just too barebones and restrictive.
// This JavaScript rewrite will allow new things to happen and also give me experience in the language.

// TODO: Test OneSync Legacy and OneSync Infinity functionality on both FiveM and RedM 
// Status: Issues with RedM OneSync Infinity. OneSync Legacy still needs to be tested.

// Issues: When running, the damage text kinda wobbles up and down. I'm not sure if I can fix this, but I'mma try

console.log('We are here')

const Delay = (ms) => new Promise(res => setTimeout(res, ms));

let TrackedEntities = {};

const BUILD = GetGameBuildNumber();
const GAME = GetGameName();
const FIVEM = 'fivem';
const REDM = 'redm';

console.log(`Code path is set to ${GAME}`);


RegisterCommand('dmghud', (source, args) => {
    SetNuiFocus(true, true);
    SendNUIMessage({showdmgmenu: true});
});

RegisterNuiCallback('cancel', () => {
    SetNuiFocus(false, false);
    SendNUIMessage({showdmgmenu: false});
});


RegisterNuiCallback('dynamicfadestatus', (data) => {
    Settings.dynamic_fade = data.dynamicfade;
});

RegisterNuiCallback('ignorevehiclestatus', (data) => {
    Settings.ignore_vehicles = data.vehicleignore
});

RegisterNuiCallback('fadespeedstatu', (data) => {
    Settings.fade_speed = data.fadespeed
});

RegisterNuiCallback('localdmgstatus', (data) => {
    Settings.local_damage = data.localdmg
});

RegisterNuiCallback('precisionstatus', (data) => {
    Settings.precision = data.precision
});



RegisterCommand('testfont', (source, args) => {
    Settings.render_font = parseInt(args[0])
    TriggerEvent('chat:addMessage', {
        color: [255, 0, 0],
        multiline: true,
        args: {"Debug": `Pbttt testing font number ${Settings.render_font}`}
    });
});


RegisterCommand('testoffset', (source, args) => {
    Settings.offset_intensity = parseInt(args[0])
    TriggerEvent('chat:addMessage', {
        color: [255, 0, 0],
        multiline: true,
        args: {"Debug": `Random offset intensity is now ${Settings.offset_intensity}`}
    });
});


// RegisterCommand('testfont', function(source, args)
//     Settings['render_font'] = tonumber(args[1])
//     TriggerEvent('chat:addMessage', {
//         color = { 255, 0, 0},
//         multiline = true,
//         args = {"Debug", "Pbttt testing font number ".. Settings['render_font']}
//     })
// end, false)

// RegisterCommand('testoffset', function(source, args)
//     Settings['offset_intensity'] = tonumber(args[1])
//     TriggerEvent('chat:addMessage', {
//         color = { 255, 0, 0},
//         multiline = true,
//         args = {"Debug", "Random offset intensity is now ".. Settings['offset_intensity']}
//     })
// end, false)



function RandomOffset(position, intensity) {  // i'll eventually simplify this but it'll work for now
    if (Math.round(Math.random()) == 1) {  // X VALUES
        position[0] -= Math.random()/intensity;
    } else {
        position[0] += Math.random()/intensity;
    }

    if (Math.round(Math.random()) == 1) {  // Y VALUES
        position[1] -= Math.random()/intensity;
    } else {
        position[1] += Math.random()/intensity;
    }

    return position
};

function DrawDamageText(position, value, color, size = 1, rate, entity) {
    const is_render_dynamic = Settings.dynamic_fade;
    if (rate == null) { rate = Settings.fade_speed };
    // checks if the timeout is true
    const offsetIntensity = Settings.offset_intensity;
    const positionOffsetBase = RandomOffset([0, 0], offsetIntensity);
    const font = Settings.render_font;
    const textOutline = true;
    let fadeCounter = 255;
    let currentAlpha = fadeCounter;
    let scaleMultiplier = size;
    let positionOffset = positionOffsetBase;
    const thread = setTick(async () => {
        // await Delay(0);
        if (currentAlpha < 0) { clearTick(thread); return; }  // this is probably really bad practice
        // local camPos = GetFinalRenderedCamCoord()
        let [onScreen, _x, _y] = GetScreenCoordFromWorldCoord(position[0], position[1], position[2]);
        // console.log(position[0]);
        // console.log(position[1]);
        // console.log(position[2]);
        // console.log(_x);
        // console.log(_y);


        // local onScreen, _x, _y = GetScreenCoordFromWorldCoord(position.x, position.y, position.z)
        if (IsEntityAPed(entity) && GetEntityHealth(entity) == 0) {  // this jitters the damage number when you kill a ped
            positionOffset = RandomOffset(positionOffset, offsetIntensity * 10)
        }
        // if (Settings['offset_mode'] == 'jitter') {
        //     positionOffset = RandomOffset(positionOffset, offsetIntensity * 10);
        // } else if (Settings['offset_mode'] == 'float') {  // this is complex
        //     // https://math.stackexchange.com/questions/604324/find-a-point-n-distance-away-from-a-specified-point-in-a-given-direction
        //     let angle = Math.atan2(positionOffset.x, positionOffset.y) - Math.atan2(_x, _y);

        //     positionOffset.x = positionOffset.x + Math.cos(angle) * Settings['offset_mode_fly_speed'];
        //     positionOffset.y = positionOffset.y + Math.sin(angle) * Settings['offset_mode_fly_speed'];
        //     onScreen = true;  // compromise for legacy fly
        // } else if (Settings['offset_mode'] == 'fly') {
        //     // GOAL - Get 3D world space positions for these 
        //     // Basically, we're gonna do a 3d simulation for an invisible object that is the origin of the 2d text
        //     // I'm probably really in over my head with this one.

        //     // This might be scrapped
        //     print('Function not yet implemented');
        // }
        // local distance = GetDistanceBetweenCoords(camPos.x, camPos.y, camPos.z, position.x, position.y, position.xyz.z, 1)
        // local scale = (1 / distance) * (perspectiveScale) * (1 / GetFinalRenderedCamFov()) * 75

        if (onScreen) {
            if (GAME == FIVEM) {
                SetTextScale(scaleMultiplier * 0.0, 0.35 * scaleMultiplier);
                // SetTextScale(0.0, scale)
                SetTextFont(font);
                SetTextProportional(true);
                SetTextColour(color[0], color[1], color[2], currentAlpha);
                // SetTextColour(224, 50, 50, currentAlpha);
                if (textOutline) { SetTextOutline(); }
                BeginTextCommandDisplayText("STRING");

                SetTextCentre(true);
                AddTextComponentSubstringPlayerName(value);
                EndTextCommandDisplayText(_x + positionOffset[0], _y + positionOffset[1]);
                // EndTextCommandDisplayText(_x, _y);
                // console.log('Did a render');
            } else if (GAME == REDM) {
                let vstr = CreateVarString(10, "LITERAL_STRING", tostring(value));  // the game will crash if VALUE is not a string
                SetTextColor(color[0], color[1], color[2], currentAlpha);
                SetTextScale(parseInt(scaleMultiplier * 0.0), parseInt(0.35 * scaleMultiplier));
                SetTextFontForCurrentCommand(font);
                SetTextCentre(true);

                DisplayText(vstr, _x + positionOffset[0], _y + positionOffset[1]);
            }
        }
        if (!is_render_dynamic) {  // people who use a static fade want it to update instantly
            rate = Settings.fade_speed;
        }
        fadeCounter = fadeCounter - rate;
        // currentAlpha = +Math.round(fadeCounter).toFixed(0)
        currentAlpha = Math.round(fadeCounter);

    });
}

function MergeVehicleHealths(veh) {
    let wheel_healths = 0;
    // print(GetVehicleNumberOfWheels(veh))
    for (let i = 0; i < GetVehicleNumberOfWheels(veh); i++) {
        wheel_healths += GetVehicleWheelHealth(veh, i);
    };
    let heli_healths = 0;
    if (GetVehicleClass(veh) == 15) {  // if vehicle is helicopter, get it's health stats
        heli_healths = GetHeliMainRotorHealth(veh) + GetHeliTailBoomHealth(veh) + GetHeliTailRotorHealth(veh);
    }
    return GetVehicleBodyHealth(veh) + GetVehicleEngineHealth(veh) + GetVehiclePetrolTankHealth(veh) + wheel_healths + heli_healths;
}


// console.log(`${key}: ${value}`);
function TrackEntityHealth() {
    // MERGE DIFFERENT ENTITY GROUPS
    TrackedEntities = {};  // this is "temporary". basically, we reconstruck the tracked entities every time to avoid mem leaks
    let entities = GetActivePlayers();

    for (let [, value] of Object.entries(GetGamePool('CPed'))) {
        entities.push(value);
    }
    for (let [, value] of Object.entries(GetGamePool('CVehicle'))) {
        entities.push(value);
    }

    // UPDATE LAST KNOWN HEALTH VALUES
    for (let [, ent] of Object.entries(entities)) {
        if (IsEntityAPed(ent)) {
            if (GAME == FIVEM) {
                TrackedEntities[ent] = {h: GetEntityHealth(ent), a: GetPedArmour(ent)}
            } else {
                TrackedEntities[ent] = {h: GetEntityHealth(ent), a: 0}
            }
        } else if (IsEntityAVehicle(ent)) {
            TrackedEntities[ent] = {h: MergeVehicleHealths(ent), a: 0}
        }
        // entities.push(value)
    }

    // UPDATE TRACKEDENTITIES TO REMOVE VOID ENTITIES
    for (let [, ent] of Object.entries(TrackedEntities)) {
        if (!entities.hasOwnProperty(ent) && TrackedEntities.hasOwnProperty(ent)) {
            const index = TrackedEntities.indexOf(ent);
            if (index > -1) {
                TrackedEntities.splice(index, 1);
                console.log(`Removed ${ent} from tracking list (index of ${index})`);
            }
        }
    }
}

function CalculateHealthLost(ent) {
    let health = 0;
    let armor = 0;
    if (IsEntityAPed(ent)) {
        health = TrackedEntities[ent].h - GetEntityHealth(ent);
        TrackedEntities[ent].h = GetEntityHealth(ent);
        // print(health)
        armor = TrackedEntities[ent].a - GetPedArmour(ent);
        TrackedEntities[ent].a = GetPedArmour(ent);
    } else if (IsEntityAVehicle(ent)) {
        health = TrackedEntities[ent].h - MergeVehicleHealths(ent);
        TrackedEntities[ent].h = MergeVehicleHealths(ent);
    }
    return {h: health, a: armor};
}

function CalculateDamagePosition(suspect, victim, victimDied) {
    // let [, position] = GetPedLastWeaponImpactCoord(suspect);
    // IsEntityAtCoord(victim, position, [10, 10, 10], 0, 1, 0)
    let [, position] = GetPedLastWeaponImpactCoord(suspect);
    // console.log(position)
    // console.log(typeof position)
    // if (IsEntityAtCoord(victim, position, [1, 1, 1], 0, 1, 0) || position == [0, 0, 0]) {
    if (position[0] == 0 && position[1] == 0 && position[2] == 0) {
        console.log('Position failure, trying backup')
        position = GetEntityCoords(victim);
        // position = [69, 69, 69]
        if (IsEntityAPed(victim)) {
            if (victimDied == undefined) { victimDied = IsPedFatallyInjured(victim); }
            if (victimDied && GetPedCauseOfDeath(victim) == 0) {
                position = GetPedBoneCoords(victim, 0x60F1);
            } else {
                let [success, bone] = GetPedLastDamageBone(victim);
                if (success) {
                    position = GetPedBoneCoords(victim, bone);
                } else {
                    position = GetPedBoneCoords(victim, 0x60F1);
                }
            }
        }
        // } else {
        //     position = GetEntityCoords(victim);
        // }
    }
    return position
}

function CalculateFadeRate(isMelee, weaponHash) {
    let fadeRate = Settings.fade_speed;

    if (isMelee == 0 && Settings.dynamic_fade) {
        fadeRate = Math.log(GetWeaponTimeBetweenShots(weaponHash)) / Math.log(0.7);
        if (fadeRate == Infinity) {
            fadeRate = 5;
        } else if (fadeRate <= 1) {
            fadeRate = 1;
        }
    }
}

function PrepareDamageText(victim, victimDied, dmg, position, fadeRate) {
    if (IsEntityAPed(victim) && victimDied && dmg.h != 0) {
        DrawDamageText(position, Math.round(-dmg.h + 100), Settings.color.damage_entity, 1, fadeRate, victim)
    } else {
        DrawDamageText(position, Math.round(-dmg.h), Settings.color.damage_entity, 1, fadeRate, victim)
    }
    
    if (dmg.a != 0) {
        DrawDamageText(position, Math.round(-dmg.a), Settings.color.damage_armor, 1, fadeRate, victim)
    }
    
    if (victimDied) {
        SendNUIMessage({play_audio: 'https://wiki.teamfortress.com/w/images/1/14/Killsound.wav'});
    } else {
        SendNUIMessage({play_audio: 'https://wiki.teamfortress.com/w/images/c/cf/Hitsound.wav'});
    }

}

onNet('ewdamagenumbers:sync_others', (suspect, victim, dmg, position, fadeRate) => {
    if (suspect != PlayerPedId() && victim != PlayerPedId() && Settings.local_damage) { return; }
    PrepareDamageText(victim, IsPedFatallyInjured(victim), dmg, position, fadeRate)

});

if (GAME == FIVEM) {
    setTick(async () => {
        await Delay(1000);
        TrackEntityHealth();
    })
    // AddEventHandler('CEventEntityDamaged', function (entities, eventEntity, args)
    //     print("CEventEntityDamaged \neventEnt: "..eventEntity.."\nentities: "..json.encode(entities).."\nargs: "..json.encode(args))
    //     // print('Start of dump')
    //     // for iter = 1, 8 - 1 do
    //     //     print(args[iter])
    //     // end
    //     // print('End of dump')
    // end)

    const writhe_says = ['Ouch!', 'Ow!', 'Ugh!'];
    on('CEventWrithe', function (args) {  // EXPAND
        console.log('Writhing')
        const thread = setTick(async () => {
            const victim = args[0];
            if (!IsPedFatallyInjured(victim)) {
                // items[Math.floor(Math.random()*items.length)]
                // Colors likely need to be adjusted. TODO: Add a color wheel to the settings menu for all color related settings
                DrawDamageText(GetPedBoneCoords(victim, 0xFE2C), writhe_says[Math.floor(Math.random()*writhe_says.length)], Settings.color.entity_writhe, 0.75);
                // Delay(500);
            } else { clearTick(thread); }
            await Delay(500);
        })

    })

    on('CEventDamage', function (victims, suspect) {
        // console.log(victims);
        // console.log(suspect);
        for (let [, victim] of Object.entries(victims)) {
            if (!IsPedAPlayer(suspect) || !IsPedAPlayer(victim)) { return; }
            const dmg = CalculateHealthLost(victim);
            const position = CalculateDamagePosition(suspect, victim);
            const weaponHash = GetPedCauseOfDeath(victim);
            const isMelee = GetWeaponDamageType(weaponHash) == 2;
            const fadeRate = CalculateFadeRate(isMelee, weaponHash);

            emitNet("ewdamagenumbers:update_others", suspect, victim, dmg, position, fadeRate);
        }
        // if (!skip_damage_render) {
        //     if (IsEntityAPed(victim) && IsPedFatallyInjured(victim) && dmg.h != 0) {
        //         DrawDamageText(position, Math.round(-dmg.h + 100), Settings['color']['damage_entity'], 1, fadeRate, victim)
        //     } else {
        //         DrawDamageText(position, Math.round(-dmg.h), Settings['color']['damage_entity'], 1, fadeRate, victim)
        //     }
            
        //     if (dmg.a != 0) {
        //         DrawDamageText(position, Math.round(-dmg.a), Settings['color']['damage_armor'], 1, fadeRate, victim)
        //     }
        // }

    })

    // use GetWeaponTimeBetweenShots to get dynamic fade speed per weapon
    // use log 0.7 (x) to get Fade Speed from TimeBetweenShots. If output is below 0.1, keep it at 0.1. Refine later
    on('gameEventTriggered', function (eventName, data) {
        if (eventName != 'CEventNetworkEntityDamage') { return; }
        // console.log(Settings.color.damage_entity);

        const victim = data[0];
        // console.log(typeof victim);
        const suspect = data[1];

        if (IsPedAPlayer(suspect) && IsPedAPlayer(victim)) { return; }

        if (suspect != PlayerPedId() && victim != PlayerPedId() && Settings.local_damage) { return; }
        // if (DebugFlags.prefer_pvp == true && !IsEntityAVehicle(victim)) { return; }
        // console.log('This should only show if it is a vehicle');

        let offset = 0;

        if (BUILD >= 2060) {
            offset++;
            if (BUILD >= 2189) {
                offset++;
            }
        }

        const victimDied = data[3 + offset];
        const weaponHash = data[4 + offset];
        const isMelee = data[9 + offset];
        const damageType = data[10 + offset];

        // Would it be funny to render blood drop emotes twice a second for ten seconds when the below is true?
        // Yes.
        // Am I gonna do it...?
        // Maybe, when I clean up everything. It'll be an easter egg that can be toggled
        // console.log(`victimDied? ${victimDied}`)

        const position = CalculateDamagePosition(suspect, victim, victimDied);

        const fadeRate = CalculateFadeRate(isMelee, weaponHash);

        let skip_damage_render = false
        if (Settings.ignore_vehicles) {
            if (IsEntityAVehicle(victim)) {
                skip_damage_render = true
            }
        }

        let dmg = CalculateHealthLost(victim)
        if (!skip_damage_render) {
            // if (IsEntityAPed(victim) && IsPedFatallyInjured(victim) && dmg.h != 0) {  // consider using victimDied instead of IsPedFatallyInjured

            PrepareDamageText(victim, victimDied, dmg, position, fadeRate)
            // if (IsEntityAPed(victim) && victimDied && dmg.h != 0) {  // consider using victimDied instead of IsPedFatallyInjured
            //     DrawDamageText(position, Math.round(-dmg.h + 100), Settings.color.damage_entity, 1, fadeRate, victim)
            // } else {
            //     DrawDamageText(position, Math.round(-dmg.h), Settings.color.damage_entity, 1, fadeRate, victim)
            // }
            
            // if (dmg.a != 0) {
            //     DrawDamageText(position, Math.round(-dmg.a), Settings.color.damage_armor, 1, fadeRate, victim)
            // }

            // if (victimDied) {
            //     SendNUIMessage({play_audio: 'https://wiki.teamfortress.com/w/images/1/14/Killsound.wav'});
            // } else {
            //     SendNUIMessage({play_audio: 'https://wiki.teamfortress.com/w/images/c/cf/Hitsound.wav'});
            // }
        }


        switch (damageType) {
            case 93:
                DrawDamageText(position, 'Pop!', Settings.color.damage_vehicle_ding, 0.5, fadeRate, victim) // tire damage
                break;
            case 116:
            case 117:  // 117 happens with the exhaust pipe of the Imponte Pheonix. No idea what this is, putting it here for now.
                DrawDamageText(position, 'Ding!', Settings.color.damage_vehicle_ding, 0.5, fadeRate, victim)  // general vehicle damage
                break;
            case 120:
            case 121:
            case 122:
                DrawDamageText(position, 'Smash!', Settings.color.damage_vehicle_ding, 0.5, fadeRate, victim)  // window damage
                break;
        }
    })
}
// } else if (GAME == REDM) {
//     function RenderStepRDR3(victim, suspect, defaultPosition, value) {
//         let positon, entity = RaycastFromPlayer();
//     }
// }

//     end)
// } else if (GAME == REDM) {  // RedM doesn't have the `gameEventTriggered` handler
//     function RenderStepRDR3(victim, suspect, defaultPosition, value)  // there is a return, and if you return in the above Thread, it exits the thread
//         if suspect ~= PlayerPedId() and victim ~= PlayerPedId() and Settings['local_damage'] == true then
//             return  // if i'm not a victim or suspect, and I only want to show my damage, return
//         end

//         // TODO: OneSync causes issues relating to the activation of the Game Event. We need to fix it.
//         // Basically, if a horse isn't visible but dead, it'll despawn, but when it gets back into view, it'll spawn and die, triggering the event.
//         // Oddity: It only seems to happen with horses that were attached to a carriage.

//         // Potential Solution: Take advantage of TrackedEntities, with a simple data value of alive = true or false

//         // Interesting to note: In Armadillo, the body pits corpses are spawned in as peds and then killed.
//         // Workaround: Check for those specific models and don't render if they are the entity.
//         // This could also be a OneSync thing, but I have yet to test that.

//         local position, entity = RaycastFromPlayer()

//         if entity ~= victim then
//             local is_ped, bone = GetPedLastDamageBone(victim)
//             if is_ped == 1 then
//                 position = GetPedBoneCoords(victim, bone)
//             else
//                 position = defaultPosition
//             end
//         end

//         DrawDamageText(position, round(-value), Settings['color']['damage_entity'], 1, victim)

//     end
//     Citizen.CreateThread(function()
//         while true do
//             Citizen.Wait(0)

//             local size = GetNumberOfEvents(0)
//             if size > 0 then
//                 for i = 0, size - 1 do
//                     local eventAtIndex = GetEventAtIndex(0, i)
//                     if eventAtIndex == 402722103 then  // EVENT_ENTITY_DAMAGED
//                     // if eventAtIndex == -1315570756 then  // EVENT_NETWORK_DAMAGE_ENTITY
//                         local eventDataSize = 9
//                         local eventDataStruct = DataView.ArrayBuffer(8*eventDataSize)  // not a fan of using DataView here. i'll rewrite it someday
//                         for iter = 0, eventDataSize - 1 do
//                             eventDataStruct:SetInt32(8*iter, 0)
//                         end
                        
//                         // local eventDataExists = GetEventData(0, i, eventDataStruct:Buffer(), eventDataSize)  // doesn't work?

//                         local eventDataExists = Citizen.InvokeNative(0x57EC5FA4D4D6AFCA, 0, i, eventDataStruct:Buffer(), eventDataSize)  //GetEventData
//                         if eventDataExists then
//                             local victim = eventDataStruct:GetInt32(0)
//                             local suspect = eventDataStruct:GetInt32(8)
//                             local position = vector3(eventDataStruct:GetFloat32(8*6), eventDataStruct:GetFloat32(8*7), eventDataStruct:GetFloat32(8*8))
//                             local value = eventDataStruct:GetFloat32(32)

//                             RenderStepRDR3(victim, suspect, position, value)
//                         end

//                     end
//                 end
//             end
//         end
//     end)

// }
