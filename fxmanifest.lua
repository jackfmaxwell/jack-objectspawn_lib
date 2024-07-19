fx_version 'cerulean'

game 'gta5'

author 'JACK'

description 'Object spawner'

version '1.0.0'

license 'GPL3.0'

lua54 'yes'

--Entity view is from https://github.com/qbcore-framework/qb-adminmenu (GPL 3.0) Modifications made
--Gizmos is from https://github.com/Demigod916/object_gizmo (GPL 3.0) Modifications made
client_scripts{
	'client/**/*.lua',
}

server_scripts{
	'server/**/*.lua',
}

shared_scripts {
	'@ox_lib/init.lua',
	'config.lua',
 }
 escrow_ignore {
	'**/*'
}


 ui_page 'web/dist/index.html'

 files {
	'web/dist/index.html',
	'web/dist/**/*',
}