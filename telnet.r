REBOL [
    Title: "Telnet protcol scheme"
    Date: 6-Jul-2001/17:51
    Version: 1.0.1.1
    File: %telnet.r
    Author: "Frank Sievertsen"
    Usage: {
        read telnet://user:password@host/command

        port: open telnet://user:password@host/command
        port: open telnet://user:password@host/
        port: open telnet://host/

        You will habe to use "copy" more than once to receive
        data from the port.
    }
    Purpose: "A telnet protocol scheme"
    History: [
        1.1.0 2-Jul-2001 "Original version" 
        1.1.1 6-Jul-2001 "Returns none, when connection closed"
    ]
    Email: fsievert@uos.de
    library: [
        level: 'advanced 
        platform: none 
        type: 'protocol 
        domain: [ldc other-net tcp] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

make Root-Protocol [
    scheme: 'telnet
    port-id: 23
    port-flags: system/standard/port-flags/pass-thru 
    tmp: none
    open: func [port /local in] [
        open-proto port
        if any [port/target port/path] [
            if not port/target [port/target: ""]
            if port/path [insert port/target port/path]
        ]
        port/state/flags: port/state/flags or system/standard/port-flags/direct or 32 or 2051; No-Wait, BINARY (51) (2048)
        port/sub-port/state/flags: port/sub-port/state/flags or 2051 or 32
        if all [port/user port/pass] [
            in: make string! 100
            until [
                append in copy port
                find in "login:"
            ]
            system/words/insert port/sub-port join port/user "^/"
            clear in
            until [
                append in copy port
                find in "password"
            ]
            system/words/insert port/sub-port join port/pass "^/"
            while ["" <> copy port] []
            if port/target [
                system/words/insert port/sub-port join port/target ";exit^/"
                clear in
                forever [
                    wait port/sub-port
                    tmp: make string! 100
                    if zero? read-io port/sub-port tmp 100 [break]
                    append in tmp
                ]
                port/user-data: in
            ]
        ]
    ]
    copy: func [port /part range /local in num] [
       either port/user-data [
          port/user-data
       ] [
          in: make string! 100
          out: make string! 100
          forever [
            num: 1
            while [wait [0 port/sub-port]] [
                tmp: make string! 100
                if zero? num: read-io port/sub-port tmp 100 [break]
                append in tmp
            ]
            if zero? num [break/return none]
            if parser/incoming in out [
                write-io port/sub-port out length? out
                break/return in
            ]
            system/words/wait port/sub-port
          ]
       ]
    ]
    insert: func [port data] [
        system/words/insert port/sub-port data
    ]

    parser: make object! [
        s-will: to-char 251
        s-wont: to-char 252
        s-do:   to-char 253
        s-dont: to-char 254

        iac:  to-char 255
        sb: to-char 250
        se: to-char 240
        required: to-char 1
        supplied: to-char 0

        non-command: complement charset reduce [iac]

        terminal-type: to-char 24
        terminal-speed: to-char 32
        suppress-go-ahead: to-char 3
        echo: to-char 1

        tmp: none

        send: func [block [block!]] [
            system/words/append out-port to-binary join iac reduce block
        ]

        sb-data: [
            iac se
            | skip sb-data
        ]

        start: end: none
        data: [any [
            start: iac [
                s-do terminal-type (
                    send [s-will terminal-type]
                )
                | s-do echo (
                    ; Ignore
                )
                | sb terminal-type required iac se (
                    send [sb terminal-type supplied "vt100" iac se]
                )
                ; DEFAULTS
                | sb sb-data
                | s-do copy tmp skip (
                    send [s-wont tmp]
                )
                | s-will copy tmp skip (
                    send [s-dont tmp]
                )
                | s-wont copy tmp skip (
                    ;Ignore
                )
                | s-dont copy tmp skip (
                    ;Ignore
                )
            ] end: (remove/part start end) :start
            | non-command
        ]]

        out-port: none
        incoming: func [str [any-string!] port [port! any-string!]] [
            out-port: port
            parse/all str data
        ]
    ]

    net-utils/net-install :scheme self port-id
]
                                                                                                                                                                