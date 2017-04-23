REBOL [
    Title: "sms-Functions" Version: 1.1.0
    Date: 25-Jul-2006
    Author: "Janeks Kamerovskis"
    File: %sms-funcs.r
    Purpose: {
        funcions that allows send and receive SMS by GSM modem
    }
    notes: {
    }
    library: [
        level: 'intermediate
        platform: 'all
        type: [ function tutorial tool]
        domain: [ other-net ]
        tested-under: [ REBOL/View 1.3.50.3.1 on "Windows XP"]
        support: none
        license: none
        see-also: none
]
]

;this shoud be specified here or somwhere else:

;this is valid for Windoze
system/ports/serial: [ com1 com2 com3 com4 com5 com6 com7 com8 com9 com10 ] ; --->>> ar šo nez k&#257;p&#275;c velk tikai uz Com1 ti. neiet. ja lieto paplašin&#257;to porta specifik&#257;ciju!!!
;system/ports/serial: [ com6 ] ; ar šo str&#257;d&#257; ja lieto paplašin&#257;to porta specifik&#257;ciju - &#326;em tikai port1
;for other system should be something another
;...

sms-in-dir: %smsesin/
sms-out-dir: %smsesout/
sms-unsent-dir: %smsesunsent/
sms-in-dir: join what-dir sms-in-dir
sms-out-dir: join what-dir sms-out-dir
sms-unsent-dir: join what-dir sms-unsent-dir

stat-file: join what-dir %cell-stats

; setting this value forces to do not test for phone model with AT commands
; [ "brandname" "full model name" ]
;phone-model: [ "SIEMENS" "SIEMENS MC35i" ]
;phone-model: [ "Nokia" "Nokia 30" ]

phone-brands:[
;	"AT"
	"Nokia"
	"SIEMENS"
]

;last error log file
if not value? 'last-error-log-file [
	last-error-log-file: %last_err.log
]

send-str: func [
	str2send
	port
][
	for i 1 (length? str2send) 1 [
		insert port to-char str2send/:i
	]
]

open-sms-port: func [
	sp-name [ string! ] "Serial port name of GSM modem"
	/local rez sp rez-obj
][
	rez-obj: make object! [
		serial-port: none
		open-reply: none
		phone: make object! [
			brandname: none
			model: none
		]
	]
	either not error? sp: try [
		gpsPort: rejoin [ "port" index? find system/ports/serial to-word sp-name ]
;		open/mode to-url rejoin [ "serial://" gpsPort "/9600/8/none/1" ] [ write read string no-wait ]
;		open/mode to-url rejoin [ "serial://" gpsPort "/9600/8/none/1" ] [ write read string no-wait ]
		open/mode to-url rejoin [ "serial://" gpsPort "/19200/8/none/1" ] [ write read no-wait direct ]

;		open/mode serial://port1/9600/none [write read string no-wait]

;		sp: open/mode [
;		open/mode [
;			scheme: 'serial
;			host: 'port7 ; how to corectly put here gpsPort value ???
;			host: to-word rejoin [ "port" index? find system/ports/serial to-word sp-name ]
;		][ write read string no-wait ]
	][
		insert sp rejoin [ "ATE" crlf ]
		rez: last parse copy wait [ 0.1 sp ] crlf
		either "OK" = rez [
			insert sp "AT+CMGF=1^M^/"
			copy wait [ 0.1 sp ]
			either not value? 'phone-model [
				rez-obj/serial-port: sp
				rez-obj/open-reply: "OK"
				rez-obj/phone/brandname: first check-phone-model sp
				rez-obj/phone/model: second check-phone-model sp
			][
				either phone-model [
					rez-obj/serial-port: sp
					rez-obj/open-reply: "OK"
					rez-obj/phone/brandname: first phone-model
					rez-obj/phone/model: second phone-model
				][
					rez-obj/serial-port: sp
					rez-obj/open-reply: "OK"
					rez-obj/phone/brandname: first check-phone-model sp
					rez-obj/phone/model: second check-phone-model sp
				]
			]
		][
			rez-obj/serial-port: sp
			rez-obj/open-reply: rez
		]
	][
		rez-obj/open-reply: "Port could not be opened!"
	]
	return rez-obj
]

check-phone-model: func [
	sp [ port! ] "Opened serial port"
	/local rez phb
][
	insert sp rejoin [ "ATI" crlf ]
	rez: parse copy wait [ 0.1 sp ] crlf
	foreach wrd phone-brands [
		if find rez wrd [
			phb: wrd
		]
	]
	switch/default phb [
		"Nokia" [
			insert sp rejoin [ "ATI3" crlf ]
			rez: parse copy wait [ 0.1 sp ] crlf
			reduce [ phb rejoin [ rez/1 " " rez/2 ] ]
		]
		"Siemens" [
			reduce [ phb rejoin [ rez/1 " " rez/2 ] ]
		]
	][
		[ "AT" "Unknown" ]
	]
]

sends-sms: func [
	mp [ object! ] "Phone/modem object (see code)"
	ph [ string! number! ] "Phone number to send"
	msg [ string! ] "Message text"
	/local modcoms rez
][
	modcoms: reduce [
		rejoin [ "AT+CMGF=1" crlf ]
		rejoin [ "AT+CMGS=" {"} ph {"} crlf ]
		rejoin [ msg to-char 26 ]
		rejoin [ {+CMGS: 5} crlf ] ;check for that message is accepted in modem?
	]
	foreach cm modcoms [
		insert mp/serial-port cm
		wait 1
		rez: parse copy wait mp/serial-port crlf
;		probe rez
		if not attempt [ rez: last rez ][ ;Probably need to change to be shure that port is empty
			rez: "EMPTY REZ"
		]
		if rez = "ERROR" [ break ]
	]
	return rez
]

write-sms: func [
	{Write sms to modem storage. Returns stored message ID
	Note: Modem should be set to text mode (AT+CMGF=1)}
	mp [ object! ] "Phone/modem object (see code)"
	ph [ string! number! ] "Phone number to send"
	msg [ string! ] "Message text"
	/local rez
][
	rez: copy []
	insert mp/serial-port rejoin [ "AT+CMGW=" {"} ph {"} crlf ]
	repend rez parse copy wait mp/serial-port crlf

	insert mp/serial-port rejoin [ msg to-char 26 ]
	repend rez parse copy wait mp/serial-port crlf

	either try [ rez: to-integer select rez "+CMGW:" ] [
		rez
	][
		last rez
	]
]

send-stored-sms: func [
	{Send sms from modem storage
	Note: Modem should be set to text mode (AT+CMGF=1)}
	mp [ object! ] "Phone/modem object (see code)"
	id [ string! number! ] "Stored message ID"
	/local rez
][
	rez: copy []
	insert mp/serial-port rejoin [ "AT+CMSS=" id crlf ]
	repend rez parse copy wait mp/serial-port crlf
	either "OK" = last rez [
		select rez "+CMSS:"
	][
		last rez
	]
]

send-sms: func [
	mp [ object! ] "Phone/modem object (see code)"
	ph [ string! number! ] "Phone number to send"
	msg [ string! ] "Message text"
	/local id rez
][
	id: write-sms mp ph msg
	either number? id [
		rez: send-stored-sms mp id
		erase-sms mp id
	][
		"ERROR"
	]
	return rez
]

file-num: func [n] [
    ; Output 000n file name format:
    n: form n
    insert/dup n "0" 4 - length? n
    to-file n
]

convert-date-time: func [
	sms-date-time
	/local datex
][
	datex: parse first parse sms-date-time "," "/"
	to-date rejoin [
		rejoin [ reverse copy/part next load form datex 2
			add first copy/part load form datex 1 2000
		]
		to-time second parse sms-date-time ","
	]
]

sms: make object! [
	ID: none
	status: none
	dest-phone: none
	src-phone: none
	date-time: none
	content: ""
]

reset-sms: func [
;	sms [ object! ]

][
	sms/ID: none
	sms/status: none
	sms/dest-phone: none
	sms/src-phone: none
	sms/date-time: none
	sms/content: copy ""
]

read-sms: func [
	{Read sms from modem storage
	Note: Modem should be set to text mode (AT+CMGF=1)}
	mp [ object! ] "Phone/modem object (see code)"
	/only "Filter only given types of SMSes"
	sms-type [ string! block! ] {SMS type: any of "STO SENT", "STO UNSENT", "REC READ", "REC UNREAD" }
	/local rez smses sms-id r-lines
][
	sms-id: none
	smses: copy []
	rez: copy []
	r-lines: copy []

	either only [
		insert mp/serial-port rejoin [ {AT+CMGL="} sms-type {"} crlf ]
	][
		insert mp/serial-port rejoin [ {AT+CMGL="ALL"} crlf ]
	]
	wait 1
	while [
		rez: parse/all copy wait [ 0.1 mp/serial-port ] crlf
		all [
			not "OK" = last rez
			not "ERROR" = last rez
		]
	][
		either mp/phone/brandname = "Siemens" [
			repend r-lines rez
		][
			repend r-lines next rez
		]
		wait 1
	]
	either mp/phone/brandname = "Siemens" [
		repend r-lines rez
	][
		repend r-lines next rez
	]
	r-lines: copy/part r-lines ( length? r-lines ) - 2

	foreach resp-line r-lines [
		either "+CMGL:" = copy/part resp-line 6 [
			reset-sms sms
			sms-blk: parse/all resp-line ","
			sms-id: to-integer second parse sms-blk/1 " "
			switch sms-blk/2 [
				"STO SENT" [
					sms/status: sms-blk/2
					sms/id: sms-id
					sms/dest-phone: sms-blk/3
				]
				"STO UNSENT" [
					sms/status: sms-blk/2
					sms/id: sms-id
				]
				"REC READ" [
					sms/status: sms-blk/2
					sms/id: sms-id
					sms/src-phone: sms-blk/3
					sms/date-time: convert-date-time sms-blk/5 ","
				]
				"REC UNREAD" [
					sms/status: sms-blk/2
					sms/id: sms-id
					sms/src-phone: sms-blk/3
					sms/date-time: convert-date-time sms-blk/5 ","
				]
			]
			repend smses [
				sms-id
				sms-blk
			]
		][
			if sms-id [
				if 0 < length? sms/content [ sms/content: repend sms/content newline ]
				sms/content: repend sms/content resp-line
				change/only next find smses sms-id make sms []
			]
		]
	]

	rez: smses
;	if empty? rez [
;		rez: "EMPTY REZ"
;	]
;	if rez = "ERROR" [ break ]

	return rez
]

erase-sms: func [
	{Erase sms from modem storage
	Note: Modem should be set to text mode (AT+CMGF=1)}
	mp [ object! ] "Phone/modem object (see code)"
	sms-id [ integer! string! ] "SMS index number"
	/local rez
][
	rez: copy []
	insert mp/serial-port rejoin [ "AT+CMGD=" sms-id crlf ]
	repend rez parse copy wait mp/serial-port crlf
	return last rez
]

cell-strength: func [
	sp [ port! ] "Serial port of GSM modem"
	/local rez
][
	insert sp rejoin [ "AT+CSQ" crlf ]
	rez: parse copy wait [ 1 sp ] crlf

	either find rez "ERROR" [
		rez: "ERROR"
	][
		rez: divide to-integer first parse rez/2 "," 31
	]
	return rez
]

sms-save2disk: func [
	sms [ object! ] "SMS for storing to disk"
	dir [ file! ] "Directory to store"
	/local files file
][
	files: sort/reverse load dir
	file: files/1
	file: either file [1 + to-integer file] [1]
	file: file-num file
	save join dir file compose [
		ID: (sms/ID)
		status: (sms/status)
		dest-phone: (sms/dest-phone)
		src-phone: (sms/src-phone)
		date-time: (sms/date-time)
		content: (sms/content)
	]
	file
]

downl-sms: func [
	sp-name [ object! ] "Phone/modem object (see code)"
	/only "Filter only given types of SMSes"
	sms-type [ string! block! ] {SMS type: any of "STO SENT", "STO UNSENT", "REC READ", "REC UNREAD" }
	/local smses
][
	either only [
		smses: read-sms/only sp-name sms-type
	][
		smses: read-sms sp-name
	]
	either all [ block? smses not empty? smses ] [
		foreach [ id sms ] smses [
			sms-save2disk sms sms-in-dir
			erase-sms sp-name id
		]
	][
		smses: []
	]
	smses
]

read-sms-from-disk: func [
	dir
	/local rez sms-obj
][
	rez: copy []
	foreach file reverse read dir [
		sms-obj: construct load rejoin [ dir file ]
		sms-obj/id: to-integer file
		repend rez [
			sms-obj/id
			sms-obj
		]
	]
	return rez
]

test-port: does [
	for i 1 20 1 [
		mp: open-sms-port "COM4"
		print [ mp/2 mp/3/1 mp/3/2 ]
		wait 1
		close mp/1
		wait 1
	]
]

sms-file-server: func [
	{Reads and sends simple text SMSes from and to files.
	Certain directories are required to run this funcion - see beginning of this script file!
	}
][
	mp: open-sms-port "COM4"
	forever [
		save stat-file compose [
			cell-strength: (cell-strength mp/serial-port)
		]
		smses-to-send: read-sms-from-disk sms-unsent-dir
		foreach [ sms-id sms ] smses-to-send [
			either "ERROR" <> send-sms mp sms/dest-phone sms/content [
				sms/status: "STO SENT"
				sms/date-time: now
				sms-save2disk sms sms-out-dir
				delete rejoin [ sms-unsent-dir file-num sms-id ]
				print rejoin [ "SMS to " sms/dest-phone " sent at " now ]
			][
				print rejoin [ "SMS to " sms/dest-phone " failed to send at " now ]
				print either port? wait [ 1 mp/serial-port ] [ rejoin [ "Port clearing o'k!" copy mp/serial-por ] ] [ "Port empty!" ]
			]
		]
		smses-received: downl-sms mp
		foreach [ sms-id sms ] smses-received [
			print rejoin [ "SMS from " sms/src-phone " received at " sms/date-time ]
		]

		isBr: false
		loop 10 [
			wait 1
			if input? [
				print "SMS reading stopped!!!"
				isBr: true
				break
			]
		]
		if isbr [ break ]
	]
	close mp/serial-port
]