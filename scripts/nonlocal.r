REBOL [
    Title: "Find Non-local Variables"
    Date: 25-May-2000
    File: %nonlocal.r
    Author: "Carl Sassenrath"
    Usage: "dump-vars function-name"
    Purpose: {
        Provides an way to find local variables that have
        not been declared as locals.
    }
    Note: {
        This function displays words that MIGHT be a problem.
        Some variables may be shown that are part of object
        contexts and some variables may not be shown because
        they are set to values in other contexts or functions.
    }
    library: [
        level: 'advanced 
        platform: none 
        type: [tool] 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

find-var-sets: func [
    "Searches a block to find variable assignments."
    blk [any-block!] vars [block!] /local value
][
    forall blk [
        value: first :blk
        if any [block? :value paren? :value] [find-var-sets :value vars]
        if set-word? :value [insert vars make word! :value]
        if :value = 'set [
            blk: next :blk
            if not tail? :blk [
                value: first :blk
                if word? :value [insert vars :value]
            ]
        ]
    ]
]

find-nonlocal: func [
    "Returns a block of non-local variables for the function."
    funct [function!] /local code vars locals
][
    locals: copy first :funct
    code: second :funct
    vars: copy []

    ;-- Convert all arg and local variables to words:
    while [not tail? locals] [
        either any [refinement? first locals  any-word? first locals][
            change locals to-word first locals
            locals: next locals
        ][remove locals]
    ]
    locals: head locals

    ;-- Find all variables and compare with defined locals:
    find-var-sets code vars
    difference/only intersect vars vars locals
]

dump-vars: func [
    "Display a list of all non-local variables used in a function."
    'funct [word!] /local vars
][
    either empty? vars: find-nonlocal get funct [
        print "No undeclared local variables found."
    ][
        print "Non-Local Variables:"
        sort vars
        foreach word vars [print [tab word]]
    ]
    exit
]

example: [  ;--- Check all functions in system
    vals: second system/words
    foreach word first system/words [
        if function? first vals [
            if not empty? words: find-nonlocal first vals [
                print [word mold words]
            ]
        ]
        vals: next vals
    ]
    halt
]

do example