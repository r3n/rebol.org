REBOL [
    file: %file-date-comparison-ctx.r
    date: 24-May-2006
    title: "file-date-comparison-ctx"
    purpose: "Compare file dates using a dialect"
    author: "Gregg Irwin"
    library: [
        level: 'intermediate
        platform: 'Windows ; not sure about file modes on other OSs
        type: [module function dialect]
        domain: [files]
        tested-under: [view 1.3.2 on WinXP by Gregg]
        support: none
        license: 'public-domain ; no warranty expressed or implied
        see-also: [%file-size-comparison-ctx.r %collect.r]
    ]
    comment: {Uses COLLECT function}
]

file-date-comparison-ctx: context [
    =negate-op?: none
    =or-equal?: none
    =op: none
    =parse-end-mark: none
    =attr: 'modification-date
    =date: none

    make-lit-word: func [val] [to lit-word! :val]
    lit-equal: make-lit-word "="
    lit-lesser: make-lit-word "<"
    lit-greater: make-lit-word ">"
    lit-lesser-or-equal: make-lit-word "<="
    lit-greater-or-equal: make-lit-word ">="

    attr=: [
        ['changed | 'modified | 'upated | 'modification-date]
        | ['created | 'creation-date | 'create-date] (=attr: 'creation-date)
        | ['accessed | 'access-date] (=attr: 'access-date)
    ]
    date=: [
        [
            set =date date!
            | set =date file!      (=date: get-modes =date =attr)
            | 'yesterday (=date: now/date - 1)
            | 'today     (=date: now/date)
            | 'tomorrow  (=date: now/date + 1)
        ]
    ]
    word-comparison=: [
        [
            ['after | 'since | 'newer 'than] (=op: 'greater)
            | ['before | 'older 'than] (=op: 'lesser)
        ]
        opt ['or 'equal 'to (=or-equal?: true)]
    ]
    lit-comparison=: [
        lit-equal              (=or-equal?: false  =op: 'equal)
        | lit-lesser           (=or-equal?: false  =op: 'lesser)
        | lit-greater          (=or-equal?: false  =op: 'greater)
        | lit-lesser-or-equal  (=or-equal?: true   =op: 'lesser)
        | lit-greater-or-equal (=or-equal?: true   =op: 'greater)
    ]
    rules=: [
        (
            =negate-op?: =or-equal?: =op: =parse-end-mark: =date: none
            =attr: 'modification-date
        )
        opt 'if opt ['date | 'date?]
        opt [['no | 'not] (=negate-op?: true)]
        opt ['date | 'date?]
        opt attr=
        [word-comparison= | lit-comparison=]
        (if =negate-op? [=op: pick [greater lesser] =op = 'lesser])
        (=op: to word! rejoin [=op either =or-equal? ['-or-equal] [""] '?])
        date=
        =parse-end-mark:
    ]

    set 'date-comparison-cmd? func [input [block!]] [
        parse input rules=
        return =parse-end-mark
    ]

    set 'make-file-date-comparison-func func [spec] [
        parse spec rules=
        either =parse-end-mark [
            func [file] reduce [=op  'get-modes 'file to lit-word! =attr  =date]
        ] [none]
    ]

    set 'files-matching-date-spec func [
        files [block!]
        spec [block!]
    ][
        if match?: make-file-date-comparison-func spec [
            collect 'keep [
                foreach file files [if match? file [keep: file]]
            ]
        ]
    ]
]
; Examples
;foreach file files-matching-date-spec read %. [accessed after 1-jan-2006] [print [file modified? file]]
;foreach file files-matching-date-spec read %. [date < 1-jan-2006] [print [file modified? file]]
