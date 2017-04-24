REBOL [
    Title: "Gradient Multiply"
    Date: 20-May-2000
    Purpose: "demonstrate gradient multiply effects"
    File: %gmul.r
    Author: "Jeff"
    library: [
        level: 'intermediate
        platform: none
        type: none
        domain: 'GUI
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

r-vect: does [2x2 - random 3x3]
gm:  does [compose [gradmul (r-vect) (white) (black)]]
view layout [
    bg: backdrop 0.255.0 with [
        rate: 12 feel: make feel [engage: func [f a e][f/effect: gm show f]]
    ] box 200x200
]