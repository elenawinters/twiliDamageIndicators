// JAVASCRIPT REWRITE
// I want the ability to do more things, and LUA is just too barebones and restrictive.
// This JavaScript rewrite will allow new things to happen and also give me experience in the language.

// TODO: Test OneSync Legacy and OneSync Infinity functionality on both FiveM and RedM 
// Status: Issues with RedM OneSync Infinity. OneSync Legacy still needs to be tested.

// Issues: When running, the damage text kinda wobbles up and down. I'm not sure if I can fix this, but I'mma try

console.log('We are here')

const Delay = (ms) => new Promise(res => setTimeout(res, ms));

console.log(`Code path is set to ${exports.twiliCore.GAME()}`);


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

RegisterNuiCallback('fadespeedstatus', (data) => {
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
            if (exports.twiliCore.GAME() == exports.twiliCore.FIVEM()) {
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
            } else if (exports.twiliCore.GAME() == exports.twiliCore.REDM()) {
                let vstr = CreateVarString(10, "LITERAL_STRING", value.toString());  // the game will crash if VALUE is not a string
                SetTextColor(color[0], color[1], color[2], currentAlpha);
                SetTextScale(scaleMultiplier * 0.0, 0.35 * scaleMultiplier);
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

// function PrepareDamageText(victim, victimDied, dmg, position, fadeRate) {
//     if (IsEntityAPed(victim) && victimDied && dmg.h != 0) {
//         DrawDamageText(position, Math.round(-dmg.h + 100), Settings.color.damage_entity, 1, fadeRate, victim)
//     } else {
//         DrawDamageText(position, Math.round(-dmg.h), Settings.color.damage_entity, 1, fadeRate, victim)
//     }
    
//     if (dmg.a != 0) {
//         DrawDamageText(position, Math.round(-dmg.a), Settings.color.damage_armor, 1, fadeRate, victim)
//     }
    
//     if (victimDied) {
//         SendNUIMessage({play_audio: 'https://wiki.teamfortress.com/w/images/1/14/Killsound.wav'});
//     } else {
//         SendNUIMessage({play_audio: 'https://wiki.teamfortress.com/w/images/c/cf/Hitsound.wav'});
//     }

// }

// onNet('ewdamagenumbers:sync_others', (suspect, victim, dmg, position, fadeRate) => {
//     if (suspect != PlayerPedId() && victim != PlayerPedId() && Settings.local_damage) { return; }
//     PrepareDamageText(victim, IsPedFatallyInjured(victim), dmg, position, fadeRate)

// });

if (exports.twiliCore.GAME() == exports.twiliCore.FIVEM()) {
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
}


onNet('twiliCore:damage:event', (suspect, victim, situation) => {
    if (suspect.entity != PlayerPedId() && victim.entity != PlayerPedId() && Settings.local_damage) { return; }
    const fadeRate = exports.twiliCore.GAME() == exports.twiliCore.FIVEM() ? CalculateFadeRate(situation.isMelee, situation.weaponHash) : 1;
    let skip_damage_render = false
    if (Settings.ignore_vehicles) {
        if (IsEntityAVehicle(victim.entity)) {
            skip_damage_render = true
        }
    }

    let killSound = 'https://wiki.teamfortress.com/w/images/1/14/Killsound.wav';
    let hitSound = 'https://wiki.teamfortress.com/w/images/c/cf/Hitsound.wav';

    if (IsEntityAPed(victim.entity)) {
        SendNUIMessage({play_audio: situation.isDead ? killSound : hitSound});
    }

    // This is pretty janky code.
    // let dmg = CalculateHealthLost(victim.entity)
    if (!skip_damage_render) {
        // if (IsEntityAPed(victim) && IsPedFatallyInjured(victim) && dmg.h != 0) {  // consider using victimDied instead of IsPedFatallyInjured
        if (exports.twiliCore.GAME() == exports.twiliCore.FIVEM() && IsEntityAPed(victim.entity) && situation.isDead && situation.healthLost.h != 0) {
            DrawDamageText(situation.position, exports.twiliCore.math().round(-situation.healthLost.h + 100, Settings.precision), Settings.color.damage_entity, 1, fadeRate, victim.entity)
        } else {
            DrawDamageText(situation.position, exports.twiliCore.math().round(-situation.healthLost.h, Settings.precision), Settings.color.damage_entity, 1, fadeRate, victim.entity)
        }
        
        if (situation.healthLost.a != 0 && situation.healthLost.a != null) {
            DrawDamageText(situation.position, exports.twiliCore.math().round(-situation.healthLost.a, Settings.precision), Settings.color.damage_armor, 1, fadeRate, victim.entity)
        }
        
        // if (situation.victimDied) {
        //     SendNUIMessage({play_audio: 'https://wiki.teamfortress.com/w/images/1/14/Killsound.wav'});
        // } else {
        //     SendNUIMessage({play_audio: 'https://wiki.teamfortress.com/w/images/c/cf/Hitsound.wav'});
        // }

        // PrepareDamageText(victim.entity, situation.isDead, situation.healthLost, situation.position, fadeRate)

    }

    switch (situation.damageTypeSecondary) {
        case 93:
            DrawDamageText(situation.position, 'Pop!', Settings.color.damage_vehicle_ding, 0.5, fadeRate, victim.entity) // tire damage
            break;
        case 116:
        case 117:  // 117 happens with the exhaust pipe of the Imponte Pheonix. No idea what this is, putting it here for now.
            DrawDamageText(situation.position, 'Ding!', Settings.color.damage_vehicle_ding, 0.5, fadeRate, victim.entity)  // general vehicle damage
            break;
        case 120:
        case 121:
        case 122:
            DrawDamageText(situation.position, 'Smash!', Settings.color.damage_vehicle_ding, 0.5, fadeRate, victim.entity)  // window damage
            break;
    }

    // emitNet("ewdamagenumbers:update_others", suspect, victim, situation.healthLost, situation.position, fadeRate);
    // PrepareDamageText(victim.entity, situation.isDead, situation.healthLost, situation.position, fadeRate)

});
