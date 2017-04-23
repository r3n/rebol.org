REBOL [
	Title: {Simple REBOL Text Parser}
	Purpose: "Parse text using a REBOL grammar and index values found within it."
	File: %rebol-text-parser.r
	Date: 9-Mar-2013
	Version: 1.0.1
	Author: "Brett Handley"
	Web: http://www.codeconscious.com
	Needs: [
		%load-parse-tree.r ; rebol.org
	]
	Library: [
		level: 'intermediate
		platform: 'all
		type: [tool function]
		domain: [parse text-processing]
		tested-under: [
			View 2.7.8.3.1 on [Win7] {Basic tests.} "Brett"
		]
		support: none
		license: 'apache-v2.0
		see-also: [%parse-analysis.r]  ; And see NEEDS block above.
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
	history: [
		1.0.1 [9-Mar-2013 "Fix last minute bug, was doing too much at once :-/" "Brett Handley"]
		1.0.0 [4-Mar-2013 "Initial version." "Brett Handley"]
	]
]

script-manager do-needs ; Does each file listed in NEEDS block.

; ---------------------------------------------------------------------------------------------------------------------
;
; SIMPLE REBOL TEXT PARSER
;
;
; Purpose:
;
;	Parse REBOL code in textual form. Allow mapping of REBOL blocks to their positions in a textual representation.
;
;
; Objects:
;
;	rebol.text.grammar
;
;		Simple parse rules that describe the grammar of REBOL text.
;
; Functions:
;
;	valid-reboltext?
;
;		A simple function to determine if the supplied text can be parsed by this parser. It's main use it to
;		show the correct way to invoke parse using REBOL.TEXT.GRAMMAR.
;
;	rebol-to-text-index
;
;		Using the simple grammar, maps block, block tail and value positions in text to text offsets and lengths.
;		The mapping in indexed by a path of block index positions.
;
;	block-to-text-index
;
;		Using the simple grammar, maps block and value positions in text to text offsets and lengths.
;		The mapping is indexed by series references.
;
;	convert-block-to-text-tokens
;
;		Takes a token list as returned from tokenise-parse (parse-analysis.r) when applied to a block input
;		and converts the lengths and positions to textual lengths and offsets.
;		Used by visualise-parse (parse-analysis-view.r).
;
; Comments:
;
;	Initial motivation for this script was to provide the functions required to implement a block input
;	mode for make-token-stepper (parse-analysis-view.r). However, the functions may be useful for other
;	applications.
;
;	rebol.text.grammar was developed from Parse-code by Carl Sassenrath.
;
; ---------------------------------------------------------------------------------------------------------------------


; Guard is used here to prevent block end and paren end markers
; from being consumed by the value rule.

use [p1 p2 guard val][
	rebol.text.grammar: context [
		line-end: [newline]
		comment: [some [#";" [thru newline | to end]]]
		block-start: [#"["]
		block-end: [#"]"]
		paren-start: [#"("]
		paren-end: [#")"]
		value: [skip (set [val p2] load/next p1) :p2]
		block: [block-start any-block block-end]
		paren: [paren-start any-block paren-end]
		any-block: [
			any [
				p1: line-end
				| comment
				| block
				| paren
				| p1: [[#"]" | #")" ] (guard: [end skip]) | (guard: none) ] :p1 guard value
			]
		]
	]
]


valid-reboltext?: func [
	{Determine if text looks like REBOL code.}
	text [string!] {REBOL Text String.}
][
	parse text rebol.text.grammar/any-block
]


rebol-to-text-index: func [
	{Identifies position and length of REBOL blocks, parens and values within text. Returns index path to value, length, position.}
	text [string!] {REBOL Text String.}
	/local stack exclude-terms structure ast
][
	structure: [(:name) [seqnum (seqnum) length (:length) position (index? position)] (either block? :content [:content][none])]
	ast: load-parse-tree/structure (bind [block paren value] rebol.text.grammar) [valid-reboltext? text] structure
	stack: copy []
	new-line/all/skip collect [
		use [path type length position entry][
			parse-ast/post ast [
				keep entry: reduce [join stack :node/param/seqnum :node/type :node/param/length :node/param/position]
				if any ['block = :node/type 'paren = :node/type] [
					append stack :node/param/seqnum
				]
			][
				if any ['block = :node/type 'paren = :node/type] [
					set [path type length position] reduce [join stack 1 + divide length? any [:node/value []] 3 :node/type :node/param/length :node/param/position]
					keep reduce [path 'tail 0 length + position - 1]
					remove back tail stack
				]
			]
		]
	] true 4
]


block-to-text-index: func [
	{Maps block positions to textual lengths and positions within a text representation.}
	block [block!] {The block to index.}
	/text {Specify the string. Default is a MOLD of the block.} string [string!] {Must be the textual equivalent to block.}
	/local series num data index
][
	if not text [
		string: mold block
	]
	index: rebol-to-text-index string
	if empty? index [return index]
	block: reduce [block] ; To equate to molded text (which is semantically like a containing block).
	forskip index 4 [
		series: copy index/1
		clear back tail series
		series: do join to path! 'block series
		num: last index/1
		series: at series num
		change/only index series
	]
	head index
]


convert-block-to-text-tokens: func [
	{Converts tokens as returned from tokenise-parse into textual lengths and positions.}
	block [block!] {The original block.}
	tokens [block!] {As returned from tokenise-parse (has references to block and it's sub-blocks).}
	/text {Specify the string. Default is a MOLD of the block.} string [string!] {Must be the textual equivalent to block.}
	/local data ref-start ref-end pos-start pos-end index
][
	if not text [string: mold block]
	index: block-to-text-index/text block string
	forskip tokens 4 [
		either found? pos-start: find-same index ref-start: tokens/4 [
			poke tokens 4 pos-start/4
			ref-end: tokens/3
			either ref-end = 0 [
				pos-end: 0 ; Length of zero is just zero.
			][
				either ref-end = 1 [
					pos-end: pos-start/3 ; We have length of a single REBOL value.
				][
					; Calculate length, by finding ending reference.
					ref-end: skip ref-start tokens/3
					either found? pos-end: find-same index ref-end [
						pos-end: (pos-end/4) - pos-start/4
					][
						make error! rejoin [{Could not find reference for token end: } mold ref-end]
					]
				]
			]
			poke tokens 3 pos-end
		][
			make error! {Could not find reference for token start.}
		]
	]
	tokens: head tokens
]

