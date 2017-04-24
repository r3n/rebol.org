REBOL [
	Title: {REBOL Parse Rule Parser}
	Purpose: {Parse REBOL Parse Rules.}
	File: %parserule-parser.r
	Date: 9-Mar-2013
	Version: 1.0.2
	Author: "Brett Handley"
	Web: http://www.codeconscious.com
	Needs: [
		%parse-analysis.r ; rebol.org
		%parse-analysis-view.r ; rebol.org (If you want to use visualise-abnf)
		%load-parse-tree.r ; rebol.org
		%rewrite.r ; http://www.colellachiara.com/soft/
		%error-text.r ; rebol.org
		%indexing.r ; rebol.org
	]
	Library: [
		level: 'intermediate
		platform: 'all
		type: [tool function]
		domain: [parse dialects]
		tested-under: [
			View 2.7.8.3.1 on [Win7] {Basic tests.} "Brett"
		]
		support: none
		license: 'apache-v2.0
		see-also: none  ; See NEEDS block above.
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
		1.0.2 [9-Mar-2013 "Change skipping term to be more meaningful. Added comment." "Brett Handley"]
		1.0.1 [5-Mar-2013 "Bugfix due to last minute typo and wrong commented heading." "Brett Handley"]
		1.0.0 [4-Mar-2013 "Initial version." "Brett Handley"]
	]
]

script-manager do-needs ; Does each file listed in NEEDS block.

; ---------------------------------------------------------------------------------------------------------------------
;
; REBOL PARSE RULE PARSER
;
;
; Purpose:
;
;	Parse REBOL parse rules.
;
;
; Note:
;
;	This is a work in progress. Not sure if I'll keep all the functions as they are.
;
;
; Objects:
;
;	parserules.grammar
;
;		Parse rules that describe the grammar of a set of parse rule definitions.
;
;
; Functions:
;
;	valid-parserules?
;
;		Simple function to test whether a block conforms to the grammar of parserules
;		I have defined here.
;		Assumes the block can be parsed by [some [set-word! skip]].
;
;	build-parserules-tree
;
;		Return a token tree of the Parse Rules.
;		Note: This tree can be parsed by parse-token-tree (load-parse-tree.r).
;		Assumes the parse rules block can be parsed by [some [set-word! skip]].
;
;	build-parserules-ast
;
;		Build Parse rules Token Tree into an Abstract Syntax Tree where each node has form:
;
;			[Type Param Content]
;
;		Note: This AST can be parsed by parse-ast (load-parse-tree.r).
;
;		A Param of logic! just indicates if the node is a leaf or not.
;		A Param of block! is a block of parameters for the node.
;		Content of block! means the node contains other nodes.
;
;	depends-on?
;
;		Takes a parse rule definition as input and returns the rule names (words) it depends upon.
;
;	get-rule-list
;
;		Given a parse rule definition it recursively finds all the rule names the definition relies upon.
;
;	analyse-rules
;
;		Takes a block of parserules, checks the rules and returns warnings.
;		Assumes the block can be parsed by [some [set-word! skip]].
;
;	gather-rules
;
;		Starting with the name of a rule, gather all rules it ultimately references if they are available.
;		Assumes the block can be parsed by [some [set-word! skip]].
;
;	de-nest-parse-rules
;
;		Removes unnecessary nesting of blocks from rule definition.
;		Assumes the block can be parsed by [some [set-word! skip]].
;
;	visualise-parserules
;
;		Interactive highlighting of the structure of the parserules block.
;		Assumes the block can be parsed by [some [set-word! skip]].
;
; To Do:
;
;	parse-ast-to-rebol
;
;		Takes a parse rules AST and returns REBOL parse rules.
;
;	de-nest-parse-ast
;
;		Takes a parse rules AST and removes unnecessary block nesting.
;
; Comment:
;
;	A wrote parserules.grammar by hand from my knowledge of parse and some tests.
;	As parse's behaviour is quite complex, it quite possible that my hand crafted grammar
;	here may not match exactly with parse's actual behaviour.
;
;	Subsequent to writing this script I've come across this very nice reference for parse:
;
;		http://en.wikibooks.org/wiki/REBOL_Programming/Language_Features/Parse/Parse_expressions
;
; ---------------------------------------------------------------------------------------------------------------------

use [guard p] [

	parserules.grammar: context [

		rulelist: [some rule]

		rule: [rulename rule-definition]
		rulename: [set-word!]
		rule-definition: [composite | match-type]

		rule-type: [set-variable | input-position | repetition | match-type ]

		input-position: [set-word-to-data | set-data-from-word]
		set-word-to-data: [set-word!]
		set-data-from-word: [get-word!]

		set-variable: ['set variable-name non-block-element | 'copy variable-name element]
		variable-name: ['word]

		repetition: [repeat match-type]
		repeat: ['opt | 'any | 'some | min-repeat opt max-repeat]
		min-repeat: [integer!]
		max-repeat: [integer!]

		match-type: [action | composite | into-rule | skipping | data-tail | match-nothing | word-lookup | datatype | simple] ; order is important

		data-tail: ['end]

		skipping: [skip-op [input-index | paren | block | data-tail | datatype | simple] | skip-1]

		skip-op: ['to | 'thru]
		input-index: [integer!]
		datatype: [datatype!]
		skip-1: ['skip]

		action: [paren!]
		paren: [paren!]
		block: [block!]


		match-nothing: ['none]

		simple: [any-type!] ; A catch-all - assumed to be simple.

		into-rule: ['into [composite | word-lookup]]

		word-lookup: [word!]

		composite: [p: block! :p into [p: to '| :p alternation | sequence]]
		sequence: [
			some [
				(guard: none)
				opt ['| (guard: [end skip])]
				guard rule-type
			]
		]
		alternation: [sequence some ['| sequence]] ; Alternative sequences.

	]

]


valid-parserules?: func [
	{Test if block is valid set of Parse Rule definitions.}
	block [block!] {Parse Rules.}
	/definition {Block consists of a parse rule definition only.}
	/quiet {Do not print warning.}
	/local ending-position rule
] [
	if empty? block [return false]
	either definition [
		block: reduce [:block]
		rule: parserules.grammar/rule-definition
	][rule: parserules.grammar/rulelist]
	if not result: parse block [rule ending-position:][
		if not quiet [
			either found? ending-position [
				print [{Parsing the parse rules failed at index position: } index? ending-position]
			][
				print [{Parsing the parse rules failed.}]
			]
		]
	]
	result
]


build-parserules-tree: func [
	{Return a token tree of the Parse Rules.}
	block [block!] {Parse Rules.}
	/definition {Block consists of a parse rule definition only.}
	/ignore {Exclude specific terms from result.} exclude-terms [block!] {Block of words representing rules.}
	/local result structure do-parse num
] [
	do-parse: either definition [
		num: either empty? block [0][1]
		[valid-parserules?/definition block]
	][
		num: divide length? block 2
		[valid-parserules? block]
	]
	result: either ignore [
		load-parse-tree/structure/ignore parserules.grammar do-parse [(:NAME) (:LEAF?) (:CONTENT)] exclude-terms
	][
		load-parse-tree/structure parserules.grammar do-parse [(:NAME) (:LEAF?) (:CONTENT)]
	]
	if not equal? divide length? result 3 num [
		print {Number of rules in build-parse-tree result does not match those of input block.}
	]
	result
]


build-parserules-ast: func [
	{Build Parse rules token tree into an Abstract Syntax Tree.}
	block [block!] {Parse Rules.}
	/definition {Block consists of a parse rule definition only.}
	/local x value param repeat tree build-tree
] [

	build-tree: 'build-parserules-tree/ignore
	if definition [append :build-tree 'definition]

	repeat: func [
		value
		/local pos min max
	] [
		parse value [
			'any (min: 'none max: 'none)
			| 'opt (min: 'none max: 1)
			| 'some (min: 1 max: 'none)
			| 'min-repeat skip into [set min integer!] ['max-repeat skip into [set max integer!] | (max: min)]
		]
		compose/deep [min (:min) max (:max)]
	]

	tree: do build-tree block [rulelist sequence rule-type match-type rule-definition]

	rewrite tree
	[
		[x: 'repetition logic! into ['repeat logic! set param block! to end]] [
			repeat [(repeat param)] [((if param [remove/part x/3 3]) x/3)]
		]
		[x: 'rule logic! into ['rulename logic! set param block! to end]][
			rule [name (form to word! :param/1)] [((if param [remove/part x/3 3]) x/3)]
		]
		[x: word! true into [set value skip]][
			(:x/1) true (:value)
		]
	]

	tree
]


depends-on?: func [
	{Returns the words the parse rule definition depends upon (excluding built-in datatype words).}
	rule-def  {The parse rule definition.}
	/all {Return all instances, do not use Unique function.}
	/local result word-value
][
	result: collect [
		parse-ast build-parserules-ast/definition :rule-def [
			if 'word-lookup = :node/type [
				word-value: attempt [get :node/value]
				either datatype? :word-value [
					if not equal? form :node/value mold :word-value [
						keep :node/value
					]
				][
					keep :node/value
				]
			]
		]
	]
	if not all [result: unique result]
	result
]


get-rule-list: func [
	{Returns all the rules this definition depends upon.}
	rule-def [block!] {The parse rule definition.}
	/local queue rules
][
	rules: copy []
	queue: depends-on?/all rule-def ; Need all because words with same name may have different contexts.
	while [not empty? queue][

		; Get rule
		rule: first queue
		remove queue

		; Add it to our list if we haven't seen it before.
		if value? :rule [
			rule-def: get :rule
			if not block? :rule-def [rule-def: reduce [:rule-def]]
			if not found? find-same rules :rule [
				append rules :rule
				append queue depends-on?/all rule-def
			]
		]

	]
	rules
]


analyse-rules: func [
	{Check the rules - assumes block can be parsed by [some [set-word! skip]].}
	block [block!] {Parse Rules.}
	/local result
][

	result: copy [
	]

	; Check for rulenames that have multiple definitions.
	use [index list][
		index: index-writer list: copy []
		forskip block 2 [index/append :block/1 :block/2]
		unset 'index ; No need for indexing function now.
		list: remove-each [key locations] list [new-line/all locations true 1 = length? locations]
		if not empty? list [
			append result reduce [
				'multi-def list
			]
		]
	]

	; Check for definitions that are used by multiple rulenames.
	use [index list][
		index: index-writer list: copy []
		forskip block 2 [index/append :block/2 :block/1]
		unset 'index ; No need for indexing function now.
		remove-each [key locations] list [1 = length? locations]
		if not empty? list [
			mold new-line/all/skip list true 2
			append result reduce [
				'same-def list
			]
		]
	]

	; Check for rules that are referenced at most once.
	use [ast index list name][
		index: index-writer list: copy []
		ast: build-parserules-ast block
		parse-ast ast [
			switch :node/type [
				rule [
					name: to set-word! :node/param/name
				]
				word-lookup [index/append :node/value :name]
			]
		]
		unset 'index ; No need for indexing function now.
		remove-each [key locations] list [1 < length? locations]
		if not empty? list [
			mold new-line/all/skip list true 2
			append result reduce [
				'one-reference list
			]
		]
	]

	result
]


gather-rules: func [
	{Starting with the name of a rule, gather all rules it ultimately references if they are available.}
	'rule [word!] {The rule to start with.}
	rules [block!] {Block of Parse Rules.}
	/local queue rule-def pos index list ast
][

	queue: reduce [to set-word! :rule]
	index: index-writer list: copy []

	while [not tail? queue][

		; Get rule
		rule: first queue
		remove queue

		if found? pos: find rules :rule [

			; Get definition
			rule-def: copy/part pos 2

			; Add it to our list, if we haven't seen it before.
			if not index/exists :rule [

				index/append :rule second rule-def

				; Find out what it references, add each to queue for processing.
				ast: build-parserules-ast rule-def
				parse-ast ast [
					if 'word-lookup = :node/type [append queue to set-word! :node/value]
				]

			]


		]

	]

	unset 'index ; No need for it now.
	for i 2 length? list 2 [poke list i first pick list i] ; De-nest defintions.
	new-line/all/skip list true 2; Return list.
]


de-nest-parse-rules: func [
	{Removes unnecessary nesting of blocks from rule definition.}
	rules [block!]
	/local guard block
][
	for i 2 length? rules 2 [
		while [
			all [
				block? block: pick rules i
				1 = length? block
				block? block/1
			]
		][poke rules i block/1]
	]
]


visualise-parserules: func [
	{Interactive highlighting of the structure of the parserules block.}
	block [block!] {Parse Rules.}
][
	visualise-parse block parserules.grammar [valid-parserules? block]
]
