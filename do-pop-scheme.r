REBOL [
	Title: "DO-POP Scheme"
	Date: 6-jul-2005
	File: %do-pop-scheme.r
	Author: "Brett Handley"
	Purpose: {A scheme to allow flexible POP3 operations.}
	Comment: {

*You need to learn and understand the POP3 protocol to use this properly. See http://en.wikipedia.org/wiki/POP3

*DELE *marks* messages for deletion but they are not physically deleted by the server until after QUIT
is issued. Messages can be unmarked with RSET. For this reason the the mailbox-length and
mailbox-size variables are not updated for DELE and keep their original values from when the port is opened.
Therefore at any given time, the number of messages that will be left after all messages marked for deletion
are removed will be:

	(mailbox-length - messages-deleted)

}

	Library: [
		level: 'intermediate
		platform: 'all
		type: 'protocol
		domain: 'email
		tested-under: [
			core 1.3.1.3.1 on [WinXP] {Basic tests.} "Brett"
		]
		support: none
		license: none
		comment: {
			Copyright (C) 2005 Brett Handley All rights reserved.
			* Portions of this code based upon the POP scheme by REBOL Technologies.
			* Read the associated documentation for license terms, you must agree with
			  the terms to use this script.
		}
	]

]

; Sample use.

comment [

	; -- Example 1: Quick check of mailbox statistics. -----------------------------------------------

	read do-pop://mailbox:password@mailserver.com


	; -- Example 2: Interactive POP commands using their network names given by the RFC. -------------

	popcmd: open do-pop://mailbox:password@mailserver.com

	insert popcmd 'list
	print copy popcmd

	insert popcmd [my-message: retr 1]
	print my-message

	insert popcmd [help list]

	close popcmd

	; -- Example 3: Syntactically nicer. --------------------------------------------------------------

	pop-service: open do-pop://mailbox:password@mailserver.com
	do-pop: func [value][insert pop-service value copy pop-service]

	foreach [msgnum size] do-pop 'list [
		do-pop [
			print [msgnum get in import-email top msgnum 'subject ]
		]
	]

	close pop-service

]

make Root-Protocol [

	{Evaluate REBOL code within a POP context.}

	; --------------------------------------------------
	; Modes, Constants and helpers
	; --------------------------------------------------

	port-flags: system/standard/port-flags/pass-thru

	; Use these to ensure correct behaviour.

	copy*: get in system/words 'copy
	insert*: get in system/words 'insert
	close*: get in system/words 'close
	net-log: get in net-utils 'net-log

	; --------------------------------------------------
	; Port lifetime methods.
	; --------------------------------------------------

	open: func [
		"Open the port. Required handler method."
		port "An initialised but not yet open port."
		/local greeting timestamp result
	] [
		net-log ["Port Request - Open" ]

		; Create context specific commands
		port/locals: context [

			commands: context [

				; ------------------------------------------------
				; POP Transaction State Commands
				; ------------------------------------------------

				dele: func [
					"Marks the message as deleted. Affects STAT, LIST, UIDL."
					message-number [integer! string!]
				] [
					request-remote port ["DELE" message-number]
					messages-deleted: messages-deleted + 1
					return ; unset
				]

				noop: func [
					{Sends the command.}
				] [
					request-remote port "NOOP"
					return ; unset
				]

				list: func [
					{Returns scan listings of messages.}
					/only message-number [integer! string!] "Restrict to specified message."
				] [
					either only [
						copy* next parse request-remote port ["LIST" message-number] none
					] [
						request-remote port "LIST"
						parse read-til-dot port make string! 1024 none
					]
				]

				retr: func [
					{Retrieves the message.}
					message-number [integer! string!]
				] [
					request-remote port ["RETR" message-number]
					read-til-dot port make string! 10000
				]

				rset: func [
					{Unmarks (resets) all messages marked as deleted.}
				] [
					request-remote port "RSET"
					messages-deleted: 0
					return ; unset
				]

				stat: func [
					{Returns statistics of mailbox as [length size].}
				] [
					use [length size] [
						set [length size] copy* next parse request-remote port "STAT" none
						reduce [to integer! length to integer! size]
					]
				]

				top: func [
					{Returns headers for message.}
					message-number [integer! string!]
					/lines number [integer!] {Number of body lines to include. Default is 0.}
				] [
					request-remote port ["TOP" message-number form any [number 0]]
					read-til-dot port make string! 10000
				]

				uidl: func [
					{Returns unique-id listing.}
					/only message-number [integer! string!] "Restrict to specified message."
				] [
					either only [
						copy* next parse request-remote port ["UIDL" message-number] none
					] [
						request-remote port "UIDL"
						parse read-til-dot port make string! 1024 none
					]
				]

			]
			mailbox-length: 0
			mailbox-size: 0
			messages-deleted: 0
			pop-result: none
		]

		; Set the state variables tail.
		port/state/tail: none

		if error? set/any 'result try [

			; Open the connection. Based upon logic from prot-pop.r by REBOL Technologies.

			open-proto port

			greeting: request-remote port 'none

			if any [
				port/algorithm <> 'apop
				not parse greeting [to "<" copy timestamp thru ">" to end]
				error? catch [
					request-remote port reform [
						"APOP" port/user lowercase enbase/base checksum/method rejoin [timestamp port/pass] 'md5 16
					]
				]
			] [
				request-remote port ["USER" port/user]
				request-remote port ["PASS" port/pass]
			]

			;Get stats and set variables.
			do bind [pop-result: set [mailbox-length mailbox-size] commands/stat] in port/locals 'self

		] [
			attempt [request-remote port "QUIT"]
			result
		]

		port

	]

	close: func [
		"Close the port. Required handler method."
		port "An open port."
	] [
		net-log ["Port Request - Close" ]
		attempt [request-remote port "QUIT"]
		port/locals: none ; Free up local context.
		close* port/sub-port
	]

	; --------------------------------------------------
	; Port item methods.
	; --------------------------------------------------

	copy: func [
		"Copy from the port. Returns result of last Insert to the port."
		port "An open port."
	] [
		; Copy from port/state/index.
		net-log ["Port Request - Copy" ]
		get/any in port/locals 'pop-result
	]

	insert: func [
		"Insert data into the port. Supports Insert request."
		port "An open port."
		data
	] [
		; Insert at port/state/index. Need to modify port/state/tail?
		net-log ["Port Request - Insert" :data]

		; Evaluate.
		set/any in port/locals 'pop-result do bind bind/copy data in port/locals 'self in port/locals/commands 'self
		port
	]

	; -------------------------------------------------------------------
	; Support functions
	; -------------------------------------------------------------------

	; read-til-dot copied and modified from prot-pop.r by REBOL Technologies.
	read-til-dot: func [port buf] [
		while [(line: system/words/pick port/sub-port 1) <> "."] [
			insert* tail buf line
			insert* tail buf newline
		]
		buf
	]

	request-remote: func [
		"Sends pop command to the server, checks reply."
		port
		value
	] [
		net-utils/confirm port/sub-port compose/only [(value) "+OK"]
	]


	; --------------------------------------------------
	; Install the scheme.
	; --------------------------------------------------

	net-utils/net-install do-pop self 110

]
