REBOL [
    Title: "ML"
    Date: 3-Jan-2003
    Name: 'ML
    Version: 1.7.0
    File: %ml.r
    Author: "Andrew Martin"
    Needs: [%Build%20Tag.r %Push.r %Pop.r]
    Purpose: {
^-^-ML generates HTML, XHTML, XML, WML and SVG markup
^-^-from Rebol words, paths, tags and blocks.
^-^-}
    eMail: Al.Bri@xtra.co.nz
    Web: http://valley.150m.com
    library: [
        level: 'advanced 
        platform: none 
        type: none 
        domain: 'web 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

make object! [
	Stack: make block! 10
	push Stack ""
	set 'ML function [
		{ML generates HTML, XHTML, XML, WML and SVG markup
		from Rebol words, paths, tags and blocks.}
		Dialect [block!]
		] [String Values_Rule Values Value Tag NameSpace] [
		String: copy ""
		Values_Rule: [
			; Caution! The 'none word below is replaced in the 'parse rule below!
			none [
				set Value any-type! (
					Tag: next next Tag
					insert Tag Value
					Value: none
					)
				]
			; Caution! The 'opt word below is replaced in the 'parse rule below!
			opt [
				set Value [
					decimal! | file! | block! | string! | char!
					| money! | time! | issue! | tuple! | date!
					| email! | pair! | logic! | integer! | url!
					]
				]
			]
		Values: make block! 10
		parse Dialect [
			any [
				[
					set Tag tag! (
						Values_Rule/1: 0	; Replace 'none word in 'Values_Rule above.
						Values_Rule/3: either any [	; Replace 'opt word...
							#"/" = last Tag	; empty tag.
							#"?" = first Tag	; XML tag.
							#"!" = first Tag	; DOCTYPE tag.
							] [0] [1]
						)
					| set Tag [path! | word!] (
						Tag: to-block get 'Tag
						; Replace 'none word in 'Values_Rule above.
						Values_Rule/1: -1 + length? Tag
						Values_Rule/3: 'opt	; Replace 'opt word...
						)
					] (Value: none) Values_Rule (
					Tag: head Tag
					repend String either none? Value [
						if not tag? Tag [
							Tag: Build-Tag Tag
							]
						if all [
							#"/" <> last Tag
							#"?" <> first Tag
							#"!" <> first Tag
							] [
							append Tag " /"
							]
						[Tag newline]
						] [
						[
							either all [block? Value empty? String] [newline] [""]
							either tag? Tag [Tag] [
								Build-Tag head change Tag join first Stack first Tag
								]
							either block? Value [ML Value] [Value]
							to-tag join #"/" first either tag? Tag [to-block Tag] [Tag]
							]
						]
					Values_Rule/1: none
					)
				| set NameSpace set-word! set Value block! (
					push Stack probe mold :NameSpace
					insert tail String ML Value
					pop Stack
					)
				| none!	; Ignore 'none values.
				| set Value any-type! (append String Value)
				]
			end
			]
		String
		]
	]
