fx_version 'cerulean'
games { 'gta5', 'rdr3' }

author 'Elena Winters'
description 'Shows amount of damage you dealt to an entity next to that entity'
version '0.3.0'

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

-- shared_scripts {
--     'shared/Vector3.js'
-- }

client_scripts {
    'client/c_globals.js',
    'client/c_config.js',
    'client/c_damage.js'
}

-- server_scripts {
--     'server/s_damage.js'
-- }

-- client_script 'dmgconfig.lua'
-- client_script 'dataview.lua'
-- client_script 'dmgclient.lua'
client_script 'dmghud.lua'
