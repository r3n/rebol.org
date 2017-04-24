REBOL [
    title: "Wiggly Text"
    date: 13-mar-2014
    file: %wiggly-text.r
    author:  Nick Antonaccio
    purpose: {
        A quick demo done with a student, loosely based on the
        QT "Wiggly" example.
    }
]
random/seed now
svv/vid-face/color: white
g: copy [size 200x100]
pos: 10x30
foreach chr request-text/default "This text wiggles" [
    append g compose [at (pos) text (form chr)]
    pos: pos + 10x2
]
view/new v: layout g
forever [
    if none = system/view/screen-face/pane/1 [quit]
    foreach f system/view/screen-face/pane/1/pane [
        f/font/color: random 255.255.255
        either f/user-data <> "up" [
            f/offset/2: f/offset/2 + 2
        ][
            f/offset/2: f/offset/2 - 2
        ]
        if f/offset/2 > 60 [f/user-data: "up"]
        if f/offset/2 < 30  [f/user-data: "down"]
    ]
    wait .015
    show v
]