REBOL [
    Title: "Gradient Colorize Examples"
    Date: 4-Jun-2001/10:52:55+9:00
    Version: 0.0.1
    File: %My_Grab.r
    Author: "Tesserator"
    Purpose: {Trying to Auto DL weather maps on 30min. intervals from: http://wwwghcc.msfc.nasa.gov/cgi-bin/get-goes?satellite=Global%20Composite&x=0&y=0&map=none&zoom=1&width=1000&height=500&quality=100
}
    Email: jimbo@sc.starcat.ne.jp
    library: [
        level: none 
        platform: none 
        type: none 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

flash "Fetching image..."
img: load-thru/binary http://wwwghcc.msfc.nasa.gov/cgi-bin/get-goes?satellite=Global%20Composite&x=0&y=0&map=none&zoom=1&width=1000&height=500&quality=100

unview

view layout [
    across backdrop 0.50.0
    style box box img 80
    vh1 "Gradient Colorize Examples"
    below guide
    box effect [fit gradcol]
    box yellow effect [fit gradcol]
    box effect [fit gradcol 200.0.0]
    box yellow effect [fit gradcol 200.0.0]
    box effect [fit gradcol 200.0.0 0.0.200]
    return
    box effect [fit gradcol 1x0]
    box yellow effect [fit gradcol 1x0]
    box effect [fit gradcol 1x0 200.0.0]
    box yellow effect [fit gradcol 1x0 200.0.0]
    box effect [fit gradcol 1x0 200.0.0 0.0.200]
    return
    box effect [fit gradcol -1x0]
    box yellow effect [fit gradcol -1x0]
    box effect [fit gradcol -1x0 200.0.0]
    box yellow effect [fit gradcol -1x0 200.0.0]
    box effect [fit gradcol -1x0 200.0.0 0.0.200]
    return
    box effect [fit gradcol 0x1]
    box yellow effect [fit gradcol 0x1]
    box effect [fit gradcol 0x1 200.0.0]
    box yellow effect [fit gradcol 0x1 200.0.0]
    box effect [fit gradcol 0x1 200.0.0 0.0.200]
    return
    box effect [fit gradcol 0x-1]
    box yellow effect [fit gradcol 0x-1]
    box effect [fit gradcol 0x-1 200.0.0]
    box yellow effect [fit gradcol 0x-1 200.0.0]
    box effect [fit gradcol 0x-1 200.0.0 0.0.200]
    return
    box effect [fit gradcol 1x1]
    box yellow effect [fit gradcol 1x1]
    box effect [fit gradcol 1x1 200.0.0]
    box yellow effect [fit gradcol 1x1 200.0.0]
    box effect [fit gradcol 1x1 200.0.0 0.0.200]
    return
    box effect [fit gradcol -1x1]
    box yellow effect [fit gradcol -1x1]
    box effect [fit gradcol -1x1 200.0.0]
    box yellow effect [fit gradcol -1x1 200.0.0]
    box effect [fit gradcol -1x1 200.0.0 0.0.200]
    return
    box effect [fit gradcol 1x-1]
    box yellow effect [fit gradcol 1x-1]
    box effect [fit gradcol 1x-1 200.0.0]
    box yellow effect [fit gradcol 1x-1 200.0.0]
    box effect [fit gradcol 1x-1 200.0.0 0.0.200]
    return
    box effect [fit gradcol -1x-1]
    box yellow effect [fit gradcol -1x-1]
    box effect [fit gradcol -1x-1 200.0.0]
    box yellow effect [fit gradcol -1x-1 200.0.0]
    box effect [fit gradcol -1x-1 200.0.0 0.0.200]
]
