REBOL [
    Title: "'Progress bar capsule' styles"
    Date: 7-Oct-2001/13:36:21+2:00
    Version: 1.0.0
    File: %progress-c.r
    Author: "Oldes"
    Purpose: {This style allows you to create progress bar as a 'capsule' with a grid in your layouts very simply. See the example script: http://sweb.cz/r-mud/examples/progress-c.r}
    Comment: {
^-^-Make sure you have loaded the 'capsule' style as well!
^-^-(http://www.sweb.cz/r-mud/styles/capsules.r)}
    Email: oliva.david@seznam.cz
    library: [
        level: 'advanced 
        platform: none 
        type: 'module 
        domain: [GUI VID] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
progress-ss: stylize [
    progress-capsule: box 200x1 feel [
        redraw: func [f a p][
            f/data: max 0 min 1 f/data
            if f/data <> f/state [
                either f/size/x > f/size/y [
                    f/c2/size/x: max 0 f/data * f/c1/size/x
                ] [
                    f/c2/size/y: max 0 (1 - f/data) * f/c1/size/y
                ]
                f/state: f/data
                show f/c2
            ]
        ]
    ] with [
        data: 0
        color: none
        site: http://www.sweb.cz/r-mud/
        caps-image: site/imgz/capsules/bryce3.gif
        sock-source: site/imgz/sockets/bryce3.bin
        sock-color: 170.185.165
        sock-edge: 3x3
        effects: [
            [effect [multiply 170.60.0 tint -20 contrast 15 sharpen 2] 'image caps-image]
            [effect [multiply 220.120.0 tint -30 contrast 15] 'image caps-image]
        ]
        c1: c2: sock: none
        grids: 17
            
        get-pane: func[/local tmp get-capsule gs grid][
            get-capsule: func[ef /local lay][
                lay: make block! compose [
                    styles capsules
                    backdrop 0.0.0 origin 0x0
                    capsule (size)
                ]
                layout append lay ef
            ]
            gs: [0x0 0x0]
            either size/x > size/y [
                c1: get-capsule effects/1
                c2: get-capsule effects/2
                size/y: c1/size/y
                gs/1/x: size/x / grids
                gs/2/x: gs/1/x / 2              
            ][
                c1: get-capsule effects/2
                c2: get-capsule effects/1
                size/x: c1/size/x
                gs/1/y: size/y / grids
                gs/2/y: gs/1/y / 2      
            ]
            grid: make face compose/deep [
                size: (size) 
                color: 0.0.0
                edge: none
                effect: [grid (gs/1) (gs/2) 30.30.30]
            ]
            tmp: layout compose/deep [
                styles capsules
                origin 0x0
                sock: socket (size + (2 * sock-edge)) 'depth 3 'source (sock-source) (sock-color)
                at (sock-edge)
                c1: image (to-image c1) effect [difference ( to-image grid) key 0.0.0]
                at (sock-edge)
                c2: image (to-image c2) effect [difference ( to-image grid) key 0.0.0]
            ]
            reduce [sock c1 c2]
        ]
        init: [
            pane: get-pane
            size: sock/size
            either size/x > size/y [
                c2/size/x: data * c2/size/x
            ][  c2/size/y: (1 - data) * c2/size/y]
        ]
    ]
]                                                                                          