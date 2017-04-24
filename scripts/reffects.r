REBOL [
    Title: "AutoEffects"
    Date: 20-May-2000
    File: %reffects.r
    Purpose: "Demonstates many VID effects"
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

foreach [n b][
    r-pair: [random 1x1] r-num2: [random length? some-effects]
    r-tup:  [random 255.255.255] r-num:  [(random 256) - 128]
    eng: [make face/feel [engage: func [f a e][foreach i [
         [o-range f/font/size 30 8 y: not y][12 < length? effect clear effect]
         [a = 'time f/font/color: r-tup f/font/size: do compose [
            f/font/size (pick [+ -] y) 1] x: not x aa/text: form
            append effect compose pick some-effects r-num2]]
                [all bind i in f 'self show f show aa]]]]]
[n does b] o-range: func [x u d][any [x > u x < d]]
some-effects: [[tint (r-num)][invert][flip (r-pair)][reflect (r-pair)][grayscale]
    [brighten (r-num)][contrast (r-num)][gradcol (r-pair) (r-tup) (r-tup)]
    [gradmul (r-pair) (r-tup) (r-tup)][blur][sharpen][difference (r-tup)]]
view layout [backdrop 0.0.0
    im: image "REBOL/view" pic with [y: x: on rate: 5 effect: [] feel: eng]
    aa: text 255.255.0 (im/size * 1x0 + 0x80) (loop 100 [append "" #.])
]
