REBOL [
    File: %snake-game.r
    Date: 19-Aug-2009
    Title: "Snake Game"
    Author:  Nick Antonaccio
    Purpose: {
        A little graphic game.  
        Taken from the tutorial at http://musiclessonz.com/rebol.html
    }
]

snake: to-image layout/tight [button red 10x10]
food: to-image layout/tight [button green 10x10]
the-score: 0  direction: 0x10  newsection: false  random/seed now
rand-pair: func [s] [
    to-pair rejoin [(round/to random s 10) "x" (round/to random s 10)]
]
b: reduce [
    'image food ((rand-pair 190) + 50x50) 
    'image snake ((rand-pair 190) + 50x50)
]
view center-face layout/tight gui: [
    scrn: box white 300x300 effect [draw b] rate 15 feel [
        engage: func [f a e] [
            if a = 'key [
                if e/key = 'up [direction: 0x-10]
                if e/key = 'down [direction: 0x10]
                if e/key = 'left [direction: -10x0]
                if e/key = 'right [direction: 10x0]
            ]
            if a = 'time [
                if any [b/6/1 < 0 b/6/2 < 0 b/6/1 > 290 b/6/2 > 290] [
                    alert "You hit the wall!" quit
                ]
                if find (at b 7) b/6 [alert "You hit yourself!" quit] 
                if within? b/6 b/3 10x10 [
                    append b reduce ['image snake (last b)]
                    newsection: true
                    b/3: (rand-pair 290)
                ]
                newb: copy/part head b 5  append newb (b/6 + direction)
                for item 7 (length? head b) 1 [
                    either (type? (pick b item) = pair!) [
                        append newb pick b (item - 3)
                    ] [
                        append newb pick b item
                    ]
                ]
                if newsection = true [
                    clear (back tail newb)
                    append newb (last b)
                    newsection: false
                ]
                b: copy newb
                show scrn
                the-score: the-score + 1 
                score/text: to-string the-score
            ]
        ]
    ]
    origin across h2 "Score:" 
    score: h2 bold "000000"
    do [focus scrn]
]