REBOL [
    Title: "Rebol Name Value"
    Date: 5-Dec-2002
    Name: 'RNV
    Version: 1.2.0
    File: %rnv.r
    Author: "Andrew Martin"
    Purpose: "Common RNV manipulation functions."
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

RNV: make object! [
	Directory: %./
	Data: make block! 20
	Value: function [Name [word!]] [Value] [
		any [
			Value: select Data Name
			repend Data [
				Name Value: load/all rejoin [Directory join to-file Name %.rnv]
				]
			]
		Value
		]
	Name: function [NameValues [block!] Name [word!]] [Block Values] [
		any [
			select NameValues Name
			(
				Block: make block! 10
				foreach [Name Value] NameValues [
					if all [
						word? Name
						integer? Value
						] [
						Values: RNV/Value Name
						append Block select pick Values Value Name
						]
					]
				either empty? Block [none] [Block]
				)
			]
		]
	NameValue: func [Name [word!] Index [integer!]] [
		RNV/Name pick RNV/Value Name Index Name
		]
	Columns: func [Name [word!] Columns [block!]] [
		map/only RNV/Value Name func [NameValue [block!]] [
			map/full Columns function [Column [string! word!]] [Value] [
				Value: select NameValue Column
				if all [
					word? Column
					integer? Value
					Column != Name
					] [
					Value: RNV/NameValue Column Value
					]
				Value
				]
			]
		]
	Store: does [
		foreach [Name Value] Data [
			save/all join to-file Name %.rnv Value
			]
		]
	Index: function [RNV [block!] Name [word!]] [Table] [
		Table: make block! 2 * length? RNV
		repeat Item length? RNV [
			repend Table [RNV/:Item/:Name Item]
			]
		sort/skip Table 2
		]
	]
