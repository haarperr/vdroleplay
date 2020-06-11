resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

ui_page 'html/index.html'

files {
    'html/app.js',
    'html/style.css',
    'html/index.html'
}

client_scripts {    
    --config
    'config.lua',
    
    --scripts
    'client/functions.lua',
    'client/client.lua',
    'client/death.lua',
    'client/permissions.lua',

    --language
    'lang/en-US.lua',
    'lang/nl-NL.lua'
}

server_scripts { 
    'server/server.lua',
    '@mysql-async/lib/MySQL.lua'
}

dependencies {
    'mysql-async'
}