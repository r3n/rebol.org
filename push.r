REBOL [
    Title: "Push"
    Date: 3-Jul-2002
    Name: 'Push
    Version: 1.0.0
    File: %push.r
    Author: "Andrew Martin"
    Purpose: {Inserts a value into a series and returns the series head.}
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'beginner 
        platform: none 
        type: 'function 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Push: func [
	"Inserts a value into a series and returns the series head."
	Stack [series! port! bitset!]	"Series at point to insert."
	Value [any-type!] /Only	"The value to insert."
	][
	head either Only [
		insert/only Stack :Value
		][
		insert Stack :Value
		]
	]
