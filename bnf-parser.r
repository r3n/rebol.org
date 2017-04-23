REBOL [
	Title: "BNF Parser"
	Date: 7-Mar-2013
	File: %bnf-parser.r
	Purpose: "Parse BNF rules."
	Version: 1.1.0
	Author: "Brett Handley"
	Web: http://www.codeconscious.com
	Needs: [
		%parse-analysis.r ; rebol.org
		%parse-analysis-view.r ; rebol.org (If you want to use visualise-bnf)
		%load-parse-tree.r ; rebol.org
	]
	Library: [
		level: 'intermediate
		platform: 'all
		type: [tool function]
		domain: [dialects parse text-processing]
		tested-under: [
			view 2.7.8.3.1 on [Win7] {Basic tests.} "Brett"
		]
		support: none
		license: 'apache-v2.0
		see-also: none ; See NEEDS block above.
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
		1.1.0 [7-Mar-2013 "First published." "Brett Handley"]
		1.0.0 [23-Sep-2003 "First version." "Brett Handley"]
	]
]

;
; The script-manager function is something set within my REBOL environment to manage scripts.
; Here's a simplified stand-in.

if not value? 'script-manager [
	script-manager: func ['word /local needs][
		if any [
			:word <> 'do-needs
			none? in system/script/header 'needs
			none? needs: system/script/header/needs
		][return]
		if not parse needs: compose [(:needs)] [some file!][make error! {Expected a NEEDS block consisting of file!.}]
		foreach [file] needs [do file]
	]
]

script-manager do-needs ; Does each file listed in NEEDS block.

; ---------------------------------------------------------------------------------------------------------------------
;
; BNF PARSER
;
;
; Purpose:
;
;	This script is used to parse a flavor of BNF. It main purpose is to be an example of
;	PARSING a grammar, using PARSE-ANALYSIS-VIEW.R and LOAD-PARSE-TREE.R.
;
;
; Values:
;
;	bnf-text
;
;		Show the definition of BNF in terms of BNF. This is the definition I used to
;		create bnf.grammar.
;
;	bnf.grammar
;
;		Defines the parse rules used to process the BNF text.
;
;		There are two points here where dynamic "guard" rules are used to constrain
;		pattern matching. One is rhs-identifier-not-left. This rule is needed so that
;		left-hand-side identifiers are not confused with right-hand-side identifiers,
;		so that in turn left-hand-side identifiers will mark the point where each rule begins.
;
;		The second use of guard rule is to ensure that double quotes within double quotes
;		are identified properly. The way I do this is to say that the terminating double
;		quote will be followed by a space, or a newline, or the end of input.
;
;
; Functions:
;
;
;	valid-bnf?
;
;		Returns TRUE if it can parse the BNF text data using the rules.
;		All the following parsing funtions leverage this function.
;
;
;	visualise-bnf
;
;		Displays the ABNF and allows interactive highlighting and navigation through the parse steps/tokens.
;		Used during debugging.
;
;
;	bnf-parse-tree
;
;		This function returns a token tree from BNF.
;		Used by bnf-to-parse.
;
;
;	bnf-to-parse
;
;		Takes token tree from bnf-parse-tree and emits REBOL parse rules.
;
;		The approach taken is to treat the parse tree as an executable REBOL block. So functions
;		are defined for part of the token tree, bound to the tree and REDUCE is called upon the block
;		yielding the new rules.
;
;		Note that the resulting rules are insufficient to parse BNF, but they are a start.
;
;
; Comments:
;
;	An alternative approach is embedded the actions required to emit the REBOL with the parse rules. There is
;	a script on REBOL.org that does this http://www.rebol.org/view-script.r?script=bnf-compiler.r
;
; ---------------------------------------------------------------------------------------------------------------------


bnf-text: {
	syntax     ::=  { rule }
	rule       ::=  identifier  "::="  expression
	expression ::=  term { "|" term }
	term       ::=  factor { factor }
	factor     ::=  identifier |
	                quoted_symbol |
	                "("  expression  ")" |
	                "["  expression  "]" |
	                "{"  expression  "}"
	identifier ::=  letter { letter | digit }
	quoted_symbol ::= """ { any_character } """
}


bnf.grammar: context [
	syntax: [any [rule] sp? end]
	rule: [sp? lhs-identifier sp? define-op sp? expression]
	expression: [term any [sp? alternative-op sp? term]]
	term: [factor any [sp? factor]]
	factor: [
		rhs-identifier-not-left
		| quoted_symbol
		| single
		| optional
		| repetition
	]
	identifier: [letter any [letter | digit | #"-" | #"_"]]
	rhs-identifier-not-left: [
		(lhs-identifier-test: [rhs-identifier])
		opt [
			identifier sp? define-op (lhs-identifier-test: [end skip])
			end skip
		]
		lhs-identifier-test
	]
	lhs-identifier: [identifier]
	rhs-identifier: [identifier]
	lhs-identifier-test: none
	quoted_symbol: [dquote any quoted-text dquote]
	pos: none
	dquote: #"^""
	single: [#"(" sp? expression sp? #")"]
	optional: [#"[" sp? expression sp? #"]"]
	repetition: [#"{" sp? expression sp? #"}"]
	alternative-op: "|"
	define-op: "::="
	letter: charset [#"a" - #"z" #"A" - #"Z"]
	digit: charset "0123456789"
	quoted-text: [some any-character]
	any-character: [
		not-dquote
		|
		{"} [p: [#" " | newline | end] (not-endquote: [end skip]) :p | (not-endquote: [none])] not-endquote ; Prevents end dquote from being considered part of quoted text.
	]
	not-dquote: exclude complement charset {"}
	sp-char: charset " ^-^/"
	sp: [some sp-char]
	sp?: [any sp-char]
	not-endquote: p: none
]

valid-bnf?: func [
	input [string!]
	{Test if input can be parsed by our BNF grammar.}
][
	parse/all/case input bnf.grammar/syntax
]

visualise-bnf: func [
	{Visualise the BNF text by overlaying highlighted grammar rules.}
	input [string!] {BNF text.}
	/local terms
] [
	terms: [rule lhs-identifier rhs-identifier quoted-text single alternative-op optional repetition]
	visualise-parse input bind terms in bnf.grammar 'self [valid-bnf? input]
]

bnf-parse-tree: func [
	{Create token tree of the BNF.}
	input [string!] {BNF text.}
	/local terms
] [
	terms: [rule lhs-identifier rhs-identifier quoted-text single alternative-op optional repetition]
	load-parse-tree bind terms in bnf.grammar 'self [valid-bnf? input]
]

bnf-to-parse: func [
	{Takes BNF token tree and reduces it to REBOL parse rules.}
	text [string!]
	/local _to_parse
] [
	_to_parse: func [input [block!] /local terms emit result] [
		result: make block! 100
		emit: func [value /only] [
			either only [insert/only tail result :value
			] [insert tail result :value]]
		terms: context [
			rule: func [item [block!] /local tmp] [
				emit first tmp: _to_parse item
				emit/only next tmp
			]
			lhs-identifier: func [item [string!]] [emit to set-word! item]
			rhs-identifier: func [item [string!]] [emit to word! item]
			alternative-op: func [item [string!]] [emit to word! item]
			quoted-text: func [item [string!]] [if 1 = length? item [item: first item] emit item]
			single: func [item [block!]] [emit/only _to_parse item]
			optional: func [item [block!]] [
				emit 'opt
				emit/only _to_parse item
			]
			repetition: func [item [block!]] [
				emit 'any
				emit/only _to_parse item
			]
		]
		reduce bind input in terms 'self
		result
	]
	new-line/all/skip _to_parse bnf-parse-tree text true 2
]

; ---------------------------------------------------------------------------------------------------------------------
; Demonstration

visualise-bnf bnf-text

print "^/ The BNF Token Tree^/"
print mold bnf-parse-tree bnf-text

print "^/ The BNF converted to parse rules^/"
print mold bnf-to-parse bnf-text

HALT