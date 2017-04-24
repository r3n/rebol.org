REBOL [
    Title: "Decode Charset Function"
    Date: 23-Aug-2001
    Version: 1.0.0
    File: %decode-charset.r
    Author: "Nenad Rakocevic"
    Purpose: "Converts 'charset values to something readable"
    Email: dockimbel@free.fr
    Example: {
^-^-decode-charset net-utils/url-parser/alpha-num
^-}
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

decode-charset: func [data [bitset!] /local out byte][
    out: make string! 100
    data: to-binary data
    forall data [
        byte: to-integer data/1
        repeat i 8 [
            if 1 = (1 and byte) [
                append out to-char (i - 1) + (8 * ((index? data) - 1))
            ]
            byte: to-integer (byte / 2)
        ]
    ]
    out
]                           