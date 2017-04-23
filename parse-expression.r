REBOL [
	File: %parse-expression.r
	Date: 21-Mar-2011
	Title: "Mathematical Expression Dialect Parser"
	Author: "Francois Vanzeveren"
	Purpose: {Converts a mathematical expression into a block of rebol code that can be evaluated.}
	Version: 0.9.6
	History: [
		0.9.6 21-Mar-2011 "Francois Vanzeveren" 
			{- The caret character (^^) can now be used for exponentiation
			 - Minor improvement to ease the use of the library}
		0.9.5 16-Mar-2011 "Francois Vanzeveren" 
			{- BUG FIX: The evaluation of an expression containing trigonometric functions 
				caused an error.
			 - BUG FIX: The exponentiation of built-in functions (e.g. "log(2)**2")caused an error. 
			 - New built-in functions: log2()}
		0.9.4 15-Mar-2011 "Francois Vanzeveren"
			{- BUG FIX: + - * / and // are now left-associative! Thanks to Ladislav from REBOL3 
				on altme for reporting this bug!}
		0.9.3 14-Mar-2011 "Francois Vanzeveren"
			{- BUG FIX: signed numbers and signed (sub-)expressions are now properly handled.
				e.g. "+(1+x)/-(1-x)" returns [divide add 1.0 x negate subtract 1.0 x]}
		0.9.2 14-Mar-2011 "Francois Vanzeveren"
			{-IMPROVEMENT: much more readable and elegant recursive implementation.
			- BUG FIX: precedence between '**' and '*' fixed, e.g 2**3*6 will now return 
				[multiply power 2 3 6] instead of [power 2 multiply 3 6]}
		0.9.1 13-Mar-2011 "Francois Vanzeveren"
			{New functions implemented:
				abs(), arcos(), acos(), arcsin(), asin(), arctan(), atan(), cos(), exp(),
				log(), ln(), sin(), sqrt(), tan()}
		0.9.0 13-Mar-2011 "Francois Vanzeveren" 
			"First public release. Future versions will provide additional functions."
	]
	TO-DO: {
		Version 1.0.0
			- expression syntax error handling to return usefull messages to the user when
			she/he makes syntax errors in the expression.
	}
	Library: [
		level: 'intermediate
		platform: 'all
		type: [dialect function]
		domain: 'math
		tested-under: [windows linux]
		license: 'lgpl
	]
]

parse-expression: func [
	p_expression [string!] "The expression to parse."
	/local eq retval parent-depth str tmp char
] [
	eq: trim/all lowercase copy p_expression
	
	if empty? eq [return copy []]
	
	retval: copy []
	
	; Avons-nous à faire à un nombre?
	if tmp: attempt [to-decimal eq] [
		append retval tmp
		return retval
	] 
	
	parent-depth: 0
	str: copy ""
	char: copy ""
	
	; We first search for operators of first precedence (+ and -)
	parse/all eq [
		any [
			"+" (
				either any [greater? parent-depth 0 empty? char found? find "+-*/(" char]
				[append str "+"]
				[
					insert retval 'add					; by using 'insert...
					append retval parse-expression str	; and 'append, we preserve the left-associativity of the addition
					str: copy ""
				]
				char: copy "+"
			) |
			"-" (
				either any [greater? parent-depth 0 empty? char found? find "+-*/(" char]
				[append str "-"] 
				[
					insert retval 'subtract				; by using 'insert
					append retval parse-expression str	; and 'append, we preserve the left-associativity of the subtraction
					str: copy ""
				] 
				char: copy "-"
			) |
			"(" (
				append str "("
			  	parent-depth: add parent-depth 1
			  	char: copy "("
			) | 
			")" (
				append str ")"
				parent-depth: subtract parent-depth 1
				char: copy ")"
			) | 
			copy char skip (append str char)
		]
	]
	
	if not empty? retval [
		append retval parse-expression str
		return retval
	]
	
	; We did not find operator of first precedence (+ and -)
	; We look now for second precedence (* and /).
	parent-depth: 0
	str: copy ""

	parse/all eq [
		any [ 
			"**" (append str "**" char: copy "*") | 
			"*" (
				either zero? parent-depth [
					insert retval 'multiply				; by using 'insert...
					append retval parse-expression str	; and 'append, we preserve the left-associativity of the multiplication
					str: copy ""
				] [append str "*"]
				char: copy "*"
			) |
			"//" (
				either zero? parent-depth [
					insert retval 'remainder			; by using 'insert...
					append retval parse-expression str	; and 'append, we preserve the left-associativity of the remainder
					str: copy ""
				] [append str "//"]
				char: copy "/"
			) |
			"/" (
				either zero? parent-depth [
					insert retval 'divide				; by using 'insert... 
					append retval parse-expression str 	; and 'append, we preserve the left-associativity of the division
					str: copy ""
				] [append str "/"]
				char: copy "/"
			) |
			"(" (
				append str "("
			  	parent-depth: add parent-depth 1
			  	char: copy "("
			) | 
			")" (
				append str ")"
				parent-depth: subtract parent-depth 1
				char: copy ")"
			) | 
			copy char skip (append str char)
		]
	]
	
	if not empty? retval [
		append retval parse-expression str
		return retval
	]
	
	; Toujours rien? Il s'agit alors:
	; * soit d'un exposant
	; * soit d'un opérateur unitaire
	; * soit d'une expression entièrement comprise entre parenthèse
	; * soit d'une inconnue
	
	; Exposant
	parent-depth: 0
	str: copy ""
	parse/all eq [
		any [
			"**" (
				either zero? parent-depth [
					append retval 'power 
					append retval parse-expression str
					str: copy ""
				] [append str "**"]
			) | 
			"^^" (
				either zero? parent-depth [
					append retval 'power 
					append retval parse-expression str
					str: copy ""
				] [append str "^^"]
			) | 
			"(" (
				append str "("
			  	parent-depth: add parent-depth 1
			) | 
			")" (
				append str ")"
				parent-depth: subtract parent-depth 1
			) | copy char skip (append str char)
		]
	]
	if not empty? retval [
		append retval parse-expression str
		return retval
	]
	
	; opérateur unitaire
	parent-depth: 0
	str: copy ""
	parse/all eq [
		"+" copy str to end (
			append retval parse-expression str
			return retval
		) |
		"-" copy str to end (
			append retval 'negate
			append retval parse-expression str
			return retval
		) |
		"abs(" copy str to end (
			remove back tail str
			append retval 'abs
			append retval parse-expression str
			return retval
		) |
		"arccos(" copy str to end (
			remove back tail str
			append/only retval 'arccosine/radians
			append retval parse-expression str
			return retval
		) |
		"acos(" copy str to end (
			remove back tail str
			append/only retval 'arccosine/radians
			append retval parse-expression str
			return retval
		) |
		"arcsin(" copy str to end (
			remove back tail str
			append/only retval 'arcsine/radians
			append retval parse-expression str
			return retval
		) |
		"asin(" copy str to end (
			remove back tail str
			append/only retval 'arcsine/radians
			append retval parse-expression str
			return retval
		) |
		"arctan(" copy str to end (
			remove back tail str
			append/only retval 'arctangent/radians
			append retval parse-expression str
			return retval
		) |
		"atan(" copy str to end (
			remove back tail str
			append/only retval 'arctangent/radians
			append retval parse-expression str
			return retval
		) |
		"cos(" copy str to end (
			remove back tail str
			append/only retval 'cosine/radians 
			append retval parse-expression str
			return retval
		) |
		"exp(" copy str to end (
			remove back tail str
			append retval 'exp 
			append retval parse-expression str
			return retval
		) |
		"log2(" copy str to end (
			remove back tail str
			append retval 'log-2 
			append retval parse-expression str
			return retval
		) |
		"log10(" copy str to end (
			remove back tail str
			append retval 'log-10 
			append retval parse-expression str
			return retval
		) |
		"log(" copy str to end (
			remove back tail str
			append retval 'log-10 
			append retval parse-expression str
			return retval
		) |
		"ln(" copy str to end (
			remove back tail str
			append retval 'log-e 
			append retval parse-expression str
			return retval
		) |
		"sin(" copy str to end (
			remove back tail str
			append/only retval 'sine/radians
			append retval parse-expression str
			return retval
		) |
		"sqrt(" copy str to end (
			remove back tail str
			append retval 'square-root
			append retval parse-expression str
			return retval
		) | 
		"tan(" copy str to end (
			remove back tail str
			append/only retval 'tangent/radians
			append retval parse-expression str
			return retval
		)
	]
	
	; Expression complètement comprise entre parenthèses.
	if equal? #"(" first eq [
		remove head eq ; on supprimer la parenthèse ouvrante
		remove back tail eq ; on supprimer la parenthèse fermante
		append retval parse-expression eq
		return retval
	]
	
	; il ne reste plus que l'hypothèse d'une inconnue
	append retval to-word eq
	return retval
]