REBOL [
    Title: "Automatic local variables"
    Date: 20-Jul-1999
    Version: 1
    File: %protect-func.r
    Author: "Thomas Jensen"
    Tabs: 4
    Purpose: {
        Function generator that automatically makes local variables
    }
    Language: 'English
    Email: dm98411@edb.tietgen.dk
    Charset: 'ANSI
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

protected-function: function [spec body] [ locals ][
    locals: make block! []
    foreach word body [
        if set-word? :word [
            append locals make word! :word
        ]
    ]
    function spec locals body
]

example: [
    some-math-function: protected-function [x] [
        y: + x 2
        z: / x 2
        z + y
    ]
    
    x: "this string (x) has not been modified!"
    y: "this string (y) has not been modified!"
    z: "this string (z) has not been modified!"

    print some-math-function 4
    
    print [x newline y newline z]
]
do example
