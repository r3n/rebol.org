REBOL [
    Title: "Messenger"
    Date: 25-May-2001/0:32
    Version: 1.0.3
    File: %rebalert.r
    Author: "P Bevan"
    Purpose: "Display a Reminder at a specified time"
    Email: philb@upnaway.com
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

flash "Fetching image..."
pic: load read-thru/to http://www.rebol.com/view/demos/nyc.jpg %nyc.jpg
unview

scroll-left: function [str] [t-str]
[
    t-char: first str
    t-str: remove str
    t-str: join t-str t-char
    return t-str
]

; center-txt: txt center font-size 16

l-test: stylize 
    [ltext: vtext font-size 60 right 255.255.0]

f-disp-msg: function [t-mess] []
[
    t-mess: join "...." [t-mess "...."]
    view/new layout 
    [
        styles l-test
        backdrop pic effect [gradcol 1x1 0.0.80 100.0.0 fit]
        time: ltext t-mess
        with 
        [
            rate: 2
            feel: make feel 
            [
                engage: func [face action event i] 
                [
                    face/text: scroll-left face/text
                    show face
                ]
            ]
        ]
    ]
]


f-wait: function [i-time t-mess] [u-time t-time tm-time]
[
    t-time: join "Waiting until " i-time
    u-time: to-time i-time
    
    view/new layout 
    [
        backdrop pic effect [gradcol 1x1 0.0.80 100.0.0 fit] 
        c-time: vtext "Time : 00:00:00"
        with 
        [
            rate: 1
            feel: make feel 
            [
                engage: func [face action event i] 
                [
                    if u-time < now/time
                    [
                        unview/all
                        f-disp-msg t-mess
                    ]
                    ; show current time
                    tm-time: to-string now/time
                    either (length? tm-time) < 6 
                        [c-time/text: join "Time : " [tm-time ":00"]]
                        [c-time/text: join "Time : " tm-time]
                    show face
                ]
            ]
        ]
        text t-time
    ]
]


t-time: to-string now/time

view layout
[
    backdrop pic effect [gradcol 1x1 0.0.80 100.0.0 fit]
    t-mess: field ""
    t-time: field t-time 60x24
    button "OK" 60x24 
        [
            either (to-time t-time/text) = none
            [
                unfocus
                inform/offset layout [label "Invalid time entered"] 100x100
            ]
            [
                unfocus
                unview/all
                f-wait t-time/text t-mess/text
            ]
        ]
]
