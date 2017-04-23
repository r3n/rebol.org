REBOL [
    Title: "Mandelbrot"
    Date: 21-Sep-2001
    Version: 0.0.1
    File: %mandelbrot.r
    Author: "Keith Ray"
    Purpose: "Create Mandelbrot Set "
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

clear-im: func [im [image!] color [tuple!]][
    repeat j im/size/x * im/size/y [poke im j color]
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
    itmax: 100
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
    xStart: ( xPixel / 100.0 ) - 2.0
    ;convert it to a value between -2.0 ... 2.0
    yStart: ( yPixel / 100.0 ) - 2.0 
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
    if (r < rmax)[ bol: true]
    return bol
]

x-siz: 300 y-siz: 400           
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
            if calc-pixel x y  [ set-pixel im x y blue ]
            ] 
        show img
        ]
       show img
    ]

    button "Quit" [quit]
]
                                                                                      