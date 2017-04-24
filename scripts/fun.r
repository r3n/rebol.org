REBOL [
    Title: "Fun"
    Date: 3-Jan-2003
    Name: 'Fun
    Version: 2.0.0
    File: %fun.r
    Author: "Andrew Martin"
    Purpose: "Automatic local word generation for a function."
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    Acknowledgements: {
^-^-Tim Johnson -- who pushed me to do this.
^-^-}
    library: [
        level: 'advanced 
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
	Find-Locals: function [Locals [block!] Body [block!] Deep [none! logic!]] [Value] [
		parse Body [
			any [
				set Value set-word! (
					if not found? find Locals Value: to word! :Value [
						insert tail Locals Value
						]
					)
				| set Value block! (
					if Deep [
						Find-Locals Locals Value Deep
						]
					)
				| skip
				]
			]
		Locals
		]
	set 'Fun function [
		"Automatic local word generation for a function."
		Spec [block!]	{Optional help info followed by arg words, optional type and string.}
		Body [block!]	"The body block of the function."
		/Deep	"Inspect block! values recursively for more local words."
		][
		Locals LocalRefinement
		][
		Locals: copy []
		if found? LocalRefinement: find Spec /local [
			insert Locals next LocalRefinement
			Spec: copy/part Spec LocalRefinement
			]
		Find-Locals Locals Body Deep
		Locals: exclude Locals Spec
		function Spec Locals Body
		]
	set 'Sub :Fun
	]
