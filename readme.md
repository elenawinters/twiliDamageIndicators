# twiliDamageIndicators

This FiveM/RedM script displays damage next to entities that you have hurt.

When you kill a ped, the damage number will jitter around.

It also has hitmarker sounds. Currently, these are hardcoded and finicky. If you wish to disable this, you can comment out lines [259, 260, and 261](https://github.com/elenawinters/ewdamagenumbers/blob/feature/client/c_damage.js#L259-L261) in c_damage.js.

This is the development branch. Everything you see here is currently in progress and may not work correctly.

## Dependencies

Currently, the only dependency is [twiliCore](https://github.com/elenawinters/twiliCore).

## Commands

`/dmghud` | Display the HUD to change EWDN settings.

`/showhealth` | Show how much health a vehicle currently has. Will be removed in future update.

`/hidehealth` | Turn off the current vehicle health overlay. Will be removed in future update.

`/testfont` | Current test command to test a font. Will be removed in future update.

`/testoffset` | Current test command to test intensity of text offset. Will be removed in future update.

## TODO

- Remove legacy code.
- Update/overhaul settings HUD.