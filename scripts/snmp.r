REBOL [
	Title: "SNMP v1 protocol"
	Date: 16-Dec-2001
	Author: "VDemong"
	Email: vdemongodin@free.fr
	File: %snmp.r
	Version: 0.8.0
	Purpose: { Implementation of SNMP v1 scheme (RFC 1155,1156,1157) , no TRAP.
          URL is snmp://[community@]<host adr>/CMD/<id values>
          default community is public
          Where CMD is get getnext or set
          id values is a string like that: "1.3.6.1.2.1.1.1.0 1.3.6.1.2.1.1.5.0"
         
          Return an object:

              make object! [
                  version: 0
                  community: "public"
                  request-id: 1122
                  error-status: 0
                  error-message: "NoError"
                  error-index: 0
                  values: [[#1.3.6.1.2.1.1.1.0 {Hardware: x86 Family 5 Model 8 Stepping 12 AT/AT COMP
                  ATIBLE - Software: Windows 2000 Version 5.0 (Build 2195 Uniprocessor Free)}] [#1.3.6.1.
                  2.1.1.5.0 "BOGOMILE"]]
              ]

           samples:
           p: open snmp://public@127.0.0.1/GET/
           insert p "1.3.6.1.2.1.1.5.0"
           rep1: copy p
           close p
           rep2: read join snmp://public@127.0.0.1/GET/  "1.3.6.1.2.1.1.1.0 1.3.6.1.2.1.1.5.0";
           rep5: read join snmp://public@127.0.0.1/GETnext/1.3.6.1.2.1.4.21.1.1.0

	   adr: 172.16.1.1
	   while [ adr <> 172.16.1.254 ] [
	        error? try [
		  rep: read to-url rejoin [ "snmp://" adr "/GET/1.3.6.1.2.1.1.1.0 1.3.6.1.2.1.1.5.0" ]
		  print [ "At " adr " find: "  second first rep/values "  :  " second second rep/values ]
	        ]
	        adr: adr + 0.0.0.1
           ]
        }
	Category: [protocol]
        Library: [
		level: 'advanced
		platform: 'all
		type: [protocol tool]
		domain: [other-net protocol]
		tested-under: "Mac OsX"
		support: vdemongodin@free.fr
		license: gpl
		see-also: none
        ]
]


make root-protocol [

	;i pick this in mysql-protocol.r 
	sys-copy: 	get in system/words 'copy
	sys-insert: get in system/words 'insert
	net-log: 	get in net-utils	'net-log
	
	last-snmp-id: none ; last snmp response for get-next loops (a todo work ... )

	;;;Internal object for SNMP handling decode/encoding SNMP messages 
	SNMP-CMD: make object! [
		NULL: none
		errors:  [ "NoError" "tooBig" "noSuchName" "badValues" "readOnly" "genErr" ]
		;BER decode
		BER-SELECT: function [ msg [ binary! ] ] [ tag ] [
			if 0 = length? msg [ return sys-copy [ 0 0 ] ]
			tag: to-integer first msg ; GET BER id
			return switch tag [
				02 [ decode-integer msg ]
				03 [ decode-bit-string msg ]
				04 [ decode-octet-string msg ]
				05 [ decode-null msg ]
				06 [ decode-ob-id msg ]
				48 [ decode-sequence msg ]
				64 [ decode-ip msg ]
				65 [ decode-counter msg ]
				66 [ decode-gauge msg ]
				67 [ decode-time-ticks msg ]
				68 [ decode-opaque msg ]
				128 [ decode-null msg ]
				129 [ decode-null msg ]
				130 [ decode-null msg ]
			]
		]


		;;decode function returns a block [ length  value ]

		;;value: tuple!
		decode-ip: function [msg] [tmprsp tmpval tmpip][
			tmprsp: decode-octet-string msg
			tmpval: second tmprsp
			tmpip: sys-copy []
			forall tmpval [ append tmpip to-integer first tmpval ]
			reduce [ first tmprsp to-tuple tmpip ]
		]

		
		decode-counter: func [msg][
			decode-integer msg
		]
		
		decode-gauge: func [msg] [
			decode-integer msg
		]

		;;value: time!
		decode-time-ticks: function [msg] [tmprsp ti res][
			tmprsp: decode-integer msg
			ti: to-time ((second tmprsp) / 100)
			res: join to-integer (ti/hour / 24) " day(s) "
			ti: to-time reduce [ (ti/hour // 24) ti/minute ti/second ]
			reduce [ first tmprsp join res ti ]
		]

		;;to test
		decode-opaque: function [msg] [tmpres tmpmsg] [
			tmpres: decode-octet-string msg
			tmpmsg: BER-SELECT to-binary second tmpres
			reduce [ first tmpres second tmpmsg ]
		]
		
		decode-null: func [msg] [
			return [ 2 NULL ]
		]
		
		decode-sequence: function [ msg [ binary! ] ] [sequence tmpmsg len tmplen] [
			sequence: sys-copy []
			tmpmsg: next msg
			len: decode-length tmpmsg
			tmplen: second len
			tmpmsg: skip tmpmsg first len
			while [ tmplen > 0 ] [
				tmpres: BER-select tmpmsg
				append/only  sequence second tmpres
				tmplen: tmplen - first tmpres
				tmpmsg: skip tmpmsg first tmpres
			]
			reduce [ 1 + (first len) + (second len)  sequence ]
		]

		;; value: string!
		decode-ob-id: function [ msg [ binary! ]] [tmpmsg len result id1 id2 acc i] [
			tmpmsg: next msg
			len: decode-length tmpmsg
			tmpmsg: skip tmpmsg first len
			id2: (first tmpmsg) // 40
			id1: to-integer ((first tmpmsg) / 40)
			tmpmsg: next tmpmsg
			tmpmsg: sys-copy/part tmpmsg -1 + second len
			acc: 0
			result: sys-copy ""
			for i 1 (-1 + second len) 1 [
				either 127 < tmpmsg/:i [
					acc: 128
				][
					append result to-string reduce [ "." (acc + tmpmsg/:i) ]
					acc: 0
				]
			]
			sys-insert result to-string reduce [ id1 "." id2  ] 
			reduce [ 1 + (first len) + (second len) result ]
		]

		;;value: integer!
		decode-integer: function [ msg [ binary! ]] [ tmpmsg ] [
			tmpmsg: sys-copy/part next msg length? msg
			len: to-integer first tmpmsg
			msg: skip msg len + 1
			reduce [ len + 2 to-integer sys-copy/part next tmpmsg len ]
		]

		;;value: string!
		decode-octet-string: function [ msg [ binary! ] ] [tmpmsg len str] [
			tmpmsg: sys-copy next msg
			len: to-integer first tmpmsg
			either len > 128 [
				use [len-len lenpart] [
					len-len: len - 128
					lenpart: sys-copy/part next tmpmsg len-len
					len: to-integer lenpart
					tmpmsg: skip tmpmsg len-len + 1
				]
			]
			[
				tmpmsg: next tmpmsg
			]
			
			str: to-string sys-copy/part tmpmsg len
			tmpmsg: skip tmpmsg len
			
			reduce [ index? tmpmsg  str ]
		]

		;;i don't care about length
		skip-length: function [ msg ] [len len-len] [
			len: to-integer first msg
			either len > 128 [
				len-len: len - 128
				len-len + 1
			]
			[1]
		]

		;; i have care ...
		decode-length: function [ msg ] [len len-len] [
			len: to-integer first msg
			either len > 128 [
				len-len: len - 128
				return reduce [ len-len + 1  to-integer sys-copy/part next msg len-len ]
			] [
				return reduce [ 1 len ]
			]
		]

		;; build response
		decode-message: function [ msg [ binary! ] ] [result decode len] [
			result: sys-copy []
			msg: skip msg 1 ;skip sequence in front of message
			msg: skip msg skip-length msg
			decode: decode-integer msg
			append  result reduce [ to-set-word 'version second decode ]
			msg: skip msg first decode
			decode: decode-octet-string msg
			append  result reduce [ to-set-word 'community second decode ]
			msg: skip msg first decode
			msg: next msg
			msg: skip msg skip-length msg
			decode: decode-integer msg
			append result reduce [ to-set-word 'request-id  second decode ]
			msg: skip msg first decode
			decode: decode-integer msg
			append  result reduce [ to-set-word 'error-status second decode ]
			msg: skip msg first decode			
			append result reduce [ to-set-word 'error-message pick errors 1 + second decode ]
			decode: decode-integer msg
			append  result reduce [ to-set-word 'error-index second decode ]
			msg: skip msg first decode
			append  result reduce [ to-set-word 'values second BER-SELECT msg ]
			return make object! result
		]


		
		;BER encode
		
		BER-length: function [ len ] [bin-len] [
			net-log rejoin ["BER encode data length: " len ] 
			bin-len: sys-copy #{}
			either  128 > len  [
				sys-insert bin-len to-char len
			][
				sys-insert bin-len to-char ( len // 127)
				sys-insert bin-len to-char to-intager ( len / 127 )
				sys-insert bin-len to-char 82
			]
			return bin-len
		]
				
		BER-IPAdr: function [ ipadr ][i tmpstr][
			net-log rejoin ["BER encode ip adr: " ipadr ]
			tmpstr: sys-copy ""
			for i 1 4 1 [ append tmpstr to-char ipadr/:i ]
			return BER-string tmpstr
		]
				
		BER-integer: function [ int ] [hex-int ber-int val] [
			net-log rejoin ["BER encode integer: " int ]
			ber-int: sys-copy {}
			hex-int: to-hex int
			forskip hex-int 2 [
				val: to-integer sys-copy/part hex-int 2
				if val > 0  [ append ber-int to-char val ]				
			]
			ber-int: head ber-int
			ber-int: join BER-length length? ber-int ber-int
			sys-insert ber-int to-char 2 ; BER integer
			return ber-int
		]
		
		BER-time: function [time-val] [ber-time hex-time][
			net-log rejoin ["BER encode time: " time-val ] 
			ber-time: sys-copy #{}
			hex-time: to-hex ( 100 * to-integer time-val )
			forskip hext-time 2 [
				val: to-integer sys-copy/part hex-int 2
				if val > 0 [ append ber-time to-char val ]
			]
			sys-insert ber-time BER-Length length? ber-time 
			sys-insert ber-time to-char 67 ; BER time ticks id
		]
				
		BER-string: function [ str ] [ber-str] [
			net-log rejoin ["BER encode octet string: " str ]
			ber-str: sys-copy #{}
			sys-insert ber-str str
			ber-str: join BER-length length? ber-str ber-str
			sys-insert ber-str to-char 4
			return ber-str
		]
		
		
		BER-obj-id: function [ obj-id ] [id ber-id] [
			net-log rejoin ["BER encode object id: " obj-id ]
			ber-id: sys-copy #{}
			id: parse to-string obj-id "."
			forall id [ sys-insert id to-integer first id remove next id ]
			id: head id
			for i 3 (length? id)  1 [
				either id/:i > 127 [
					append ber-id to-char 129
					append ber-id to-char ( -128 + id/:i )
				][
					append ber-id to-char id/:i
				]
			]
			sys-insert ber-id to-char ((40 * first id) + second id)
			ber-id: join BER-length (length? ber-id) ber-id
			sys-insert ber-id to-char 6
			return ber-id
		]
				
		BER-GETvarBindList: function [ objid-list ] [id-blk] [
			id-blk: to-block objid-list
			id-blk: next id-blk
			forskip id-blk 2 [ sys-insert id-blk 'NULL ]
			sys-insert id-blk 'NULL
			id-blk: head id-blk
			return id-blk
		]
		
		BER-SETvarBindList: func [ objid-list ] [
			return to-block objid-list
		]
		
		BER-VarBindList: function [ objid-block ] [bin-req tmp-bin typ] [
			bin-req: sys-copy #{}
			forskip objid-block 2 [
				typ: to-string type? second objid-block
				tmp-bin: sys-copy switch typ [
				"integer" [ BER-integer second objid-block ]
				"tuple"   [ BER-IPAdr second objid-block ]
				"issue"   [ BER-obj-id second objid-block ]
				"word"    [ either "NULL" = uppercase to-string second objid-block
						[ #{0500} ]
						[ BER-string to-string second objid-block ]
					]
				"time"    [ BER-time second objid-block ]
				]
				sys-insert tmp-bin BER-obj-id first objid-block
				sys-insert tmp-bin BER-length length? tmp-bin
				sys-insert tmp-bin to-char 48 ; BER sequence ID
				append  bin-req sys-copy tmp-bin
				clear tmp-bin
			]
			sys-insert bin-req BER-length length? bin-req
			sys-insert bin-req to-char 48
			return bin-req
		]
		
		Req: function [
		{build a SNMP v1 request - return binary value}
			community [string!] "community name"
			objid-block [block!] {PDU vars bind list}
			req-id [integer!] "request identifier"
			req-type "request type identifier"
		]
		[ bin-req ]
		[
			net-log "BUILD request"
			bin-req: BER-VarBindList objid-block
			sys-insert bin-req  sys-copy #{020100020100} ; error flags
			sys-insert bin-req BER-integer req-id 
			sys-insert bin-req BER-length length? bin-req 
			sys-insert bin-req to-char req-type
			sys-insert bin-req BER-string community  
			sys-insert bin-req sys-copy #{020100}  ;SNMP V1 tag
			sys-insert bin-req BER-length length? bin-req 
			sys-insert bin-req to-char 48
			return bin-req
		]
		
		
		;"PUBLIC INTERFACE"	
		Get-Request: func [
			community [string!] "community name"
			obj-id {object identifiers eg. "1.3.6.1.1.2.1.0"}
			req-id [integer!] "request identifier"
		][
			net-log "SNMP get request"
			Req community (BER-GETVarBindList obj-id) req-id 160
		]
		
		Get-next-Request: func [
			community [string!] "community name"
			obj-id {object identifiers eg. "1.3.6.1.1.2.1.0"}
			req-id [integer!] "request identifier"
		][
			net-log "SNMP getNext request"
			Req community (BER-GETVarBindList obj-id) req-id 161
		]
		
		Set-Request: func [
		{build a SNMP v1 request - return binary value}
			community [string!] "community name"
			obj-id {object identifiers bind  "1.3.6.1.1.2.1.0 <value>"}
			req-id [integer!] "request identifier"
		][
			net-log "SNMP set request"
			Req community (BER-SETVarBindList obj-id) req-id 163
		]
	]


	; protocol stuffs ....

	scheme: 'snmp
	port-id: 161
	port-flags: system/standard/port-flags/pass-thru or 32


	open: func [ port ] [
		open-proto/sub-protocol port 'udp
		if none = port/user [ port/user: "public" ]
		if none <> port/target [
			insert port port/target
		]
	]

	insert: function [ port data ] [req tmpdata] [
		;tuple are limited to length 10
		;insert a # in front then to-block read them as issue
		;(see VarBindList) 
		;all obj id begin with 1.
		tmpdata: sys-copy data
		sys-insert tmpdata "#"
		replace/all tmpdata " 1." " #1."
		net-log "INSERT data"
		str-path: uppercase to-string port/path
		switch/default str-path [
			"GET/"       [
				req: SNMP-CMD/get-request port/user tmpdata to-integer now/time
				write-io port/sub-port req length? req
			]
			"GETNEXT/"   [
				req: SNMP-CMD/get-next-request port/user tmpdata to-integer now/time
				write-io port/sub-port req length? req				
			]
			"SET/"       [
				req: SNMP-CMD/set-request port/user tmpdata to-integer  now/time
				write-io port/sub-port req length? req
			]
		][
			net-error reform [ str-path " is an invalid SNMP command"]
		]
	]

	copy: function [ port ] [ buffer length ] [
		buffer: make binary! 1000
		until [
			length: read-io port/sub-port buffer 1000
			( length <= 1000 )
		]
		net-log rejoin  ["COPY read " length? buffer " byte(s)"]
		SNMP-CMD/decode-message buffer
	]

	read: func [port] [
		net-log "READ port"
		insert port port/target
	]

	net-utils/net-install 'snmp self 161
]




