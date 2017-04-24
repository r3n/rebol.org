REBOL [
    Title:  "Library Interface Dialect"
    File:   %lib-dialect.r
    Date: 14-Apr-2006
    Author: "Gregg Irwin"
    Purpose: {
        Allow for a more concise way to define library routine 
        interfaces.
    }
    library: [
        level: 'intermediate
        platform: 'all
        type: [function dialect]
        domain: [external-library win-api]
        tested-under: [Windows]
        support: none
        license: 'BSD
        see-also: none
    ]

]

lib-dialect-ctx: context [
;     lib-ctx: make object! [file: lib: none free: does [free lib]]
;     lib-spec: none

    lib: none
    def-rtn-type: none

    name-mods: copy []
    mod-name: func [name] [do join name-mods name]

    ; dump/trace option to show generated code?

    ;has-rtn-type?: does [all [rtn-type  'none <> rtn-type]]
    ; lib is a global word reference in this func.
    make-dll-func: func [reb-name spec rtn-type name] [
        spec: copy any [spec []]
        if all [rtn-type  'none <> rtn-type] [
            append spec compose/deep [return: [(rtn-type)]]
        ]
        ;print ['make-dll-func reb-name mold spec rtn-type mold  mod-name any [name  form reb-name]]
        set reb-name make routine! spec lib  mod-name any [name  form reb-name]
    ]

    data-type: [
        'none | 'char | 'short | 'long | 'integer! | 'string! | 'decimal!
        ; TBD add struct support ?
    ]

    func-decl: [
        (spec: name: none  rtn-type: def-rtn-type)
        set reb-name word!          ;(print reb-name)
        any [
              [set spec block!]     ;(print mold spec)
            | [opt ['returns | 'as] set rtn-type data-type]  ;(print rtn-type)
            | [opt 'calls set name string!]    ;(print name)
        ]
        (make-dll-func reb-name spec rtn-type name)
    ]

    ; You can use this multiple times, e.g. grouping functions by return
    ; type and using it before each group.
    set-def-rtn-type: [
        opt 'set ['def-rtn-type | 'default-return-type]
        set def-rtn-type data-type
    ]

    rules: [
        ['lib | 'library] set file file! (lib: load/library file) ;append lib-spec compose [file: (file)]
        opt [
            ['modify-import-names | 'mod-imports] set name-mods block!
        ]
        any [set-def-rtn-type | func-decl]
    ]

    set 'make-routines func [spec [any-block!]] [
        clear name-mods
        parse spec rules
    ]

;     set 'make-library-interface func [spec] [
;         lib-spec: copy []
;         clear name-mods
;         parse spec rules
;     ]

]

