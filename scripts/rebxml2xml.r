REBOL [
	Title:		"RebXML to XML Converter"
	Date:		02-Mar-2009
	Version:	1.3.1
	File:		%rebxml2xml.r
	Author:		"John Niclasen"
	Rights:		{Copyright © John Niclasen, NicomSoft 2005}
	Purpose:	{Converts a RebXML block structure to XML.}
	History: [
		1.3.1	[02-Mar-2009 "JN"  {Fixed potential bug in EmptyElemTag.}]
		1.3.0	[08-Nov-2005 "JN"  {Fixed bug with value in Attribute.
									Added Comment.}]
		1.2.0	[26-Feb-2005 "JN"  {Added support for utf-8.}]
		1.1.1	[24-Feb-2005 "JN"  {Changed EmptyElemTag from # to a slash: /}]
		1.1.0	[23-Feb-2005 "JN"  {Added improved build-tag.
									Added support for namespace-tags.
									Changed EmptyElemTag from "" to a number sign: #}]
		1.0.1	[31-Jan-2005 "JN" {Added replacements for #"&", #"<" and #">".}]
		1.0.0	[25-Jan-2005 "JN" {Created.}]
	]
	library: [
		level: 'intermediate
		platform: 'all
		type: 'tool
		domain: [markup parse xml]
		tested-under: none
		support: none
		license: 'BSD
		see-also: "xml2rebxml.r"
	]
]

; An improved build-tag is here, because the original build-tag within REBOL can't cope with some types of tags.
build-tag: func [
    "Generates a tag from a composed block." 
    values [block!] "Block of parens to evaluate and other data." 
    /local tag value-rule xml? name attribute value
][
    tag: make string! 7 * length? values 
    value-rule: [
        set value issue! (value: mold value) 
        | set value file! (value: replace/all copy value #" " " ") 
        | set value any-type!
    ] 
    xml?: false 
    parse compose values [
        [
            set name ['?xml (xml?: true) | word! | url!] (append tag name) 
            any [
                set attribute [word! | url!] value-rule (
                    repend tag [#" " attribute {="} value {"}]
                ) 
                | value-rule (repend tag [#" " value])
            ] 
            end (if xml? [append tag #"?"])
        ] 
        | 
        [set name refinement! to end (tag: mold name)]
    ] 
    to tag! tag
]

context [

lit-slash: to-lit-word "/"
mark: none
convert2utf-8: off

tag: []
stack: []
name:
att:
value: none
output: make string! 16384

iso2utf-8: func [
	data	[string!]
	/local c2chars c3chars iso8859 mark
][
	c2chars: charset [#"^(A0)" - #"^(BF)"]
	c3chars: charset [#"^(C0)" - #"^(FF)"]
	iso8859: [any [
		mark: c2chars (mark: insert mark #"^(C2)") :mark skip |
		mark: c3chars (
			change mark to-char mark/1 - #"^(40)"
			mark: insert mark #"^(C3)"
		) :mark skip |
		skip
	]]

	parse/all data iso8859
	data
]
 
document: [prolog element]

prolog: [
	(either convert2utf-8 [
		insert output {<?xml version="1.0" encoding="utf-8"?>^/}
	][
		insert output {<?xml version="1.0" encoding="ISO-8859-1"?>^/}
	])
	;any Comment
	any CharData
]

element: [
	EmptyElemTag
	| STag [CharData | into content] ETag
]

STag: [
	set name [word! | url!] (clear tag insert tag name) any Attribute (
		insert tail output build-tag tag
		insert tail stack name
	)
]

Attribute: [
	mark: lit-slash :mark break
	| set att [word! | url!] set value string! (
		value: copy value
		replace/all value #"&" "&amp;"
		replace/all value #"<" "&lt;"
		replace/all value #">" "&gt;"
		replace/all value #"'" "&apos;"
		replace/all value #"^"" "&quot;"
		insert tail tag reduce [att value]
	)
]

ETag: [
	(insert tail output to tag! rejoin [#"/" last stack]
	remove back tail stack)
]

EmptyElemTag: [
	set name [word! | url!] (clear tag insert tag name)
			[lit-slash | any Attribute lit-slash] (
		insert tail tag #"/"
		insert tail output build-tag tag
	)
]

content: [
	;opt CharData any [Comment | element opt CharData]
	any [CharData | element]
]

CharData: [
	set value string! (
		either (copy/part value 4) = "<!--" [	; comment
			insert tail output value
		][
		replace/all value #"&" "&amp;"
		replace/all value #"<" "&lt;"
		replace/all value #">" "&gt;"
		replace/all value #"'" "&apos;"
		replace/all value #"^"" "&quot;"
		insert tail output value
		]
	)
]

;Comment: [set value string! (insert tail output value)]

set 'rebxml2xml func [
	data
	/utf-8
][
	either utf-8 [
		data: load iso2utf-8 mold data
		convert2utf-8: on
	][
		convert2utf-8: off
	]

	clear output
	clear stack
	parse data document
	output
]

]	; context
