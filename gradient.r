REBOL [
    Title: "Gradients demonstration"
    Date: 20-May-2000
    Purpose: "Gradients demonstration"
    File: %gradient.r
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

pairs: [1x0 -1x0 0x1 0x-1 1x1 -1x1 -1x-1 1x-1]
foreach [n b] [r-t: [random 255.255.255] r-s: [50x50 + random 200x200]
    r-v: [pairs: next pairs all [tail? pairs pairs: head pairs] pairs/1]
][n does b]
view layout do page: does [
    foo: copy [backdrop 0.0.0] sz: r-s
    loop 3 [loop 3 [append foo compose/deep [box (sz) (form v: r-v) with [
            effect: [fit gradient (v)(r-t)(r-t)]]]] append foo [return]]
    append foo [backdrop [unview/all view layout page] with [color: none]]
]
