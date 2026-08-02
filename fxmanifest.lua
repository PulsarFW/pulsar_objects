fx_version 'cerulean'
games { 'gta5' }

name 'Pulsar Objects'
description 'Persisted world objects with in-game placement and DB-backed storage'
author 'Artmines - maintained for Pulsar Framework'
url 'https://pulsarframe.work'
version 'v1.0.0'

version_check 'yes'
github 'https://github.com/PulsarFW/pulsar_objects'

client_script '@pulsar_core/components/cl_error.lua'
shared_script '@pulsar_core/core/sh_pulsar.lua'
client_script '@pulsar_pwnzor/client/check.lua'
server_script '@oxmysql/lib/MySQL.lua'

shared_scripts({
	'shared/**/*.lua',
})

client_scripts({
	'client/**/*.lua',
	'client/gizmo.js',
})

server_scripts({
	'server/**/*.lua',
})

lua54 'yes'