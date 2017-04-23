Rebol [
    Author: "Ladislav Mecir"
    Date: 12-May-2006/15:58+2:00
    Purpose: {REBOL code from the bindology article}
    File: %contexts.r
    Title: "Contexts"
]

do http://www.rebol.org/download-a-script.r?script-name=closure.r

spelling?: func [
    {return the spelling of a WORD}
    word [any-word!]
] [
	case [
    	word? :word [mold :word]
    	set-word? :word [head remove back tail mold :word]
    	true [next mold :word]
    ]
]

variable?: func [
    {is the given WORD a variable?}
    word [any-word!]
] [
    found? bind? :word
]

different-binding: func [
    {
    	for a given WORD yield a word having
        strict equal spelling, equal type and different binding
    }
    word [any-word!] {the given word}
] [
    bind :word case [
        'self = :word [use [self] ['self]]
        set-word? :word [make object! reduce [:word none]]
        true [first second make function! reduce ['self :word] [self]]
    ]
]

aliases?: func [
    {find out, if WORD1 and WORD2 are aliases}
    word1 [any-word!]
    word2 [any-word!]
] [
    found? all [
        equal? :word1 :word2
        not strict-equal? spelling? :word1 spelling? :word2
    ]
]

same-variable?: func [
	{are WORD1 and WORD2 the same variable?}
    word1 [any-word!]
    word2 [any-word!]
] [
    found? all [
        equal? :word1 :word2
        equal? bind? :word1 bind? :word2
    ]
]

aliases?: func [
    {find out, if WORD1 and WORD2 are aliases}
    word1 [any-word!]
    word2 [any-word!]
    /local context
] [
    found? all [
        equal? :word1 :word2
        (
            if context: any [bind? :word1 bind? :word2] [
                word1: in context :word1
                word2: in context :word2
            ]
            ; WORD1 and WORD2 have equal binding now
            not same? :word1 :word2
        )
    ]
]

context-words?: func [
	{get the words in a given CONTEXT}
	context [object!]
] [
	bind first context context
]

global-context: bind? 'system

global?: func [
    {find out if a WORD is global}
    word [any-word!]
] [
    same? global-context bind? :word
]

local?: func [
    {find out, if a WORD is local}
    word [any-word!]
] [
    not any [
        none? bind? :word
        global? :word
    ]
]

code-string: {
    'f 'g 'h
    use [g h] [
        colorize "USE 1"
        'f 'g 'h
        use [h] [
            colorize "USE 2"
            'f 'g 'h
        ]
    ]
}

emit: func [text [char! string! block!]] [
    append result either block? text [rejoin text] [text]
]

colorize: func [
    {emit a table row containing text and the colorized code block}
    text [string!]
    /local space?
] [
    emit ["^/|-^/| " text "^/| "]
    space?: ""
    parse code-block rule: [
        (
            emit [space? #"["]
            space?: ""
        )
        any [
            [
                set word any-word! (
                    emit [
                        space?
                        {<font color="}
                        case [
                            not bind? :word ["brown"]
                            global? :word ["blue"]
                            equal? bind? :word bind? code-block/6/4 ["red"]
                            equal? bind? :word bind? code-block/6/8/5 [
                                "magenta"
                            ]
                        ]
                        {">}
                        mold :word
                        </font>
                    ]
                ) | into rule | set word skip (
                    emit [space? mold :word]
                )
            ]
            (space?: " ")
        ]
        (emit #"]")
    ]
]

make-context-model: func [
	{context creation simulation}
    words [block!] {context words, needs to be non-empty}
] [
    bind? first use words reduce [reduce [first words]]
]

use-model: function [
    {USE simulation, works for non-empty WORDS block}
    [throw]
    words [block!] "Local word(s) to the block"
    body [block!] "Block to evaluate"
] [new-context] [
    unless empty? words [
        ; create a new context
        new-context: make-context-model words
        ; bind the body to the new Context
        bind body new-context
    ]
    do body
]

nm-use: func [
    {
        Defines words local to a block.
        Does't modify the BODY argument.
    }
    [throw]
    words [block!] {Local words to the block}
    body [block!] {Block to evaluate}
] [
    use words copy/deep body
]

spec-eval: func [
    {evaluate the SPEC like MAKE OBJECT! does}
    spec [block!]
] [
    any-type? catch [loop 1 spec]
]

make-object!-model: function [
    {MAKE OBJECT! simulation}
    spec [block!]
] [set-words object sw] [
    ; find all set-words in SPEC
    set-words: copy [self]
    parse spec [
        any [
            copy sw set-word! (append set-words sw) |
            skip
        ]
    ]
    ; create a context with the desired local words
    object: make-context-model set-words
    ; set 'self in object to refer to the object
    object/self: object
    ; bind the SPEC to the blank object
    bind spec in object 'self
    ; evaluate it
    spec-eval spec
    ; return the value of 'self as the result
    return get/any in object 'self
]

specbind: function [
    {bind only known-words}
    block [block!]
    known-words [block!]
] [p w bind-one kw] [
    bind-one: [
        p:
        [
            copy w any-word! (
                if kw: find known-words first w [
                    change p bind w first kw
                ]
            ) | copy w [path! | set-path! | lit-path!] (
                if kw: find known-words first first w [
                    change p bind w first kw
                ]
            ) | into [any bind-one] | skip
        ]
    ]
    parse block [any bind-one]
    block
]

make-proto: function [
    {MAKE PROTO simulation}
    proto [object!]
    spec [block!]
] [set-words object sw word value spc body pwords] [
	; get local words from proto
    set-words: copy first proto

    ; append all set-words from SPEC
    parse spec [
        any [
            copy sw set-word! (append set-words sw) |
            skip
        ]
    ]

    ; create a blank object with the desired local words
    object: make-context-model set-words
    object/self: object

    ; copy the contents of the proto
    pwords: bind first proto object
    repeat i (length? first proto) - 1 [
        word: pick next first proto i
        any-type? set/any 'value pick next second proto i
        any [
            all [string? get/any 'value set in object word copy value]
            all [
                block? get/any 'value
                value: specbind copy/deep value pwords
                set in object word value
            ]
            all [
                function? get/any 'value
                spc: load mold third :value
                body: specbind copy/deep second :value pwords
                set in object word func spc body
            ]
            any-type? set/any in object word get/any 'value
        ]
    ]

    bind spec object
    spec-eval spec
    return get/any in object 'self
]

locals?: func [
    {Get all locals from a spec block.}
    spec [block!]
    /args {get only arguments}
    /local locals item item-rule
] [
    locals: make block! 16
    item-rule: either args [
		[
			refinement! to end (item-rule: [end skip]) |
			set item any-word! (insert tail locals to word! :item) | skip
		]
	] [
		[
			set item any-word! (insert tail locals to word! :item) | skip
		]
	]
    parse spec [any item-rule]
    locals
]

set-words: func [
    {Get all set-words from a block}
    block [block!]
    /deep {also search in subblocks/parens}
    /local elem words rule here
] [
    words: make block! length? block
    rule: either deep [
        [
            any [
                set elem set-word! (
                    insert tail words to word! :elem
                ) | here: [block! | paren!] :here into rule | skip
            ]
        ]
    ] [
        [
            any [
                set elem set-word! (
                    insert tail words to word! :elem
                ) | skip
            ]
        ]
    ]
    parse block rule
    words
]

funcs: func [
    {Define a function with auto local and static variables.}
    [throw]
    spec [block!] {Help string (opt) followed by arg words with opt type and string}
    init [block!] {Set-words become static variables, shallow scan}
    body [block!] {Set-words become local variables, deep scan}
    /local svars lvars
] [
    ; Preserve the original Spec, Init and Body
    spec: copy spec
    init: copy/deep init
    body: copy/deep body
    ; Collect static and local variables
    svars: set-words init
    lvars: set-words/deep body
    unless empty? svars [
        ; create the static context and bind Init and Body to it
        use svars reduce [reduce [init body]]
    ]
    unless empty? lvars: exclude exclude lvars locals? spec svars [
        ; declare local variables
        insert any [find spec /local insert tail spec /local] lvars
    ]
    do init
    make function! spec body
]

function!-model: make object! [
    spec: none
    body: none
    context: none
    context-words: none
    recursion-level: none
]

func-model: function [
    {create a function!-model}
    spec [block!]
    body [block!]
] [result aw] [
    result: make function!-model []

    ; SPEC and BODY are deep copied
    result/spec: copy/deep spec
    result/body: copy/deep body

    ; context words are collected from SPEC
    result/context-words: locals? spec
    either empty? result/context-words [
    	result/context: [[] []]
    ] [
        result/context: make-context-model result/context-words
        bind result/body result/context
        bind result/context-words result/context
    ]

    ; RECURSION-LEVEL is set to zero
    result/recursion-level: 0

    result
]

call-stack-model: make block! []

exec: func [body] [do body]

evaluate-model: function [
    {evaluate a function!-model}
    f-model {the evaluated function!-model}
    values [block!] {the supplied values}
] [old-values result] [
    ; detect recursive call
    if (f-model/recursion-level: f-model/recursion-level + 1) > 1 [
        ; push the old values of context words to the stack
        insert/only tail call-stack-model second f-model/context
    ]
    set/any f-model/context-words values

    ; execute the function body
    error? set/any 'result exec f-model/body

    ; restore the former values from the stack, if needed
    if (f-model/recursion-level: f-model/recursion-level - 1) > 0 [
    	; pop the old values of the context words from the stack
        set/any f-model/context-words last call-stack-model
        remove back tail call-stack-model
    ]

    return get/any 'result
]
