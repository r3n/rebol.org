REBOL [
    Title: "REBOL Script Cleaner (Pretty Printer)"
    Date: 29-May-2003
    File: %clean-script.r
    Author: "Carl Sassenrath"
    Purpose: {
        Cleans (pretty prints) REBOL scripts by parsing the REBOL code
        and supplying standard indentation and spacing.
    }
    History: [
    "Carl Sassenrath" 1.1.0 29-May-2003 {Fixes indent and parse rule.}
    "Carl Sassenrath" 1.0.0 27-May-2000 "Original program."
    ]
    library: [
        level: 'intermediate 
        platform: all 
        type: [tool] 
        domain: [text text-processing]
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

script-cleaner: make object! [

    out: none ; output text
    spaced: off ; add extra bracket spacing
    indent: "" ; holds indentation tabs

    emit-line: func [] [append out newline]

    emit-space: func [pos] [
        append out either newline = last out [indent] [
            pick [#" " ""] found? any [
                spaced
                not any [find "[(" last out find ")]" first pos]
            ]
        ]
    ]

    emit: func [from to] [emit-space from append out copy/part from to]

    set 'clean-script func [
        "Returns new script text with standard spacing (pretty printed)."
        script "Original Script text"
        /spacey "Optional spaces near brackets and parens"
        /local str new
    ] [
        spaced: found? spacey
        clear indent
        out: append clear copy script newline
        parse script blk-rule: [
            some [
                str:
                newline (emit-line) |
                #";" [thru newline | to end] new: (emit str new) |
                [#"[" | #"("] (emit str 1 append indent tab) blk-rule |
                [#"]" | #")"] (remove indent emit str 1) break |
                skip (set [value new] load/next str emit str new) :new
            ]
        ]
        remove out ; remove first char
    ]
]

;example: print clean-script read %clean-script.r