fx_version 'cerulean'
games { 'gta5', 'rdr3' }

author 'Elena Winters'
description 'Shows amount of damage you dealt to an entity next to that entity'
version '0.2.1'

rdr3_warning 'I acknowledge that this is a prerelease build of RedM, and I am aware my resources *will* become incompatible once RedM ships.'

ui_page 'html/ui.html'

files {
    'html/ui.html',
    'html/script.js',
    'html/style.css',
}

client_script 'dmgconfig.lua'
client_script 'dataview.lua'
client_script 'dmgclient.lua'
client_script 'dmghud.lua'
