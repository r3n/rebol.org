Rebol [
    title: "Textris"
    date: 29-june-2008
    file: %textris.r
    author: Nick Antonaccio
    purpose: {
        The game of Tetris, in text mode.  
        Taken from the tutorial at http://musiclessonz.com/rebol_tutorial.html
    }
]

tui: func [commands [block!]] [
    string: copy ""
    cmd: func [s][join "^(1B)[" s]
    arg: parse commands [
        any [
            'clear (append string cmd "J") |
            'up    set arg integer! (append string cmd [
                arg "A"]) |
            'down  set arg integer! (append string cmd [
                arg "B"]) |
            'right set arg integer! (append string cmd [
                arg "C"]) |
            'left  set arg integer! (append string cmd [
                arg "D"]) |
            'at   set arg pair! (append string cmd [
                arg/x ";" arg/y "H" ]) |
            set arg string! (append string arg)
        ]
        end
    ]
    string
]

shape: [
    ["####"]
    ["#" down 1 left 1 "#" down 1 left 1 "#" down 1 left 1 "#"]
    ["###" down 1 left 2 "#"]
    [right 1 "#" down 1 left 2 "##" down 1 left 1 "#"]
    [right 1 "#" down 1 left 2 "###"]
    ["#" down 1 left 1 "##" down 1 left 2 "#"]
    ["###" down 1 left 3 "#"]
    ["##" down 1 left 1 "#" down 1 left 1 "#"]
    [right 2 "#" down 1 left 3 "###"]
    ["#" down 1 left 1 "#" down 1 left 1 "##"]
    ["###" down 1 left 1 "#"]
    [right 1 "#" down 1 left 1 "#" down 1 left 2 "##"]
    ["#" down 1 left 1 "###"]
    ["##" down 1 left 2 "#" down 1 left 1 "#"]
    ["##" down 1 left 1 "##"]
    [right 1 "#" down 1 left 2 "##" down 1 left 2 "#"]
    [right 1 "##" down 1 left 3 "##"]
    ["#" down 1 left 1 "##" down 1 left 1 "#"]
    ["##" down 1 left 2 "##"]
    ;
    ["    "]
    [" " down 1 left 1 " " down 1 left 1 " " down 1 left 1 " "]
    ["   " down 1 left 2 " "]
    [right 1 " " down 1 left 2 "  " down 1 left 1 " "]
    [right 1 " " down 1 left 2 "   "]
    [" " down 1 left 1 "  " down 1 left 2 " "]
    ["   " down 1 left 3 " "]
    ["  " down 1 left 1 " " down 1 left 1 " "]
    [right 2 " " down 1 left 3 "   "]
    [" " down 1 left 1 " " down 1 left 1 "  "]
    ["   " down 1 left 1 " "]
    [right 1 " " down 1 left 1 " " down 1 left 2 "  "]
    [" " down 1 left 1 "   "]
    ["  " down 1 left 2 " " down 1 left 1 " "]
    ["  " down 1 left 1 "  "]
    [right 1 " " down 1 left 2 "  " down 1 left 2 " "]
    [right 1 "  " down 1 left 3 "  "]
    [" " down 1 left 1 "  " down 1 left 1 " "]
    ["  " down 1 left 2 "  "]
]
floor:  [
    21x5 21x6 21x7 21x8 21x9 21x10 21x11 21x12 21x13 21x14 21x15
]
oc:  [ 
    [0x0 0x1 0x2 0x3] [0x0 1x0 2x0 3x0] [0x0 0x1 0x2 1x1]
    [0x1 1x0 1x1 2x1] [0x1 1x0 1x1 1x2] [0x0 1x0 1x1 2x0]
    [0x0 0x1 0x2 1x0] [0x0 0x1 1x1 2x1] [0x2 1x0 1x1 1x2]
    [0x0 1x0 2x0 2x1] [0x0 0x1 0x2 1x2] [0x1 1x1 2x0 2x1]
    [0x0 1x0 1x1 1x2] [0x0 0x1 1x0 2x0] [0x0 0x1 1x1 1x2]
    [0x1 1x0 1x1 2x0] [0x1 0x2 1x0 1x1] [0x0 1x0 1x1 2x1]
    [0x0 0x1 1x0 1x1] 
]
width: [4 1 3 2 3 2 3 2 3 2 3 2 3 2 3 2 3 2 2]
score: 0

prin tui [clear]
a-line: copy [] loop 11 [append a-line " "] 
a-line: rejoin ["   |"  to-string a-line "|"]
loop 20 [print a-line] prin "   " loop 13 [prin "+"] print ""
print tui compose [
    at 4x21 "TEXTRIS" at 5x21 "-------" 
    at 7x20 "Use arrow keys" at 8x20 "to move/spin."
    at 10x20 "'P' = pause"
    at 13x20 "SCORE:  " (to-string score)
]

keys: open/binary/no-wait [scheme: 'console]
forever [
    random/seed now
    r: random 19
    xpos: 9
    for i 1 20 1 [
        pos: to-pair rejoin [i "x" xpos]
        do compose/deep [prin tui [at (pos)] print tui shape/(r)]
        old-r: r
        old-xpos: xpos 
        if not none? wait/all [keys :00:00.30] [
            switch/default to-string copy keys [
                "p" [
                    print tui [
                        at 23x0 "Press [Enter] to continue"
                    ]
                    ask ""
                    print tui [
                        at 24x0 "                              "
                        at 23x0 "                              "
                    ]
                ]
                "^[[D" [if (xpos > 5) [
                        xpos: xpos - 1
                ]]
                "^[[C" [if (xpos < (16 - compose width/(r))) [
                        xpos: xpos + 1
                ]]
                "^[[A" [if (xpos < (16 - compose width/(r)))  [
                        switch to-string r [
                            "1" [r: 2]
                            "2" [r: 1]
                            "3" [r: 6]
                            "4" [r: 3]
                            "5" [r: 4]
                            "6" [r: 5]
                            "7" [r: 10]
                            "8" [r: 7]
                            "9" [r: 8]
                            "10" [r: 9]
                            "11" [r: 14]
                            "12" [r: 11]
                            "13" [r: 12]
                            "14" [r: 13]
                            "15" [r: 16]
                            "16" [r: 15]
                            "17" [r: 18]
                            "18" [r: 17]
                            "19" [r: 19]
                        ]
                    ]
                ]                   
            ] []
        ]
        do compose/deep [
            prin tui [at (pos)] print tui shape/(old-r + 19)
        ]
        stop: false
        foreach po compose oc/(r) [
            foreach coord floor [
                floor-y: to-integer first coord
                floor-x: to-integer second coord
                oc-y:  i + to-integer first po
                oc-x:  xpos + to-integer second po
                if (oc-y = (floor-y - 1)) and (floor-x = oc-x) [
                    stop-shape-num: r
                    stop: true
                    break
                ]
            ]
        ]
        foreach po compose oc/(old-r) [
            foreach coord floor [
                floor-y: to-integer first coord
                floor-x: to-integer second coord
                oc-y:  i + to-integer first po
                oc-x:  old-xpos + to-integer second po
                if (oc-y = (floor-y - 1)) and (floor-x = oc-x) [
                    stop-shape-num: old-r
                    stop: true
                    break
                ]
            ]
        ]
        if stop = true [
            left-col: second pos 
            width-of-shape: length? compose oc/(stop-shape-num)
            right-col: left-col + width-of-shape - 1
            counter: 1
            for current-column left-col right-col 1 [
                add-coord: compose oc/(stop-shape-num)/(counter)
                new-floor-coord: (pos + add-coord)
                append floor new-floor-coord
                counter: counter + 1
            ]
            break
        ]
    ]
    do compose/deep [prin tui [at (pos)] print tui shape/(old-r)]
    if (first pos) < 2 [
        prin tui [at 23x0]
        print "   GAME OVER!!!^/^/"
        halt
    ]
    score: score + 10
    print tui compose [at 13x28 (to-string score)]
    for row 1 20 1 [
        line-is-full: true
        for colmn 5 15 1 [
            each-coord: to-pair rejoin [row "x" colmn]
            if not find floor each-coord [
                line-is-full: false
                break
            ]
        ]
        if line-is-full = true [
            remove-each cor floor [(first cor) = row]
            new-floor: copy [
                21x5 21x6 21x7 21x8 21x9 21x10 21x11 21x12 21x13
                21x14 21x15
            ]
            foreach cords floor [
                either ((first cords) < row) [
                    append new-floor (cords + 1x0)
                ][
                    append new-floor cords
                ]
            ]
            floor: copy unique new-floor
            score: score + 1000
            prin tui [clear]
            loop 20 [print a-line] 
            prin "   " loop 13 [prin "+"] print ""
            print tui compose [
                at 4x21 "TEXTRIS" at 5x21 "-------" 
                at 7x20 "Use arrow keys" at 8x20 "to move/spin."
                at 10x20 "'P' = pause"
                at 13x20 "SCORE:  " (to-string score)
            ]
            foreach was-here floor [
                if not ((first was-here) = 21) [
                    prin tui compose [at (was-here)]
                    prin "#"
                ]
            ]
        ]
    ]
]