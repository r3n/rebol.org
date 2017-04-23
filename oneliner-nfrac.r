Rebol [
    Title: "Fractional length"
    Date: 20-Jul-2003
    File: %oneliner-nfrac.r
    Purpose: {nfrac 33 => 0 ; nfrac "456" => 0 ; nfrac 0.2104 => 4 ; nfrac "1256.63" => 2 ; nfrac
1.0 => 0}
    One-liner-length: 53
    Version: 1.0.0
    Author: {collective contribution on www.codeur.org/forum/forum.php?theme=17}
    Library: [
        level: 'beginner
        platform: 'all
        type: [How-to FAQ one-liner function]
        domain: [math]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
nfrac: func [d][length? second parse join d ".." "."]
