REBOL [
    Title: "Func Parse String"
    Date: 20-Jul-2004
    Version: 0.8.1
    File: %parse-string.r
    
    Author: "Stan Silver"
    Email: stasil213@yahoo.com
    
    Purpose: {Creates and returns a function that performs custom string substitution}
    
    Notes: {
    
        The file contains one function, called 'func-parse-string, and tests.
        
        This function is called with one argument - a rule block.  The rule block
        is similar in spirit to a rebol parse rule block, but with different syntax.
        
        A new function is returned that should be stored in a variable.  In other words,
        func-parse-string acts like a function definition (like func and function).
        The new function can be used repeatedly to perform string parsing and substitution.
        
        The parse string rule block may contain any number of any of the following lines
            
                    [set-word-for-user-defined-rule]: [any code - same as a rebol parse rule]
                    keep [rule]
                    remove [rule]
                    replace [rule] [expression]
                    before [rule] [expression]
                    after [rule] [expression]
                    before-after [rule] [before expression] [after expression]

                where

                    [rule] is a char! or string! or block! (what to match in the input string)
                    [expression] is a char! or string! or block! (what to put in the output string)
        
        The rules are checked top to bottom.  Put the rules to check first on top.
        For example, put a keep #"x" above a remove a-to-z.
        
        You may "do" the file as it is, and the tests will not be run.
        To run the tests, "do" the file with the argument 'test
        Example: do/args %parse-string.r 'test
        
        To see the parse rule that is generated, use the /rule and /print options
        (CURRENTLY NOT WORKING CORRECTLY)
        Example: func-parse-string/rule/print [replace "x" "X"]
        
        To see the object that is generated, use the /object and /print options
        Example: func-parse-string/object/print [replace "x" "X"]

        The returned function is wrapped in an object (unseen by the user)
        to provide a local context for the variables used.
        Loading this file and running the code should only add one word
        to the namespace: 'func-parse-string.
            
        This code has not been optimized for speed.
        
    }
    
    Example: {
    
        (look at the tests for other examples)
    
        my-parse: func-parse-string [
            start: charset [#"a" - #"c"]
            efg-pair: ["ef" | "fg" | "eg"]

            keep #"a"
            remove [start]
            remove #"d"
            replace [efg-pair] "_x_"
            replace "h" "HH"
            before #"k" "["
            after "l" #"]"
            before-after "m" "<<" ">>"
        ]

        my-parse "abcdefghijklm"
 
        ==> "a_x_gHHij[kl]<<m>>"
            
        func-parse-string/object/print [...RULE BLOCK AS ABOVE...]
 
        ==> make object! [
                start: charset [#"a" - #"c"]
                efg-pair: ["ef" | "fg" | "eg"]
                parse-rule: [
                    copy _temp #"a" (append _output _temp) |
                    [start] |
                    #"d" |
                    [efg-pair] (append _output reduce "_x_") |
                    "h" (append _output reduce "HH") |
                    copy _temp #"k" (append _output reduce "[" append _output _temp) |
                    copy _temp "l" (append _output _temp append _output reduce #"]") |
                    copy _temp "m" (append _output reduce "<<" append _output _temp append _output reduce ">>") |
                    copy _temp skip (append _output _temp)
                ]
                _temp: none
                _output: none
                parse-string-function: func [input [string!]][
                    _output: copy ""
                    parse/all input [some parse-rule]
                    _output
                ]
            ]    
    }
    
    library: [
        level: 'advanced 
        platform: 'all
        type: 'dialect 
        domain: 'text-processing 
        tested-under: none
        support: none
        license: none
        see-also: none
    ]
]

;======;
; CODE ;
;======;

func-parse-string: function [string-rule [block!] /rule /object /print] [

    ;=================;
    ; local variables ;
    ;=================;
    _rule _rul
    _expression _exp _exp1 _exp2
    _keep _remove _replace _before _after _before-after
    _set-word _wor
    _any-after-set-word _any
    
    parse-definitions
    parse-rule
    parse-object

    format-rule
    
] [

    ;====================================================================;
    ; internal rules, used to change the string-rule into the parse-rule ;
    ;====================================================================;
    _rule: [string! | char! | block!]
    _expression: [string! | char! | block!]
    
    _keep: [
        'keep
        copy _rul _rule
        (append parse-rule reduce [
            'copy '_temp first _rul
            to paren! reduce [
                'append '_output '_temp
            ]
            '|
        ])
    ]
    _remove: [
        'remove
        copy _rul _rule
        (append parse-rule reduce [
            first _rul
            '|
        ])
    ]
    _replace: [
        'replace
        copy _rul _rule
        copy _exp _expression
        (append parse-rule reduce [
            first _rul
            to paren! reduce [
                'append '_output 'reduce first _exp
            ]
            '|
        ])
    ]
    _before: [
        'before
        copy _rul _rule
        copy _exp _expression
        (append parse-rule reduce [
            'copy '_temp first _rul
            to paren! reduce [
                'append '_output 'reduce first _exp
                'append '_output '_temp
            ]
            '|
        ])
    ]
    _after: [
        'after
        copy _rul _rule
        copy _exp _expression
        (append parse-rule reduce [
            'copy '_temp first _rul
            to paren! reduce [
                'append '_output '_temp
                'append '_output 'reduce first _exp
            ]
            '|
        ])
    ]
    _before-after: [
        'before-after
        copy rul _rule
        copy exp1 _expression
        copy exp2 _expression
        (append parse-rule reduce [
            'copy '_temp first rul
            to paren! reduce [
                'append '_output 'reduce first exp1
                'append '_output '_temp
                'append '_output 'reduce first exp2
            ]
            '|
        ])
    ]
    
    ;==========================================================================;
    ; internal rules, used to put definitions into the parse definitions block ;
    ;==========================================================================;
    _set-word: [
        copy _wor
        set-word!
        (append parse-definitions to set-word! first _wor)
    ]
    _any-after-set-word: [
        copy _any
        any-type!
        (append/only parse-definitions first _any)
    ]

    ;======================================================================;
    ; change the string-rule into the parse definitions and the parse rule ;
    ;======================================================================;
    parse-definitions: copy []
    parse-rule: copy []
    parse string-rule [
        some [
            _keep | _remove | _replace |
            _before | _after | _before-after |
            _set-word | _any-after-set-word
        ]
    ]
    
    ;==========================================;
    ; add the default clause to the parse rule ;
    ;==========================================;
    append parse-rule reduce [
        'copy '_temp 'skip
        to paren! [append _output _temp]
    ]
    
    ;===============================;
    ; build the parse string object ;
    ;===============================;
    append parse-definitions [parse-rule:]
    append/only parse-definitions parse-rule
    append parse-definitions [_temp:]
    append parse-definitions none
    append parse-definitions [_output:]
    append parse-definitions none
    append parse-definitions [parse-string-function:
        func [input [string!]] [
            _output: copy ""
            parse/all input [some parse-rule]
            _output
        ]
    ]
    parse-object: context parse-definitions
    
    ;=================================================;
    ; user options, mainly for learning and debugging ;
    ;=================================================;
    if rule [
        either print
            [return prin [format-rule parse-rule CRLF]]
            [return parse-rule]
    ]
    if object [
        either print
            [return prin [mold parse-object CRLF]]
            [return parse-object]
    ]
    format-rule: function [rule [block!]] [
        rule-string
        output
        temp
    ] [
        rule-string: mold rule
        output: copy ""
        parse/all rule-string [some [
            " | " (append output " |^M^/")    |
            copy temp skip (append output temp)
        ]]
        output
    ]
     
    ;========================================================================;
    ; (for normal use) return the parse string function of the object        ;
    ; we assume that because the function points to the object,              ;
    ; the object sticks around in memory to provide context for the function ;
    ;========================================================================;
    get in parse-object 'parse-string-function
]

;=======;
; TESTS ;
;=======;

;=====================================================;
; to run tests, do the file with 'test as its argument ;
; (e.g.) do/args %parse-string.r 'test                 ;
;=====================================================;
if 'test = system/script/args [

    ;=====================================================================;
    ; a short-cut function to repeatedly run the tests (under MS Windows) ;
    ;=====================================================================;
    p: func [] [
        do/args %/c/Program Files/rebol/view/local/parse-string.r 'test
    ]

    ;===============;
    ; test function ;
    ;===============;
    ???: func [result 'ignore desired] [
        if not result = desired [
            print ["TEST FAILED" mold result ignore mold desired]
        ]
    ]

    ;========================;
    ; pre test set variables ;
    ;========================;
    alpha:                 15
    parse-string-function: 16
    _temp:                 17
    _output:               18
    x:                     19
    
    ;=======;
    ; tests ;
    ;=======;
    ps1: func-parse-string [
        alpha:       charset [#"a" - #"z"]
        
        remove       "h"
        remove       #"e"
        replace      "ll" "hey"
        after        "o" "-boy"
        before       "t" #"_"
        before-after "r" ">>" "<<"
    ]
    ps2: func-parse-string [
        alpha:       charset [#"a" - #"z"]
        
        replace      [some alpha] "hi"
    ]
    ps3: func-parse-string [
        delimiter:   charset reduce [#" " tab cr newline] 
        alpha:       charset [#"a" - #"z" #"A" - #"Z"]
        digit:       charset "0123456789"
        alphanum:    union alpha digit

        replace      [delimiter] #"_"
        keep         #"b"
        keep         #"2"
        before-after [alphanum] #"/" #"\"
    ]
    ps4: func-parse-string [
        dots:        [some #"."]
        alpha:       charset [#"a" - #"z" #"A" - #"Z"]
        digit:       charset "0123456789"
        alphanum:    union alpha digit
        alphanums:   [some alphanum]

        x:           none ; so x is not global

        replace      [copy x some "a"] [length? x "A"]
        before       [copy x some "b"] [length? x]
        after        [copy x some "c"] [length? x]
        before-after [copy x dots alphanums] [length? x "["] ["]" length? x]
    ]
    ps5: func-parse-string [
        replace      #" " #"_"
        replace      [#"/" | #"\"] "slash"
        replace      #"." #"o"
    ]

    ??? ps1 "hello there"          >> "heyo-boy _t>>r<<"
    ??? ps1 "hello world"          >> "heyo-boy wo-boy>>r<<ld"

    ??? ps2 "hello there"          >> "hi hi"
    ??? ps2 "hello world"          >> "hi hi"

    ??? ps3 "!@# $%) &*( abc 123"  >> "!@#_$%)_&*(_/a\b/c\_/1\2/3\"

    ??? ps4 "a bb ccc .b ..c d"    >> "1A 2bb ccc3 1[.b]1 2[..c]2 d"

    ??? ps5 "2.3 3/4 4\5 6.7"      >> "2o3_3slash4_4slash5_6o7"

    ;=========================================;
    ; post test that variables are not global ;
    ;=========================================;
    ??? alpha                      >> 15
    ??? parse-string-function      >> 16
    ??? _temp                      >> 17
    ??? _output                    >> 18
    ??? x                          >> 19

    ;===========================================;
    ; fail a test to show the tests are running ;
    ;===========================================;
    ??? 'should                    >> 'fail

    ;=======================;
    ; show the file is done ;
    ;=======================;
    'EOF

]