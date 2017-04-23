REBOL [
    Title: "Fish 'n Strips"
    Date: 6-Jun-2000
    File: %fish.r
    Author: "Allen Kamp"
    Purpose: "Fun with Transparency"
    Email: allenk@powerup.com.au
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

trans: stylize [
    r: image with [image: none color: none effect: [colorize 180.10.10]]
    g: r with [effect: [colorize 10.180.10]]
    b: r with [effect: [colorize 10.10.240]]
]

view/title layout [styles trans
    size 200x200
    backdrop 240.240.204
    at 20x20 r 20x160
    at 60x20 g 20x150 
    at 100x20 b 20x140 
    at 20x20 r 160x20
    at 20x60 g 150x20 
    at 20x100 b 140x20 
    ] "Fish 'n Strips"
