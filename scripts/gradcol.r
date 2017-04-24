REBOL [
    Title: "Simple GradCol Example"
    Date: 20-May-2000
    File: %gradcol.r
    Author: "Jeff"
    Purpose: "Demomstrate graduated colors"
    library: [
        level: 'intermediate
        platform: none
        type: none
        domain: 'GUI
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

pic: load-thru/binary http://www.rebol.com/view/bay.jpg
page: does [
    foo: copy [backdrop 0.0.0 [unview/all view layout page]]
    loop 5 [loop 5 [append foo compose/deep [
        image pic 80x80 (random 255.255.255) with [effect: [fit gradcol (2x2 - random 3x3)
            (random 255.255.255) 0.0.0]]]]  append foo [return]
    ]
    append foo [backdrop [unview/all view layout page] with [color: none]]
]
view layout page
