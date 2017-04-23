REBOL [
    Title: "Pop"
    Date: 3-Jul-2002
    Name: 'Pop
    Version: 1.0.0
    File: %pop.r
    Author: "Andrew Martin"
    Purpose: {Returns the first value in a series and removes it from the series.}
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

Pop: function [
	"Returns the first value in a series and removes it from the series."
	Stack [series! port! bitset!]	"Series at point to pop from."
	][
	Value
	][
	Value: pick Stack 1
	remove Stack
	:Value
	]
