REBOL [
	Title:   "Remote file Utility"
	Date:     2001-12-01
	Purpose: "Exchange files over a network without ftp"
	File:    %remote-file.r
	Author:  "Ingo Hohmann"
	Version:  0.0.2
	Web: http://www.h-o-h.org
	Category: [ Network Ftp ]
	ToDo:    [
		{error handling}
	]
	Usage: {
		As a script:

		remote-file.r receive
		starts the server that listens for files to be sent

		remote-file.r send a_file_name
		sends the file a_file_name

    As a library

    do-receive
		- starts the file recieve server

		do-receive/file filename
		- receives exactly one file, and stores under filename

		do-send afile
		- sends one file

		do-send ablock-of-files
		- sends all files named in the block

		setup
		- asks the user for host/port

		do-setp host port
		- sets host to host, and port to port
		}
	known-bugs: [
		{Missing error handling in the server part.}
	]
	library: [
		level: 'intermediate
		platform: 'all
		type: [tool module]
		domain: [ftp files other-net]
		tested-under: [core-2.5.6.4.2]
		support: none
		license: none
		see-also: none
	]
]

; helpers
din-date: func [
"Shows date in DIN format (iho)"
	/convert date [date! string!]
	/local pad
][
	pad: func [d] [either 2 = length? d: to-string d [d] [join "0" d]]
	date: either none? date [now/date] [to-date date]
	rejoin ["" date/year "-" pad date/month "-" pad date/day]
]

error: func [
	{Throws a custom error}
	info [block!]
] [
	throw make error! append copy [ h-o-h ] compose info
]

on-error: func [
	{tries value, and if it returns an error,
		error-block is done.
		In the error block 'err contains the disarmed error.}
		value
		error-block
	/local err
][
	either error? set/any 'err try :value [
		err: disarm err
		do bind error-block 'err
	][
		err
	]
]


system/error: make system/error [
	h-o-h: make object! [
		code: 1000
		type: "h-o-h Script errors"
		read: ["Unable to read from:" :arg1]
		write: ["Unable to write to:" :arg1]
		network: ["Unable to connect to:" :arg1]
		type-check: ["Expected value of type" :arg1 "but recieved" :arg2 "(" :arg3 ")"]
	]
]

; -------------- remote file

remote-file: make object! [
	header: context [
		Title:   "H-O-H Remote File"
		Author:  "Ingo Hohmann"
		Email:   ingo@h-o-h.org
		Purpose: "Exchange files over a network, without the need for ftp"
			Version: 0.1
	]

	my-host: "localhost"
	my-port: 4321
	init?: false

	setup: func [
		"Ask for host and port"
		/local host port
	][
		print "Please tell me about the host you want to connect to:"
		host:      ask join "Hostname or IP (" [ my-host "): " ]
		port: load ask join "Port           (" [ my-port "): " ]
		host: either "" = host [ my-host ][ host ]
		port: either [] = port [ my-port ][ port ]
		do-setup host port
	]

	do-setup: func [
			"Setup host and port"
		host [string! tuple!] port [integer!]
	][
		my-host: host
		my-port: port
	]

	setup?: func [
		"Test if host and port are set"
		/interactive
		"Ask if not set"
	][
		if all [
			not none? host
			not none? port
		][
			return true
		]
		either interactive [
			setup
			return true
		][
			return false
		]
	]

	;
	; Send
	;

	send: func [
		"Send files interactively"
		/local file err
	][
		file: ask "Filename: "
		while [file <> "" ] [
			if #"%" = first file [
				remove/part file 1
			]
			file: to-file file
			if error? err: try [ do-send file ] [
				print "Sorry, I was unable to send the file"
			]
			file: ask "Filename: "
		]
	]

	do-send: func [
		[catch]
		"Do the send"
		file [file! block!]
		/local data port
	][
		if not block? file [
			file: reduce [file]
		]

		foreach f file [
			if not file? f [error [type-check (file!) (type? f) (f)] ]
		]

		foreach f file [
			if error? data: try [ read/binary f ] [
				error compose [ read (f) ]
			]

			if error? try [
				port: open/binary join tcp:// [my-host ":" my-port]

				insert port join f cr
				insert port data
				close port
			] [
				error [ network (join tcp:// [my-host ":" my-port]) ]
			]
		]
	]

	;
	; Receive
	;

	do-receive: func [
		"Receive and save files"
		/file "Receive only one file"
		fn [file!]
		/local pos data filename port connection pass fname fext err
	][
		if error? err: try [ port: open/binary join tcp://: my-port ] [
			error [network join tcp://: my-port ]
		]

		while [true] [
			either port = wait [port 1] [
				connection: first port
				data: copy ""

				; read the first line of data from the port,
				; this line contains the filename
				until [
					append data copy connection
					all [
						0 < length? data
						pos: find data cr
					]
				]
				; get the filename
				filename: last split-path to-file copy/part data pos
				;remove the first line from data recieved do far
				remove/part data next pos

				prin [ "Receiving" filename ]
				; if a file of that name already exists, create a new file name
				if exists? filename [
					if pos: find/last filename "." [
						fname: copy/part filename pos
						fext: copy pos
					]
					pass: 0
					while [ pass: pass + 1 exists? filename ][
						switch/default pass [
							1 [ filename: join fname [ "-" din-date fext ] ]
							2 [ filename: join fname [ "-" din-date "_" replace/all form now/time ":" "." fext]]
						] [
							filename: join fname [ "-" din-date "_" replace/all form now/time/precise ":" "." fext]
						]
					]
				]
				prin [ ", saving as:" filename "... " ]

				; write the data to the file, until all data has been recieved
				write/binary filename data
				while [data: copy connection] [
					write/append/binary filename data
				]
				close connection
				print "done"

				; if only recieving one file, stop now
				if file [
					close port
					return
				]
			][
				; if keyboard pressed, return
				if input? [
					close port
					return
				]
			]
		]
	]

	receive: :do-receive

	; if started with args, just start
	args: none
	if args: system/options/args [
		print [ self/header/Title "V." self/header/version ]
		change-dir system/options/path
		either #"r" = first first args [
			print rejoin [
				"Waiting for files on: tcp://" read dns:// ":" my-port newline
				"Press any key to stop"
				newline
				]
			do-receive
		][
			setup
			either 1 < length? args [
				do-send to-file first next args
			][
				send
			]
		]
	]

] ; remote-file


