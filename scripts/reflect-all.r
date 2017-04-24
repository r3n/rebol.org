REBOL [
    Title: "Reflect all Directions"
    Date: 20-May-2000
    File: %reflect-all.r
    Purpose: "Displays all reflection directions."
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


pic: %bay.jpg
spec: [styles refl-style]
refl-style: stylize [refl: box with [make font [color: red size: 24]]]
vectors: [0x0 0x1 0x-1 | 1x0 1x1 1x-1 | -1x0 -1x1 -1x-1]

foreach v vectors [
    append spec either word? v ['return][
        compose/deep [refl pic form (v) effect [reflect (v)]]
    ]
]


view layout spec
