Rebol [
    title: "Simple Image Distort"
    date: 29-june-2008
    file: %draw-distort.r
    purpose: {
        How to distort an image using the draw dialect.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

pos: 300x300
view layout [
    scrn: box pos black effect [
        draw [image logo.gif 0x0 300x0 300x300 0x300
    ]]
    btn "Animate" [
        for point 1 140 1 [
            scrn/effect/draw: copy reduce [
                'image logo.gif 
                (pos - 300x300)
                (1x1 + (to-pair rejoin ["300x" point]))
                (pos - (to-pair rejoin ["1x" point]))
                (pos - 300x0)
            ]
            show scrn
        ]
        for point 1 300 1 [
            scrn/effect/draw: copy reduce [
                'image logo.gif 
                (1x1 + (to-pair rejoin ["1x" point]))
                (pos - 0x300)
                (pos - 0x0)
                (pos - (to-pair rejoin [point "x1"]))
            ]
            show scrn
        ] 
        scrn/effect/draw: copy [
            image logo.gif 0x0 300x0 300x300 0x300
        ]
        show scrn
    ]
]