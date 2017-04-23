REBOL [
    Title: "Throbbing Button"
    Date: 31-May-2001
    Version: 1.0.1
    File: %throb.r
    Author: "Bohdan Lechnowsky"
    Purpose: {To demonstrate a button that screams "CLICK ME!!" Updated from June 2000 version.}
    Email: bo@rebol.com
    library: [
        level: 'intermediate 
        platform: 'all 
        type: [Demo How-to] 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

dir: 2x2

button: make face [
    offset: 0x0
    image: load-thru/binary http://www.rebol.com/graphics/poweredby.gif
    size: image/size
    effect: 'fit
    rate: 20
    feel: make feel [
        engage: func [face act evt][
            button/offset: button/offset + (dir / 2)
            button/size: button/size - dir
            if any [button/offset = 0x0 button/offset = 5x5][
                dir: negate dir
            ]
            show button
        ]
    ]
]

main: make face [
    offset: 20x24
    size: button/size + 4x4
    pane: [button]
]

view main
