Rebol [
    title: "Simple Draw Animation Controls"
    date: 29-june-2008
    file: %draw-controls.r
    purpose: {
        How to move graphics around the screen using the draw dialect.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

pos: 200x200
view layout [
    scrn: box 400x400 black rate 0:0:0.1 feel [
        engage: func [face action event] [
            if action = 'time [
                scrn/effect/draw: copy []
                append scrn/effect/draw [circle pos 20]
                show scrn
            ]   
        ] 
    ] effect [ draw [] ]
    across
    btn "Up" [pos/y: pos/y - 10]
    btn "Down" [pos/y: pos/y + 10]
    btn "Right" [pos/x: pos/x + 10]
    btn "Left" [pos/x: pos/x - 10]
]