REBOL [
	Title: "PARADOX-PROTOCOL"
	File: %paradox-protocol.r
	Author: "nicolas"
	Purpose: "Paradox database REBOL protocol"
	Email: "nverscheure free fr"
  Library: [ 
    level: 'beginner 
    platform: 'all 
    type: [protocol] 
    domain: [database] 
    tested-under: [windows] 
    support: none 
  ]	
	Description: {
		Paradox Database REBOL protocol
		Based on the work of Randy Beck
        rb@randybeck.com
        http://www.randybeck.com
        Paradox file format description :
        http://www.scalabium.com/pdx/pdx2txt.htm
		
		Datatype supported : char, longint, logical, date, time
		
		Do not support index file and other stuff Like that.
		Very basic approach.
		
		For the writting of the protocol, get inspired by mysql protocol 
		written by DocKimbel Softinnov (http://softinnov.org)
		
		ROADMAP :
		- Correct port : distinct directory from single file
		- Test protocol with heavy file
		- Make a paradox viewer with View
		- Implement SQL Command : SELECT
	}
	Version: 0.3.3
	Date: 03/03/2011
	History: [
		03/03/2011 0.3.3 "(nve) Correct problem with empty file and pb with directory"
		28/01/2011 0.3.2 "(nve) Release on rebol.org"
		16/11/2010 0.3.1 "(nve) Correct open for single file"
		13/11/2010 0.3.0 "(nve) Merge db-reader.r into protocol"
		05/11/2010 0.2.0 "(nve) Send all the rows"
		03/11/2010 0.2.0 "(nve) Implement copy and insert function"
		02/11/2010 0.1.0 "(nve) Creation of the REBOL program"
	]
	Comment: ""
	Usage: {
		>> do %paradox-protocol.r
		>> db-port: open paradox://MON_FICHIER_PARADOX.db
		>> insert db-port "SELECT * FROM MON_FICHIER_PARADOX"
		>> foreach item copy db-port [probe item]
		>> foreach item copy/part db-port 8 [probe item]
		>> close db-port
	}
	Notes: "Sorry for my english"
	License: {
		Copyright 2011 Nicolas Verscheure. All rights reserved.

		Redistribution and use in source and binary forms, with or without modification, are
		permitted provided that the following conditions are met:

		   1. Redistributions of source code must retain the above copyright notice, this list of
			  conditions and the following disclaimer.

		   2. Redistributions in binary form must reproduce the above copyright notice, this list
			  of conditions and the following disclaimer in the documentation and/or other materials
			  provided with the distribution.

		THIS SOFTWARE IS PROVIDED BY NICOLAS VERSCHEURE ``AS IS'' AND ANY EXPRESS OR IMPLIED
		WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
		FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL NICOLAS VERSCHEURE OR
		CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
		CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
		SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
		ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
		NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
		ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

		The views and conclusions contained in the software and documentation are those of the
		authors and should not be interpreted as representing official policies, either expressed
		or implied, of Nicolas Verscheure.
	}
	Copyright: (c) 2011, Nicolas VERSCHEURE
]

make root-protocol [
	scheme: 'paradox
	db: object!
	port-flags: system/standard/port-flags/pass-thru	
	open*: get in system/words 'open
	copy*: get in system/words 'copy
	pick*: get in system/words 'pick
	close*: get in system/words 'close
	locals-class: make object! [
		stream-end?: none
		rowcount: 0
		columns: 0
		rownum: 0
	]
	;-----------------------------------------------------------------------------
	read-rows: func [port [port!] /part n [integer!]
		/local rows count
	][
		either part [count: any [n 0]] [count: max any [n 0] port/locals/rowcount]
		rows: make block! max any [n 0] port/locals/rowcount
		for i 1 count 1 [
			port/locals/rownum: port/locals/rownum + 1
			if port/locals/stream-end?: (port/locals/rownum > port/locals/rowcount) [break]
			append/only rows pick* db/db-data port/locals/rownum
		]
		rows
	]
	;------------------- DATABASE PARADOX ----------------------------------------
	db-database: make object! [
	  empty-file: false
		db-file: file!
		db-type: [
			byte 			1
			integer 	2
			word			2
			longint		4
			shortint	2
			char			1
			pchar			4
			^pchar		4
			date			4
			logical		1
			time			4
			timestamp	8
			number		8
		]
		numRecords: none
		numFields: none
		db-structure: [
			#04		fileType		byte
			#05		maxTableSize	byte
			#06		numRecords		longint
			#21		numFields		integer
			#39		fileVersionID	byte
		]
		maxTableSizeValue: [
			1	["64M    (block size = $0400 bytes)" 1024	#0400]
			2	["128M    (block size = $0800 bytes)" 2048	#0800]
			3	["192M    (block size = $0C00 bytes)" 3072	#0C00]
			4	["256M    (block size = $1000 bytes)" 4096	#1000]
		]
		fileTypeValue: [
			0	"this is an indexed .DB data file"
			1	"this is a primary index .PX file"
			2	"this is a non-indexed .DB data file"
			3	"this is a non-incrementing secondary index .Xnn file"
			4	"this is a secondary index .Ynn file (inc or non-inc)"
			5	"this is an incrementing secondary index .Xnn file"
			6	"this is a non-incrementing secondary index .XGn file"
			7	"this is a secondary index .YGn file (inc or non inc)"
			8	"this is an incrementing secondary index .XGn file" 
		]
		fileVersionIDValue: [
			3	[#03	"version 3.0"	79]
			4	[#04	"version 3.5"	79]
			5	[#05	"version 4.x"	79]
			6	[#06	"version 4.x"	79]
			7	[#07	"version 4.x"	79]
			8	[#08	"version 4.x"	79]
			9		[#09	"version 4.x"	79]
			10	[#0A	"version 5.x"	79]
			11	[#0B	"version 5.x"	79]
			12	[#0C	"version 7.x"	261]
		]
		fieldTypeValue: [
			1 	[char "Alpha" ]
			2 	[date "Date" ]
			3		[shortint "Short integer" ]
			4		[longint "Long integer" ]
			5		[currency "currency" ]
			6		[number "Number" ]
			9		[logical "Logical" ]
			11	[byte "Memo BLOb" ]
			12	[byte "Binary Large Object" ]
			13	[byte "Formatted Memo BLOb" ]
			14	[byte "OLE" ]
			16	[byte "Graphic BLOb" ]
			20	[time "Time" ]
			21	[timestamp "Timestamp" ]
			22	[integer "Autoincrement" ]
			23	[byte "BCD" ]
			24 	[byte "Bytes" ]
		]
		db-data: []
		db-fieldtypes: []
		db-file-port: port! 
		;===============================================================================
		; READ STRUCTURE OF PARADOX FILE
		get-header: func [] [
			db-file-port: open*/seek db-file
			forskip db-structure 3 [
				d: copy*/part at db-file-port (to-integer db-structure/1) + 1 select db-type db-structure/3
				switch db-structure/2 [
					fileType [
						d: to-integer d
					]
					maxTableSize [
						d: (to-integer d) - (to-integer #F)
					]
					numRecords [
						d: to-integer reverse d
					]
					numFields [
						d: to-integer reverse d
					]
				]
				set db-structure/2 d
			]
			db-fieldtypes: []
			; RECUPERATION DU TYPE DES CHAMPS 
			o: to-integer #79
			for n 1 numFields 1 [
				append db-fieldtypes to-integer copy*/part at db-file-port o 1
				o: o + 1
				append db-fieldtypes to-integer copy*/part at db-file-port o 1
				o: o + 1
			] 
			; NOM DE TABLE
			; tableNamePtr
			o: o + 4
			; array[1..(numFields)] of pchar         fieldNamePtrArray
			for n 1 numFields 1 [
				o: o + 4
			]
			d: copy*/part at db-file-port o third select fileVersionIDValue to-integer fileVersionID
			t: copy* ""
			foreach i d [either i == 0 [break] [t: join t to-char i]]
			tableName: t
			; RECUPERATION DU NOM DES CHAMPS 
			db-fieldnames: []
			o: to-integer #01C4
			for n 1 numFields 1 [
				s: copy* ""
				forever [
					d: to-integer copy*/part at db-file-port o 1
					o: o + 1
					either d == 0 [
						append db-fieldnames copy* s
						break
					][
						s: join s to-char d
					]
				] 
			]
			close* db-file-port
 		]
		; RECUPERATION DES DONNEES
		get-data: func [] [ 
			db-data: []
			db-file-port: open*/seek db-file
			; Start of 
			o: to-integer #0800
			; 0002 | word      blockNumber
			o: o + 2
			blockNumber: to-integer copy*/part at db-file-port o 2
			; 0004 | integer   addDataSize
			o: o + 2	
			addDataSize: to-integer copy*/part at db-file-port o 2
			; 0006.......      fileData 
			o: o + 2 + 1
			for m 1 numRecords 1 [
				data-blk: copy* []
				for n 1 numFields 1 [
					; length of the datatype 
					len: pick* db-fieldtypes (n * 2)
					; get data according to datatype
					switch/default first select fieldTypeValue pick* db-fieldtypes ((n * 2) - 1) [
						char [
							s: copy* ""
							for i 1 len 1 [
								d: to-integer copy*/part at db-file-port o 1
								if d <> 0 [
									s: join s to-char d
								]
								o: o + 1
							]
							append data-blk s
						] 
						longint [
							v: to-integer copy*/part at db-file-port o len
							either v >= 0 [v: (to-integer #80000000) + v][v: v - (to-integer #80000000)]
							append data-blk to-integer v
							o: o + len
						]
						number [
							v: to-integer copy*/part at db-file-port o len
							print rejoin ["v = " v]
							either v >= 0 [v: (to-integer #80000000) + v][v: v - (to-integer #80000000)]
							append data-blk to-integer v
							o: o + len
						]						
						logical [
							v: (to-integer copy*/part at db-file-port o len) - (to-integer #80)
							append data-blk to-logic v
							o: o + len
						]
						date [
							t: (to-integer copy*/part at db-file-port o len)							
							v: t - (to-integer #80000000)
							d: 1/1/0001
							d: d + v - 1
							append data-blk d
							o: o + len
						]
						time [							
							t: (to-integer copy*/part at db-file-port o len)
							v: t - (to-integer #80000000)
							d: v / 1000
							append data-blk to-time d
							o: o + len
						]
					] [
						s: copy* ""
						
						s: copy*/part at db-file-port o len
						append data-blk s
						o: o + len
					]
				]
				append/only db-data data-blk 
			]
			close* db-file-port
		]
		show-header: func ["Print header of the file"] [
			print rejoin [
				'fileTypeValue " = " select fileTypeValue fileType newline
				'maxTableSize " = " select maxTableSizeValue maxTableSize maxTableSize newline
				'numRecords " = " numRecords newline
				'numFields " = " numFields newline
				'tableName " = " tableName newline
				'fileVersionID " = " second select fileVersionIDValue to-integer fileVersionID
			]
			print ["Liste des champs :"]
			forskip db-fieldnames 1 [
				print rejoin [index? db-fieldnames " " db-fieldnames/1]
			]
			print ["Liste des champs :"]
			forskip db-fieldtypes 2 [
				print rejoin [to-integer (index? db-fieldtypes) / 2 + 1 " " select fieldTypeValue db-fieldtypes/1 " " db-fieldtypes/2]
			]
		]
		show-data: func [] [
			for n 1 numRecords 1 [
				print rejoin ["=> Record n° " n] 
				data: pick* db-data n
				db-fieldnames: head db-fieldnames
				forskip db-fieldnames 1 [
					print rejoin [tab index? db-fieldnames " " first db-fieldnames " = " pick* data index? db-fieldnames]
				]
			]
		]			
	]
	;-----------------------------------------------------------------------------
	open: func [port [port!]][
	  ;-- Say how big we are
	  port/state/tail: 2000
	  port/state/index: 0
	  port/state/flags: port/state/flags or port-flags		
	  port/locals: make locals-class []  	  
    db: make db-database []
		either none? port/target [
	    db/db-file: to-file port/host
		][
		  db/db-file: dirize port/host
		  if not none? port/path [db/db-file: join db/db-file dirize port/path]
		  if not none? port/target [db/db-file: join db/db-file port/target]
		  db/db-file: to-file db/db-file
		]
		db/empty-file: not ((size? db/db-file) > 0)
		if not db/empty-file [
     	db/get-header
	  	port/locals/columns: db/numFields
    ]
	]
  copy: func [port [port!] /part data [integer!]][
  	if not db/empty-file [
  	  either not port/locals/stream-end? [
  			either all [value? 'part part][read-rows/part port data][read-rows port]
  		][none]
	  ]
  ]
  insert: func [port [port!] data [string! block!] /local res][
		if not db/empty-file [
		  either block? data [
  			if empty? data [net-error "INSERT: No data !"]
  			print ["INSERT data:" mold data]
  		][
  			either find/any data "DESC*" [
  				db/show-header
  			][
  				if find/any data "SELECT*" [
  					db/get-data
  					port/locals/rownum: 0
  					port/locals/stream-end?: db/numRecords <= 0
  					port/locals/rowcount: db/numRecords
  				]
  			]
  		]
	  ] 
  ]
  close: func [port [port!]][
  	;print "CLOSE"
  ]
  pick: func [port [port!] data][
		if not db/empty-file [
  		either any [none? data data = 1][
  			either port/locals/stream-end? [copy* []][copy/part port 1]
  		][none]
    ]
  ]	
	;-----------------------------------------------------------------------------
	;--- Register ourselves.
	net-utils/net-install paradox self 0
]
