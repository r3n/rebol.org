Rebol [
	Title: "Flatten"
	File: %flatten.r
	Author: "Ladislav Mecir"
	Date: 03/Jul/2009
	Purpose: {flatten a block}
]

flatten: func [
	block [block!]
	/local result pos rule
] [
	result: make block! 0
	parse block rule: [
		any [
			pos: block! :pos into rule
			| skip (insert/only tail result first pos)
		]
	]
	result
]
