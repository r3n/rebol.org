Rebol [
    Title: "Paint drops"
    Date: 20-Jul-2003
    File: %oneliner-paint-drops.r
    Purpose: "A surface is filled with colored drops."
    One-liner-length: 132
    Version: 1.0.0
    Author: "Vincent Ecuyer"
    Library: [
        level: 'intermediate
        platform: none
        type: [How-to FAQ one-liner]
        domain: [vid gui]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
view layout[b: box rate 9 effect[draw[pen(random snow)circle(random 99x99)2]blur]box 1x1 rate 9 effect[draw[(b/image: to-image b)]]]
