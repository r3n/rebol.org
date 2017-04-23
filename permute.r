REBOL [
    Title: "Permute"
    Date: 3-Jul-2002
    Name: 'Permute
    Version: 1.0.0
    File: %Permute.r
    Author: "Andrew Martin"
    Purpose: "Permutes a matrix."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    Example: {
^-^-Permute [[-1 0 1] [-1 0 1]]
^-^-;== [[-1 -1] [-1 0] [-1 1] [0 -1] [0 0] [0 1] [1 -1] [1 0] [1 1]]
^-^-}
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

make object! [
	Permute2: function [Matrix [block!]][Permutations][
		Permutations: make block! (length? Matrix/1) * (length? Matrix/2)
		foreach M1 Matrix/1 [
			foreach M2 Matrix/2 [
				repend/only Permutations [M1 M2]
				]
			]
		Permutations
		]
	Permute3: function [Matrix [block!]][Permutations][
		Permutations: make block! (length? Matrix/1) * (length? Matrix/2) * (length? Matrix/3)
		foreach M1 Matrix/1 [
			foreach M2 Matrix/2 [
				foreach M3 Matrix/3 [
					repend/only Permutations [M1 M2 M3]
					]
				]
			]
		Permutations
		]
	Permute4: function [Matrix [block!]][Permutations][
		Permutations: make block! (length? Matrix/1) * (length? Matrix/2)
			* (length? Matrix/3) * (length? Matrix/4)
		foreach M1 Matrix/1 [
			foreach M2 Matrix/2 [
				foreach M3 Matrix/3 [
					foreach M4 Matrix/4 [
						repend/only Permutations [M1 M2 M3 M4]
						]
					]
				]
			]
		Permutations
		]
	Merge: function [Matrix [block!]][][
		map/only Matrix func [Item][join Item/1 Item/2]
		]
	set 'Permute func [[catch] Matrix [block!]][
		switch/default length? Matrix [
			2 [Permute2 Matrix]
			3 [Permute3 Matrix]
			4 [Permute4 Matrix]
			5 [Merge transpose reduce [Permute3 Matrix Permute2 at Matrix 4]]
			6 [Merge transpose reduce [Permute3 Matrix Permute3 at Matrix 4]]
			7 [Merge transpose reduce [Permute3 Matrix Permute4 at Matrix 4]]
			8 [Merge transpose reduce [Permute4 Matrix Permute4 at Matrix 5]]
			][
			throw make error! [script out-of-range Matrix]
			]
		]
	]
