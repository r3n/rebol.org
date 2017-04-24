REBOL [
    Title: "Parse REBOL Source"
    Date: 29-May-2003
    File: %parse-code.r
    Author: "Carl Sassenrath"
    Purpose: "An example of how to parse REBOL source code."
    History: "29-May-2003 - Fixed deep parse recursion bug."
    library: [
        level: 'intermediate 
        platform: none 
        type: [tool] 
        domain: 'text-processing 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

parse-code: func [
    "Parse REBOL source code."
    text /local str new
][
    parse text blk-rule: [
        some [  ; repeat until done
            str:
            newline |
            #";" [thru newline | to end] new: (probe copy/part str new) |
            [#"[" | #"("] blk-rule |
            [#"]" | #")"] break |
            skip (set [value new] load/next str  probe :value) :new
        ]
    ]
]

;example: parse-code read %parse-code.r
