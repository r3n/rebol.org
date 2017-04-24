REBOL [
    Title: "Make Object"
    Date: 3-Jul-2002
    Name: 'Make-Object
    Version: 1.0.0
    File: %make-object.r
    Author: "Andrew Martin"
    Purpose: {
^-^-Scans a Spec looking for set-word! inside them,
^-^-then stuffs them in the object spec with none.
^-^-}
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

make object! [
	SetWords?: function [Spec [block!]][Words][
		Words: make block! 10
		foreach Value Spec [
			any [
				if all [
					set-word? :Value
					not found? find Words :Value
					][
					append Words :Value
					]
				if block? :Value [
					append Words SetWords? Value
					Words: unique Words
					]
				]
			]
		Words
		]
	set 'Make-Object function [
		{Scans a Spec looking for set-word! inside them,
			then stuffs them in the object spec with none.}
		Spec [block!]
		][
		SetWords
		][
		SetWords: SetWords? Spec
		if not empty? SetWords [
			append SetWords none
			insert Spec SetWords
			]
		make object! Spec
		]
	]
