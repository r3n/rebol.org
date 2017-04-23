REBOL [
    Title: "Mandelbrot II"
    Date: 23-Sep-2001
    Version: 0.0.1
    File: %mandelbrot2.r
    Author: "Keith Ray"
    Purpose: "Create Mandelbrot Set with colors "
    Email: keithray@yahoo.com
    library: [
        level: none 
        platform: none 
        type: none 
        domain: [GUI math] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

start-x: 2.0
start-y: 1.5
global-color: 0

clear-im: func [im [image!] color [tuple!]][
    repeat j im/size/x * im/size/y [poke im j color]
]


set-color: func [c ][ 
    switch c [
        1 [z: 0.0.0]
        2 [z: 20.0.0]
        3 [z: 40.0.0]
        4 [z: 60.0.0]
        5 [z: 80.0.0]
        6 [z: 100.0.0]
        7 [z: 120.0.0]
        8 [z: 140.0.0]
        9 [z: 160.0.0]
        10 [z: 180.0.0]
        12 [z: 180.20.0]
        22 [z: 180.40.0]
        13 [z: 180.60.0]
        14 [z: 180.80.0]
        15 [z: 180.100.0]
        16 [z: 180.120.0]
        17 [z: 180.140.0]
        18 [z: 180.160.0]
        19 [z: 180.180.0]
        20 [z: 160.180.0]
        21 [z: 140.180.0]
        22 [z: 120.180.0]
        23 [z: 100.180.0]
        24 [z: 80.180.0]
        25 [z: 60.180.0]
        26 [z: 40.180.0]
    ]
return z
]


set-outside-pixel: func [
    im [image!]
    x [integer!]
    y [integer!]
    colr [integer!]
    /local  x-siz y-siz siz
][  
    x-siz: im/size/x
    y-siz: im/size/y
    color: set-color global-color
    poke im (y-siz - y * x-siz + x) color 
    
]





set-pixel: func [
    im [image!]
    x [integer!]
    y [integer!]
    color [tuple!]
    /local  x-siz y-siz siz
][
    x-siz: im/size/x
    y-siz: im/size/y
    poke im (y-siz - y * x-siz + x) color
]


calc-pixel: func [xPixel yPixel] [ 
    rmax: 2
    itmax: 26
    xStart: 0.00
    yStart: 0.00
    count: 0
    r: 0.00
    xnew: 0.00
    ynew: 0.00
    xold: 0.00
    yold: 0.00 
    ;convert to real coordinates
    ;convert it to a value between -2.0 ... 1.0
    xStart: ( xPixel / 100.0 ) - start-x
    ;convert it to a value between -2.0 ... 2.0
    yStart: ( yPixel / 100.0 ) - start-y 
    xold: xStart
    yold: yStart
    count: 0
    r:  0.0
    flag: 2
    while [flag > 1 ][ 
        flag: 0
        if ( r <= rmax )[flag: flag + 1 ]
        if ( count < itmax ) [flag: flag + 1 ]
        xnew: (xold * xold) - (yold * yold) + xStart
        ynew:  (2.0 * xold * yold) + yStart
        r: square-root ((xnew * xnew) + (ynew * ynew))
        xold: xnew
        yold:  ynew
        count: count + 1
    ]
    bol: false
    if (r > rmax)[global-color: to-integer r]
    if (r < rmax)[ bol: true]
    return bol
]

x-siz: 300 y-siz: 300           
im: to-image to-pair reduce [x-siz y-siz]
bg-color: 255.255.220
clear-im im bg-color    

view layout [
    img: image im 
    across
    pad 50
    button "Draw" [
    clear-im im bg-color
        repeat x x-siz [
            repeat y y-siz [
            either calc-pixel x y  [ set-pixel im x y black ][set-outside-pixel im x y y]
            ] 
        show img
        ]
       show img
    ]

    button "Quit" [quit]
]
                                                                                                                                                