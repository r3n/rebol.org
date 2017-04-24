REBOL [
    File: %ski-game.r
    Date: 23-07-2009
    Title: "Ski Game"
    Author:  Nick Antonaccio
    Purpose: {
        A little graphic game.  
        Taken from the tutorial at http://musiclessonz.com/rebol.html
    }
]

tree:  load to-binary decompress 64#{
eJzt18sNwjAQBFDTBSVw5EQBnLjQE1XRngmBQEj8Wa/3M4oYOZKBKHkaWwTO1/sh
jDkNx3N6HI7LcOzCfnz/9v5cMnEai7lj4mokT9C7XczUsrhvGSku6RkgDIbHAEP0
2EiIMBdMDuaOWZCSL91bQvCsSY4MHE9umXz7ydVi3xgltYvEKboexzVSlpTa614d
NonpUauIv176dX0ZTRgJlVgzNl25A3gkGwld1bkrNFqqedQfEI02AU9PjDeMpac/
ShKeTXylROqCImlXRFd9zkQoh4tp+GpqlSTnLnum4HTEzK/gjpmTpDxSASlHFqYU
EE/8nddG9n+9LIm8t9OeIEra2JZWDRSG4VEioa0UFCZFqv/aMQh2Rf790EnGgcJU
SVAer0Bhcp7/epVJvkHzBHjPfz+XSe6BwryC5gmQno3mAY3tpba2KAAA
}

skier-left: load to-binary decompress 64#{
eJyN0U8og2EcB/DvNrz+E5fJZSmRf9Ej76h3Ne1AIspyMQflpJDFU/KO1cQmSnGa
A3PYkvInB3kvuyzlgJolh+fCRUq5iBvP8+5lTvKrX33ep+/zp9/b2Tthhl6zvGt5
W3nX8TYhS1//MOGnSjNEa/AUxd0UVQ3raL9IYbBvA2OBI9Q0DqB6fAujl08Yi97D
Hr3F5EQYSss2OrrWEFo5xB+VO5Vx/skvnxmQbDCFvxcjMJ/b0s6LAZXGA3O0ZtTt
pW3WbJmDeMC8a1gE9o3bTBFI9YvGhrOKSueyEQpu9ri60vQFXFqPMx1K+sNWrdOh
73Y/uMr85fKdcIrJ0z6vxSfsYV5KCU2JEPNIlD9dFZ65AfXwD+HsKdAZiiLdqtvt
Hh65E5ZklTGmDvWLgxxKkjAivwt7XxhJEvIsrCY8ikLs0Tj3yGeCKaQtdsX9fv3G
N1jCJdyv84lHJkNriiM7Li29OIDV0jcU8kuIHaiPLEDEsG9DQYxiQTi0A8sBpEvh
OT65GmBYH9Jx5nf8TFFUFf5ZX2hFdG1uAgAA
}

skier-right: load to-binary decompress 64#{
eJxz8s1jYgCDMiDWAGIJINYCYkYGFrD4D0YGOBBAMBn4++Yz6HjVMSgY1oP5gWdu
M/gHTmCwNutlKJ26l6F03VUGp3XnGGo+/mGILVnMoFkwhaHm7GcGz4m7GbABFwST
eQWSNXMQbM+3DAwlULbmEgaWXih75QUGzvkQJstMBwbPRRA2L1D5yS8QNudioNQF
qNYPDExAZRCtDg78c6Fa7wZK3Ycq940O3L1fAcLWigpctUsZzHTSj5Jd+l7NAKS6
3HnXk6jHSiBF7sUmxi7Gl9VAZrqVOxsZuTirg8TTS0qAQs5FIPF0BhYXFkgog/zg
7gJlq5SXpaWVF4O9lZKuXl6eVl4AZLIfKS82LzYuB2nlOFxWXl5ubA6ytm1KWU65
cXExkMl09lNNR3q5eTFQPYfHE7YT6cXlJgcYGI7cPMAOMtKhgcH9wE8FBuPycgOG
BoYKtl8ODL4gjccY2HSAfr4BVMvgAwyazwwsXSA7ORgY2BQYeH+Cw+sAKPo5wEHj
kQAO/GZwIIHDgc0AaxQSBAAFOXD7bgIAAA==
}

random/seed now
the-score: 0
board: reduce ['image 300x20 skier-right black]
for i 1 20 1 [
    pos: random 600x540
    pos: pos + 0x300
    append board reduce ['image pos tree black]
]
view center-face layout/tight [
    scrn: box white 600x440 effect [draw board] rate 0 feel [
        engage: func [f a e] [
            if a = 'key [
                if e/key = 'right [
                    board/2: board/2 + 5x0
                    board/3: skier-right
                ]
                if e/key = 'left [
                    board/2: board/2 - 5x0
                    board/3: skier-left
                ]
                show scrn
            ]
            if a = 'time [
                new-board: copy []
                foreach item board [
                    either all [
                        ((type? item) = pair!) 
                        ((length? new-board) > 4)
                    ] [ 
                        append new-board (item - 0x5) 
                    ] [
                        append new-board item
                    ]
                    coord: first back back (tail new-board)
                    if ((type? coord) = pair!) [
                        if ((second coord) < -60) [
                            remove back tail new-board
                            remove back tail new-board
                            remove back tail new-board
                            remove back tail new-board
                        ]
                    ]
                ]
                board: copy new-board
                if (length? new-board) < 84 [
                    column: random 600
                    pos: to-pair rejoin [column "x" 440]
                    append board reduce ['image pos tree black]
                ]
                collision-board: remove/part (copy board) 4
                foreach item collision-board [
                    if (type? item) = pair! [
                        if all [
                          ((item/1 - board/2/1) < 15)
                          ((item/1 - board/2/1) > -40)
                          ((board/2/2 - item/2) < 30)
                          ((board/2/2 - item/2) > 5)
                        ] [
                            alert "Ouch - you hit a tree!"
                            alert rejoin ["Final Score: " the-score]
                            quit
                        ]
                    ]
                ]
                the-score: the-score + 1 
                score/text: to-string the-score
                show scrn
            ]
        ]
    ]
    origin across h2 "Score:" 
    score: h2 bold "000000"
    do [focus scrn]
]