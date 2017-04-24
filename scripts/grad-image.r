REBOL [
    Title: "Gradient Colorize Examples"
    Date: 22-May-2001/17:13:56-7:00
    Version: 1.0.0
    File: %grad-image.r
    Author: "Carl at REBOL"
    Purpose: "Applies multiple gradients to a single image."
    Email: carl@rebol.com
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tutorial 
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

flash "Fetching image..."
img: load-thru/binary http://www.rebol.com/view/demos/nyc.jpg
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
