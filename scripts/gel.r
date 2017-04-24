REBOL [
    Title: "Cool Effect Gel"
    Date: 2-Apr-2001
    Version: 1.3.2
    File: %gel.r
    Author: "Carl Sassenrath"
    Purpose: "Power of the REBOL/View engine."
    Email: carl@rebol.com
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

the-image: load-thru/binary http://www.rebol.com/view/demos/palms.jpg

effects: [
    [contrast 40]
    [invert]
    [colorize 0.0.200]
    [gradcol 1x1 0.0.255 255.0.0]
    [tint 100]
    [luma -80]
    [multiply 80.0.200]
    [grayscale emboss]
    [flip 0x1]
    [flip 1x0]
    [rotate 90]
    [reflect 1x1]
    [blur]
    [sharpen]
]

faces: layout [
    size the-image/size
    backdrop the-image
    pad 0x20 space 0x2
    vh2 yellow "Grab the gel and drag it around."
    vtext bold "Click on button below to change the effect."
    across
    at the-image/size * 0x1 + 10x-40
    pos: vh1 90x24
    rota: rotary 200 [
        v-face/effect: load first rota/data
        show v-face
    ]
]

rota/data: []
foreach e effects [append/only rota/data form e]

vid-face: get-style 'face

append faces/pane v-face: make vid-face [
    size: 100x100
    pos/text: offset: 108x92
    edge: make edge [color: 250.120.40 size: 4x4]
    color: font: para: text: data: image: none
    effect: first effects
    feel: make feel [
        engage: func [f a e] [  ;intercepts target face events
            if find [over away] a [
                pos/text: f/offset: confine f/offset + e/offset - f/data f/size
                    0x0 f/parent-face/size
                f/effect: pick effects index? rota/data
                show [f pos]
            ]
            if a = 'down [f/data: e/offset]
        ]
    ]
]

view faces
