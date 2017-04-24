REBOL [
    Title: "Series Slice"
    Date: 4-Aug-2004
    Version: 1.0.1
    File: %series-slice.r
    
    Author: "Stan Silver"
    Email: stasil213@yahoo.com
    
    Purpose: {Provides array slicing for series}
    
    Notes: {
    
        To define the function:     do %series-slice.r
        To run the tests:           do/args %series-slice.r 'test
    
    }
    
    Example: {
    
        ;; ======================
        ;; slice series to
        ;; slice series [from]
        ;; slice series [from to]
        ;; ======================

        str: "hello world"

        slice str 2             >> "he"
        slice str -3            >> "hello wor"
        slice str [2]           >> "ello world"
        slice str [-3]          >> "rld"
        slice str [2 5]         >> "ello"
        slice str [3 -2]        >> "llo worl"
        slice str [-4 -2]       >> "orl"
        slice str [-2 2]        >> ""    

    }
    
    History: {
    
        1.0.1   code clean-up (with help from Anton)
        1.0.0   initial version

    }
    
    Library: [
        level: 'beginner
        platform: 'all
        type: 'function
        domain: 'extension
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

slice: function [series [series!] from-to [block! integer!]][

    ;; ======================
    ;; slice series to
    ;; slice series [from]
    ;; slice series [from to]
    ;; ======================

    start end distance

][

    either block? from-to [
        start: from-to/1
        end: either (length? from-to) = 1 [length? series] [from-to/2]
        ][
        start: 1
        end: from-to
    ]

    if start < 0 [start: (length? series) + 1 + start]
    if end < 0 [end: (length? series) + 1 + end]
    distance: end - start + 1 

    either distance > 0 [
        copy/part (at series start) distance
        ][
        clear copy series
    ]

]

if 'test = system/script/args [context [

    ;; =============================
    ;; test function
    ;;
    ;; to run tests:
    ;; do/args %series-slice.r 'test
    ;; =============================
    
    tests: 0
    succeeded: 0

    ?: func [result 'ignore desired] [
        tests: tests + 1
        either result = desired [
            succeeded: succeeded + 1
            ][
            print ["TEST FAILED" mold result ignore mold desired]
        ]
    ]

    ;; =====
    ;; tests
    ;; =====

    a: [2 3 4 5 6 7 8]

    ? slice a 2                              >> [2 3]
    ? slice a -3                             >> [2 3 4 5 6]
    ? slice a [2]                            >> [3 4 5 6 7 8]
    ? slice a [-3]                           >> [6 7 8]
    ? slice a [2 5]                          >> [3 4 5 6]
    ? slice a [3 -2]                         >> [4 5 6 7]
    ? slice a [-4 -2]                        >> [5 6 7]
    ? slice a [-2 2]                         >> []

    b: "hello world"

    ? slice b 2                              >> "he"
    ? slice b -3                             >> "hello wor"
    ? slice b [2]                            >> "ello world"
    ? slice b [-3]                           >> "rld"
    ? slice b [2 5]                          >> "ello"
    ? slice b [3 -2]                         >> "llo worl"
    ? slice b [-4 -2]                        >> "orl"
    ? slice b [-2 2]                         >> ""
    
    print ["Tests:" tests "Succeeded:" succeeded]
    
]]