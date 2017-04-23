REBOL [
    Title: "REBOL Locking System"
    Date: 23-Jun-1999
    Version: 1
    File: %lock-file.r
    Author: "Cal Dixon"
    Rights: {
        Copyright (c) 1999 Caleb Dixon.  This version is free for ANY
        use.  Do whatever you want with it as long as you don't claim
        to have created this.
    }
    Usage: {
        Be sure to run the 'lock-server function in a separate rebol
        process before calling the other functions, they will fail if
        the server is not available.  Once the server is running, you
        can just "do %locker.r" then use 'get-lock and 'free-lock in
        any script that needs resource locking.
    }
    Purpose: {To provide functions for voluntary resource locking in rebol}
    Comment: {
       This version does not do enough error checking.  This will be
       fixed later.
    }
    Email: deadzaphod@hotmail.com
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: [tcp other-net] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

; change this line if you want to use a port other than 7007 for this service.
if not value? 'rebol-lock-port   [rebol-lock-port: 7007]

lock-server: func [{Handles requests to lock and unlock named resources.}][
    locks: make block! []
    listener: open/lines join tcp://: rebol-lock-port

    while [true] [
        conn: first listener
        wait conn
        req: load first conn
        if (= to-lit-word (pick req 1) 'lock) [
            if none? find locks (pick req 2) [ append locks reduce [ (pick req 2) true ] ]
        if (available: do rejoin [ "locks/" (pick req 2) ]) [
             do rejoin [ "locks/" (pick req 2) ": false" ]
        ]
        insert conn rejoin [ "[" available "]" ]
        ]
        if (= to-lit-word (pick req 1) 'free) [
            do rejoin [ "locks/" (pick req 2) ": true" ]
            insert conn "[ true ]"
        ]
        close conn
    ] 
] 

try-obtain-lock: function [ "Attempt to lock a named resource" 
    whichword [word!] ] [] [
    conn: open/lines join tcp://localhost: rebol-lock-port
    insert conn rejoin [ "[lock " whichword "]" ]
    return do load first conn
]

get-lock: function [ 
    {Attempt to lock a named resource, and retry if it is not available}
    whichword [word!] retries [integer!] ] [ gotit ] [

    while [ not (gotit: try-obtain-lock whichword) ] [
        if (retries < 1) [ return gotit ]
        retries: retries - 1
        wait 1
    ]
    gotit
]

free-lock: function [ "Free a named resource" whichword [word!] ] [] [
   conn: open/lines join tcp://localhost: rebol-lock-port
   insert conn rejoin [ "[free " whichword "]" ]
   return do load first conn
]

