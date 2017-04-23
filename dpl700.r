REBOL [
	title: "PhotoTrackr DPL700"
	purpose: "Reads the memory from the Gisteq PhotoTrackr GPS logger to a file"
	author: "pijoter"
	date: 29-Sep-2009/10:17:22+2:00
	file: %dpl700.r
	license: "GNU General Public License (Version II)"
	library: [
		level: 'intermediate
		platform: 'all
		type: [tool]
		domain: [file-handling]
		tested-under: [
			view 2.7.6  on [Linux WinXP]
		]
		support: none
		license: 'GPL
	]
]

dt: context [
	to-epoch: func [date [date!]] [
		;; epoch to czas gmt
		any [
			attempt [to-integer (difference date 1970-01-01/00:00:00)]
			(date - 1970-01-01/00:00:00) * 86400
		]
	]

	from-epoch: func [value [integer!] /zone tz [time!] /local date time dt] [
		value: to-time value
		date: 1970-01-01 + (round/down value / 24:00:00)
		time: value // 24:00:00

		dt: to-date rejoin [date "/" time]
		dt/zone: any [(if value? zone [tz]) 0:00]
		dt + dt/zone
	]

	normalize: func [dt [date!] /date /time /local pad d t s] [
		pad: func [val n] [head insert/dup val: form val #"0" (n - length? val)]

		dt: rejoin [
			(pad dt/year 4) #"-" (pad dt/month 2) #"-" (pad dt/day 2)
			#"/" to-itime any [dt/time 0:00]
		]

		any [
			if date [copy/part dt 10]
			if time [copy/part (skip dt 11) 8]
			dt
		]
	]

	to-stamp: func [dt [date!] /date /time] [
		dt: any [
			if date [self/normalize/date dt]
			if time [self/normalize/time dt]
			self/normalize dt
		]
		remove-each ch dt [found? find "-/:" ch]
	]

	to-local: func [dt [date!] /zone offset [time!]] [
		offset: any [
			if zone [offset]
			now/zone
		]
		dt/zone: offset
		dt: dt + offset
	]

	to-gmt: func [dt [date!]] [
		any [
			zero? dt/zone
			attempt [
				dt: dt - dt/zone
				dt/zone: 0:00
			]
		]
		dt
	]

	to-iso: func [dt [date!]] [
		dt: self/to-gmt dt
		append (replace (self/normalize dt) "/" "T") "Z"
	]
]

host: context [
	windows?: does [system/version/4 = 3]
	linux?: does [system/version/4 = 4]
]

dpl: context [
	DUMP-PREFIX: "dpl_"
	DUMP-SUFFIX: ".sr"

	hardware: context [
		BUFFER-SIZE: 4'000'000
		buffer: make binary! BUFFER-SIZE

		last-command: none
		last-response: none

		cmd-table: [
			"ident" [
				"WP AP-Exit^@" none							;; INIT
				"W'P Camera Detect^@" "WP GPS+BT^@"		;; BOD
				"WP AP-Exit^@" none							;; EXIT
			]
			"dump" [
				"WP AP-Exit^@" none							;; INIT
				"W'P Camera Detect^@" "WP GPS+BT^@"		;; BOD
				#{60b50000000000} "WP Update Over^@"	;; DUMP
				"WP AP-Exit^@" none							;; EXIT
			]
			"erase" [
				"WP AP-Exit^@" none							;; INIT
				"W'P Camera Detect^@" "WP GPS+BT^@"		;; BOD
				#{61b60000000000} [0:0:8 "WP Update Over^@"]	;; ERASE
				"WP AP-Exit^@" none							;; EXIT
			]
			"datetime" [
				"WP AP-Exit^@" none							;; INIT
				"W'P Camera Detect^@" "WP GPS+BT^@"		;; BOD
				#{64B80000000000} 16							;; DATETIME
				"WP AP-Exit^@" none							;; EXIT
			]
			"reset" [
				"WP AP-Exit^@" none							;; EXIT
			]
			"test" [
				"WP AP-Exit^@" none							;; INIT
				"W'P Camera Detect^@" "WP GPS+BT^@"		;; BOD
				#{63B70000000000} 4							;; ???
				"WP AP-Exit^@" none							;; EXIT
			]
		]

		reset: func [gps [port!] /local cmd] [
			cmd: select self/cmd-table "reset"
			if block? cmd [insert gps first cmd]
		]

		flow: func [gps [port!] cmd [word! string! block!]
			/callback f [function!]
			/local pairs awake command response timeout status item bytes-requested bytes-received
			match tmp start-datetime ready] [

			pairs: any [
				if block? cmd [cmd]
				select self/cmd-table (to-string cmd)
			]
			if any [none? pairs empty? pairs] [return false]

			awake: any [:f (get in self 'awake)]
			start-datetime: now/precise

			foreach [command response] pairs [
				if command <> 'none [

					write-io gps command (length? command)
					self/last-command: command

					net-utils/net-log ["flow/write" (mold command)]
				]

				if response <> 'none [
					if not block? response [response: reduce [response]]

					bytes-requested: any [
						if integer? bytes-requested: first response [bytes-requested]
						none ;; till EOD
					]

					timeout: any [
						if time? timeout: first response [timeout]
						0.1
					]

					clear self/buffer
					bytes-received: 0
					self/last-response: none

					set/any 'status try [
						until [
							wait [gps timeout]
							bytes: any [attempt [read-io gps tmp: self/buffer any [bytes-requested 20480]] 0]
							bytes-received: length? self/buffer

							net-utils/net-log ["flow/read" "received" (bytes-received) "last-read" bytes]
							if bytes <= ZERO [break]

							match: false
							foreach item response [
								if all [
									any [(string? item) (binary? item)]
									found? match: find/last self/buffer item
								][
									self/last-response: copy/part match (length? item)
									if string? item [self/last-response: to-string self/last-response]
									remove/part match (length? item)

									net-utils/net-log ["dpl/flow" "response found" (mold self/last-response)]
									break
								]
							]

							any [
								found? match
								bytes-received = bytes-requested
							]
						]
					] ;; try

					ready: all [(not error? get/any 'status) (bytes-received > ZERO)]

					net-utils/net-log ["flow/time" (difference now/precise start-datetime)]
					net-utils/net-log ["flow/callback" (ready)]

					any [
						if ready [awake self]
						break
					]
				]
			]
		]

		is-gisteq?: does [self/last-response = "WP GPS+BT^@"]
		is-over?: does [self/last-response = "WP Update Over^@"]

		awake: func [hardware [object!]] [true]
	]

	cmd: get in self/hardware 'flow

	connected?: func [port [word! string!] /local device gisteq-found?] [
		gisteq-found?: false
		port: to-word port

		if device: self/init port [
			self/cmd/callback device "ident" func [hardware [object!]] [
				if gisteq-found?: hardware/is-gisteq? [
					net-utils/net-log ["dpl/connected?" (port)]
				]
				true ;; callback
			]
			close device
		]

		gisteq-found?
	]

	detect: has [serial com port device] [
		printd "trying to find phototrackr gps device..."

		serial: system/ports/serial
		any [
			if host/windows? [
				repeat c 10 [
					com: to-word (join "com" c)
					if not found? find serial com [append serial com]
				]
			]
			if host/linux? [
				append serial [ttyUSB0 ttyUSB1 ttyACM0 ttyACM1 ttyS0 ttyS1]
			]
		]

		forall serial [
			port: to-word join "port" (index? serial)

			if self/connected? port [
				printd ["found! /" (port) (pick system/ports/serial index? serial)]
				break/return port
			]
		]
	]

	init: func [port [word!] /local device] [
		device: attempt [
			open/binary/direct/no-wait compose [
				scheme: 'serial
				device: port
				speed: 115200
				data-bits: 8
				parity: 'none
				stop-bits: 1
				rts-cts: off
				timeout: 1
			]
		]
		net-utils/net-log ["dpl/init" (port) (not none? device)]
		device
	]

	erase!: func [port [word!] /local device erased?] [
		net-utils/net-log "dpl/erase!"

		erased?: false

		if device: self/init port [
			printd "erasing memory..."

			self/cmd/callback device "erase" func [hardware [object!]] [
				if binary? hardware/last-command [
					either erased?: hardware/is-over? [
						net-utils/net-log ["dpl/erase!" (true)]
						printd "gps memory is empty now!"
					][
						self/debug hardware
					]
				]
				true ;; callback
			]

			self/cmd device "reset"
			close device
		]

		erased?
	]

	dump: func [port [word!] /as name [string! file!] /local device mark saved?] [
		net-utils/net-log "dpl/dump"

		saved?: false

		if device: self/init port [
			printd "reading memory..."

			self/cmd/callback device "dump" func [hardware [object!] /local file] [
				if binary? hardware/last-command [
					either all [
						hardware/is-over?
						(length? hardware/buffer) = 3997696
					][

						count: any [
							if found? mark: find hardware/buffer #{FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF} [
								attempt [to-integer ((index? mark) / 16)]
							]
							3997696 / 16
						]

						file: to-file any [
							if all [(as) (not empty? name)] [name]
							rejoin [self/DUMP-PREFIX (dt/to-stamp now) self/DUMP-SUFFIX]
						]

						net-utils/net-log ["dpl/dump" (file) (length? hardware/buffer) "bytes" (count) "records"]
						printd [(form file) "/" (length? hardware/buffer) "bytes" count "records"]

						attempt [
							write/binary file hardware/buffer
							saved?: true
						]
					][
						self/debug hardware
					]
				]
				true ;; callback
			]

			self/cmd device "reset"
			close device
		]

		saved?
	]

	datetime: func [port [word!] /gmt /local device gmt-date] [
		net-utils/net-log "dpl/datetime"

		gmt-date: none

		if device: self/init port [
			self/cmd/callback device "datetime" func [hardware [object!] /local dtm date time] [
				if binary? hardware/last-command [
					dtm: hardware/buffer

					if (length? dtm) = 16 [
						date: to-date reduce [(dtm/4 + 2000) dtm/5 dtm/6]
						time: to-time reduce [dtm/1 dtm/2 dtm/3]
						gmt-date: to-date rejoin [date "/" time "+" 0:0]

						net-utils/net-log ["dpl/datetime" "raw" (dtm) "cooked" (gmt-date) "GMT"]
					][
						self/debug hardware
					]
				]
				true ;; callback
			]

			self/cmd device "reset"
			close device
		]

		if gmt-date [
			printd ["gps datetime" dt/normalize gmt-date "GMT"]
			any [
				if gmt [gmt-date]
				dt/to-local gmt-date
			]
		]
	]

	debug: func [hardware [object!]] [
		print "something went wrong!"
		print ["[debug]" (mold hardware/last-command) (mold hardware/last-response) (length? hardware/buffer)]
	]
]

printd: func [message [block! string!]] [
	any [
		system/options/quiet
		print message
	]
]

hold: does [
	any [
		system/options/quiet
		not host/windows?
		ask "^/press enter"
	]
]

getopts: func [cmds [string!] cases [block!]
	/default case [block!]
	/local args cmd opts opt rcs] [

	args: any [system/script/args ""]
	args: parse args none

	cmds: parse cmds ":"
	rcs: make block! length? cmds

   forall cmds [
		cmd: first cmds
		if found? opts: find args (join "--" cmd)  [
			set [opt optargs] opts
			;; parametr opcji nie moze byc taki sam jak opcja
			any [
				none? optargs
				(length? optargs) <= 2
				not found? find head cmds (skip optargs 2)
				optargs: none
			]
			if (opt = (join "--" cmd)) [(append rcs cmd) (switch cmd cases)]
		]
	]

	any [
		if all [empty? rcs function? case] [do case]
		true
	]
]

;### main ###

system/options/quiet: false
net-watch: false
if all [net-watch none? system/script/args] [system/script/args: "--verbose"]

cmds: make block! 4
gps: none
filename: none

printd [
	system/script/header/title LF
	system/script/header/purpose LF
]

getopts "help:port::dump::erase:datetime:test:quiet:verbose" [
	"port" [
		device: to-word any [
			attempt [to-string second (split-path to-file any [optargs "ttyACM0"])]
			"ttyACM0"
		]

		port: any [
			if found? port: find system/ports/serial device [index? port]
			length? append system/ports/serial device
		]

		gps: to-word join "port" port
	]
	"dump" [
		append cmds "dump"
		filename: all [optargs (attempt [to-file optargs])]
	]
	"erase" [append cmds "erase"]
	"datetime" [append cmds "datetime"]
	"quiet" [system/options/quiet: true]
	"help" [append cmds "help"]
	"verbose" [
		net-watch: true
		echo to-file rejoin ["log_" (dt/to-stamp now) ".txt"]
	]
	"test" [append cmds "test"]
]

if empty? cmds [append cmds "dump"]
net-utils/net-log ["main/getopts" "cmds" cmds]

if found? find cmds "help" [
	print [
		system/script/header/file
		"[--port {comX|unix-device}] --dump [filename] --erase --datetime --test --help --quiet --verbose"
	]
	hold quit
]

gps: any [gps dpl/detect]
if any [(none? gps) (not dpl/connected? gps)] [
	print "no gps - no fun!"
	hold quit
]

foreach cmd cmds [
	switch cmd [
		"dump" [
			any [
				if filename [dpl/dump/as gps filename]
				dpl/dump gps
			]
		]
		"erase" [dpl/erase! gps]
		"datetime" [dpl/datetime gps]
		"test" [

			;; API
			if device: dpl/init gps [
				dpl/cmd/callback device "test" func [hardware [object!]] [
					if binary? hardware/last-command [
						print ["cmd" form hardware/last-command]
						print ["response" form hardware/buffer]
					]
					true ;; callback
				]
				close device
			]

		]
	]
]

hold quit
