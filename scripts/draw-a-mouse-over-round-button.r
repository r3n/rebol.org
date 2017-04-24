REBOL [
    Title: "Draw A Mouse Over Round Button"
    Date: 12-Feb-2006
    Name: "Draw A Mouse Over Round Button"
    Version: 1.1.1
    File: %draw-a-mouse-over-round-button.r
    Author: "R. v.d.Zee"
    Owner: "R. v.d.Zee"
    Rights: "Copyright (C) R. v.d.Zee 2008"
    Needs: ["REBOL/View 1.3.2.3.1 5-Dec-2005 Core 2.6.3"]
    Tabs: 4
    Purpose: {draw a round button with a mouse over effect}
    History:   [
        1.1.0  [12-Feb-2006 "Created"] 
        1.1.1  [12-Mar-2008 {revised proportions, 
        use in-built logo.gif, change script style
        add engage to button, add scroller colors}
        ]
    ]
    Library: [
        level: 'beginner
        platform: 'all 
        type: [reference tutorial]
        domain: [GUI] 
        tested-under: 'XP
        support: none 
        license: none 
        see-also: none
    ]
    Language: 'English
]

button-font: make face/font [style: [italic bold] size: 20]

pen-color: gold 
fill-color: leaf
round-button: [
   line-width 3
    pen pen-color
    fill-pen fill-color
    circle 23x23 20
    pen gold
    font button-font text "R" 15x10
]


coal-face: layout [
    size 420x430
    backcolor coal
    backeffect [grid 5x5 coffee]
    across
    origin 180x10
    button-box: box 47x46 effect [draw round-button] feel [
        engage: func [face action event] [
            if action = 'down [
                fill-color: coffee
                face/effect: [draw round-button]
                show face
                write clipboard:// code-info/text
            ]

        ]
        over: func [face act pos] [
            pen-color: either act [red] [gold]
            fill-color: either act [green][leaf]
            face/effect: [draw round-button]
            show face
         ] 
    ] 
    return
    space 0
    pad -160x5
    code-info: info 350x313 coal font-color green wrap with [
        edge/effect: none
        edge/size: 1x1
        edge/color: coffee
    ]
    info-scroll: scroller 16x313 orange - 90 [
        scroll-para code-info info-scroll
    ]
    return
    pad 150x10
    logo: image orange - 90 logo.gif
]

codeIn: read script
codeIn: find codeIn "button-font:"

insert codeIn rejoin [
     "Purpose: " rebol/script/header/purpose newline  
     "- a left mouse-click pastes the area text to the clipboard" 
     "^/" "^/"
]
code-info/text: codeIn
code-info/para/origin: 10x5
coal-face/offset: 0x27

;    set initial color of arrows, colors change with mouse click
info-scroll/pane/2/effect/3: info-scroll/pane/3/effect/3: 255.0.10

;    could not change effect
;info-scroll/pane/2/edge/effect: info-scroll/pane/3/edge/effect: 'bevel

;    top and bottom scroller arrow box
info-scroll/pane/2/edge/color: info-scroll/pane/3/edge/color: coffee

;    dragger edge and dragger color
info-scroll/pane/1/color: coffee
info-scroll/pane/1/edge/color: red

;    arrow box colors, must use tuples
info-scroll/pane/2/colors: info-scroll/pane/3/colors: [76.26.0 255.0.10]

;    scale in-built logo image
logo/size: logo/size * .6

view coal-face
