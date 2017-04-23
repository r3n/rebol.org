REBOL [
    Title: "Increment and Decrement"
    Date: 24-Apr-1999
    File: %incdec.r
    Purpose: {
        Increment and decrement a variable by one.
    }
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

set '++ func ['word] [set word (get word) + 1]
set '-- func ['word] [set word (get word) - 1]

;Quick test:

test-inc-dec: [
    num: 10
    ++ num
    print num
    -- num
    print num
    print ++ num
    print num
    print -- num
    print num
]

do test-inc-dec
