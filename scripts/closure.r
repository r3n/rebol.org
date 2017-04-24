Rebol [
    Title: "Closure"
    File: %closure.r
    Date: 11-May-2009/19:13:51+2:00
    Author: "Ladislav Mecir"
    Purpose: {
        CLOSURE is suggested instead of FUNC when you need functions
		exhibiting async behaviour,	e.g. for:
		- View
		- Async Ports
		- Higher Order Functions
		
		Closures differ from "normal" Rebol functions by using a fresh
		context every time they are called.
		
		Rule of thumb: if your function is returning a new function, block, or
		a local word, you will be safe if it is a closure.
    }
]

closure: func [
    [catch]
    spec [block!] {Help string (opt) followed by arg words (and opt type and string)}
    body [block!] {The body block of the closure}
    /local spc item result
] [
    spc: make block! 1 + (2 * length? spec)
    insert/only spc [throw]
    result: make block! 5 + length? spec
    insert result reduce [:do :make :function! spc body]
    parse spec [
        any [
            set item any-word! (
                insert tail result to word! :item
                insert tail spc to get-word! :item
                insert/only tail spc [any-type!]
            ) | skip
        ]
    ]
    throw-on-error [make function! spec result]
]

comment [
    ; Examples:

    f-maker: func [x][does [x]]
    f-ok: f-maker "OK"
    f-bug: f-maker "BUG"
    f-ok ; == "BUG"
    
    c-maker: closure [x][does [x]]
    c-ok: c-maker "OK"
    c-bug: c-maker "BUG"
    c-ok ; == "OK"
    
    block: copy []
    f: closure [x] [
        if x = 2 [f 1]
        insert tail block 'x
    ]
    f 2
    print block ; 1 2
    
    ; Tests:
    f: closure [x [any-type!]] [type? get/any 'x]
    f () ; == unset!
    f make error! "" ; == error!
    f first [:x] ; == get-word!
    f first [x:] ; == set-word!
    f: closure [do make function! spc body] [
        print [do make function! spc body]
    ]
    f 0 1 2 3 4 ; 0 1 2 3 4
    f: closure [x [any-type!]] [return get/any 'x]
    type? f make error! "" ; == error!
]
