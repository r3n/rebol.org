REBOL [
    Title: "Chatter"
    Date: 14-Mar-2002/17:48:17-8:00
    Version: 0.9.0
    File: %chatter.r
    Author: "Ryan Cole"
    Purpose: {Chat using UDP broadcasts across your internal network.  No setup required!}
    Email: ryanc@iesco-dms.com
    library: [
        level: none 
        platform: none 
        type: none 
        domain: 'tcp 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

udp-in: open udp://:9905
udp-out: open/lines udp://255.255.255.255:9905
set-modes udp-out [broadcast: on]

name: request-text/title "Enter your name:"
insert udp-out reform [name "is here."]

scroll: function [tf sf] [tmp] [
    tmp: min 0x0 tf/size - (size-text tf)
    either sf/size/x > sf/size/y [tf/para/scroll/x: sf/data * first tmp] [
        tf/para/scroll/y: sf/data * tmp/y]
    show [tf sf]
]

win: view/new layout [
    backcolor silver
    origin 4x4
    guide heard: area white 290x100 wrap font-size 10
    talk: field 260x32 wrap font-size 10
    at 0x0 key #"^M" [
        if empty? talk/text [exit]
        insert udp-out rejoin [name ":  " talk/text]
        clear talk/text
    ]
    return pad -8x0
    sld: slider 10x100 [scroll heard sld]
]

forever [
    focus talk
    conn: wait [udp-in]
    if not viewed? win [
        insert udp-out reform [name "left."]
        quit
    ]
    append heard/text copy conn
    sld/data: 1
    scroll heard sld
]                                                 