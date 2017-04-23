REBOL [
    Title: "Tail recursion"
    Date: 14-Nov-2001/15:58:27+1:00
    Version: 1.0.0
    File: %tailfunc.r
    Author: "Maarten Koopmans"
    Purpose: {Provides transparent tail recursive functions with refinement transferral. Source code 4 gurus only}
    Email: m.koopmans2@chello.nl
    Web: http://www.vrijheid.net
    library: [
        level: 'advanced 
        platform: 'all 
        type: [Tool function] 
        domain: 'UI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

tail-func: func 
[ 
  {Returns a function that handles tail-recursion transparently.}
    args [block!] body [block!]
    /local meta-func meta-spec meta-body p1 p2
]
[
    meta-spec: append/only copy [] args
    meta-body: append/only copy [] body
    
    ;matches refinements and copies refinements to our command
    p1: [ set r refinement! 
                (either get bind to-word r 'comm 
                    [ 
                        append comm mold r 
                        ref-mode: on
                    ]
                    [ ref-mode: off ]
                )
            ]
    
    
    ;matches words and copies their values to the statement if ref-mode = on
    p2: [ set w word! (if ref-mode [ append/only statement get bind to-word w 'local])]
    
    
    meta-func: copy 
    [
        ;The use context is accessible from the wrapper function that
        ;eliminates tail recursion. It plays the role of a stack frame
        ;ti implement a goto like behaviour in case of tail recursion
        use [ _*loop-detected _*myself _*innerfunc _*loops _*myspec _*myspec2 _*mycall]
        [
            ;some static initialization of the use context varaiables
          _*loops: 0
            _*loop-detected: false
            _*mycall: copy []
            _*innerfunc: func (meta-spec) (meta-body)
            _*myspec: copy first :_*innerfunc
            _*myspec2: append copy _*myspec [/local ref-mode p1 p2 r w comm statement ret]
          insert/only _*myspec2 [catch] 

            ;The function that is returned from the use context
            _*myself: func _*myspec2
            [ 
                ;How deep in a loop am I?
                _*loops: _*loops + 1

                ;These parse rules extract how I am called
                ;(which refinements and so)
                p1: [(p1)]
                p2: [(p2)]
                ref-mode: on

                ;Ourt initial call
                comm: copy {_*innerfunc}
                ;Our initial statement
                statement: copy []
                
                ;Generate our statement and call
                parse _*myspec [ any [ p1 | p2 ]]
                insert statement to-path comm

                ;Copy it in the use context so it survives
                ;a loop (_*mycall is the 'goto args)
                _*mycall: copy statement
                
                if _*loops = 2 
                [
                    _*loops: 1
                    _*loop-detected: true
                    return
                ]

                ;Until we are no longer in loop-detection mode
                until
                [
                    _*loop-detected: false
                    set/any 'ret do bind _*mycall '_*loops 
                    not _*loop-detected
                ]

                ;set/any 'ret pick ret 1
                
                ;Use context cleanup
              _*loops: 0
            _*loop-detected: false
            _*mycall: copy []


                ;return our value
                return get/any 'ret
            ];_*myself: func ...

        ];use context

    ];meta-func

    ;return our function....    
    do compose/deep meta-func
]


;some samples

rec-fun: tail-func [x [integer!]][x: x + 1 print x rec-fun x]
rec-fun2: tail-func [x /y z]
[
    x: x + 1
    either y
    [ print [ x z ] rec-fun2 x]
    [ print x rec-fun2/y x x ]
]

                                                                                                                              