REBOL [
    Title: "Parse Analysis Toolset"
    Date: 17-Dec-2004
    File: %parse-analysis.r
    Purpose: "Some tools to help learn/analyse parse rules."
    Version: 1.1.0
    Author: "Brett Handley"
    Web: http://www.codeconscious.com
    Library: [
        level: 'intermediate
        platform: 'all
        type: 'tool
        domain: [dialects parse text-processing]
        tested-under: [
            core 2.5.6.31 on [WinNT4] {Basic tests.} "Brett"
        ]
        support: none
        license: none
        comment: {
Copyright (C) 2004 Brett Handley All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions are
met:

May not be executed within web CGI or other server processes.

Redistributions of source code must retain the above copyright notice,
this list of conditions and the following disclaimer.  Redistributions
in binary form must reproduce the above copyright notice, this list of
conditions and the following disclaimer in the documentation and/or
other materials provided with the distribution.  Neither the name of
the author nor the names of its contributors may be used to
endorse or promote products derived from this software without specific
prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS
IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED
TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.  
}
        see-also: none
    ]
]

hook-parse: func [
    "Hook parse rules for events: test a rule (Test), rule succeeds (Pass), rule fails (Fail). Returns hook context."
    rules [block!] "Block of words. Each word must identify a Parse rule to be hooked."
    /local hook-context spec
] [

    ; Check the input

    if not parse rules [some any-word!] [make error! "Expecting a block of words."]

    ; Create the hook context.

    hook-context: context [
        step: level: status: current: ; State tracking variables.
        rule-words: ; The original rules (maintaining their bindings).
        rule-def: ; The original rule values.
        last-begin: ; A variable to track the input position when the rule starts.
        last-end: ; A variable to track the input position when the rule ends.
        pass: fail: test: ; Functions called when the corresponding parse event occurs.
        none
        reset: does [step: level: 0 last-begin: last-end: current: none]
    ]
    hook-context/rule-words: rules

    ; Create a context to store the original rule definitions.

    spec: make block! multiply 2 length? rules
    repeat rule rules [insert tail spec to set-word! rule]
    hook-context/rule-def: context append spec [none]

    ; Modify the given rules to point to the
    ; hook-context's tracking rules and save
    ; the original rules.

    repeat rule rules [

        set in hook-context/rule-def rule reduce [get rule]

        set rule bind reduce [

            ; Rule invocation

            to set-word! 'last-begin
            to paren! compose [
                step: step + 1 level: level + 1
                current: (to lit-word! rule) status: 'test
                test
            ]

            ; Call the original rule.

            in hook-context/rule-def rule

            ; Rule Success

            to set-word! 'last-end
            to paren! compose [
                step: step + 1 level: level - 1
                current: (to lit-word! rule) status: 'pass
                pass
            ]

            '|

            ; Rule failure

            to set-word! 'last-end
            to paren! compose [
                step: step + 1 level: level - 1
                current: (to lit-word! rule) status: 'fail
                fail
            ]
            'end 'skip ; Ensure the failure result is maintained.

        ] in hook-context 'self

    ]

    ; Return the hook-context.
    hook-context

]

unhook-parse: func [
    "Unhooks parse rules hooked by the Hook-Parse function."
    hook-context [object!] "Hook context returned by the Hook-Parse function."
] [
    repeat rule hook-context/rule-words [set rule first get in hook-context/rule-def rule]
    hook-context/rule-def: none ; Clear references to original rules.
    hook-context/reset
    return ; return unset
]

count-parse: func [
    "Returns counts of calls, successes, fails of Parse rules."
    body [block!] "Expression to invoke Parse on your input."
    hook-context [object!] "Hook context returned by the Hook-Parse function."
    /local ctr-t ctr-p ctr-f increment
] [

    ; Initialise counters
    foreach w [ctr-t ctr-p ctr-f] [set w array/initial length? hook-context/rule-words 0]

    ; Helper function
    increment: func [ctr /local idx] [
        idx: index? find hook-context/rule-words hook-context/current
        poke ctr idx add 1 pick ctr idx
    ]

    ; Bind to the hook-context. Note that the event functions *must* be bound to the same context.
    do bind [
        test: does [increment ctr-t]
        pass: does [increment ctr-p]
        fail: does [increment ctr-f]
    ] in hook-context 'self

    ; Invoke the parse as specified by user.
    hook-context/reset
    do body

    ; Return result
    reduce [copy hook-context/rule-words ctr-t ctr-p ctr-f]
]

explain-parse: func [
    "Emits numbered parse steps."
    body [block!] "Invoke Parse on your input."
    hook-context [object!] "Hook context returned by the Hook-Parse function."
    /begin begin-fn [any-function!] "Function called when rule begins. Spec: [context-stack [block!] begin-context-clone [object!]]"
    /end end-fn [any-function!] "Function called when rule ends.  Spec: [context-stack [block!] begin-context-clone [object!] end-context-clone [object!]]."
] [
    ; Initialise

    if not begin [
        begin-fn: func [context-stack begin-context] [
            print rejoin bind/copy [
                head insert/dup copy "" "  " subtract level 1
                step " begin '" current " at " index? last-begin
            ] in begin-context 'self
        ]
    ]
    if not end [
        end-fn: func [context-stack begin-context end-context] [
            print rejoin bind/copy [
                head insert/dup copy "" "  " (subtract begin-context/level 1)
                step " end '" current " at " index? last-end
                " started-on " begin-context/step " " end-context/status "ed"
            ] in end-context 'self
        ]
    ]

    use [stack] [

        stack: make block! 20

        ; Make the hook-context. Note that the event functions *must* be
        ; bound to the same context.
        do bind [
            test: has [] [
                begin-fn stack hook-context
                insert tail stack make hook-context []
            ]
            pass: has [ctx] [
                ctx: last stack
                remove back tail stack
                end-fn stack ctx hook-context
            ]
            fail: has [ctx] compose [
                ctx: last stack
                remove back tail stack
                end-fn stack ctx hook-context
            ]
        ] in hook-context 'self

        ; Invoke the hook-context
        hook-context/reset
        do body
    ]

    ; Return unset
    return
]

tokenise-parse: func [
    "Tokenises the input using the rule names."
    body [block!] "Invoke Parse on your input. The block must return True in order to return the result."
    hook-context [object!] "Hook context returned by the Hook-Parse function."
] [
    use [stack result fn-b fn-e] [
        stack: make block! 20
        result: make block! 10000
        fn-b: does [insert/only tail stack tail result]
        fn-e: func [context-stack begin-context end-context /local bookmark] [
            bookmark: last stack
            remove back tail stack
            either 'pass = end-context/status [
                insert tail result reduce [
                    end-context/current
                    subtract index? end-context/last-end index? begin-context/last-begin ; Length
                    index? begin-context/last-begin ; Input position
                ]
            ] [clear bookmark]
        ]
        explain-parse/begin/end body hook-context :fn-b :fn-e
        result
    ]
]
