REBOL [
    Title: "Calculese"
    Date: 9-OCT-2004
    Version: 1.0.0
    File: %calculese.r
    Author: "Ryan S. Cole"
    Purpose: "A dialect for creating calculators."
    Email: ryan@skurunner.com
    library: [
        level: 'intermediate 
        platform: 'all
        type: 'dialect
        domain: 'math 
        tested-under: none 
        support: none 
        license: 'pd
        see-also: none
    ]
]

comment [
>> calculese "4 * 55 ="
== "120."

>> calculese "1"
== "1."
>> calculese "+"
== "1."
>> calculese "2"
== "2."
>> calculese "="
== "3."

]


calc-engine: make object! [
	op: none
	reg: []
	acc: none
	error: none
	error-message: "ERROR!"
	memory: none
	stack: []

	begin-paren: does [
		insert/only stack reduce [op reg]
		acc: op: none
		reg: copy []
	]
	
	end-paren: does [
		op: stack/1/1
		reg: stack/1/2
		remove stack
		if none? pick reg not op [insert reg copy ""]
		reg/1: any [acc form 0] 

	]


	; For working with the displayed number...
	;cur-str: does [any [reg/1 acc form 0]]
	;cur-num: does [to-decimal cur-str]
	cur-set: func [val] [
		either not either :op [reg/2][reg/1] [
			insert reg form val
		] [
			reg/1: form val
		]
	]

	op-defs: reduce [
		"+" :add
		"-" :subtract
		"*" :multiply
		"x" :multiply
		"×" :multiply
		"·" :multiply
		"/" :divide
		"÷" :divide
		"And" func [a b] [and to-integer a to-integer b]
		"Or" func [a b] [or to-integer a to-integer b]
		"Xor" func [a b] [xor to-integer a to-integer b]
		"Mod" :remainder
		"^^" :power
		"Exp" :power
	]

	func-defs: reduce [
		"Neg" :negate
		"±" :negate
		"Abs" :absolute
		"Arccos" :Arccosine
		"Arcsin" :Arcsine
		"Arctan" :Arctangent
		"Cos" :cosine
		"Sin" :sine
		"Tan" :Tangent
		"Not" :complement
		"Exp-E" :exp
		"Log-10" :log-10
		"Log-2" :log-2
		"Log-E" :log-E
		"Rnd" :random
		"SqR" :square-root
		"Pi" func [arg] [Pi]
		"%" func [arg] [arg * .01]
		"¹/x" func [arg] [1 / arg]
		"²" func [arg] [arg * arg]
		"³" func [arg] [arg * arg * arg]
		"++" func [arg] [arg + 1]
		"--" func [arg] [arg - 1]
		"MR" func [arg] [any [memory 0]]
	]

	null-func-defs: reduce [
		"MC" func [arg] [memory: none arg]
		"M+" func [arg] [memory: (any [memory 0]) + arg]
		"M-" func [arg] [memory: (any [memory 0]) - arg]
		"M*" func [arg] [memory: (any [memory 0]) * arg]
		"Mx" func [arg] [memory: (any [memory 0]) * arg]
		"M×" func [arg] [memory: (any [memory 0]) * arg]
		"M·" func [arg] [memory: (any [memory 0]) * arg]
		"M/" func [arg] [memory: (any [memory 0]) / arg]
		"M÷" func [arg] [memory: (any [memory 0]) / arg]
	]



	display: has [txt] [
		if error [return error-message]
		txt: form any [reg/1 reg/2 acc 0]
		if not find txt "." [append txt "."]
		return txt
	]

	;does double argument operations
	solve-op: has [tmp] [
		tmp: load form any [reg/2 acc reg/1 0]
		acc: none
		op: select op-defs op
		if :op [
			error: error? try [acc: do [
			op (to-decimal tmp) (to-decimal reg/1)
		] ] ]
		reg: copy []
		op: no
	]

	;does single argument in place operations
	solve-func: function [funx] [tmp] [
		tmp: to-decimal any [reg/1 acc 0]
		clear-entry
		error: error? try [acc: do [funx tmp]]
	]

	;does single argument null operations
	solve-null-func: function [funx] [tmp] [
		tmp: to-decimal any [reg/1 acc 0]
		error: error? try [funx tmp]
	]


	all-clear: does [
		acc: op: none
		reg: copy []
		stack: copy []
	]

	clear-entry: does [
		acc: none
		remove either reg/2 [next reg][reg]
	]

	press: function [key] [def old-op] [
		error: none
;print ["key: " key "  reg: " reg "  acc: " acc "  mem: " memory] 

		if find ".0123456789" key [
			if none? pick reg not op [insert reg copy ""]
			if all ["." = key  find reg/1 key] [exit]
			if all ["0" = key  reg/1/1 = key] [exit]
			append reg/1 key
			acc: none
		]
		if select op-defs key [
			if reg/2 [solve-op]
			any [reg/1 insert reg any [acc 0]] 
			op: key
		]
		if selected: select func-defs key [solve-func :selected]
		if selected: select null-func-defs key [solve-null-func :selected]
		if find "^M=" key [solve-op]
		if "AC" = key [all-clear]
		if "CE" = key [clear-entry]

		if "(" = key [
			if reg/2 [solve-op]
			;any [reg/1 insert reg any [acc 0]]
			begin-paren
		]
		if ")" = key [
			if not empty? stack [
				if reg/2 [solve-op]
				end-paren
			]
		]
;print ["key: " key "  reg: " reg "  acc: " acc "  mem: " memory] 

	]
]

calculese: function [calc [string! block!]] [] [
	if block? calc [calc: form calc]
	characters: complement charset [".0123456789"]
	foreach token parse/all calc " " [
		either find token characters [
			calc-engine/press to-string token
		] [
			foreach digit to-string token [
				calc-engine/press to-string digit
			]
		]
	]

	calc-engine/display
]


                                                                                                                                                                                                            