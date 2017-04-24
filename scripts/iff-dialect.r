REBOL [
    Title: "IFF dialect"
    Date: 16-Jan-2013
    Version: 1.1.0
    File: %iff-dialect.r
    Author: "Vincent Ecuyer"
    Purpose: {Electronic Arts Interchange File Format (IFF) dialect}
    Usage: {
        >> do %iff-dialect.r
        >> iff-binary: make-iff [dialect block]
        >> write/binary destination iff-binary

        EA-IFF85 structure:

        <form-type> <size> <form-id> [
            <chunk-id> <size> [...]
            <form-type> <size> <form-id> [
                <chunk-id> <size> [...]
                <chunk-id> <size> [...]
            ]
            <chunk-id> <size> [...]
            <chunk-id> <size> [...]
        ]
        
        where <form-type> is one of "FORM" "CAT " "LIST" "PROP".

        This dialect allows following styles (same results):

        [form "TESTS"          ; ids are truncated to 4 chars
            [a 2.3.4 b "bla"]  ; ids are padded to 4 chars
        ]

        [form test [           ; ids are converted to uppercase strings
            "A   " [2.3.4]     ;
            b      ["bl" "a"]  ;
        ]]

        [test [                ; "FORM" is default form-type
            A #{020304}        ;
            B #{626C61}        ;
        ]]

        to write text into Amiga clipboard (IFF FTXT format):

        write/binary %/clips/0 make-iff [
            form ftxt [
                chrs (replace/all read %iff-dialect.r newline "^(0A)")
            ]
        ]
    }
    History: [
        1.1.0 16-Jan-2013 "Added REBOL3 compatibility"
        1.0.1 25-Mar-2005 "Bugfix: infinite loop with empty blocks"
        1.0.0 31-Dec-2003 "First version"
    ]
    Library: [
        level: 'intermediate
        platform: 'all
        type: [dialect module]
        domain: [dialects files parse]
        tested-under: [
        	core 2.7.8.2.5   on [Macintosh osx-x86]
        	core 2.101.0.2.5 on [Macintosh osx-x86]
        ]
        support: none
        license: 'public-domain
        see-also: none
    ]
]

ctx-iff: context [
    to-bin: func [value] either system/version > 2.100.0 [
        [copy skip tail to-binary value -4]
    ][
        [load join "#{" [to-hex value "}"]]
    ]
    v: none
    out: copy #{}
    offsets: copy []
    pos: none
    clear-all: does [clear out clear offsets v: none]
    prep-size: does [
        append offsets length? out
        append out #{00000000}
    ]
    set-size: does [
        change skip out last offsets
            to-bin (length? out) - 4 - last offsets
        remove back tail offsets
    ]
    id-form: ["FORM" | 'form]
    id-cat:  ["CAT " | 'cat ]
    id-list: ["LIST" | 'list]
    id-prop: ["PROP" | 'prop]
    form-type: [
        id-form (append out id-form/1) |
        id-cat  (append out id-cat/1 ) |
        id-list (append out id-list/1) |
        id-prop (append out id-prop/1)    
    ]
    iff: [[form-type | (append out id-form/1)] iff-form]
    iff-form: [
        (prep-size)
        id
        [end | pos: block! :pos into [any [[form-type iff-form] | chunk]]]
        (set-size)
    ]
    id: [[
        set v string!   |
        set v issue!    (v: mold v) |
        set v any-word! (v: uppercase form v)
    ](append out copy/part join v "    " 4)]
    chunk: [
        id
        (prep-size)
        [end | pos: block! :pos into [any data] | data]
        (set-size)
        (if odd? length? out [append out #{00}])
    ]
    data: [
        'word set v integer! (append out skip to-bin v 2) |
        'long set v integer! (append out to-bin v) |
        'byte set v integer! (append out to-char v) |
        set v binary!        (append out v) |
        set v any-string!    (append out to-binary v) |
        set v image!         (append out to-binary v) |
        set v integer!       (append out to-binary to-char v) |
        set v tuple!         (append out to-binary v) |
        'none                |
        pos: block! :pos into [any data] |
        set v 1 skip         (append out to-binary v)
    ]
    if system/version > 2.100.0 [
        throw-on-error: :do
    ]
    set 'make-iff func [
        "Build an IFF binary"
        [catch]
        value [block!] "Definition block"
    ][
        throw-on-error [
            clear-all
            if not parse compose/deep value iff [
                clear-all
                do make error! "Bad IFF definition"
            ]
            value: copy out
            clear-all
            value
        ]
    ]
]