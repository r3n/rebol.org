REBOL [
    Title: "Greek"
    Date: 3-Jul-2002
    Name: 'Greek
    Version: 1.0.0
    File: %greek.r
    Author: "Andrew Martin"
    Purpose: {
^-^-Greek changes all upper and lower case letters to random letters,
^-^-preserving their case, and changes digits to random digits as well.
^-^-}
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'intermediate 
        platform: none 
        type: 'tool 
        domain: 'text-processing 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Greek: function [
	{Greek changes all upper and lower case letters to random letters,
	preserving their case, and changes digits to random digits as well.}
	Text [string!]	{The text to "greek".}
	][
	Mark
	][
	parse/case Text [
		some [
			Mark: Upper (change Mark #"A" - 1 + random 26) |
			Mark: Lower (change Mark #"a" - 1 + random 26) |
			Mark: Digit (change Mark #"0" - 1 + random 10) |
			skip
			]
		]
	Text
	]
