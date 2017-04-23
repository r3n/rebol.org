REBOL 
[
    Title:   "Timer"
    Date:    06/10/2005
    File:    %timer-style.r
    Version: 1.1
    Author: "Phil Bevan"
    email: phil.bevan@gmail.com
    Purpose: "A simple Timer Style .... with an example of Timer with Saving & Loading"            
    Library: [
        level: 'intermediate
        platform: 'all
        type: [demo]
        domain: [vid]
        tested-under: "View 1.3.1.3.1"
        support: none
        license: none
        see-also: none
    ]
    Changes: [
        1.0 - Initial Version
        1.1 - Deal correctly when time goes past midnight
    ]
 ]

; functions for timers
f-format-time: func [
    {Format a time into hh:mm:ss format}
    ip-time [time!]
    /local ip-h ipm ip-s op-h op-m op-s op-time
][
    ip-h: ip-time/hour 
    ip-m: ip-time/minute 
    ip-s: ip-time/second 
    either ip-h < 10
    [op-h: join "0" to-string ip-h]
    [op-h: to-string ip-h]

    either ip-m < 10
    [op-m: join "0" to-string ip-m]
    [op-m: to-string ip-m]

    either ip-s = 0
    [op-s: "00"] [
        either ip-s < 10
        [op-s: join "0" to-string to integer! ip-s]
        [op-s: to-string to integer! ip-s]
    ]
    op-time: rejoin [op-h ":" op-m ":" op-s]
    return op-time
]

; reset timer
f-timer-reset: func [
    {reset the timer}
    face
][
    face/ti-tot: 0:00:00
    face/ti-gap: 0:00:00
    face/ti-pause: now
    face/text: f-format-time 0:00:00
    show face
]

f-timer-elapsed: func [{reset the timer} face][
    face/ti-tot + face/ti-gap
]


; start timer
f-timer-start: func [{start/stop the timer} face][
    if face/ti-stop = true [
        face/ti-pause: now
        face/ti-stop: false
    ]
]

; stop timer
f-timer-stop: func [{stop the timer} face][
    face/ti-stop: true 
    face/ti-tot: face/ti-tot + ((now/date - face/ti-pause/date) * 24:00:00) + (now/time - face/ti-pause/time)
]


; Styles
fixed-styles: stylize
[
    fix-area: area font [name: "courier new" size: 12] wrap
    fix-field: field font [name: "courier new" size: 12]
    fix-text: text font [name: "courier new" size: 12]
] 

timer-styles: stylize 
[
    timer: tt "00:00:00" 255.255.255 shadow 1x1 with
    [
        rate: 1
        feel: make feel [
            redraw: func [face][
                redraw: none
                show face
            ]
  
            engage: func [f][
                if f/ti-stop = false [
                    f/ti-gap: (now/date - f/ti-pause/date) * 24:00:00 + (now/time - f/ti-pause/time)
                    if f/ti-gap > 0:00:00 [
                        i: f-format-time f/ti-tot + f/ti-gap
                        f/text: i
                        show f
                    ]
                ]
            ]
        ]

        ti-tot: 0:00:00
        ti-gap: 0:00:00
        ti-pause: 0:00:00
        ti-stop: true
    ]
]

lay: layout [
        styles timer-styles
        origin 0x0
        at 0x0
        space 0
        backdrop 0.100.0
        across
        timer-1: timer center 240x24 font-size 18 bold shadow 2x2 wheat 0:00:00
        return
        btn 60 "Start" [f-timer-start timer-1]
        btn 60 "Stop" [f-timer-stop timer-1]
        btn 60 "Save" [
            write %curr-time.txt f-format-time f-timer-elapsed timer-1
            quit
        ]
        btn 60 "Reset" [
            write %curr-time.txt "0:00:00"
            f-timer-reset timer-1
            f-timer-stop timer-1
        ]
        return
] 

either exists? %curr-time.txt
    [tm: to time! read %curr-time.txt]
    [tm: 0:00:00]
timer-1/text: f-format-time tm
timer-1/ti-tot: tm

view center-face lay