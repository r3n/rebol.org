Rebol [
	Title: "Apply"
	File: %apply.r
	Date: 26-Dec-2012/15:00:27+1:00
	Author: "Ladislav Mecir"
	Purpose: {APPLY function definition}
	License: {
		Licensed under the Apache License, Version 2.0 (the "License");
		you may not use this file except in compliance with the License.
		You may obtain a copy of the License at

		http://www.apache.org/licenses/LICENSE-2.0
	}
]

use [return1 return2 do-block] [
	return1: func [
		{special return function setting the given ATTRIBUTE word}
		[throw]
		attribute [word!]
		value [any-type!]
	][
		set attribute {no-attribute}
		return get/any 'value
	]

	return2: func [
		{
			special return function using the given ATTRIBUTE value
			to adjust the spec of the APPLY function
		}
		[throw]
		value [any-type!]
		attribute
	][
		poke third :apply 2 attribute
		return get/any 'value
	]

	do-block: func [
		{function doing a block}
		block [block!]
	][
		do block
	]

	apply: func [
		{apply a function to a block of arguments}
		[throw]
		f [any-function!]
		arguments [block!]
		/only {use arguments as-is, do not reduce the block!}
		/local call path index refinement attribute
		parameter get-argument ignore-argument
	][
		unless only [
			error? set/any 'parameter do-block [
				arguments: reduce arguments
				attribute: true
			]
			unless attribute [return2 get/any 'parameter [throw]]
		]
		; code calling the function
		call: reduce ['return1 first ['attribute] path: to path! 'f]
		index: 1 ; index of the argument to be processed
		parameter: get-argument: [
			word! (insert insert/only insert tail call 'pick arguments index)
			| lit-word! (
				either get-word? pick arguments index [
					use [argument] [
						error? set/any 'argument pick arguments index
						insert tail call first [:argument]
					]
				][
					insert/only tail call pick arguments index
				]
			) | get-word! (
				use [argument] [
					error? set/any 'argument pick arguments index
					insert tail call 'argument
				]
			)
		]
		ignore-argument: [word! | lit-word! | get-word!]
		parse third :f [
			any [
				[
					set refinement refinement! (
						parameter: either all [pick arguments index true][
							insert tail path to word! refinement
							get-argument
						][ignore-argument]
					) | parameter
				] (index: index + 1) ; argument processed
				| skip
			]
		]
		attribute: [throw]
		return2 do-block call attribute
	]
]

comment [
	; Helper functions
	quote: func [:x [any-type!]][return get/any 'x]
	also: func [x [any-type!] y [any-type!]][return get/any 'x]
	
	; Test cases:

	1 == apply :subtract [2 1]

	; 1 == apply :- [2 1] ; R3 - specific
	
	-2 == apply :- [2] ; R2 - specific

	none == apply func [a][a][]
	
	none == apply/only func [a][a][]
	
	1 == apply func [a][a][1 2]
	
	1 == apply/only func [a][a][1 2]
	
	true == apply func [/a][a][true]
	
	none == apply func [/a][a][false]
	
	none == apply func [/a][a][]
	
	true == apply/only func [/a][a][true]
	
	true == apply/only func [/a][a][false] ; the word 'false
	
	none == apply/only func [/a][a][]
	
	use [a] [a: true true == apply func [/a][a][a]]
	
	use [a] [a: false none == apply func [/a][a][a]]
	
	use [a] [a: false true == apply func [/a][a]['a]]
	
	use [a] [a: false true == apply func [/a][a][/a]]
	
	use [a] [a: false true == apply/only func [/a][a][a]]
	
	paren! == apply/only :type? [()]

	'paren! == apply/only :type? [() true]

	[1] == head apply :insert [copy [] [1] none none none]

	[1] == head apply :insert [copy [] [1] none none false]

	[[1]] == head apply :insert [copy [] [1] none none true]

	native! == apply :type? [:print]

	get-word! == apply/only :type? [:print]

	1 == do does [apply :return [1] 2]

	; 2 == do does [apply does [][return 1] 2] ; a bug
	
	1 == do does [apply does [][return 1] 2]

	; 2 == do does [apply func [a][a][return 1] 2] ; a bug
	
	1 == do does [apply func [a][a][return 1] 2]

	; unset? apply does [][return 1] ; a bug
	
	; 1 == apply func [a][a][return 1] ; a bug
	
	; error? try [apply :add [return 1 2]] ; R3 specific
	
	; error? try [apply :add [2 return 1]] ; R3 specific
	
	; error? try [apply :also [return 1 2]] ; R3 specific
	
	; 2 == apply :also [2 return 1] ; a bug

	unset? apply func [x [any-type!]][get/any 'x][()]

	unset? apply func ['x [any-type!]][get/any 'x][()]

	unset? apply func [:x [any-type!]][get/any 'x][()]

	unset? apply func [x [any-type!]][return get/any 'x][()]

	unset? apply func ['x [any-type!]][return get/any 'x][()]

	unset? apply func [:x [any-type!]][return get/any 'x][()]

	error? apply :make [error! ""]

	; error? apply func [:x [any-type!]][return get/any 'x][make error! ""] ; R3 - specific

	error? apply/only func ['x [any-type!]][
		return get/any 'x
	] head insert copy [] make error! ""

	error? apply/only func [:x [any-type!]][
		return get/any 'x
	] head insert copy [] make error! ""
	
	use [x][x: 1 strict-equal? 1 apply func ['x][:x][:x]]
	
	use [x][x: 1 strict-equal? first [:x] apply/only func ['x][:x][:x]]
	
	use [x][unset 'x strict-equal? first [:x] apply/only func ['x [any-type!]][
		return get/any 'x
	][:x]]
	
	use [x][x: 1 strict-equal? 1 apply func [:x][:x][x]]
	
	use [x][x: 1 strict-equal? 'x apply func [:x][:x]['x]]
	
	use [x][x: 1 strict-equal? 'x apply/only func [:x][:x][x]]
	
	use [x][x: 1 strict-equal? 'x apply/only func [:x][return :x][x]]
	
	use [x][unset 'x strict-equal? 'x apply/only func [:x [any-type!]][
		return get/any 'x
	][x]]
]
