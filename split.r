REBOL [
    File: %split.r
    Date: 6-May-2012
    Title: "Split.r"
    Author: "Gregg Irwin"
    Purpose: {
        Provide functions to split a series into pieces, according to 
        different criteria and needs.
    }
    library: [
        level: 'intermediate
        platform: 'all
        type: [module function dialect]
        domain: [parse dialects text text-processing]
        tested-under: [View 2.7.8 on Win7]
        license: 'MIT
    ]
]

use [map-each test split-tests] [

    ; R3-compatible map-each interface.
    ;
    ; This is local to the context for SPLIT, because it is not designed
    ; to be fully R3 MAP-EACH compatible. For that, you should look at
    ; Brian Hawley's %r2-forward.r.
    ;
    ; What happens if the result of the DO is unset!? For now, we'll
    ; ignore unset values. The example case being SPLIT, which uses
    ; MAP-EACH with an unset value for negative numeric vals used to
    ; skip in the series.
    map-each: func [
        'word 
        data [block!] 
        body [block!]
        /local tmp
    ] [
        collect compose/deep [
            repeat (word) data [
                set/any 'tmp do bind/copy body (to lit-word! word)
                if value? 'tmp [keep/only :tmp]
            ]
        ]
    ]

    ; R2 version.
    ;
    ; There are differences from the version in R3 which, itself, will likely
    ; need to be revisited due to changes in R3.
    split: func [
        [catch]
        {Split a series into pieces; fixed or variable size, fixed number, or at delimiters}
        series [series!] "The series to split"
        dlm [block! integer! char! bitset! any-string!] "Split size, delimiter(s), or rule(s)."
        /into {If dlm is an integer, split into n pieces, rather than pieces of length n.}
        /local size count mk1 mk2 res piece-size fill-val add-fill-val type
    ][
        ; This is here becaus using "to series", which should work, fails if the
        ; target type is paren!. If we ignore that case, all the "to type" bits
        ; can go away completely.
        type: type? series
        
        either all [block? dlm parse dlm [some integer!]] [
            map-each len dlm [
                either positive? len [
                    to type copy/part series series: skip series len
                ] [
                    series: skip series negate len
                    ()
                ]
            ]
        ] [
            size: dlm
            res: collect [
                parse/all series case [
                    all [integer? size into] [
                        if size < 1 [throw make error! compose  [script invalid-arg size]]
                        count: size - 1
                        ; Max 1 is to catch when size is larger than the series, giving us 0.
                        piece-size: max 1 round/down divide length? series size
                        [
                            count [copy series piece-size skip (keep/only to type series)]
                            copy series to end (keep/only to type series)
                        ]
                    ]
                    integer? dlm [
                        if size < 1 [throw make error! compose  [script invalid-arg size]]
                        [any [copy series 1 size skip (keep/only to type series)]]
                    ]
                    'else [
                        ; This is quite a bit different under R2, in order to stop 
                        ; at the end properly and collect the final value.
                        [
                            any [
                                mk1: [
                                    to dlm mk2: dlm (keep to type copy/part mk1 mk2)
                                    | to end mk2: (keep to type copy mk1) skip
                                ]
                            ]
                        ]
                    ]
                ]
            ]
            ;-- Special processing, to handle cases where the spec'd more items in
            ;   /into than the series contains (so we want to append empty items),
            ;   or where the dlm was a char/string/charset and it was the last char
            ;   (so we want to append an empty field that the above rule misses).
            fill-val: make type none
            add-fill-val: does [append/only res fill-val]
            case [
                all [integer? size  into] [
                    ; If the result is too short, i.e., less items than 'size, add
                    ; empty items to fill it to 'size.
                    ; We loop here, because insert/dup doesn't copy the value inserted.
                    if size > length? res [
                        loop (size - length? res) [add-fill-val]
                    ]
                ]
                ; integer? dlm [
                ; ]
                'else [ ; = any [bitset? dlm  any-string? dlm  char? dlm]
                    ; If the last thing in the series is a delimiter, there is an
                    ; implied empty field after it, which we add here.
                    case [
                        bitset? dlm [
                            ; ATTEMPT is here because LAST will return NONE for an 
                            ; empty series, and finding none in a bitest is not allowed.
                            if attempt [find dlm last series] [add-fill-val]
                        ]
                        ; These cases are now handled, under R2, by the parse rule, and
                        ; no longer require special handling.
                        ;char? dlm [
                        ;    if dlm = last series [add-fill-val]
                        ;]
                        ;string? dlm [
                        ;    if all [
                        ;        find series dlm
                        ;        empty? find/last/tail series dlm
                        ;    ] [add-fill-val]
                        ;]
                    ]
                ]
            ]
                    
            res
            
        ]
    ]

    test: func [block expected-result /local res err] [
        ;print ['TEST tab mold block mold expected-result]
        if error? set/any 'err try [
            res: do block
            ;print [mold/only :block newline tab mold res]
            if res <> expected-result [print [tab 'FAILED! tab 'expected mold expected-result]]
        ][
            print [mold/only :block newline "ERROR!" mold disarm err]
        ]
    ]

    split-tests: [    
        >> [split "1234567812345678" 4]     == ["1234" "5678" "1234" "5678"]
        
        >> [split "1234567812345678" 3]     == ["123" "456" "781" "234" "567" "8"]
        >> [split "1234567812345678" 5]     == ["12345" "67812" "34567" "8"]
        
        >> [split/into [1 2 3 4 5 6] 2]       == [[1 2 3] [4 5 6]]
        >> [split/into "1234567812345678" 2]  == ["12345678" "12345678"]
        >> [split/into "1234567812345678" 3]  == ["12345" "67812" "345678"]
        >> [split/into "1234567812345678" 5]  == ["123" "456" "781" "234" "5678"]
        
        ; Dlm longer than series
        >> [split/into "123" 6]             == ["1" "2" "3" "" "" ""] ;or ["1" "2" "3"]
        >> [split/into [1 2 3] 6]           == [[1] [2] [3] [] [] []] ;or [1 2 3]
        >> [split/into first [(1 2 3)] 6]   == [(1) (2) (3) () () () ] ;or [1 2 3]
        ;>> [split/into [1 2 3] 6]     == [[1] [2] [3] none none none] ;or [1 2 3]
        
        
        >> [split [1 2 3 4 5 6] [2 1 3]]                  == [[1 2] [3] [4 5 6]]
        >> [split "1234567812345678" [4 4 2 2 1 1 1 1]]   == ["1234" "5678" "12" "34" "5" "6" "7" "8"]
        >> [split first [(1 2 3 4 5 6 7 8 9)] 3]          == [(1 2 3) (4 5 6) (7 8 9)]
        >> [split #{0102030405060708090A} [4 3 1 2]]      == [#{01020304} #{050607} #{08} #{090A}]
        
        >> [split [1 2 3 4 5 6] [2 1]]      == [[1 2] [3]]
        
        >> [split [1 2 3 4 5 6] [2 1 3 5]]  == [[1 2] [3] [4 5 6] []]
        
        >> [split [1 2 3 4 5 6] [2 1 6]]    == [[1 2] [3] [4 5 6]]
        
        ; Old design for negative skip vals
        ;>> [split [1 2 3 4 5 6] [3 2 2 -2 2 -4 3]]    == [[1 2 3] [4 5] [6] [5 6] [3 4 5]]
        ; New design for negative skip vals
        >> [split [1 2 3 4 5 6] [2 -2 2]]   == [[1 2] [5 6]]
        
        >> [split "abc,de,fghi,jk" #","]            == ["abc" "de" "fghi" "jk"]
        >> [split "abc<br>de<br>fghi<br>jk" <br>]   == ["abc" "de" "fghi" "jk"]
        
        >> [split "a.b.c" "."]     == ["a" "b" "c"]
        >> [split "c c" " "]       == ["c" "c"]
        >> [split "1,2,3" " "]     == ["1,2,3"]
        >> [split "1,2,3" ","]     == ["1" "2" "3"]
        >> [split "1,2,3," ","]    == ["1" "2" "3" ""]
        >> [split "1,2,3," #","]   == ["1" "2" "3" ""]
        
        >> [split "1..2..3" ".."]   == ["1" "2" "3"]
        >> [split "1..2..3.." ".."] == ["1" "2" "3" ""]
        
        ; Doesn't work under R2, because PARSE doesn't support [to charset!]
        ; or [to block!].
        ; Need to look at Ladislav's parse enhancements to see about that.
        ;>> [split "1,2,3," charset ",."]  == ["1" "2" "3" ""]
        ;>> [split "1.2,3." charset ",."]  == ["1" "2" "3" ""]
        ; This doesn't work under R2 either.
        ;>> [split "-a-a" ["a"]]  == ["-" "-"]
        ;>> [split "-a-a'" ["a"]] == ["-" "-" "'"]

    	;>> [split "abc^M^Jde^Mfghi^Jjk" [crlf | #"^M" | newline]] == ["abc" "de" "fghi" "jk"]
    	;>> [split "abc     de fghi  jk" [some #" "]] == ["abc" "de" "fghi" "jk"]

    ]     
     
    run-split-tests: has [chevron =test =expected-result n] [
        chevron: (to lit-word! ">>")
        n: 0
        prin "Tests parsed successfully: "
        print parse split-tests [
            some [
                chevron set =test block! '== set =expected-result block!
                (n: n + 1 test =test =expected-result)
            ]
        ]
        print [n "tests run"]
    ]   

]
