REBOL [
	Title: "Spellck2"
	Purpose: "A spellchecked area"
	Usage: {
Do this script before you create an area. like this:
 do/args %spellck.r 'load-only ;(without arg it runs demo)
Then you have spellcked areas in your script.
They flash nicely red if you press space, "." or such after a misspelled word.
}
	License: {
The dictionary is free, my code bsd.
It contains a modified 'ctx-text which is owned by RT, but since
you get that whith rebol it should be ok :)
}

	Author: "Volker Nitsch"
	Date: 23-Aug-2003
	Version: 1.0.0
	Type: 'link-app
	File: %spellck.r

	Notes: {
- The first time it downloads a big dictionary from rebol.org,
and the rebol.org-interface-code. if you dont like that, change/remove that code and distribute the dictionary yourself.

- The downloaded dictionary comes with ispell on suse8.0.
I converted it to a simple one word/line format, because that performs best with rebol for quick loading and single lookups. Unfortunally the converters are years old and confuse myself, so i cannot convert newer dictionarys currently..
 
I was not sure about the copyright, some stuff there stated GPL, but a friend send me this:
>>
I was wondering if you would mind reposting your spell check scripts on developer ,  also 
I checked with Geoff Kuenning for a copyright clarification on the dictionaries and got the following reply ....

"For all practical purposes, the ispell dictionaries are in the public
domain.  It's just not worth trying to do anything else.  In the next
release, I'll try to remember to explicitly place them in the PD.  But
in the meantime, feel free to use them in any manner you choose."
<<
}

	Library: [
		level: 'intermediate
		platform: 'all
		type: [package]
		domain: [gui ui user-interface vid]
		tested-under: none
		support: none
		license: 'BSD
		see-also: none
	]
]

;;;;;;;;;;; spellchecking

ctx-spellck2: context [

	;you may change this to another location:
	file: %words.txt
	;attempt [delete file] ;force download while debugging
	if not exists? file [
		use [win dl] [
			win: view/new layout [
				ta: area "Downloading rebol.org interface^/" wrap
			]
			do http://www.rebol.org/library/public/lds-local.r
			append ta/text "Downloading dictionary. 500kb, with modem that taakes time..^/" show ta
			dl: lds/send-server 'get-package-file ["spellck.r/words.txt"]
			dl: decompress dl/data/file
			write file dl
			unview
		]
	]
	correct-words: read file

	wrong-word: func ["callback for eventually bad-word-collector" string] []
	correct?: func [word /local res] [
		res: any [
			find correct-words join "^/" [word newline]
			1 = length? word
		]
		if not res [wrong-word word]
		found? res
	]

	;;;;; field-hooks

	letter: charset [#"A" - #"Z" #"a" - #"z" #"'"]
	other: negate letter

	spellcheck-trigger?: func [char] [
		not find letter char
	]
	spellcheck-last-word: func [string /local word left reversed] [
		left: skip string -25 ;large enough?
		reversed: head reverse copy/part left string
		either parse/all reversed [copy word some letter to end] [
			word: head reverse word
			correct? word
		] [
			true ;no text also ok..
		]
	]

	;;;;; based on ctx-text, changes marked with ;===

	ctx-spellchecked-text:
	make object! [
		view*: system/view
		hilight-text: func [face begin end] [
			view*/highlight-start: begin
			view*/highlight-end: end
		]
		hilight-all: func [face] [
			view*/highlight-start: head face/text
			view*/highlight-end: tail face/text
		]
		unlight-text: func [] [
			view*/highlight-start: view*/highlight-end: none
		]
		hilight?: func [] [
			all [
				object? view*/focal-face
				string? view*/highlight-start
				string? view*/highlight-end
				not zero? offset? view*/highlight-end view*/highlight-start
			]
		]
		hilight-range?: func [/local start end] [
			start: view*/highlight-start
			end: view*/highlight-end
			if negative? offset? start end [start: end end: view*/highlight-start]
			reduce [start end]
		]
		copy-selected-text: func [face /local start end] [
			if all [
				hilight?
				not flag-face? face hide
			] [
				set [start end] hilight-range?
				write clipboard:// copy/part start end
				true
			]
		]
		copy-text: func [face] [
			if not copy-selected-text face [
				hilight-all face
				copy-selected-text face
			]
		]
		delete-selected-text: func [/local face start end] [
			if hilight? [
				face: view*/focal-face
				set [start end] hilight-range?
				if flag-face? face hide [remove/part at face/text index? start index? end]
				remove/part start end
				view*/caret: start
				face/line-list: none
				unlight-text
				true
			]
		]
		next-word: func [str /local s ns] [
			set [s ns] view*/vid/word-limits
			any [all [s: find str s find s ns] tail str]
		]
		back-word: func [str /local s ns] [
			set [s ns] view*/vid/word-limits
			any [all [ns: find/reverse back str ns ns: find/reverse ns s next ns] head str]
		]
		end-of-line: func [str /local nstr] [
			either nstr: find str newline [nstr] [tail str]
		]
		beg-of-line: func [str /local nstr] [
			either nstr: find/reverse str newline [next nstr] [head str]
		]
		next-field: func [face /local item] [
			all [
				item: find face/parent-face/pane face
				while [
					if tail? item: next item [item: head item]
					face <> first item
				] [
					if all [object? item/1 flag-face? item/1 tabbed] [return item/1]
				]
			]
			none
		]
		back-field: func [face /local item] [
			all [
				item: find face/parent-face/pane face
				while [face <> first item: back item] [
					if all [object? item/1 flag-face? item/1 tabbed] [return item/1]
					if head? item [item: tail item]
				]
			]
			none
		]
		keys-to-insert: make bitset! #{
01000000FFFFFFFFFFFFFFFFFFFFFF7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF
}
		keymap: [
			#"^H" back-char
			#"^-" tab-char
			#"^~" del-char
			#"^M" enter
			#"^A" all-text
			#"^C" copy-text
			#"^X" cut-text
			#"^V" paste-text
			#"^T" clear-tail
		]
		;===insert char
		insert-char: func [face char] [
			delete-selected-text
			if not same? head face/text head view*/caret [view*/caret: at face/text index? view*/caret]
			face/dirty?: true
			if error? try [view*/caret: insert view*/caret char] [append view*/caret char]
			;===spellcheck, start flash
			if all [
				spellcheck-trigger? char
				not spellcheck-last-word back view*/caret
			] [
				face/rate: 10
				face/color: red
			]
		]
		edit-text: func [
			face event action
			/local key set-caret liney hi swap-text tmp tmp2 page-up page-down
		] [
			key: event/key
			if flag-face? face hide swap-text: [
				tmp: face/text face/text: face/data face/data: tmp
				view*/caret: either error? try [index? view*/caret] [tail face/text] [
					at face/text index? view*/caret
				]
			]
			if word? key [
				either event/shift [
					hi: view*/caret
					if not view*/highlight-start [view*/highlight-start: hi]
				] [unlight-text]
				tmp: caret-to-offset face view*/caret
				textinfo face view*/line-info view*/caret
				liney: view*/line-info/size/y
				hi: event/shift
			]
			if char? key [
				either find keys-to-insert key [insert-char face key] [key: select keymap key]
			]
			if word? key [
				set-caret: [view*/caret: offset-to-caret face tmp]
				page-up: [
					tmp/y: tmp/y - face/size/y
					if not head? view*/line-info/start set-caret
				]
				page-down: [
					tmp/y: tmp/y + face/size/y
					if not tail? offset-to-caret face tmp set-caret
				]
				switch key [
					back-char [
						if all [not delete-selected-text not head? view*/caret] [
							either event/control [
								tmp2: view*/caret
								remove/part view*/caret: back-word tmp2 tmp2
							] [
								remove view*/caret: back view*/caret
							]
						]
						face/dirty?: true
					]
					del-char [
						if all [not delete-selected-text not tail? view*/caret] [
							either event/control [
								remove/part view*/caret next-word view*/caret
							] [
								remove view*/caret
							]
						]
						face/dirty?: true
					]
					up [
						either event/control page-up [
							tmp/y: tmp/y - liney
							if not head? view*/line-info/start set-caret
						]
					]
					down [
						either event/control page-down [
							tmp/y: tmp/y + liney
							if not tail? offset-to-caret face tmp set-caret
						]
					]
					home [
						view*/caret: either event/control [head view*/caret] [beg-of-line view*/caret]
					]
					end [
						view*/caret: either event/control [tail view*/caret] [end-of-line view*/caret]
					]
					left [
						if not head? view*/caret [
							view*/caret: either event/control [back-word view*/caret] [back view*/caret]
						]
					]
					right [
						if not tail? view*/caret [
							view*/caret: either event/control [next-word view*/caret] [next view*/caret]
						]
					]
					page-up page-up
					page-down page-down
					enter [
						either flag-face? face return [
							if flag-face? face hide swap-text
							if flag-face? face tabbed [focus next-field face]
							action face face/data
							exit
						] [insert-char face newline]
					]
					copy-text [copy-text face unlight-text]
					cut-text [copy-text face delete-selected-text face/dirty?: true]
					paste-text [
						delete-selected-text
						face/line-list: none
						face/dirty?: true
						view*/caret: insert view*/caret read clipboard://
					]
					clear-tail [
						remove/part view*/caret end-of-line view*/caret
						face/dirty?: true
					]
					all-text [hilight-all face]
					tab-char [
						if flag-face? face tabbed [
							either in face 'refocus [face/refocus event/shift] [
								tmp2: either event/shift [back-field face] [next-field face]
								if flag-face? face hide swap-text
								action face face/data
								focus tmp2
							]
							exit
						]
						insert-char face tab
					]
				]
			]
			if hi [view*/highlight-end: view*/caret]
			if face: view*/focal-face [
				if flag-face? face hide [
					insert/dup clear face/data "*" length? face/text
					do swap-text
				]
				textinfo face view*/line-info view*/caret
				liney: view*/line-info/size/y
				tmp: caret-to-offset face view*/caret
				tmp2: face/para/scroll
				if all [tmp/x <= 0 tmp2/x < 0] [face/para/scroll/x: tmp2/x - tmp/x]
				if all [tmp/y <= 0 tmp2/y < 0] [face/para/scroll/y: tmp2/y - tmp/y]
				action: face/size - tmp - face/para/margin
				if action/x - 5 <= 0 [face/para/scroll/x: tmp2/x + action/x - 5]
				if action/y - liney <= 0 [face/para/scroll/y: tmp2/y + action/y - liney]
				show face
			]
		]
		edit:
		make object! [
			;===redraw
			redraw: func [face act pos] [
				if all [in face 'colors block? face/colors not face/rate] [
					face/color: pick face/colors face <> view*/focal-face
				]
			]
			detect: none
			over: none
			;===engage
			engage: func [face act event] [
				switch act [
					;===check for time
					time [face/rate: none face/color: face/colors/1 show face]
					down [
						either not-equal? face view*/focal-face [
							focus face
							view*/caret: offset-to-caret face event/offset
						] [
							view*/highlight-start:
							view*/highlight-end: none
							view*/caret: offset-to-caret face event/offset
						]
						show face
					]
					over [
						if not-equal? view*/caret offset-to-caret face event/offset [
							if not view*/highlight-start [view*/highlight-start: view*/caret]
							view*/highlight-end: view*/caret: offset-to-caret face event/offset
							show face
						]
					]
					key [edit-text face event get in face 'action]
				]
			]
		]
		swipe:
		make object! [
			redraw: none
			detect: none
			over: none
			engage: func [face act event] [
				switch act [
					down [
						either not-equal? face view*/focal-face [
							focus/no-show face
						] [
							view*/highlight-start:
							view*/highlight-end: none
						]
						view*/caret: offset-to-caret face event/offset
						show face
						face/action face face/text
					]
					up [
						if view*/highlight-start = view*/highlight-end [unfocus]
					]
					over [
						if not-equal? view*/caret offset-to-caret face event/offset [
							if not view*/highlight-start [view*/highlight-start: view*/caret]
							view*/highlight-end: view*/caret: offset-to-caret face event/offset
							show face
						]
					]
					key [
						if 'copy-text = select keymap event/key [
							copy-text face unlight-text
						]
					]
				]
			]
		]
	]
	;===end ctx-changed-text

	;;;;;;;;;;;; make spellcheck default

	stylize/master [
		area: area with [
			feel: ctx-spellchecked-text/edit
		]
		field: field with [
			feel: ctx-spellchecked-text/edit
		]
	]
]

;;;;;;;;;;;;;;;;;; main

if not system/script/args [
	either view? [
		view layout [
			text "Type a little text with some wrong words (type, not copypaste!)"
			ta: area wrap do [focus ta]
			field "a second field"
		]
	] [
		forever [
			word: ask "word "
			probe ctx-spellck2/correct? word
		]
	]
]
