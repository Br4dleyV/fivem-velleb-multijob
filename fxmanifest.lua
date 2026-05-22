fx_version "cerulean"
game "gta5"
lua54 "yes"

author 'Bradley <bradley@velleb.com>'
description "Multi-Job System with ox-lib and oxmysql"
version 'v1.1.0'

dependencies {
    "oxmysql",
    "ox_lib",
}

shared_scripts {
    "@ox_lib/init.lua",
    "shared/config.lua",
}

client_scripts {
    'client/bridge.lua',
    "client/main.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    'server/bridge.lua',
    "server/main.lua",
}

escrow_ignore {
    'shared/config.lua',
}
