REBOL [
    Title: "Graphical Layout Editor"
    Date: 21-Jun-2000
    Version: 1.0.1
    File: %layed.r
    Author: "Carl Sassenrath"
    Purpose: {Your basic 1K REBOL graphical object layout editor.
Not many features, but a good example of how to drag
faces and show nubs.
}
    Email: carl@rebol.com
    Note: "Keeping the nubs on top is done on purpose."
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

read-thru/to http://www.reboltech.com/library/scripts/bay.jpg %bay.jpg

; Layout to edit:
faces: layout [
    backdrop %bay.jpg 0.0.200
    vh1 "Move Stuff Around"
    image %bay.jpg
    field
    across space 0
    button "Send"
    button "Cancel"
]


vid-face: get-style 'face


engage-drag: func [f a e][  
    if find [over away] a [
        f/offset: f/offset + e/offset - f/data
        update-nubs f
        show [f nub-face]
    ]
    if a = 'down [
        f/data: e/offset
        show-nubs f
    ]
]


nub-face: make vid-face [
    edge: make edge [color: 250.120.40 effect: 'nubs size: 4x4]
    color: font: para: text: data: none
    feel: make feel [
        engage: func [f a e] [  ;intercepts target face events
            if data [data/feel/engage data a e]
        ]
    ]
]


update-nubs: func [f] [
    nub-face/offset: f/offset - 4x4
    nub-face/size: f/size + 8x8
]


show-nubs: func [f] [
    update-nubs f
    nub-face/data: f
    if not find f/parent-face/pane nub-face [
        append f/parent-face/pane nub-face
    ]
    show f/parent-face
]


foreach f faces/pane [f/feel/engage: :engage-drag]


view faces
