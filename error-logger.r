REBOL [
    Title: "error-logger"
    Date: 10-Dec-2001/20:08:05+1:00
    Version: 1.2.0
    File: %error-logger.r
    Author: "Volker"
    Usage: {

find "test: [", kill all below and do this script,
or copy the functions to yours.

Following Docu thanks to Sunanda :

Problem: Rebol error messages give way to little context. Useful for 
development maybe, but underpowered for code deployed in the field.

Volker's solution.

1. Be structured. Embed all Funcs in Objects:

  MyObject1: [Myfunc1: func [...] [...]
                    Myfunc2: func [...] [...]
                  ]

  MyObject2: [Myfunc1: func [...] [...]
                    Myfunc2: func [...] [...]
                  ]


This is pretty good practice anyway.

2. For any of these functions you want a better set of reporting on, defined 
the with the Logged marker word:

  MyObject1: [Myfunc1: logged func [...] [...]
                    Myfunc2: func [...] [...]
                  ]

  MyObject2: [Myfunc1: logged func [...] [...]
                    Myfunc2: logged func [...] [...]
                  ]


(So for some reason, I've decided not to get a better oversight on 
MyObject1/MyFunc2)

3. Before you make your first object call, run Volker's initialisation code:

Logging MyObject1
Logging MyObject2

(This replaces the 'logged marker word with some magic).

Thanks Volker!
Sunanda.
}
    Purpose: {give better error feedback. logs a kind of stack-trace on error.}
    History: [
    1.2.0 "thanks to Sunanda real docu :)" 
    1.1.0 "logged/logging to have more service added" 
    1.0.1 "error without log-file, fixed"
]
    Email: nitsch-lists@netcologne.de
    Web: http://www.escribe.com/internet/rebol/index.html?by=OneThread&t=%5BREBOL%5D%20Better%20error%20messages?
    library: [
        level: none 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
;
;control your logging here
;note i prefer logs with newest entries at top,
;otherwise i could use write/append ;-)
;
insert-error-log: func [msg] [
    msg: rejoin [newline mold now newline msg]
    print msg
    if not exists? log-file: %error-log.txt [write log-file ""]
    (write log-file join msg read log-file)
]
;
;wizzardry
;
mission: func [
    {like throw-on-error, but on error string is printed and logged.}
    string "mission-name"
    blk [block!]
] [
    if error? set/any 'blk try blk [
        msg: reform [
            ">>>mission failed>>>" newline
            "mission" remold string "error:" newline
            form-error disarm blk newline
            "<<<mission failed<<<" newline
        ]
        insert-error-log msg
        throw blk
    ]
    :blk
]
;
; THEN we want more service:
;
its-a-logged-func: func [[catch] /local msg] [
    alert msg: "ups, used 'its-a-logged-func without 'logging ?"
    throw make error! msg
]
logged: func ["mark a function for logging" f [function!]] [
    insert second :f 'its-a-logged-func
    :f
]
logging: func [
    "expaned all logged-marked functions in context"
    object
    /local name body here log-mark new-body
] [
    parse third object [
        any [
            set name set-word! here: function! (
                body: second first here
                if log-mark: find body 'its-a-logged-func [
                    remove log-mark
                    new-body: reduce ['mission mold :name copy body]
                    insert clear body new-body
                    insert/only third first here [catch]
                ]
            )
            | set-word! any-type! ()
        ]
    ]
    object
]
;
;tools
;
form-error: func [
    error [object!]
    /local arg1 arg2 arg3 message out
] [
    out: make string! 100
    set [arg1 arg2 arg3] [error/arg1 error/arg2 error/arg3]
    message: get in get in system/error error/type error/id
    if block? message [bind message 'arg1]
    append out reform reduce message
    append out reform ["^/Near:" mold error/near]
    append out reform ["^/Where:" mold get in error 'where]
]
;
;--- test-stuff below, snip it ----------------------
;
test: [
    print "based on:"
    source throw-on-error
    ;
    ;prepare mission-handling
    ;
    insert-error-log "a new test^/^/"
    ;
    ;an error-throwing demo
    ;
    ;basic demo
    ; Define object
    Initcode1: make object! [
        displayscreen: func [[catch] p-type /local line-count] [
            mission "displaying screen" [
                switch p-type [
                    "A" [Line-Count: Line-Count + 1]
                ]
            ]
        ]
    ]
    ;
    print "logged/logging-demo"
    ;
    ; Define object
    print "the source"
    Initcode2: logging probe make object! [
        displayscreen: logged func [p-type /local line-count] [
            switch p-type [
                "A" [Line-Count: Line-Count + 1]
            ]
        ]
    ]
    print "and the expansion"
    ? initcode2

    ;define function that uses the object                  
    mainfunc: func [] [initcode2/displayscreen "A"]

    ; Run the function
    ; wrapped with error-handler to run ok on desktop
    if error? set/any 'err try [
        MainFunc
    ] [print form-error disarm err]
    alert "see text in console"
]

do test                                                                                                                                                                                                  