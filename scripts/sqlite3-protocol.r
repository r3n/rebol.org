;; ===========================
;; Script: sqlite3-protocol.r
;; Downloaded from: www.REBOL.org
;; ===========================

REBOL [
    Title: "Sqlite 3.X rebol wrapper as protocol handler"
    File: %sqlite3-protocol.r
    Author: ["Cal Dixon" "Juan-Carlos Miranda"]
    Date: 22-SEP-2004
    Version: 0.1.2
    Purpose: "Sqlite wrapper as a Rebol protocol handler."
    Comment: "This is mostly Juan-Carlos's sqlite3.r script with some extra code wrapped around it"
    License: "Public Domain"
    Changes: {
	22/03/2005 - v0.1.2
			 Added trace function management thanks to the hidden callback! feature.
      22/09/2004 - v0.1.1
                   Changed a few things in the sqlite-exec function and wrapped in all in a protocol (Cal)
      21/09/2004 - v0.0.2
                   Added blob management using enbased strings to make my life easier,
                   maybe not the best solution though.
                   Added the refinement /names to sqlite-exec that allows to get results
                   as objects (I have no use for this but who knows ...)
                   I should consider finding another name but well, i am a lazy boy. :-)
                   I also added a little example that is just that, an example ...
      25/08/2004 - v0.0.1
                   Initial revision.
                   It's a dirty piece of software, but it should work.
    }
    To-Do: {
		- Add management of user functions. I was already able to do some working stuff,
		  But not yet satisfying enough to introduce it. 
    }
    library: [
        level: 'intermediate
        platform: [linux windows]
        type: [tool] 
        domain: [database external-library] 
        tested-under: [view 1.2.47.4.2 linux view 1.2.10.3.1 windows]
        support: none 
        license: public-domain
        see-also: %sqlite3.r
    ]
]


make root-protocol [
	SQLITE_OK:            0   ;; Successful result 
	SQLITE_ROW:         100   ;; sqlite3/step has another row ready 
	SQLITE_DONE:        101   ;; sqlite3/step has finished executing 

	;; sqlite datatypes
	SQLITE_INTEGER:  1
	SQLITE_FLOAT:    2
	SQLITE_TEXT:     3
	SQLITE_BLOB:     4
	SQLITE_NULL:     5

	sqlite3: context [

		;;; Just set this to your sql shared lib or dll path. 
		sql: load/library either exists? %libsqlite3.so [%libsqlite3.so][%sqlite3.dll]

		open: make routine! [ 
			name      [string!]
			db-handle [struct! [[integer!]]]
			return:   [integer!]
			] sql "sqlite3_open"


		close: make routine! [
			db      [integer!]
			return: [integer!]
			] sql "sqlite3_close"


		error-msg: make routine! [
			db      [integer!]
			return: [string!]
			] sql "sqlite3_errmsg"


		prepare: make routine! [
			db      [integer!]
			dbq     [string!]
			len     [integer!]
			stmt    [struct! [[integer!]]]
			dummy   [struct! [[integer!]]]
			return: [integer!]
			] sql "sqlite3_prepare"


		step: make routine! [
			stmt    [integer!]
			return: [integer!]
			] sql "sqlite3_step"


		finalize: make routine! [
			stmt    [integer!]
			return: [integer!]
			] sql "sqlite3_finalize"


		reset: make routine! [
			stmt    [integer!]
			return: [integer!]
			] sql "sqlite3_reset"


		bind_int: make routine! [
			stmt    [integer!]
			idx     [integer!]
			val     [integer!]
			return: [integer!]
			] sql "sqlite3_bind_int"


		bind_double: make routine! [
			stmt    [integer!]
			idx     [integer!]
			val     [decimal!]
			return: [integer!]
			] sql "sqlite3_bind_int"


		bind_text: make routine! [
			stmt    [integer!]
			idx     [integer!]
			val     [string!]
			len     [integer!]
			fn      [integer!]
			return: [integer!]
			] sql "sqlite3_bind_text"


		bind_blob: make routine! [
			stmt    [integer!]
			idx     [integer!]
			val     [string!]
			len     [integer!]
			fn      [integer!]
			return: [integer!]
			] sql "sqlite3_bind_blob"


		data_count: make routine! [
			stmt    [integer!]
			return: [integer!]
			] sql "sqlite3_data_count"


		column_count: make routine! [
			stmt    [integer!]
			return: [integer!]
			] sql "sqlite3_column_count"

		column_name: make routine! [
			stmt    [integer!]
			idx     [integer!] 
			return: [string!]
			] sql "sqlite3_column_name"


		column_type: make routine! [
			stmt    [integer!]
			idx     [integer!]
			return: [integer!]
			] sql "sqlite3_column_type"


		column_bytes: make routine! [
			stmt    [integer!]
			idx     [integer!]
			return: [integer!]
			] sql "sqlite3_column_bytes"

		column_int: make routine! [
			stmt    [integer!]
			idx     [integer!]
			return: [integer!]
			] sql "sqlite3_column_int"


		column_double: make routine! [
			stmt    [integer!]
			idx     [integer!]
			return: [decimal!]
			]  sql "sqlite3_column_double"


		column_text: make routine! [
			stmt    [integer!]
			idx     [integer!]
			return: [string!]
			] sql "sqlite3_column_text"


		column_blob: make routine! [
			stmt    [integer!]
			idx     [integer!]
			return: [string!]
			] sql "sqlite3_column_blob"

		trace: make routine! [
			db  [integer!]
			clb [callback! [int string!]]
			ptr [integer!]
			] sql "sqlite3_trace"
		]

	sqlite-open: func [
		"Create/Open sqlite database."
		name [file!] "database filename"
		/local tmp
		][
		either SQLITE_OK = sqlite3/open to-string name tmp: make struct! [p [integer!]] none [
			tmp/p
			][
			sqlite3/error-msg tmp/p
			]
		]


	sqlite-close: func [
		"Close database."
		db [integer!] "database handle"
		][
		if SQLITE_OK <> sqlite3/close db [
			sqlite3/error-msg db
			]
		]


	sqlite-error: func [
		"Display the error raised by SQLite."
		db [integer!] "database handle"
		][
		make error! sqlite3/error-msg db
		] 

	set 'set-tracing func [ 
		"Set a trace function for the given SQLITE database"
		db               [port!]     "SQLITE database port"
		tracing-function [function!] {tracing function to install. 
							Parameters should always be an integer! and a string!
							Be careful as this is not checked.}
		][
		sqlite3/trace db/locals/dbid :tracing-function 0
		]


	sqlite-exec: func [
		{Execute the specified SQL query.
		 Returns results as a block (empty if no result is to be expected.}
		db    [integer!] "database handle"
		query [series!]  "SQL query"
	    cols [block!] "column names"
		/local i j val stmt ret col result colcount
		][ 
		result: make block! 100
	    either string? query [
	        if not find query ";" [ system/words/insert tail query ";" ]
	        ][
            if not find query/1 ";" [ system/words/insert tail query/1 ";" ]
	        ]
		query: compose [(query)]
		either SQLITE_OK = sqlite3/prepare db first query length? first query stmt: make struct! [p [integer!]] none make struct! [[integer!]] none [
			stmt: stmt/p

			repeat i length? next query [
				ret: switch type? val: pick next query i reduce [
					integer! [ sqlite3/bind_int stmt i val]
					decimal! [ sqlite3/bind_double stmt i val]
					string!  [ sqlite3/bind_text stmt i val length? val 0]
					binary!  [ sqlite3/bind_blob stmt i val: enbase val length? val 0]
				]

				if SQLITE_OK <> ret [
					sqlite-error db
				]
			]

			colcount: sqlite3/column_count stmt
			repeat j colcount [
				system/words/insert tail cols form sqlite3/column_name stmt -1 + j
				]
			while [SQLITE_ROW = ret: sqlite3/step stmt] [
				col: make block! colcount
				j: 0
				repeat i colcount [
					system/words/insert tail col switch sqlite3/column_type stmt j reduce [
						SQLITE_INTEGER [sqlite3/column_int           stmt j]
						SQLITE_FLOAT   [sqlite3/column_double        stmt j]
						SQLITE_TEXT    [sqlite3/column_text          stmt j]
						SQLITE_BLOB    [debase sqlite3/column_blob   stmt j]
						]
					j: i
					]
				system/words/insert/only tail result col
				]
			if SQLITE_DONE <> ret [
				sqlite-error db
				]

			sqlite3/finalize stmt
			][
			sqlite-error db
			]
		result
		]

	port-flags: system/standard/port-flags/pass-thru

	dbid: none
	sqlresult: none
	open: func [port][
	    port/locals: context [dbid: none sqlresult: none cols: system/words/copy []]
		port/locals/dbid: sqlite-open to-file port/target
		port/state/flags: port/state/flags or port-flags
		]

	close: func [port][
		sqlite-close port/locals/dbid
		]

	insert: func [port data][
		port/locals/sqlresult: sqlite-exec port/locals/dbid data port/locals/cols
		data
		]

	copy: func [port][
		port/locals/sqlresult
		]

	net-utils/net-install sqlite self 0
	]

example: [
    print "Starting Test:"
    db: open sqlite://localhost/sqltest.db

    db-tracing: func [ctx str-out] [ print join "DB Trace >> " str-out ]
    set-tracing db :db-tracing

    insert db "CREATE TABLE t1 (a int , b text , c text)"
    repeat i 125 [
        insert db rejoin [{INSERT INTO t1 VALUES (} i {,"cool1","cool1")}]
        ]
    insert db "SELECT * FROM t1"
    res: copy db
    insert db "DROP TABLE t1"
    close db
    probe length? res
    probe res/1
    halt
	]
