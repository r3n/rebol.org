REBOL [
    Title: "Script"
    Date: 3-Jul-2002
    Name: 'Script
    Version: 1.0.0
    File: %script.r
    Author: "Andrew Martin"
    Purpose: "Returns the script source code for a word."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'intermediate 
        platform: none 
        type: [tool] 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Script: func [
	"Returns the script source code for a word."
	Word [word!]
	] [
	join {} [
		Word ": "
		either not value? Word [
			"undefined"
			] [
			either any [
				native? get Word
				op? get Word
				action? get Word
				] [
				join "native" mold third get Word
				] [
				either not error? try [get get Word] [
					join {'} get Word	; show a literal word.
					] [
					mold get Word
					]
				]
			]
		]
	]
