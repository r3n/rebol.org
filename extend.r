REBOL [
    Title: "Extend"
    Author: "Vincent Ecuyer"
    Date: 31-Jan-2013
    Version: 1.0.0
    File: %extend.r
    Purpose: {Extends a series with sequential or duplicate values.}
    Usage: {
        extend/to/cut value (series!) length (integer!)
        
        with: 
            value  - the series to modifies
            
            length - either the number of items to append 
                     (or retire, if it's negative and /cut is used), 
                     or, with /to, the total number of items
                     
            /to    - the 'length is the total length 
                     (without /cut, dont do anything is the series is too long)
            
            /cut   - shortens the series if it's too long (with /to), 
                     or if length is negative (without /to)
                     
            /dup   - duplicates values (repeat the existing values, but doesn't
                     try to continue a sequence)
                     
        Empty series : appends none or null (0) values
        
        >> extend [] 10
        == [none none none none none none none none none none]

        >> extend #{} 10
        == #{00000000000000000000}
        
        One element : builds an incrementing sequence
        
        >> extend [1] 10
        == [1 2 3 4 5 6 7 8 9 10 11]
        
        >> extend/to "a" 26
        == "abcdefghijklmnopqrstuvwxyz"
        
        /dup disables the incrementation
        
        >> extend/dup [1] 10
        == [1 1 1 1 1 1 1 1 1 1 1]
        
        Two elements or more : tries to continue the series
        
        >> extend [0 5] 6
        == [0 5 10 15 20 25 30 35]
        
        >> extend [1 3 5] 3
        == [1 3 5 7 9 11]
        
        >> extend [1 5 3] 3 
        == [1 5 3 1 5 3]
        
        It works with date!, time!, char!, number!, and tuple! elements
        
        >> extend/to reduce [now/date] 5
        == [30-Jan-2013 31-Jan-2013 1-Feb-2013 2-Feb-2013 3-Feb-2013 ]
        
        >> extend/to [08:00:00 08:30:00] 8  
        == [8:00 8:30 9:00 9:30 10:00 10:30 11:00 11:30]
        
        >> extend/to [0.0.0.127 64.0.1.127] 4 
        == [0.0.0.127 64.0.1.127 128.0.2.127 192.0.3.127]
        
        /cut is used to shorten the series
        
        >> extend/cut [1 2 3 4 5 6] -1
        == [1 2 3 4 5]

        >> extend/cut/to [0 1 2 3 4 5 6] 3
        == [0 1 2]
        
        Non-numeric elements or mixed elements : repeats the values
        
        >> extend ["cat" "rabbit" "dog"] 5
        == ["cat" "rabbit" "dog" "cat" "rabbit" "dog" "cat" "rabbit"]
        
        >> extend/to [5 dog 15] 8 
        == [5 dog 15 5 dog 15 5 dog]
    }
    Library: [
        level: 'intermediate 
        platform: 'all 
        type: [tool function] 
        domain: none
        tested-under: [ 
            view 2.7.8.2.5 on [Macintosh osx-x86] 
            core 2.101.0.2.5 on [Macintosh osx-x86] 
        ] 
        support: none 
        license: 'apache-v2.0
        see-also: none 
    ]
]

extend: func [
    "Extends a series with sequential or duplicate values."
    value [series!] "The series to modify." 
    length [integer!] "The number of values to append."
    /to "The specified length is the total length."
    /dup "Duplicates only."
    /cut "Removes the value past the specified length."
    /local x-inc x-dup any-number?
][
    ; /to refinement : 'length is total length
    if to [length: length - length? value]

    ; nothing to append
    if length <= zero [
        ; /cut refinement : clears the unwanted values
        if cut [clear at tail value length]
        return value
    ]
    
    ; datatypes who accepts operators
    any-number?: func [value][
        found? find [decimal! integer! date! time! money! pair! tuple! char!] type?/word value
    ]

    ; increments series
    x-inc: func [data] either any [any-string? value binary? value] [
        [insert tail value (to-char last value) + data]
    ][
        [insert tail value (last value) + data]
    ]

    ; duplicates series
    x-dup: does either any [any-string? value binary? value] [
        [insert/only tail value to-char first value]
    ][
        [insert/only tail value first value]
    ]
    
    ; /dup refinement : only duplicates values
    if all [dup not empty? value] [
        loop length [x-dup value: next value]
        return head value
    ]

    ; mode auto 
    switch/default length? value [
        ; empty series : fills it with null or none content
        0 [
            insert/dup value either any [any-string? value binary? value][#"^@"][none] length
        ]
        ; one item : choose according to the datatype
        1 [
            either any-number? first value [
                ; number : increments it
                loop length [x-inc 1]
            ][
                ; other value : duplicates it
                insert/only/dup value either any [any-string? value binary? value][
                    to-char first value
                ][
                    first value
                ] length
            ]
        ]
        ; two items : choose according to the datatype and the values
        2 [
            either all [any-number? first value any-number? second value][
                ; two numbers : completes with the same difference between values
                loop length compose [x-inc ((second value) - first value)]
            ][
                ; otherwise : duplicates the values
                loop length [x-dup value: next value]
            ]
        ]
    ][
        ; more items : choose according to the datatype and the values 
        either all [
            ; tests if the values are a sequence of numbers
            until [
                if any [
                    not any-number? value/1
                    (type? value/1) <> type? value/2
                    (type? value/2) <> type? value/3
                    (value/2 - value/1) <> (value/3 - value/2)
                ][break/return false]
                tail? next next value: next value
            ]
            value: head value
        ][
            ; sequence of numbers : completes it
            loop length compose [x-inc ((second value) - first value)]
        ][
            ; misc values : duplicates it
            loop length [x-dup value: next value]
        ]
    ]
    ; head of the modified series
    head value
]