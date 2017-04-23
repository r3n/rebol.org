REBOL [
	Title: "techfell uSqlite3 protocol handler"
	Purpose: {
		http://users.iol.it/irwin/
		uSQLite is a network wrapper for SQLite. It turns SQLite into an RDBMS but 
		puts the emphasis on the 'Lite'. In fact it works in a somewhat unconventional
		mmanner in order to make both servers and clients as light, portable and 
		simple as possible. Readers who are not familiar with SQLite are advised 
		to visit www.sqlite.org.
		uSQLite uses the TechFell protocol for communications between clients and servers.
	}
	Comment: "based on mysql-protocol 1.0.2 by Nenad Rakocevic / SOFTINNOV"
	Author: "Piotr Gapinski"
	Email: {news [at] rowery! olsztyn.pl}
	File: %techfell-protocol.r
	Date: 2006-02-9
	Version: 0.0.2
	Copyright: "Olsztynska Strona Rowerowa http://www.rowery.olsztyn.pl/"
	License: "GNU General Public License (GPL)"
	History: [0.0.1 2006-02-09 0.0.2 2006-02-09]
	Library: [
		level: 'intermediate
		platform: [Linux Windows]
		type: [protocol tool]
		domain: [protocol database]
		tested-under: [
			view 1.3.2 on [Linux WinXP]
			core 2.6.2 on [Linux WinXP]
		]
		support: none
		license: 'GPL
	]
]

make root-protocol [
	scheme: 'techfell
	port-id: 3002
	port-flags: system/standard/port-flags/pass-thru 

	linux?: equal? fourth system/version 4

	sys-copy: get in system/words 'copy
	sys-insert: get in system/words 'insert
	sys-pick: get in system/words 'pick
	sys-close: get in system/words 'close
	sys-write: get in system/words 'write
	net-log: get in net-utils 'net-log	

	numbers: charset "0123456789"
	num: [some numbers]

	init: func [port [port!] spec /local scheme args][
		if url? spec [net-utils/url-parser/parse-url port spec]

		port/locals: make object! [
			columns: sys-copy []
			rows: 0 
			values: sys-copy [] 
			index: 0
			tr: "^C" 
			err: none
			rc: 0
			level: 0
		]

		scheme: port/scheme
		port/url: spec

		if none? port/host [
			net-error reform ["No network server for" scheme "is specified"]
		] 
		if none? port/port-id [
			net-error reform ["No port address for" scheme "is specified"]
		]

		if none? port/user [port/user: make string! 0]
		if none? port/pass [port/pass: make string! 0]
		if port/pass = "?" [port/pass: ask/hide "Password: "]
	]

	open: func [port [port!] /local level][
		open-proto port

		port/sub-port/timeout: 4
		port/state/inBuffer: make string! 10240
		port/state/flags: port/state/flags or port-flags
		;; port/sub-port/state/flags: port/sub-port/state/flags or port-flags

		insert-query/tr port ":PPRAGMA VER" CR
		insert-query/tr port ":PPRAGMA ETX" CR
		insert-query port join ":PPRAGMA USER" [" " port/user]
		insert-query port join ":PPRAGMA PASS" [" " port/pass]

		if port/locals/rc [
			parse/all port/state/inBuffer [(level: none) thru "USELEVEL " copy level num]
			net-log ["uselevel" level]
			port/locals/level: to-integer any [level 0]
		]
		port/state/tail: 10	; for 'pick to work properly
	]

	close: func [port [port!]][
		sys-close port/sub-port
	]

	sql-escape: func [value [string!] /local chars no-chars want escaped escape mark] [
		chars: charset want: {^(00)^/^-^M^(08)'"\}
		no-chars: complement chars
		escaped: ["\0" "\n" "\t" "\r" "\b" "\'" {\"} "\\"]
		escape: func [value][
			mark: sys-insert remove mark sys-pick escaped index? find want value
		]
		parse/all value [any [mark: chars (escape mark/1) :mark | no-chars]]
		value
	]

	to-sql: func [value /local res] [
		switch/default type?/word value [
			none!	["NULL"]
			date!	[
				rejoin ["'" value/year "-" value/month "-" value/day
					either value: value/time [
						rejoin [" " value/hour ":" value/minute ":" value/second]
					][""] "'"
				]
			]
			time!	[join "'" [value/hour ":" value/minute ":" value/second "'"]]
			money!	[head remove find mold value "$"]
			string!	[join "'" [sql-escape sys-copy value "'"]]
			binary!	[to-sql to string! value]
			block!	[
					if empty? value: reduce value [return "(NULL)"]
					res: append make string! 100 #"("
					forall value [repend res [to-sql value/1 #","]]
					head change back tail res #")"
				]
		][form value]
	]

	map-rebol-values: func [data [block!] /local args sql mark] [
		args: reduce next data
		sql: sys-copy sys-pick data 1
		mark: sql
		while [found? mark: find mark #"?"][
			mark: sys-insert remove mark either tail? args ["NULL"] [to-sql args/1]
			if not tail? args [args: next args]
		]
		sql
	]

	parse-schema: func [port [port!] /local numbers num headers tr header parts] [
		;numbers: charset "0123456789"
		;num: [some numbers]

		headers: sys-copy []
		tr: port/locals/tr

		parts: [":H" thru " " copy header to tr (append headers any [header ""]) | skip]
		parse/all port/state/inBuffer [some parts to end]

		net-log ["found" (length? headers) "columns"]
		headers
	]

	parse-rows: func [port [port!] columns [integer!] /local numbers num rows tr dat parts here txt there values] [
		;numbers: charset "0123456789"
		;num: [some numbers]

		rows: sys-copy []
		tr: port/locals/tr

		dat: find/tail sys-copy port/state/inBuffer (join ":R" tr)
		if none? dat [return rows]

		;; usun nadmiarowe znaczniki i podziel na linie
		;; pamietaj o usunieciu znacznika tr w linii :OK
		parts: [
			here:
			  [":F" copy len num " " copy txt to tr there: (remove/part here there sys-insert here txt) :here]
			| ["!" there: (remove/part here there sys-insert here "none") :here]
			| [":OK" tr there: (remove/part here there) :here]
			| skip
		]
		parse/all dat [some parts to end]
		values: parse/all dat tr

		if all [
			not empty? values
			not zero? columns
		][
			net-log ["found" ((length? values) / columns) "rows" columns "columns per row"]
			forskip values columns [append/only rows sys-copy/part values columns]
		]
		rows
	]

	err?: func [port [port!] /local eol tr txt] [
		eol: charset "^M^C^@^/" ; CR LF ETX ZERO
		tr: any [
			if parse/all port/state/inBuffer [thru ":OK" copy tr eol] [tr]
			"^C"
		]
		parse/all port/state/inBuffer [(txt: none) thru ":Err " copy txt to tr]
		port/locals/tr: tr
		not port/locals/rc: empty? port/locals/err: any [txt ""]
	]

	insert-query: func [port [port!] dat [string!] /tr new-tr /local length buffer] [
		dat: join dat either all [value? tr new-tr] [new-tr] [port/locals/tr]
		clear port/state/inBuffer

		net-log ["send" dat length? dat]
		write-io port/sub-port dat length? dat

		wait port/sub-port
		buffer: make string! 2048

		until [
			length: read-io port/sub-port buffer 2048
			append port/state/inBuffer buffer
			clear buffer
			all [
				(length < 2048)
				none? wait [port/sub-port 0:0:0.05]
			]
		]

		net-log ["recv" port/state/inBuffer length? port/state/inBuffer]
		err? port
	]

	insert: func [[throw] port [port!] data [string! block!] /local columns] [
		clear port/state/inBuffer
		clear port/locals/values
		port/locals/rows: 0
		port/locals/index: 0

		;; execute sql

		if all [(string? data) (data/1 = #"[")] [data: load data]
		if empty? data [net-error "No data!"]
		either block? data [
			insert-query port data: map-rebol-values data
		][
			insert-query port data: replace/all data {"} {'}
		]

		;; parse output

		if all [
			port/locals/rc
			found? find port/state/inBuffer join ":R" port/locals/tr
		][
			port/locals/columns: parse-schema port
			columns: length? port/locals/columns
			port/locals/values: parse-rows port columns
			port/locals/rows: length? port/locals/values
		]
		port/locals/rc
	]

	read-rows: func [port [port!] /part n [integer!] /local values] [
		if any [
			not port/locals/rc	;; error
			empty? port/locals/values	;; no sql output
		][
			return []
		]

		values: skip port/locals/values port/locals/index
		either all [value? 'part n] [sys-copy/part values n] [sys-copy values]
	]

	copy: func [port /part data [number! binary!] /local rows][
		rows: either all [value? 'part part] [read-rows/part port data] [read-rows port]
		net-log ["copy" (length? rows) "rows" "at" "index" port/locals/index]
		port/locals/index:  port/locals/index + length? rows
		rows
	]

	pick: func [port [port!] data][
		either any [none? data data = 1] [copy/part port 1] [none]
	]

	net-utils/net-install :scheme self :port-id
]

comment {
	; example
	db: open techfell://user:?@localhost
	insert db "CREATE TABLE t1 (a int, b text, c text)"
	repeat i 25 [
		insert db [{INSERT INTO t1 VALUES (?, ?, ?)} i (join "cool" i) (join "cool" (25 + 1 - i))]
	]
	insert db "SELECT * FROM t1"
	probe db/locals/columns
	res: copy/part db 10
	probe res
	probe length? res
	insert db "DROP TABLE t1"
	close db
	halt
}
