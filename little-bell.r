REBOL [
    Title: "Little-bell"
    Date: 8-Jul-1999
    Version: 1.0.0
    File: %little-bell.r
    Author: "Ole Friis"
    Purpose: "Rudimentary Telnet client written in REBOL."
    Comment: {
        This script can be used to perform basic Telnet operation over
        the Internet. It does not support all of RFC 854 (it lacks
        support for the commands SE, DM, BRK, IP, AO, EL, and SB), but
        still this should suffice for your basic needs.  Perhaps in
        the future I'll add support for the rest of the RFC 854
        commands along with a host of options scattered around in
        other RFCs.

        Thanks to:
           * James Card <jdcard@inreach.com> for pointing me at the
             Telnet RFC.
           * Andrew Martin <AI.Bri@xtra.co.nz> for the name "Bell".
           * All the nice and helpful people at REBOL Inc. and on the
             REBOL mailing list!!!
    }
    Email: ole_f@post3.tele.dk
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

; The supported commands and their meaning, see RFC 854
cmd_AYT:  to-char 246 ; Are You There?
cmd_EC:   to-char 247 ; Erase character
cmd_WILL: to-char 251 ; Will
cmd_WONT: to-char 252 ; Won't
cmd_DO:   to-char 253 ; Do
cmd_DONT: to-char 254 ; Don't
cmd_IAC:  to-char 255 ; Interpret as command

; What to do with the various commands
command-actions: reduce [
    cmd_AYT [
        ; Give a sign of life
        telnet-send "Yes, we're here!"
        finish-command
    ]
    cmd_EC [
        ; Erase one character
        prin "^(back) ^(back)"
        finish-command
    ]
    cmd_WILL [
        if 2 = length? command-buffer [
            ; Try to stop all of these!
            telnet-send [cmd_IAC cmd_DONT second command-buffer]
            finish-command
        ]
    ]
    cmd_WONT [
        if 2 = length? command-buffer [
            ; We don't care what the other part won't
            finish-command
        ]
    ]
    cmd_DO [
        if 2 = length? command-buffer [
            ; No, we won't!
            telnet-send [cmd_IAC cmd_WONT second command-buffer]
            finish-command
        ]
    ]
    cmd_DONT [
        if 2 = length? command-buffer [
            ; No problem, as we won't
            finish-command
        ]
    ]
]

; Cleans up after a finished command
finish-command: func [] [
    clear command-buffer
    reading_command: no
]

; Sends a block of characters to the Telnet server
telnet-send: func [block] [
    append server-port to-string reduce block
]

; Start the session!
if error? try [
    server-port: open/binary/direct to-url rejoin [
        "TCP://"
        ask "Server name: "
        ":23"
    ]
] [print "Could not connect to server" halt]

console-port: open/binary [scheme: 'console]
ports: reduce [server-port console-port]
command-buffer: make string! 20
server-buffer:  make string! 2000
console-buffer: make string! 200
reading_command: no

while [true] [
    port: wait ports

    ; Should we read from the keyboard or the server?
    either port = server-port [
        ; Get a chunk of input from the server
        server-buffer: head server-buffer
        clear server-buffer
        read-io server-port server-buffer 2000

        ; First see if the connection has been closed
        if 0 = length? server-buffer [
            print "** Session finished **"
            close server-port
            close console-port
            halt
        ]

        ; Then process the input we just got
        while [0 < length? server-buffer] [
            either reading_command [
                insert tail command-buffer first server-buffer
                server-buffer: next server-buffer
                switch/default first command-buffer command-actions [
                    finish-command
                ]
            ] [
                either next-server-buffer: find server-buffer cmd_IAC [
                    prin copy/part server-buffer next-server-buffer
                    server-buffer: next next-server-buffer
                    reading_command: yes
                ] [
                    prin server-buffer
                    server-buffer: tail server-buffer
                ]
            ]
        ]
    ] [
        ; Process some console input
        ch: to-char pick port 1
        either (ch = newline) or (ch = #"^M") [
            telnet-send [console-buffer #"^M" newline]
            clear console-buffer
            print ""
        ] [
            either ch = #"^(back)" [
                if 0 < length? console-buffer [
                    prin "^(back) ^(back)"
                    remove back tail console-buffer
                ]
            ] [
                prin ch
                append console-buffer ch
            ]
        ]
    ]
]
