rebol [
	File: %dns-async-example.r
	Title: "Example for async dns:// and spam dns server"
	Author: "Romano Paolo Tenca"
	Date: 04/10/03
	Purpose: {
		Example code to:
			1) use the dns:// protocol in async mode
			2) use the dns:// protocol to check spam address in async mode
	}
	Note: {
		This program requires View (1.2.1 or later) to visualize results
		(and test async behaviour), but the	async code itself should work
		also under Core. Change the View code with some prints to test it
		under Core.
	}
 	library: [
 		level: 'intermediate
 		platform: 'all
 		type: [tutorial]
 		domain: [internet email]
 		tested-under: support: license: see-also: none
 	]	
]

;----------- Support functions ----------
wait-find: func [
	"Find a port in the system wait list"
	port [port!]
][find system/ports/wait-list port]
wait-stop: func [
	"Remove a port from the system wait list"
	port [port!]
][remove wait-find port]
wait-start: func [
	"Insert a port in the system wait list"
	port [port!]
][any [wait-find port insert tail system/ports/wait-list port]]

;----------- dns-spam-ctx ----------
dns-spam-ctx: context [
	host-list: reduce [

		;dns address    		dns check for spam

		"relays.visi.com"		127.0.0.2
		"list.dsbl.org"			127.0.0.2
		"bl.spamcop.net"		127.0.0.2
		;"dsn.rfc-ignorant.org"	127.0.0.2
		;"sbl.spamhaus.org"		127.0.0.2
	]

	ask-address: func [
		"Ask an address conversion to an dns:///async port"
		port [port!]
	][
		;visualize a message
		if value? 'f-a [
			insert tail f-a/text reform ["Asking" first port/user-data/read-list "to" port/user-data/host newline]
			f-a/line-list: none
			show f-a
		]
		;inserting an address in a dns:// async port starts the conversion
		;when the result will be ready, the port/awake function will be called
		insert port rejoin [reverse first port/user-data/read-list "." port/user-data/host]
	]

	next-item: func [
		"Get the next address to test"
		port [port!]
		result [logic!] /local tmp user-data
	][
		user-data: port/user-data
		;next address to test
		user-data/read-list: skip user-data/read-list 2
		;at the end? -> stop
		either tail? user-data/read-list [
			wait-stop port ;remove the port from the system wait list
			close port
		][
			ask-address port ;ask for a new address
		]
	]

	;The awake function of he dns:// port
	spam-awake: func [port /local result][
		;read the result from itself and check it
		result: port/user-data/check = copy port
		;remember the result ('or is used to not overwrite the results of others ports)
		port/user-data/read-list/2: port/user-data/read-list/2 or result
		;if match the required value, print a message
		if result [
			;visualize something
			insert tail f-a2/text reform [
				first port/user-data/read-list  "is spam for" port/user-data/host newline
			]
			f-a2/line-list: none
			show f-a2
		]
		next-item port result ;start to check the next address
		false ;= continue to wait
	]

	set 'start-spam func [
		"Open and initialize a dns:///async port for every host"
		read-list [block!]
		/local port
	][
		foreach [hst check] host-list [
			port: open/no-wait make port! [
				scheme: 'dns
				host: "/async"
				user-data: reduce ['host hst 'check check 'read-list read-list]
				awake: :spam-awake
			]
			wait-start port ;insert the port in the system wait-list (for wait [])
			ask-address port ;ask the first address
		]
	]
]

;example
;IP to check
test-list: reduce [
    192.168.1.35 false
    217.128.120.69 false
    213.36.114.1 false
    217.132.9.69 false
    210.49.39.53 false
    29.182.79.223 false
    213.41.147.86 false
    193.70.192.59 false
    65.35.3.133 false
    170.139.28.247 false
    193.70.192.90 false
    211.28.63.207 false
    193.70.192.55 false
    210.101.90.44 false
    193.70.192.55 false
    68.102.53.146 false
    167.16.235.87 false
    211.28.63.207 false
    193.70.192.90 false
    62.183.152.122 false
    61.143.117.79 false
]
start-spam test-list ;initialize all
view layout [
	across 
	f-a: area 300x400 para [] f-a2: area 300x400 para [] return
	button "quit" [quit]
]
