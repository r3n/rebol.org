REBOL [
    Title: "Table Columns"
    Date: 3-Jan-2003
    Name: 'Table-Columns
    Version: 1.0.0
    File: %table-columns.r
    Author: "Andrew Martin"
    Needs: [%Map.r %ML.r %Transpose.r]
    Purpose: {
^-^-Table-Columns takes the name of 1 or columns in a block,
^-^-and generates ML dialect for the table contents.
^-^-}
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: 'web 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Table-Columns: func [
	{Table-Columns takes the name of 1 or columns in a block,
	and generates ML dialect for the table contents.}
	Columns [block!]	"Block of words that refer to columns."
	] [
	compose/deep [
		thead [
			tr [(
				map Columns func [Column [word!]] [
					compose [
						th (form Column)
						]
					]
				)]
			]
		tbody [(
			map transpose reduce Columns func [Row [block!]] [
				compose/deep [
					tr [(
						map Row func [Item] [
							compose either any [
								number? Item
								money? Item
								] [
								[td/align "right" (form Item)]
								] [
								[td (form Item)]
								]
							]
						)]
					]
				]
			)]
		]
	]
