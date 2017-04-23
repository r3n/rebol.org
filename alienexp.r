REBOL [
    Title: "Alien Dialect Explanation"
    Date: 10-Mar-1999
    File: %alienexp.r
    Purpose: "It came from outer space explained."
    Comment: {
        Rebol is not tied to any specific syntax, and
        can even accommodate a program written entirely
        in punctuation marks.  The script %alien.r is a
        good example of which punctuation can be 
        utilized in words, as well as showing the 
        flexibility of dialects in REBOL.

        This file contains a more conventional
        explanation of the code behind the %alien.r
        script.  It is a direct translation and 
        functions exactly as does its counterpart.
    }
    library: [
        level: 'advanced 
        platform: none 
        type: none 
        domain: 'x-file 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
    Version: 1.0.0
    Author: "Anonymous"
]

make-block: func [any-block] [make block! any-block]

num-block: make-block {
    78 79 87 32 80 69 82 76
    32 85 83 69 82 83 32 87
    79 78 39 84 32 10 70 69
    69 76 32 76 69 70 84 32
    79 85 84                  }

loop-size: make integer! 4 ** 3; example of bad characters

divide-text: func [] [
    loop loop-size [prin make char! (7 * 6)]
]

divide-text print "^/"

make-msg: func [num-set] [
    foreach num num-set [prin [make char! num " "]] 
    print make char! 10
]

make-msg num-block

divide-text prin make char! add 8 2
