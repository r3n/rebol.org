REBOL [
    file: %file-size-comparison-ctx.r
    date: 24-May-2006
    title: "file-size-comparison-ctx"
    purpose: "Compare file sizes using a friendly dialect"
    author: "Gregg Irwin"
    library: [
        level: 'intermediate
        platform: 'all
        type: [module function dialect]
        domain: [files]
        tested-under: [view 1.3.2 on WinXP by Gregg]
        support: none
        license: 'public-domain ; no warranty expressed or implied
        see-also: [%file-date-comparison-ctx.r %collect.r]
    ]
    comment: {Uses COLLECT function}
]

file-size-comparison-ctx: context [
    =negate-op?: none
    =or-equal?: none
    =op: none
    =size: 0
    =size-mul: 1
    =parse-end-mark: none

    make-lit-word: func [val] [to lit-word! :val]
    lit-lesser: make-lit-word "<"
    lit-greater: make-lit-word ">"
    lit-lesser-or-equal: make-lit-word "<="
    lit-greater-or-equal: make-lit-word ">="

    size=: [
        (=size-mul: 1)
        [
            set =size number!
            | set =size file! (=size: size? =size)
        ]
        opt [
            'bytes ; no change to size-mul
            | ['kilobytes | 'KB] (=size-mul: 1024.0)
            | ['megabytes | 'MB] (=size-mul: 1048576.0)
            | ['gigabytes | 'GB] (=size-mul: 1073741824.0)
        ]
        (=size: =size * =size-mul)
    ]
    word-comparison=: [
        [
            ['more | 'bigger | 'larger | 'greater] (=op: 'greater)
            | ['less | 'smaller] (=op: 'lesser)
        ] 'than
        opt ['or 'equal 'to (=or-equal?: true)]
    ]
    lit-comparison=: [
        lit-lesser             (=or-equal?: false  =op: 'lesser)
        | lit-greater          (=or-equal?: false  =op: 'greater)
        | lit-lesser-or-equal  (=or-equal?: true   =op: 'lesser)
        | lit-greater-or-equal (=or-equal?: true   =op: 'greater)
    ]
    rules=: [
        (=negate-op?: =or-equal?: =op: =parse-end-mark: none)
        opt 'if opt ['size | size?]
        opt [['no | 'not] (=negate-op?: true)]
        [word-comparison= | lit-comparison=]
        (if =negate-op? [=op: pick [greater lesser] =op = 'lesser])
        (=op: to word! rejoin [=op either =or-equal? ['-or-equal] [""] '?])
        size=
        =parse-end-mark:
    ]

    set 'size-comparison-cmd? func [input [block!]] [
        parse input rules=
        return =parse-end-mark
    ]

    set 'make-file-size-comparison-func func [spec] [
        parse spec rules=
        either =parse-end-mark [
            func [file] reduce [=op 'size? 'file =size]
        ] [none]
    ]

    set 'files-matching-size-spec func [
        files [block!]
        spec [block!]
    ][
        if match?: make-file-size-comparison-func spec [
            collect 'keep [
                foreach file files [if match? file [keep: file]]
            ]
        ]
    ]
]
; Examples
;foreach file files-matching-size-spec read %. [size >= 1024] [print [file size? file]]
;foreach file files-matching-size-spec read %. [less than or equal to 1024] [print [file size? file]]
;foreach file files-matching-size-spec read %. [>= 64 kb] [print [file size? file]]
;foreach file files-matching-size-spec read %. [smaller than 2 mb] [print [file size? file]]
;foreach file files-matching-size-spec read %. [bigger than .5 mb] [print [file size? file]]
;foreach file files-matching-size-spec read %. [larger than %view.exe] [print [file size? file]]
