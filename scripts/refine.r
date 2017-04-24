REBOL [
    Title: "Refine"
    Date: 21-Dec-2001
    Version: 0.0.1
    File: %refine.r
    Author: "Romano Paolo Tenca"
    Purpose: {"Add refinement(s) to a word/path"
}
    Email: rotenca@libero.it
    Web: http://web.tiscali.it/anarkick/index.r
    library: [
        level: 'intermediate 
        platform: none 
        type: [tool] 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

refine: func [
    "Add refinement(s) to a word/path"
    path [lit-word! word! path!] "The word/path to refine"
    refs [word! lit-word! block!] "The word(s) to add"
    /only "Add the refinement also if its value is none!"
][
    refs: append clear [refs] :refs
    if not only [
        refs: head while [not tail? refs] [
            refs: either not all[value? first refs get/any first refs] [
                remove refs
            ][
                next refs
            ]
        ]
    ]
    either not empty? refs [
        head insert tail to path! :path refs
    ][
        :path
    ]
]

;this can be removed
if not value? 'my_local_user [
    help refine
    ask "See code for examples. Return to Quit - Esc for Shell "
    ;examples
    comment [
        x: refine/only 'find 'part
        print x "abcd" "c" 3
        x: refine/only :x 'tail
        print x "abcd" "c" 3
        x: refine/only 'find [part tail]
        print x "abcd" "c" 3
        use [part tail][
            tail: none
            part: true
            x: refine 'find [part tail]
            print x "abcd" "c" 3
        ]
        halt
    ]
]                                                        