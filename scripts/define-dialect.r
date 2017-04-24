REBOL [
    Title:   "#define dialected function"
    File:    %define-dialect.r
    Author:  "Gregg Irwin"
    Version: 0.0.1
    Date:    23-sep-2003
    Purpose: {
        Make it easier to map C #define statements. Eliminates
        the need to manually call datatype conversion functions
        for each item.
    }
    Comment: {
        The block you pass to the function is a dialect. In the
        dialect you can specify word-value pairs and functions
        used to map different types of values as they are
        processed.

        MAP is used to tell the processor what function to call
        when it encounters a particular datatype value. The
        function specified should take a single value.

            'map datatype function-name

            ; call to-integer when a binary! value is found.
            [map binary! to-integer]

        Other than that, just specify a word followed by a value.
        The resulting block will contain set-word! values for
        each word, followed by its value - which may have been
        converted by a function that was mapped to its original
        datatype.
    }
    Example: {
        do define [
            map binary! to-integer
            map issue!  to-integer

            my-name "Gregg"
            mapped-binary  #{00000001}
            mapped-issue   #000fffff
        ]
        print [my-name mapped-binary mapped-issue]
    }
    library: [
        level:    'intermediate
        platform: 'all
        type:     [function]
        domain:   [dialects parse external-library]
        tested-under: [view 1.2.8.3.1 on W2K]
        support:  none
        license:  none
        see-also: none
    ]
]


define: func [
    block [any-block!]
    /local type fn word val result map
] [
    result: make block length? block
    map: copy []
    either parse block [
        some [
            'map set type word! set fn word! (
                type: do type
                either word: find/skip map type 2 [
                    change next word get fn
                ][
                    append map reduce [type get fn]
                ]
            )
            | set word any-word! set val any-type! (
                append result reduce [
                    to set-word! word
                    either fn: select map type? val [fn val][val]
                ]
            )
        ]
        to end
    ] [result][none]
]


comment [ ; test examples
    print mold defs: define [
        map binary!  to-integer
        map issue!   to-integer

        PFD_DOUBLEBUFFER  #{00000001}
        PFD_STEREO  #{00000002}
        PFD_DRAW_TO_WINDOW  #00000004
        GL_ALL_ATTRIB_BITS  #000fffff
    ]
    do defs
    print [
        PFD_DOUBLEBUFFER
        PFD_STEREO
        PFD_DRAW_TO_WINDOW
        GL_ALL_ATTRIB_BITS
    ]

    halt
]