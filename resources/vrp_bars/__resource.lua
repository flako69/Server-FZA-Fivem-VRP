resource_manifest_version '77731fab-63ca-442c-a67b-abc70f28dfa5'

client_script{ 
	'lib/Proxy.lua',
	'lib/Tunnel.lua',
	'client.lua'
}

server_script{
	'@vrp/lib/utils.lua',
	'server.lua'
}