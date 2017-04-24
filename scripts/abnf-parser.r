REBOL [
	Title: "ABNF Parser"
	Date: 11-Mar-2013
	File: %abnf-parser.r
	Purpose: "Parse ABNF rules as found in IETF RFC documents."
	Version: 1.0.1
	Author: "Brett Handley"
	Web: http://www.codeconscious.com
	Needs: [
		%parse-analysis.r ; rebol.org
		%parse-analysis-view.r ; rebol.org (If you want to use visualise-abnf)
		%load-parse-tree.r ; rebol.org
		%rfc-parser.r ; rebol.org
		%delimit.r ; rebol.org
		%rewrite.r ; http://www.colellachiara.com/soft/
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
		see-also: [%parserule-parser.r]  ; Also see NEEDS block above.
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
		1.0.1 [11-Mar-2013 "Fix bug where build-abnf-ast was not producing correct structure for ast.num-range, ast.num-string and ast.num-char nodes." "Brett Handley"]
		1.0.0 [4-Mar-2013 "First published." "Brett Handley"]
	]
]

script-manager do-needs ; Does each file listed in NEEDS block.

; ---------------------------------------------------------------------------------------------------------------------
;
; ABNF PARSER
;
;
; Purpose:
;
;	This script is used to generate REBOL Parse rules from ABNF rules described in an IETF RFC document.
;
;
; See:
;
;	http://tools.ietf.org/html/rfc5234
;	- Text version: http://tools.ietf.org/rfc/rfc5234.txt
;
;
; Quick Start Guide:
;
; 	Example: Generating parse rules from the ABNF RFC specification document:
;
;		rfc: read %rfc5234-ABNF.txt
;		rfc: copy find rfc {^/4.  ABNF Definition of ABNF^/}
;		rfc: rfc-without-page-breaks rfc newline
;
;		abnf: rejoin delimit extract-abnf/visualise rfc newline
;		block: build-abnf-ast abnf
;		abnf-ast-to-rebol block
;		write %abnf.rules.txt mold block;
;
;
; Notes:
;
;	The translation is naive. You may have to change the order of rule alternatives and make other
;	modifications to get a working set of rules - see "Comments".
;
;	The rules found in RFC documents are meant for formally specifying the grammar and are expected
;	to be interpreted by the developer so they are unlikely to be designed for performance.
;
;	Also, note that some RFC grammar rules may have two levels of rule sets - a simple one for tokenisation
;	and another one which, while accurate, is meant to convey the semantics of the grammar. In this case using
;	the naive translation of all rules (once you get it working) may not be the best approach for parsing
;	the particular grammar.
;
;	You might want to run the generated parse rules through analyse-rules (parserule-parser.r) to see if it
;	can provides some heads up of any problems.
;
;	For the ABNF RFC See: http://tools.ietf.org/html/rfc5234
;
;
; Acknowledgement:
;
;	The script makes heavy use of the small but very powerful REWRITE function by Gabriele Santilli. I thank him
;	for providing it. 
;
;		See rewrite.r and rewrite.html after clicking on Misc at:
;
;			http://www.colellachiara.com/soft/
;
; Functions:
;
;
;	extract-abnf
;
;		Extract ABNF from an IETF RFC text document.
;		See documentation on extract-rfc-code for comments.
;
;
;	valid-abnf?
;
;		Returns TRUE if it can parse the ABNF text data using the rules.
;		All the following parsing funtions leverage this function.
;
;
;	tokenise-abnf
;
;		Was used during debugging. Returns tokens steps from a parse of ABNF using the rules.
;
;
;	visualise-abnf
;
;		Displays the ABNF and allows interactive highlighting and navigation through the parse steps/tokens.
;		Used during debugging.
;
;
;	build-abnf-tree
;
;		This function returns a token tree from ABNF.
;		Used by build-abnf-ast.
;
;
;	build-abnf-ast
;
;		Returns an abstract syntax tree (AST) of the ABNF data.
;
;
;	abnf-ast-to-rebol
;
;		Taking an AST from build-abnf-ast, it returns a REBOL block that can be composed into Parse rules.
;
;		Case sensitivity is handled using embedded paren! which contain words and strings. The words should be set to 
;		functions which will generate the appropriate parse rule for situation. Case sensitive strings are marked with
;		MATCHCASE and case insensitive strings are marked with NOCASE. Just use Compose or Context on the block to get
;		the final parse rules.
;
;		Whether you are doing a case senstive parse or not you can set MATCHCASE as follows:
;
;			matchcase: func[string][string]
;
;		If no MATCHCASE appears in the output then you can just use parse/all without the /case refinement and set the
;		NOCASE word as follows:
;
;			nocase: func[string][string].
;
;		If MATCHCASE appears in the output then you need to parse with Parse/all/case and set the NOCASE function to a
;		a function which will match the string ignoring case even in parse/case mode. Two functions are provided which
;		have different strategies to accomplish this e.g
;
;			nocase: :case-insensitive-guardrule
;
;		or
;
;			nocase: :case-insensitive-chars
;
;
;	case-insensitive-guardrule
;
;		This generates a parse rule which matches the string, ignoring case (even during parse/case mode), using a strategy
;		of comparing uppercase and lowercase versions of the string and a guard rule (requiring a new variable). Suitable
;		when the string is long.
;
;		If you use this function, make sure you allocate the variable (GUARD) it uses for the guard.
;
;
;	case-insensitive-chars
;
;		This generates a parse rule which matches the string, ignoring case (even during parse/case mode), using a strategy
;		of testing each character of the string - both the uppercase and lowercase forms of the character. Suitable when the
;		the string is short. Does not require another variable.
;
;
; Comments:
;
;		The original specification requires a CRLF line ending - this script uses a LF line ending consistent with REBOL
;		default. Therefore just read the IETF RFC text document using READ. If you want to change it see abnf.core.rules/CRLF.
;
;		Char-Val strings are case-insensitive, other character sequences and characters are case sensitive. 
;
;		Prose-val is an element that cannot be described by ABNF and so instead is described by text as an instruction to the reader.
;		These are translated to a REBOL tag! type.
;
;		Order of REBOL parse rules may need to be different to specification.
;			Example abnf.repeat:
;				If the original order was maintain in the rebol parse rule then the OPT would be satisfied by
;				the match on some digit. A fix is reverse the order of the alternatives in the repeat rule.
;
;		Some rules will specify a string sequence by repeating a charset, see Char-Val.
;		- By accummulating charsets these strings will be more meaningful and compact in the results.
;
;		To develop this script I translated the ABNF rules in a text editor manually and tweeked them to be useable
;		as REBOL parse rules. They could be optimised, but doing so might compromise any future work on handling conversion
;		of ABNF rule comments.
;
;		abnf-ast-to-rebol produces REBOL code in block format
;		- to include comments in the code would mean producing string output instead.
;
;
; Unimplemented at this time:
;
;		Handling of =/ fragments (incremental alternatives).
;		See the RFC, Section 3.3.  It should be handled while in AST form.
;

; ---------------------------------------------------------------------------------------------
; RULES
; ---------------------------------------------------------------------------------------------

use [p][

	abnf.core.rules: context compose [
		ALPHA: charset [#"A" - #"Z" #"a" - #"z"]
		BIT: charset [#"0" #"1"]
		CHAR: charset compose [(to char! first #{01}) - (to char! first #{7F})] ; %x01-7F - any 7-bit US-ASCII character, excluding NUL
		CR: (CR) ; carriage return
		;;; CRLF: (CRLF) ; Internet standard newline
		CRLF: (newline) ; Makes life easier.
		CTL: charset compose [(to char! first #{1F}) - (to char! first #{7F})]
		DIGIT: charset {0123456789}
		DQUOTE: {"}
		HEXDIG: union digit charset {abcdefABCDEF}
		HTAB: (TAB) ; horizontal tab
		LF: (LF) ; linefeed
		LWSP: [WSP | any [CRLF WSP]]
		OCTET: complement charset {} ; 8 bits of data
		SP: { }
		VCHAR.ch: charset compose [(to char! first #{21}) - (to char! first #{7E})] ; visible (printing) characters
		VCHAR: [some VCHAR.ch]
		WSP.ch: charset { ^-}
		WSP: [some WSP.ch]
	]

	; ---------------------------------------------------------------------------------------------

	abnf.grammar.rules: context bind [
		abnf.rulelist: [some [abnf.rule | any abnf.c-wsp abnf.c-nl]]
		abnf.rule: [abnf.rulename abnf.defined-as abnf.elements abnf.c-nl]
		abnf.rulename: [ALPHA any [ALPHA | DIGIT | "-"]]
		abnf.defined-as.op: ["=" | "=/"] ; Added this rule to distinguish the defined-as operation.
		abnf.defined-as: [any abnf.c-wsp abnf.defined-as.op any abnf.c-wsp]
		abnf.elements: [abnf.alternation any abnf.c-wsp]
		abnf.c-wsp: [WSP | abnf.c-nl WSP]
		abnf.c-nl: [abnf.comment | CRLF]
		abnf.comment: [";" any [WSP | VCHAR] CRLF]
		abnf.alternation: [abnf.concatenation any [any abnf.c-wsp "/" any abnf.c-wsp abnf.concatenation]]
		abnf.concatenation: [abnf.repetition any [some abnf.c-wsp abnf.repetition]]
		abnf.repetition: [opt [abnf.repeat] abnf.element]
		abnf.repeat: [any DIGIT "*" any DIGIT | some DIGIT]
		abnf.element: [abnf.rulename | abnf.group | abnf.option | abnf.char-val | abnf.num-val | abnf.prose-val]
		abnf.group: ["(" any abnf.c-wsp abnf.alternation any abnf.c-wsp ")"]
		abnf.option: ["[" any abnf.c-wsp abnf.alternation any abnf.c-wsp "]"]
		abnf.char-val: [DQUOTE opt abnf.chars.x20-21_x23-7E DQUOTE]
		abnf.base: ["b" | "d" | "x"]
		abnf.num-range: [
			p: [#"b" | #"B"] :p abnf.base abnf.bin-val.num "-" abnf.bin-val.num
			| [#"d" | #"D"] :p abnf.base abnf.dec-val.num "-" abnf.dec-val.num
			| [#"x" | #"X"] :p abnf.base abnf.hex-val.num "-" abnf.hex-val.num
		]
		abnf.num-string: [
			p: [#"b" | #"b"] :p abnf.base abnf.bin-val.num some ["." abnf.bin-val.num]
			| [#"d" | #"D"] :p abnf.base abnf.dec-val.num some ["." abnf.dec-val.num]
			| [#"x" | #"X"] :p abnf.base abnf.hex-val.num some ["." abnf.hex-val.num]
		]
		abnf.num-char: [
			p: [#"b" | #"B"] :p abnf.base abnf.bin-val.num
			| [#"d" | #"D"] :p abnf.base abnf.dec-val.num
			| [#"x" | #"X"] :p abnf.base abnf.hex-val.num
		]
		abnf.bin-val.num: [some BIT]
		abnf.dec-val.num: [some DIGIT]
		abnf.hex-val.num: [some HEXDIG]
		abnf.num-val: ["%" [abnf.num-range | abnf.num-string | abnf.num-char]]
		abnf.prose-val: ["<" opt abnf.chars.x20-3d_x3f-7e ">"]
		abnf.chars.x20-21_x23-7E: [some abnf.chars.x20-21_x23-7E.ch]
		abnf.chars.x20-21_x23-7E.ch: charset compose [
			(to char! first #{20}) - (to char! first #{21})
			(to char! first #{23}) - (to char! first #{7E})
		]
		abnf.chars.x20-3d_x3f-7e: [some abnf.chars.x20-3d_x3f-7e.ch]
		abnf.chars.x20-3d_x3f-7e.ch: charset compose [
			(to char! first #{20}) - (to char! first #{3D})
			(to char! first #{3F}) - (to char! first #{7E})
		]
	] abnf.core.rules

]

; ---------------------------------------------------------------------------------------------
; FUNCTIONS
; ---------------------------------------------------------------------------------------------


extract-abnf: func [
	{Extract ABNF from IETF RFC document.}
	string [string!] {Text of the document.}
	/visualise {View the document and highlight rules for debugging.}
] [
	rule: in abnf.grammar.rules 'abnf.rule
	either visualise [
		extract-rfc-code/visualise string :rule
	][
		extract-rfc-code string :rule
	]
]


valid-abnf?: func [
	{Test if string is valid ABNF text. Note: Rules must start at the beginning of each line.}
	string [string!] {ABNF text.}
] [
	parse/all/case string abnf.grammar.rules/abnf.rulelist
]


tokenise-abnf: func [
	{Used for debuggin the ABNF parser.}
	string [string!] {ABNF text.}
] [
	tokenise-parse abnf.grammar.rules [valid-abnf? string]
]


visualise-abnf: func [
	{Visualise the ABNF rules.}
	string [string!] {ABNF text.}
] [
	visualise-parse string abnf.grammar.rules [valid-abnf? string]
]


build-abnf-tree: func [
	{Return a token tree of the ABNF.}
	string [string!] {ABNF text.}
	/ignore {Exclude specific terms from result.} exclude-terms [block!] {Block of words representing rules.}
] [
	if not ignore [exclude-terms: copy []]
	load-parse-tree/ignore abnf.grammar.rules [valid-abnf? string] exclude-terms
]


build-abnf-ast: func [
	{Build an Abstract Syntax Tree (type parameters content)}
	string [string!] {ABNF text.}
	/local x value param repeat ast
] [

	repeat: func [
		value
		/local pos min max
	] [
		if none? value [return 'none]
		parse value bind [
			opt [copy min some DIGIT (min: to integer! min)] "*" opt [copy max some DIGIT (max: to integer! max)]
			| copy min some DIGIT (max: min: to integer! min)
		] abnf.core.rules
		min: any [min 'none] max: any [max 'none] ; We want the word none not its value.
		compose/deep [[min (:min) max (:max)]]
	]

	; Get the token tree. Structure is [token content]

	ast: build-abnf-tree/ignore string [
		; Don't need to separately process these.
		abnf.rulelist
		abnf.elements abnf.element
		abnf.num-val
		abnf.c-wsp abnf.c-nl
		abnf.comment
		abnf.chars.x20-21_x23-7E.ch abnf.chars.x20-3d_x3f-7e.ch
	]

	; Now make abstract syntax tree using structure [node param content].
	;
	; With these rewrite rules. Ensure that you know exactly what is matched and what is replaced.
	; This is particularly important when the match rule has alternatives.
	; The replacement blocks are indented for output readability.

	rewrite ast
	[
		[x: 'abnf.rule skip] [
			ast.rule [name (x/2/2) op (x/2/4/abnf.defined-as.op)] [(remove/part x/2 4 x/2)]
		]
		['abnf.rulename] [
			ast.rulename none
		]
		['abnf.alternation] [
			ast.alternation none
		]
		['abnf.concatenation] [
			ast.concatenation none
		]
		[x: 'abnf.repetition [into ['abnf.repeat set param string! to end] | block! (param: none)]] [
			ast.repetition (repeat param) [((if param [remove/part x/2 2]) x/2)]
		]
		['abnf.group] [
			ast.group none ; Maintain group to honour author's readability efforts.
		]
		['abnf.option] [
			ast.optional none
		]
		[x: 'abnf.char-val into ['abnf.chars.x20-21_x23-7E set value string! | end (value: copy {})]] [
			ast.char-val none (value)
		]
		[x: 'abnf.prose-val into ['abnf.chars.x20-3d_x3f-7e set value string! | end (value: copy {})]] [
			ast.prose-val none (value)
		]
		['abnf.bin-val.num | 'abnf.dec-val.num | 'abnf.hex-val.num] []
		[x: 'abnf.num-range block!] [
			ast.num-range [base (x/2/2) spec [(remove/part x/2 2)]] none
		]
		[x: 'abnf.num-string block!] [
			ast.num-string [base (x/2/2) spec [(remove/part x/2 2)]] none
		]
		[x: 'abnf.num-char block!] [
			ast.num-char [base (x/2/2) spec [(remove/part x/2 2)]] none
		]
	]

	ast
]


; Should really convert to a REBOL parse AST, then to the rules, rather than directly to the rules.

abnf-ast-to-rebol: func [
	{Convert an ABNF abstract syntax tree to a REBOL parse rules structure.}
	ast [block!]
	/prefix {Adds prefix to rule names.} prefix-string [string!] {Prefix to add to rule names.}
	/local param block map-char name content x p rebol.fn case-insenstive-replace
	embedded-charsets
] [

	prefix-string: any [prefix-string {}]

	rebol.fn: context [
		alternatives: func [block] [remove collect [forskip block 3 [keep head insert copy/part block 3 '|]]]
		binary: func [spec] [(insert/dup spec: copy spec #"0" 8 - length? spec) to char! first debase/base spec 2]
		decimal: func [spec] [to char! to integer! spec]
		hexadecimal: func [spec] [to char! first debase/base spec 16]
		map-char: func [param /local convert] [
			convert: switch/default param/base [
				"b" [get in rebol.fn 'binary]
				"d" [get in rebol.fn 'decimal]
				"x" [get in rebol.fn 'hexadecimal]
			] [make error! rejoin [{Unhandled base for terminal value, base: } mold param/base]]
			map-each spec param/spec [convert spec]
		]
		accumulate-charsets: func [block /local specs contents alts] [
			block: block/3
			specs: copy [] contents: copy [] alts: copy []
			while [not tail? block][
				set [word param content] block
				either 'temp.charset = :word [
					append specs param/spec
					append contents content
					remove/part block 3
				][block: skip block 3]
			] block: head block
			specs: rejoin delimit specs #"_"
			append compose/deep [
				temp.charset [spec (specs)] [
					(contents)
				]
			] block
		]
		repeat: func [param content][
			param: reduce [param/min param/max]
			param: either param = [none none] ['any] [either param = [1 none] ['some] [param]]
			if all [block? :param integer? param/1 equal? param/1 param/2][param: param/1]
			either all [block? :param integer? param/1 'none = param/2][
				; REBOL doesn't have equivalent of x-or-more, so make equivalent
				compose [(param/1) (content) any (content)]
			][
				compose [(:param) (:content)]
			]
		]
		case-sensitive: func [pattern [char! string!]][
			if either string? pattern [
				find/match/case lowercase copy pattern uppercase copy pattern ; String!
			][
				equal? lowercase pattern uppercase pattern [return pattern] ; Char!
			][return pattern] ; This pattern is not case sensitive - nothing special to do.
			to paren! reduce ['matchcase pattern]
		]
		case-insensitive: func [pattern [string!]][
			if find/match/case lowercase copy pattern uppercase copy pattern [
				return pattern  ; This pattern is not case sensitive - nothing special to do.
			]
			to paren! reduce ['nocase pattern]
		]
	]

	; Prepare the AST for REBOL conversion

	rewrite ast
	[

		;;; Order of the rewrite rules *is* significant for some rules.

		; First remove some unnecessary structures.
		; Each of these contains a single node - replace with the node.

		[x: 'ast.alternation 'none into [3 skip]] [
			(x/3)
		]
		[x: 'ast.concatenation 'none into [3 skip]] [
			(x/3)
		]
		[x: 'ast.repetition 'none block!] [
			(x/3)
		]

		; Convert num-range to temp.charset and maintain spec in parameter - in case of need to break out as new rule later.
		[x: 'ast.num-range set param block! skip] [
			temp.charset [spec (join param/base uppercase rejoin delimit param/spec #"-")] [(delimit rebol.fn/map-char param '-)]
		]

		; Where there are multiple value-ranges in an alternation - accumulate them into a single charset.
		; The reason for this is REBOL charsets are set unions anyway.
		[x: 'ast.alternation 'none into [ thru 'temp.charset thru 'temp.charset to end]] [
			ast.alternation none [
				(rebol.fn/accumulate-charsets x)
			]
		]

	]

	; Rewrite from the top down, lower to higher precedence:
	;	Alternative
	;	Concatenation
	;	Grouping, Optional
	;	Repetition
	;	Value range
	;	Comment
	;	Rule name, prose-val, Terminal value

	embedded-charsets: copy []

	rewrite ast
	[

		;;; Order of the rewrite rules *is* significant for some rules.

		; Insert alternative operator - has to happen before AST nodes are collapsed to REBOL codes.
		['ast.alternation skip set content block!] [
			(rebol.fn/alternatives content)
		]

		; Concatenation is just juxtaposition in REBOL.
		['ast.concatenation skip set content block!] [(content)]

		; Group just becomes block.
		['ast.group 'none] []

		; Convert optional straight to OPT.
		['ast.optional skip set content block!] [opt [(content)]]

		; Decide which REBOL repetition form to use.
		['ast.repetition set param block! set content block!] [
			(rebol.fn/repeat :param :content)]

		; Charsets - A rule consisting simply of temp.charset - just convert to charset.
		; Paren maintains the 3 item structure of ast.rule.
		[x: 'ast.rule set param block! into ['temp.charset block! set content block!]] [
			ast.rule [(param)] (to paren! reduce ['charset (content)])
		]

		; Charsets - Remaining temp.charset are embedded, break these out into new rules.
		; We might end up generating the same rule more than once here, but the design of the rule name
		; makes removing duplicates later easy.
		['temp.charset set param block! set content block!] [
			ast.rulename none (
				append embedded-charsets reduce [
					to set-word! (name: rejoin [prefix-string "charset." param/spec]) (to paren! reduce ['charset content])
				]
				name
			)
		]

		; Rule reference - Simple convert to a word.
		['ast.rulename 'none set content string!] [(to word! join prefix-string content)]

		; Prose value - Simple convert. Will use a tag to represent it. Will be up to user to deal with it.
		['ast.prose-val 'none set content string!] [(to tag! content)]

		; Terminal Values
		['ast.num-char set param block! skip] [(rebol.fn/case-sensitive first rebol.fn/map-char param)]
		['ast.num-string set param block! skip] [(rebol.fn/case-sensitive rejoin rebol.fn/map-char param)]

		; Char-Val are case-insenstive
		['ast.char-val 'none set content skip] [(rebol.fn/case-insensitive content)]

		; Rule.
		['ast.rule set param block! set content skip] [
			(to set-word! join prefix-string param/name) [
				(content)
			]
		]

		; De-nest charsets where rule = charset.
		[x: set-word! into [paren!]] [(x/1) (:x/2/1)]

		; De-nest string! and char! for rules.
		[x: set-word! into [char! | string!]] [(x/1) (x/2)]

	]

	; Add newly created rules back in.
	append ast unique/skip embedded-charsets 2
	new-line/all/skip ast true 2

	ast
]

case-insensitive-guardrule: func [
	{Creates a case insenstive parse rule to match a string by using a guard rule.}
	string
][
	compose [p1: (length? string) skip p2: (to paren! compose [guard: either (uppercase string) = uppercase copy/part p1 p2 [[none]][[end skip]]]) guard]
]

case-insensitive-chars: func [
	{Creates a case insenstive parse rule to match a string by enumerating the characters.}
	string [string!]
	/local lowr uppr lwr upr
][
	lowr: lowercase copy string
	uppr: uppercase copy string
	collect [repeat i length? string [lwr: lowr/:i upr: uppr/:i keep/only either lwr = upr [lwr][compose [ (lwr) | (upr)]]]]
]
