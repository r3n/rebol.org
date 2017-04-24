Rebol [
    Title: "Morse code"
    Date: 20-Jul-2003
    File: %oneliner-morse-code.r
    Purpose: {Encodes a sentence into morse code. This version is a bit suboptimal so that the
html generator won't destroy it.}
    One-liner-length: 130
    Version: 1.0.0
    Author: "Johan Roennblom"
    Library: [
        level: 'intermediate
        platform: none
        type: [How-to FAQ one-liner]
        domain: [math dialects]
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]
foreach c ask{Message:}[l: index? find{ etinamsdrgukwohblzfcpövxäqüyj}c while[l >= 2][prin pick{-.}odd? l l: l / 2]prin" "]print""
