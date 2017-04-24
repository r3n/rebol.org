REBOL [
    Title: "Leapyear"
    Date: 3-Jul-2002
    Name: 'Leapyear
    Version: 1.0.0
    File: %leapyear.r
    Author: "Andrew Martin"
    Purpose: "Returns true for a leap year."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'beginner 
        platform: none 
        type: 'tool 
        domain: 'math 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Leapyear?: function [
	"Returns true for a leap year."
	Date [date!]	"The date to check."
	] [Year] [
	Year: Date/year
	any [
		all [
			0 = remainder Year 4
			0 <> remainder Year 100
			]
		0 = remainder Year 400
		]
	]
