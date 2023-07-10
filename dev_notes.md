# TODO: RENAME SCRIPT. IT NOW HAS HITMARKER AUDIO, AND THE NAME NO LONGER FITS.

# These devnotes where from when I initially started work on this project and do not represent what the script currently does.

This is a script I started working on a few months ago, out of the curious idea that maybe I could make an idea work; displaying the amount of damage you did to an entity, next to that entity.

Within a week, I had a decent prototype, but I haven't felt ready to release it until now.

Basically, if something has health, this script will try to show damage that has been done to it. It isn't perfect, some dumpsters, when shot in specific places have health, but they are invincible, so no damage is done or shown.

This script is definitely not viable for roleplay servers, although if the roleplay server has some sort of VR event, I could definitely see this script being fun to have. Otherwise, it's just here for people curious about weapon damage and pedestrian and vehicle health.

https://github.com/elenawinters/ewdamagenumbers
https://www.youtube.com/watch?v=K7FZ0ob-8XU

#### THE ABOVE IS FOR THE FIVEM FORUMS WHENEVER I'M ABLE TO POST ON THERE
# Goals

Use GetAllPeds, check all ped every frame for GetPedSourceofDamage, and render hitmarkers on the aggressors screen

before getting damage source, check using HasEntityBeenDamagedByAnyObject if they've been damaged recently (this might not be a good idea)


## new workflow

use GetWeaponDamage to get damage, correct for headshots

## old workflow

dict = {ped: {
        h: 100  // health
        a: 100  // armor
    }
}

if HasPlayerDamagedAtLeastOnePed == true:
    ClearPlayerHasDamagedAtLeastOnePed;
    for ped in GetAllPeds:
        if src := GetPedSourceOfDamage(ped):
            old_armor = dict[ped][a]
            old_health = dict[ped][h]
            new_armor = GetPedArmour(ped)
            new_health = GetEntityHealth(ped)

            if old_health != new_health:
                if new_health > old_health:
                    dmg = "Error"
                else:
                    dmg = old_health - new_health
                DrawText3D(src, dmg, red)  // render damage
                if new_health >= 0:
                    dict[ped][h] = new_health
                else:
                    del dict[ped]
            if old_armor != new_armor
                if new_armor > old_armor:
                    dmg = "Error"
                else:
                    dmg = old_armor - new_armor
                DrawText3D(src, dmg, blue)  // render damage
                dict[ped][a] = new_armor

                


