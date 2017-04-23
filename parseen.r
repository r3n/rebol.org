Rebol[
	Title: "Parseen"
	Date: 28-Nov-2010/9:09:13+1:00
	History: [
		26/Apr/2003/11:30			"working version"
		21/Dec/2004/13:40			"thru-rule added"
		22/Dec/2004/8:05			"lit added"
		18-Mar-2007/1:45:14+1:00	"do-block corrected"
		18-Mar-2007/9:57:05+1:00	"dialect upgraded"
		16-Oct-2010/23:13:26+2:00	"then-rule added"
									"the parseen function removed"
									"lit rule renamed to quote-rule"
		31-Oct-2010/9:16:55+1:00	"if-rule added"
	]
	File: %parseen.r
	Author: "Ladislav Mecir"
	Purpose: {Parse enhancements for R2}
]

comment [
	; Example # 1  

	rule: not-rule [any "a" "b"]
	parse "ab" rule
	parse "b" rule
	parse "" rule

	; Example # 2

	rule: not-rule "aa"
	parse "ab" [rule any "a" "b"]
	parse "aab" [rule any "a" "b"]

	; Example # 3

	rule: not-rule quote-rule 1
	parse [1] [any [rule skip]]
	parse [2] [any [rule skip]]

	; Example # 4

	rule: not-rule integer!
	parse [1 a] [rule to end]
	parse [a 1] [rule to end]

	; Example # 5

	parse [a b c 1 d] [any [rule skip]]
	parse [a b c d e] [any [rule skip]]

	; Example # 6

	result: ""
	rule: to-rule [" " | "<br>"]
	parse/all "aa" [rule result: to end]
	probe result
	parse/all "a a<br>" [rule result: to end]
	probe result
	parse/all "ab<br> " [rule result: to end]
	probe result

	; Example # 7

	digit: charset [#"0" - #"9"]
	four-digit: [4 digit]
	rule: to-rule four-digit
	parse/all "abcd 1234" [rule copy fd four-digit to end]
	probe fd

	; Example # 8

	pm: charset "+-"
	rule: thru-rule pm
	parse "assdasasasa+" [copy t rule]
	probe t

	; Example # 9

	rule: quote-rule first ['ahoj]
	parse ['ahoj] rule
	parse [ahoj] rule
	
	; Example # 10
	rule: if-rule (false)
	parse [] rule
	
	; Example # 11
	rule: if-rule (true)
	parse [] rule
]

; a rule that always fails, opposite to none
fail: [end skip]

use [x y z] [
	then-rule: func [
		{generate the A THEN B | C rule}
		a
		b
		c
		/local d
	] [
		d: copy first [(x:)]
		reduce [reduce [a append/only d b '| append/only d c] 'x]
	]

	not-rule: func [
		{generate the NOT A rule}
		a
	] [
		reduce [append reduce [a] [(x: fail) | (x: none)] 'x]
	]

	and-rule: func [
		{generate the AND A rule}
		a
	] [
		reduce [append reduce [a] [(x: fail) | (x: none)] fail '| 'x]
	]

	to-rule: func [
		{generate the TO A rule}
		a
	] [
		reduce [
			'any reduce [
				append reduce [a] [(x: fail y: none) | (x: 'skip y: fail)] 'x
			]
			'y
		]
	]

	thru-rule: func [
		{generate the THRU A rule}
		a
	] [
		reduce [
			'any reduce [
				append reduce [a] [x: (y: fail z: [:x]) | (y: 'skip z: fail)] 'y
			]
			'z
		]
	]

	quote-rule: func [
		{generate the QUOTE A rule}
		a
		/local b
	] [
		b: copy/deep [copy x skip (y: unless equal? x) y]
		append/only append/only fourth b reduce [:a] [fail]
		b
	]

	if-rule: func [
		{generate the IF A rule}
		'a [paren!]
	] [
		a: reduce [first [x:] 'either :a [none] [[end skip]]]
		reduce [to paren! a 'x]
	]
]
