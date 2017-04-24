REBOL [
    Title: "Gradient Colorize"
    Date: 20-May-2000
    File: %gradcol-all.r
    Purpose: "Displays gradient colorize in all directions."
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

pic: load-thru/binary http://www.rebol.com/view/bay.jpg
spec: [style grad box font [color: yellow size: 24]]
vectors: [0x0 0x1 0x-1 | 1x0 1x1 1x-1 | -1x0 -1x1 -1x-1]

foreach v vectors [
    append spec either word? v ['return][
        compose/deep [grad pic form (v) effect [gradcol (v) 200.0.0 0.0.200]
        ]
    ]
]

view layout spec
