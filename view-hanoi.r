REBOL [
    Title: "View-Hanoi"
    Date: 4-Oct-2001
    Version: 1.0.0
    File: %view-hanoi.r
    Author: "Gregg Irwin"
    Purpose: {Towers of Hanoi with Visualization. A learning excercise for me. Hopefully it will improve over time.}
    Comment: {
        The core logic is modeled on an example in an old LISP book I have
        (Understanding LISP) by Paul Gloess. I get the blame for the
        visualization.

        You can change the number of disks!

        A long time ago I wanted to write a series of "Animated Algorithms"
        to help people visualize how they work. I guess I was just waiting
        for REBOL. :)
    }
    History: {
        * Added visualization
        * Changed _do-towers parameters to integers to ease animation calls.
    }
    Email: greggirwin@acm.org
    e-mail: greggirwin@acm.org
    TBD: {
        * Make code less fragile to changes
        * Get a better grip on dynamic layout and finding disk face to move
        * Speed control
        * Colored disks
        * Interactive version for humans to play
        * Clean up animation code. Simplify. Use move-offset?
        * Decide if I like the leading underscore convention.
        * Gack! Look at all the magic numbers!
        * Add reset button and number of disks to UI.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: [Demo Game] 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]


hanoi: context [
    num-disks: 3    ; << Have to set this here for now, until it gets into the UI.
    disk-height: 15
    disk-cell-width: 20
    move-dist: 1    ; Move more than 1 pixel at a time? May throw disk centering off.
    wait-time: 0    ; .05 *Really* slow. Anything more would be painful.
                    ; You can also uncomment the print statements in the animcation
                    ; functions to slow things down.
    tower-height: disk-height * (num-disks + 2)
    tower-top: 50
    towers: num-moves: none

    move-offset: [
        up     0x-1
        down   0x1
        left  -1x0
        right  1x0
    ]
    ; To move faster, we can multiply our offsets.

    start: func [
        num-disks[integer!] "Number of disks to play with"
    ][
        tower-height: disk-height * (num-disks + 1)
        num-moves: 0
        towers: reduce [_make-disks num-disks copy [] copy []]
        print mold towers
        _do-towers num-disks 1 2 3
        print ["Number of moves required: " num-moves]
    ]

    _do-towers: func [
        num-disks[integer!] "Number of disks to move"
        source[integer!]    "Source tower"
        temp[integer!]      "Temporary holding tower"
        dest[integer!]      "Destination tower"
    ][
        if num-disks > 0 [
            _do-towers (num-disks - 1) source dest temp
            ; If you don't want to see the disks move, comment out the next line.
            _animate-disk-move source dest
            _move-disk towers/:source towers/:dest
            _do-towers (num-disks - 1) temp source dest
        ]
    ]

    _move-disk: func [
        source[any-block!]  "Source tower"
        dest[any-block!]    "Destination tower"
    ][
        num-moves: add num-moves 1
        append dest last source
        clear back tail source
        ;print mold towers
    ]

    _make-disks: func [
        num-disks [integer!] "Number of disks to put in a block"
        /local i result
    ][
        result: make block! num-disks
        for i num-disks 1 -1 [
            append result i
        ]
        return result
    ]

    _animate-disk-move: func [source dest /local disk-face face ct] [
        disk-face: none
        ct: 0
        ; There must be a better way, but I couldn't get it to dynamically
        ; look up the face by ID (e.g. D1, D2, etc.). This makes the code
        ; pretty fragile because it is dependent on the disk faces being
        ; in order.
        foreach face l/pane [
            if face/style = 'disk [
                ct: add ct 1
                if ct = last towers/:source [
                    disk-face: :face
                    break
                ]
            ]
        ]
        if object? disk-face [
            _animate-disk-up   disk-face
            _animate-disk-over disk-face source dest
            _animate-disk-down disk-face dest
        ]
    ]

    _animate-disk-up: func [disk-face] [
        while [(disk-face/offset/y + disk-face/size/y) >= tower-top] [
            ;print disk-face/offset/y
            disk-face/offset/y: subtract disk-face/offset/y move-dist
            show disk-face
            wait wait-time
        ]
    ]

    _animate-disk-down: func [disk-face dest /local dest-y] [
        dest-y: (tower-top + tower-height) - (((length? towers/:dest) - 1) * disk-height)
        while [(disk-face/offset/y + disk-face/size/y) < dest-y] [
            ;print disk-face/offset/y
            disk-face/offset/y: add disk-face/offset/y move-dist
            show disk-face
            wait wait-time
        ]
    ]

    _animate-disk-over: func [disk-face source dest /local dest-x comp op] [
        ; + 5 accounts for 1/2 tower width
        dest-x: (_tower-x-pos dest) + 5
        either source < dest [
            comp: :lesser?
            op:   :add
        ][
            comp: :greater?
            op:   :subtract
        ]
        while [comp (disk-face/offset/x + (disk-face/size/x / 2)) dest-x] [
            ;print disk-face/offset/x
            disk-face/offset/x: op disk-face/offset/x move-dist
            show disk-face
            wait wait-time
        ]
;         either source < dest [
;             while [(disk-face/offset/x + (disk-face/size/x / 2)) < dest-x] [
;                 ;print disk-face/offset/x
;                 disk-face/offset/x: add disk-face/offset/x move-dist
;                 show disk-face
;                 wait wait-time
;             ]
;         ][
;             while [(disk-face/offset/x + (disk-face/size/x / 2)) > dest-x] [
;                 ;print disk-face/offset/x
;                 disk-face/offset/x: subtract disk-face/offset/x move-dist
;                 show disk-face
;                 wait wait-time
;             ]
;         ]
    ]

    _tower-x-pos: func [index] [
        50 + (disk-cell-width * (num-disks + 1) * (index - 1)) + ((disk-cell-width * num-disks) / 2)
    ]

    _initial-disk-x-pos: func [index] [
        ; + 5 accounts for 1/2 tower width
        return ((_tower-x-pos 1) + 5) - ((disk-cell-width * index) / 2)
    ]

    _make-disk: func [num-cells /local color] [
        ; Gray disks
        reduce ['disk to-pair reduce compose [(disk-cell-width * num-cells) disk-height] 'effect [gradient 0x1 255.255.255 0.0.0]]
        ; Random color disks
        ;color: random 255.255.255
        ;reduce ['disk to-pair reduce compose [(disk-cell-width * num-cells) disk-height] 'effect compose [gradient 0x1 (color) (color - 100)]]
    ]

    lay: [
        size to-pair reduce compose [(disk-cell-width * (num-disks + 1) * 3 + 100) (tower-height + 100)]
        style tower box to-pair reduce [10 tower-height] effect [gradient 1x0 255.255.255 0.0.0]
        style disk  box
        across
        ; Towers and disks are added below.
    ]
    ; Add Towers
    repeat i 3 [
        ; Can't get this to work as a one-liner. I'm a dope.
        ;append lay [at reduce [to-pair reduce [tower-x-pos i 50]] tower]
        append lay [at]
        append lay reduce [to-pair reduce [_tower-x-pos i tower-top]]
        append lay [tower]
    ]
    ; Add Disks
    repeat i num-disks [
        append lay [at]
        append lay reduce compose [to-pair reduce [_initial-disk-x-pos i (tower-top + ((i + 1) * disk-height))]]
        append lay to-set-word join "D" i
        append lay (_make-disk i)
    ]
    ; Add buttons
    append lay [
        return
        button "go" [start num-disks]
        button "close" [quit]
    ]

    print ""
    view/options l: layout lay [resize]

]


                                                                                                                                                                                                                                         