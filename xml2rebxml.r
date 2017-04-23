REBOL [
	Title:		"XML to RebXML Converter"
	Date:		06-Nov-2005
	Version:	1.1.2
	File:		%xml2rebxml.r
	Author:		"John Niclasen"
	Rights:		{Copyright © John Niclasen, NicomSoft 2005}
	Purpose:	{Convert XML to RebXML block structure.}

	Comment:	{
		Build from xml2txt.r and XML 1.0 DTD from www.w3.org.
	}

	History: [
		1.1.2	[06-11-2005 JN {Fixed bug with multi comments.}]
		1.1.1	[24-02-2005 JN {Changed EmptyElemTag from # to a slash: /}]
		1.1.0	[23-02-2005 JN {Added support for namespace-tags.
								Changed EmptyElemTag from "" to a number sign: #}]
		1.0.1	[31-01-2005 JN {Added "load mold" before returning output.
								Added replacements for "&gt;", "&lt;" and "&amp;".}]
		1.0.0	[25-01-2005 JN {Created.}]
	]
	library: [
		level: 'intermediate
		platform: 'all
		type: 'tool
		domain: [markup parse xml]
		tested-under: none
		support: none
		license: 'BSD
		see-also: "rebxml2xml.r"
	]
]

context [

lit-slash: to-lit-word "/"

block-begin: to word! "["
block-end: to word! "]"
attrs:	make block! 20
output:	make block! 1000
input-str: none
att-data: data: temp: tag-name: att-name: enc-name: c: none

;-- Character Sets
joinset: func [cset chars] [insert copy cset chars]
diffset: func [cset chars] [remove/part copy cset chars]

space:	charset [#"^(09)" #"^(0A)" #"^(0D)" #" "]
char:	charset [#"^(09)" #"^(0A)" #"^(0D)" #" " - #"^(FF)"]
Letter: charset [
	#"A" - #"Z" #"a" - #"z"
	#"^(C0)" - #"^(D6)" #"^(D8)" - #"^(F6)" #"^(F8)" - #"^(FF)"
]
;Digit:	charset [#"0" - #"9"]
alpha-num:	joinset Letter "0123456789"		; need to allow: Digit
name-first:	joinset Letter "_:"

NameChar:	joinset alpha-num ".-_:"
data-chars:	diffset char "<"	; "&<"
Name:		[name-first any NameChar]
S:			[some space]

;-- XML Rules
document:		[prolog element to end]

AttValue:		["'" copy att-data to "'" skip | {"} copy att-data to {"} skip]

Comment:		["<!--" thru "-->"]

PI:				["<?" thru "?>"]

CDSect:			["<![CDATA[" copy data to "]]>" "]]>" (
		trim data
		if not empty? data [
			either string? data [
				insert tail output first parse/all data "^/"
			][
				insert tail output data
			]
		]
	)
]

prolog:			[opt S opt XMLDecl any [Misc | "<!" thru ">"]]
XMLDecl:		["<?xml" VersionInfo opt EncodingDecl thru "?>"]
VersionInfo:	[S "version" Eq ["'" VersionNum "'" | {"} VersionNum {"}]]
Eq:				[opt S #"=" opt S]
;VersionNum:		[copy temp some NameChar (print ["XML Version:" temp])]
VersionNum:		[copy temp some NameChar]
Misc:			[Comment | PI | S]

element:		[
	Comment
	| s-tag [
		"/>" (
			insert tail output to-url tag-name
			insert tail output attrs
			clear attrs
			insert tail output lit-slash
		)
		| #">" (
			insert tail output to-url tag-name
			insert tail output attrs
			clear attrs
			insert tail output block-begin
		)
		any content ETag (
			;if empty? data [
				insert tail output block-end
			;]
			;clear data
		)
	]
]

s-tag:			["<" copy tag-name Name any [S Attribute] opt S]
Attribute:		[copy att-name Name Eq AttValue (
		replace/all att-data "&gt;" #">"
		replace/all att-data "&lt;" #"<"
		replace/all att-data "&amp;" #"&"
		append attrs reduce [to-url att-name att-data]
	)
]

ETag:			["</" copy tag-name Name opt S ">"]

content:		[CDSect | element
	| copy data some data-chars (
		if not empty? data [
			replace/all data "&gt;" #">"
			replace/all data "&lt;" #"<"
			replace/all data "&amp;" #"&"
			either string? last output [
				append first back tail output data
			][
				insert tail output data
			]
		]
	)
]

Latin-first: charset [#"A" - #"Z" #"a" - #"z"]
Latin:		joinset Latin-first "0123456789._-"

EncodingDecl:	[S "encoding" Eq [{"} Encname {"} | "'" Encname "'"]]
Encname:		[copy enc-name [Latin-first any Latin]]

hichar:	charset [#"^(80)" - #"^(FF)"]
unicode:		[any [
	#"^(00)" copy c char (append input-str c)
	| #"^(C2)" copy c hichar (append input-str c)
	| #"^(C3)" copy c hichar (append input-str (to-char c) + #"^(40)")
	| copy c char (append input-str c)
]]

set 'xml2rebxml func [
	"Parses XML code and returns as block structure"
	code [string!] "XML code to parse"
][
	clear output
	enc-name: none

	parse/all/case code [prolog to end]

	either enc-name = "ISO-8859-1" [
		input-str: code
	][
		input-str: make string! 16384
		clear input-str
		parse/all/case code unicode
	]

	parse/all/case input-str document
	load mold output
]

]	; context
