REBOL [
	Title: "DNS protocol"
	Date: 19-Feb-2005
	Author: "VDemong"
	Email: vdemongodin@free.fr
	File: %dig.r
	Version: 0.0.1
	History: "First try"
	Purpose: { REBOL DIG : Implementation of DNS protocol (RFC 1035)  
          	  
		  URL is dig://name-server/TYPE/name
		   
		  ans: read dig://ns.thomething.com/SOA/thomething.com
		  ans: read dig://172.30.1.1/PTR/194.252.19.3
		  ans: read dig::/172.30.1.1/A/noway.myhome.com
		  
		  you can see a list of available TYPEs in cmd-list in beginning of code
		  
		  use ans/to-str to obtain readable answer:
		  
		  >> do %dig.r                                        
		  Script: "DNS protocol" (19-Feb-2005)
		  dig protocol loaded
		  >> ans: read dig://ns.libertysurf.net/SOA/tiscali.fr
		  connecting to: ns.libertysurf.net
		  >> print ans/to-str                                 
		  ;; REQUEST: SOA(6) for tiscali.fr
		  ;; id: 7724 AA: 1 RD: 1 RA: 0 ANSWER(s): 1 AUTHORITY(s): 2 ADDITIONAL(s): 2

		  ;; ANSWER(s):
	          tiscali.fr. 1800    SOA ns.libertysurf.net.  admin-dns.libertysurf.net.  2005021701  1800  900  1209600  1800

		  ;; AUTHORITY(s)
		  tiscali.fr. 604800  NS  ns.libertysurf.net.
                  tiscali.fr. 604800  NS  ns2.libertysurf.net.

		  ;; ADDITIONAL(s)
                  ns.libertysurf.net. 1800    A   213.36.80.2
                  ns2.libertysurf.net.    1800    A   213.36.80.4

                   >> 
		  
		  If you want to extract yourself information look at the structure of objects question,answer,resource and (xxx)-data in code 
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

	;; save usefull functions
	sys-copy: get in system/words 'copy
	net-log: get in net-utils 'net-log
	
	
	;; Supported commands
	cmd-list: sys-copy [
		"A/" 1 "address"
		"NS/" 2 "name server"
		"CNAME/" 5 "cononical name"
		"SOA/" 6 "source of authority"
		"MB/" 7 "mail box"
		"MG/" 8 "mai group"
		"MR/" 9 "mail rename"
		"NULL/" 10 "null" 
		"WKS/" 11 "well know service"
		"PTR/" 12 "domain name pointer"
		"HINFO/"  13 "host informatin"
		"MINFO/" 14 "mailbox information"
		"MX/" 15 "mail exchange"
		"TXT/" 16 "text"
		"ALL/" 255 "all"
	]
	
	;; Options
	recurse?: true  ;recursive question ?
	
	
	;; packet builder
	
	question: make object! [
		TYPE: sys-copy ["A/" 1 "address"]
		ID: 0 ; 
		RD: does [ either recurse? [1][0] ]
		QNAME: sys-copy ""
		
		to-str: does [
			typ: rejoin [sys-copy/part (first TYPE) (length? first TYPE) - 1 "(" second TYPE ")"]
			rejoin [";; REQUEST: "  typ " for " QNAME ]			
		]
	
		;;set the value of type
		set-command: function [cmd [string!]] [blk] [
			blk: find cmd-list cmd
		 	either blk = none [
		 		TYPE: sys-copy ["A/" 1 "address"]
		 	][
		 		TYPE: sys-copy/part blk 3
			]
		]

		;build binary data to send packet	see insert at the end of this code
		to-bin: does[
			ID: (to-integer now/time) // 65025 ; limit to 2 bytes 
			bin: sys-copy #{}
			append bin to-char ID / 255   ; first byte
			append bin to-char ID // 255  ; second byte
			append bin either recurse? [#{0100}][#{0000}] ; set or unset RD bit
			append bin #{0001000000000000} ; QDCOUNT =1 ANCOUNT,NSCOUNT,ARCOUNT=0
			if "PTR/" = first TYPE [
				QNAME:  reverse-ip QNAME ; get name in in-addr.arpa domain
			]
			append bin encode QNAME
			append bin #{00}
			append bin to-char second TYPE
			append bin #{0001} ; IN class
			bin
		]
	
		;build reverse IP for PTR request in in-addr.arpa domain	
		reverse-ip: func [ip [string!]][
			join reverse to-tuple ip ".in-addr.arpa"
		]
	
		;encode qname <domain-name>:  length string length string ... 0x00
		encode: function[name [string!]] [bin][
			bin: sys-copy #{}
			repeat token parse name "." [
				append bin to-char length? token
				append bin token
			]
			append bin #{00}
			bin
		]
	]	
	
	
	;; decoding packet returning this object in copy , see copy at the end of code 
	answer: make object! [
		
		ID: 0
		AA: 0
		RD: 0
		RA: 0
		RCODE: 0
		ANCOUNT: 0
		NSCOUNT: 0
		ARCOUNT: 0
		error: none
		ques: none
		answers: sys-copy []
		authoritys: sys-copy []
		additionals: sys-copy []
	
		init: function [ data [binary!] ] [pos rep][
			decode-header data
			if error = none [
				pos: decode-question data
				
				for ind 1 ANCOUNT 1 [
					rep: decode-answer data pos
					pos: first rep
					append answers second rep
				]
				
				for ind 1 NSCOUNT 1 [
					rep: decode-answer data pos
					pos: first rep
					append authoritys second rep
				]
				
				for ind 1 ARCOUNT 1 [
					rep: decode-answer data pos
					pos: first rep
					append additionals second rep
				]
			]
		]
		
		
		to-str: does [
			either error = none [
				str: rejoin [
					ques/to-str newline
					";; id: " ID " AA: " AA " RD: " RD " RA: " RA " ANSWER(s): " ANCOUNT " AUTHORITY(s): " NSCOUNT " ADDITIONAL(s): " ARCOUNT newline newline
					";; ANSWER(s):" newline
				]
				
				repeat a answers [ append append str a/to-str newline]
				append str newline
				append append str ";; AUTHORITY(s)" newline
				repeat a authoritys [ append append str a/to-str newline]
				append str newline
				append append str ";; ADDITIONAL(s)" newline
				repeat a additionals [ append append str a/to-str newline]
				str
					
			
			][
				rejoin [
					ques/to-str newline
					";; id: " ID " AA: " AA " RD: " RD " RA: " RA " ANSWER(s): " ANCOUNT newline newline ";; "
					error
				]
			]
		]
		
		
		;; RFC 1035 - 4.1.1
		decode-header: func [ data [binary!] ][
			ID: get-int16 data 0
			flags: get-int16 data 2
			AA: shl (mask flags 2#{0000010000000000}) 10
			RD: shl (mask flags 2#{0000000100000000}) 8
			RA: shl (mask flags 2#{0000000010000000}) 7
			RCODE: mask flags   2#{0000000000001111}
			
			switch/default RCODE [
				0 [
					ANCOUNT: get-int16 data 6
					NSCOUNT: get-int16 data 8
					ARCOUNT: get-int16 data 10
				]
				1 [ error: "1 - Format errror" ]
				2 [ error: "2 - Server failure" ]
				3 [ error: "3 - Name error" ]
				4 [ error: "4 - Not Implemented" ]
				5 [ error: "5 - Refused" ]
			][
				net-error reform ["invalid data RCODE=" RCODE ]
			]
		]
		
		;shift left
		shl: func [arg [integer!] len [integer!] ] [ arg / (2 ** len) ]
		
		;mask
		mask: func [arg [integer!] msk [binary!] ] [ arg and (to-integer msk) ]
		
		decode-question: function [ data [binary!] ] [pos rep typ cmd][
			ques: make question []
			ques/ID: ID
			ques/RD: RD
			pos: 12 ; begining of question
			rep: get-name data pos
			ques/QNAME: sys-copy/part second rep (length? second rep) - 1
			pos: first rep
			typ: get-int16 data pos
			cmd: back find cmd-list typ
			ques/TYPE: sys-copy/part cmd 3
			pos + 4			
		]
		
		;;RFC 1035 - 4.1.3  and 3.3.Standards RRs
		decode-answer: function [ data [binary!] pos [integer!] ] [rep ans nam typ cur-pos rdata str count] [
			rep: sys-copy []
			cur-pos: pos
			ans: make resource []
			nam: get-name data cur-pos
			cur-pos: first nam
			ans/name: second nam
			typ: get-int16 data cur-pos
			cmd: back find cmd-list typ
			ans/TYPE: sys-copy/part cmd 3
			cur-pos: cur-pos + 4 ; skip CLASS
			ans/TTL: get-int32 data cur-pos
			cur-pos: cur-pos + 4
			ans/RDLENGTH: get-int16 data cur-pos
			cur-pos: cur-pos + 2
			rdata: none
			
			name-case: [
				rdata: make name-data []
				str: get-name data cur-pos
				cur-pos: first str
				rdata/name: second str
			]
			
			switch typ [
				1 [ ; A
					rdata: make a-data []
					str: get-ip data cur-pos
					cur-pos: first str
					rdata/ip: second str
				]
				2 name-case ;NS
				5 name-case ;CNAME
				6 [ ; SOA
					rdata: make soa-data []
					str: get-name data cur-pos
					cur-pos: first str
					rdata/MNAME: second str
					str: get-name data cur-pos
					cur-pos: first str
					rdata/RNAME: second str
					rdata/SERIAL: get-int32 data cur-pos
					cur-pos: cur-pos + 4
					rdata/REFRESH:  get-int32 data cur-pos
					cur-pos: cur-pos + 4
					rdata/RETRY:  get-int32 data cur-pos
					cur-pos: cur-pos + 4
					rdata/EXPIRE:  get-int32 data cur-pos
					cur-pos: cur-pos + 4
					rdata/MINIMUM:  get-int32 data cur-pos
					cur-pos: cur-pos + 4
					
				]
				7 name-case ; MB
				8 name-case ;MG
				9 name-case ;MR
				10 [ ; NULL
					rdata: make garbage-data []
					rdata/data: sys-copy/part (at data cur-pos) ans/RDLENGTH
					cur-pos: cur-pos + ans/RDLENGTH
				]
				11 [ ; WKS
					rdata: make wks-data []
					str: get-ip data cur-pos
					cur-pos: first str
					rdata/ip: second str
					str: get-proto data cur-pos
					cur-pos: first str
					rdata/proto: second str
					str: get-bitmap data cur-pos
					cur-pos: first str
					rdata/bit-map: second str
					]
				12 name-case ;PTR
				13 [ ; HINFO
					rdata: make hinfo-data []
					str: get-string data cur-pos
					cur-pos: first str
					rdata/cpu: second str
					str: get-string data cur-pos
					cur-pos: first str
					rdata/os: second str
					
				]
				14 [ ; MINFO
					rdata: make minfo-data []
					str: get-name data cur-pos
					cur-pos: first str
					rdata/RMAILBOX: second str
					str: get-name data cur-pos
					cur-pos: first str
					rdata/EMAILBOX: second str
				]
				15 [ ; MX
					rdata: make mx-data []
					rdata/preference: get-int16 data cur-pos
					cur-pos: cur-pos + 2
					str: get-name data cur-pos
					cur-pos: first str
					rdata/exchange: second str
				]
				16 [ ; TXT
					rdata: make txt-data[]
					count: 0
					until [
						str: get-string data cur-pos
						cur-pos: first str
						count: count + first str
						append rdata/datas second str
						append rdata/datas newline
						(count >= ans/RDLENGTH)
					]
				]

			]
			ans/RDATA: rdata
			append append rep cur-pos ans
		]
		
		
		
		get-int16: func [ data [binary!] pos [integer!]  ] [
			to-integer sys-copy/part (at data pos + 1) 2 
		]
		
		get-int32: func [ data [binary!] pos [integer!]  ] [
			to-integer sys-copy/part (at data pos + 1) 4
		]
		
		get-string: function [ data [binary!] pos [integer!]  ] [cur-pos ind rep][
			rep: sys-copy []
			cur-pos: pos + 1
			len: to-integer pick data cur-pos
			str: to-string sys-copy/part (at data cur-pos + 1) len
			append rep (pos + len + 1)
			append rep str
		]
		
		get-name: function [ data [binary!] pos [integer!]  ] [cur-pos ptr str rep tmp][
			rep: sys-copy []
			cur-pos: pos + 1
			len: to-integer pick data cur-pos
			if len = 0 [return append append rep (pos + 1) sys-copy ""]
			if (to-integer #{C0}) = mask len #{C0} [
				ptr: get-int16 data pos
				ptr: ptr xor (to-integer #{C000})
				return append append rep  (pos + 2) second get-name data ptr
			]
			str: get-string data pos
			pos: first str
			tmp: get-name data pos
			append append rep first tmp rejoin [second str "." second tmp]  
			
		]
		
		get-proto: function [ data [binary!] pos [integer!]  ] [rep][
			rep: sys-copy []
			append append rep (pos + 1)  pick data pos
		]
		
		get-bitmap: function [ data [binary!] pos [integer!]  ] [rep][
			rep: sys-copy []
			append append rep (pos + ans/RDLENGTH - 3)  (tsys-copy/part (at data pos) (ans/RDLENGTH - 3))					
		]
		
		get-ip: function [ data [binary!] pos [integer!]  ] [rep adr][
			rep: sys-copy []
			append append rep (pos + 4)  (to-tuple sys-copy/part (at data pos + 1) 4)
		]
	]
	
	;; resource and resource types
	 resource: make object! [
	 	NAME: sys-copy ""
	 	TYPE: none
	 	TTL: 0
	 	RDLENGTH: 0
	 	RDATA: none
	 	to-str: does [
	 		if not (type = none) [
	 			rejoin [NAME TAB TTL TAB sys-copy/part (first TYPE) (length? first TYPE) - 1 TAB RDATA/to-str ]
	 		]
	 	]
	 ]
	 
	 ;; NS CNAME MB MG MR PTR
	 name-data: make object! [
	 	name: sys-copy ""
	 	to-str: does [ name]
	 ]
	 
	 ;; TXT
	 txt-data: make object! [
	 	datas: sys-copy ""
	 	to-str: does [ datas]
	 ]
	 
	 ;; HINFO
	 hinfo-data: make object! [
	 	cpu: sys-copy ""
	 	os: sys-copy ""
	 	to-str: does [ rejoin ["cpu: " cpu " os: " os]]
	 ]

	;; MINFO
	minfo-data: make object! [
		RMAILBOX: sys-copy ""
		EMAILBOX: sys-copy ""
		to-str: does [  rejoin [RMAILBOX "  " EMAILBOX] ]
	]
	 
	;; MX 
	mx-data: make object! [
		preference: 0
		exchange: sys-copy ""
		to-str: does [rejoin [preference "   " exchange]]
	]
	
	;; SOA
	soa-data: make object! [
		MNAME: sys-copy ""
		RNAME: sys-copy ""
		SERIAL: 0
		REFRESH: 0
		RETRY: 0
		EXPIRE: 0
		MINIMUM: 0
		to-str: does [ 
			rejoin [
				MNAME "  "
				RNAME "  "
				SERIAL "  "
				REFRESH "  "
				RETRY "  "
				EXPIRE "  "
				MINIMUM
			]		
		]
	]
	
	;; A
	a-data: make object! [
		ip: none
		to-str: does [to-string ip]
	]
	
	;; WKS
	wks-data: make object! [
		ip: none
		proto: 0
		bit-map: sys-copy #{00}
		to-str: does [
			str: sys-copy ""
			append str to-sring ip
			append str "  "
			append str switch/default proto [ 6 ["tcp"] 17 ["udp"]] [ proto ]
			append str "  "
			i: 0
			repeat byte bit-map [
				val: to-integer byte
				for j 8 1 -1 [
					if j = (j and val) [
						append str i " "
					]
					i: i + 1
				]
			]
		]
	]
		
	
	
	;; NULL
	garbage-data: make object! [
		data: none
		to-str: does [data]
	]
	
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;; 
	;;protocol methods and fields
	
	scheme: 'dig
	port-id: 53
	port-flags: system/standard/port-flags/pass-thru or 32
	
	open: func [port] [
		open-proto/sub-protocol port 'udp
		if none <> port/target [
			insert port port/target
		]
	]
	
	insert: function [port data] [bin][
		quest: make question [ QNAME: data ]
		quest/set-command port/path
		net-log quest/to-str
		bin: quest/to-bin
		write-io port/sub-port bin length? bin
	]
	
	copy: function [port] [buffer length][
		buffer: make binary! 512
		until [
			length: read-io port/sub-port buffer 512
			(length <= 512)
		]
		net-log rejoin ["COPY read " length? buffer " byte(s)"]
		ans: make answer []
		ans/init buffer
		ans
	]
	
	read: func [port] [
		net-log "READ port"
		insert port port/target
	]
	
	
	
	net-utils/net-install 'dig self 53

]