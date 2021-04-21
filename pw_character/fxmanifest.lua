fx_version 'bodacious'
games {'gta5'} -- 'gta5' for GTAv / 'rdr3' for Red Dead 2, 'gta5','rdr3' for both

description 'PixelWorld Character Appearance'
name 'PixelWorld: pw_character'
author 'PixelWorldRP [Dr Nick] - https://PixelWorldrp.com'
version 'v1.0.0'

server_scripts {
    '@pw_mysql/lib/MySQL.lua', -- Required for MySQL Support
    'config.lua',
    'server/main.lua',
}

client_scripts {
    'config.lua',
    'client/tattoos.lua',
    'client/skins.lua',
    'client/main.lua'
}

ui_page 'nui/index.html'

files {
    'nui/index.html',
    'nui/pw_character.js',
    'nui/style.css',
}
