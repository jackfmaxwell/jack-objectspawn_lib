fx_version 'cerulean'

game 'gta5'

author 'JACK'

description 'AI Library'

version '0.1'

lua54 'yes'



client_scripts{
	'client.lua',
	'gizmos_client.lua',
}

server_scripts{
	'server.lua'
}

shared_scripts {
	'config.lua',
	'@ox_lib/init.lua'
 }


 ui_page 'web/dist/index.html'

 files {
	'web/dist/index.html',
	'web/dist/**/*',
}