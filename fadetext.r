REBOL [
    Title: "Fade Presentation"
    Date: 20-May-2000
    Purpose: "Demonstrate fade effects"
    File: %fadetext.r
    Author: "Jeff"
    library: [
        level: 'advanced
        platform: none
        type: none
        domain: 'GUI
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

ptext: parse form next first system/words none
incr: func [/tup/templ/inc] [
    tup: 10.10.10 + random 255.255.255
    tmp: copy [] inc: to-tuple repeat i 3 [
        append tmp to-integer (pick tup i) / 10
    ] reduce [tup inc]
]
one-way: func [c end inc][
    make face/feel [engage: func [f a e] compose/deep [
        all [a = 'time (to-set-path c/1) (c/1) (inc)
            (end) = (c/1) f/rate: 0] show f]]
] set [sc inc] incr
foreach [n b][
    r-vect: [2x2 - random 3x3]
    gm:  [compose [gradmul (r-vect) (white) (black)]]
    bgc: [one-way [f/color] sc compose [+ (inc)]]
    tgc: [one-way [f/font/color] black compose [- (inc)]]][n does b]
view layout [
    bg: backdrop 0.0.0 with [rate: 10 feel: bgc effect: gm]
    tt: text (ptext/1) 120x30 (sc) with [font: [size: 18]
        rate: 10 feel: tgc effect: [key 0.0.0]]
    button "Next" [tt/text: first either tail? ptext: next ptext
        [ptest: head ptext][ptext] bg/effect: gm set [sc inc] incr
        bg/color: black tt/font/color: sc bg/feel: bgc
        tt/rate: bg/rate: 10 show reduce [bg tt]]
]
