REBOL [
    Title: "Gradient in all Directions"
    Date: 20-May-2000
    File: %grad-all.r
    Author: "Carl Sassenrath"
    Purpose: "Displays all gradient directions."
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

spec: [style grad box 160x160 font [color: yellow size: 24]]
vectors: [0x0 0x1 0x-1 | 1x0 1x1 1x-1 | -1x0 -1x1 -1x-1]

foreach v vectors [
    append spec either word? v ['return][
        compose/deep [grad form (v) effect [gradient (v) 200.0.0 0.0.200]
        ]
    ]
]

view layout spec
