REBOL [
    Title: "Transpose"
    Date: 3-Jul-2002
    Name: 'Transpose
    Version: 1.0.0
    File: %transpose.r
    Author: "Andrew Martin"
    Purpose: "Transposes a Matrix's rows and columns."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    Acknowledgements: [
        "Joel Neely" 
        "Gerald Goertzel" 
        "Larry"
    ]
    Example: [
        transpose [[1 2 3 4 5] ["a" "b" "c" "d" "e"]] 
        transpose [[1 2 3] [14 15 16] [27 28 29]]
    ]
    library: [
        level: 'intermediate 
        platform: 'all 
        type: 'tool 
        domain: 'math 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

Transpose: function [
	"Transposes a Matrix's rows and columns."
	[catch]
	Matrix [block!]	"The Matrix."
	][
	Rows Columns Transposed
	][
	throw-on-error [
		Rows: length? Matrix
		Columns: length? Matrix/1
		Transposed: array reduce [Columns Rows]
		repeat Row Rows [
			repeat Column Columns [
				poke pick Transposed Column Row pick pick Matrix Row Column
				]
			]
		Transposed
		]
	]
