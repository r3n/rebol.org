REBOL [
	title: "Block preprocessor. At last!"
	file: %preprocess.r
	author: "Marco Antoniazzi"
	Copyright: "(C) 2011 Marco Antoniazzi. All Rights reserved"
	email: [luce80 AT libero DOT it]
	date: 17-08-2011
	version: 0.5.1
	Purpose: "Use macros (also with parameters) in your code"
	Notes: {This is a very simple but quite usable implementation.
			Use with care. Not allowed: Macro recursion, multi-level #ifdef . Error checking is a nightmare ;( .
			To see expanded macros use: probe preprocess/debug code (generated code will possibly not work).
	}
	History: [
		0.5.1 [17-08-2011 "First version"]
	]
	library: [
		level: 'intermediate
		platform: 'all
		type: 'function
		domain: 'text-processing
		tested-under: [View 2.7.8.3.1]
		support: none
		license: 'BSD
		see-also: none
	]
]

context [
	system/error: make system/error [
	    macro-errors: make object! [
	        code: 1000
	        type: "Macro Error"
	        no-block: ["macro's spec and body must be block! not:" :arg1]
			no-rec: ["recursion not allowed in:" :arg1]
			redefined: ["macro:" :arg1 "-- already defined"]
	    ]
	]
	throw-error: func [[throw] message [block!]] [insert message first ['macro-errors] throw make error! reduce message]
	
	macros-list: copy []

	erase: func [{Removes from start to end from a series and returns after the remove. (eg. erase/all ";" "^/" to strip Rebol comments)}
		series [series! port! bitset!] start end /all
	] [
		until [
			series: any [remove/part find series start any [find/tail series end break] head series]
			any [head? series not all]
		]
		any [series head series]
	]
	replace_deep: func [target search replaced /all /local pos rep] [
		rep: pick [replace_deep replace_deep/all] none? all
		pos: target
		while [pos: find/tail pos any-block!] [
			do rep first back pos search replaced
		]
		do pick [replace replace/all] none? all target search replaced
		target
	]
	expand_macro_deep: func [code [block! paren!] name spec [block!] body [block!] /local pos new-body type] [

		replace_params_deep: func [args [block! paren!] spec [block!] body [block! paren!] /local param] [
			body: mold body
			foreach param spec [
				replace/all body mold param mold first args
				args: next args
			]
			load body
		]

		pos: code
		while [pos: find pos any-block!] [
			expand_macro_deep first pos name spec body
			pos: next pos
		]
		new-body: [[] []] ; intentionally use a static block
		pos: code
		while [pos: find pos name] [
			new-body: head change new-body next pos
			new-body: replace_params_deep new-body spec copy/deep body
			remove/part pos macros-list/:name + 1; remove macro's param(s)
			insert pos new-body
		]
		code
	]
	set 'preprocess func [[catch] code [block!] /debug /local pos name spec body] [
		insert macros-list [#date 0]
		replace_deep/all code #date now/date
		insert macros-list [#time 0]
		replace_deep/all code #time now/time
		insert macros-list [#define 2]
		expand_macro_deep code #define [name val] [#macro name [] [val]] ; predefined #define
		pos: code
		while [pos: find pos #ifdef] [
			name: first next pos
			either any [
				find/part code rejoin [[] #macro name] pos
				find/part code rejoin [[] #define name] pos
				] [
				remove/part pos 2; remove (unset) word
			] [
				erase pos #ifdef #endif
			]
		]
		pos: code
		while [pos: find pos #ifndef] [
			name: first next pos
			either any [
				find/part code rejoin [[] #macro name] pos
				find/part code rejoin [[] #define name] pos
				] [
				erase pos #ifndef #endif
			] [
				remove/part pos 2 ; remove (unset) word
			]
		]
		pos: code
		while [pos: find/tail pos #macro] [
			name: first pos
			spec: first next pos
			body: first next next pos
			if find mold body mold name [throw-error ['no-rec mold name]]
			if not block? spec [throw-error ['no-block type?/word spec] ]
			if not block? body [throw-error ['no-block type?/word body] ]
			if find mold pos join "#macro " mold name [throw-error ['redefined mold name]]
			insert macros-list reduce [name length? spec]
			if not debug [pos: remove/part back pos 4 pos: skip pos -3] ; remove macro's definition
			expand_macro_deep skip pos 3 name spec body
		]
		replace/all code #endif [] ; remoce orphans #endif
		code
	]
]

; EXAMPLES
; trying to use unique names for macros (using issue to better distinguish them)
code: [
#macro #comment [code] []
#macro #either-c [cond true-block false-block] [case [cond true-block true false-block]]
#macro #either-a [cond true-block false-block] [any [all [cond true-block] false-block]]
#macro #if-e [cond body] [#either-c cond body []] 											; redefine "if" with (redefined) "either"
#macro #if-c [cond body] [case [cond body]]
#macro #if-a [cond body] [all [cond do body]]
#macro #unless [cond body] [if not cond body]
#macro #loop [body] [while [true] body]														; I want an endless loop and I want to call it: ... "loop" ;)
#macro #while [cond body] [#loop [if not do cond [break] do body]]
#macro #until [body] [#loop [if do body [break]]]
#macro #cfor [init test inc body] [do init #while test [do body do inc]]
#macro #forskip [word skip-num body] [#while [not tail? word] [do body word: skip word skip-num]]
#macro #forall [word body] [#forskip word 1 body]
#macro #foreach [word data body] [#forall data [word: first data do body] data: head data]
#macro #func [] [make function!]
#macro #has [spec] [make function! head insert copy spec /local]
; ... and so on

print #comment "this is not printed" "this is not commented out"						; note that using "comment" instead gives an error

Print #date
Print #time

#define one 1
a: one bl: [a b c d]
#define debug 1
#ifdef debug
#macro #print [val] [print join "debugging:" val]
#endif
#ifndef debug
#define #print print
#endif
#print ["bl is:" bl]
#ifdef one
print "#ifdef: one"
#endif
#ifndef one
print "#ifndef: no one"
#endif
prin "#either-c: " print #either-c (a <> one) ["a <> 1"] ["a = 1"]							; ATTENTION: note use of parentheses
prin "#either-a: " print #either-a (a <> one) ["a <> 1"] ["a = 1"]
prin "#if-e: " #if-e (a = one) [print "a = 1"]
prin "#if-c: " #if-c (a = one) [print "a = 1"]
prin "#if-a: " #if-a (a = one) [print "a = 1"]
prin "#unless: " #unless (a <> one) [print "a = 1"]
prin "#loop: " #loop [print ["a =" a] a: a + 1 if a = 3 [break]]
prin "#while: " #while [a <= 4] [print ["a =" a] a: a + 1]
prin "#until: " #until [print ["a =" a] a: a + 1 a = 7]
prin "#cfor: " #cfor [a: 1] [a <= 2] [a: a + 1] [print ["a =" a]]
prin "#forskip: " #forskip bl 2 [print ["bl =" first bl]] bl: head bl
prin "#forall: " #forall bl [print ["bl =" first bl]] bl: head bl
prin "#foreach: " #foreach elem bl [print ["elem =" elem]]
print "end of macro experiments"

]
do preprocess code

halt

