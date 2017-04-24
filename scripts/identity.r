REBOL [
    Title: "Identity.r"
    Author: "Ladislav Mecir"
    File: %identity.r
    Date: 7-Dec-2010/20:30:16+1:00
    Purpose: {functions from the http://www.rebol.net/wiki/Identity article}
    Library: [
        level: 'intermediate
        platform: 'all
        type: 'tutorial
        domain: none
        tested-under: 2.7.6
        support: none
        license: none
        see-also: none
    ] 
]

do http://www.rebol.org/download-a-script.r?script-name=contexts.r
do http://www.rebol.org/download-a-script.r?script-name=apply.r

never: func [
    a [any-type!]
    b [any-type!]
] [
    false
]

always: func [
    a [any-type!]
    b [any-type!]
] [
    true
]

equal-type?: func [
    {do the values have equal types?}
    a [any-type!]
    b [any-type!]
] [
    equal? type? get/any 'a type? get/any 'b
]

new-line-attribute?: func [
    {returns the new-line attribute of a value}
    value [any-type!]
] [
    new-line? head insert/only copy [] get/any 'value
]

new-line-attribute: func [
    {returns a value with the new-line attribute set as specified}
    value [any-type!]
    attribute [logic!]
] [
    return first new-line head change/only [1] get/any 'value attribute
]

equal-new-line?: func [
    {compares new-line attribute of the values}
    a [any-type!]
    b [any-type!]
] [
    equal? new-line-attribute? get/any 'a new-line-attribute? get/any 'b
]

equal-mutation?: func [
    bs1 [any-type!]
    bs2 [any-type!]
    /local state1 state2
] [
    ; we concentrate on bitsets,
    ; so one of the criteria used is,
    ; whether the "bitsetness" of both values equals
    unless equal? bitset? get/any 'bs1 bitset? get/any 'bs2 [return false]

    ; to further concentrate on bitsets we consider non-bitsets equivalent
    unless bitset? get/any 'bs1 [return true]

    ; check whether both bitsets yield equal results
    ; when searching for #"^(00)"
    unless equal? state1: find bs1 #"^(00)" find bs2 #"^(00)" [return false]

    ; now the bitsets either both contain or don't contain #"^(00)"
    either state1 [
        ; both bitsets contain #"^(00)", so let's remove it from bs1
        remove/part bs1 "^(00)"

        ; we removed #"^(00)" from bs1,
        ; check, whether we find it in bs2
        state2: find bs2 #"^(00)"

        ; reverse the mutation
        insert bs1 "^(00)"
    ] [
        ; both bitsets don't contain #"^(00)", so let's insert it into bs1
        insert bs1 "^(00)"

        ; we inserted #"^(00)" into bs1,
        ; check, whether we find it in bs2
        state2: find bs2 #"^(00)"

        ; reverse the mutation
        remove/part bs1 "^(00)"
    ]

    ; bitsets are discernible, if STATE1 and STATE2 are equal
    state1 <> state2
]

identical?: func [
    {are the values identical?}
    a [any-type!]
    b [any-type!]
    /local statea stateb
] [
    case [
        ; compare types
        not-equal? type? get/any 'a type? get/any 'b [false]

        ; compare new-line attributes
        not-equal? new-line-attribute? get/any 'a
            new-line-attribute? get/any 'b [false]

        ; handle #[unset!]
        not value? 'a [true]

        ; errors can be disarmed and compared afterwards
        error? :a [same? disarm :a disarm :b]

        ; money with different denominations are discernible
        all [money? :a not-equal? first a first b] [false]

        (
            ; for money with equal denominations it suffices to compare values
            if money? :a [a: second a b:  second b]
            decimal? :a
        ) [
            ; bitwise comparison is finer than same? and transitive for decimals
            statea: make struct! [a [decimal!]] none
            stateb: make struct! [b [decimal!]] none
            statea/a:  a
            stateb/b:  b
            equal? third statea third stateb
        ]

        ; this is finer than same? and transitive for dates
        date? :a [and~ a =? b a/time =? b/time]

        ; compare even the closed ports, do not ignore indices
        port? :a [
            error? try [statea: index? :a]
            error? try [stateb: index? :b]
            return and~
                statea = stateb ; ports with different indices are discernible
                equal? reduce [a] reduce [b]
        ]

        bitset? :a [
            ; bitsets differing in #"^(00)" are discernible
            either not-equal? statea: find a #"^(00)" find b #"^(00)" [false] [
                ; use the approach of the equal-mutation? equivalence
                either statea [
                    remove/part a "^(00)"
                    stateb: find b #"^(00)"
                    insert a "^(00)"
                ] [
                    insert a "^(00)"
                    stateb: find b #"^(00)"
                    remove/part a "^(00)"
                ]
                statea <> stateb
            ]
        ]

        ; for structs we compare third
        struct? :a [same? third a third b]

        true [:a =? :b]
    ]
]

real-index?: func [
    {return a realistic index for any series}
    series [series!]
    /local orig-tail result
] [
    orig-tail: tail :series
    while [tail? :series] [insert tail :series #"1"]
    result: index? :series
    clear :orig-tail
    result
]

id2?: func [
    {are the values identical?}
    a [any-type!]
    b [any-type!]
    /local statea stateb
] [
    case [
        ; compare types first
        not-equal? type? get/any 'a type? get/any 'b [false]

        ; compare new-line attributes
        not-equal? new-line-attribute? get/any 'a
            new-line-attribute? get/any 'b [false]

        ; handle #[unset!]
        not value? 'a [true]

        ; errors can be disarmed and compared afterwards
        error? :a [equal? disarm :a disarm :b]

        ; money with different denominations are discernible
        all [money? :a not-equal? first a first b] [false]

        (
            ; for money with equal denominations it suffices to compare values
            if money? :a [a: second a b:  second b]
            decimal? :a
        ) [
            ; bitwise comparison is finer than same? and transitive for decimals
            statea: make struct! [a [decimal!]] none
            stateb: make struct! [b [decimal!]] none
            statea/a:  a
            stateb/b:  b
            equal? third statea third stateb
        ]

        ; this is finer than same? and transitive for dates
        date? :a [and~ a = b a/time = b/time]

        ; compare even the closed ports, do not ignore indices
        port? :a [
            error? try [statea: index? :a]
            error? try [stateb: index? :b]
            return and~
                statea = stateb ; ports with different indices are discernible
                equal? reduce [a] reduce [b]
        ]

        bitset? :a [
            ; bitsets differing in #"^(00)" are discernible
            either not-equal? statea: find a #"^(00)" find b #"^(00)" [false] [
                ; use the approach of the equal-mutation? equivalence
                either statea [
                    remove/part a "^(00)"
                    stateb: find b #"^(00)"
                    insert a "^(00)"
                ] [
                    insert a "^(00)"
                    stateb: find b #"^(00)"
                    remove/part a "^(00)"
                ]
                statea <> stateb
            ]
        ]

        (
            ; for structs we compare third
            if struct? :a [a: third a b: third b]

            series? :a
        ) [
            either equal? real-index? :a real-index? :b [
                ; A and B have equal index, it is sufficient to compare tails
                a: tail :a
                b: tail :b

                ; use INSERT to mutate A
                insert a #"1"
                stateb: 1 = length? b

                ; undo the mutation
                clear a
                stateb
            ] [false]
        ]

        any-word? :a [
            ; compare spelling
            either not-strict-equal? mold :a mold :b [false] [
                ; compare binding
                equal? bind? :a bind? :b
            ]
        ]

        true [:a = :b]
    ]
]

relatives?: func [
    {
        Two values are relatives, if every change of one
        affects the other too
    }
    a [any-type!]
    b [any-type!]
    /local var var2
] [
    ; errors are relatives with objects
    if error? get/any 'a [a: disarm :a]
    if error? get/any 'b [b: disarm :b]
    ; ports are relatives with contexts
    if port? get/any 'a [a: bind? in :a 'self]
    if port? get/any 'b [b: bind? in :b 'self]
    ; objects
    if not-equal? object? get/any 'a object? get/any 'b [return false]
    if object? get/any 'a [
        ; objects are relatives with contexts
        a: bind? in :a first first :a
        b: bind? in :b first first :b
        return same? :a :b
    ]
    ; structs
    if not-equal? struct? get/any 'a struct? get/any 'b [return false]
    if struct? get/any 'a [return same? third :a third :b]
    ; series
    if not-equal? series? get/any 'a series? get/any 'b [return false]
    if series? get/any 'a [
        if not-equal? list? :a list? :b [return false]
        ; series with different indices can be relatives
        a: tail :a
        b: tail :b
        unless list? :a [
            ; any-blocks are relatives with blocks
            ; any-strings are relatives with strings
            parse :a [a:]
            parse :b [b:]
        ]
        return same? :a :b
    ]
    ; variables
    if not-equal? all [
        any-word? get/any 'a bind? :a ; is it a variable?
    ] all [
        any-word? get/any 'b bind? :b ; is it a variable?
    ] [return false]
    if all [any-word? get/any 'a bind? :a] [
        return found? all [
            equal? :a :b
            same? bind? :a bind? :b
        ]
    ]
    ; functions
    if not-equal? any-function? get/any 'a any-function? get/any 'b [
        return false
    ]
    if any-function? get/any 'a [return same? :a :b]
    ; bitsets
    if not-equal? bitset? get/any 'a bitset? get/any 'b [return false]
    if bitset? get/any 'a [
        unless equal? var: find a #"^(00)" find b #"^(00)" [return false]
        either var [
            remove/part a "^(00)"
            var2: find b #"^(00)"
            insert a "^(00)"
        ] [
            insert a "^(00)"
            var2: find b #"^(00)"
            remove/part a "^(00)"
        ]
        return var <> var2
    ]
    ; all other values
    true
]

same-series-references?: func [
    {
        Find out, whether the INDEX1 reference in the SERIES1
        is the same as
        the INDEX2 reference in the SERIES2
    }
    series1 [series!]
    index1 [integer!]
    series2 [series!]
    index2 [integer!]
] [
    if zero? index1 [return zero? index2]
    if zero? index2 [return false]
    index1: either negative? index1 [index1] [index1 - 1]
    index2: either negative? index2 [index2] [index2 - 1]
    found? all [
        relatives? :series1 :series2
        equal? (real-index? :series1) + index1
            (real-index? :series2) + index2
    ]
]

find-reference: func [
    {find a reference to a given value in a series}
    series [series!]
    value [any-type!]
] [
    while [not tail? :series] [
        if identical? first :series get/any 'value [
            return :series
        ]
        series: next :series
    ]
    none
]

find-relative: func [
    {find a reference to a relative of a value in a given series}
    series [series!]
    value [any-type!]
] [
    while [not tail? :series] [
        if relatives? first :series get/any 'value [
            return :series
        ]
        series: next :series
    ]
    none
]

rfind: function [
    {
        find out whether a block
        or its subblocks
        contain a value with a given property
    }
    block [block!]
    property [any-function!]
] [rf explored] [
    explored: make block! 0
    rf: function [
        block
    ] [result] [
        if not find-reference explored block [
            insert/only tail explored block
            while [not tail? block] [
                either (property first block) [
                    return block
                ] [
                    if all [
                        block? first block
                        result: rf first block
                    ] [return result]
                ]
                block: next block
            ]
        ]
        none
    ]
    rf block
]

find-pair: func [
    {find a pair of occurrences in a given series}
    series [series!]
    a [any-type!]
    b [any-type!]
] [
    while [not tail? :series] [
        if all [
            identical? first first :series get/any 'a
            identical? second first :series get/any 'b
        ] [return :series]
        series: next :series
    ]
    none
]

equal-state?: function [
    {are the values in equal state?}
    a [any-type!]
    b [any-type!]
] [compo compb compw rc] [
    compo: make block! 0
    compb: make block! 0
    compw: make block! 0
    rc: function [
        a [any-type!]
        b [any-type!]
    ] [i1 i2] [
        unless equal-type? get/any 'a get/any 'b [return false]
        unless equal-new-line? get/any 'a get/any 'b [return false]
        if identical? get/any 'a get/any 'b [return true]
        if error? :a [
            a: disarm :a
            b: disarm :b
        ]
        if object? :a [
            if find-pair compo :a :b [return true]
            insert/only tail compo reduce [:a :b]
            return rc bind first a in a 'self bind first b in b 'self
        ]
        if any-word? :a [
            if strict-not-equal? mold :a mold :b [return false]
            if find-pair compw :a :b [return true]
            insert/only tail compw reduce [:a :b]
            return rc get/any :a get/any :b
        ]
        if struct? :a [
            return found? all [
                equal? first :a first :b
                equal? second :a second :b
                equal? third :a third :b
            ]
        ]
        if series? :a [
            error? try [i1: index? :a]
            error? try [i2: index? :b]
            if not-equal? i1 i2 [return false]
            a: head :a
            b: head :b
            if not-equal? length? :a length? :b [return false]
            if any-string? :a [return strict-equal? :a :b]
            if find-pair compb :a :b [return true]
            insert/only tail compb reduce [:a :b]
            repeat i length? :a [
                unless rc pick :a i pick :b i [return false]
            ]
            return true
        ]
        false
    ]
    rc get/any 'a get/any 'b
]

strict-cyclic?: function [
    block [any-block!]
] [rec in] [
    in: make block! 1
    rec: func [checked] [
        if not positive? real-length? :checked [
            return false
        ]
        if find-reference in :checked [
            return true
        ]
        insert/only tail in :checked
        foreach value :checked [
            if all [
                any-block? get/any 'value
                rec :value
            ] [return true]
        ]
        remove back tail in
        false
    ]
    rec :block
]

native-cyclic?: function [
    block [any-block!]
] [rec in] [
    in: make block! 1
    rec: func [checked] [
        if not positive? real-length? :checked [
            return false
        ]
        if find-relative in :checked [
            return true
        ]
        insert/only tail in :checked
        foreach value :checked [
            if all [
                any-block? get/any 'value
                rec :value
            ] [return true]
        ]
        remove back tail in
        false
    ]
    rec :block
]

deepcopy: function [
    block [any-block!]
] [rc copied copies] [
    copied: make block! 0
    copies: make block! 0
    rc: function [
        block
    ] [result found] [
        either found: find-reference :copied :block [
            return pick copies index? found
        ] [
            result: make :block :block
            insert/only tail copied :block
            insert/only tail copies :result
            while [not tail? :result] [
                if any-block? first :result [
                    change/only :result rc first :result
                ]
                result: next :result
            ]
            head :result
        ]
    ]
    rc :block
]

mutable?: function [
    {finds out, if the VALUE is mutable}
    value [any-type!]
] [r] [
    parse head insert/only copy [] get/any 'value [
        any-function! | error! | object! | port! | series! | bitset! |
        struct! | set r any-word! (
            either bind? :r [r: none] [r: [skip]]
        ) r
    ]
]
