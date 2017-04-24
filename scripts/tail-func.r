REBOL [
	Title: "Tail func"
	Date: 4-Oct-2012/11:08:03+2:00
	Author: "Ladislav Mecir"
	File: %tail-func.r
	Purpose: {define tail-recursive functions}
]

use [do-body do-tail-call] [
	; a helper function evaluating tail-func body
	do-body: func [
		[throw]
		body [block!]
	] [
		while [true] [catch/name [return do body] 'tail-call]
	]
	
	; a helper function executing the tail call
	do-tail-call: func [
		func-context [block! none!]
		'tail-context [word! none!]
	] [
		if func-context [
			set/any func-context second bind? tail-context
		]
		throw/name none 'tail-call
	]
	
	tail-func: func [
	    {
			Define a recursive user function with the supplied SPEC and BODY.
	     	The function can use a special TAIL-CALL local function
	     	to perform a tail-recursive function call.
	    }
	    [catch]
	
		spec [block!] {Help string (opt) followed by arg words (and opt type and string)}
	    body [block!] {The body block of the function}
	    /local the-function tail-call context-word context-block
	] [
		; define a new 'tail-call local variable
		tail-call: use [tail-call] ['tail-call]
		
		; bind the given BODY to "know" the 'tail-call variable
		body: bind/copy body tail-call
		
		; find a local word in SPEC
		context-word: find spec any-word!
		if context-word [context-word: to word! first context-word]
		
		; define the TAIL-CALL function
		set tail-call throw-on-error [
			func spec compose [do-tail-call (context-word) (context-word)]
		]

		; define the function
		the-function: throw-on-error [
			func spec reduce [context-word body] 
		]
		
		; get the function context
		context-word: first second :the-function

		; adjust the function body

		; replace the context word in the function body by DO-BODY
		change second :the-function 'do-body

		; adjust the TAIL-CALL body

		; make sure the 'do-tail-call word is bound correctly
		change second get tail-call 'do-tail-call

		if context-word [
			; make the first argument of DO-TAIL-CALL a function context block
			context-block: first bind? context-word
			; take care of refinements
			repeat i length? context-block [
				poke context-block i to word! pick context-block i
			]
			bind context-block context-word
			change/only at second get tail-call 2 context-block
		]
	
	    :the-function
	]
]