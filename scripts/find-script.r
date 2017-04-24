REBOL [
    Title: "Find script"
    Author: "Ladislav Mecir"
    Date: 12-Nov-2012/0:11:35+1:00
    File: %find-script.r
    Purpose: {The FIND-SCRIPT function from R3.}
]

whitespace: charset [#"^A" - #" " #"^(7F)"]

find-script: func [
    {Find a script header. Return starting position.}
    script [string! binary!]
    /local result
] [
    parse/all script [
        any [
            any whitespace
            script:
            opt [#"[" any whitespace]
            "rebol"
            any whitespace
            #"["
            (result: script)
            break
            | thru #"^(line)"
        ]
    ]
    result
]
