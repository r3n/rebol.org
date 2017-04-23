REBOL [
    Title: "Ellipse Demo"
    Date: 20-May-2000
    File: %ellipse.r
    Purpose: "Demonstate drawing ellipses"
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

foreach [n b][r-t: [random 255.255.255] r-s: [50x50 + random 200x200]][n does b]
view layout do page: does [
    foo: copy [backdrop 0.0.0 [unview/all view layout page]]
    loop 3 [loop 3 [append foo compose/deep [box (c: r-t) (sz: r-s) (form sz)
        with [effect: [oval (complement c)]]]] append foo [return]]
    append foo [backdrop [unview/all view layout page] with [color: none]]
]
