REBOL [
    Title: "Console capture"
    Date: 31-Jul-2001
    Version: 1.0.0
    File: %capture.r
    Author: "Nenad Rakocevic"
    Usage: {
^->> capture on^-; activate the capture mode
^->> capture off  ; get back to normal mode
^-
^-Captured output is helded in 'get-captured.
^->> print get-captured
^-}
    Purpose: "Capture console output in a string!"
    Email: dockimbel@free.fr
    library: [
        level: 'intermediate 
        platform: none 
        type: [tutorial tool] 
        domain: 'x-file 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

ctx-console-capture: context [
    out: none
    sys-print: get in system/words 'print
    sys-prin:  get in system/words 'prin
    
    set 'get-captured does [out]
    
    print-out: func [value][append out reform [reduce value newline]]
    prin-out:  func [value][append out reform value]
    
    set 'capture func [flag [logic!]][
        either flag [
            out: make string! 1024
            set 'print :print-out
            set 'prin :prin-out
        ][
            set 'print :sys-print
            set 'prin  :sys-prin
        ]
    ]
]                                      