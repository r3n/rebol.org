REBOL [
    File: %space-invaders-shootup.r
    Date: 20-Aug-2009
    Title: "Space Invaders Shootup"
    Author:  Nick Antonaccio
    Purpose: {
        An extremely simple variation of the classic game.  
        Taken from the tutorial at http://musiclessonz.com/rebol.html
    }
]

alien1:  load to-binary decompress 64#{
eJx9UzFLQzEQjijUOognHTIVhCd0cXJ1kLe3g7SbFKcsWQoWZ7MFhNKxg0PpH3Cx
WbKUqpPoUNcOPim1Q+kPkCJekvf0NTx7cLl7d8l33+XywvL+FrFyhVpCPUY9QN0g
LnG7ScjjrtM98iedToeM3kbW7/f71k4/p6R+USe9Xo/UqjUbi94jMhgMrL/8XpLm
ZZP4spPyzxVTT35MM2Zir4vFYu4dM7GP2M483Fa8f8w0O/Vy24yzo8RXipfJmdb8
kJxwrdJ7K4gxiSs7/09czYpdW6vcsI+AtrEKQ7ScDPlLHO/aNQ8huzaVeSDaHrNi
3IlBjDI6mqVsWvIA0E5ZJ2OtlUIuAKHmqoS5kHOt9UPMP0sm3TU5PHdHQVIZMs3v
qZTPmrMAQAj6ZXOSUtkwPKRwloKQNlexCDOvR4fpclGq76KNzC2mQPiG681i5gAw
ZusVJEAh5JojBzrEGQYC2dncuh7+y83d7ASVAu8MpAQqkT9+3Gg3Q+wHI2AZSAFm
1+99FzMQkzllVUxeTFUrc4vC4Q4VV4wlLyaerjD1XPe+tLxK8SNbqTrJOIf/Bd4X
V+VU7AfjSm0ZEgQAAA==
}
ship1: load to-binary decompress 64#{
eJx1Us9L3EAU/rTbMdHE9VlYukSQFhUpvXjQXrfizR8XkYAnt0oQVsTLGlgEFdSL
l3jqpXgre6sEJAgDsidPIul/sHjopeIfILj0JdnV3ez0y7zJzLx533vvY2YXhzOI
scs2yfaF7QNbDxLHjzfAu4HEhpKryAgDfccC4rfAws0IjF/96HsWyH7XMNXIon9Z
QJvWsNQw8XZP4NPlKD73Whi/HcZO4z207fv7jyo8/jk4r1TdFQXcSrV+flEtq3x2
5amuB44lyU+BpHRKHq4dKXnZCbLkxl9kOF5BarPVDFWyBAWcEAVFsjrhENGmhyPK
UXe+XNHf9HqZW9GgyzUUoloqXcXE1wv6iSTHohSkQ8yJQ5l2RCiSvPIGbaVkTFuu
Ge5/erfdurb+wM3ETZHPyjaX5NzNHPATOHMsn894sMZJWX4uH78OYSvTrUU+paI2
q8nQl5JHMFaSOZLBbHPnoR2ndHUa5NtPwubfFKziT1YqRDdY2VV3JckT3X2ZIlwW
KQjmUxGhGQ0Ecm5OlhBvUsSi/NpXmjLRoFx4YWuL0789fN24m+jsK2x+wGE+JjLR
DePiqdbKZqZojf1qLZ2ptdO3ZrxXwjCODzuThK3Af4EF8jYSBAAA
}
alien-fire: load to-binary decompress 64#{
eJxz8o1jZACDMiDWAGI+IJYFYkYGFrD4CyAW5oZgAYhSBhZmFoaWphaG48eOMwQF
BDFoaGgwPH36lGHZsmUM4uLiDFk5WQyzZs1iuHHzBsOfv38Ydu7cyWBhZsFQXlrO
EBEVATTBaWlolAoDA/vp3bt37wHyZwPpTUCaedqpUBWGS6HLMj8AedpA0Z1QGqTK
KXrNtCdgF/BLtrCD6GywOAPDabA6BobCTAMwXTfzFMh8uM7ZUBpi/p3QZdMMwLp2
796GbH7omrR2sH6Omc+h5m4C09pQuiKzHWp+O1R+D1QeQjstPQINIwag+wBUhlwj
XgEAAA==
}
ship-fire: load to-binary decompress 64#{
eJxz8t3FAAFlQKwBxOxALAjEjAwsYHEXIBbmhmABqFo2FhYG9l4eBvajbAwKSTIM
/H8FGFjUOBg4tnEyGP1VYWAXZWOwadNg4KhiYdA5JMLAacbJIHNLhUFnkgiDIpMg
2IyDd2UYVMqdGNLLyxoOz7RpCJ5p2pDi4sYAwlFpSz+AcEoJkF8O5KstZWhUkvig
4uLEoAIUO7f7zQcA8m8lvboAAAA=
}
bottom: 270  end: sidewall: false  random/seed now
b: ['image 300x400 ship1 'line -10x270 610x270]
for row 60 220 40 [
    for column 20 380 60 [
        pos: to-pair rejoin [column "x" row]
        append b reduce ['image pos alien1]
    ]
]
view center-face layout/tight [
    scrn: box black 600x440 effect [draw b] rate 1000 feel [
        engage: func [f a e] [
            if a = 'key [
                if e/key = 'right [b/2: b/2 + 5x0]
                if e/key = 'left [b/2: b/2 - 5x0]
                if e/key = 'up [
                    if not find b ship-fire [
                        fire-pos: b/2 + 25x-20
                        append b reduce ['image fire-pos ship-fire]
                    ]
                ]
                system/view/caret: none
                show scrn
                system/view/caret: head f/text
            ]
            if a = 'time [
                if (random 1000) > 900 [ 
                    f-pos: to-pair rejoin [random 600 "x" bottom]
                    append b reduce ['image f-pos alien-fire]
                ]
                for i 1 (length? b) 1 [
                    removed: false
                    if ((pick b i) = ship-fire) [
                        for c 8 (length? head b) 3 [
                            if (within? (pick b c) (
                            (pick b (i - 1)) + -40x0) 50x35)
                            and ((pick b (c + 1)) <> ship-fire) [
                                removed: true 
                                d: c
                                e: i - 1
                            ]
                        ]
                        either ((second (pick b (i - 1))) < -10) [
                            remove/part at b (i - 2) 3
                        ] [
                            do compose [b/(i - 1): b/(i - 1) - 0x9]
                        ]
                    ]
                    if ((pick b i) = alien1) [
                        either ((second (pick b (i - 1))) > 385) [
                            end: true
                        ] [
                            if ((first (pick b (i - 1))) > 550) [
                                sidewall: true
                                for item 4 (length? b) 1 [
                                    if (pick b item) = alien1 [
                                        do compose [
                                          b/(item - 1): b/(item - 1) + 0x2
                                        ]
                                    ]
                                ]
                                bottom: bottom + 2       
                                b/5: to-pair rejoin [-10 "x" bottom]
                                b/6: to-pair rejoin [610 "x" bottom]
                            ]
                            if ((first (pick b (i - 1))) < 0) [
                                sidewall: false
                                for item 4 (length? b) 1 [
                                    if (pick b item) = alien1 [
                                        do compose [
                                          b/(item - 1): b/(item - 1) + 0x2
                                        ]
                                    ]
                                ]
                                bottom: bottom + 2
                                b/5: to-pair rejoin [-10 "x" bottom]
                                b/6: to-pair rejoin [610 "x" bottom]
                            ]
                            if sidewall = true [
                                do compose [b/(i - 1): b/(i - 1) - 2x0]
                            ]
                            if sidewall = false [
                                do compose [b/(i - 1): b/(i - 1) + 2x0]
                            ]
                        ]
                    ]
                    if ((pick b i) = alien-fire) [
                        if within? ((pick b (i - 1)) + 0x14) (
                            (pick b 2) + -10x0) 65x35 [
                            alert "You've been killed by alien fire!" quit
                        ]
                        either ((second (pick b (i - 1))) > 400) [
                            remove/part at b (i - 2) 3
                        ] [
                            do compose [b/(i - 1): b/(i - 1) + 0x3]
                        ]
                    ]
                    if removed = true [
                        remove/part (at b (d - 1)) 3
                        remove/part (at b (e - 1)) 3
                    ]
                ]
                system/view/caret: none
                show scrn
                system/view/caret: head f/text
                if not (find b alien1) [
                    alert "You killed all the aliens. You win!" quit
                ] 
                if end = true [alert "The aliens landed! Game over." quit]
            ]
        ]
    ]
    do [focus scrn]
]