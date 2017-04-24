REBOL [
	Title: "better-than-nothing sqlite3 handler"
	Purpose: "easy access to sqlite3 database without /Pro or /Command features"
	Comment: "based on mysql-protocol 1.0.2 by Nenad Rakocevic / SOFTINNOV"
	Author: "Piotr Gapinski"
	Email: {news [at] rowery! olsztyn.pl}
	File: %btn-sqlite.r
	Date: 2006-01-30
	Version: 0.2.2
	Copyright: "Olsztynska Strona Rowerowa http://www.rowery.olsztyn.pl/"
	License: "GNU General Public License (GPL)"
	History: [0.1.0 2006-01-20 0.1.1 2006-01-20 0.2.0 2006-01-25 0.2.1 2006-01-27 0.2.2 2006-01-30]
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
	scheme: 'btn
	port-id: 0
	port-flags: system/standard/port-flags/pass-thru
	awake: none
	open-check: none

	sqlite: none
	options: none
	linux?: equal? fourth system/version 4

	sys-copy: get in system/words 'copy
	sys-insert: get in system/words 'insert
	sys-pick: get in system/words 'pick
	sys-close: get in system/words 'close
	sys-write: get in system/words 'write
	net-log: get in net-utils 'net-log	

	init: func [[catch] port spec] [
	        if not url? spec [net-error "Bad URL"]
		net-utils/url-parser/parse-url port spec
		if none? port/target [net-error reform ["No database name for" port/scheme "is specified"]]

		port/locals: make object! [columns: none rows: 0 values: none sqlite-rc: 0 index: 0]
		port/url: spec 

		sqlite: any [
			select [3 "sqlite3.exe" 4 "/usr/bin/sqlite3"] (fourth system/version)
			"sqlite3"
		]
		options: {-html -header}
	]

	open: func [port [port!]][
		port/state/flags: port/state/flags or port-flags
	]

	close: func [port [port!]][]

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

	insert-query: func [port [port!] data [string! block!] /local cmd] [
		cmd: reform [sqlite options port/target rejoin [{"} data {"}]]
		net-log ["call" cmd]
		port/locals/sqlite-rc: call/wait/output cmd port/state/inBuffer
	]

	parse-schema: func [port [port!] /local headers parts] [
		headers: sys-copy []
		parts: [<th> copy header to </th> (append headers any [header ""]) | skip]

		parse/all port/state/inBuffer [some parts to end]
		net-log ["found" (length? headers) "columns"]
		headers
	]

	parse-rows: func [port [port!] items-per-row [integer!] /local values parts rows] [
		values: sys-copy []
		parts: [<td> copy value to </td> (append values any [value ""]) | skip]

		parse/all port/state/inBuffer [some parts to end]
		rows: sys-copy []

		if all [
			not empty? values
			not zero? items-per-row
		][
			net-log ["found" ((length? values) / items-per-row) "rows" items-per-row "columns per row"]
			forskip values items-per-row [append/only rows sys-copy/part values items-per-row]
		]
		rows
	]

	insert: func [[throw] port [port!] data [string! block!] /local items-per-row] [
		port/state/inBuffer: make string! 4096
		port/locals/values: none
		port/locals/rows: 0
		port/locals/index: 0

		;; execute sql

		if all [(string? data) (data/1 = #"[")] [data: load data]
		either block? data [
			if empty? data [net-error "No data!"]
			insert-query port data: map-rebol-values data
		][
			insert-query port data: replace/all data {"} {'}
		]

		;; parse output

		port/locals/columns: parse-schema port
		items-per-row: length? port/locals/columns

		port/locals/values: parse-rows port items-per-row
		port/locals/rows: length? port/locals/values

		zero? port/locals/sqlite-rc
	]

	read-rows-html: func [port [port!] /part n [integer!] /local rows] [
		if any [
			not zero? port/locals/sqlite-rc	;; sqlite error
			empty? port/locals/values	;; no sql output
		][
			return []
		]

		values: skip port/locals/values port/locals/index
		either all [value? 'part n] [sys-copy/part values n] [sys-copy values]
	]

	copy: func [port /part data [integer!] /local rows][
		rows: either all [value? 'part part] [read-rows-html/part port data] [read-rows-html port]
		net-log ["copy" (length? rows) "rows" "at" "index" port/locals/index]
		port/locals/index:  port/locals/index + length? rows
		rows
	]

	net-utils/net-install :scheme self :port-id
]

comment {
	; example
	db: open btn://localhost/test.db3
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
