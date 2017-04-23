REBOL [
    Title: "Import and Validate User Input"
    Author: "Christopher Ross-Gill"
    Date: 5-Jun-2007
    Version: 0.1.1
    File: %filtered-import.r
    Rights: {Copyright (c) 2007, Christopher Ross-Gill}
    Purpose: {Filters user input based upon a given spec}
    Home: http://www.ross-gill.com/QM/
    Comment: {Extracted from the QuarterMaster web framework}
    History: [
        0.1.0 26-Apr-2007 chrisrg "First standalone release"
        0.1.1 5-Jun-2007 chrisrg "Fixed optional value handling"
    ]
    Library: [
        level: 'intermediate
        platform: 'all
        type: [dialect function]
        domain: [cgi db dialects parse ui]
        tested-under: [Core 2.6.2 WinXP OSX]
        support: none
        license: 'cc-by-sa
        see-also: ""
    ]
    Notes: {}
]

context [
    range!: :pair!

    pop: func [stack [series! port!] /local val][
        val: pick stack 1
        remove stack
        :val
    ]

    envelope: func [val [any-type!]][either any-block? val [val][reduce [val]]]

    add-to: func [ser key val][
        key: envelope key
        map key func [key][as word! key]
        if find key none! [return none]
        until [
            ser: any [
                find/tail ser key/1
                insert tail ser key/1
            ]

            key: next key

            switch type?/word ser/1 [
                none! [unless tail? key [insert/only ser ser: copy []]]
                string! [change/only ser ser: envelope ser/1]
                block! [ser: ser/1]
            ]

            if tail? key [append ser val]
        ]
    ]

    get-from: func [series 'key][
        key: copy envelope get key
        while [all [not tail? key any-block? series]][
            series: select series pop key
        ]
        all [tail? key series]
    ]

    comment {[
        chars-n:  charset [#"0" - #"9"]   ; numeric
        chars-la: charset [#"a" - #"z"]   ; lower-alpha
        chars-ua: charset [#"A" - #"Z"]   ; upper-alpha
        chars-a:  union chars-la chars-ua ; alphabetic
        chars-an: union chars-a chars-n   ; alphanumeric
        chars-hx: union chars-n charset [#"A" - #"F" #"a" - #"f"] ; hex
        chars-ud: union chars-an charset "*-._!~',"               ; url decode
        chars-u:  union chars-ud charset ":+%&=?"                 ; url
        chars-id: union chars-n union chars-la charset "-_"       ; id
        chars-w1: union chars-a charset "*-._!+?&|"  ; word-first-letter
        chars-w*: union chars-w1 chars-n             ; word
        chars-f:  insert copy chars-an #"-"          ; file
        chars-p:  union chars-an charset "-_!+%"     ; path
        chars-sp: charset " ^-"                      ; space
        chars-up: charset [#"^(80)" - #"^(FF)"]      ; above ascii
        chars: complement nochar: charset " ^-^/"    ; no-space
    ]}

    chars-n:  #[bitset! 64#{AAAAAAAA/wMAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=}]
    chars-la: #[bitset! 64#{AAAAAAAAAAAAAAAA/v//BwAAAAAAAAAAAAAAAAAAAAA=}]
    chars-ua: #[bitset! 64#{AAAAAAAAAAD+//8HAAAAAAAAAAAAAAAAAAAAAAAAAAA=}]
    chars-a:  #[bitset! 64#{AAAAAAAAAAD+//8H/v//BwAAAAAAAAAAAAAAAAAAAAA=}]
    chars-an: #[bitset! 64#{AAAAAAAA/wP+//8H/v//BwAAAAAAAAAAAAAAAAAAAAA=}]
    chars-hx: #[bitset! 64#{AAAAAAAA/wN+AAAAfgAAAAAAAAAAAAAAAAAAAAAAAAA=}]
    chars-ud: #[bitset! 64#{AAAAAIJ0/wP+//+H/v//RwAAAAAAAAAAAAAAAAAAAAA=}]
    chars-u:  #[bitset! 64#{AAAAAKJ8/wf+//+H/v//RwAAAAAAAAAAAAAAAAAAAAA=}]
    chars-id: #[bitset! 64#{AAAAAAAg/wMAAACA/v//BwAAAAAAAAAAAAAAAAAAAAA=}]
    chars-w1: #[bitset! 64#{AAAAAEJsAID+//+H/v//FwAAAAAAAAAAAAAAAAAAAAA=}]
    chars-w*: #[bitset! 64#{AAAAAEJs/4P+//+H/v//FwAAAAAAAAAAAAAAAAAAAAA=}]
    chars-f:  #[bitset! 64#{AAAAAAAg/wP+//8H/v//BwAAAAAAAAAAAAAAAAAAAAA=}]
    chars-p:  #[bitset! 64#{AAAAAKJo/wP+//+H/v//BwAAAAAAAAAAAAAAAAAAAAA=}]
    chars-sp: #[bitset! 64#{AAIAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=}]
    chars-up: #[bitset! 64#{AAAAAAAAAAAAAAAAAAAAAP////////////////////8=}]
    chars:    #[bitset! 64#{//n///7///////////////////////////////////8=}]
    nochar:   #[bitset! 64#{AAYAAAEAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=}] 

    utf-2: #[bitset! 64#{AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/////wAAAAA=}]
    utf-3: #[bitset! 64#{AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP//AAA=}]
    utf-4: #[bitset! 64#{AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA/wA=}]
    utf-5: #[bitset! 64#{AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA8=}]
    utf-b: #[bitset! 64#{AAAAAAAAAAAAAAAAAAAAAP//////////AAAAAAAAAAA=}]

    utf-8: [utf-2 1 utf-b | utf-3 2 utf-b | utf-4 3 utf-b | utf-5 4 utf-b]

    interpolate: func [body [string!] escapes [any-block!] /local out][
        body: out: copy body

        parse/all body [
            any [
                to #"%" body: (
                    body: change/part body reduce any [
                        select/case escapes body/2 body/2
                    ] 2
                ) :body
            ]
        ]

        out
    ]

    id: [chars-la 0 15 chars-id]
    word: [chars-w1 0 25 chars-w*]
    number: [integer!]
    integer: [opt #"-" number]

    masks: reduce [
        issue!    [some chars-u]
        logic!    ["true" | "on" | "yes"]
        word!     [word]
        url!      [id #":" some [chars-u | #":" | #"/"]]
        email!    [some chars-u #"@" some chars-u]
        path!     [word 0 3 [#"/" [word | integer]]]
        integer!  [integer]
        'positive [number]
        'id       [id]
        'key      [word 0 6 [#"." word]]
    ]

    system/words/as: as: func [
        [catch] type [datatype!] value [any-type! none!]
        /where format [none! block! word!]
    ][
        case/all [
            word? format [format: select masks format]
            none? format [format: select masks type]
            block? format [
                unless parse/all form value format [return #[none]]
            ]
        ]

        attempt [make type value]
    ]

    result: errors: #[none]

    messages: [
        not-included "is not included in the list"
        excluded "is reserved"
        invalid "is missing or invalid"
        not-confirmed "doesn't match confirmation"
        not-accepted "must be accepted"
        empty "can't be empty"
        blank "can't be blank"
        too-long "is too long (maximum is %d characters)"
        too-short "is too short (minimum is %d characters)"
        wrong-length "is the wrong length (should be %d characters)"
        not-a-number "is not a number"
    ]

    else: #[none]
    otherwise: [
        ['else | 'or][
            set else string! | copy else any [word! string!]
        ] | (else: #[none])
    ]

    key: value: target: format: else: #[none]

    constraint: use [is is-not? is-or-length-is op val val-type range group][
        op: val: val-type: #[none]
        is: ['is | 'are]
        is-or-length-is: [
            [
                ['length | 'size] (val: length? value val-type: integer!)
                | (val: :value val-type: :type)
            ] is
        ]
        is-not?: ['not (op: #[false]) | (op: #[true])]

        [
            is [
                'accepted otherwise (
                    unless true = value [report not-accepted]
                ) |
                'confirmed opt 'by set val get-word! otherwise (
                    unless value = as/where :type get-from source to-word val format [
                        report not-confirmed
                    ]
                ) |
                is-not? 'within set group any-block! otherwise (
                    either found? find group value [
                        unless op [report excluded]
                    ][
                        if op [report not-included]
                    ]
                )
            ] |
            is-or-length-is [
                is-not? 'between [set range [range! | into [2 val-type]]] otherwise (
                    either op [
                        case [
                            val < target: range/1 [report too-short]
                            val > target: range/2 [report too-long]
                        ]
                    ][
                        unless any [
                            val < range/1
                            val > range/2
                        ][report excluded]
                    ]
                ) |
                ['more-than | 'after] set target val-type otherwise (
                    unless val > target [report too-short]
                ) |
                ['less-than | 'before] set target val-type otherwise (
                    unless val < target [report too-long]
                ) |
                is-not? set target val-type otherwise (
                    either value = target [
                        unless op [report wrong-length]
                    ][
                        if op [report wrong-length]
                    ]
                )
            ]
        ]
    ]

    humanize: func [word][uppercase/part replace/all form word "-" " " 1]

    report: func ['message [word!]][
        message: any [
            all [string? else else]
            all [block? else select else message]
            reform [humanize key any [select messages message ""]]
        ]
        unless select errors :key [repend errors [:key copy []]]
        append select errors :key interpolate message [
            #"w" [form key]
            #"W" [humanize key]
            #"d" [form target]
            #"t" [head remove back tail form type]
        ]
    ]

    system/words/import: import: func [
        "Imports and validates user input" [catch]
        source [block!] {User input: [word! any-type! ...]}
        spec [block!] {Importation and validation rules}
        /else word [word!] {A word to assign an error report to}
        /local required present constraints
    ][
        errors: copy []
        result: copy []

        bind constraint 'source
        bind spec 'self

        unless parse compose/deep/only spec [
            any [
                set key set-word! (key: to-word key)
                set required opt 'opt (required: required <> 'opt)
                set type word! (throw-on-error [type: to-datatype :type])
                set format opt block!
                otherwise

                (
                    value: get-from source key

                    present: not any [
                        none? value
                        empty? trim/head/tail form value
                    ]

                    either all [present value: as/where :type value format][
                        constraints: [any constraint]
                        repend result [key value]
                    ][
                        constraints: [to set-word! | to end]
                        case [
                            present [report invalid]
                            required [report blank]
                            not required [repend result [key none]]
                        ]
                    ]
                )

                constraints
            ]
        ][
            throw make error! "Could not parse Import specification"
        ]

        unless set any [word 'word] all [not empty? errors errors][result]
    ]
]