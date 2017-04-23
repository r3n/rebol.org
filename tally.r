REBOL [
    Title: "Tally"
    Date: 3-Jul-2002
    Name: 'Tally
    Version: 1.0.0
    File: %tally.r
    Author: "Andrew Martin"
    Purpose: {Tallies up the values in a series, producing a block of [Value Count] pairs.}
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'beginner 
        platform: 'all 
        type: 'tool 
        domain: [DB math] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Tally: function [
	"Tallies up the values in a series, producing a block of [Value Count] pairs."
	Values [series!]
	][
	Tallies Tally
	][
	Tallies: make block! length? Values
	foreach Value Values [
		either found? Tally: find/skip Tallies Value 2 [
			change next Tally 1 + second Tally
			] [
			repend Tallies [Value 1]
			sort/skip Tallies 2
			]
		]
	Tallies
	]
