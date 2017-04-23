REBOL [
	Date: 13-Mar-2011/17:56:26+1:00
	File: %evaluate.r
	Title: "Evaluate"
	Author: "Ladislav Mecir"
	Purpose: {
		A few expression evaluators and expression translators written in REBOL.
	}
]

#include-check %use-rule.r

slash: to lit-word! first [/]

double-slash: to lit-word! first [//]

unless value? 'words-of [
	words-of: func [value] [copy next first value]
	values-of: func [value] [copy next second value]
]

; An object containing evaluating functions.
evaluate: make object! [
	pow: :power
	mul: :multiply
	div: :divide
	rem: :remainder
	ad: :add
	sub: :subtract
	neg: :negate
	setw: :set
	seq: func [a b] [a]
]

; An object containing translating functions.
translate: make object! [
	pow: func [a b] [append append copy [power] a b]	
	mul: func [a b] [append append copy [multiply] a b]
	div: func [a b] [append append copy [divide] a b]
	rem: func [a b] [append append copy [remainder] a b]
	ad: func [a b] [append append copy [add] a b]
	sub: func [a b] [append append copy [subtract] a b]
	neg: func [a] [append copy [negate] a]
	setw: func [a b] [append append/only copy [set first] append copy [] a b]
	seq: func [a b] [append a b]
]

; The expression parsing functions below take an EVALUATOR argument,
; which can be an object containing either evaluating or translating functions,
; causing the respective expression parsing function to either yield a result,
; or a translation of the given expression.

; In the functions, the variable 'a is used as an accumulator.
; When 'a is going to be overwritten,
; we store the content in a rule-local variable 'b.

std: func [
	{
		Standard priority/associativity evaluator
		Priority/associativity:
		0: number, paren
		1: unary -, unary +/right to left
		2: power/right to left
		3: multiplication, division, remainder/left to right
		4: addition, subtraction/left to right
		5: set-word/right to left
		6: expression expression/left to right
	}
	[catch]
	expression [block!]
	evaluator [object!]
	/local pow mul div rem ad sub neg setw seq
	pos a element p1 p2 p3 p4 expr
] [
	set bind words-of evaluator 'local values-of evaluator
	
	element: [pos: paren! :pos into p4 | set a number!]
	
	; right to left
	p1: use-rule [b] [
		'- p1 (a: neg a)
		| '+ p1
		| set b set-word! p4 (a: setw b a)
		| element
	]
	
	; right to left
	p2: use-rule [b] [p1 opt ['** (b: a) p2 (a: pow b a)]]
	
	; left to right
	p3: use-rule [b] [
		p2 any [
			'* (b: a) p2 (a: mul b a)
			| slash (b: a) p2 (a: div b a)
			| double-slash (b: a) p2 (a: rem b a)
		]
	]
	
	; left to right
	p4: use-rule [b] [
		p3 any ['+ (b: a) p3 (a: ad b a) | '- (b: a) p3 (a: sub b a)]
	]

	; left to right
	expr: use-rule [b] [
		p4 any [(b: a) p4 (a: seq b a)] end
		| (throw make error! "invalid expression")
	]
	
	parse expression expr

	a
]

sra: func [
	{
		Simple right-associative expression evaluator
		Priority/associativity:
		0: number, paren
		1: infix: power, multiplication, division, remainder,
		addition, subtraction/right to left
		2: prefix: negate, power, multiplication, division, remainder,
		addition set-word/right to left
		3: subexpression subexpression/left to right
	}
	[catch]
	expression [block!]
	evaluator [object!]
	/local pow mul div rem ad sub neg setw seq
	pos a m expr right-operand prefix infix element
] [
	set bind words-of evaluator 'local values-of evaluator
	
	element: [pos: paren! :pos into expr | set a number!]
	
	prefix: use-rule [b] [
		'- right-operand (a: neg a)
		| set b set-word! right-operand (a: setw b a)
		| '+ right-operand (b: a) infix (a: ad b a)
		| '* right-operand (b: a) infix (a: mul b a)
		| slash (b: a) right-operand infix (a: div b a)
		| double-slash (b: a) right-operand infix (a: rem b a)
		| '** (b: a) right-operand infix (a: pow b a)
	]
	
	infix: use-rule [b] [
		element opt [
			'+ (b: a) right-operand (a: ad b a)
			| '- (b: a) right-operand (a: sub b a)
			| '* (b: a) right-operand (a: mul b a)
			| slash (b: a) right-operand (a: div b a)
			| double-slash (b: a) right-operand (a: rem b a)
			| '** (b: a) right-operand (a: pow b a)
		]
	]
	
	right-operand: [prefix | infix]
	
	expr: use-rule [b] [
		right-operand any [(b: a) infix (a: seq b a)] end |
		(throw make error! "invalid expression")
	]
	
	parse expression expr
	
	a
]

rle: func [
	{
		REBOL-like expression evaluator
		Priority/associativity:
		0: number, paren
		1: infix: power, multiplication, division, remainder,
		addition, subtraction/left to right
		2: prefix: negate, power, multiplication, division, remainder,
		addition set-word/right to left
		3: subexpression subexpression/left to right
	}
	[catch]
	expression [block!]
	evaluator [object!]
	/local pow mul div rem ad sub neg setw seq
	pos a expr right-operand prefix infix element
] [
	set bind words-of evaluator 'local values-of evaluator

	element: [pos: paren! :pos into expr | set a number!]

	prefix: use-rule [b] [
		'- prefix (a: neg a)
		| set b set-word! right-operand (a: setw b a)
		| '+ right-operand (b: a) infix (a: ad b a)
		| '* right-operand (b: a) infix (a: mul b a)
		| slash right-operand (b: a) infix (a: div b a)
		| double-slash right-operand (b: a) infix (a: rem b a)
		| '** right-operand (b: a) infix (a: pow b a)
	]
	
	right-operand: [prefix | infix]
	
	infix: use-rule [b] [
		element any [
			'+ (b: a) element (a: ad b a)
			| '- (b: a) element (a: sub b a)
			| '* (b: a) element (a: mul b a)
			| slash (b: a) element (a: div b a)
			| double-slash (b: a) element (a: rem b a)
			| '** (b: a) element (a: pow b a)
		] opt [
			'+ (b: a) prefix (a: ad b a)
			| '- (b: a) prefix (a: sub b a)
			| '* (b: a) prefix (a: mul b a)
			| slash (b: a) prefix (a: div b a)
			| double-slash (b: a) prefix (a: rem b a)
			| '** (b: a) prefix (a: pow b a)
		]
	]
	
	expr: use-rule [b] [
		right-operand any [(b: a) infix (a: seq b a)] end |
		(throw make error! "invalid expression")
	]
	
	parse expression expr

	a
]

comment [
	foreach expression [
		[1 + 2 ** 3 * 2]
	] [
		print ["Expression:" mold expression]
		foreach f [std sra rle] [
			print [
				f
				"result:" do get f expression evaluate
				"translation:" mold do get f expression translate
			]
		]
	]
]

comment [
	results:
	
	Expression: [1 + 2 ** 3 * 2]
	std result: 17.0 translation: [add 1 multiply power 2 3 2]
	sra result: 65.0 translation: [add 1 power 2 multiply 3 2]
	rle result: 54.0 translation: [multiply power add 1 2 3 2]
]
