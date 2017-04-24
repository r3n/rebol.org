REBOL [
	File: %multi-methods.r
	Date: 11-Apr-2005
	Title: "Multi-methods implementation"
	Version: 1.4.0
	Author: "Jaime Vargas"
	Rights: {Copyright © Jaime Vargas, Why Wire, Inc. 2005}
	Purpose: {Implements polyformism using multi-methods technique and typed objects}
	library: [
	    level: 'intermediate
	    platform: 'all
	    type: 'tool
	    domain: [dialects extension math scientific]
	    tested-under: none
	    support: none
	    license: 'BSD
	    see-also: none
	]
]

time-it: func [code [block!] /local start time][
	start: now/time/precise 
	do code 
	time: now/time/precise - start
	print [mold code "->" time]
]

unfold-native: func [
	name [word!] dispatch-table [series!]
	/local 
		f spec 
		arg-types b refinement-rule parameter-rule locals-rule spec-rule
		i-vars blocks code permutations
][
	f: get name
	spec: third :f
	
	arg-types: copy []
	refinement-rule: [refinement! opt word! opt block! opt string! end skip] ;force fail
	parameter-rule: [word! set b block! (insert/only tail arg-types b) opt string!]
	locals-rule: [/local some [word!]]
	spec-rule: [opt string! some [refinement-rule | parameter-rule] opt locals-rule]
	
	unless parse spec spec-rule [throw make error join "Can't overload " :name]
	
	i-vars: copy [] ;vars for the iterators
	blocks: copy [] ;vars for the blocks
	repeat i length? arg-types [
		insert tail i-vars to-word join 'i i
		insert tail blocks to-word join 'b i
		replace/all arg-types/:i number! [integer! decimal!] ;make types explicit
	]
	
	code: copy "["
	repeat i length? arg-types [
		insert tail code form compose [foreach (i-vars/:i) (blocks/:i) "["]
	]
	insert tail code mold/only compose/only [insert/only tail permutations reduce (i-vars)]
	insert/dup tail code "]" 1 + length? arg-types
    code: load form code

	permutations: copy []
	use blocks [
		set blocks arg-types
		do bind code 'arg-types 
	]
	
	foreach spec permutations [
		insert tail dispatch-table reduce [mold spec :f]
	]
]

define-method: func [
	[catch]
	'name [word!] spec [block!] code [block!] /trace
	/local 
	    arg-spec fp-spec locals t v w 
		name-rule type-rule continue? param-spec-rule monad-types monad-rule monad-rule-spec local-rule spec-rule
		register-name methods-name
][
	;; first validate the spec
	arg-spec: copy []
	fp-spec: copy []
	locals: copy []

	continue?: [none] ;used to stop parsing
	
	;; spec as a parameter specification list
	name-rule: [set w set-word!]
	type-rule: [set t word! (unless datatype? attempt [get t] [continue?: [end skip]])]
	param-spec-rule: [some [name-rule type-rule continue? (
		insert tail arg-spec reduce [to-word :w reduce [:t]]
		insert tail fp-spec :t
	)]]
	
	;; spec as a monadic specification list
	monad-types: [number! | money! | pair! | tuple! | any-string! | date! | time!]
	monad-rule: [set v monad-types]
	monad-spec-rule: [some [name-rule monad-rule (insert tail fp-spec reduce [:v])]]
	
	local-rule: [/local some [
		set w word! (
			if result: find arg-spec :w [continue?: [end skip]]
			insert tail locals :w)
		continue?]
	]
	
	spec-rule: [[param-spec-rule | monad-spec-rule] opt local-rule ]
    unless parse spec spec-rule [throw make error! "invalid spec"]

	register-name: to-word join :name '-register
	methods-name: to-word join :name '-methods?
	unless all [value? name value? methods-name] [
		
		if find [op!] type?/word attempt [get name] [throw make error! join "Can't overload " :name]
	
		context [
			dispatch-table: make block! []
		
			if find [action!] type?/word attempt [get name][
				unfold-native :name dispatch-table
			]
		
			spec-fingerprint: func [spec [block!] /local types][
				extract/index spec 2 2
			]
		
			values-fingerprint: func [values [block!] /local types][
				types: copy []
				foreach v values [insert tail types type?/word v]
				types
			]
		
			retrieve-func: func [values [block!] /local f fp][
				if f: select/only dispatch-table mold values [return compose [(:f) (true)]] ;monadic fingerprint
				either f: select/only dispatch-table fp: mold values-fingerprint values [compose [(:f) (false)]][
					throw make error! reform ["Don't have a method to handle:" fp]
				]
			]
		
			set :name func [[catch] values [block!] /local f monadic] compose [
				values: reduce values
				set [f monadic] retrieve-func values
				(either trace [
					[  
						probe do probe compose either monadic [ [(:f)] ][ [(:f) (values)] ]
					]
				][	
					[
						do compose either monadic [ [(:f)] ][ [(:f) (values)] ]
					]
				])
			]
		
			set :register-name func [fp-spec spec locals code /local fingerprint pos][
				either found? pos: find/only dispatch-table fp-spec [
					poke dispatch-table 1 + index? pos function spec locals code
				][
					insert tail dispatch-table reduce [mold fp-spec function spec locals code]
				]
			]
		
			set :methods-name does [
				foreach [fp f] dispatch-table [
					print [:fp "->" mold either 'action! = type?/word :f [:f][second :f]]
				]
			]
		]
	]

	do reduce [register-name fp-spec arg-spec locals code]
	none
]

comment [
	;;Usage examples
	
	;define-method creates a "fingerprint" for each parameter-spec
	;and evals corresponding code according to "fingerprint"
	define-method f [x: integer!] [x + 1]
	define-method f [s: block!] [attempt [pick s 2]]
	define-method f [x: decimal!] [sine x]

	>> f[1] == 2
	>> f[[one two three]] == two
	>> b: [one two three]
	>> f[b] == two
	>> f[90.0] == 1.0

	;instrospection one can always see the methods of a function
	>> f-methods?
	;[integer!] -> [x + 1]
	;[block!] -> [attempt [pick s 2]]
	;[decimal!] -> [sine x]

	;singleton parameter specs are posible.
	;This allows for "rule" based programming
	define-method fact [n: 0] [1]
	define-method fact [n: integer!][n * fact[n - 1]]

	>> fact-methods? 
	;[0] -> [1]
	;[integer!] -> [n * fact [n - 1]]

	;now that we have singletons we can use memoization techniques
	define-method fact-memoize [n: 0] [1]
	define-method fact-memoize [n: integer! /local r ][
		r: n * fact[n - 1]
		define-method fact-memoize compose [n: (:n)] reduce [r]
		r
	]

	>> time-it [fact[12]] == 0:00:00.000434         ;no memoization
	>> time-it [fact-memoize[12]] == 0:00:00.000583 ;first invoication
	>> time-it [fact-memoize[12]] == 0:00:00.000087 ;cache lookup

	;dispatch for undefined type signals error
	>> fact[1.0] 
	** User Error: Don't have a method to handle: [decimal!]
	** Near: fact [1.0]

	;moization is more dramatic when calculating the fibonacci sequence
	define-method fib [n: 1] [1]
	define-method fib [n: 2] [1]
	define-method fib [n: integer!][ add fib[n - 2] fib[n - 1] ]

	define-method fib-memoize [n: 1] [1]
	define-method fib-memoize [n: 2] [1]
	define-method fib-memoize [n: integer! /local r][
		r: add fib-memoize[n - 1] fib-memoize[n - 2]
		define-method fib-memoize compose [n: (:n)] reduce [r]
		r
	]

	;without memoization
	>> time-it [fib [20]] == 0:00:00.32601
	>> time-it [fib [19]] == 0:00:00.207066

	;dramatic gains due to memoization
	>> time-it [fib-memoize[20]] == 0:00:00.002187 ;first invoication
	>> time-it [fib-memoize[20]] == 0:00:00.000096 ;cache lookup
	>> time-it [fib-memoize[19]] == 0:00:00.0001   ;cache lookup

	;it is possible to overload some natives!
	define-method add [x: issue! y: issue!][join x y]
	add[1 1] == 2
	add[1.0.0 1] == 2.1.1
	add[#abc #def] == #abcdef
]

define-object: func [
	spec [block!] 
	/local 
		arg-spec ctx-spec object-name constructor-name predicate-name attributes
		spec-rule type-spec continue? w
][
	arg-names: copy []

	continue?: [none] ;used to stop parsing
	name-rule: [set w word! (insert tail arg-names w)]
	type-rule: [set w word! (unless datatype? attempt [get w] [continue?: [end skip]])]
	spec-rule: [name-rule some [name-rule opt [into [some [type-rule continue?]]]]]

	either any [
		not parse spec spec-rule
		arg-names <> unique arg-names
	][
		make error! "invalid spec"
	]

    object-name: to-string first arg-names
	constructor-name: to-word join 'make- object-name
	predicate-name: to-word join object-name '?
	attributes: next arg-names

	arg-spec: copy []
	foreach itm attributes [
		insert tail arg-spec reduce [
			to-word join itm '-value
			either block? w: select spec itm [w][[any-type!]]
		]
	]

	ctx-spec: copy []
	arg-names: extract arg-spec 2 1
	repeat i length? attributes [
		insert tail ctx-spec reduce [to-set-word attributes/:i to-get-word arg-names/:i]
	]

	;create constructor function
	set constructor-name make function! 
		compose [(reform ["Makes a new" uppercase object-name "object with attributes" mold attributes]) (arg-spec)]
		compose/only [make object! (ctx-spec)] ;body

	;create predicate function
	set predicate-name make function! 
		compose [(reform ["Determines if value is a" uppercase object-name "object"]) value [object!] /local types]
		compose/deep/only [
			if (attributes) <> next first value [return false]
			
			foreach itm (attributes) [
				unless any [
					[any-type!] = types: select (arg-spec) to-word join itm '-value
					find types type?/word value/:itm
				][return false]
			]
			
			true
		] 
]

comment [
	;; Usage examples 
	
	define-object [point x [integer!] y [integer!]]
	
	point? make-point 1 1 == true
	point? context [x: 1 y: 1] == true
	point? context [x: "abc" y: "cde"] == false
	make-point "abc" "cde" == error!
]