REBOL [
    title: "Jigsaw Puzzle - press SPACE bar to view original image"
    date: 14-Aug-2010
    file: %jigsaw-puzzle.r
    author:  Nick Antonaccio
    purpose: {
        Chop a selected image into a selected number of pieces, and then
        drag/drop the pieces to reassemble the original image.
    }
]
random/seed now
pic: load request-file/only/filter ["*.png" "*.gif" "*.jpg" "*.bmp"]
siz: pic/size
while [any [
    siz/1 > system/view/screen-face/size/1 
    siz/2 > system/view/screen-face/size/2
]] [
    siz: siz * .8   pic: to-image layout/tight [image pic siz]
]
divs: request-list "How many pieces?" [4 16 36 64 100 144 256 400]
sqr: square-root divs
x-size: round (siz/x / sqr)
y-size: round (siz/y / sqr)
p-size: as-pair x-size y-size
end: false
movestyle: [
    engage: func [f a e] [if end = false [
        if a = 'down [
            f/data: e/offset
            remove find f/parent-face/pane f
            append f/parent-face/pane f
        ]
        if find [over away] a [
            unrounded-pos: (f/offset + e/offset - f/data)
            snap-x: (round/to first unrounded-pos x-size)
            snap-y: (round/to second unrounded-pos y-size)
            either any [
                snap-x >= siz/1  snap-x < 0  snap-y >= siz/2  snap-y < 0
            ] [f/offset: unrounded-pos] [f/offset: as-pair snap-x snap-y]
        ]
        show f
        if all [a = 'up  pic = to-image system/view/screen-face/pane/1] [
            end: true  alert "Congratulations - you finished!"
        ]
    ]]
]
gui: compose [size (siz) key #" " [view/new layout [image (pic)]]]
repeat i (to-integer sqr) [
    repeat ii (to-integer sqr) [
        pos: as-pair (x-size * (ii - 1)) (y-size * (i - 1))
        append gui compose/deep [
            at random (siz - p-size) image pic (p-size) effect compose [
                crop (pos) (p-size)
            ] feel movestyle
        ]
    ]
]
alert {Press the space bar at any time to view the original image.}
view center-face layout/tight gui