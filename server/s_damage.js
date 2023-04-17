console.log('EWDamageNumbers is running on the server.')

onNet('ewdamagenumbers:update_others', (suspect, victim, message, position, fadeRate) => {
    console.log(`${suspect} hurts ${victim} for ${JSON.stringify(message)} at ${position}`);
    // console.log(`${suspectName}(${suspect}) killed ${victimName}(${victim}) with ${weaponHash}. Critical(${criticalHit}) Cause(${getKeyByValue(DamageTypes, damageType)}) Bone(${getKeyByValue(PedBones, damageBone[1])}) Killstreak(${killStreaks[suspect]})`);
    emitNet('ewdamagenumbers:sync_others', -1, suspect, victim, message, position, fadeRate);



    // console.log('Server has been notified to update the killfeed globally');
})