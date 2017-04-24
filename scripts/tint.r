REBOL [
    Title: "Tint demonstration"
    Date: 20-May-2000
    File: %tint.r
    Author: "Jeff"
    library: [
        level: 'advanced 
        platform: 'all 
        type: 'Demo 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Purpose: "Tint demonstration"
]

pic: load-thru/binary http://www.rebol.com/view/bay.jpg
tnt: -128 view layout do page: does [
    foo: copy [backdrop 0.0.0 [unview/all view layout page]] 
    loop 10 [loop 9 [append foo compose/deep [image pic 60x60 (form tnt) 
        with [effect: [fit tint (tnt)] ] ] tnt: tnt + 3] append foo [return]]
    append foo [backdrop [quit] with [color: none]]
] 
