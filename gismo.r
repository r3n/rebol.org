REBOL [
    Title: "GISMo - Graphical Internet Server Monitor"
    File: %gismo.r
    Version: 1.1.0
    Date: 6-Nov-2005
    Author: "Carl Sassenrath"
    Purpose: {Graphical Internet server monitor, as posted in the REBOL cookbook, found
        at http://www.rebol.net/cookbook/ - See that for more notes.}
    Needs: [view 1.3.1]
    Library: [
        level: 'intermediate
        platform: 'all
        type: 'tool
        domain: [http other-net]
        tested-under: none
        support: none
        license: none
        see-also: none
        ]
]

time-out: 5  ; Seconds to wait for the connection (adjust it!)
poll-time: 0:10:00

system/schemes/default/timeout: time-out
system/schemes/http/timeout: time-out

sites: [
    ; List of URLs (http or tcp are allowed)
    http://www.rebol.com
    http://www.rebol.net
    http://mail.rebol.net
    http://mail.rebolot.com
    tcp://www.altme.com:5400
]

foreach site sites [
    ; Convert any http to tcp on port 80
    if find/match site http:// [
        insert remove/part site 7 tcp://
        append site ":80"
    ]
]

img: make image! [200x40 0.0.0.255]
draw img [
    pen coal
    fill-pen linear 0x0 0 44 89 1 1 silver gray coal silver
    box 8.0 0x0 199x39
]

out: [backeffect [gradient 0x1 black coal]]
foreach site sites [
    port: make port! site
    append out compose/deep [
        image img (port/host) [check-site face] [browse face/data]
        with [data: (site)]
    ]
]

append out [
    pad 50x0
    btn water 100 "Refresh" rate poll-time feel [
        engage: func [f a e] [if find [time down] a [check-sites]]
    ]
]

color-face: func [face color] [
    face/effect: reduce ['colorize color]
    show face
]

check-site: func [face] [
    color-face face gray
    color-face face either attempt [close open face/data true][green][red]
]

check-sites: does [
    foreach face out/pane [
        if face/style = 'image [check-site face]
    ]
]

out: layout out
view/new out
check-sites
do-events
