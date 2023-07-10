fx_version 'cerulean'
games { 'gta5', 'rdr3' }

author 'Elena Winters'
description 'Hitmarkers in FiveM/RedM. Shows amount of damage you dealt to an entity next to that entity'
version '0.3.0+23.7.10'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

dependencies {
    'twiliCore'
}

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/script.js',
    'html/style.css',
}

shared_scripts {
    '@twiliCore/shared/u_common.js'
}

client_scripts {
    '@twiliCore/client/c_globals.js',
    'client/c_config.js',
    'client/c_damage.js',

    'dmghud.lua'
}

-- dmghud has yet to be ported over to JavaScript. It will likely be moved into twiliDebug