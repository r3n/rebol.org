Rebol [
	Title: "Use-rule"
	File: %use-rule.r
	Author: ["Ladislav Mecir" "Gregg Irwin"]
	Date: 31-Oct-2010/9:48:59+1:00
	Purpose: {
		Create a recursion and thread-safe parse rule with local variables.
		R2/R3 compatible.
	}
	Notes: {
		The USE-RULE function implements two USE variants as described in
		http://www.rebol.net/wiki/Parse_Project.

		The default, rebinding variant, rebinds the given rule every time
		it is used for matching (that is why we call it "rebinding variant"),
		while the /no-rebind variant binds the given rule just once.

		The difference between the rebinding and the /no-rebind variant
		is similar as the difference between closures and functions.

		The WORDS block is expected to contain only words.

		The implementation of the USE-RULE function does not use
		the latest parse enhancements to remain compatible with R2
		as well as with R3.
	}
]

use-rule: func [
	{
		Create a recursion and thread-safe parse rule with local variables.
		R2/R3 compatible.
	}
	words [block!] {Local variables to use}
	rule [block!] {Parse rule}
	/no-rebind {Do not rebind the given RULE every time it is reused}
] [
	; we need some fresh local variables per every USE-RULE call
	make object! either no-rebind [[
		; We need the 'pos and 'success variables to transfer the parsing state
		; between "inner" and "outer" PARSE calls.
		pos: none
		success: none

		; The INNER-BODY function processes the given rule.
		inner-body: func [rule] [
			; If the parse of the given rule succeeds,
			; we set the "outer parse position"
			; to the point where the rule match ended,
			; otherwise we use [end skip] for "parse failure"
			; (for R2 compatibility).
			success: either parse pos [rule pos: to end] [
				[:pos]
			] [
				[end skip]
			]
		]

		; Define CONTEXT-FN's context to contain words specified by the caller.
		spec: copy []
		unless empty? words [append spec to refinement! first words]
		append spec next words
		
		; The CONTEXT-FN function calls the INNER-BODY function,
		; supplying the given rule bound to the CONTEXT-FN function's context
		; as the RULE argument to it.
		context-fn: func spec reduce [:inner-body rule]
		
		; The result rule will be a "snapshot" of the block below,
		; COPY/DEEP is needed to make sure the subsequent calls
		; of the USE-RULE function do not modify the rule
		set 'rule copy/deep [pos: (context-fn) success]
	]] [[
		; Define a new 'rebound-rule variable.
		; (this block is processed by MAKE OBJECT! at the top)
		rebound-rule: none

		set 'rule reduce [
			; The new rule contains a paren! evaluation at the start.
			to paren! compose/only/deep [
				; We compose a copy of the given WORDS block
				; as a WORDS argument into the USE call,
				; and a deep copy of the given RULE into the USE BODY.
				
				; Whenever the new rule is matched, the rule in the
				; USE BODY is rebound by the USE call and deep copied.
				; (to not be influenced by subsequent USE calls)
				rebound-rule: copy/deep use (copy words) [(copy/deep rule)]
			]
			
			; The rebound rule is used for matching by PARSE.
			'rebound-rule
		]
	]]
	rule
]


comment [
	; tests
	rule: [
		"b" (print 1) |
		a: "a" rule "a" b: (print subtract index? b index? a)
	]
	parse "aabaa" rule
	
	rule: use-rule [a b] [
		"b" (print 1) |
		a: "a" rule "a" b: (print subtract index? b index? a)
	]
	parse "aabaa" rule

	rule: use-rule/no-rebind [a b] [
		"b" (print 1) |
		a: "a" rule "a" b: (print subtract index? b index? a)
	]
	parse "aabaa" rule
]
