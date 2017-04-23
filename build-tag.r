REBOL [
    Title: "Build-Tag"
    Date: 14-Nov-2002
    Name: 'Build-Tag
    Version: 1.2.0
    File: %build-tag.r
    Author: "Andrew Martin"
    Purpose: {
^-^-Build-Tag is a replacement Build-Tag that handles XML attributes.
^-^-An earlier version of Build-tag is incorporated into latest Rebol/Core. :)
^-^-}
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

Build-Tag: function [
	"Generates a tag from a composed block."
	Values [block!] "Block of parens to evaluate and other data."
	] [
	Tag Value_Rule XML? Name Attribute Value
	] [
	Tag: make string! 7 * length? Values
	Value_Rule: [
		set Value issue! (Value: mold Value)
		| set value file! (Value: replace/all copy Value #" " "%20")
		| set Value any-type!
		]
	XML?: false
	parse compose Values [
		[
			set Name ['?xml (XML?: true) | word! | url! | string!] (append Tag Name)
			any [
				set Attribute [word! | url! | string!] Value_Rule (
					repend Tag [#" " Attribute {="} Value {"}]
					)
				| Value_Rule (repend Tag [#" " Value])
				]
			end (if XML? [append Tag #"?"])
			]
		| [set Name refinement! to end (Tag: mold Name)]
		]
	to tag! Tag
	]
