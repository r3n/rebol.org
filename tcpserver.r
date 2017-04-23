REBOL [
	file:		%tcpserver.r
	title:		"TCP Server"
	author:		"Semseddin (Endo) Moldibi"
	version:	1.0.0
	date:		2010-07-28
	purpose:	"Opens a TCP port and accepts multiple client connections."
	Library: [
        level: 'intermediate
        platform: 'all
        type: [how-to tools]
        domain: 'tcp
        tested-under: [view 2.7.7.3.1 on "WinXP Pro"]
        support: "semseddin/at/gmail.com"
        license: 'public-domain
        see-also: none
	]
]

if not empty? port-number: ask "TCP Port number? " [
	;Open server port
	server: open/no-wait join tcp://: port-number
	print reform ["Port" port-number "opened."]

	;list of ports to wait
	wait-for: make block! 10

	;first one is server, rest will be clients
	append wait-for server

	forever [
		;wait for multiple clients AND server for new connections
		which: wait wait-for
		either which = server [
			;add the newly connected client to the wait list
			append wait-for first which
			print reform ["New client connected, number of active clients:" (length? wait-for) - 1]
		] [
			;print the incoming message comes from the Nth client
			either msg: copy which [
				print reform [
					"New message from client"
					(index? find wait-for which) - 1
					":"
					msg
				]
			] [
				;remove the disconnected client from the wait list
				print reform [
					"Client" (index? find wait-for which) - 1 "disconnected"
				]
				remove find wait-for which
			]
		]
	]
]
