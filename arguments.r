REBOL [
    Title: "Arguments"
    Date: 31-Aug-2002
    Name: 'Arguments
    Version: 1.0.1
    File: %arguments.r
    Author: "Andrew Martin"
    Purpose: "Returns the arguments of the function as a block."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    Example: [
        Arguments :Arguments
    ]
    library: [
        level: 'intermediate 
        platform: none 
        type: 'function 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Arguments: function [
	"Returns the arguments of the function as a block."
	F [any-function!]
	] [
	Arguments
	] [
	Arguments: make block! 2
	foreach Argument pick :F 1 [
		if refinement? :Argument [
			break
			]
		append Arguments :Argument
		]
	Arguments
	]
