REBOL [
    Title: "RIM - REBOL Instant Messenger"
    Date: 5-Jul-2001/3:45-7:00
    Version: 1.2.2
    File: %rim.r
    Author: "Sean & Carl Sassenrath"
    Purpose: "A true peer-to-peer instant messenger."
    History: [
    1.0.0 20-May-2001 "Original version" 
    1.0.8 21-May-2001 "Welcome, auto-popup, and log-file options added." 
    1.1.0 22-May-2001 {User list indicates connection. Disconnect supported.} 
    1.2.0 17-Jun-2001 "Added window resizing." 
    1.2.1 5-Jul-2001 {'me dialog added. Timestamp option added. Changes by Seth Chromick (vache@bluejellybean.com)} 
    1.2.2 1-Nov-2001 "Validate local users file. -Carl"
]
    Email: carl@rebol.com
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: [ldc other-net tcp GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]


comment {
opts: center-face layout [

    across
    text "Name:" tab me: field user-prefs/name
    return

    across
    text "Site:" tab site: field "http://www.reboltech.com/cgi/rebol"
    return
    
    across  
    text "Pop to top?:" tab pop-to-top: check
    return

    across
    text "Logfile:" tab log-file: field "none"
    return

    across
    text "Greeting:" tab greeting: field "Hello! :)"
    return
    button "Close" [unview/only opts]

] "RIM Options"
}

me: any [request-text/title/default "Enter your name:" user-prefs/name]

site:       http://www.reboltech.com/cgi/rebol
timestamp:  yes
user:       replace/all copy me " " "%20"
pop-to-top: on
log-file:   off  ; Set to %rim-save.txt to save msgs
greeting:   none
poll-time:  0:01
users:      either exists? %rim-users.r [load %rim-users.r][[]]

; Only strings allowed:
forall users [
    if not string? users/1 [remove users][users: next users]
]
users: head users

user-list: []
ports: []

instructions: trim/auto {
    If you are using a firewall, it will block incoming connections.
    However, outgoing connections will work (if no firewall on other side).

    Click on one or more names in the list to connect directly to them.

    Click Greet to provide a greeting when people connect to you.
}

open-listen: does [
    if error? try [listener: open/lines tcp://:7070][
        alert "Computer will not allow connections." quit
    ]
    ports: reduce [poll-time listener]
]

quit-prog: does [
    read join site/lookup.r?cmd=remove&service=chat&name= user
    foreach p next ports [close p]
    quit
]

announce: has [active] [
    li/effect: [gradcol 255.0.0 200.200.0]  show li
    if error? try [
        user-list: load join site/lookup.r?cmd=post&service=chat&name= [user "&data=7070"]
    ][
        show-msg "Cannot connect to name lookup server."
        exit
    ]
    active: extract user-list 4
    if not empty? exclude active users [
        users: union users active
        save %rim-users.r users
    ] 
    sort/compare users func [a b] [
        if not find active a [return 1]
        if not find active b [return -1]
        0
    ]
    li/effect: none
    show [ul li]
]

toggle-user: func [user] [
    if not disconnect-user user [connect-to user]
]

disconnect-user: func [user] [
    if port: is-here? user [
        close port
        remove find ports port
        return true
    ]
]

connect-to: func [user /local port] [
    if not user: find user-list user [exit]
    flash rejoin ["Connecting directly to " user/1 "..."]
    if error? try [port: open/lines join tcp:// [user/2 ":" user/4]][
        unview
        show-msg rejoin ["Cannot connect to: " user/1 " Could be behind a firewall."]
        exit
    ]
    unview
    append ports port
    show-msg reform ["Connected to:" user/1 "on" port/remote-ip]
    insert port join me " is here."
]

is-here?: func [user /local ip] [
    if ip: select user-list user [
        foreach port next next ports [
            if ip = port/remote-ip [return port]
        ]
    ]
]

port-to-user: func [port /local user] [
    either user: find user-list port/remote-ip [first back user]["Someone"]
]

main-loop: has [port line time new] [
    time: now
    forever [
        port: wait ports
        if port [
            either port = listener [
                append ports new: first listener
                insert new join "Hello from " me
                if greeting [
                    insert new greeting
                    show-msg join "I said: " greeting
                ]
                if not find user-list new/remote-ip [time: now - 1]
            ][
                if error? try [line: first port][
                    line: reform [port-to-user port "disconnected."]
                    remove find ports port
                ]
                show-msg line
                if log-file [write/append log-file reform [now line newline]]
            ]
            if pop-to-top [win/changes: 'activate show win] 
        ]
        if now - poll-time > time [announce  time: now]
    ]
]

scroll-para: func [tf sf /local tmp][  ;!!! fix bug in View! (not - 0x30)
    if none? tf/para [exit]
    tmp: min 0x0 tf/size - (size-text tf)
    either sf/size/x > sf/size/y [tf/para/scroll/x: sf/data * first tmp] [
        tf/para/scroll/y: sf/data * second tmp]
    show tf
]

send-msg: has [line] [
    if empty? trim/all copy talk/text [exit]
    li/effect: [colorize 180.180.180]  show li

    either timestamp [
    line: rejoin [me " [" now/time "] : " talk/text]
    ][
    line: rejoin [me ": " talk/text]
    ]

    foreach p next next ports [insert p line]
    if log-file [write/append log-file reform [now line newline]]
    li/effect: none  show li
    show-msg join "I said: " talk/text
    unfocus
    clear talk/text
    talk/line-list: none
    focus talk
]

show-msg: func [txt] [
    append msg/text txt
    append msg/text newline 
    update-para
]

update-para: does [
    sld/data: 1
    show sld
    scroll-para msg sld
]

cnt: 0

win: center-face layout [
    origin 0x0 space 0x0
    backcolor black
    style menu text 50x24 white center middle bold
    here: at
    text "On-line Users:" white black bold 120x24 middle [announce]
    across
    ul: list 108x300 [
        space 0
        text 160x16 font-size 10 [toggle-user bud]
    ] supply [
        count: count + cnt
        face/text: face/color: none
        if count > length? users [return none]
        face/text: bud: pick users count
        face/font/color: either find user-list bud [black][pewter]
        if is-here? bud [face/color: yellow]
    ]
    sl: slider ul/size * 0x1 + 12x0 [
        c: to-integer value * ((length? users) - 8)
        if cnt <> c [cnt: c  show ul]
    ]
    return
    at here + 120x0 guide
    pad 6
    menu "Send" [send-msg]
    menu "Greet" [greeting: any [request-text/title/default "Greeting Message:" greeting greeting]]
    menu "Options" [alert "Need to make an option dialog. See the source!"]
    menu "Quit" [quit-prog]
    pad 186
    li: image logo.gif [browse http://www.rebol.com]
    return
    msg: area 480x250 wrap instructions
    sld: slider 12x250 [scroll-para msg sld]
    return below
    talk: field 480x50 wrap [send-msg]
]

resize-window: func [size] [
    win/size: size
    ul/size/y: sl/size/y: size/y - 24
    talk/size/x: msg/size/x: size/x - ul/size/x - sl/size/x - sld/size/x
    sld/size/y: msg/size/y: size/y - talk/size/y - 24
    talk/offset/y: msg/offset/y + msg/size/y
    sld/offset/x: msg/offset/x + msg/size/x
    li/offset/x: size/x - li/size/x
        
    show win
]

view/new/title/options win reform [system/script/header/title system/script/header/version] [resize]
deflag-face talk tabbed
insert-event-func [
    switch event/type [
        close [quit-prog]
        resize [resize-window win/size]
    ]
    event
]
focus talk
flash "Announcing presence..."
announce
unview 
open-listen
main-loop





                                                                                                                                                                                                                                                                                         