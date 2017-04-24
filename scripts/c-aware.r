REBOL [
	Author: "Ladislav Mecir"
	Title: "C-aware"
	File: %c-aware.r
	Date: 3-Nov-2010/18:10:31+1:00
	Purpose: {
		This is an idea, how to "instantly" make R2 cycle bodies CONTINUE-aware.
	}
]

c-aware: func [
	{make a block CONTINUE-aware}
	block [block!]
] [
	compose/only [catch/name (block) 'continue]
]

continue: func [[throw]] [throw/name none 'continue]

comment [
	; usage:
	for n 1 5 1 c-aware [
		if n < 3 [continue]
		print n
	]
]
