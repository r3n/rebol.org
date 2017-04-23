REBOL [
	Title: {RFC Parser}
	Purpose: {Parse RFC Documents.}
	File: %rfc-parser.r
	Date: 4-Mar-2013
	Version: 1.0.0
	Author: "Brett Handley"
	Web: http://www.codeconscious.com
	Needs: [
		%parse-analysis.r ; rebol.org
		%parse-analysis-view.r ; rebol.org (If you want to use visualise-abnf)
		%delimit.r ; rebol.org
	]
	Library: [
		level: 'advanced
		platform: 'all
		type: [tool function]
		domain: [dialects parse text-processing]
		tested-under: [
			view 2.7.8.3.1 on [Win7] {Basic tests.} "Brett"
		]
		support: none
		license: 'apache-v2.0
		see-also: [%abnf-parser.r]  ; And see NEEDS block above.
	]
	License: {

		Copyright 2013 Brett Handley

		Licensed under the Apache License, Version 2.0 (the "License");
		you may not use this file except in compliance with the License.
		You may obtain a copy of the License at

			http://www.apache.org/licenses/LICENSE-2.0

		Unless required by applicable law or agreed to in writing, software
		distributed under the License is distributed on an "AS IS" BASIS,
		WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
		See the License for the specific language governing permissions and
		limitations under the License.
	}
	History: [
		1.0.0 [4-Mar-2013 "First published." "Brett Handley"]
	]
]

script-manager do-needs ; Does each file listed in NEEDS block.

; ---------------------------------------------------------------------------------------------------------------------
; RFC PARSER
;
;
; Purpose:
;
;	This script is used to parse IETF RFC text documents, in order to extract rules and examples, ie. to make life
;	easier when trying to implement an RFC in REBOL.
;
;	Note: Make sure you download the TXT version of the document you want to process. Eg.:
;
;		http://tools.ietf.org/rfc/rfc5234.txt
;
; Quick Start Guide:
;
;		See the Quick Start Guide in the comments of %abnf-parser.r (also on rebol.org).
;
; Functions:
;
;
;	rfc-without-page-breaks
;
;		Dealing with the page breaks is a pain when trying to extract the rules, this function removes them.
;
;
;	extract-rfc-code
;
;		Motivation: Extract ABNF rules from RFC documents.
;
;		Extracts code blocks from the text version of an IETF RFC document. I've only tried it
;		on a few I was interested in.
;
;		You give it a grammar rule and it tries to identify the indented code blocks that start with
;		code that matches the rule.
;
;		Be aware that sometimes documents may create example rules or duplicates which are not meant to
;		be part of the formal specification. This function cannot identify those and similar cases.
;
;		Sometimes code blocks match the rule pattern but are actually a different type. For example,
;		example data that conforms to being valid ABNF even though it is not ABNF.
;
;		May have been more resuable to break the rfc into blocks of text with an indent amount. Thereby
;		allowing the block to be tested as a whole.
;
;		It has worked for the few RFC's I have dealt with, YMMV.
;
;		Note: Check on the usage restrictions, if any, for the document you are working with.
;
;
;	strip-comments
;
;		Simple function to remove comment lines from a code string.
;
;
; ---------------------------------------------------------------------------------------------------------------------


rfc-without-page-breaks: func [
	{Return a copy of the RFC document without page breaks (footer/form feed/header).}
	string [string!] {Text of the document.}
	line-end [string! char!]
	/local digit not-line-end p.page p.footer-text p.prelines.start p.body result page-break rules
] [

	digit: charset {0123456789}
	not-line-end: complement charset reduce [line-end]

	rules: context [
		page-break: [
			thru {[Page } p.page: some digit {]} line-end
			#"^L" line-end
			thru line-end
			some line-end
			(
				p.footer-text: next find/reverse p.page line-end
				p.prelines.start: next next find/reverse p.footer-text not-line-end
			)
		]
		main: [
			some [
				p.body: page-break (
					; Append up to the break.
					append result copy/part p.body p.prelines.start
					; If > 3 prelines, make 1 blank, otherwise none.
					append result remove/part copy/part (copy/part p.prelines.start p.footer-text) 4 3 ; 
				) p.body:
			]
			(append result copy p.body) ; Copy last page.
		]
	]

	result: make string! length? string
	parse/all string rules/main
	result
]


extract-rfc-code: func [
	{Attempts to extract indented code blocks from IETF RFC document.}
	string [string!] {Text of the document.}
	'rulename [word!] {The rule that defines your code.}
	/visualise {View the document and highlight rules for debugging.}
	/local p0 p1 p2 result indent block extract-rules heading
] [

	; We have to deal with indentation. The rules are consistently indented but while
	; our parse rule does not deal with indentation we can use it to identify the first
	; rule in an indented block. Then we assume that everything in the indented block is a rule.


	extract-rules: context [

		ALPHA: charset [#"A" - #"Z" #"a" - #"z"]
		DIGIT: charset {0123456789}
		VCHAR: charset compose [(to char! first #{21}) - (to char! first #{7E})] ; visible (printing) characters
		WSP: charset { ^-}
		FORMFEED: #"^L"
		

		coderule: (reduce [:rulename])
		codelines: [thru newline any newline]
		codeblock: [
			p0: some [#" " | "^-"] p1: coderule ; We have identified the start of an indented code block
			(indent: copy/part p0 p1 block: copy {})
			:p0 some [indent p1: codelines p2: (append block copy/part p1 p2 block)]
			(append result heading append result append trim/tail block newline) ; Whole block.
		]

		section-heading: [
			p0: some [some [alpha | digit] #"."] some [WSP | VCHAR] p1: 2 newline (
				heading: rejoin [{^/; ---------- Section } copy/part p0 p1 { }]
				insert/dup tail heading #"-" max 0 subtract 100 length? heading
				append heading newline
			)
		]
		thru-other-lines: [thru newline any newline]
		main: [
			some [
				codeblock
				| section-heading
				| FORMFEED
				| thru-other-lines ; Advance for next test.
			]
		]
	]

	result: copy []
	either visualise [
		visualise-parse/ignore string extract-rules [parse/all string extract-rules/main] [DIGIT ALPHA WSP VCHAR FORMFEED]
	] [
		parse/all string extract-rules/main
	]
	result

]


strip-comments: func [
	{Used to remove comment lines from a code string (e.g. ABNF).}
	string
	/local p0 p1
] [
	parse/all string [
		any [
			p0: [any #" " #";" thru newline | 2 1000 newline] p1: (p0: remove/part p0 p1) :p0
			| thru newline
		]
	]
	string
]
