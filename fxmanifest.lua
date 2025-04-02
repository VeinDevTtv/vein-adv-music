-- fxmanifest.lua
fx_version 'cerulean'
games { 'gta5' }

author 'Vein'
description 'QBCore Music Performance System'
version '1.0.0'

shared_script 'config.lua'

client_script 'client.lua'
server_script 'server.lua'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/static/js/*.js',
    'html/static/css/*.css',
    'html/static/media/*'
}
