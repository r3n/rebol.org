REBOL [
    Title: "UDP Group Chat"
    date: 3-Aug-2010
    file: %udp-group-chat.r
    author:  Nick Antonaccio
    purpose: {
        Because this script uses UDP,  anyone who runs it on a local network will
        automatically receive messages broadcast by others on the same network.
        A separate server program and/or connection(s) to specific IP addresses
        are NOT required.  A "who's online" function is included to list all currently
        logged in users.
    }

]
net-in: open udp://:9905  ; This is UDP, so NO known IP addresses required
net-out: open/lines udp://255.255.255.255:9905
set-modes net-out [broadcast: on]
svv/vid-face/color: white
name: request-text/title "Your name:"
prev-message: ""
gui: view/new layout [
    a1: area wrap rejoin [name ", you are logged in."]  across
    f1: field
    btn "Save Chat" [write request-file/only/save/file %chat.txt a1/text]
    btn "?" [alert "Press [CTRL] + U to see who's online."]
    at 0x0 key #"^M" [
        if f1/text = "" [return]
        insert net-out rejoin [name {, } now/time {:    } f1/text]
    ]
    at 0x0 key #"^u" [
        insert net-out rejoin [name {, } now/time {:    Who's online?}]
    ]
]
forever [
    focus f1
    received: wait [net-in]
    if not viewed? gui [quit]
    if find (message: copy received) "Who's online" [
        insert net-out rejoin [name " is online."]
    ]
    if message <> prev-message [
        insert (at a1/text 1) message show a1
        attempt [
            insert s: open sound:// load %/c/windows/media/ding.wav
            wait s close s
        ]
    ]
    prev-message: copy message
]