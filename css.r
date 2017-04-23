REBOL [
    Title: "CSS"
    Date: 7-Aug-2002
    Name: 'CSS
    Version: 1.0.0
    File: %css.r
    Author: "Andrew Martin"
    Purpose: {
^-^-CSS generates CSS markup from Rebol
^-^-words, paths, tags, blocks and other Rebol values.
^-^-}
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: none 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

CSS: function [
	"CSS generates CSS markup from Rebol words, paths, tags, blocks and other values."
	Dialect [block!]	"CSS dialect block."
	] [CSS Number Declaration Property Value Value2 Selector Selector2 Selector3] [
	CSS: make string! 2000
	Number: [integer! | decimal!]
	Declaration: [
		some [
			set Property set-word! (
				repend CSS [
					tab mold get 'Property
					; In the above line "get 'Property" can be replaced
					; with "Property" with new Rebol versions.
					]
				)
			some [
				[set Value Number %.] (
					repend CSS [
						#" " Value #"%"
						]
					)
				| set Value file! (
					repend CSS [
						" url(" replace/all copy Value #" " "%20" ")"
						]
					)
				| set Value url! (
					repend CSS [
						" url(" Value ")"
						]
					)
				| [set Value Number set Value2 word!] (
					repend CSS [
						#" " Value Value2
						]
					)
				| set Value [word! | issue!] (
					repend CSS [
						#" " mold Value
						]
					)
				] (
				append CSS ";^/"
				)
			]
		]
	parse Dialect [
		any [
			[
				set Selector word! set Selector2 word! set Selector3 word! (
					repend CSS [
						mold Selector #" " mold Selector2 #" " mold Selector3 " {^/"
						]
					)
				| set Selector word! (
					repend CSS [
						mold Selector " {^/"
						]
					)
				| set Selector block! (
					foreach Item Selector [
						repend CSS [Item ", "]
						]
					remove/part back back tail CSS 2
					append CSS " {^/"
					)
				| set Selector path! (
					foreach Item :Selector [
						repend CSS [Item #" "]
						]
					remove back tail CSS
					append CSS " {^/"
					)
				]
			into Declaration (
				append CSS rejoin [
					tab "}" newline
					]
				)
			]
		end
		]
	CSS
	]
