REBOL [
    Title: "Rugby"
    Date: 8-Aug-2001/14:12:55+2:00
    Version: 3.4.0
    File: %rugby3.r
    Author: "Maarten Koopmans"
    Needs: "Command 2.0+ , Core 2.5+ , View 1.1+"
    Purpose: {A high-performance, handler based, server framework and a rebol request broker...}
    Comment: {Many thanx to Ernie van der Meer for code scrubbing.
            Added touchdown and view integration.
^-^-^-^-^-^-Fixed non-blocking I/O bug in serve and poll-for-result.
^-^-^-^-^-^-Added trim/all to handle large binaries in decompose-msg.
Fixed rugby protocol.
^-^-}
    Email: m.koopmans2@chello.nl
    library: [
        level: 'advanced 
        platform: none 
        type: none 
        domain: [GUI tcp other-net ldc] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

hipe-serv: make object!
[
    port-q: copy []
    object-q: copy []
    server-port: none
    my-handler: none
    restricted-server: make block! 20
    restrict: no
    restrict-to: func
    [
        {Sets server restrictions. The server will only serve to machines with
     the IP-addresses found in the list.}
        r [any-block!] "List of IP-addresses to serve."
    ]
    [
        restrict: yes
        append restricted-server r
    ]
    allow?: func
    [
        {Checks if a connection to the specified IP-address is allowed.}
        ip [tuple!] "IP-address to check."
    ]
    [
        return found? find restricted-server ip
    ]
    port-q-delete: func
    [
        "Removes a port from our port list."
        target [port!]
    ]
    [
        remove find port-q target
    ]
    port-q-insert: func
    [
        "Inserts a port into our port list."
        target [port!]
    ]
    [
        append port-q target
    ]
    object-q-insert: func
    [
        {Inserts a port and its corresponding object into the object queue.}
        target [port!]
        /local o
    ]
    [
        append object-q target
        o: make object! [port: target handler: :my-handler user-data: none]
        append object-q o
    ]
    object-q-delete: func
    [
        {Removes a port and its corresponding object from the object queue.}
        target [port!]
    ]
    [
        remove remove find object-q target
    ]
    start: func
    [
        {Initializes everything for a client connection on application level.}
        conn [port!]
    ]
    [
        set-modes conn [no-wait: true]
        port-q-insert conn
        object-q-insert conn
    ]
    stop: func
    [
        "cleans up after a client connection."
        conn [port!]
        /local conn-object
    ]
    [
        port-q-delete conn
        error? try
        [
            conn-object: select object-q conn
            close conn-object/port
            object-q-delete conn
        ]
    ]
    init-conn-port: func
    [
        "Initializes everything on network level."
        conn [port!]
    ]
    [
        either restrict
        [
            either allow? conn/remote-ip
            [
                start conn
                return
            ]
            [
                close conn
                return
            ]
        ]
        [
            start conn
            return
        ]
    ]
    init-server-port: func
    [
        "Initializes our main server port."
        p [port!]
        conn-handler [any-function!]
    ]
    [
        server-port: p
        append port-q server-port
        server-port/backlog: 15
        my-handler: :conn-handler
        open/direct/no-wait server-port
    ]
    process-ports: func
    [
        "Processes all ports that have events."
        portz [block!] "The port list"
        /local temp-obj
    ]
    [
        foreach item portz
        [
            either (item = server-port)
            [
                init-conn-port first server-port
            ]
            [
                if item/scheme = 'tcp
                [
                    temp-obj: select object-q item
                    temp-obj/handler temp-obj
                ]
            ]
        ]
    ]
    serve: func
    [
        {Starts serving. Does a blocking wait until there are events.}
        /local portz
    ]
    [
        forever
        [
            portz: wait/all port-q
            process-ports portz
        ]
    ]
]
rugby-server: make hipe-serv
[
    exec-env: none
    nargs: func
    [
        "Gets the number of function arguments."
        f [any-function!]
    ]
    [
        -1 + index? any [find first :f refinement! tail first :f]
    ]
    fill-0: func
    [
        "Zero-extends a string number."
        filly [string!]
        how-many [integer!] 
        /local fills
    ] 
    [
        loop how-many - length? filly [insert filly "0"] 
        return filly
    ] 
    compose-msg: func 
    [
        "Creates a message for on the wire transmission." 
        msg [any-block!]
    ] 
    [
        f-msg: reduce [checksum/secure mold do mold msg msg] 
        return mold compress mold f-msg
    ] 
    clear-buffer: func [cleary [port!] /local msg size-read] 
    [
        msg: copy "" 
        until 
        [
            size-read: read-io cleary msg 1 
            1 = size-read
        ]
    ] 
    decompose-msg: func 
    [
        {Extracts a message that has been transmitted on the wire.} 
        msg [any-string!]
    ] 
    [
        return do decompress do trim/all msg
    ] 
    check-msg: func 
    [
        "Check message integrity." 
        msg [any-block!]
    ] 
    [
        return (checksum/secure mold second msg) = first msg
    ] 
    write-msg: func 
    [
        "Does a low-level write of a message." 
        msg 
        dest [port!] 
        /local length
    ] 
    [
        set-modes dest [no-delay: true] 
        either 16000 > length? msg 
        [
            length: write-io dest msg length? msg 
            either length = length? msg 
            [
                return true
            ] 
            [
                return length
            ]
        ] 
        [
            length: write-io dest msg 16000
        ] 
        if 0 > length [return true] 
        return length
    ] 
    safe-exec: func 
    [
        {Safely executes a message. Checks the exec-env variable for a list of
     valid commands to execute.} 
        statement [any-block!] 
        env [any-block!] 
        /local res n stm err
    ] 
    [
        if found? (find env first statement) 
        [
            n: nargs get to-get-word first statement 
            res: none 
            stm: copy/part statement (n + 1) 
            res: do stm 
            return res
        ] 
        make error! rejoin ["Rugby server error: Unsupported function: " mold statement]
    ] 
    do-message: func 
    [
        "High-level 'do' of a message." 
        msg [any-string!] 
        /local f-msg res size-read
    ] 
    [
        f-msg: decompose-msg msg 
        either check-msg f-msg 
        [
            res: safe-exec pick f-msg 2 exec-env 
            return res
        ] 
        [
            make error! rejoin [{Rugby server error: Message integrity check failed: } pick f-msg 2]
        ]
    ] 
    do-handler: func 
    [
        {The rugby server-handler (my-handler in hipe-serv).} 
        o 
        /local msg ret size size-read result
    ] 
    [
        if (none? o/user-data) 
        [
            o/user-data: copy ""
        ] 
        if (not object? o/user-data) 
        [
            error? try 
            [
                size: copy "" 
                msg: copy/part o/port (8 - (length? o/user-data)) 
                size-read: length? msg 
                either (size-read = (8 - (length? o/user-data))) 
                [
                    size: copy o/user-data 
                    append size copy/part msg (8 - (length? o/user-data)) 
                    remove/part msg (8 - (length? o/user-data)) 
                    if (0 < (length? msg)) [size: (to-integer size) - length? msg] 
                    o/user-data: context 
                    [
                        task: copy msg 
                        rest: to-integer size 
                        ret-val: copy "" 
                        msg-read: false 
                        ret-val-written: false 
                        task-completed: false 
                        header-written: false 
                        header-length: copy "0"
                    ]
                ] 
                [
                    o/user-data: append o/user-data msg
                ] 
                unset 'size
            ] 
            return
        ] 
        if (not o/user-data/msg-read) 
        [
            if (error? try 
                [msg: copy "" 
                    size-read: length? msg: copy/part o/port o/user-data/rest
                ]) 
            [return] 
            if 0 = size-read [return] 
            o/user-data/task: append o/user-data/task msg 
            o/user-data/rest: (o/user-data/rest - size-read) 
            if (o/user-data/rest = 0) [o/user-data/msg-read: true] 
            return
        ] 
        if not o/user-data/task-completed 
        [
            ret: copy [] 
            if error? result: try [do-message o/user-data/task] 
            [
                result: disarm result
            ] 
            append/only ret result 
            o/user-data/ret-val: compose-msg ret 
            o/user-data/header-length: fill-0 to-string length? o/user-data/ret-val 8 
            o/user-data/task-completed: true
        ] 
        if not o/user-data/header-written 
        [
            wr-res: write-msg o/user-data/header-length o/port 
            either logic? wr-res 
            [
                o/user-data/header-written: true
            ] 
            [
                remove/part o/user-data/header-length wr-res
            ] 
            return
        ] 
        if not o/user-data/ret-val-written 
        [
            wr-res: write-msg o/user-data/ret-val o/port 
            o/user-data/ret-val 
            either logic? wr-res 
            [
                o/user-data/ret-val-written: true 
                clear-buffer o/port 
                stop o/port
            ] 
            [
                remove/part o/user-data/ret-val wr-res
            ] 
            return
        ]
    ] 
    init-rugby: func 
    [
        {Inits our server according to our server port-spec and with rugby's
     do-handler} 
        port-spec [port!] 
        x-env [any-block!]
    ] 
    [
        exec-env: copy x-env 
        init-server-port port-spec :do-handler
    ] 
    go: func 
    [
        "Start serving."
    ] 
    [
        serve
    ]
] 
serve: func 
[
    "Exposes a set of commands as a remote service" 
    commands [block!] "The commands to expose" 
    /with "Expose on a different port than tcp://:8001" p [port!] "Other port" 
    /restrict "Restrict access to a block of ip numbers" r [block!] "ip numbers"
] 
[
    if restrict 
    [
        rugby-server/restrict-to r
    ] 
    either with 
    [
        rugby-server/init-rugby p commands
    ] 
    [
        rugby-server/init-rugby make port! tcp://:8001 commands
    ] 
    rugby-server/serve
] 
rugby-client: make object! 
[
    deferred-ports: copy [] 
    deferred-index: 0 
    fill-0: func 
    [
        "Zero-extends a string number." 
        filly [string!] 
        how-many [integer!] 
        /local fills
    ] 
    [
        loop how-many - length? filly [insert filly "0"] 
        return filly
    ] 
    compose-msg: func 
    [
        "Creates a message for on the wire transmission." 
        msg [any-block!]
    ] 
    [
        f-msg: reduce [checksum/secure mold do mold msg msg] 
        return mold compress mold f-msg
    ] 
    decompose-msg: func 
    [
        {Extracts a message that has been transmitted on the wire.} 
        msg [any-string!]
    ] 
    [
        return do decompress do trim/all msg
    ] 
    check-msg: func 
    [
        "Check message integrity." 
        msg [any-block!]
    ] 
    [
        return (checksum/secure mold second msg) = first msg
    ] 
    write-msg: func 
    [
        "Writes a message on the port." 
        msg [any-block!] 
        dest [port!] 
        /local length f-msg
    ] 
    [
        f-msg: compose-msg msg 
        length: fill-0 to-string length? f-msg 8 
        write-io dest length 8 
        write-io dest f-msg length? f-msg 
        write-io dest length 1
    ] 
    rexec: func 
    [
        "Does a high-level rexec." 
        msg [any-block!] 
        /with p [port!] 
        /oneway 
        /deferred 
        /local res dest holder err
    ] 
    [
        dest: either with [p] [make port! tcp://127.0.0.1:8001] 
        open/no-wait/direct dest 
        write-msg msg dest 
        holder: make object! 
        [
            port: dest 
            data: copy "" 
            length: none
        ] 
        deferred-index: 1 + deferred-index 
        append deferred-ports deferred-index 
        append deferred-ports holder 
        if not any [oneway deferred] 
        [
            return wait-for-result deferred-index
        ] 
        if deferred [return deferred-index] 
        return true
    ] 
    poll-for-result: func 
    [
        index [integer!] 
        /local o msg size-read
    ] 
    [
        o: select deferred-ports index 
        if not object? o 
        [
            make error! {Rugby client error: poll-for-result: Failed to locate deferred port object}
        ] 
        set-modes o/port [no-wait: true] 
        msg: make string! 512 
        size-read: read-io o/port msg 512 
        either 0 >= size-read 
        [
            return false
        ] 
        [
            append o/data msg
        ] 
        if all [none? o/length 8 <= length? o/data] 
        [
            o/length: 8 + to-integer copy/part o/data 8
        ] 
        either all [o/length o/length <= length? o/data] 
        [
            close o/port 
            msg: decompose-msg skip o/data 8 
            remove/part find deferred-ports index 2 
            either check-msg msg 
            [
                return do pick msg 2
            ] 
            [
                make error! rejoin [{Rugby client error: Return message integrity check failed on} 
                    mold pick msg 2]
            ]
        ] 
        [
            return false
        ]
    ] 
    wait-for-result: func 
    [
        index [integer!]
    ] 
    [
        until [poll-for-result index]
    ]
] 
set 'rexec get in rugby-client 'rexec 
wait-for-result: func 
[
    "Wait for the result to arrive" 
    index [integer!] "index of the result to wait for."
] 
[
    rugby-client/wait-for-result index
] 
poll-for-result: func 
[
    {Poll if the result has arrived. Return false or the value (or none in
   case of an error).} 
    index [integer!] "the index to poll for."
] 
[
    rugby-client/poll-for-result index
] 
touchdown-server: make object! 
[
    key: none 
    init-key: has [exists-key] 
    [
        if not key 
        [
            either error? try [exists-key: exists? %tdserv.key] 
            [
                key: rsa-make-key key 
                rsa-generate-key key 512 3
            ] 
            [
                either exists-key 
                [
                    if error? try [key: do read %tdserv.key] 
                    [
                        key: rsa-make-key key 
                        rsa-generate-key key 512 3
                    ]
                ] 
                [
                    key: rsa-make-key 
                    rsa-generate-key key 512 3
                ] 
                error? try [write %tdserv.key mold key]
            ]
        ]
    ] 
    get-public-key: does [return key/n] 
    get-session-key: func [s-key [binary!] /local k] 
    [
        k: rsa-encrypt/decrypt/private key s-key 
        return k
    ] 
    decrypt: func [msg [binary!] k [binary!] /local res dec-port crypt-str] 
    [
        crypt-str: 8 * length? k 
        dec-port: open make port! [
            scheme: 'crypt 
            algorithm: 'blowfish 
            direction: 'decrypt 
            strength: crypt-str 
            key: k 
            padding: true
        ] 
        insert dec-port msg 
        update dec-port 
        res: copy dec-port 
        close dec-port 
        return to-string res
    ] 
    encrypt: func [msg [binary! string!] k [binary!] /local res enc-port crypt-str] 
    [
        crypt-str: 8 * length? k 
        enc-port: open make port! [
            scheme: 'crypt 
            algorithm: 'blowfish 
            direction: 'encrypt 
            strength: crypt-str 
            key: k 
            padding: true
        ] 
        insert enc-port msg 
        update enc-port 
        res: copy enc-port 
        close enc-port 
        return res
    ] 
    get-message: func [msg [binary!] dec-key [binary!] /local crypto-port crypto-strength answ] 
    [
        answ: decrypt msg dec-key 
        return answ
    ] 
    get-return-message: func [r enc-key [binary!] /local blok msg] 
    [
        blok: copy [] 
        append blok r 
        msg: encrypt mold blok enc-key 
        return msg
    ] 
    sexec-srv: func [stm [block!] /local str-stm stm-blk] 
    [
        stm-blk: do get-message do pick stm 2 get-session-key do pick stm 1 
        return get-return-message rugby-server/safe-exec stm-blk rugby-server/exec-env get-session-key do pick stm 1
    ]
] 
negotiate: does 
[
    return append append copy [] crypt-strength? touchdown-server/get-public-key
] 
set 'sexec-srv get in touchdown-server 'sexec-srv 
secure-serve: func ["Start a secure server." statements [block!] 
    /with "On a specific port" p "The port spec." [port!] 
    /restrict "Limit access to specific IP addresses" rs "Block of allowed IP addresses" [block!] 
    /local s-stm
] 
[
    touchdown-server/init-key 
    s-stm: append copy statements [negotiate sexec-srv] 
    if all [with restrict] 
    [
        serve/with/restrict s-stm p rs
    ] 
    if with 
    [
        serve/with s-stm p
    ] 
    if restrict 
    [
        serve/restrict s-stm rs
    ] 
    serve s-stm
] 
touchdown-client: make object! 
[
    decrypt: func ["Generic decryption function" 
        msg [binary!] 
        k [binary!] 
        /local res dec-port crypt-str
    ] 
    [
        crypt-str: 8 * length? k 
        dec-port: open make port! [
            scheme: 'crypt 
            algorithm: 'blowfish 
            direction: 'decrypt 
            strength: crypt-str 
            key: k 
            padding: true
        ] 
        insert dec-port msg 
        update dec-port 
        res: copy dec-port 
        close dec-port 
        return to-string res
    ] 
    encrypt: func [
        msg [binary! string!] 
        k [binary!] 
        /local res enc-port crypt-st
    ] 
    [
        crypt-str: 8 * length? k 
        enc-port: open make port! [
            scheme: 'crypt 
            algorithm: 'blowfish 
            direction: 'encrypt 
            strength: crypt-str 
            key: k 
            padding: true
        ] 
        insert enc-port msg 
        update enc-port 
        res: copy enc-port 
        close enc-port 
        return res
    ] 
    key-cache: copy [] 
    negotiate: func [dest [port!] /local serv-strength] 
    [
        if not found? find key-cache mold dest 
        [
            serv-strength: rexec/with [negotiate] dest 
            serv-strength 
            if not none? serv-strength 
            [
                append key-cache mold dest 
                append key-cache serv-strength
            ] 
            return serv-strength
        ] 
        return select key-cache mold serv-strength
    ] 
    generate-session-key: func [crypt-str [integer!]] 
    [
        return copy/part checksum/secure mold now/date 16
    ] 
    generate-message: func [stm [block!] s-key [binary!] r-key [object!] /local str-stm blk-stm crypt-port p-blk] 
    [
        blk-stm: copy [sexec-srv] 
        p-blk: copy [] 
        append p-blk rsa-encrypt r-key s-key 
        append p-blk encrypt mold stm s-key 
        append/only blk-stm p-blk 
        return blk-stm
    ] 
    get-return-message: func [stm s-key [binary!] /local ret] 
    [
        ret: do decrypt stm s-key 
        return ret
    ] 
    sexec: func [{A secure exec facility a la rexec for /Pro and /COmmand users} 
        stm [any-block!] /with dest [port!] 
        /local port sst crypt-str r-key ps-key g-stm ret s-key
    ] 
    [
        either with 
        [
            port: dest
        ] 
        [
            port: make port! tcp://localhost:8001
        ] 
        sst: negotiate port 
        if none? sst [return none] 
        either (crypt-strength? = 'full) 
        [
            either (first sst) = 'full 
            [
                crypt-str: 128
            ] 
            [
                crypt-str: 56
            ]
        ] 
        [
            crypt-str: 56
        ] 
        s-key: generate-session-key crypt-str 
        ps-key: second sst 
        r-key: rsa-make-key 
        r-key/n: ps-key 
        r-key/e: 3 
        g-stm: generate-message stm s-key r-key 
        ret: rexec/with g-stm port 
        either none? ret 
        [
            return ret
        ] 
        [
            return do get-return-message ret s-key
        ]
    ]
] 
set 'sexec get in touchdown-client 'sexec 
rugby-view: func [
    {Displays a window face. Does not start the event loop.} 
    view-face [object!] 
    /new "Creates a new window and returns immediately" 
    /offset xy [pair!] "Offset of window on screen" 
    /options opts [block! word!] "Window options [no-title no-border resize]" 
    /title text [string!] "Window bar title" 
    /local scr-face
] [
    scr-face: system/view/screen-face 
    if find scr-face/pane view-face [return view-face] 
    either any [new empty? scr-face/pane] [
        view-face/text: any [
            view-face/text 
            all [system/script/header system/script/title] 
            copy ""
        ] 
        new: all [not new empty? scr-face/pane] 
        append scr-face/pane view-face
    ] [change scr-face/pane view-face] 
    if offset [view-face/offset: xy] 
    if options [view-face/options: opts] 
    if title [view-face/text: text] 
    show scr-face 
    view-face
] 
echo: func [e [string!]] [return e] 
client-test: does [rexec [echo "Rugby is great!"]]                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            