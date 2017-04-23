REBOL [
    title: "Relative Positioning In Resized VID Window"
    date: 18-Apr-2010
    file: %resize.r
    author:  Nick Antonaccio
    purpose: {
        A simple example of how to position widgets relative to one another
        in a resized VID GUI window. 
        Taken from the tutorial at http://re-bol.com
    }
]

REBOL []

svv/vid-face/color: white
view/new/options gui: layout [
    across
    t1: text bold "X"
    t2: text "- 50x25"
    t3: text "- 25x50"
] [resize]

insert-event-func [
    either event/type = 'resize [
        fs: t1/parent-face/size
        t1/offset: fs / 2x2
        t2/offset: t1/offset - 50x25
        t3/offset: t1/offset - 25x50
        show gui  none
    ] [event]
]

ss: system/view/screen-face/size
gui/size: (ss - 200x200)  ;  make the window 200 pixels less wide and short than the screen
gui/offset: (ss / 2x2) - (gui/size / 2x2)  ; center the window
show gui  do-events