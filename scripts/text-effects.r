REBOL [
    Title: "Text effect styles"
    Date: 1-Oct-2001/19:05:14+2:00
    Version: 1.0.0
    File: %text-effects.r
    Author: "Oldes"
    Purpose: "This version contains just 'sine-text style..."
    Comment: {see the example script: http://sweb.cz/r-mud/examples/sine-text.r}
    Email: oliva.david@seznam.cz
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'Demo 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

text-effects-ss: stylize [
    sine-text: box 100x100 rate 50 feel [
        engage: func [f a e][if a = 'time [f/redraw]]
    ] with [
        transposition: 0
        amplitude: 40
        frequency: 1
        move: -1
        text-length: 0
        start-offset: 0x0
        text-style: [banner with [para/origin: para/margin: font/offset: 0x0]] 
        redraw: func[][
            if move = 0 [
                transposition: transposition + 1
                if transposition >= 360 [transposition: 0]
            ]
            foreach f pane [
                f/offset/x: f/offset/x + move
                either f/offset/x >= (text-length - f/size/x) [
                    f/offset/x: 0 - f/size/x
                ][  if f/offset/x <= (0 - f/size/x) [
                    f/offset/x: text-length + f/offset/x]
                ]
                if (f/offset/x < size/x) and (f/offset/x > -20) [
                    f/offset/y: amplitude + (
                        amplitude * (sine (transposition + (f/offset/x * frequency)))
                    )
                ]
            ]
            show self
        ]
        set-text: func [str /local ch lay tmp][
            lay: make block! []
            append lay compose [
                style p (text-style)
                origin 0x0
                across space 0x0
            ]
            forall str [
                ch: to-string str/1
                repend lay either ch = " " [['pad 5x0]][[ 'p copy ch]]
            ]
            tmp: layout lay
            foreach f tmp/pane [
                f/offset/x: f/offset/x + start-offset/x
            ]
            
            pane: tmp/pane
            tmp: last pane
            text-length: tmp/offset/x + tmp/size/x
            redraw
        ]
        init: [
            set-text text
            text: none
        ]
    ]
]                                                                     