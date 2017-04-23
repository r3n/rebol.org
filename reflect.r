REBOL [
    Title: "Reflection Demo"
    Date: 20-May-2000
    Purpose: "Demonstrates VID effects"
    File: %reflect.r
    Author: "Jeff"
    library: [
        level: 'advanced
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
sty: stylize [i: image with [image: pic size: 200x200 font: [size: 32 color: 255.20.0]]]
r-v: does [2x2 - random 3x3]
view layout do page: does [
    foo: copy [styles sty backdrop 0.0.0]
    loop 3 [loop 3 [append foo compose/deep [i (form v: r-v) with [
            effect: [fit reflect (v)]]]] append foo [return]]
    append foo [backdrop [unview/all view layout page] with [color: none]]
]
