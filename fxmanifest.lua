-- fxmanifest.lua
fx_version 'cerulean'
games { 'gta5' }

author 'Vein'
description 'QBCore Music Performance System'
version '1.2.0'

shared_script 'config.lua'

client_script 'client.lua'
server_script {
    '@oxmysql/lib/MySQL.lua',
    'server.lua'
}

ui_page 'vein-adv-music-ui/build/index.html'

files {
    'vein-adv-music-ui/build/index.html',
    'vein-adv-music-ui/build/static/js/*.js',
    'vein-adv-music-ui/build/static/css/*.css',
    'vein-adv-music-ui/build/static/media/**/*'
}

dependencies {
    'qb-core',
    'oxmysql',
    'ox_inventory',
    'ox_lib',
    'xsound'
}

lua54 'yes'
