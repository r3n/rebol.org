REBOL [
    Title: "Color REBOL Code in HTML"
    Date: 21-Jul-2005 ;29-May-2003
    File: %color-code.r
    Author: "Carl Sassenrath"
    Purpose: {
        Colorize source code based on datatype.  Result is HTML.
        This script is used to syntax color the library scripts.
    }
    History: [
        "29-May-2003 - Fixed deep parse rule bug."
        "21-Jul-2005 - Fixed bug if source contains bad chars."
    ]
    library: [
        level: 'intermediate 
        platform: all 
        type: [tool] 
        domain: 'text-processing 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

color-coder: make object! [

    ; Set the color you want for each datatype:
    colors: [
         char!          0.120.40
         date!          0.120.150
         decimal!       0.120.150
         email!         0.120.40
         file!          0.120.40
         integer!       0.120.150
         issue!         0.120.40
         money!         0.120.150
         pair!          0.120.150
         string!        0.120.40
         tag!           0.120.40
         time!          0.120.150
         tuple!         0.120.150
         url!           0.120.40
         refinement!    160.120.40
         cmt            10.10.160
    ]

    out: none

    emit: func [data] [repend out data]

    to-color: func [tuple][
        result: copy "#"
        repeat n 3 [append result back back tail to-hex pick tuple n]
        result
    ]

    emit-color: func [value start stop /local color][
        either none? :value [color: select colors 'cmt][
            if path? :value [value: first :value]
            color: either word? :value [
                any [
                    all [value? :value any-function? get :value 140.0.0]
                    all [value? :value datatype? get :value 120.60.100]
                ]
            ][
                any [select colors type?/word :value]
            ]
        ]
        either color [ ; (Done this way so script can color itself.)
            emit ["-[" {-font color="} to-color color {"-} "]-"
                copy/part start stop "-[" "-/font-" "]-"]
        ][
            emit copy/part start stop
        ]
    ]

    set 'color-code func [
        "Return color source code as HTML."
        text [string!] "Source code text"
        /local str new value
    ][
        out: make string! 3 * length? text

        set [value text] load/next/header detab text
        emit copy/part head text text
        spc: charset [#"^(1)" - #" "] ; treat like space

        parse/all text blk-rule: [
            some [
                str:
                some spc new: (emit copy/part str new) |
                newline (emit newline)|
                #";" [thru newline | to end] new: 
                    (emit-color none str new) |
                [#"[" | #"("] (emit first str) blk-rule |
                [#"]" | #")"] (emit first str) break |
                skip (
                    set [value new] load/next str
                    emit-color :value str new
                ) :new
            ]
        ]

        foreach [from to] reduce [ ; (join avoids the pattern)
            "&" "&amp;" "<" "&lt;" ">" "&gt;"
            join "-[" "-" "<" join "-" "]-" ">"
        ][
            replace/all out from to
        ]

        insert out {<html><body bgcolor="#ffffff"><pre>}
        append out {</pre></body></html>}
    ]
]

;Example: write %color-code.html color-code read %color-code.r
