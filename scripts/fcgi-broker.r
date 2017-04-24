REBOL [
	Title: "FastCGI Broker"
	File: %fcgi-broker.r
	Date: 15-Dec-2005
	Author: "Pascal Hurni"
	Version: 1.0.1
	Library: [
		level: 'intermediate
		platform: 'windows
		type: [module tool]
		domain: [cgi http html extension win-api]
		tested-under: [w2k core 2.5.6 view 1.3.1 view 1.3.2]
		support: http://mortimer.devcave.net/projects/rebfcgi
		license: 'bsd
		see-also: http://mortimer.devcave.net
	]
	Purpose: {Rebol script broker for a hooked rebol interpreter launched as a FastCGI application.
		This is the root script which runs others scripts on request of the FastCGI peer.
	
		This enables REBOL/Core or REBOL/View to act as a FastCGI application without the need
		for REBOL/Command.
	
		This script only works on Windows with a patched REBOL interpreter.
		Details available at http://mortimer.devcave.net/projects/rebfcgi
	}
]

fcgi-broker: context [
	;-- buffer for the command
	command: make string! 8192

	;-- magic value to indicate 'end of command'
	magic: to-binary {^~ReBfCgI}

	;-- alias for the input stream
	stdin: system/ports/input

	;-- Function that waits for the next request
	wait-for-command: func [port [port!] /local result][
		;-- commands are line oriented
		set-modes stdin [lines: true]
	
		;-- Read stdin until we find the magic marker (this is to skip previous stdin data not read)
		while [not error? result: try [command: copy first port]][
			if command: find/tail command magic [
				return command
			]
		]
		;-- Loop broken by an error, is it an EOF ?
		if not-equal? 315 get in disarm result 'code [
			;-- No, show it
			probe result
		]

		none
	]

	;-- The broker itself
	run: has [result][
		;-- Keep original words
		quit': :quit
		halt': :halt
	
		;-- Quit and Halt executed in the script, should simply abort the do block
		quit: halt: func [[throw]][return none]

		;-- Wait and get next FCGI command
		while [command: wait-for-command stdin][
			;-- Execute the command which will set up the system/options/cgi
			do command

			;-- Launch the script (DO DOES is for encapsulating the try block in a function so that QUIT and HALT can simply RETURN)
			if do does [error? set/any 'result try [do to-rebol-file system/options/cgi/path-translated]][
				;-- Output error to web server
				print rejoin ["Content-Type: text/plain^/^/<pre>" mold disarm result "</pre>"]
			]

			;-- Put the 'End of command' marker in the output stream
			write-io system/ports/output magic length? magic
			
			;-- This tries to force a thread scheduling, so that the FcgiHandler can catch the magic marker (it has a higher priority)
			wait 0.01
		]
	
		;-- No more commands, end.
		quit: :quit'
		halt: :halt'
	]
]

;-- Do it!
fcgi-broker/run
