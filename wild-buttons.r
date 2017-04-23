REBOL [
    Title: "Wild Buttons"
    Date: 7-Jun-2001
    Version: 1.0.1
    File: %wild-buttons.r
    Author: "Bohdan Lechnowsky"
    Purpose: {To demonstrate some easy visual button effects with REBOL/View.}
    Comment: {
^-^-added center-face so title bar displays in Windows
^-^--Larry Palmiter
^-}
    Email: larry@ecotope.com
    library: [
        level: 'beginner 
        platform: none 
        type: 'Demo 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

button: make face [
    edge: make edge [size: 10x10]
    font: make font [
        color: 255.255.255
        size: 12
        align: 'center
        valign: 'center
    ]
    para: make para []
    feel: make feel []
]

pairs: [1x1 1x0 1x-1 0x-1 -1x-1 -1x0 -1x1 0x1]
epairs: pairs
button: make button [
    feel: make feel [
        engage: func [face act evt][
            pairs: next pairs
            epairs: back epairs
            if tail? pairs [pairs: head pairs]
            button/effect: reduce ['gradient to-pair first pairs 0.0.255]
            button/edge/effect: reduce ['gradient to-pair first epairs 255.0.0]
            if head? epairs [epairs: tail pairs]
            switch act [up [unview/all]]
            show button
        ]
    ]
    rate: 10    ;10 frames per second
    text: "Rotating gradient - Click me to continue"
]
view center-face make face [size: button/size pane: button edge: make edge [size: 0x0]]

button/text: "No title bar - Click me to continue"
view/options center-face make face [offset: 3x23 size: button/size pane: button edge: make edge [size: 0x0]] 'no-title

button/text: "No title bar or border - Click me to continue"
view/options center-face make face [size: button/size pane: button edge: make edge [size: 0x0]] [no-title no-border]

button/text: "Window is resizable - Click me to continue"
view/options center-face make face [size: button/size pane: button edge: make edge [size: 0x0]] [resize]

col: 90
dir: 40
stops: [255 155]
button: make button [
    offset: 0x0
    effect: none
    image: none
    edge: make edge [
        effect: none
        image: none
    ]
    feel: make feel [
        engage: func [face act evt][
            button/edge/color: to-tuple reduce [col 0 0]
            button/color: 255.0.0 - button/edge/color
            col: col + dir
            if any [col < 90 col > stops/1][
                dir: negate dir
                if col < 90 [
                    stops: next stops
                    if tail? stops [stops: head stops]
                ]
                col: col + dir
            ]
            switch act [up [unview/all]]
            show button
        ]
    ]
    rate: 20    ;20 frames per second
    text: "Does REBOL/View make your heart race?"
]
view center-face make face [size: button/size pane: button edge: make edge [size: 0x0]]
