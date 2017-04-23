REBOL [
    title: "VID Shooter"
    date: 6-Mar-2010
    file: %vid-shooter.r
    author:  Nick Antonaccio
    purpose: {
        A simple shooter game to demonstrate timer events and offsets in VID.        
        Taken from the tutorial at http://re-bol.com
    }
]

score: 0   speed: 10   lives: 5   fire: false   random/seed now/time
alert "[SPACE BAR: fire] | [K: move left] | [L: move right]"
do game: [
    view center-face layout [
        size 600x440
        backdrop black
        at 246x0 info: text tan rejoin ["Score: " score " Lives: " lives]
        at 280x440 x: box 2x20 yellow
        at (as-pair -50 (random 300) + 30) y: btn 50x20 orange
        at 280x420 z: btn 50x20 blue
        box 0x0 #"l" [z/offset: z/offset + 10x0 show z]
        box 0x0 #"k" [z/offset: z/offset + -10x0 show z]
        box 0x0 #" " [
            if fire = false [
                fire: true 
                x/offset: as-pair (z/offset/1 + 25) 440
            ]
        ]
        box 0x0 rate speed feel [
            engage: func [f a e] [
                if a = 'time [
                    if fire = true [x/offset: x/offset + 0x-30]
                    if x/offset/2 < 0 [x/offset/2: 440  fire: false]
                    show x
                    y/offset: y/offset + as-pair 
                        ((random 20) - 5) ((random 10) - 5)
                    if y/offset/1 > 600 [
                        lives: lives - 1
                        if lives = 0 [
                            alert join "GAME OVER!!! Final Score: " score
                            quit
                        ]
                        alert "-1 Life!"   unview   do game
                    ]
                    show y
                    if within? x/offset (y/offset - 5x5) 60x30 [
                        alert "Ka-blammmm!!!"
                        score: score + 1   speed: speed + 5  fire: false
                        unview   do game
                    ]
                ]
            ]
        ]
    ]
]