REBOL [
	title: "Vertical and horizontal panels styles"
	file: %vert-horiz-panels-style.r
	author: "Marco Antoniazzi"
	email: [luce80 AT libero DOT it]
	date: 17-12-2011
	version: 0.1.3
	Purpose: {Add simple vertical and horizontal panels styles to VID GUIs}
	comment: {Very simple layout. Sizes are not propagated.
		You are strongly encouraged to post an enhanced version of this script}
	History: [
		0.1.2 [21-08-2011 "First version"]
		0.1.3 [17-12-2011 "Simplified words definition, bug fixed vertical alignment"]
	]
	Category: [util vid view]
	library: [
		level: 'intermediate
		platform: 'all
		type: 'how-to
		domain: [gui vid]
		tested-under: [View 2.7.7.3.1]
		support: none
		license: 'BSD
		see-also: none
	]
]

vert-horiz-panels: stylize [
	vert-panel: panel with [
		align: 'justify
		words: [left center right justify [new/align: first args args]]
		calc-size: func [fpane s1 s2 /local face main-size min-size max-size ex succ] [
			if 1 < length? fpane [
				main-size: 0
				min-size: 2147483647
				max-size: 0
				foreach face fpane [min-size: min min-size face/offset/:s1]
				foreach face fpane [max-size: max max-size (face/offset/:s1 + face/size/:s1)]
				main-size: (max size/:s1 max-size - min-size) - edge/size/:s1
				forall fpane [
					face: first fpane
					succ: pick fpane 2
					if all [succ succ/offset/:s2 > (face/offset/:s2 + face/size/:s2)] [; there is not a face beside us
						case [
							align = 'justify [do ex: [
								face/size/:s1: min main-size (max-size - face/offset/:s1)
							]]
							any [align = 'center align = 'middle] [do ex: [
								min-size: main-size - face/size/:s1 / 2 + face/offset/:s1
								if (face/size/:s1 / 2 + min-size) <= (size/:s1 - edge/size/:s1 / 2) [face/offset/:s1: min-size - (edge/size/:s1 / 2)]
							]]
							any [align = 'right align = 'bottom] [do ex: [
								min-size: main-size - face/size/:s1 + face/offset/:s1
								if (face/size/:s1 + min-size) <= size/:s1 [face/offset/:s1: min-size - edge/size/:s1]
							]]
						]
					]
				]
				do ex ; last face
				fpane: head fpane
			]
		]
		append init [
			calc-size pane 1 2	; 1 = x , 2 = y
		]
	]
	horiz-panel: vert-panel with [
		words: [top middle bottom justify [new/align: first args args]]
		insert init [ ; remove words that change direction: we want only a STRICT HORIZONTAL group
			replace/all second :action 'across []
			replace/all second :action 'below []
			replace/all second :action 'return []
			insert second :action 'across
		]
		append init [
			calc-size pane 2 1
		]
	]
]

win: layout [
	styles vert-horiz-panels
	across
	vert-panel center [
		btn "one"
		btn "thirteen"
		across btn "two" btn "fourteen" return
		btn "five"
	] edge [size: 2x2 color: white]
	vert-panel [
		panel [
			across
			vert-panel right [ space 4x9
				style text text red yellow
				text "Name"
				text "Surname"
				text "Age"
			]
			panel [
				style field field 50x20
				field
				field
				field
			]
		]
		vert-panel center [
			btn "OK"
			btn "Do not press me"
		] edge [size: 2x2 color: white] ; to see that buttons are NOT centered because layout is not propagated
	]
	vert-panel [
		style btn btn 30 ; give a (optional) minimum width
		field right "0" 0 ; 0 size because layout is not propagated
		horiz-panel [
			panel [
				across
				btn "7" btn "8" btn "9" return
				btn "4" btn "5" btn "6"
			]
			btn "+"
		]
		horiz-panel [
			vert-panel [
				panel [
					across
					btn "1" btn "2"
				]
				btn "0"
			]
			vert-panel [
				btn "3"
				btn "."
			]
			btn "="			
		]
	]
]

view win