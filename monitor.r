REBOL [
    Title: "Handy Server Monitor Window"
    Date: 2-May-2002
    Version: 1.0.0
    File: %monitor.r
    Author: "Carl Sassenrath"
    Purpose: {A handy script that  monitors various servers (such as
web and email servers) and displays them in a nice little
status window.
}
    Email: carl@rebol.com
    library: [
        level: none 
        platform: none 
        type: none 
        domain: [other-net tcp web GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

sleep-time: 60

;-- Main window layout:
window: layout [
    style lab text 100x24 right middle
    style inf info 200 font-color white
    style err info 40 center

    across origin 8 space 4x4
    h2 "Server Monitor" return
    lab "Status:" t1: info 200 "Initializing"
    text "Errs" center bottom 40x24 bold return
    l2: lab "Email Port:"  t2: inf  200 e2: err return
    l3: lab "Web Server:"  t3: inf  200 e3: err return
    l4: lab "Docs Server:" t4: inf  200 e4: err return
    l5: lab "CGI Script:"  t5: inf  200 e5: err return
]

;-- Set error counts:
foreach face [e2 e3 e4 e5] [set in get face 'text 0]

;-- Window update functions:
start: func [lab str] [
    stat none none str
    lab/color: gold
    show lab
]

done: func [lab] [
    lab/color: none
    show lab
]

count-error: func [face] [
    face/text: face/text + 1
    show face
]

stat: func [face 'status str] [
    t1/text: str
    show t1
    if face [
        face/text: str
        face/color: select [ok 0.130.0 bad 150.0.0] status
        show face
    ]
]

check: func [face title block /local info err] [
    if none? info: find window/pane face [exit]
    set [info err] next info
    start face reform ["Connecting to" title] 
    either error? try block [
        stat info bad reform ["Failed:" title]
        count-error err
    ][
        stat info ok reform [title "Ok"]
    ]
    done face
]

view/new window

forever [

    ;-- Clear all status boxes:
    foreach face [t2 t3 t4 t5] [
        face: get face
        face/color: black
        face/text: ""
        show face
    ]

    ;-- Try to connect via tcp to known address:
    check l2 "TCP Email Port" [
        close open [
            scheme: 'tcp
            host: 208.201.243.114
            port-id: 25
        ]
    ]

    ;-- Try connect and request from HTTP servers:
    check l3 "REBOL Web Server" [read http://www.rebol.com]

    check l4 "REBOL Tech Server" [read http://www.reboltech.com]

    check l5 "CGI Test" [
        read http://demo.rebol.net/cgi-bin/test.r
    ]

    ;-- Count down to next check:
    repeat n sleep-time [
        wait 1
        if not viewed? window [quit] ; in case window was closed
        stat none none reform ["Checking in" sleep-time - n "seconds"]
    ]
]
                                                                                                                