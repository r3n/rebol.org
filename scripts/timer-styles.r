REBOL 
[
    Title: "Time Styles"
    File: %timer-styles.r
    Author: "Phil Bevan"
    Date: 13-Nov-2000/12:00:00
    Version: 1.0.0
    Purpose: {
        A simple clock & timer style 
    }

    History: [
        1.0.0   ["Initial version" "Phil Bevan"]
        ]
    Email: philb@upnaway.com
    library: [
        level: 'advanced
        platform: [all]
        type: [tool]
        domain: 'math 
        tested-under: ["view 1.2.8.3.1" "view 1.2.46.3.1"]
        support: none 
        license: none 
        see-also: none
    ]
]





f-format-time: func 
[
    {Format a time into hh:mm:ss format}
    ip-time [time!]
    /nosecs {"Do not output seconds"}
    /am-pm {"Use am-pm format"}
    /local ip-h ipm ip-s op-h op-m op-s op-time
]
[
    ip-h: ip-time/hour 
    ip-m: ip-time/minute 
    ip-s: to integer! ip-time/second 

    either am-pm
    [
        either ip-h >= 12 
        [
            op-am-pm: "pm"
            either ip-h > 12 
            [op-h: ip-h - 12]
            [op-h: ip-h]                    
        ]
        [
            op-am-pm: "am"
            either ip-h = 0 [op-h: ip-h + 12]
            [op-h: ip-h]                    
        ]

    ]
    [
        op-am-pm: ""
        either ip-h < 10
        [op-h: rejoin ["0" ip-h]]
        [op-h: ip-h]
    ]

    either ip-m < 10
    [op-m: rejoin ["0" ip-m]]
    [op-m: ip-m]

    either ip-s = 0
    [op-s: "00"]
    [
        either ip-s < 10
        [op-s: rejoin ["0" ip-s]]
        [op-s: ip-s]
    ]

    op-time: rejoin [op-h ":" op-m]
    either nosecs <> none
    [op-time: rejoin [op-time op-am-pm]]
    [op-time: rejoin [op-time ":" op-s op-am-pm]]
    return op-time
]

timer-styles: stylize 
[
    clock: vtext to string! now/time middle with
    [
        secs: true
        am-pm: false
        rate: 1
        feel: make feel 
        [
            redraw: func [f]
                [redraw: none show f]
  
            engage: func [f /local i]
            [
                either f/secs 
                [
                    either f/am-pm
                    [i: f-format-time/am-pm now/time]
                    [i: f-format-time now/time]
                ]
                [
                    either am-pm
                    [i: f-format-time/am-pm/nosecs now/time]
                    [i: f-format-time/nosecs now/time]
                ]
                f/text: i show f
            ]
        ]
    ]

    timer: tt "00:00:00" 255.255.255 shadow 1x1 with
    [
        rate: 1
        feel: make feel 
        [
            redraw: func [face]
            [
                redraw: none
                show face
            ]
  
            engage: func [f]
            [
                if f/ti-stop = false
                [
                    f/ti-gap: now/time - f/ti-pause
                    if f/ti-gap > 0:00:00
                    [
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
        
        ; start-stop timer
        f-start-stop: func 
        [
            {start/stop the timer}
            face
            /local curr-time
        ] 
        [
            curr-time: now/time
            either face/ti-stop = true 
            [
                face/ti-stop: false
                face/ti-pause: curr-time
            ]
            [
                face/ti-stop: true 
                face/ti-tot: face/ti-tot + (curr-time - face/ti-pause)
            ]
        ]

    ]
]


;
; demo clocks/timer styles
;

view layout
[
    styles timer-styles
    origin 5x5
    backdrop 0.100.0

    across    


    text "The time is : " font-size 30
    clock font-size 30 bold with [am-pm: true] 200
    return

    timer-1: timer font-size 60 bold 100.200.0 0.0.80 center 400x80

    toggle with [texts: ["Start" "Stop"] colors: [0.150.100 150.20.20]] 60x80
        [timer-1/f-start-stop timer-1]
    return
    

    timer-2: timer 200.0.0 55.255.255 center

    toggle with [texts: ["Start" "Stop"] colors: [0.150.100 150.20.20]] 60x24
        [timer-2/f-start-stop timer-2]
    return

] 


view layout
[
    styles timer-styles
    origin 5x5
    backdrop 0.100.0

    below   
    clock font-size 12
    clock font-size 14
    clock font-size 16
    clock font-size 18
    clock font-size 20
    clock font-size 22
    clock font-size 24
    clock font-size 26
    clock font-size 28
    clock font-size 30
    return
    clock font-size 12 255.255.0
    clock font-size 14 255.235.0
    clock font-size 16 255.215.0
    clock font-size 18 255.195.0
    clock font-size 20 255.175.0
    clock font-size 22 255.155.0
    clock font-size 24 255.135.0
    clock font-size 26 255.115.0
    clock font-size 28 255.95.0
    clock font-size 30 255.75.0
    return
    clock font-size 12 0.0.0    0.255.0
    clock font-size 14 0.0.0    0.240.30
    clock font-size 16 0.0.0    0.210.60
    clock font-size 18 0.0.0    0.180.90
    clock font-size 20 0.0.0    0.150.120
    clock font-size 22 0.0.0    0.120.150
    clock font-size 24 0.0.0    0.90.180
    clock font-size 26 0.0.0    0.60.210
    clock font-size 28 0.0.0    0.30.240
    clock font-size 30 0.0.0    0.0.255
    return
] 


view layout
[
    styles timer-styles
    origin 5x5
    backdrop 0.100.0

    across    
    tim00: timer font-size 12     
    toggle with [texts: ["Start" "Stop"] colors: [0.150.100 150.20.20]] 40x24
        [tim00/f-start-stop tim00]
    return

    tim01: timer font-size 16     
    toggle with [texts: ["Start" "Stop"] colors: [0.150.100 150.20.20]] 40x24
        [tim01/f-start-stop tim01]
    return

    tim02: timer font-size 20 bold
    toggle with [texts: ["Start" "Stop"] colors: [0.150.100 150.20.20]] 40x24
        [tim02/f-start-stop tim02]
    return

    tim03: timer font-size 24 bold
    toggle with [texts: ["Start" "Stop"] colors: [0.150.100 150.20.20]] 40x24
        [tim03/f-start-stop tim03]
    return

    tim04: timer font-size 28 bold
    toggle with [texts: ["Start" "Stop"] colors: [0.150.100 150.20.20]] 40x24
        [tim04/f-start-stop tim04]
    return

    tim05: timer font-size 32 bold
    toggle with [texts: ["Start" "Stop"] colors: [0.150.100 150.20.20]] 40x24
        [tim05/f-start-stop tim05]
    return

    tim06: timer font-size 36 bold
    toggle with [texts: ["Start" "Stop"] colors: [0.150.100 150.20.20]] 40x24
        [tim06/f-start-stop tim06]
    return

    tim07: timer font-size 40 bold
    toggle with [texts: ["Start" "Stop"] colors: [0.150.100 150.20.20]] 40x24
        [tim07/f-start-stop tim07]
    return

    tim08: timer font-size 44 bold
    toggle with [texts: ["Start" "Stop"] colors: [0.150.100 150.20.20]] 40x24
        [tim08/f-start-stop tim08]
    return

    tim09: timer font-size 48 bold
    toggle with [texts: ["Start" "Stop"] colors: [0.150.100 150.20.20]] 40x24
        [tim09/f-start-stop tim09]

    return
] 
