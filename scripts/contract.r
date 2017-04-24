REBOL [
    Title: "Software engineering: design by contract"
    Date: 18-May-2001/9:21:57+2:00
    Version: 1.0.1
    File: %contract.r
    Author: "Maarten Koopmans"
    Purpose: "Facilitates design by contract"
    Email: m.koopmans2@chello.nl
    library: [
        level: 'advanced 
        platform: 'all 
        type: [Tool module] 
        domain: [UI user-interface] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]



system/error/user: make system/error/user [ pre-error: [ "The precondition " :arg1 " was not met" ]  ]
system/error/user: make system/error/user [ post-error: [ "The postcondition " :arg1 " was not met" ]  ]


block-all: func [ { Block variant on all.  Evaluates al netsed blocks as conditions.} a [any-block!]][

    ;Are we @ the tail? Then we have evaluated all the conditions succesfully. Return true.
    either tail? a
    ; We are at the end of the conditions, return true
    [ return true]
    [
      ; Is the block empty or does it contain none
      either any [ empty? first a none? first first a]
      [
        ;yes, skip and do the next condition
        block-all next a
      ]
      [
        ;Continue... we have a valid condition
        ;If the first condition is true, recursively call block-all on the next
        either do first a
        [ block-all next a]
        [return false]
      ];either any
    ]
]

find-false: func [ {Finds the first false block in a block of blocks and return at the start of it.}  a [any-block!] ]
                 [
                   ;Initialize. Skip all empty and none! conditions
                   ;until [ either any [ empty? first a none? first first a]  [a: next a ] [true ] ]
                   while [all [(not tail? a) (do first a)] ]
                   [
                     ;go to the next element and skip empty ones and ones of type none!
                     until [ either any [ empty? first a none? first first a]  [a: next a false] [a: next a true ] ]
                   ]
                   return  copy a
                 ]

contract: func [ {Contracts are functions that support pre and post conditions, aka design by contract.
                                    Note that your code should return a value (at least none) for this to work.}
                 args [any-block!] {Function arguments.}
                 conditions [any-block!] { conditions in the format: [ pre [ [cond1] [cond2]] post [[cond3] ..]}
                 locals [any-block!] {Local variables to the function.}
                 body [any-block!] {The body of the function, should ALWAYS return a value (at least none).}
                 /local pre-cond post-cond pre-code post-code func-args func-body
                                    cond-block do-func inner-func do-body
               ]
               [
                 pre-code: copy []
                 post-code: copy []

                 ;Find the pre conditions
                 pre-cond: select conditions 'pre
                 if (not none? pre-cond)
                 [
                    ;Pre-code is the code for the precondition.
                    pre-code: copy compose/deep [ if not block-all compose/deep [(pre-cond)]]
                    ;Append some code. We need to split the compose because we use a compose again in the resulting code :)
                    append cond-block: copy compose/deep [ cond: mold first find-false compose/deep [(pre-cond)]] [ make error! compose [ user pre-error (cond)]]
                    ;And append the cond-block to pre-code. Now we have our pre-code ready.
                    append/only pre-code cond-block
                 ]

                 post-cond: select conditions 'post
                 ;Find the pre conditions
                 if (not none? post-cond)
                 [
                    ;Pre-code is the code for the precondition.
                    post-code: copy compose/deep [ if not block-all compose/deep [(post-cond)]]
                    ;Append and compose some code. We need to split the compose because we use a compose again in the resulting code :)
                    append cond-block: copy compose/deep [ cond: mold first find-false compose/deep [(post-cond)]] [ make error! compose [ user post-error (cond)]]
                    ;And append the cond-block to pre-code. Now we have our pre-code ready.
                    append/only post-code cond-block
                 ]

                                 ;Append the local variables to the argument block
                 append func-args: copy args /local
                                 append func-args [ __return __ret_err]
                                 append func-args locals

                                 ;if the body is empty, make sure it returns none
                                 if body = []
                                 [
                                    body: copy [ none ]
                                 ]

                                 ;We evaluate the body as an anonymous function with access to all or locals
                                 do-body:  copy compose/deep [ __innerfunc: func [] [(:body)]]


                 ; Change the function body to include the conditions
                                 func-body: copy []
                                 ; we at least return none
                                 insert func-body copy [ __return: none ]
                                 append func-body copy pre-code
                                 append func-body do-body
                                 append func-body copy [ __return: __innerfunc ]
                 append func-body copy post-code
                                 append func-body copy [ __return ]

                 ;Create and return the function
                 return func func-args func-body

               ]



