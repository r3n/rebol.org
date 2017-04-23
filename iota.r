REBOL [
    Title: "Iota"
    Date: 3-Jul-2002
    Name: 'Iota
    Version: 1.0.0
    File: %iota.r
    Author: "Andrew Martin"
    Purpose: {Makes a block containing a range of values, from Start to End.}
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    Example: [
    iota 1 10 
    iota/by -4 10 2 
    iota #"A" #"F"
]
    library: [
        level: 'beginner 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Iota: function [
	{Makes a block containing a range of values, from Start to End.}
	[catch throw]
	Start [number! series! money! time! date! char!] "Starting value."
	End [number! series! money! time! date! char!] "Ending value."
	/By Bump [number! money! time! char!] "Amount to skip each time."
	][
	Block
	][
	throw-on-error [
		all [
			none? Bump
			Bump: 1
			]
		Block: make block! 100
		for I Start End Bump [
			insert tail Block I
			]
		Block
		]
	]
