REBOL [
    Title: "Ice"
    Date: 11-Dec-2002
    Name: 'Ice
    Version: 1.0.0
    File: %ice.r
    Author: "Andrew Martin"
    Purpose: {Freezes and melts a Rebol object! "sea".}
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    Acknowledgements: "Romano Paolo Tenca"
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: [DB file-handling] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

make object! [
	Magic: '.
	Find-Same: func [Series [series!] Value [any-type!]] [
		while [
			all [
				found? Series: find/only/case Series :Value
				not same? first Series :Value
				]
			][
			Series: next Series
			]
		Series
		]
	Freeze-Value: function [Sea [block!] Fish] [Path Value Index] [
		if all [
			not lit-path? :Fish
			not path? :Fish
			any [
				function? :Fish
				object? :Fish
				series? :Fish
				]
			] [
			Path: make lit-path! reduce [Magic]
			Value: either series? :Fish [head :Fish] [:Fish]
			either found? Index: Find-Same Sea :Value [
				Index: index? Index
				] [
				append/only Sea :Value
				Index: length? Sea
				]
			append :Path Index
			if all [
				series? :Fish
				1 < Index: index? Fish
				] [
				append/only :Path Index
				]
			Fish: :Path
			]
		:Fish
		]
	set 'Freeze function ["Freezes Object Sea" Sea [block!]] [Block Object] [
		foreach Fish Sea [
			switch type?/word :Fish [
				block! [
					Block: Fish
					forall Block [
						Block/1: Freeze-Value Sea pick Block 1
						]
					]
				object! [
					Object: Fish
					foreach Word next first Object [
						set in Object Word Freeze-Value Sea get in Object Word
						]
					]
				]
			]
		Sea	; At this point, the 'Sea has become ice. :)
		]
	Melt-Value: function [Ice [block!] Path] [Value] [
		Value: :Path
		if all [
			path? :Path
			Magic = first :Path
			2 <= length? :Path
			integer? second :Path
			] [
			Value: pick Ice second :Path
			if all [
				3 = length? :Path
				integer? third :Path
				] [
				Value: at Value third :Path
				]
			]
		Value
		]
	set 'Melt function ["Melts Object Ice" Ice [block!]] [Rule Value Object] [
		parse Ice Rule: [
			any [
				[
					set Value path! (
						Value/1: Melt-Value Ice Value/1
						)
					]
				| [
					set Object object! (
						foreach Word next first Object [
							set in Object Word Melt-Value Ice get in Object Word
							]
						)
					]
				| into Rule
				| any-type!
				]
			end
			]
		Ice	; At this point, the 'Ice has become sea. :)
		]
	]
