REBOL [
    Title: "R2HTML"
    Date: 21-Dec-2002
    Name: 'R2HTML
    Version: 1.3.1
    File: %r2html.r
    Author: "Andrew Martin"
    Rights: "Copyright (c) 2002, Andrew Martin."
    Needs: [%ML.r %Map.r]
    Usage: [
    write %file.html R2HTML read %file.r
]
    Purpose: "Converts .r rebol script file into a .html file."
    Comment: {
^-^-Converts .r rebol script file into a .html file.
^-^-The resulting .html file displays the rebol script
^-^-and allows execution of the rebol script.
^-^-}
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: none 
        platform: none 
        type: 'tool 
        domain: 'web 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

make object! [
	; A temporary replacement for "amp;" to avoid infinite recursion.
	; Don't simplify! Why?
	; The constant will be replaced when this script is converted to HTML!
	; "amp;" with "R2HTML" between each letter.
	Amp_Entity_Replacement: join "a" "R2HTMLmR2HTMLpR2HTML;"
	Named_Entities: [
		"quot" "amp" "lt" "gt" "nbsp" "iexcl" "cent" "pound" "curren"
		"yen" "brvbar" "sect" "uml" "copy" "ordf" "laquo" "not" "shy"
		"reg" "macr" "deg" "plusmn" "sup2" "sup3" "acute" "micro"
		"para" "middot" "cedil" "sup1" "ordm" "raquo" "frac14"
		"frac12" "frac34" "iquest" "times" "Oslash"
		]
	Replace_Named_Entities: func [Script [string!]] [
		Map Named_Entities func [Entity [string!]] [
			replace/all Script join #"&" Entity join #"&" [Amp_Entity_Replacement Entity]
			]
		Script
		]
	Replace_Entities: func [Script [string!]] [
		replace/all Script "&#" join "&" [Amp_Entity_Replacement "#"]
		Replace_Named_Entities Script
		replace/all Script "<" "&lt;"
		replace/all Script ">" "&gt;"
		replace/all Script Amp_Entity_Replacement "amp;"
		Script
		]
	set 'R2HTML function [Script [string!] "Rebol script to convert to HTML."] [Header] [
		Header: first load/header Script
		ML compose/deep [
			html [
				title (Header/Title)
				]
			body [
				h1 (Header/Title)
				table [(
					map next first Header function [Word] [Value] [
						if Value: get in Header Word [
							ML compose/deep [
								tr [
									td [(to-string mold to-set-word Word)]
									td [(
										switch/default type?/word Value [
											url! [
												compose [
													a/href (Value) (to-string Value)
													]
												]
											email! [
												compose [
													a/href (join "mailto:" Value)
													(to-string Value Header/Title)
													]
												]
											string! [
												trim Value
												]
											block! [
												compose [
													pre (detab mold Value)
													]
												]
											] [
											mold Value
											]
										)]
									]
								]
							]
						]
					)]
				pre (detab Replace_Entities Script)
				]
			]
		]
	]
