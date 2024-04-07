fx_version 'cerulean'

game 'gta5'

author 'JACK'

description 'AI Library'

version '0.1'

lua54 'yes'



client_scripts{
	'@PolyZone/client.lua',
	'@PolyZone/EntityZone.lua',
	'@PolyZone/BoxZone.lua',
	'@PolyZone/CircleZone.lua',
	'@PolyZone/RemoveZone',
}

server_scripts{

}

shared_scripts {
	'config.lua',
	'@ox_lib/init.lua'
 }

