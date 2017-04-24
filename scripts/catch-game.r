REBOL [
    title: "Catch Game"
    date: 30-Apr-2010
    file: %catch-game.r
    author:  Nick Antonaccio
    purpose: {
        A tiny game to demonstrate the basics of VID.
        Taken from the tutorial at http://re-bol.com
    }
]

alert "Arrow keys move left/right (up: faster, down: slower)"
random/seed now/time   speed: 11   score: 0
view center-face layout [
    size 600x440   backdrop white   across
    at 270x0 text "Score:"  t: text bold 100 (form score)
    at 280x20  y: btn 50x20 orange
    at 280x420 z: btn 50x20 blue
    key keycode [left] [z/offset: z/offset - 10x0  show z]
    key keycode [right]  [z/offset: z/offset + 10x0  show z]
    key keycode [up]  [speed: speed + 1]
    key keycode [down]  [if speed > 1 [speed: speed - 1]]
    box 0x0 rate 0 feel [engage: func [f a e] [if a = 'time [
        y/offset: y/offset + (as-pair 0 speed)  show y
        if y/offset/2 > 440 [
            y/offset: as-pair (random 550) 20   show y
            score: score - 1
        ]
        if within? z/offset (y/offset - 50x0) 100x20 [
            y/offset: as-pair (random 550) 20   show y
            score: score + 1
        ]
        t/text: (form score)  show t
    ]]]
]