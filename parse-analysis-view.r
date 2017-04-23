REBOL [
	Title: "Parse Analysis Toolset /View"
	Date: 25-May-2013
	File: %parse-analysis-view.r
	Purpose: "Some REBOL/View tools to help learn/analyse parse rules."
	Version: 2.1.0
	Author: "Brett Handley"
	Web: http://www.codeconscious.com
	Needs: [
		%parse-analysis.r ; rebol.org
		%rebol-text-parser.r ; rebol.org
	]
	Library: [
		level: 'advanced
		platform: 'all
		type: [tool function]
		domain: [parse text-processing debug]
		tested-under: [
			view 2.7.8.3.1 on [Win7] {Basic tests.} "Brett"
		]
		support: none
		license: 'apache-v2.0
		see-also: [%load-parse-tree.r] ; And see NEEDS block above.
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
		2.1.0 [25-May-2013 "Add Resizing to make-token-stepper. Add rebol-text-parser.r to needs block. Couple of tweeks to scrolling." "Brett Handley"]
		2.0.0 [4-Mar-2013 "Release as version 2. Licensed with Apache License, Version 2.0" "Brett Handley"]
		1.3.0 [24-Feb-2013 {Accommodate major changes to parse-analysis.r} "Brett Handley"]
		1.2.3 [23-Feb-2013 {Bugfix and make highlighter style highlight drawing more robust, multiple other enhancements.} "Brett Handley"]
		1.2.2 [22-Feb-2013 {Added show-lf keyword to highlighter style, multiple other enhancements.} "Brett Handley"]
		1.2.1 [18-Feb-2013 {Added mouse-wheel scrolling and other navigation.} "Brett Handley"]
		1.2.0 [13-Feb-2013 {Changed some variable handling. Major new addition: make-token-stepper.
			Added comments. Added visualise-parse.} "Brett Handley"]
		1.1.0 [19-Dec-2004 "First published version." "Brett Handley"]
		1.0.0 [19-Dec-2004 "Initial version." "Brett Handley"]
	]
]

script-manager do-needs ; Does each file listed in NEEDS block.

; -----------------------------------------------------------------------------------
;
; Comments
;
;	This script helps visualise the matching of parse rules against text.
;	It currently only works with string! type inputs because I haven't
;	worked out yet how to do caret-to-offset functionality with block inputs.
;
;	I don't claim it to be a model of good design, it has been evolved until it does what
;	I want it to do. In addition it was created originally with a slider style
;	and I've just introduced scroller. I'm pretty sure there are better ways
;	to organise the interactions but I'm too rusty with VID to do it right now.
;
;	I hope this will encourage people to develop and share useful REBOL parse rules,
;	protocols and applications.
;
;
; MAKE-TOKEN-STEPPER
;
;
; Purpose:
;
;	Step through and highlight where rules match the input so as to be able
;	to follow what happened during a parse run and help identify problems in parse rules.
;
;
; Concept/behaviour:
;
;	A parsing run is traced into a sequence of parse steps (events). Make-token-stepper
;	allows you to move forward and backward through the steps.
;
;	Each step is one of three types:
;
;		TEST - When a parse rule is invoked to start testing the input.
;		PASS - When a parse rule has successfully matched some input.
;		FAIL - When a parse rule has completed unsuccessfully.
;
;	Moving forward through the steps, at each TEST the rule is added to the Active stack
;	and is highlighted in orange. At each PASS or FAIL it is removed from the Active stack
;	and highlighted in Green if it passed or Red if it failed.
;
;	The status area shows the current step number, the step details and the Active rule stack.
;	The structure of a step is [EVENT rulename length-matched input-position]
;
;	At all times the current rule definition is shown at the very bottom of the window.
;
;	Line feed characters (newline) are indicated by a small white block at the end of lines.
;
;
; Navigating with keys and mouse:
;
;	The basics:
;
;		Normal mouse highlight/copy is available, it is unreleated to the other functions.
;
;		Mouse scroll wheel - scroll the page.
;
;		page-down, page-up - scroll by page.
;
;		down - next parse step
;		up - prior parse step
;
;		ctrl home - move to first parse step
;		ctrl end - move to last parse step
;
;		ctrl page-down - scroll so end of rule is visible without changing highlights.
;		ctrl page-up - scroll so start of rule is visible without changing highlights.
;
;
;	Finding the longest match of input.
;
;		ctrl shift home = move to the first step that got furthest through the input.
;		ctrl shift end = move to the last step that got furthest through the input.
;
;			Note: These last two are worth trying first when your rules are not working,
;			      because they have a good chance of showing where the problem occurs.
;
;
;	When the input position is important:
;
;		Ctrl + mouse click - moves to parse step that matched that position in the input.
;
;		end / home = next/previous PASS at this position. Input position is held constant, so you
;		             can "zoom out" to parent rules with the End key and "zoom in" to child rules
;                        at the same position with the Home key.
;
;	When the rules are more important:
;
;		White Rule buttons (rules that passed sometime) = move to the next PASS for that rule.
;		Gray Rule buttons (rules that never passed) = move to the next FAIL for that rule.
;
;		right / left = next/previous PASS of any rule (hold shift for FAIL).
;
;		ctrl right / ctrl left = next/previous time this rule will PASS (hold shift for FAIL).
;
;		ctrl down = Move to the step that this rule finishes with a PASS or FAIL.
;		ctrl up = Move to the step that this rule started with a TEST.
;
;
; MAKE-TOKEN-HIGHLIGHTER
;
; Purpose:
;
;	Creates a face that shows token names in a scroll panel and
;	text input in the main part. Clicking on a token name highlights
;	all parts of the text that are matched by that token.
;
; Notes:
;
;	Each token is considered to be a different colour. By using the
;	token name as the colour and passing that to the HIGHTLIGHTED-TEXT
;	style all text with that token (colour) can be highlighted at once.
;
;	Superseeded by MAKE-TOKEN-STEPPER.
;
;
;
; VISUALISE-PARSE
;
; Purpose:
;
;	An easy way to use make-token-stepper.
;
; -----------------------------------------------------------------------------------



stylize/master [

	;
	; Highlighted-Text Style
	;
	;	Set HIGHLIGHTS with a block of [colour length caret] triples.
	;	Use HIGHLIGHT to calculate the draw effect for the highlights.
	;


	HIGHLIGHTED-TEXT: text with [
		highlights: show-lf: sizing-face: sizing-adj: line-leading: none
		text-size?: func[text][
			insert clear sizing-face/text text
			sizing-adj + size-text sizing-face
		]
		highlight: has [
			text.xy text.start text.end line.tail line.tail.xy visual.end box.extent tmp tmp.xy
			drw-blk nl
		] [
			line-leading: 0x1 * text-size? {M}
			append clear drw-blk: effect/draw [pen white]
			if any [not highlights empty? highlights] [return]
			foreach [caret length colour] head reverse copy highlights [
				text.start: at text caret
				text.end: skip text.start length

				; Highlight may cover multple lines, draw each.
				while [
					all [
						length > 0 ; Prevent drawing empty highlights.
						(index? text.start) < (index? text.end)
					]
				] [
					; Need to find the character tail for this highlight.
					; There could be a line break due to wrap, or newline, before text.end.
					; If offset x is > start, then character is on the same line (a newline).

					text.xy: caret-to-offset self text.start
					visual.end: offset-to-caret self to pair! reduce [size/1 text.xy/2]
					tmp: at text max (index? text.start) min (index? visual.end) (subtract index? text.end 1) ; Search optimisation.

					until [
						tmp: next tmp
						tmp.xy: caret-to-offset self tmp
						any [
							(tail? tmp)
							(tmp.xy/x <= text.xy/x)
							(index? tmp) >= (index? text.end)
						]
					]
					line.tail: tmp

					; line.tail is at the tail of the line, or tail of the highlight.
					; Visually, it could be on the same line, or on the following line (newline/wrap).
					; But we want the offset of the end of the current line.
					nl: none
					line.tail.xy: caret-to-offset self line.tail

					if line.tail.xy/2 > text.xy/2 [
						line.tail.xy: either nl: newline = first back line.tail [
							(either show-lf [10x0][0x0]) + (caret-to-offset self back line.tail)
						][
							(caret-to-offset self back line.tail) + (text-size? first back line.tail)
						]
					]

					; Now draw line highlight.
					box.extent: subtract line.tail.xy text.xy
					box.extent/2: line-leading/2
					if edge [text.xy: text.xy - edge/size] ; Draw is relative to edge.
					if edge [line.tail.xy: line.tail.xy - edge/size] ; Draw is relative to edge.
					insert tail drw-blk reduce ['fill-pen colour 'box text.xy text.xy + box.extent]
					if nl [
						line.tail.xy: line.tail.xy - 8x1 + line-leading - 0x7
						if show-lf [insert tail drw-blk reduce ['fill-pen show-lf 'box line.tail.xy line.tail.xy + 4x5]]
					]
					if text.start = line.tail [
						make error! {Should not happen. Line.tail = Text.Start during draw highlights.}
					]

					text.start: line.tail
				]
			]
		]
		words: [
			highlights [new/highlights: second args next args]
			show-lf [new/show-lf: second args next args] ; Draws newlines.
		]
		append init [
			effect: append/only copy [draw] make block! multiply 5 divide length? any [highlights []] 3
			sizing-face: make-face/styles/spec 'text copy self/styles compose [size: (size)] ; Need to copy fonts.
			sizing-adj: 0x0
			sizing-adj: -1x0 * subtract (2 * text-size? {X}) (text-size? {XX})
			if all [show-lf not tuple? :show-lf] [show-lf: gray]
			if show-lf [size: size + 10x0] ; Space for line feed indicator.
			highlight
		]
	]

	SCROLL-PANEL: FACE edge [size: 2x2 effect: 'ibevel] with [

		data-padding: data: cropbox: sliders: none

		; returns unit-vector for an axis
		uv?: func [w] [either w = 'x [1x0] [0x1]]

		; calculates canvas size
		sz?: func [f] [either f/edge [f/size - (2 * f/edge/size)] [f/size]]

		; calculates size of data not shown.
		hiddenamt?: func [] [max 0x0 data/size - (sz? cropbox)]

		; slider widths for both directions as a pair
		sldw: 15x15

		; Manages the pane.
		layout-pane: function [/resize child-face] [sz dsz v v1 v2 lyo] [
			if none? data [data: copy []]

			; Convert VID to a face.
			if block? data [data: layout/offset/styles data 0x0 copy self/styles]

			; On initial layout create the crop-box and sliders.
			if not resize [
				if not size [size: data/size if edge [size: 2 * edge/size + size]]
				lyo: layout compose/deep [
					origin 0x0 cropbox: box
					scroller 5x1 * sldw [
						face/parent-face/scroll-to-match face
					]
					scroller 1x5 * sldw [
						face/parent-face/scroll-to-match face
					]
				]
				sliders: copy/part next lyo/pane 2
				pane: lyo/pane
			]

			; data face goes inside cropbox
			cropbox/pane: data
			sz: sz? self
			cropbox/size: sz dsz: data/size

			; Determine the size of the content plus any required sliders.
			repeat i 2 [
				repeat v [x y] [
					if dsz/:v > sz/:v [dsz: sldw * (reverse uv? v) + dsz]
				]
			]
			dsz: min dsz sldw + data/size

			; Size the cropbox to accomodate sliders.
			repeat v [x y] [
				if (dsz/:v > sz/:v) [
					cropbox/size: cropbox/size - (sldw * (reverse uv? v))
				]
			]

			; Size and position the sliders - non-required slider(s) is/are off stage.
			repeat sl sliders [
				v2: reverse v1: uv? v: sl/axis
				sl/offset: cropbox/size * v2
				sl/size: add 2 * sl/edge/size + cropbox/size * v1 sldw * v2
				sl/resize none
				sl/redrag divide cropbox/size/:v data/size/:v
				if resize [svvf/drag-off sl sl/pane/1 0x0]
			]
			if resize [do-face self data/offset]
			self
		]

		; Page scrolling.
		page-down: func [] [
			scroll-drag/page sliders/2
			show face
		]

		page-up: func [] [
			scroll-drag/back/page sliders/2
			show face
		]

		; Ensure item can be seen, scroll if necessary.
		show-item: func [
			offset extent
			/surround min-surround {Minimum to show before or after the item.}
			/local tl br unseen
		] [
			if not surround [min-surround: 45x45]
			unseen: hiddenamt?
			tl: offset + cropbox/pane/offset - min-surround ; tl is relative to cropbox.
			br: tl + extent + min-surround
			foreach axis [x y][
				if tl/:axis < 0 [cropbox/pane/offset/:axis: min 0 cropbox/pane/offset/:axis + negate tl/:axis]
				if br/:axis > cropbox/size/:axis [cropbox/pane/offset/:axis: max negate unseen/:axis cropbox/pane/offset/:axis - (br/:axis - cropbox/size/:axis)]
			]
			move-scrollers/no-action/offset cropbox/pane/offset ; Sync scroller to new position.
		]

		; Set the scroller in code and fire event so page scrolls.
		move-scrollers: func [
			{Move the vertical scroller.}
			value
			/axis {Scroll only one axis.} axis-name [word!]
			/relative {Relative to current position.}
			/offset {Value is an offset, instead of a proportion.}
			/no-action {Don't fire the scroller's action (prevents scroller from scrolling the view).}
			/local dnm unseen bar-axis axis-v
		] [
			unseen: hiddenamt?
			foreach bar sliders [
				bar-axis: bar/axis
				if any [not axis :bar-axis = :axis-name][
					axis-v: value
					if offset [axis-v: either zero? dnm: unseen/:bar-axis [0] [divide negate value/:bar-axis dnm]]
					if relative [axis-v: bar/data + axis-v]
					axis-v: min 1 max 0 axis-v
					bar/data: axis-v
					if not no-action [do-face bar none]
					show bar
				]
			]
		]

		; Scrolls view to match the scroller position.
		scroll-to-match: func [
			{Scroll subpanel to match the scroller position.}
			bar
			/local uv other-axis
		] [
			uv: uv? bar/axis
			this-axis: uv * negate bar/data * hiddenamt?
			other-axis: cropbox/pane/offset * reverse uv ; Other axis component.
			cropbox/pane/offset: other-axis + this-axis
			cropbox/changes: 'offset ; Performance hint to graphics system.
			show cropbox
			do-face self cropbox/pane/offset
			self
		]

		; Method to change the content
		modify: func [spec] [data: spec layout-pane/resize self]

		; Resize method.
		resize: func [new /x /y] [
			either any [x y] [
				if x [size/x: new]
				if y [size/y: new]
			] [size: any [new size]]
			layout-pane/resize self
		]

		init: [feel: none layout-pane]

		; Keywords.
		words: [data [new/data: second args next args]
			action [new/action: func [face value] second args next args]]
		multi: make multi [
			image: file: text: none
			block: func [face blk] [if blk/1 [face/data: blk/1]]
		]
	]
]

make-token-highlighter: func [
	{Returns a face which highlights tokens.}
	input "The input the tokens are based on."
	tokens [block!] "Block of tokens as returned from the tokenise-parse function."
] [

	use [
		sz-main sz-input names name-count name-area ctx
		token-lyo colours set-highlight trace-term btns
		highlighter-face
	] [

		sz-main: divide multiply 13 subtract system/view/screen-face/size 0x150 16

		sz-input: sz-main
		ctx-text/unlight-text

		; Build colours and bind token words to them.
		name-count: length? names: unique extract tokens 3
		colours: make block! 1 + name-count
		foreach name names [insert tail colours reduce [to set-word! name silver]]
		colours: context colours
		tokens: bind/copy tokens in colours 'self

		; An object to store window specific methods.
		ctx: context [
			rule?: func [
				"Returns the rules that are satisfied at the given input position."
				tokens "As returned from tokenise-parse."
				position [integer!] "The index position to check."
				/local result
			] [
				if empty? tokens [return copy []]
				result: make block! 100
				forskip tokens 3 [
					if all [
						get in colours tokens/1 ; Make sure only highlighted terms are selected
						position >= tokens/3 tokens/3 + tokens/2 > position] [
						insert tail result copy/part tokens 3
					]
				]
				result
			]
			all-highlights: has [btn] [
				repeat word next first colours [
					set in colours word sky
					btn: get in btns word
					btn/edge/color: sky
				]
			]
			clear-highlights: has [btn] [
				repeat word next first colours [
					set in colours word none
					btn: get in btns word
					btn/edge/color: silver
				]
			]
			set-highlight: func [name /local clr btn] [
				clr: 110.110.110 + random 120.120.120
				set in colours name clr ; Set the highlighted token.
				btn: get in btns name
				btn/edge/color: clr
			]
		]

		; Build name area
		btns: make colours []
		name-area: append make block! 2 * length? names [
			origin 0x0 space 0x0 across
			btn "[Clear]" [
				ctx-text/unlight-text clear trace-term/text
				token-lyo/user-data/clear-highlights show token-lyo
			]
			btn "[All]" [
				ctx-text/unlight-text clear trace-term/text
				token-lyo/user-data/all-highlights show token-lyo
			]
		]
		foreach name names [
			insert tail name-area append reduce [
				(first bind reduce [to set-word! name] in btns 'self) 'btn
				form name get in colours name
				compose [token-lyo/user-data/set-highlight (to lit-word! name) show token-lyo]
			] [edge [size: 3x3]]
		]

		; Build main layout
		token-lyo: layout [

			origin 0x0 space 0x0

			; The names
			scroll-panel to pair! reduce [sz-input/1 45] name-area

			; The input
			scroll-panel sz-input [

				origin 0x0 space 0x0

				highlighter-face: highlighted-text black input as-is highlights tokens feel [
					engage: func [face act event /local rules pos] [
						switch act [
							down [
								either not-equal? face system/view/focal-face [
									focus face
									system/view/caret: offset-to-caret face event/offset
								] [
									system/view/highlight-start:
									system/view/highlight-end: none
									system/view/caret: offset-to-caret face event/offset
								]
								pos: index? system/view/caret ; map cursor to position in the input
								rules: token-lyo/user-data/rule? tokens pos ; get the rules at the input position
								; highlight the first (most specific) rule
								if not empty? rules [
									system/view/highlight-start: at face/text rules/3
									system/view/highlight-end: skip system/view/highlight-start rules/2
								]
								insert clear trace-term/text form head reverse extract rules 3
								show face show trace-term
							]
						]
					]
				]

			]

			; The text area at bottom.
			trace-term: area wrap to pair! reduce [sz-main/1 40]

		]
		token-lyo/user-data: ctx
		token-lyo/text: "Token Highlighter"
		token-lyo/user-data/all-highlights
		token-lyo
	]
]


make-token-stepper: func [
	{Returns a face which highlights tokens.}
	input "The input the tokens are based on."
	steps [block!] "Block of tokens as returned from the tokenise-parse function with /fails refinement."
] [

	use [
		sz-main sz-input names name-count name-area ctx
		token-lyo colours set-highlight btns
		tokens txt-height nm-height
		highlighter-face btn-scroll main-scroll trace-term rule-term resizing-delta
	] [

		rule-stack: copy []
		tokens: steps

		txt-height: 40
		nm-height: 45

		sz-main: divide multiply subtract system/view/screen-face/size (to pair! reduce [0 2 * txt-height + nm-height]) 2 3

		sz-input: subtract sz-main (to pair! reduce [0 2 * txt-height + nm-height])
		ctx-text/unlight-text

		; Build colours and bind token words to them.
		name-count: length? names: unique extract next tokens 4
		colours: make block! 1 + name-count
		foreach name names [insert tail colours to set-word! name]
		colours: context append colours 'white

		; Generate VID for name area.
		btns: make colours []
		name-area: append make block! 2 * length? names [
			origin 0x0 space 0x0 across
		]
		use [passed] [
			foreach name names [
				passed: found? find tokens reduce ['pass :name]
				insert tail name-area append reduce [
					(first bind reduce [to set-word! name] in btns 'self) 'btn
					form name
					set in colours name either passed [white] [gray]
					'with compose [data: (passed)]
					compose [
						token-lyo/user-data/move-to-step-for-rule/state/rule face/data (to lit-word! name)
						token-lyo/user-data/scroll-to-rule
						token-lyo/user-data/update-highlights/no-namescroll
					]
				] [edge [size: 3x3]]
			]
		]

		; Build main layout
		token-lyo: layout [

			origin 0x0 space 0x0

			; The names
			btn-scroll: scroll-panel to pair! reduce [sz-input/1 nm-height] name-area

			; The input
			main-scroll: scroll-panel sz-input [

				origin 0x0 space 0x0

				highlighter-face: highlighted-text black input as-is show-lf true feel [

					engage: func [face act event /local rules pos get-pos] [

						ctx-text/swipe/engage :face :act :event ; Provides for text highlight/copy.
						if face <> system/view/focal-face [focus face] ; Swipe feel may have unfocussed this face.

						get-pos: func [] [
							either not-equal? face system/view/focal-face [
								focus face
								system/view/caret: offset-to-caret face event/offset
							] [
								system/view/highlight-start:
								system/view/highlight-end: none
								system/view/caret: offset-to-caret face event/offset
							]
							index? system/view/caret ; map cursor to position in the input
						]

						switch act bind [
							up [
								if event/control [
									pos: get-pos
									move-to-position pos event/control event/shift
									update-highlights
								]
							]
							key [
								switch event/key [
									end [either event/control [either event/shift [move-to-furthest-input true] [last-step]] [next-step-at-pos event/shift] scroll-to-rule/end update-highlights]
									home [either event/control [either event/shift [move-to-furthest-input false] [first-step]] [prior-step-at-pos event/shift] scroll-to-rule update-highlights]
									down [either event/control [move-to-step-for-rule] [next-step] scroll-to-rule/end update-highlights]
									up [either event/control [move-to-step-for-rule/first] [prior-step] scroll-to-rule update-highlights]
									right [either event/control [move-to-step-for-rule/state not event/shift] [move-to-next-pass event/shift] scroll-to-rule/end update-highlights]
									left [either event/control [move-to-step-for-rule/prior/state not event/shift] [move-to-prior-pass event/shift] scroll-to-rule update-highlights]
									page-down [either event/control [scroll-to-rule/end update-highlights] [main-scroll/page-down]]
									page-up [either event/control [scroll-to-rule update-highlights] [main-scroll/page-up]]
								]
							]
							scroll-line [
								main-scroll/move-scrollers/relative/offset/axis (-1 * event/offset/y * face/line-leading) 'y
								show main-scroll
							]
						] token-lyo/user-data
					]

				]

			]

			; The text area at bottom.
			trace-term: area wrap to pair! reduce [sz-main/1 txt-height]

			; The text area at bottom.
			rule-term: area wrap to pair! reduce [sz-main/1 txt-height]

		]


		; An object to store window methods and data.
		ctx: context [
			all-highlights: has [btn] [
				repeat word next first colours [
					set in colours word sky
					btn: get in btns word
					btn/edge/color: sky
				]
			]
			clear-highlights: has [btn] [
				repeat word next first colours [
					set in colours word none
					btn: get in btns word
					btn/edge/color: silver
				]
			]
			set-highlight: func [name scroll /colour clr /local btn] [
				if not colour [clr: 110.110.110 + random 120.120.120]
				set in colours name clr ; Set the highlighted token.
				btn: get in btns name
				btn/edge/color: clr
				if scroll [btn-scroll/show-item btn/offset btn/size]
			]

			current-step: tokens
			rule-stack: copy []
			sticky-position: none

			at-end?: does [not lesser? index? current-step subtract length? tokens 4]

			init: func [] [
				token-lyo/text: "Token Stepper"
				if not tail? current-step [append rule-stack current-step/2]
				sticky-position: current-step/4
				resizing-delta: token-lyo/size - main-scroll/size
			]

			resize: func [][
				main-scroll/size: token-lyo/size - resizing-delta
				rule-term/size/x: trace-term/size/x: btn-scroll/size/x: main-scroll/size/x
				abut 0x1 reduce [btn-scroll main-scroll trace-term rule-term]
				btn-scroll/resize none
				main-scroll/resize none
			]

			update-highlights: func [/no-namescroll /local clr event rule length position] [
				if not tail? current-step [
					clear-highlights
					set [event rule length position] current-step
					clr: either 'fail = event [red] [either 'test = event [orange] [green]]
					set-highlight/colour :rule (not no-namescroll) clr
					highlighter-face/highlights: reduce [
						tan position - 1 1
						clr length position
					]
					highlighter-face/highlight
					insert clear rule-term/text mold get rule
				]
				insert clear trace-term/text reform [
					"Step:" add divide subtract index? current-step 1 4 1
					mold new-line/all copy/part current-step 4 false
					"Active:" mold rule-stack
				]
				show token-lyo
			]

			next-step: func [/sticky] [
				if at-end? [return]
				current-step: skip current-step 4
				if not at-end? [
					either 'test = current-step/1 [append rule-stack current-step/2] [remove back tail rule-stack]
				]
				if sticky [sticky-position: current-step/4]
			]
			prior-step: func [/sticky] [
				if head? current-step [return]
				if not at-end? [
					either 'test <> current-step/1 [append rule-stack current-step/2] [remove back tail rule-stack]
				]
				current-step: skip current-step -4
				if sticky [sticky-position: current-step/4]
			]

			first-step: func [] [
				current-step: head current-step
				clear rule-stack
				init
			]

			last-step: func [] [
				insert clear trace-term/text {Searching...} show trace-term
				while [not at-end?] [next-step]
				sticky-position: current-step/4
			]

			move-next-until: func [condition /nonsticky /local event rule length position result] [
				if at-end? [return false]
				until compose/deep [
					next-step
					set [event rule length position] current-step
					any [
						result: (bind :condition 'event)
						at-end?
					]
				]
				if not nonsticky [sticky-position: position]
				return result
			]
			move-prior-until: func [condition /nonsticky /local event rule length position result] [
				if head? current-step [return false]
				until compose/deep [
					prior-step
					set [event rule length position] current-step
					any [
						result: (bind :condition 'event)
						head? current-step
					]
				]
				if not nonsticky [sticky-position: position]
				return result
			]
			move-to-next-pass: func [failures /local word] [
				insert clear trace-term/text {Searching...} show trace-term
				word: either failures ['fail] ['pass]
				move-next-until [:word = :event]
			]
			move-to-prior-pass: func [failures /local word] [
				insert clear trace-term/text {Searching...} show trace-term
				word: either failures ['fail] ['pass]
				move-prior-until [:word = :event]
			]

			move-to-step-for-rule: func [/first /prior /state pass /rule name /local condition bookmark save-rules result] [
				insert clear trace-term/text {Searching...} show trace-term
				if not rule [name: current-step/2]
				bookmark: current-step save-rules: copy rule-stack
				either first [
					prior: true
					condition: ['test = :event :name = :rule]
				] [
					condition: compose either state [
						[(to lit-word! either pass ['pass] ['fail]) = :event :name = :rule]
					] [
						['test != :event :name = :rule]
					]
				]
				result: do either prior [:move-prior-until] [:move-next-until] compose/only [all (condition)]
				if not result [current-step: bookmark rule-stack: save-rules]
			]

			move-to-furthest-input: func [last? /local bookmark save-rules] [
				insert clear trace-term/text {Searching...} show trace-term
				first-step
				bookmark: current-step save-rules: copy rule-stack
				while [not at-end?] compose [
					if current-step/4 (either last? [[>=]] [[>]]) bookmark/4 [bookmark: current-step save-rules: copy rule-stack]
					next-step/sticky
				]
				current-step: bookmark rule-stack: save-rules
			]

			move-to-position: func [pos special failures] [
				insert clear trace-term/text {Searching...} show trace-term

				either failures [

					; Move forwards to find next rule that failed at or after position.
					if (current-step/4 + current-step/3 - 1) < pos [
						move-next-until [all ['fail = :event position >= pos]]
						return
					]

					; Move backwards to find rule that failed at position or before
					if current-step/4 > pos [
						move-prior-until [all ['fail = :event position < pos]]
					]

				] [

					; Move forwards to find next rule that matches position.
					if (current-step/4 + current-step/3 - 1) < pos [
						move-next-until [(position + length - 1) >= pos]
						return
					]

					; Move backwards to find rule that matches position
					if current-step/4 > pos [
						move-prior-until [position < pos]
					]

				]

			]

			next-step-at-pos: func [special /local pos word bookmark save-rules] [
				insert clear trace-term/text {Searching...} show trace-term
				word: 'pass
				pos: sticky-position
				bookmark: current-step save-rules: copy rule-stack
				move-next-until/nonsticky [all [:word = :event position <= pos (position + length - 1) >= pos]]
				if not all [current-step/4 <= pos (current-step/4 + current-step/3 - 1) >= pos] [
					current-step: bookmark rule-stack: save-rules
				]
			]

			prior-step-at-pos: func [special /local pos word bookmark save-rules] [
				insert clear trace-term/text {Searching...} show trace-term
				word: 'pass
				pos: sticky-position
				bookmark: current-step save-rules: copy rule-stack
				move-prior-until/nonsticky [all [:word = :event position <= pos (position + length - 1) >= pos]]
				if not all [current-step/4 <= pos (current-step/4 + current-step/3 - 1) >= pos] [
					current-step: bookmark rule-stack: save-rules
				]
			]

			scroll-to-rule: func [/end {Show end of rule.} /local pos offset end-offset extent] [
				pos: at highlighter-face/text current-step/4
				either end [
					pos: skip pos current-step/3 ; End of rule (new rule starts here).
					extent: 3 * highlighter-face/line-leading
				] [
					extent: 4 * highlighter-face/line-leading ; Provide a bit of surround at bottom.
				]
				offset: caret-to-offset highlighter-face pos
				main-scroll/show-item offset extent
			]

		]

		token-lyo/user-data: ctx
		focus highlighter-face
		token-lyo/user-data/init
		token-lyo/user-data/update-highlights

		; Resizing event.
		token-lyo/feel: make token-lyo/feel [
			detect: func [face event] [
				switch event/type [
					key [
						if face: find-key-face face event/key [
							if get in face 'action [do-face face event/key]
							return none
						]
					]
					resize [
						token-lyo/user-data/resize
						show face
					]
				]
				event
			]
		]

		center-face token-lyo
		token-lyo
	]
]


abut: func [
	{Make faces abut each other, in the specified direction.}
	uv {Unit vector direction. 1x0 or 0x1} [pair!]
	faces [block!]
	/local offset
] [
	offset: get in first faces 'offset
	foreach face faces [
		face/offset: offset
		offset: uv * face/size + offset
	]
]


visualise-parse: func [
	{Displays your input and highlights the parse rules.}
	data [string! block!] {Input to the parse.}
	rules [block! object!] {Block of words or an object containing rules. Each word must identify a Parse rule to be hooked.}
	body [block!] {Invoke Parse on your input.}
	/ignore {Exclude specific terms from result.} exclude-terms [block!] {Block of words representing rules.}
	/local result block tokens
][
	if not ignore [exclude-terms: copy []]
	view/new center-face layout [title "Visualise Parse" label "Tokenising input..."]
	error? set/any 'result try [
		tokens: tokenise-parse/all-events/ignore rules body exclude-terms
		if block? data [
			block: data
			data: mold block
			convert-block-to-text-tokens/text block tokens data
		]
	]
	unview
	if error? get/any 'result [
		view center-face layout [title "Visualise Parse - Error" text as-is error-text? disarm result button "Ok" [unview]]
		tokens: none
	]
	if block? tokens [
		view/options make-token-stepper data tokens [resize]
	]
]
