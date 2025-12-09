fx_version "cerulean"
game "gta5"
lua54 "yes"

description "Multi-Job System with ox-lib and oxmysql"
version 'v0.1'
author "https://velleb.be"

dependencies {
    "oxmysql",
    "ox_lib",
}

shared_scripts {
    "@ox_lib/init.lua",
    "shared/config.lua",
}

client_scripts {
    "client/main.lua",
}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    "server/main.lua",
}