REBOL [
	Title: "Parse Analysis Toolset"
	Date: 4-Mar-2013
	File: %parse-analysis.r
	Purpose: "Some tools to help learn/analyse parse rules."
	Version: 2.0.0
	Author: "Brett Handley"
	Web: http://www.codeconscious.com
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
		see-also: [%parse-analysis-view.r]
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
		2.0.0 [4-Mar-2013 "Release as version 2. Licensed with Apache License, Version 2.0" "Brett Handley"]
		1.3.1 [1-Mar-2013 "Removed a level of parse recursion. Add /only to tokenise-parse." "Brett Handley"]
		1.3.0 [24-Feb-2013 "Major changes - parameters and implementation. To reduce memory overhead and simplify." "Brett Handley"]
		1.2.0 [4-Jan-2013 "Add /block to explain-parse, /all-events to tokenise-parse. Added trace-parse." "Brett Handley"]
		1.1.0 [17-Dec-2004 "First published version." "Brett Handley"]
		1.0.0 [17-Dec-2004 "Initial version." "Brett Handley"]
	]
]

; ---------------------------------------------------------------------------------------------------------------------
;
; PARSE ANALYSIS
;
;
; Purpose:
;
;	This script provides some tools to add value to parse.
;
;
; Note:
;
;	Some of these rules modify the original rules by "hooking" them. So if break
;	processing with the ESC key before the function finises the rules will not be
;	unhooked - possibly leading to strange behaviour if you try it again.
;
;
; Functions:
;
;	tokenise-parse
;
;		Tokenises some input according to parse rules.
;
;	explain-parse
;
;		Explains each parse step as it occurs.
;
;	parse-steps
;
;		Records the steps (events) for rule testing and completion that parse took.
;
;	count-parse
;
;		Counts the steps that parse took.
;
;	hook-parse
;
;		Modifies parse rules to incoporate evaluation of blocks at key events during a parse.
;
;	unhook-parse
;
;		Restores parse rules to their original state.
;
;	find-same
;
;		Find the position of a specific value within a block. The value in the block when compared
;		with the search value must satisfy the SAME? function.
;
;		It is a helper function used by some scripts that rely upon this script. Seemed
;		simpler just to include it here instead of within it's own script.
;
;
; Comments
;
;	I hope this script will encourage people to develop and share useful REBOL parse rules,
;	protocols and applications.
;
;	In version 1.3 I simplified the tracing of parse rules, radically reducing memory
;	requirements and increasing performance. I've made changes to the interface of the
;	functions too so these changes obsolete earlier versions. The changes are so significant
;	I decided to release the set of scripts as version 2.0.
;
; -----------------------------------------------------------------------------------


tokenise-parse: func [
	{Return parse events.}
	rules [block! object!] {Block of words or an object containing rules. Each word must identify a Parse rule to be hooked.}
	body [block!] {Invoke Parse on your input string.}
	/only {Returns input series references instead of index positions when input is string!.}
	/ignore {Exclude specific terms from result.} exclude-terms [block!] {Block of words representing rules.}
	/all-events  "Include TEST and FAIL events also."
	/local hook try-result terms event-actions
][
	if object? rules [rules: bind exclude first rules [self] rules]
	if not ignore [exclude-terms: copy []]
	if object? exclude-terms [exclude-terms: exclude first exclude-terms [self]]
	terms: exclude rules exclude-terms
	use [result stack first-step][
		event-actions: copy compose/deep [
			test [
				insert/only stack position
				(either all-events [[append result reduce [:status :current 0 position]]][[]])
			]
			pass fail [
				first-step: stack/1 remove stack
				(either all-events [[do]][[if 'pass = :status]]) [append result reduce [:status :current subtract index? position index? first-step first-step]]
			]
		]
		hook: hook-parse terms event-actions
		hook/reset
		result: copy [] stack: copy []
		error? set/any 'try-result try [do body] 
		unhook-parse hook
		if error? get/any 'try-result [:try-result]
		if all [not only not empty? result string? result/4][
			for i 4 length? result 4 [poke result i index? pick result i]
		]
		result
	]
]


explain-parse: func [
	"Emits numbered parse events."
	rules [block! object!] {Block of words or an object containing rules. Each word must identify a Parse rule to be hooked.}
	body [block!] "Invoke Parse on your input."
	/ignore {Exclude specific terms from result.} exclude-terms [block!] {Block of words representing rules.}
	/block {Return block events. Default is to print them.}
	/local hook try-result terms
] [

	; Initialise

	if object? rules [rules: bind exclude first rules [self] rules]
	if not ignore [exclude-terms: copy []]
	if object? exclude-terms [exclude-terms: exclude first exclude-terms [self]]
	terms: exclude rules exclude-terms

	use [result stack event indent first-step][
		hook: hook-parse terms compose [
			test [
				event: reduce [:step 'begin :current 'at index? position 'level level]
				(either block [append/only result event][
					indent: head insert/dup copy "" "  " level - 1
					print join indent form event
				])
				insert/only stack :event
			]
			pass fail [
				first-step: stack/1 remove stack
				event: reduce [:step 'end :current 'at index? position
					'started-on first-step/1 :status
				]
				(either block [append/only result event][
					indent: head insert/dup copy "" "  " subtract last first-step 1
					print join indent form event
				])
			]
		]
		hook/reset
		result: copy [] stack: copy []
		error? set/any 'try-result try [do body] 
		unhook-parse hook
		if error? get/any 'try-result [:try-result]
		either block [new-line/all result true] [return]
	]

]


parse-steps: func [
	{Return the steps that the parse took.}
	rules [block! object!] {Block of words or an object containing rules. Each word must identify a Parse rule to be hooked.}
	body [block!] {Invoke Parse on your input string.}
	/ignore {Exclude specific terms from result.} exclude-terms [block! object!] {Block of words or object representing rules.}
	/local hook try-result terms
][
	if object? rules [rules: bind exclude first rules [self] rules]
	if not ignore [exclude-terms: copy []]
	if object? exclude-terms [exclude-terms: exclude first exclude-terms [self]]
	terms: exclude rules exclude-terms
	use [result][
		hook: hook-parse terms [
			test pass fail [append/only result reduce [:status :current index? position]]
		]
		hook/reset
		result: copy []
		error? set/any 'try-result try [do body] 
		unhook-parse hook
		if error? get/any 'try-result [:try-result]
		result
	]
]


count-parse: func [
	"Returns counts of calls, successes, fails of Parse rules."
	rules [block! object!] {Block of words or an object containing rules. Each word must identify a Parse rule to be hooked.}
	body [block!] {Invoke Parse on your input string.}
	/ignore {Exclude specific terms from result.} exclude-terms [block!] {Block of words representing rules.}
	/local hook try-result terms
][
	if object? rules [rules: bind exclude first rules [self] rules]
	if not ignore [exclude-terms: copy []]
	if object? exclude-terms [exclude-terms: exclude first exclude-terms [self]]
	terms: exclude rules exclude-terms

	use [test pass fail][
		test: array/initial length? terms 0
		pass: array/initial length? terms 0
		fail: array/initial length? terms 0
		use [event name idx arry][
			foreach step parse-steps terms body [
				set [event name] step
				idx: index? find terms :name
				arry: get bind :event 'test
				poke arry idx 1 + pick arry idx
			]
		]
		new-line/all reduce [terms test pass fail] true
	]
]


hook-parse: func [
	"Hook parse rules for events: test a rule (Test), rule succeeds (Pass), rule fails (Fail). Returns hook context."
	rules [block! object!] "Block of words or an object containing rules. Each word must identify a Parse rule to be hooked."
	event-body [block!] {Block of [test [...] pass [...] fail [...]] to be evaluated at each event. Will be bound to hook context.}
	/local hook-context spec body-for p1
] [

	; Check the input

	if object? rules [rules: exclude first rules [self]]
	if not parse rules [some any-word!] [make error! "Expecting a block of words."]

	; A helper to parse the event-body mini-dialect.
	body-for: func ['word [word!] /local result][
		parse event-body compose [thru (to lit-word! :word) any word! set result block!]
		result
	]
	
	; Create the hook context.

	hook-context: context [
		step: level: status: current: ; State tracking variables.
		rule-words: ; The original rules (maintaining their bindings).
		rule-def: ; The original rule values.
		position: ; A variable to track the input position.
		none
		reset: does [step: level: 0 position: current: none]
	]
	hook-context/rule-words: rules

	; Create a context to store the original rule definitions.

	spec: make block! multiply 2 length? rules
	repeat rule rules [insert tail spec to set-word! rule]
	hook-context/rule-def: context append spec [none]

	; Modify the given rules to point to the
	; hook-context's tracking rules and save
	; the original rules.

	repeat rule rules [

		; Save existing rule.
		set in hook-context/rule-def rule reduce [get rule]

		; Replace rule with new rule incorporating tracing code.
		set rule bind compose [

			; Rule invocation

			position:
			(to paren! compose/only [
				step: step + 1 level: level + 1
				current: (to lit-word! rule) status: 'test
				do (body-for test)
			])

			; Call the original rule.

			(get in hook-context/rule-def rule)

			; Rule Success

			position:
			(to paren! compose/only [
				step: step + 1 level: level - 1
				current: (to lit-word! rule) status: 'pass
				do (body-for pass)
			])

			|

			; Rule failure

			position:
			(to paren! compose/only [
				step: step + 1 level: level - 1
				current: (to lit-word! rule) status: 'fail
				do (body-for fail)
			])
			end skip ; Ensure the failure result is maintained.

		] hook-context

	]

	; Return the hook-context.
	hook-context

]


unhook-parse: func [
	"Unhooks parse rules hooked by the Hook-Parse function."
	hook-context [object!] "Hook context returned by the Hook-Parse function."
] [
	repeat rule hook-context/rule-words [set rule first get in hook-context/rule-def rule]
	hook-context/rule-def: none ; Clear references to original rules.
	hook-context/reset
	return ; return unset
]


find-same: func [
	{Finds a value in a block, must satisfy SAME? function.}
	block [block!]
	value
	/local pos result
][
	while [found? pos: find/only block :value][
		if same? :pos/1 :value [result: pos break]
		block: next pos
	]
	result
]


error-text?: function [
	"A function to generate normal error message text given an error object."
	error [object!]
][message][
	do bind/copy [
		if block? message: system/error/:type/:id [
			message: bind/copy message 'arg1
		]
		rejoin [
			{** } uppercase/part reform type 1 
			{ Error: } reform message
			{^/** Where: } mold error/where
			{^/** Near: } mold error/near
		] 
	] in error 'self
]	
