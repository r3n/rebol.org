REBOL [
	Title: "Load-Parse-Tree (Parse-Analysis)"
	Date: 5-May-2013
	File: %load-parse-tree.r
	Purpose: "Load a block structure representing your input as matched by Parse."
	Version: 2.0.1
	Author: "Brett Handley"
	Web: http://www.codeconscious.com
	Comment: {Requires parse-analysis.r 2.0.0 (see rebol.org).}
	Needs: [
		%parse-analysis.r ; rebol.org
	]
	Library: [
		level: 'advanced
		platform: 'all
		type: [tool function]
		domain: [dialects parse text-processing]
		tested-under: [
			View 2.7.8.3.1 on [Win7] {Basic tests.} "Brett"
		]
		support: none
		license: 'apache-v2.0
		see-also: [%parse-analysis-view.r] ; And see NEEDS block above.
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
		2.0.1 [5-May-2013 "Fix undeclared variable fn.post in parse-token-tree." "Brett Handley"]
		2.0.0 [4-Mar-2013 "Release as version 2. Licensed with Apache License, Version 2.0" "Brett Handley"]
		1.3.0 [24-Feb-2013 "Major changes - parameters and implementation. To reduce memory overhead and simplify." "Brett Handley"]
		1.2.0 [15-Feb-2013 "Added /only which corresponds to the behaviour of the previous version. This change might break stuff." "Brett Handley"]
		1.1.0 [28-Jan-2013 "Modified to add /structure, removed unused /block." "Brett Handley"]
		1.0.0 [17-Jun-2006 "Initial version." "Brett Handley"]
	]
]

script-manager do-needs ; Does each file listed in NEEDS block.

; ---------------------------------------------------------------------------------------------------------------------
;
; LOAD-PARSE-TREE (Parse Analsysis toolkit)
;
;
; Purpose:
;
;	Derive data structure from input using parse rules.
;
;
; Quick Start Guide:
;
;	Using this example grammar:
;
;		mygrammar: context [
;			alpha: charset [#"A" - #"Z" #"a" - #"z"]
;			digit: charset {0123456789}
;			word: [some alpha]
;			number: [some digit]
;			main: [
;				some [word | number | skip]
;			]
;		]
;
;	... you can do this:
;
;		>> text: {Word 123 +=+ 45 End}
;		>> print mold load-parse-tree/ignore mygrammar [parse/all text mygrammar/main] [alpha digit]
;		[
;		    main [
;		        word "Word"
;		        number "123"
;		        number "45"
;		        word "End"
;		    ]
;		]
;
;
;
; Functions:
;
;	load-parse-tree
;
;		This function creates a tree structure from input using parse rules. Doing so may remove the need to
;		use actions to build structure in the parse rules themselves allowing them to be reused for different
;		purposes.
;
;		The resulting structure can be customised using the /structure refinement.  The default structure
;		is a simple tree consisting of NAME and CONTENT where content could be a block containing NAME and CONTENT.
;		NAME comes from the names of the original parse rules.
;
;		I call the default structure a token tree. PARSE-TOKEN-TREE is provided to parse through it.
;
;		You give load-parse-tree the rules it must track and a block that when evaluated will parse your input.
;		Check the return value from parse to determine if you should use the result from load-parse-tree.
;
;
;	parse-token-tree
;
;		Parses the default tree strucure as returned from LOAD-PARSE-TREE, evaluting a block at each node.
;
;
;	parse-ast
;
;		Parses a tree structure as returned from LOAD-PARSE-TREE when the /STRUCTURE is given
;		as [(:NAME) (LEAF?) (CONTENT)] evaluating a block at each tree node.
;
;		I call this type of structure an Abstract Syntax Tree because it can be useful for representing one.
;		If you consider the tree to be made up of [type param content] nodes then param can be a block that
;		stores attributes.  PARSE-AST does not restrict the type of param or content. It just requires that
;		type be a word!.
;
;
; Comments:
;
;	The combination of using LOAD-PARSE-TREE and PARSE-TOKEN-TREE can be particularly useful for extracting
;	structured data from some given format.
;
;	See the documentation for examples and ideas for using these functions.
;
;	I hope this script will encourage people to develop and share useful REBOL parse rules, protocols
;	and applications.
;
; ---------------------------------------------------------------------------------------------------------------------


load-parse-tree: func [
	"Builds a token tree of the input using the rule names."
	rules [block! object!] {Block of words or an object containing rules. Each word must identify a Parse rule to be hooked.}
	body [block!] {Invoke Parse on your input string.}
	/ignore {Exclude specific terms from result.} exclude-terms [block! object!] {Block of words representing rules.}
	/only {Keeps empty content blocks for non-terminals, instead of replacing them with the matched input.}
	/structure block [block!] {A compose block of output structure. Words set: [NAME LEAF? CONTENT LENGTH POSITION LEVEL SEQNUM]. Default structure [(:name) (content)]}
	/local hook try-result terms
][
	if object? rules [rules: bind exclude first rules [self] rules]
	if not ignore [exclude-terms: copy []]
	if object? exclude-terms [exclude-terms: exclude first exclude-terms [self]]
	terms: exclude rules exclude-terms

	if not structure [block: [(:name) (content)]]
	use [name leaf? content length position level seqnum] [
		bind block 'leaf?
		use [result stack first-step tk-len tk-ref] [
			hook: hook-parse terms [
				test [
					insert/only stack compose/only [step (:step) position (:position) result (:result)]
					result: copy []
				]
				pass fail [

					first-step: stack/1 remove stack

					set bind [name content result level] 'leaf? reduce [:current :result :first-step/result :level]

					if 'pass = :status [
						tk-len: subtract index? position index? first-step/position ; Length
						tk-ref: first-step/position ; Input position
						set bind [length position] 'leaf? reduce [tk-len tk-ref]
						either 1 + first-step/step = step [
							leaf?: true
							content: copy/part tk-ref tk-len
						] [
							leaf?: false
							either empty? content [
								if not only [content: copy/part tk-ref tk-len]
							] [new-line/all/skip content 1 (length? block)]
						]
						seqnum: 1 + divide length? result (length? block)
						insert tail result compose/only/deep block
					]
				]
			]
			hook/reset
			result: copy [] stack: copy []
			error? set/any 'try-result try [do body]
			unhook-parse hook
			if error? get/any 'try-result [:try-result]
			new-line/all/skip result true (length? block)
		]
	]
]


parse-token-tree: func [
	{Parse through a Token Tree as returned from LOAD-PARSE-TREE, evaluating body at each node.}
	tree [block!] {Token tree as returned by load-parse-tree with structure [type content].}
	body [block!] {Block to evaluate. Word set is NODE which has words [TYPE PARAM VALUE NODE-REF].}
	/post post-body {Block to evaluate when leaving node that had child nodes.}
	/local rule p guard ctx fn fn.post
][
	ctx: context [type: value: node-ref: none]
	fn: func [node] compose [(body)]
	if post [fn.post: func [node] compose [(post-body)]]
	rule: copy [
		opt [(guard: none) p: word! block! (guard: [end skip]) :p]
		guard node-ref: set type word! set value skip (fn ctx fn.post ctx)
		| node-ref: set type word! p: into [(value: :p/1 fn ctx) some rule]
	]
	if post [append rule [p: (node-ref: skip p -2 set [type value] node-ref fn.post ctx)]]
	rule: bind rule ctx
	parse tree [some rule]
]


parse-ast: func [
	{Parse through a Abstract Syntax Tree as returned from LOAD-PARSE-TREE/structure [type param content], evaluating body at each node.}
	tree [block!] {AST.}
	body [block!] {Block to evaluate. Word set is NODE which has words [TYPE PARAM VALUE NODE-REF].}
	/post post-body {Block to evaluate when leaving node.}
	/local rule p guard ctx fn fn.post
][
	ctx: context [type: param: value: node-ref: none]
	fn: func [node] compose [(body)]
	if post [fn.post: func [node] compose [(post-body)]]
	rule: copy [
		opt [(guard: none) p: word! skip block! (guard: [end skip]) :p]
		guard node-ref: set type word! set param skip set value skip (fn ctx fn.post ctx)
		| node-ref: set type word! set param skip p: into [(value: :p/1 fn ctx) some rule]
	]
	if post [append rule [p: (node-ref: skip p -3 set [type param value] node-ref fn.post ctx)]]
	rule: bind rule ctx
	parse tree [some rule]
]
