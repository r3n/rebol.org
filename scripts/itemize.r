REBOL [
    Title: "Itemize"
    Date: 16-Oct-2002
    Name: 'Itemize
    Version: 1.1.0
    File: %itemize.r
    Author: "Andrew Martin"
    Purpose: {Appends Value to Values, if Value not all ready in block.}
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
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

Itemize: func [
	"Appends Value to Values, if Value not all ready in block."
	Values [series!]
	Value
	] [
	if not found? find/only Values Value [
		insert/only tail Values Value
		]
	Values
	]
