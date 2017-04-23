REBOL [
    Title: "SQL PROTOCOL"
    Date: 05-Mar-2006
    Author: ["Marco"]
    Version: 0.6.8
    Email: [marco@adyreb.org]
    File: %sql-protocol.r
    Category: [database]
    Library: [
        level: 'intermediate
        platform: 'all
        type: [dialect protocol tool]
        domain: [database db dialects protocol scheme sql]
        tested-under: [win]
        support: marco@adyreb.org
        license: 'public-domain
        see-also: none
    ]
    Purpose: {
		SQL-PROTOCOL is a SQL Relationnal Database Management System (RDBMS) entirely written in REBOL 
		with JOIN and SORT capability. This allow you having an easy to use lightweight database engine embeded
		in your REBOL application.
		
		Today, sql-protocol execute only these kind of query :
		* SELECT ... FROM ... WHERE ... ORDER BY ...
		* INSERT ... INTO ... VALUES ...
		* UPDATE ... SET ... WHERE ...
		* DELETE FROM ... WHERE ...
		* CREATE TABLE ...
		* DROP TABLE ...
		
		Query can be submited either as a standard SQL query string or as a SQL like query dialect block.
		* by using SQL query string you will have a better compatibility with other database system like MySQL, Oracle or DB2.
		* by using SQL query dialect you will get advantage of REBOL scripting facility.
		
		This quick example illustrates how to load the protocol, open a database, 
		select some rows from two tables, probe the result and close the database.
		
		Using standard SQL query string :
		
		    do %sql-protocol.r
		    db: open sql:my-db
		    insert db {
		        SELECT * FROM a, b
		        WHERE a.c2 = b.c1 AND a.c1 = 1
		        ORDER BY 1, 2 DESC
		    }
		    foreach item copy db [probe item]
		    close db
		
		The same using the SQL dialect :
		
		    do %sql-protocol.r
		    db: open sql:my-db
		    insert db [
		        SELECT * FROM a b
		        WHERE a.c2 = b.c1 AND a.c1 = 1
		        ORDER BY 1 [2 DESC]
		    ]
		    foreach item copy db [probe item]
		    close db
		
		Moreover, sql-protocol provide a basic compabibility with the ODBC text driver {Microsoft text driver (*.csv,*.txt)} 
		in order to provide a quick and simple way to share data between REBOL application and any ODBC application,
		for example, MS Excel to produce table or chart,or MS Word to produce letters or mailing.
		
		sql-protocol provide also a set of file protocol which can be used directly in your script :
		DATA:  - text file containing a REBOL block for each row
		HEAP:  - same as DATA but for transient table (in memory table)
		CSV:   - delimited file by any caracter except doublequote ("), newline (^/) or linefeed (^M).
    }
    Comment: {
        This script includes some elements inspired from Logan
        This script is also inspired by ODBC and MySQL
        
        Many thanks to Christophe for the Rebol Unit tool that I use to test each version of sql-protocol.
        Many thanks to Robert for the Make Doc Pro tool that I use to produce the documentation of sql-protocol.
    }
    Usage: {
        Columns id must be either table-name.column-name or row/index
        Table & Alias couple must be placed in a block
        Columns & Asc | Desc couple must be placed in a block

        Sample for persistent dababase :
        --------------------------------
        do %sql-protocol.r
        db: open sql:my-db
        insert db [CREATE TABLE a [c1 c2 c3] IF NOT EXISTS]
        insert db [CREATE TABLE b [c1 c2] IF NOT EXISTS]
        insert db [CREATE TABLE c [c1 c2 c3] TYPE = HEAP]
        insert db [CREATE TABLE d [c1 c2 c3] TYPE = [CSV ColNameHeader: false format: 'Delimited delimited: ";"]
        insert db [INSERT INTO a VALUES 
            [1 2 3]
            [1 2 4]
            [2 3 4]
            [3 4 5]
        ]
        insert db [INSERT INTO b VALUES 
            [1 "x"]
            [2 "y"]
        ]
        repeat i 100 [insert db compose/deep [INSERT INTO c VALUES [(i) (i + 1) (i + 2)]]]
        insert db [SELECT DISTINCT * a.c2 FROM a [b b1]
            WHERE a.c2 = b1.c1 AND a.c1 = 1
            ORDER BY 1 [2 DESC]
        ]
        foreach item copy db [probe item]
        insert db [UPDATE c SET c1: 1 WHERE c1 > 50]
        insert db [DELETE FROM c WHERE c1 >= 2]
        insert db [DROP TABLE a]
        close db
    }
    History: [
        0.0.1 [15-Sep-2004 {Initial alpha version} marco@adyreb.org]
        0.1.0 [28-Sep-2004 {Change in provision of SQl protocol - DATA: protocol & database object} marco@adyreb.org]
        0.2.0 [13-Oct-2004 {First beta published on www.rebol.org} marco@adyreb.org]
        0.3.0 [11-Nov-2004 {Add CSV protocol, change on DATA protocol and preparation to FIXED protocol} marco@adyreb.org]
        0.4.0 [14-Dec-2004 {Implement new schema.ctl and extend TYPE = clause} marco@adyreb.org]
        0.5.0 [17-Jan-2005 {Alpha version published on www.rebol.org} marco@adyreb.org]
        0.6.0 [17-Jan-2005 {More flexible SQL dialect (FROM clause)} marco@adyreb.org]
        0.6.1 [16-Mar-2005 {More flexible SQL dialect (columns, WHERE and ORDER BY clause)} marco@adyreb.org]
        0.6.2 [29-Mar-2005 {Extends test case} marco@adyreb.org]
        0.6.3 [11-May-2005 {End of extended test and publication to library} marco@adyreb.org]
        0.6.4 [02-Feb-2006 {Add LIKE clause + some bug correction} marco@adyreb.org]
        0.6.5 [05-Feb-2006 {First attempt of SQL string parsing for SELECT + some bug correction} marco@adyreb.org]
        0.6.6 [07-Feb-2006 {Correction of a bug when using word in the SQL dialect} marco@adyreb.org]
        0.6.7 [08-Feb-2006 {Improvement of word handling in dialect} marco@adyreb.org]
        0.6.8 [05-Mar-2006 {Implement SQL parsing for INSERT, UPDATE & DELETE clauses} marco@adyreb.org]
    ]
    to-do: [
        {Implement /new when openning sql protocol and throw an error fr all other refinements}
        {Implement directory mngt for sql protocol}
        {implement FixedLength file (FIXED protocol)}
        {More and more, improve performance and simplify the script}
    ]
]

; *******************************************************************
; protocol utilities
; *******************************************************************

; -----------------
; Word redefinition
; -----------------
; These words are redefined because
; - either they are functions redefined for the protocol handler
; - or they are used as refinement within functions of thze protocol handler

all*: get in system/words 'all
any*: get in system/words 'any
change*: get in system/words 'change
close*: get in system/words 'close
copy*: get in system/words 'copy
find*: get in system/words 'find
get-modes*: get in system/words 'get-modes
insert*: get in system/words 'insert
open*: get in system/words 'open
pick*: get in system/words 'pick
poke*: get in system/words 'poke
query*: get in system/words 'query
remove*: get in system/words 'remove
update*: get in system/words 'update
skip*: get in system/words 'skip
select*: get in system/words 'select
sort*: get in system/words 'sort
set-modes*: get in system/words 'set-modes

; -----------------------
; port flags redefinition
; -----------------------
; These are the values I could find, but some are misssing

system/standard/port-flags: make system/standard/port-flags [
    read: to-integer power 2 0
    write: to-integer power 2 1
    append: to-integer power 2 2
    new: to-integer power 2 3
    flag-4: to-integer power 2 4
    binary: to-integer power 2 5
    lines: to-integer power 2 6
    flag-7: to-integer power 2 7
    with: to-integer power 2 8
    opened: to-integer power 2 9
    closed: to-integer power 2 10
    wait: to-integer power 2 11
    flag-12: to-integer power 2 12
    eof: to-integer power 2 13
    async: to-integer power 2 14
    flag-15: to-integer power 2 15
    flag-16: to-integer power 2 16
    changed: to-integer power 2 17
    updated: to-integer power 2 18
    direct: to-integer power 2 19
    flag-20: to-integer power 2 20
    custom: to-integer power 2 21
    pass-thru: to-integer power 2 22
    flag-23: to-integer power 2 23
    seek: to-integer power 2 24
    skip: to-integer power 2 25
    flag-26: to-integer power 2 26
    flag-27: to-integer power 2 27
    allow-read: to-integer power 2 28
    allow-write: to-integer power 2 29
    flag-30: to-integer power 2 30
    flag-31: to-integer -1
]

; --------------------
; throw-error function
; --------------------

throw-error: func [
    [throw]
    "Throw an error base on err parms"
    err [error! block! object!]
][
    either error? err [
        err: disarm err
    ][
        err: make error-object err
    ]
    throw make error! reduce bind [type id arg1 arg2 arg3 near where] in err 'self
]

; -----------------------
; to-record function
; -----------------------
    to-record: func [
        value
        only
        /local data item rule out-data sub-data
    ][
        parse data: copy/deep value rule: [
            any [
                s: set item word! (either value? item [
                    change/only s get item
                ][
                    s: next s
                ]) :s
            |
                into rule
            |
                skip
            ]
        ]
        either all [
            not only
            parse data [any [block!]]
        ][
            data
        ][
            reduce [data]
        ]
    ]


; *******************************************************************
; Base data protocol handler
; *******************************************************************

base-protocol: context [
; ------------------
; BASE Close handler
; ------------------

    close: func [
        {Close sub-port} 
        port [port!] "An open port spec"
    ][
        net-utils/net-log reduce ["Closing port for" to-string port/scheme]
        if port? port/sub-port [
            close* port/sub-port
        ]
        port
    ]

; -------------------
; BASE Update handler
; -------------------

    update: func [
        {Update sub-port} 
        port [port!] "An open port spec"
    ][
        net-utils/net-log reduce ["Updating port for" to-string port/scheme] 
        if port? port/sub-port [
            update* port/sub-port
        ]
        port
    ]

; -----------------
; BASE Pick handler
; -----------------

    pick: func [
        "Pick operation." 
        port [port!] "An open port spec"
        data "Index where to pick data"
        /local buffer
    ][
        net-utils/net-log ["Pick at " data "index"]
        if none? data [data: 1]
        buffer: at port/state/inBuffer index? port
        pick* buffer data
    ]

; -----------------
; BASE Copy handler
; -----------------

    copy: func [
        "Copy operation." 
        port [port!] "An open port spec"
        /local buffer
    ][
        net-utils/net-log ["Copy of" port/scheme]
        buffer: at port/state/inBuffer index? port
        copy*/part buffer port/state/num
    ]

; ----------------------
; BASE get-modes handler
; ----------------------
    get-modes: func [
        port [port!] "An open port spec"
        modes "A mode block"
    ][
        get-modes* port
    ]

; ----------------------
; BASE set-modes handler
; ----------------------
    set-modes: func [
        port [port!] "An open port spec"
        modes "A mode block"
    ][
        set-modes* port
    ]
]

        
; *******************************************************************
; Default file handler (reused for data, csv and fixed protocol)
; *******************************************************************

file-handler: context [

; -----------------
; FILE Init handler
; -----------------
    init: func [
        port
        spec
        /local scheme file path target locals
    ][
        net-utils/net-log reduce ["Initializing" to-string spec "for" to-string port/scheme] 

        if url? spec [
            set [scheme target] parse/all spec ":"
            spec: compose [scheme: (scheme) target: (target)]
        ]
        spec: context spec
; ------------
; Manage shema
; ------------
        if any [
            none? locals: in spec 'schema
            none? locals: get locals
        ][
            locals: []
        ]
        port/locals: make file-schema locals

; ----------------------------
; Manage file, path and target
; ----------------------------
        target: to-file spec/target
        if any [
            none? path: in spec 'path
            none? path: get path
        ][
            either #"/" = first target [
                path: %/.
            ][
                path: %.
            ]
        ]
        if #"/" <> first target [
            path: dirize to-file path
        ]
        set [path target] split-path file: join path spec/target
        if none? target [target: %./]
        if not any [
            #"/" = last target
            find target #"."
        ][
            target: join target port/handler/file-extension port
        ]
        port/path: clean-path path
        port/target: target
        if none? port/target [
            net-error reform ["No target file for" port/scheme "is specified"]
        ] 
    ]
; -----------------
; FILE Open handler
; -----------------
    open: func [
        {Open sub-port.} 
        port "Initalized port spec"
        /local sub-port inBuffer file header delimiter cmd parms
    ][
        net-utils/net-log reduce ["Opening port for" to-string port/scheme]
        port/status: 'file

        port/state/flags: port/state/flags and complement system/standard/port-flags/direct
        port/state/flags: port/state/flags or system/standard/port-flags/lines
        port/state/flags: port/state/flags or system/standard/port-flags/pass-thru

        port/sub-port: make port! join port/path port/target
        port/sub-port/state/flags: port/sub-port/state/flags or (port/state/flags and system/standard/port-flags/new)
        either #"/" = last port/target [
            open* port/sub-port
            port/state/inBuffer: copy* port/sub-port
        ][
            port/state/inBuffer: port/handler/read-sub-port port
        ]
        port/state/tail: length? port/state/inBuffer
        port
    ]

; ------------------
; FILE Close handler
; ------------------
    close: func [
        {Close sub-port} 
        port [port!] "An open port spec"
    ][
        net-utils/net-log reduce ["Closing port for" to-string port/scheme]
        if all [
            not #"/" = last port/target
            system/standard/port-flags/changed = (port/state/flags and system/standard/port-flags/changed)
        ][
            port/handler/write-sub-port port
            port/state/flags: port/state/flags and complement system/standard/port-flags/changed
        ]
        close* port/sub-port
        port
    ]

; -------------------
; FILE Update handler
; -------------------
    update: func [
        port [port!] "An open port spec"
    ][
        net-utils/net-log reduce ["Updating port for" to-string port/scheme] 
        if all [
            not #"/" = last port/target
            system/standard/port-flags/changed = (port/state/flags and system/standard/port-flags/changed)
        ][
            port/handler/write-sub-port port
            port/state/flags: port/state/flags and complement system/standard/port-flags/changed
        ]
        update* port/sub-port
        port
    ]

; -----------------
; FILE Pick handler
; -----------------
    pick: func [
        "Pick operation." 
        port [port!] "An open port spec"
        data "Index where to pick data"
        /local buffer
    ][
        net-utils/net-log ["Pick at " data "index"]
        if none? data [data: 1]
        buffer: at port/state/inBuffer index? port
        pick* buffer data
    ]

; -----------------
; FILE Copy handler
; -----------------
    copy: func [
        "Copy operation." 
        port [port!] "An open port spec"
        /local buffer
    ][
        net-utils/net-log ["Copy of" port/scheme]
        buffer: at port/state/inBuffer index? port
        copy*/part buffer port/state/num
    ]

; -------------------
; FILE Insert handler
; -------------------
    insert: func [
        port [port!]
        value
        /part
            range [number! series! port! pair!] 
        /only
        /dup
            count [number! pair!]
        /local buffer cmd parms
    ][
        net-utils/net-log ["Insert of " port/state/num "bytes"]
        cmd: to-path 'insert*
        parms: copy* []
        if all [value? 'part part][append cmd 'part repend parms [range]] 
        if dup [append cmd 'dup repend parms [dup]]
        either #"/" = last port/target [
            buffer: at port/sub-port index? port
            buffer: do compose [(cmd) buffer value (parms)]
        ][
            value: to-record value only
            buffer: at port/state/inBuffer index? port
            buffer: do compose [(cmd) buffer value (parms)]
            port/handler/insert-sub-port port value cmd parms
        ]
        port/state/tail: length? head buffer
        at port index? buffer
    ]

; -------------------
; FILE Change handler
; -------------------
    change: func [
        port [port!]
        value
        /part
            range [number! series! port! pair!] 
        /only
        /dup
            count [number! pair!]
        /local buffer cmd parms data
    ][
        net-utils/net-log ["Change of " port/state/num "bytes"]
        cmd: to-path 'change*
        parms: copy* []
        if part [append cmd 'part repend parms [range]] 
        if dup [append cmd 'dup repend parms [count]] 
        either #"/" = last port/target [
            buffer: at port/sub-port index? port
            buffer: do compose [(cmd) buffer value (parms)]
        ][
            value: to-record value only
            buffer: at port/state/inBuffer index? port
            buffer: do compose [(cmd) buffer value (parms)]
            port/handler/change-sub-port port value cmd parms
        ]
        port/state/tail: length? head buffer
        at port index? buffer
    ]

; -----------------
; FILE Sort handler
; -----------------
    sort: func [
        port [port!]
        /case "Case sensitive sort."
        /skip "Treat the series as records of fixed size."
            size [integer!] "Size of each record."
        /compare "Comparator offset, block or function."
            comparator [integer! block! function!]
        /part "Sort only part of a series."
            length [integer!] "Length of series to sort."
        /all "Compare all fields"
        /reverse "Reverse sort order"
        /local buffer cmd parms
    ][
        net-utils/net-log ["Sort in" port/scheme]

        cmd: to-path 'sort*
        parms: copy* []
        if skip [append cmd 'skip repend parms [size]] 
        if compare [append cmd 'compare repend parms [:comparator]] 
        if part [append cmd 'part repend parms [length]] 
        if all [append cmd 'all] 
        if reverse [append cmd 'reverse] 

        either #"/" = last port/target [
            buffer: at port/sub-port index? port
            buffer: do compose [(cmd) buffer value (parms)]
        ][
            buffer: at port/state/inBuffer index? port
            buffer: do compose [(cmd) buffer (parms)]
            port/handler/sort-sub-port port cmd parms
        ]
        port/state/tail: length? head buffer
        at port index? buffer
    ]

; -----------------
; FILE Poke handler
; -----------------
    poke: func [
        port [port!]
        index [number! logic! pair!]
        value
        /local buffer item
    ][
        net-utils/net-log ["Pick at " data "index"]
        either #"/" = last port/target [
            buffer: at port/sub-port index? port
            poke* buffer index value
        ][
            buffer: at port/state/inBuffer index? port
            buffer: poke* buffer index value
            port/handler/poke-sub-port port index value
        ]
        value
    ]

; -------------------
; FILE Remove handler
; -------------------
    remove: func [
        "Remove operation." 
        port [port!] "An open port spec"
        /local buffer cmd parms
    ][
        net-utils/net-log ["Remove of" port/scheme]
        either #"/" = last port/target [
            buffer: at port/sub-port index? port
            buffer: remove*/part buffer port/state/num
        ][
            buffer: at port/state/inBuffer index? port
            remove*/part buffer port/state/num
            remove-sub-port port
        ]
        port/state/tail: length? head buffer
        at port index? buffer
    ]

; ------------------
; FILE Query handler
; ------------------
    query: func [
        port [port!]
        /clear
        /local sub-port
    ][
        net-utils/net-log ["query of " port/scheme]
        sub-port: make port! rejoin [port/path port/target]
        query* sub-port
        port/status: sub-port/status
        port/date: sub-port/date
        port/size: sub-port/size
        none
    ]

; ---------------------------
; FILE get-modes handler
; ---------------------------
    get-modes: func [
        port [port!] "An open port spec"
        modes "A mode block"
    ][
        get-modes* port
    ]

; ----------------------
; FILE set-modes handler
; ----------------------
    set-modes: func [
        port [port!] "An open port spec"
        modes "A mode block"
    ][
        set-modes* port
    ]

; ----------------------------
; FILE file-extension function
; ----------------------------
    file-extension: func [
        port [port!]
    ][
        %.dat
    ]

; ----------------------------
; FILE file-schema function
; ----------------------------
    file-schema: context [
        format: none
        cols: []
    ]

; --------------------
; FILE insert-sub-port
; --------------------
    insert-sub-port: func [
        port [port!]
        value
        cmd [path!]
        parms [block!]
        /local buffer result data
    ][
        result: data: make block! length? value
        foreach item value [
            data: insert* data port/handler/to-sub-record port item
        ]
        buffer: at port/sub-port index? port
        buffer: do compose [(cmd) buffer result (parms)]
    ]

; --------------------
; FILE change-sub-port
; --------------------
    change-sub-port: func [
        port [port!]
        value
        cmd [path!]
        parms [block!]
        /local buffer result data
    ][
        result: data: make block! length? value
        foreach item value [
            data: insert* data port/handler/to-sub-record port item
        ]
        buffer: at port/sub-port index? port
        buffer: do compose [(cmd) buffer result (parms)]
    ]

; ------------------
; FILE sort-sub-port
; ------------------
    sort-sub-port: func [
        port [port!]
        cmd [path!]
        parms [block!]
        /local buffer
    ][
        close* port/sub-port
        buffer: open*/new/lines port/sub-port
        foreach item port/state/inBuffer [
        buffer: insert* buffer port/handler/to-sub-record port item
        ]
        port/sub-port
    ]

; ------------------
; FILE poke-sub-port
; ------------------
    poke-sub-port: func [
        port [port!]
        index [number! logic! pair!]
        value
    ][
        buffer: at port/sub-port index? port
        buffer: poke* buffer index port/handler/to-sub-record port value
    ]

; --------------------
; FILE remove-sub-port
; --------------------
    remove-sub-port: func [
        port [port!]
    ][
        buffer: at port/sub-port index? port
        buffer: remove*/part buffer port/state/num
    ]

; --------------------------
; FILE Register the protocol
; --------------------------
; -->       net-utils/net-install FILE self none
]

; *******************************************************************
; DELIMITED Protocol Handler
; *******************************************************************

make file-handler [

; ---------------------------------
; DELIMITED file-extension function
; ---------------------------------
    file-extension: func [
        port [port!]
    ][
        switch port/locals/format [
            Delimited %.txt
            CSVDelimited %.csv
            TABDelimited %.tab
        ]
        ""
    ]

; ---------------------------------
; DELIMITED file-delimiter function
; ---------------------------------
    file-delimiter: func [
        {Default file delimiter}
        port [port!]
    ][
        switch/default port/locals/format [
            Delimited [";"]
            CSVDelimited [","]
            TABDelimited ["^-"]
        ][
            ";,^-"
        ]
    ]

; -----------------------------
; DELIMITED file-schema
; -----------------------------
    file-schema: context [
        ColNameHeader: false
        format: 'Delimited
        delimiter: none
        max-scan-rows: 0
        character-set: 'OEM
        cols: none
    ]

; -----------------------
; DELIMITED Read sub-port
; -----------------------
    read-sub-port: func [
        port "Initalized port spec" 
        /local result line d m y v s e
            end-of-line
            quote-char
            double-quote
            end-of-line-set
            digit-set
            delimited-header-line
            delimited-text-line
            delimited-data
            delimited-string
            unquoted-string
            quoted-string
            number
            exact-number
            approximate-number
            unsigned-integer
            date
            mm dd yy yyyy mmm
            date-separator
            delimited-null
            current-delimiter
            delimiter-set
            character-set
    ][
        net-utils/net-log reduce ["Reading sub-port for" to-string port/scheme] 
; Basic char
; ----------
        quote-char: {"}
        digit-char: "0123456789"
        end-of-line-char: "^/^M"

; Basic character set
; -------------------
        end-of-line: [ "^/^M" | "^M" | "^/" ]
        double-quote: rejoin [quote-char quote-char]
        end-of-line-set: charset end-of-line-char
        digit-set: charset digit-char

; Manage delimiter
; ----------------
        current-delimiter: any [
            port/locals/delimiter
            port/handler/file-delimiter port
            ",;^-"
        ]
        delimiter-set: charset current-delimiter
        character-set: complement charset rejoin [current-delimiter quote-char end-of-line-char]
        delimiter: [
            copy d delimiter-set (
                if none? port/locals/delimiter [
                    delimiter-set: charset port/locals/delimiter: d
                    character-set: complement charset rejoin [current-delimiter quote-char end-of-line-char]
                ]
            )
        ]

; Manage file
; -----------
        text-file: either port/locals/ColNameHeader [
            [delimited-header-line any delimited-text-line]
        ][
            [any delimited-text-line]
        ]

; Manage line
; -----------
        delimited-header-line: [delimited-text-line (
            if none? port/locals/cols [
                port/locals/cols: copy* []
                foreach item first result [
                    repend port/locals/cols [to-word item copy* []]
                ]
            ]
            clear result
        )]

        delimited-text-line: [
            end-of-line 
        |
            (line: copy* [])
            delimited-data
            any [delimiter delimited-data]
            end-of-line
            (insert*/only tail result line)
        ]

; Manage data
; -----------
        delimited-data: [[
            date s: [delimiter | end-of-line] :s
        |
            number s: [delimiter | end-of-line] :s
        |
            delimited-string s: [delimiter | end-of-line] :s
        |
            delimited-null s: [delimiter | end-of-line] :s
        ] (append line v)]

; Manage date
; -----------
        date: [[
            copy d dd date-separator copy m [mm | mmm] date-separator copy y [yyyy | yy]
        |
            copy m mmm date-separator copy d dd date-separator copy y [yyyy | yy]
        |
            copy y yyyy date-separator copy m [mm | mmm] date-separator copy d dd
        ] (v: to-date rejoin [d "-" m "-" y])]
        mm: [digit-set [digit-set | none]]
        dd: [digit-set [digit-set | none]]
        yy: [digit-set digit-set]
        yyyy: [digit-set digit-set digit-set digit-set]
        mmm: ["Jan" | "Feb" | "Mar" | "Apr" | "May" | "Jun" | "Jul" | "Aug" | "Sep" | "Oct" | "Nov" | "Dec"]
        date-separator: [ "-" | "/" | "."]

; Manage number
; -------------
        number: [approximate-number | exact-number]
        approximate-number: [copy v [
            ["+" | "-" | none] [
                unsigned-integer ["." unsigned-integer | none]
            |
                "." unsigned-integer
            ]["e" | "E"] ["+" | "-"] unsigned-integer
        ] (v: to-decimal v) ]
        exact-number: [s:
            ["+" | "-" | none]
            [
                unsigned-integer "." [unsigned-integer | none] e: (v: to-decimal copy*/part s e)
            |
                "." unsigned-integer e: (v: to-decimal copy*/part s e)
            |
                 unsigned-integer e: (v: to-integer copy*/part s e)
            ]
        ]

        unsigned-integer: [some digit-set]

; Manage string
; -------------
        delimited-string: [unquoted-string | quoted-string]

        unquoted-string: [
            s: character-set
            any [character-set | quote-char]
            e: (v: to-string copy*/part s e)
        ]

        quoted-string: [
            quote-char s:
            any [character-set | delimiter-set | end-of-line-set | double-quote]
            e: quote-char
            (v: to-string copy*/part s e)
        ]

; Manage null value
; -----------------
        delimited-null: [s: delimiter :s (v: none)] ; NULL is represented by no data between two delimiters.

        either system/standard/port-flags/new =(port/state/flags and system/standard/port-flags/new) [
;            port/state/flags: port/state/flags or system/standard/port-flags/changed
        port/state/inBuffer: copy* []
            write-sub-port port
            port/state/inBuffer
        ][
            open* port/sub-port
            result: make block! 0
            either parse/all copy* port/sub-port text-file [
                port/state/inBuffer: result
            ][
            make error! "Invalid CSV file"
            ]
        ]
    ]

; ----------------------
; DELIMITED Write record
; ----------------------
    write-sub-port: func [
        {Write the file.} 
        port "Initalized port spec" 
        /local line sep
    ][
        net-utils/net-log reduce ["Writing records" to-string port/scheme] 
        if none? port/locals/delimiter [
            port/locals/delimiter: port/handler/file-delimiter port
        ]
;       clear head port/sub-port
        attempt [close* port/sub-port]
        open*/new port/sub-port
        if port/locals/ColNameHeader [
            line: clear []
            sep: ""
            foreach item port/locals/cols [
                if block? item [
                    item: first item
                ]
                item: to-string item
                append line sep
                append line item
                sep: port/locals/delimiter
            ]
            append port/sub-port line
            append port/sub-port newline
        ]
        foreach item head port/state/inBuffer [
            line: clear []
            sep: ""
            foreach jtem item [
                if none? find [integer! decimal! date! time!] type? jtem [
                    jtem: to-string jtem
                    jtem: replace/all to-string jtem {"} {""}
                    if any [
                        find* jtem {"}
                        find* jtem port/locals/delimiter
                        find* jtem {^/}
                        find* jtem {^M}
                    ][
                        jtem: rejoin [{"} jtem {"}]
                    ]
                ]
                append line sep
                append line jtem
                sep: port/locals/delimiter
            ]
            append port/sub-port line
            append port/sub-port newline
        ]
    ]

; -------------------------
; DELIMITED insert-sub-port
; -------------------------
    insert-sub-port: func [
        port [port!]
        value
        cmd [path!]
        parms [block!]
        /local
    ][
        port/state/flags: port/state/flags or system/standard/port-flags/changed
    ]

; -------------------------
; DELIMITED change-sub-port
; -------------------------
    change-sub-port: func [
        port [port!]
        value
        cmd [path!]
        parms [block!]
        /local
    ][
        port/state/flags: port/state/flags or system/standard/port-flags/changed
    ]

; -------------------------
; DELIMITED sort-sub-port
; -------------------------
    sort-sub-port: func [
        port [port!]
        cmd [path!]
        parms [block!]
        /local
    ][
        port/state/flags: port/state/flags or system/standard/port-flags/changed
    ]

; -----------------------
; DELIMITED poke-sub-port
; -----------------------
    poke-sub-port: func [
        port [port!]
        index [number! logic! pair!]
        value
        /local
    ][
        port/state/flags: port/state/flags or system/standard/port-flags/changed
    ]

; -------------------------
; DELIMITED remove-sub-port
; -------------------------
    remove-sub-port: func [
        port [port!]
    ][
        port/state/flags: port/state/flags or system/standard/port-flags/changed
    ]

; -------------------------------
; DELIMITED Register the protocol
; -------------------------------
    net-utils/net-install CSV self none
]

; *******************************************************************
; DATA Protocol Handler
; *******************************************************************

    make file-handler [

; ----------------------------
; DATA file-extension function
; ----------------------------
    file-extension: func [
        port [port!]
    ][
        %.data
    ]

; -----------------------
; DATA Read sub-port
; -----------------------
    read-sub-port: func [
        port
        /local result data sub-port
    ][
        sub-port: open*/lines port/sub-port
        port/state/inBuffer: data: make block! length? sub-port
        while [not tail? sub-port][
            data: insert*/only data load first sub-port
            sub-port: next sub-port
        ]
        port/state/inBuffer
    ]

; -----------------
; DATA Write record
; -----------------
    write-sub-port: func [
        {Write the file.} 
        port "Initalized port spec" 
    ][
        none
    ]

; ---------------------------
; DATA to-sub-record function
; ---------------------------

    to-sub-record: func [
        port [port!]
        value
    ][
        mold value
    ]

; --------------------------
; DATA Register the protocol
; --------------------------
    net-utils/net-install DATA self none
]

; *******************************************************************
; HEAP Protocol Handler
; *******************************************************************

context [

    root-heap: make block! 0

; -----------------
; HEAP Init handler
; -----------------

    init: func [
        "Parse URL and/or check the port spec object" 
        port "Unopened port spec" 
        spec {Argument passed to open or make (a URL or port-spec)} 
        /local scheme file path target locals
    ][
        net-utils/net-log reduce ["Initializing" to-string spec "for" to-string port/scheme] 
        either url? spec [
            set [scheme file] parse/all spec ":"
            set [path target] split-path file: to-file file
            if none? target [target: %./]
            if not any [
                #"/" = last target
                find target #"."
            ][=
                target: join target %.heap
            ]
            port/path: clean-path to-rebol-file path
            port/target: target
            port/url: spec 
        ][
            spec: context spec
            target: to-file spec/target
            if any [
                none? path: in spec 'path
                none? path: get path
            ][
                either #"/" = first target [
                    path: %/.
                ][
                    path: %.
                ]
            ]
            path: dirize to-file path
            set [path target] split-path file: join path target
            if none? target [target: %./]
            if not any [
                #"/" = last target
                find target #"."
            ][
                target: join target %.heap
            ]
            port/path: clean-path path
            port/target: target
        ]
        if none? port/target [
            net-error reform ["No target file for" port/scheme "is specified"]
        ] 
    ]

; -----------------
; HEAP Open handler
; -----------------

    open: func [
        {Open sub-port.} 
        port "Initalized port spec"
        /local item file path new-flag
    ][
        net-utils/net-log reduce ["Opening port for" to-string port/scheme]
        port/status: 'file
        port/state/flags: port/state/flags or system/standard/port-flags/lines
        port/state/flags: port/state/flags or system/standard/port-flags/pass-thru
        file: rejoin [port/path port/target]
        new-flag: system/standard/port-flags/new = (system/standard/port-flags/new and port/state/flags)
        either none? port/state/inBuffer: select-heap file root-heap [
            either all [
                #"/" = last port/target
                not new-flag
            ][
                throw-error [type: 'access id: 'cannot-open arg1: file]
            ][
                port/state/inBuffer: insert-heap file root-heap 
            ]
        ][
            if new-flag [
                either #"/" = last port/target [
                    throw-error [type: 'access id: 'cannot-open arg1: file]
                ][
                    clear port/state/inBuffer
                ]
            ]
        ]
        if #"/" = last port/target [
            port/state/inBuffer: extract port/locals: port/state/inBuffer 2
        ]
        port/state/tail: length? port/state/inBuffer
        port
    ]

; ------------------
; HEAP Close handler
; ------------------

    close: func [
        {Close sub-port} 
        port [port!] "An open port spec"
    ][
        net-utils/net-log reduce ["Closing port for" to-string port/scheme]
        port
    ]

; -------------------
; HEAP Update handler
; -------------------

    update: func [
        {Update sub-port} 
        port [port!] "An open port spec"
    ][
        net-utils/net-log reduce ["Updating port for" to-string port/scheme] 
        port
    ]

; -----------------
; HEAP Pick handler
; -----------------

    pick: func [
        "Pick operation." 
        port [port!] "An open port spec"
        data "Index where to pick data"
        /local buffer
    ][
        net-utils/net-log ["Pick at " data "index"]
        if none? data [data: 1]
        buffer: at port/state/inBuffer index? port
        pick* buffer data
    ]

; -----------------
; HEAP Copy handler
; -----------------

    copy: func [
        "Copy operation." 
        port [port!] "An open port spec"
        /local buffer
    ][
        net-utils/net-log ["Copy of" port/scheme]
        buffer: at port/state/inBuffer index? port
        copy*/part buffer port/state/num
    ]

; -------------------
; HEAP Insert handler
; -------------------

    insert: func [
        port [port!]
        value
        /part
            range [number! series! port! pair!] 
        /only
        /dup
            count [number! pair!]
        /local buffer cmd parms
    ][
        net-utils/net-log ["Insert of " port/state/num "bytes"]
        cmd: to-path 'insert*
        parms: copy* []
        if all [value? 'part part][append cmd 'part repend parms [range]] 
        if dup [append cmd 'dup repend parms [dup]]
        either #"/" = last port/target [
            throw-error [type: 'script id: 'bad-port-action arg1: 'insert]
        ][
            buffer: at port/state/inBuffer index? port
            buffer: do compose [(cmd) buffer to-record value only (parms)]
        ]
        port/state/tail: length? head buffer
        at port index? buffer
    ]

; -------------------
; HEAP Change handler
; -------------------

    change: func [
        port [port!]
        value
        /part
            range [number! series! port! pair!] 
        /only
        /dup
            count [number! pair!]
        /local buffer cmd parms data
    ][
        net-utils/net-log ["Change of " port/state/num "bytes"]
        cmd: to-path 'change*
        parms: copy* []
        if part [append cmd 'part repend parms [range]] 
        if dup [append cmd 'dup repend parms [count]] 
        either #"/" = last port/target [
            buffer: at port/locals (2 * index? port) - 1
            change* buffer value
            buffer: at port/state/inBuffer index? port
            buffer: change* buffer value
        ][
            buffer: at port/state/inBuffer index? port
            buffer: do compose [(cmd) buffer to-record value only (parms)]
        ]
        port/state/tail: length? head buffer
        at port index? buffer
    ]

; -----------------
; HEAP Poke handler
; -----------------

    poke: func [
        port [port!]
        index [number! logic! pair!]
        value
        /local buffer item
    ][
        net-utils/net-log ["Pick at " data "index"]
        either #"/" = last port/target [
            buffer: at port/locals (2 * index? port) - 1
            poke* buffer (2 * index) - 1 value
            buffer: at port/state/inBuffer index? port
            poke* buffer index value
        ][
            buffer: at port/state/inBuffer index? port
            poke* buffer index value
        ]
        value
    ]

; -------------------
; HEAP Remove handler
; -------------------

    remove: func [
        "Remove operation." 
        port [port!] "An open port spec"
        /local buffer cmd parms
    ][
        net-utils/net-log ["Remove of" port/scheme]
        either #"/" = last port/target [
            buffer: at port/locals (2 * index? port) - 1
            buffer: remove*/part buffer 2 * port/state/num
            buffer: at port/state/inBuffer index? port
            buffer: remove*/part buffer port/state/num
        ][
            buffer: at port/state/inBuffer index? port
            buffer: remove*/part buffer port/state/num
        ]
        port/state/tail: length? head buffer
        at port index? buffer
    ]

; ------------------
; HEAP Query handler
; ------------------

    query: func [
        port [port!]
        /clear
    ][
        net-utils/net-log ["query at " data "index"]
        if select-heap rejoin [port/path port/target] root-heap [
            either #"/" = last port/target [
                port/status: 'directory
            ][
                port/status: 'file
            ]
        ]
        none
    ]

; ----------------------
; HEAP get-modes handler
; ----------------------
    get-modes: func [
        port [port!] "An open port spec"
        modes "A mode block"
    ][
        get-modes* port
    ]

; ----------------------
; HEAP set-modes handler
; ----------------------
    set-modes: func [
        port [port!] "An open port spec"
        modes "A mode block"
    ][
        set-modes* port
    ]

; ===================================================================
; HEAP protocol utilities
; ===================================================================

    split-full-path: func [
        file [file!]
        /local path target result block
    ][
        file: clean-path file
        block: result: parse/all file "/"
        forall block [
            change* block to-file rejoin [first block "/"]
        ]
        if #"/" <> last file [
            remove* back tail last result
        ]
        next result
    ]

    select-heap: func [
        file [file!]
        heap [block!]
        /local item
    ][
        file: split-full-path file
        while [all [
            not tail? file
            heap: select* heap first file
        ]][
            file: next file
        ]
        heap
    ]

    find-heap: func [
        file [file!]
        heap [block!]
    ][
        file: split-full-path file
        item: heap
        while [all [
            not tail? file
            heap: find*/skip item first file 2
        ]][
            file: next file
            item: second heap
        ]
        heap
    ]

    insert-heap: func [
        file [file!]
        heap [block!]
        /locals item
    ][
        file: split-full-path file
        while [not tail? file][
            if none? item: select* heap first file [
                insert* tail heap reduce [first file item: make block! 0]
            ]
            heap: item
            file: next file
        ]
        item
    ]

; --------------------------
; HEAP Register the protocol
; --------------------------
    net-utils/net-install HEAP self none

]

; *******************************************************************
; SQL protocol context
; *******************************************************************
; This object contains 4 things:
; - the SQL engine (various functions)
; - the SQL protocol
; - the DATA protocol
; - some utilities

sql-ctx: context [

; *******************************************************************
;                          SQL parsing
; *******************************************************************
    result: cols: where: values: value: item: item-1: item-2: sql-err: sql-exp: none
; Parse function
    sql-parse-request: func [
        "Return an SQL Rebol dialect block from SQL request string"
        request [string!] "The request string"
    ][
    	sql-exp: request
        result: copy []
        cols: copy []
        values: copy []
        value: copy []
        sql-err: 'SQL
        either not parse/all request [
        	any space-set [
        		sqlc-select
        	|
	        	sqlc-insert
    	    |
        		sqlc-update
        	|
        		sqlc-delete
    		]
        ][
            return throw-error [type: 'sql id: 'syntax arg1: sql-err arg2: sql-exp]
        ][
            result
        ]
    ]

; Basic charset
    end-of-line: [ "^/^M" | "^/" ]
    end-of-line-set: charset "^/^M"
    space-set: charset " ^-^/^M"
    any-space: [any space-set]
    some-space: [some space-set]
    num-set: charset "1234567890"
    alpha-set: charset "abcdefghijklmnopqrstuvwxyz"
    name-set: union num-set alpha-set
    str-set: complement charset "'"

; Basic type
    sqlc-integer: [some num-set]
    sqlc-decimal: [some num-set opt ["." some num-set]]
    sqlc-number: [copy item sqlc-integer (item: to integer! item)| sqlc-decimal (item: to integer! item)]
    sqlc-string: [any str-set]
    sqlc-name: [alpha-set any name-set]
    sqlc-full-name: [sqlc-name "." sqlc-name | sqlc-name]

; -------------------------------------------------------
; SELECT clause
; -------------------------------------------------------
    sqlc-select: [
        any space-set "SELECT" some space-set (append result [SELECT])
        opt ["DISTINCT" some space-set (append result [DISTINCT])]
        [
            "FROM" some space-set
        |
            sqlc-column any [any space-set "," any space-set sqlc-column] some space-set "FROM" some space-set
        ] (append result [FROM])
        sqlc-table any [any space-set "," any space-set sqlc-table]
        opt [
            some space-set "WHERE" some space-set (
                append result [WHERE]
                insert*/only where: copy [] result
            ) sqlc-where
        ]
        opt [
            some space-set "GROUP" some space-set "BY" (append result [GROUP BY])
            some space-set sqlc-group any [any space-set "," any space-set sqlc-group]
        ]
        opt [
            some space-set "ORDER" some space-set "BY" (append result [ORDER BY])
            some space-set sqlc-order any [any space-set "," any space-set sqlc-order]
        ]
        any space-set
    ]

; Column clause
    sqlc-column: [
        sqlc-count
    |
        "*" (append result '*)
    |
        copy item [sqlc-name ".*"] (append result to word! item)
    |
        (insert/only where: copy [] to paren! copy []) sqlc-value (append result first where)
    ]

; COUNT clause
    sqlc-count: [
        "COUNT" any space-set "(" any space-set ["UNIQUE" some space-set | none]
        sqlc-count-col any [any space-set "," any space-set sqlc-count-col] 
        any space-set ")"                   
    ]

; Count column clause
    sqlc-count-col: ["*" | sqlc-full-name]

; From table clause
    sqlc-table: [
        copy item-1 sqlc-name [
            some space-set opt ["AS" some space-set] copy item-2 sqlc-name (
                insert*/only tail result compose [(to word! item-1) AS (to word! item-2)]
            )
        |
            none (append result to word! item-1)
        ]
    ]

; WHERE clause
    sqlc-where: [
        sqlc-where-condition
        any [
            any space-set copy item ["AND" | "OR"] some space-set (append first where to word! uppercase item)
            sqlc-where-condition
        ]
    ]

; Test clause
    sqlc-where-condition: [
        "(" any space-set (
            insert/only where to paren! copy []
        ) sqlc-where any space-set ")" (
            insert*/only tail second where first where
            remove where
        )
    |
        sqlc-value any space-set [
            "LIKE" (append first where 'LIKE) some space-set [
                "'" copy item sqlc-string "'" (
                    item: copy item
                    replace/all item #"%" #"*"
                    replace/all item #"_" #"?"
                    append first where item
                )
            |
                sqlc-value
            ]
        |
            copy item ["<>" | "<=" | ">=" | "=" | "<" | ">"] (append first where to word! item) 
            any space-set sqlc-value
        ]
    ]

; GROUP BY clause
    sqlc-group: [
            copy item sqlc-integer (append result to integer! item)
        |
            copy item sqlc-full-name (append result to word! item)
    ]

; ORDER BY clause
    sqlc-order: [
        [
            copy item sqlc-integer (item-1: to integer! item)
        |
            copy item sqlc-full-name (item-1: to word! item)
        ][
            some space-set copy item-2 ["ASC" | "DESC"]  (insert*/only tail result compose [(item-1) (to word! uppercase item-2)])
        |
            none (insert*/only tail result item-1)
        ]
    ]

; Value clause
    sqlc-value: [
        [
            "(" any space-set (
                insert/only where to paren! copy []
            ) sqlc-value any space-set ")" (
                insert*/only tail second where first where
                remove where
            )
        |
            "'" copy item sqlc-string "'" (append first where item)
        |
            copy item sqlc-full-name (append first where to word! item)
        |
            sqlc-number (append first where item)
        ]
        opt [
            any space-set copy item ["+" | "-" | "*" | "/"] (append first where to word! item)
            any space-set sqlc-value
        ]
    ]

; -------------------------------------------------------
; INSERT clause
; -------------------------------------------------------
    sqlc-insert: [
        any space-set sql-exp: "INSERT" opt [ some space-set "INTO"] (append result [INSERT INTO])
        some space-set sql-exp: sqlc-table
        opt [
        	any space-set "(" sql-exp: copy item sqlc-name (append cols to word! item) any [
        		any space-set "," any space-set sql-exp: copy item sqlc-name (append cols to word! item)
        	]
        	any space-set ")" (insert*/only tail result cols)
        ]
        [
        	any space-set "VALUES" (append result [VALUES]) sqlc-insert-values any [
        		any space-set "," any space-set sqlc-insert-values
        	]
        |
        	any space-set sqlc-select
    	]
	]
; INSERT values
    sqlc-insert-values: [
        any space-set "(" (
			insert*/only tail result copy []
        	insert/only where: copy [] last result
        ) sql-exp: sqlc-value
        any [
        	any space-set "," any space-set sql-exp: sqlc-value 
        ] ")"
    ]

; -------------------------------------------------------
; UPDATE clause
; -------------------------------------------------------
    sqlc-update: [
        any space-set sql-exp: "UPDATE" (append result [UPDATE])
        some space-set sql-exp: sqlc-table
        some space-set sql-exp: "SET" (append result [SET]) some space-set sql-exp: sqlc-set
        any [
        	any space-set "," any space-set sql-exp: sqlc-set
        ]
        opt [
            some space-set "WHERE" some space-set (
                append result [WHERE]
                insert*/only where: copy [] result
            ) sqlc-where
        ]
	]
    sqlc-set: [
    	copy item sqlc-name any space-set "=" (
			insert* tail result to set-word! item
        	insert*/only where: copy [] result
        ) sql-exp: sqlc-value
	]

; -------------------------------------------------------
; DELETE clause
; -------------------------------------------------------
    sqlc-delete: [
        any space-set sql-exp: "DELETE" some space-set "FROM"(append result [DELETE FROM])
        some space-set sql-exp: sqlc-table
        opt [
            some space-set "WHERE" some space-set (
                append result [WHERE]
                insert*/only where: copy [] result
            ) sqlc-where
        ]
	]

; *******************************************************************
;                          SQL Engine
; *******************************************************************

; ===================================================================
; sql-query function
; ===================================================================

    sql-query: func [
            "Execute sql like request on a database"
        query [string! block!]
        port [port!]
        /local word distinct cols col from where order-by table values value if-not-exist scheme spec
    ][
        if string? query [sql-exp: query: sql-parse-request query]
        distinct: if-not-exist: false
        cols: copy* []
        where: copy* []
        order-by: copy* []
        values: copy* []
        scheme: 'data
        spec: copy* []
        sql-exp: query
        sql-err: 'SQD
        either parse query [
            sql-exp: 'SELECT (word: 'SELECT)
            ['DISTINCT (distinct: true) | none]
            copy cols to 'FROM
            'FROM copy from [to 'WHERE | to 'ORDER | to end]
            [
                'WHERE copy where [to 'ORDER | to end]
            |
                none
            ]
            [
                'ORDER 'BY copy order-by to end
            |
                none
            ]
            end
        |
            sql-exp: 'INSERT (word: 'INSERT)
            opt 'INTO set table word!
            opt [set cols block!]
            'VALUES copy values to end
        |
            sql-exp: 'UPDATE (word: 'UPDATE)
            set table word!
            'SET copy values [to 'WHERE | to end] 
            [
                'WHERE copy where to end
            |
                none
            ]
        |
            sql-exp: 'DELETE (word: 'DELETE)
            'FROM set table word!
            [
                'WHERE copy where to end
            |
                none
            ]
        |
            sql-exp: ['CREATE 'TABLE] (word: 'CREATE-TABLE)
            set table word!
            set cols block!
            ['IF 'NOT 'EXISTS (if-not-exist: true) | none]
            [
                'TYPE '= [
                    set scheme word!
                |
                    set spec block! (
                        scheme: first spec
                        spec: copy next spec
                    )
                ]
            |
                none
            ]
        |
            sql-exp: ['DROP 'TABLE] (word: 'DROP-TABLE)
            set table word!
        ][
            switch/default word [
                SELECT [
                    sql-select distinct cols from where order-by port
                ]
                INSERT [
                    sql-insert table cols values port
                ]
                UPDATE [
                    sql-update table values where port
                ]
                DELETE [
                    sql-delete table where port
                ]
                CREATE-TABLE [
                    sql-create-table table cols if-not-exist scheme spec port
                ]
                DROP-TABLE [
                    sql-drop-table table port
                ]
            ][
	            return throw-error [type: 'sql id: 'syntax arg1: sql-err arg2: sql-exp]
            ]
        ][
            return throw-error [type: 'sql id: 'syntax arg1: sql-err arg2: sql-exp]
        ]
    ]

; ===================================================================
; SQL-SELECT function
; ===================================================================
; This function return the rows corresponding to the cols, from, where and order-by clause

; It does 4 things :
; - normalize the cols clause (replace the * and table.* element by corresponding cols)
; - normalize the where clause (add parenthesis when necessary and translate the LIKE clause)
; - generate dynamicaly the code that
;   - extract the data from the database
;   - join the tables (if many)
;   - execute the where condition
;   - obtain the columns
; - apply the distinct flag if any
; - sort the result
; - return the result

; The result is a block of block (one for each resulting row)
; If the where block is empty, the function return all the row
; The join is done even if the where clause is empty (this is not true in SQL)

; Return a block of block (one for each resulting row)

    sql-select: func [
        distinct [logic!]
        cols [block!]
        from [block!]
        where [block!]
        order-by [block!]
        port [port!]
        /local result spec body rows index way
    ][

; Normalize the cols, from and where clause
; -----------------------------------
        from: to-rebol-from from
        cols: either empty? cols [
            [*] 
        ][
            to-rebol-cols cols from port
        ]
        where: either empty? where [
            [true]
        ][
            to-rebol-where where
        ]
        order-by: to-rebol-path order-by

; Extract the data, applies joins, where and cols clause
; ------------------------------------------------------
        result: rows: copy* []
        set [spec body] make-do-select cols from where port
        bind body 'result
        use spec body

; Applies the distinct clause
; ---------------------------
        if distinct [result: unique result]

; Applies the order by clause
; ---------------------------
        if not empty? order-by [
            foreach item head reverse copy order-by [
                set [index way] either block? item [
                    item
                ][
                    reduce [item 'asc]
                ]
                if not integer? index [
                    index: index? find cols reduce [index]
                ]
                either way = 'desc [ 
                    sort/compare/reverse result index
                ][  
                    sort/compare result index
                ]
            ]
        ]

; return the result
; -----------------
        result
    ]

; -------------
; to-rebol-from
; -------------
; This function normalize the from clause in order to be compatible with Rebol, can be
; FROM table table ...
; FROM table AS alias ... !!! To remove -> not good
; FROM [table alias] ...
; FROM [table AS alias] ...
; or combination of above

    to-rebol-from: func [
        from [block!]
        /local table item1 item2
    ][
        table: copy* []
        parse from [any [
            into [
                copy item1 word! opt 'AS copy item2 word! (
                    append table reduce [first item2 first item1]
                )
            ]
        |
            copy item1 word! 'AS copy item2 word! (
                append table reduce [first item2 first item1]
            )
        |
            copy item1 word! (
            append table reduce [first item1 first item1]
            )
        ]]
        table
    ]

; -------------
; to-rebol-cols
; -------------
; This function normalize the cols clause in order to be compatible with Rebol

; It replace * and alias.* by the corresponding columns
; Return a normalized cols clause (block of column or alias/column)

    to-rebol-cols: func [
        cols [block!]
        from [block!]
        port [port!]
        /local result rule p item1 item2
    ][
        cols: to-rebol-path cols
        result: copy* []
        foreach item cols [
            set [item1 item2] to-block item
            either item1 = '* [
                foreach [item1 item2] from [
                    foreach item get-cols item2 port [
                        item: first to-block item
                        insert*/only tail result to-path reduce [item1 item]
                    ]
                ]
            ][
                either item2 = '* [
                    item2: first select/skip from item1 2
                    foreach item get-cols item2 port [
                        item: first to-block item
                        insert*/only tail result to-path reduce [item1 item]
                    ]
                ][
                    insert*/only tail result item
                ]
            ]
        ]
        result
    ]

; --------------
; to-rebol-where
; --------------
; This function normalize the where clause in order to be compatible with Rebol
; - Column names are normalized
; - Clause before or after AND or OR are placed between parenthesis
;   AND is applied before OR
;   sample : a = 1 and b = 2 or a = 2 ==>> ((a = 1) and (b = 2)) or (a = 2)
; - <expression> LIKE <criteria> is changed to
;     tail? any [find/any/match <expression <criteria> "*"]
; Return the normalized where clause

    to-rebol-where: func [
        where [block!]
        /local result item item-1 item-2
    ][
        result: copy* []
        where: to-rebol-path where
        parse where [
            any [
                end
                break
            |
                'OR copy item [to 'OR | to end] (
                    append result 'OR
                    if parse item [paren!] [item: to-block first item]
                    insert*/only tail result to-paren to-rebol-where item
                )
            |
                copy item to 'OR (
                    if parse item [paren!] [item: to-block first item]
                    insert*/only tail result to-paren to-rebol-where item
                )
            |
                'AND copy item [to 'AND | to end] (
                    append result 'AND
                    if parse item [paren!] [item: to-block first item]
                    append result to-rebol-where item
                )
            |
                copy item to 'AND (
                    if parse item [paren!] [item: to-block first item]
                    append result to-rebol-where item
                )
            |
                copy item to end (
                    if parse item [paren!] [item: to-rebol-where to block! first item]
                    parse item [
;                        'LIKE copy item-2 to end (
;                                item: compose/deep [tail? any [find/any/match (item-2) "*"]]
;                            )
;                    |
                        copy item-1 to 'LIKE 'LIKE copy item-2 to end (
                                item: compose/deep [tail? any [find/any/match (item-1) (item-2) "*"]]
                            )
                    |
                        to end
                    ]
                    insert*/only tail result to-paren item
                )
            ]
        ]
        result
    ]

; --------------
; to-rebol-path
; --------------
; This function normalize the block or paren to remove the dot notation
; Return a normalized block

    to-rebol-path: func [
        block [block! paren!]
        /local result p
    ][
        result: copy* []
        parse block rule: [any [
            set p word! (
                if find to string! p "." [
                    p: parse/all to-string p "."
                    forall p [change p to-word first p]
                    p: to path! head p
                ]
                insert*/only tail result p
            )
        |
            set p [block! | paren!] (
                insert*/only tail result to-rebol-path p
            )
        |
            set p any-type! (
                insert*/only tail result p
            )
        ]]
        either block? block [
            result
        ][
            to-paren result
        ]
    ]

; ---------------------
; make-do-select
; ---------------------
; This function build dynamicaly a the used spec and body to process the data

; Return the body and the spec

    make-do-select: func [
        cols [block!]
        from [block!]
        where [block!]
        port [port!]
        /local body words set-words £item1 spec
    ][
        spec: copy* [cols]
        body: copy* []
        foreach [item1 item2] from [
            append spec reduce [item1 £item1: to-word rejoin ['£ item1]]
            words: copy* []
            set-words: copy* []
            foreach item get-cols item2 port [
                item: first to-block item
                append words item
                append set-words to-set-word item
            ]
            insert body compose/deep [
                (to-set-word item1) context [(set-words) none]
                (to-set-word £item1) bind [(words)] in (item1) 'self
                bind cols in (item1) 'self
                bind where in (item1) 'self
            ]
        ]
        insert body compose/deep [
            cols: [(cols)]
        ]
        append body make-do-loop cols from where port 1
        reduce [spec body]
    ]

; -------------------
; make-do-loop
; -------------------
; This function build dynamicaly a the spec and body that applies the where clause.

; Return the body of the function

    make-do-loop: func [
        cols [block!]
        from [block!]
        where [block!]
        port [port!]
        index [integer!]
        /local item item1 item2 code
    ][
        either tail? from [
            compose/deep [
                if (where) [
                    rows: insert*/only rows reduce cols
                ]
            ]
        ][
            set [item1 item2] from
            item: to-word join '£ index
            compose/deep [
                use [(item)][
                    (to-set-word item) get-data (to-lit-word item2) port
                    while [not tail? (item)][
                        set (to-word rejoin ['£ item1]) first (item)
                        (make-do-loop cols skip from 2 where port index + 1)
                        (to-set-word item) next (item) 
                    ]
                ]
            ]
        ]
    ]

; ===================================================================
; SQL-INSERT function
; ===================================================================
; This execute the sql INSERT query

    sql-insert: func [
        table [word!]
        cols [block!]
        values [block!]
        port [port!]
        /local spec rows
    ][
        spec: get-cols-name table port
        if empty? cols [
            cols: copy spec
        ]
        cols
        rows: get-data table port
        do compose/deep [
            use [(spec)] [
                foreach item to-record values false [
                    set [(cols)] item
                    insert*/only tail rows reduce [(spec)]
                ]
            ]
        ]
        copy* []
    ]

; ===================================================================
; SQL-UPDATE function
; ===================================================================
; This execute the sql UPDATE query

    sql-update: func [
        table [word!]
        values [block!]
        where [block!]
        port [port!]
        /local spec data
    ][
        where: either empty? where [
            [true]
        ][
            to-rebol-where where
        ]
        spec: get-cols-name table port
        data: get-data table port
        do compose/deep [
            use [(spec)][
                while [not tail? data][
                    row: first data
                    set [(spec)] row
                    if (where) [
                        reduce [(values)]
                        change/only data reduce [(spec)]
                    ]
                    data: next data
                ]
            
            ]
        ]
        copy* []
    ]

; ===================================================================
; SQL-DELETE function
; ===================================================================
; This execute the sql DELETE query

    sql-delete: func [
        table [word!]
        where [block!]
        port [port!]
        /local spec data row
    ][
        where: either empty? where [
            [true]
        ][
            to-rebol-where where
        ]
        spec: copy* []
        foreach item get-cols table port [
            append spec item
        ]
        data: get-data table port
        do compose/deep [
            use [(spec)][
                while [not tail? data][
                    row: first data
                    set [(spec)] row
                    either (where) [
                        data: remove data
                    ][
                        data: next data
                    ]
                ]
            ]
        ]
        copy* []
    ]

; ===================================================================
; SQL-CREATE-TABLE function
; ===================================================================
; This execute the sql CREATE TABLE query

    table-schema: context [
        scheme: none
        cols: none
    ]

    sql-create-table: func [
        table [word!]
        cols [block!]
        if-not-exist [none! logic!]
        scheme [none! word!]
        spec [none! block!]
        port [port!]
        /local item file url
    ][
        if attempt [port/locals/table/:table] [
            either if-not-exist [
                return copy* []
            ][
                throw-error [type: 'sql id: 'already-exist arg1: "Table" arg2: table]
            ]
        ]
        if none? scheme [scheme: 'data]
        scheme: to-word lowercase to-string scheme
        if none? in system/schemes scheme [
            throw-error [type: 'sql id: 'invalid-type arg1: "table" arg2: table arg3: scheme]
        ]
        if none? spec [
            spec: copy* []
        ]
        if scheme = 'CSV [
            spec: make sql-text spec
            spec/format: to-string spec/format
            spec/delimiter: any [
                select ["CSVDelimited" "," "TabDelimited" "^-" "FixedLength" ""] spec/format
                spec/delimiter
                ";"
            ]
            spec: third spec
        ]
        port/locals/table: make port/locals/table compose/deep [
            (to-set-word table) [
                scheme: (to-lit-word scheme)
                target: (to-file rejoin [table either find to-string table #"." [copy ""][rejoin ["." scheme]]])
                schema: [
                    (spec)
                    cols: [(cols)]
                ]
            ]
        ]
        save-schema port
        get-data/new table port
        copy* []
    ]

; ===================================================================
; SQL-DROP-TABLE function
; ===================================================================
; This execute the sql DROP TABLE query

    sql-drop-table: func [
        table [word!]
        port [port!]
        /local item data url
    ][
        url: get-url table port
        if data: attempt [port/locals/data/:table] [
            close* data
            port/locals/data: context remove find third port/locals/data to-set-word table
        ]
        if exists? url [delete url]
        port/locals/table: context remove find third port/locals/table to-set-word table
        save-schema port
        copy* []
    ]

; ===================================================================
; Other function
; ===================================================================

; -----------------
; get-cols function
; -----------------

        get-cols: func [
            table [word!]
            port [port!]
            /local spec
        ][
            if none? spec: attempt [port/locals/table/:table] [
                throw-error [type: 'sql id: 'not-found arg1: "Table" arg2: table]
            ]
        spec: select spec to-set-word 'schema
            select spec to-set-word 'cols
        ]

; ----------------------
; get-cols-name function
; ----------------------

    get-cols-name: func [
        table [word!]
        port [port!]
        /local result
    ][
        result: copy* []
        foreach item get-cols table port [
        append result either block? item [ first item ][ item ]
        ]
        result
    ]

; -----------------
; get-data function
; -----------------

        get-data: func [
            table [word!]
            port [port!]
            /new
            /locals spec data
        ][
            if none? spec: attempt [port/locals/table/:table] [
                throw-error [type: 'sql id: 'not-found arg1: "Table" arg2: table]
            ]
            spec: compose [
                (spec)
                path: (port/path)
            ]
            if none? data: attempt [port/locals/data/:table] [
                port/locals/data: make port/locals/data compose [
                    (to-set-word table) either new [data: open*/new spec][data: open* spec]
                ]
            ]
        data
        ]

; ----------------
; get-url function
; ----------------

        get-url: func [
            table [word!]
            port [port!]
            /local spec word
        ][
            if none? spec: attempt [port/locals/table/:table] [
                throw-error [type: 'sql id: 'not-found arg1: "Table" arg2: table]
            ]
            spec: context spec
            to-url rejoin [spec/scheme ":" port/path spec/target]
        ]

; --------------------
; load-schema function
; --------------------

        load-schema: func [
            port [port!]
            /local file table spec item cols name value
        ][
            either port/target = %schema.ini [
                file: open/lines rejoin [port/path port/target]
                table: copy* []
            forall file [
                parse/all first file [
                    "[" copy name to "]" to end (
                        name: trim name
                        append table compose/only [
                            (to-set-word name) (spec: compose/only [
                                target: (to-file name)
                                schema: (item: compose/only [cols: (cols: copy* [])])
                            ])
                        ]
                    )
                |
                    "ColNameHeader=" copy value to end (
                        append item compose/only [
                            ColNameHeader: (do value)
                        ]
                    )
                |
                    "Format=Delimited(" copy value to ")" to end (
                        append spec compose [scheme: 'CSV]
                        append item compose/only [
                            Format: "Delimited"
                            Delimiter: (value)
                        ]
                    )
                |
                    "Format=" copy value to end (
                                    value: trim value
                        append spec compose [scheme: (select ["CSVDelimited" 'CSV "TabDelimited" 'CSV "FixedLength" 'FEXED] value)]
                        append item compose [
                            Format: (value)
                            Delimiter: (select ["CSVDelimited" "," "TabDelimited" "^-" "FixedLength" ""] value)
                        ]
                    )
                |
                    "Col" to "=" skip copy name to " " skip copy type to " width " " width " copy length to end (
                        insert*/only tail cols compose [
                            (to-word name) (to-word type) (to-integer length)
                        ]
                    )
                |
                    "Col" to "=" skip copy name to " " skip copy type to end (
                        insert*/only tail  cols compose [
                            (to-word name) (to-word type)
                        ]
                    )
                |
                    copy name to "=" skip copy value to end (
                        append item compose/only [
                            (to-set-word trim name) (value)
                        ]
                    )
                ]
            ]
                close file
                port/locals/table: context table
            ][
                port/locals/table: context load rejoin [port/path port/target]
            ]

        ]

; --------------------
; save-schema function
; --------------------

        save-schema: func [
            port [port!]
            /local file index schema
        ][
            either port/target = %schema.ini [
                file: open*/new/lines rejoin [port/path port/target]
                foreach [table spec] third port/locals/table [
                    append file rejoin ["[" to-word table "]"]
                    schema: third make sql-text select spec to-set-word 'schema
                    foreach [name value] schema [
                name: lowercase to-string name
                switch/default name [
                            "format" [
                                value: lowercase value
                                either value = "delimited" [
                                    append file rejoin ["format=Delimited(" select schema to-set-word 'delimiter ")"]
                                ][
                                    append file rejoin ["format=" value]
                                ]
                            ]
                            "delimiter" [
                            ]
                            "cols" [
                                index: 0
                                foreach col value [
                                    index: index + 1
                                    either block? col [
                                        append file reform [rejoin ["Col" index "=" col/1] col/2 either col/3 [reform ['width col/3]][""]]
                                    ][
                                        append file reform [rejoin ["Col" index "=" col] 'char 'width 255]
                                    ]
                                ]
                            ]
                        ][
                            append file rejoin ["" name "=" value]
                        ]
                    ]
                ]
                close* file
            ][
                if file? port/target [
                    save rejoin [port/path port/target] third port/locals/table
                ]
            ]
        ]

; ===================================================================
; sql-locals prototype
; ===================================================================

    sql-locals: context [

; Table object
; -------------
        table: context []

; Data object
; -----------
        data: context []
    ]

; ===================================================================
; sql-text prototype
; ===================================================================

    sql-text: context [
        ColNameHeader: True
        Format: "Delimited"
        Delimiter: ";"
        MaxScanRows: 0
        CharacterSet: "OEM"
    ]

; ===================================================================
; SQL Error model
; ===================================================================

    system/error: make system/error [
        sql: context [
            code: 8100
            type: "SQL Error"
            syntax: ["Syntax error" :arg1 "in query expression" :arg2]
            already-exist: [:arg1 :arg2 "already exist"]
            invalid-type: [:arg3 "is an invalid type for" :arg1 :arg2 ]
            not-found: [:arg1 :arg2 "could not be found. Make sur the object exists and that you spell it correctly"]
        ]
    ]

; ===================================================================
; SQL Protocol Handler
; ===================================================================
; This object contains the handler for the SQL protocol.

    context [

; ----------------
; SQL Init handler
; ----------------

        init: func [
            port
            spec [url! block!]
            /local scheme file path target locals
        ][
            net-utils/net-log reduce ["Initializing" mold/only spec "for" to-string port/scheme] 
            either url? spec [
                set [scheme file] parse/all spec ":"
                set [path target] split-path file: to-file file
                if not find target #"." [
                    set [path target] compose [(dirize file)]
                ]
                port/path: clean-path to-rebol-file path
                if none? target [
                    either exists? rejoin [port/path %schema.ini] [
                        target: %schema.ini
                    ][
                        target: %schema.ctl
                    ]
                ]
                port/target: target
                port/url: spec
                port/locals: make sql-locals []
            ][
                spec: context spec 
                if none? locals: attempt [spec/database] [
                    locals: []
                ]
                locals: make sql-locals locals
                if none? path: attempt [spec/path] [
                   path: %.
                ]
                path: dirize to-file path

                port/path: path
                port/target: 'transient
                port/locals: locals
            ]
            if none? port/target [
                net-error reform ["No target file for" port/scheme "is specified"]
            ]
        ]

; ----------------
; SQL Open handler
; ----------------

        open: func [
            port
            /local target file
        ][
            net-utils/net-log reduce ["Opening port for" to-string port/scheme]
            port/status: 'file
            port/state/flags: port/state/flags or system/standard/port-flags/pass-thru
            if file? port/target[
                target: join port/path port/target
                query* file: make port! target
                either file/status [
                    load-schema port
                ][
                    make-dir port/path
                    save-schema port
                ]
            ]
            port/state/inBuffer: copy* []
            port/state/tail: length? port/state/inBuffer
            port
        ]

; -----------------
; SQL Close handler
; -----------------

        close: func [
            port [port!]
        ][
            net-utils/net-log reduce ["Closing port for" to-string port/scheme]
            foreach item second port/locals/data [
                if port? item [
                    close* item
                ]
            ]
            port
        ]

; ------------------
; SQL Update handler
; ------------------

        update: func [
            port [port!]
        ][
            net-utils/net-log reduce ["Updating port for" to-string port/scheme] 
            foreach item next second port/locals/data [
                if port? item [
                    update* item
                ]
            ]
            port
        ]

; ----------------
; SQL Pick handler
; ----------------

        pick: func [
            port [port!]
        ][
            pick* port/state/inBuffer (port/state/index + port/state/num)
        ]

; ----------------
; SQL Copy handler
; ----------------

        copy: func [
            port [port!]
        ][
            net-utils/net-log ["Copy of" port/scheme]
            copy*/part at port/state/inBuffer index? port port/state/num
        ]

; ------------------
; SQL Insert handler
; ------------------

        insert: func [
            port [port!]
            value [string! block!]
            /local result
        ][
            net-utils/net-log ["Insert of " port/state/num "bytes"]
;            port/state/inBuffer: sql-query to-block value port
            port/state/inBuffer: sql-query value port
            port/state/tail: length? port/state/inBuffer
            head port
        ]

; ---------------------
; SQL get-modes handler
; ---------------------
        get-modes: func [
            port [port!]
            modes
        ][
            get-modes* port
        ]

; ---------------------
; SQL set-modes handler
; ---------------------
        set-modes: func [
            port [port!] "An open port spec"
            modes
        ][
            set-modes* port
        ]

; -------------------------
; SQL Register the protocol
; -------------------------

        net-utils/net-install SQL self none
    ]
]
