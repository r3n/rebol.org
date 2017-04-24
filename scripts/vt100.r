REBOL [
    Title: "VT100 Functions"
    Date: 4-Sep-1999
    File: %vt100.r
    Author: "Jeff Kreis"
    Purpose: "Examples of VT100 screen functions"
    Comment: {
        To see these escapes in action, script must be invoked in a
        terminal capable of VT100 emulation.  Also start rebol as cgi,
            ie: rebol -c vt.r
        otherwise these escapes will not work.
    }
    Email: jeff@rebol.com
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: 'text-processing 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
]

foreach [name letter] [up "A" down "B" right "C" left  "D"] [
    set name func [arg] reduce bind [
        'rejoin reduce ["^(escape)[" 'arg letter]
    ] 'letter
]
clr: "^(escape)[H^(escape)[J"
jump: func [x y][
    rejoin ["^(escape)[" x ";" y "H"]
]

do example: [
    print [
        clr 
        jump  10 10 'R
        up    4     'E
        left  13    'B
        down  10    'O
        right 30    'L

    ]
]    

