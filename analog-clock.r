REBOL [
	File: %analog-clock.r
	Date: 11-Jun-2005
	Title: "Analog Clock"
	Version: 1.1.0
	Author: "Vincent Ecuyer"
	Purpose: {Colorful clock with analog display}
	Notes: {
	    VID isn't used in this demo: all faces are made with make face [...]
    }
    History: [
        1.0.0 [28-Dec-2003 "First version"]
        1.1.0 [11-Jun-2005 "View 1.3 compatibility & Digital display fix"]
    ]
 	Library: [
 	        level: 'advanced
 	        platform: 'all
 	        type: [demo tool]
 	        domain: [sdk GUI]
 	        tested-under: [
            	view 1.2.1.3.1  on [Win2K]
            	view 1.2.1.1.1  on [AmigaOS30]
            	view 1.3.0.3.1  on [Win2K]
            	face 1.2.47.3.1 on [Win2K]
 	        ]
 	        support: none
 	        license: 'public-domain
 	        see-also: %clock.r
 	]
]

if none? system/view/event-port [
    insert system/ports/wait-list
        system/view/event-port: open make system/standard/port [
            scheme: 'event
            awake: func [port] bind [wake-event port] in system/view 'self
        ]
]

s1: m1: m2: m3: h1: h2: h3: 0x0
text-pos: 100x5

hour: form now/time
if 7 > length? hour [insert tail hour ":00"]
date: form now/date

l: make face [
    offset: 50x50
    text: hour
    size: 201x226
    color: 0.0.0
    edge: none
    feel: system/view/window-feel
    rate: 10
    pane: reduce [
        clk: make face [
            offset: 0x0
            size: 201x201
            color: 0.0.0
            edge: none
            effect: compose [
                gradient 1x1 255.255.0 255.0.0 tint
                (to-integer 6 * ((pick now/time 3) - 30))
                draw [
                    pen 255.255.0 'line-width 2
                    line c s1
                    pen 255.0.0 fill-pen 255.255.0 'line-width 1
                    polygon c m1 m2 m3
                    line c m1 m2 m3 c
                    polygon c h1 h2 h3
                    line c h1 h2 h3 c
                ] oval 0.0.0
            ]
            rate: 1
            feel: context [
                engage: func [f a e /local t v][
                    t: now/time
                    clk/effect/6: to-integer 6 * (t/second - 30)
                    s1: c + to-pair compose [
                         (to-integer rs/x * sine v: 6 * t/second)
                         (- to-integer rs/y * cosine v)
                    ]
                    m1: c + to-pair compose [
                         (to-integer rm/x * 0.85 * sine (
                             v: (6 * t/minute) + (v / 60)) - 4)
                         (- to-integer rm/y * 0.85 * cosine v - 4)
                    ]
                    m2: c + to-pair compose [
                         (to-integer rm/x * sine v)
                         (- to-integer rm/y * cosine v)
                    ]
                    m3: c + to-pair compose [
                         (to-integer rm/x * 0.85 * sine v + 4)
                         (- to-integer rm/y * 0.85 * cosine v + 4)
                    ]
                    h1: c + to-pair compose [
                         (to-integer rh/x * 0.85 * sine (
                             v: (t/hour // 12 * 30) + (v / 12)) - 4)
                         (- to-integer rh/y * 0.85 * cosine v - 4)
                    ]
                    h2: c + to-pair compose [
                         (to-integer rh/x * sine v)
                         (- to-integer rh/y * cosine v)
                    ]
                    h3: c + to-pair compose [
                         (to-integer rh/x * 0.85 * sine v + 4)
                         (- to-integer rh/y * 0.85 * cosine v + 4)
                    ]
                ]
            ]
        ]
        dgt: make face [
            offset: 0x201
            size: 201x25
            color: 0.0.0
            edge: none
            font: make face/font [style: 'bold size: 16]
            effect: [draw [
                font dgt/font
                text 5x5 hour text text-pos date
            ] gradcol 0x1 255.0.0 255.255.0]
            rate: 1
            feel: make face/feel [
                engage: func [f a e][
                    if a = 'time [
                        insert clear hour form now/time
                        if 7 > length? hour [insert tail hour ":00"]
                        date: form now/date
                        l/changes: 'text show l
                    ]
                ]
            ]
        ]
    ]
]

insert system/view/screen-face/feel/event-funcs func [face event][
    if equal? event/type 'resize [
        l/size/y: max l/size/y 25
        resize clk/size: l/size - 0x25
        dgt/size/x: l/size/x
        dgt/offset: clk/size * 0x1
        text-pos/x: max 80 dgt/size/x - 100
        show l
    ]
    return event
]

resize: func [value [pair!]][
    c: value / 2
    rs: c * 0.95
    rm: rs * 0.95
    rh: rm * 0.70
]

resize 201x201

view/options l 'resize
quit