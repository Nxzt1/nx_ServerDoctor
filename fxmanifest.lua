fx_version 'cerulean'
game 'common'
lua54 'yes'

name 'NX_ServerDoctor'
description 'Revisa la configuración del servidor y explica los problemas en lenguaje claro (solo lectura).'
author 'Nxsty'
version '1.0.0'
license 'Propietaria: uso gratuito, prohibida la venta y la redistribución (ver LICENSE)'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/app.js',
    'html/fonts/*.woff2',
    'html/fonts/OFL.txt',
}

client_script 'client.lua'

server_scripts {
    'config.lua',
    'server/core.lua',
    'server/resources.lua',
    'server/report.lua',
    'server/checks/dependencias.lua',
    'server/checks/manifiestos.lua',
    'server/checks/permisos.lua',
    'server/checks/framework.lua',
    'server/checks/imagenes.lua',
    'server/checks/rendimiento.lua',
    'server/checks/rutasnui.lua',
    'server/checks/erroreslog.lua',
    'server/main.lua',
}
