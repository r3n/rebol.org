REBOL [
    Title: "Interweave"
    Date: 18-Jul-2002
    Name: 'Interweave
    Version: 1.0.1
    File: %Interweave.r
    Purpose: {Combines two series into one series by interleaving their values.}
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    Example: [
    Interweave [1 2 3] [#"A" #"B" #"C"] 
    Interweave "ABCDE" "12345"
]
    library: [
        level: 'beginner 
        platform: none 
        type: 'tool 
        domain: 'DB 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Interweave: function [
	{Combines two series into one series by interleaving their values.}
	Series1 [series!]
	Series2 [series!]
	] [Interweaved Length] [
	Interweaved: make type? Series1 Length: length? Series1
	repeat Index Length [
		repend Interweaved [
			Series1/:Index Series2/:Index
			]
		]
	Interweaved
	]
