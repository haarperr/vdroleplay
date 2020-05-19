resource_manifest_version '44febabe-d386-4d18-afbe-5e627f4af937'

ui_page 'html/index.html'

files {
    'html/app.js',
    'html/style.css',
    'html/index.html'
}

client_scripts {    
    'client.lua',
    '@vd-core/client/functions.lua'
}

server_scripts { 
    'server.lua',
    '@mysql-async/lib/MySQL.lua'
}

dependencies {
    'vd-core',
    'mysql-async'
}