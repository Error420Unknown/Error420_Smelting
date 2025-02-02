fx_version 'cerulean'
game 'gta5'
lua54 'yes'

author 'Error420:Unknown'
description 'Simple Smelting Script'
version '1.0.0'

shared_script '@ox_lib/init.lua'

client_scripts {
    'client/smelting_cl.lua',
    'config.lua'
}

server_scripts {
    '@oxmysql/lib/MySQL.lua',
    'server/smelting_sv.lua',
    'config.lua'
}