REBOL [
    Title: "Sqlite 3.X rebol wrapper try"
    File: %sqlite3.r
    Author: "Juan-Carlos Miranda"
    Date: 21-SEP-2004
    Version: 0.0.2
    Purpose: "Sqlite wrapper in Rebol."
    Comment: "Just a try, so it's quite dirty."
    License: "Public Domain"
    Changes: {
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
    library: [
        level: 'intermediate
        platform: [linux windows]
        type: [tool] 
        domain: [database external-library] 
        tested-under: [view 1.2.47.4.2 linux]
        support: none 
        license: public-domain
        see-also: none
    ]
]



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
	sql: load/library %/home/bouba/SQLITE3/lib/libsqlite3.so
	
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



sqlite-exec: func [
    {Execute the specified SQL query.
     Returns results as a block (empty if no result is to be expected.}
    db    [integer!] "database handle"
    query [series!]  "SQL query"
    /names           "If specified, objects will be returned instead of row blocks"
    /local i j val stmt ret col result] [ 
    result: copy [] 
    
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

        while [SQLITE_ROW = ret: sqlite3/step stmt] [
            col: copy []
            j: 0
            repeat i sqlite3/data_count stmt [
                if names [
                    insert tail col to-set-word sqlite3/column_name stmt j
                ]
                insert tail col switch sqlite3/column_type stmt j reduce [
                    SQLITE_INTEGER [sqlite3/column_int           stmt j]
                    SQLITE_FLOAT   [sqlite3/column_double        stmt j]
                    SQLITE_TEXT    [sqlite3/column_text          stmt j]
                    SQLITE_BLOB    [debase sqlite3/column_blob   stmt j]
                ]
                j: i
            ]
            insert/only tail result either names [make object! col][col]
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

example: [
    db: sqlite-open %test.db
    sqlite-exec db "CREATE TABLE t1 (a int , b text , c text);"
    sqlite-exec db "CREATE TABLE t2 (a int , b text , c text);"


    print "Testing of 1000 inserts one transaction at a time."
    t: now/time/precise
    repeat i 1000 [
        sqlite-exec db reduce [{INSERT INTO t1 VALUES (?,"cool1","cool1");} i]
    ]
    delta: now/time/precise - t
    print join "durée = " delta


    print "Testing of 1000 inserts in one global transaction."
    t: now/time/precise
    sqlite-exec db "begin transaction;"
    repeat i 1000 [
        sqlite-exec db reduce [{INSERT INTO t2 VALUES (?,"cool2","cool2");} i]
    ]
    sqlite-exec db "commit transaction;"
    delta: now/time/precise - t
    print join "durée = " delta


    print "Select now all data from both tables."
    print {Just go through "res" block if you want to see the results.}
    res: copy []
    t: now/time/precise
    repeat i 1000 [
        insert tail res sqlite-exec/names db reduce ["SELECT * FROM t1 WHERE a=?;" i]
        insert tail res sqlite-exec/names db reduce ["SELECT * FROM t2 WHERE a=?;" i]
    ]
    delta: now/time/precise - t
    print join "durée = " delta

    sqlite-close db
]