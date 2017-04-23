REBOL [
    Title: "CASE multiple conditional function"
    Date: 27-Nov-2005
    File: %case.r
    Purpose: {
        Provide a generalized multiple conditional function for situations that would otherwise call for 
        deeply nested EITHER blocks. CASE is more general than SWITCH because the conditions can be any 
        DO-able block rather than being based on a single value. This can be used simply to allow a 
        SWITCH-like behavior that supports ranges instead of single values, e.g.:
            print case [
              [ lesser? x 1 ] [ "x < 1" ]
              [ equal? x 1 ] [ "x = 1" ]
              [ greater? x 1 ] [ "x > 1"]
            ]
        It can also be used for more complex situations, since any DO-able block can be used for the 
        condition block.
    }
    Author: "Christopher M. Dicely"
    Version: 1.0.0
    eMail: cmdicely@gmail.com
    library: [
        level: 'beginner
        platform: 'all
        type: 'function
        domain: 'extension
        tested-under: [ view 1.3.1.3.1 on [WinXP] ]
        support: none
        license: none
        see-also: none
    ]  
]


case: func [
    "Multiple conditional function"
    cases [block!] {
        Block containing alternating series of: COND-BLOCK which is evaluated and DO-BLOCK which is evaluated if COND-BLOCK is true.  
        Does first DO-BLOCK where the COND-BLOCK is true and returns the value returned by that DO-BLOCK
    }
    /default
    "Execute default-block if no conditions are true"
        default-block [block!]
        "Block to execute if no conditions are true"
    /local
        retval
        result
        errval
        is-done
] [
    retval: none
    is-done: false
    forskip cases 2 [
        if do first cases [
            if error? result: try [ retval: do second cases ] [ 
                { Handles the case where the DO-BLOCK doesn't return a value; sets retval to none }
                errval: disarm result
                either equal? result2/code 301 [ retval: none ] [ throw result ]
            ]
            is-done: true
            break
        ]
    ]
    if all [ default not is-done ] [ retval: do default-block ]
    return retval
]