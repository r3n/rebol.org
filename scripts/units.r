Rebol [
    File: %units.r
    Date: 2015-05-26
    Version: 0.0.0
    Title: "Units"
    Purpose:  "Units conversion program"
    Usage: {
        do %units.r
        units/fetch
        units/convert 1.0 "g" "mpound"
        units/examples
    }
    Author: "Scott Wall"
    Note: {
        Based on GnuWin32 - units version 1.87
        Requires %units.dat in same directory. This can be found at:
        https://gist.githubusercontent.com/offby1/665756/raw/ef139e26af5fd52e7072383641c0de85d6eb0ab7/units.dat
    }
    History: {
        0.0.0 Initial version.
    }
    Todo: {
    - implement formulae
    - implement tables
    - fix complex units with powers, e.g., airwatt, RSI
    - fix compound units, e.g. marathon
    - fix information theory units
    - force units to be conformant
    }
    Date: 03-10-2005
    Library: [
        level: 'intermediate
        platform: 'all
        type: [function]
        domain: [external-library]
        tested-under: [windows]
        support: none
        license: [GPL]
        see-also: none
    ]
]

units: make object! [
    value: 1.0
    is-from?: false

    fetch: func [
        "reads the units, parsing into US (default) or UK definitions."
        /uk "uk definitions"
    ][
        proportional-units: copy []
        formula-units: copy []
        table-units: copy []
        prefixes: copy []
        active: true
        is-uk?: uk
        parse/all read %units.dat rules
    ]

    inject: func [
        bl [block!]
        v
    ][
        either is-from? [ append/only bl v ][ insert/only bl v ]
    ]

    resolve-proportional: func [
       bl [block!]
       /loc x y idx s in-par? inner
    ][
        y: copy []
        operators: charset "*+-/^^"
        in-par?: false
        inner: copy []
        foreach s parse bl/2 none [
            case [
                in-par? [
                    ; compose block for expression in parentheses
                    case [
                        idx: find s ")" [
                            in-par?: false
                            inject y inner
                            inner: copy []
                        ]
                        not none? attempt [to-decimal s][
                            inject inner to-decimal s
                        ]
                        equal? "/" s [inject inner "/"]
                        equal? "|" s [inject inner "|"]
                        equal? "*" s [inject inner "*"]
                        equal? "^^" s [inject inner "^^"]
                        true [inject inner resolve s]
                    ]
                ]
                equal? s "!" [
                    unless empty? y inject y 1
                ]
                equal? s "!dimensionless" [
                    unless empty? y inject y 1
                ]
                idx: find s "|" [
                    fctr: split-value s index? idx
                    x: bl/1 * (to-decimal fctr/1) / (to-decimal fctr/2)
                    inject y x
                ]
                idx: find s "(" [ in-par?: true ]
                idx: find s operators [
                    either equal? 1 index? idx [
                        inject y s
                    ][
                        inject y to-decimal s
                    ]
                ]
                not none? attempt [to-decimal s] [inject y to-decimal s ]
                true [ inject y resolve s ]
            ]
        ]
        return compose/deep [(bl/1) [(y)]]
    ]

    resolve-formula: func [
       bl [block!]
       /local y operators formula
    ][
    parm: bl/1
        print "formula definitions are non-functional!"
        y: copy []
comment {
        operators: charset "*+-/^^"
        print ["formula:" mold bl]
        print ["length bl:" length? bl]
        print ["bl-1:" mold bl/1]
        print ["bl-2:" mold bl/2]
        print ["bl-3:" mold bl/3]
        print ["bl-4:" mold bl/4]
        formula: either is-from? [bl/2/4][bl/2/5]
        prin ["using:" formula]
        replace/all formula rejoin [" " bl/2/1 " "] " # "
        print [":" formula]
        parse formula uexpr
}
        comment {
        foreach s parse formula none [
            case [
                equal? s "(" [ ]
                equal? s ")" [ ]
                find s operators [ ]
                true [ ]
            ]
        ]
        }

        return y
    ]

    resolve-table: func [
       bl [block!]
    ][
        print "table definitions are not defined!"
        return 1
    ]


    eval: func [
        u-in [string!]
        /loc bl o u x y e is-power?
    ][
        foreach o "+/^^*" [replace/all u-in o rejoin [" " o " "]]
        u: parse u-in none
        x: none
        y: none
        is-power?: false
        foreach e u [
            switch/default e [
                "/" [ y: compose/deep/only [(y) (e)] ]
                "*" [ y: compose/deep/only [(y) (e)] ]
                "^^" [ is-power?: true ]
                "2" [
                    either is-power? [
                        y: compose/deep/only [(y) "*" (y)]
                        is-power?: false
                    ][
                        append/only y e
                    ]
                ]
                "3" [
                    either is-power? [
                        y: compose/deep/only [[(y) "*" (y)] "*" (y)]
                        is-power?: false
                    ][
                        append/only y e
                    ]
                ]
            ][
                x: resolve e
                y: either none? y [x][to-block append/only y x]
            ]
        ]
        return y
    ]

    resolve: func [
        u [string!]
        /loc bl x
    ][
        bl: find-piece to-string u
        x: case [ 
            block? bl/2 [blx: copy bl resolve-formula bl]
            equal? 2 length? bl [ resolve-proportional bl ]
            equal? 3 length? bl [ resolve-table bl]
            true [print "unrecognized block:" length? bl]
        ]
        return x
    ]

    convert: func [
        val [number!]
        from-unit [string!]
        to-unit [string!]
    ][
        initial: val
        is-from?: true
        val: reduce-value val eval from-unit eval to-unit
        print ["convert " initial from-unit "->" val to-unit]
        val
    ]

    has-block?: func [
        bl [block!]
    ][
        foreach s bl [ if block? s [return true] ]
        return false
    ]

comment {
    eval-to-block: func [
        val [number!]
        toward [block!]
        /loc result x y z n
    ][
        x: y: z: 1.0
;        print ["eval-to-block(" val ") =" mold toward]
        to-rules: [ some [
            set n number! (
                print ["dec-t:" x ":" n ":"]
                x: x / n
                print x
                ) |
            set b block! (
                print ["bl:" val ":" mold b ":"]
                unless all [equal? 1 b/1 equal? 1 b/2/1][
;                    print ["evaluating..." mold b/2]
                    y: y / (eval-to-block val b)
                ]
                print ["b->" y]
                )
            ]
            opt ["^^" set z number! (
                print ["pow(" y "," z ")"]
                y: power z y
                print y
                )
            ]
        ]
        parse toward to-rules

        result: either has-block? toward [
            prin ["b-result:" x ":" val]
            val / (x * y)
            ][
            prin ["e-result:" x ":" val]
            val / (x * y)
            ]
        print ["to:" result]
        result
    ]
    }

    eval-from-block: func [
        val [number!]
        from [block!]
        /loc result x y n b p state inverse
    ][
        x: y: 1.0
        state: none
        inverse: false
        optional: none
        from-rules: [
            opt [opt none! (state: -1) "/" (state: 1.5 inverse: true)]
            some [
                [
                    set n number! (x: x * n state: 1) 
                    opt ["^^" set n number! (x: power x n state: 1.2)]
                ] |
                set b block! (y: y * eval-from-block val b state: 2)
            ]
            optional:
            any [
                ["^^" set n decimal! ( y: power y n state: 3)] |
                ["^^" set b block! ( y: power y eval-from-block val b state: 4)] |
                ["/" set b block! ( y: y / eval-from-block val b state: 5)] |
                ["*" set n decimal! (y: y * n state: 6)] |
                ["*" set b block! (y: y * eval-from-block val b state: 7)] |
                [set b block! (y: y * eval-from-block val b state: 8)]
            ]
        ]
        p: parse from from-rules
        unless p [
            print ["Parse error:" p ":" state ":" type? optional ":" mold optional]
        ]
        result: either has-block? from [x * y][val * x * y]
        if inverse [result: 1 / result]
        result
    ]

    reduce-value: func [
        val [number!]
        from [block!]
        toward [block!]
    ][
;        print ["from:" mold from]
;        print ["to:" mold toward]
        value: val
        val: val * eval-from-block 1.0 from
        val: val / eval-from-block 1.0 toward
;        val2: val * eval-to-block 1.0 toward
;        print ["alternatively:" val2]

        return val
    ]

    digit: charset [#"0" - #"9"]
    number: [
        copy num [
        opt "-" some [
            [some digit] |
            [some digit "|" some digit "^^" some digit] |
            [some digit "^^" some digit] |
            [some digit "^^" expr] |
            [some digit "|" some digit] |
            [some digit opt "." any digit opt [["e" | "E"] opt "-" some digit ]] |
            ["." some digit]
        ]
        ] (num: to-decimal trim num)
    ]
    alpha: charset [#"A" - #"Z" #"a" - #"z" #"$" #"-" #"_" #"'" #"%"]
    alphas: [some alpha]
    alphanum: charset [#"a" - #"z"]
    namechar: charset [#"A" - #"Z" #"a" - #"z" #"$" #"_" #"'" #"," #"%" #"0" - #"9" #"." #"ã" #"¼" #"½" #"¾" #"µ" #"¢" #"£" #"¥" #"å" #"Å" #"°" #"ö"]
    exprchar: charset [#"A" - #"Z" #"a" - #"z" #"$" #"-" #"_" #"'" #"," #"%" #"0" - #"9" #"/" #"(" #")" #" " #"*" #"|" #"!" #"." #"^^" #"~" #"+" #"ã"]
    spacer: charset reduce [tab #" "]
    spaces: [some spacer]
    whitespacer: charset reduce [tab newline #" "]
    whitespaces: [some whitespacer]
    commnt: ["#" copy text to newline]
    line-continuation: ["\" any spacer newline any spacer]
    reference: [copy text alphas copy stuff opt ["^^" some digit] ]
    references: [reference any [spaces reference] ]

    factor: 1
    expr: [
        [ copy txt
        references (print "hello" print (find-unit txt factor) print ["reference" txt]) |
        number (factor: factor * num)
        ]
        spaces 
        opt ["/" (print "div")| "^^" (print "oper") | "*" (print "mult")]
        any spacer
        opt [expr (print "e/r")]
    ]

    uexpr: [
        [expr any spacer "(" any spacer expr any spacer ")" opt [any spacer expr]] |
        [references (print "help") any spacer "(" expr ")"] |
        expr any spacer |
        "/" any spacer expr |
        ["!dimensionless" (print "---")] |
        "!" (print "root")
    ]

    comment {
    equation: [
        [expr any spacer "+" any spacer equation] (print "ADD")|
        [expr any spacer "^^" any spacer equation] (print "EXP")|
        ["-" any spacer equation] (print "negative")|
        ["(" any spacer equation any spacer ")" (print "pexpr") "/" expr] |
        ["(" any spacer equation any spacer ")" (print "pexpr")] |
        [any alphas "(" equation ")" opt equation] |
        expr
    ]
    }

    unit-definition: [
        copy text some exprchar (
        foreach o "/^^*()" [replace/all text o rejoin [" " o " "]]
        if active [
            append proportional-units compose/deep [(name) [(trim text)]]
        ]
        )
    ]

    prefix-definition: [
        copy text some exprchar (
        t: trim text
        if none? attempt [n: to-decimal t] [
            n: case [
            x: find t "^^" [
                fctr: split-value t index? x
                power to-decimal fctr/1 to-decimal fctr/2
            ]
            x: find t "|" [
                fctr: split-value t index? x
                (to-decimal fctr/1) / (to-decimal fctr/2)
            ]
            true [
                either none? t1: select prefixes to-word t [t][t1]
            ]
            ]
        ]
        append prefixes compose [(to-word name) (n)]
        )
    ]

    formula-definition: [
        copy var to ")" ")"
        spaces
        opt [
        "[" copy d1 any exprchar 
        ";" copy d2 some exprchar 
        "]"
        ]
        copy e1 some exprchar (
            foreach o "+()/^^" [replace/all e1 o rejoin [" " o " "]]
        )
        ";" any spacer
        opt line-continuation
        copy e2 some exprchar (
        foreach o "+()/^^" [replace/all e2 o rejoin [" " o " "]]
        bl: compose/deep [[(var) (d1) (d2) (trim e1) (trim e2)]]
        if active [
            append formula-units name
            append/only formula-units bl
        ]
        )
    ]

    table-definition: [
        copy u to "]" ( numbers: copy [] ) "]"
        some [
        any spacer any line-continuation
        some [
            any spacer copy n some number (append numbers n)
            opt "," any spacer
        ]
        ] (
        bl: compose/deep [(u) [(numbers)]]
        if active [
            append table-units name
            append/only table-units bl
        ]
        )
    ]

    definition: [
        copy name some namechar
        [
        [ spaces unit-definition] |
        [ "-" prefix-definition] |
        [ "(" formula-definition] |
        [ "[" table-definition]
        ]
        any spacer
        opt commnt
        whitespaces
    ]

    rules: [
        some [
            definition |
            commnt |
            newline |
            whitespaces |
            ["!locale" any spacer [
                "en_US" (active: not is-uk?)| "en_GB" (active: is-uk?)]
            ] |
            ["!endlocale" (active: true)]
        ]
        end
    ]

    find-unit: func [
        w [string!]
        m
        /loc x
    ][
        case [
            x: select/case proportional-units w [
                return compose/deep [(m) (x)]
            ]
            x: select/case formula-units w [
                return compose/deep [(m) (x)]
            ]
            x: select/case table-units w [
                return compose/deep [(m) (x)]
            ]
        ]
        return none
    ]

    find-piece: func [
        w [string!]
        /loc t x y pl-chars
    ][
        ; first check units as-is, then try to de-pluralize units
        pl-chars: 0  ; number of plural characters
        loop 4 [
            t: find-unit w 1
            either none? t [
                foreach [prefix fctr] prefixes [
                    f: find/match/case w prefix
                    if f [
                        x: find-unit f fctr
                        unless none? x[
                            either string? x/1 [
                                y: units/resolve x/1
                                return compose/deep [(y/2) (x/2)]
                            ][
                                y: x
                                while [all [(not decimal? y/1) (not none? y/1)]][
                                    y: select/case prefixes to-word y/1
                                ]
                                return compose/deep [(y/1) (x/2)]
                            ]
                        ]
                    ]
                ]
            ][
                return t
            ]
            comment {
            If we got this far, then maybe the units need to be de-pluralized.

            Plural rules for english: add -s
            after x, sh, ch, ss   add -es
            -y becomes -ies except after a vowel when you just add -s as usual
            }
            case [
                all [zero? pl-chars equal? back tail w "s"] [
                    pl-chars: 1
                    remove back tail w
                ]
                all [equal? 1 pl-chars equal? back tail w "e"][
                    pl-chars: 2
                    remove back tail w
                ]
                all [equal? 2 pl-chars equal? back tail w "i"][
                    pl-chars: 3
                    replace back tail w "i" "y"
                ]
                true [
                    print ["unable to evaluate:" w]
                    halt 
                ]
            ]
        ]
    ] 

    split-value: func [
        s [string!]
        d [integer!]
        /loc numer denom
    ][
        numer: copy s
        denom: copy s
        clear skip numer (d - 1)
        remove/part denom d
        to-block reduce [numer denom]
    ]

    lookup: func [
        s
        /local u
    ][
        print ["Searching for: " s "..."]
        foreach [u bl] proportional-units [
            if find to-string u to-string s [ print u ]
        ]
    ]

    test: func [
        "tests units/convert results against expected values."
        from-units [string!]
        to-units [string!]
        inp [number!] "input value"
        expect [number!] "expected value"
    ][
        actual: units/convert inp from-units to-units
        delta: abs divide subtract expect actual expect
        if lesser? 0.1 delta [
            prin ["Failed delta:" delta "for "]
        ]
        print [from-units "->" to-units ":" expect ":" actual]
    ]

    verify-proportional: does [
        test "g" "mpound" 12.5 27.55778277
        test "cup sugar" "kg" 2 0.4
        test "in^^2" "centare" 250 0.16129
        test "Bq" "curie" 2.30 6.216216216e-11
        test "apdram" "g" 3 11.6638038
        test "stick" "cm" 1.5 7.62
        test "australiasquare" "ft^^2" 2.5 250
        test "hp" "watt" 100 74569.98716
        test "meter * feet" "are" 345 1.05156
        test "ccf" "kl" 42 118.9307557
        test "edoma" "shaku^^2" 1.5 25.23
        test "edoma" "m^^2" 2.5 3.86134068
        test "shou" "l" 4.5 8.117580766
        test "jou_area" "chuukyouma" 1 0.93444444
        test "acre" "m^^2" 1.2 4856.22770688
        test "hectare" "m^^2" 1.2 12000
        test "stack" "m^^3" 2.5 7.64554858
        test "arpent" "acre" 4.2 3.548232963
        test "arpent" "hectare" 4.2 1.435924679
        test "frigorie" "joule" 2 8371.6
        test "/min" "Bq" 1.15 0.01916667
        test "mm^^3" "l" 250 2.5e-4
        test "mm*mm*mm" "l" 250 2.5e-4
        test "UKinch" "cm" 1.5 3.809993375
        test "scfm" "watt" 1 47.82007468
        test "irishrood" "acre" 2.5 1.012389124
        test "irishrood" "hectare" 2.5 0.4097009816
        test "standardgauge" "in" 2 104.5
        test "kB" "bit" 3 24000
    ]

    verify-bugs: does [
        test "airwatt" "hp" 200 0.2679988207
        test "airwatt" "watt" 10 9.983
        test "marathon" "km" 1.5 63.292482
        test "cdromspeed" "Hz" 2 153600
        test "nat" "bit" 4 2
    ]

    verify-formula: does [
        test "shoesize_men" "cm" 10 31
        test "tempC" "tempK" 60 333.15
    ]

    verify: does [
        verify-formula
        verify-proportional
    ]

    examples: does [
        units/convert 1.0 "g" "mpound"
        units/convert 1.15 "/min" "Bq"
        units/convert 250 "mm^^3" "l"
        units/convert 2.30 "Bq" "curie"
    ]

]

units/fetch
;units/fetch/uk
;units/examples