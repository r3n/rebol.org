REBOL [
    Title: "Rot-13"
    Date: 21-Oct-1999
    Version: 1.0.1
    File: %rot-13.r
    Author: "Allen Kamp"
    Usage: {To encode >> rot-13 "This is a test" == "Guvf vf n grfg" 
              To decode, just use rot-13 again >> rot-13 "Guvf vf n grfg" == "This is a test"
    }
    Purpose: "To Encode and Decode Rot-13 strings"
    Email: allenk@powerup.com.au
    Notes: {
              Rotates Roman alphabet chars by 13 places. Case is preserved.
              Used in Newsgroups to prevent accidental reading of content.
    }
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

rot-13: func [
    {Converts a string to or from Rot-13}
    data [any-string!]
    /local scrambled rot-chars rot-char
][
    rot-chars: {anabobcpcdqderefsfgtghuhivijwjkxklylmzmANABOBCPCDQDEREFSFGTGHUHIVIJWJKXKLYLMZM}
    scrambled: copy ""
    foreach char data [
        if none? (rot-char: select/case rot-chars char) [rot-char: char]
        insert tail scrambled :rot-char
    ]
    return scrambled
]

; example
; print rot-13 "Rebol Rules"
