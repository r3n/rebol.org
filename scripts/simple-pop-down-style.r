REBOL [
	title: "Pop-down style example"
	file: %simple-pop-down-style.r
	author: "Marco Antoniazzi"
	email: [luce80 AT libero DOT it]
	date: 21-09-2014
	version: 0.0.1
	Purpose: {A quick way to add a simple pop-down to VID GUIs}
	comment: {You are strongly encouraged to post an enhanced version of this script}
	History: [
		0.0.1 [21-09-2014 "First version"]
	]
	Category: [util vid view]
	library: [
		level: 'beginner
		platform: 'all
		type: 'how-to
		domain: [gui vid]
		tested-under: [View 2.7.8.3.1]
		support: none
		license: none
		see-also: none
	]
]

choice-btn-style: stylize [
	choice-btn: btn with [
		pad: 6
		font: make font [align: 'left]
		font-btn: font ; copy font to copy its size to list text
		update: true ; update face when an item is chosen
		chosen: none ; to store chosen item
		list: none
		list-size: none
		text: any [text ""]
		texts: any [texts [""]]
		colors-back: none
		colors-fore: none
		access: context [
			set-face*: func [face value][face/text: face/chosen: value]
			get-face*: func [face][face/text]
		]
		words: [
			update [new/update: second args next args]
		]
		insert init [ ; must insert in init to avoid reusing face (boh? , copied from check-line)
			; arrow down
			pane: make-face/spec 'box compose/deep [
				size: 12x10
				offset: 0x0 
				feel: none
				effect: [draw  [transform 0.0 0x0 2 2 0x0 pen (font/color) fill-pen (font/color) polygon 1x1 3x1 2x2 ]]
				edge: make edge [size: 1x0 color: none]
			]
		]
		append init [
			if texts [
				data: texts
				chosen: first texts
			]
			para: make para [origin: origin + 2x0] 
			size/x: size/x + pad
			edge-size: edge-size? self
			pane/offset: as-pair (size/x - pane/size/x ) (size/y - 5 / 2)
			pane/offset/x: either empty? text [pane/offset/x / 2][pane/offset/x - 2]
			list-size: any [list-size size/x]
			list: layout/tight [
				list as-pair (list-size) 18 * ((length? texts) - 1) + 2 edge [size: 1x1 color: black] [
					origin 0 space 0 across
					txt (list-size) "" with [ ; use txt if text is modified
						colors-back: reduce [white black]
						colors-fore: reduce [black white]
						font: make font [color: first colors-fore size: font-btn/size]
						color: first colors-back
						feel: make feel [
							over: func [face action event][
									face/font/color: pick face/colors-fore not action
									face/color: pick face/colors-back not action
									show face
							]
							engage: func [face act event][
								if event/type = 'down [
									do-face list/data chosen: face/text
									hide-popup
									; restore colors
									face/font/color: face/colors-fore/1
									face/color: face/colors-back/1
								]
								focus find-window face
								show face
							]
						]
						
					]
				] supply [
					face/text: texts/(count + 1)
					if count > length? texts [return none]
				]
			]
			list/pane/1/subface/pane/1/colors-back: any [reduce colors-back reduce [white black]]
			list/pane/1/subface/pane/1/colors-fore: any [reduce colors-fore reduce [black white]]
			list/data: self ; store btn face
		]
	] feel [
		redraw-super: :redraw
		redraw: func [face act pos][
			redraw-super face act pos
			if face/update [face/text: face/chosen]
		]
		engage: func [face action event][
			if (action = 'down) or (action = 'up) [
				remove/part find face/effect 'mix 2
				face/list/offset: (win-offset? face) + (face/size * 0x1)
				face/list/offset/x: face/list/offset/x - face/list/size/x + face/size/x ; right aligned
				show-popup/window/away face/list find-window face
				do-events
			]
		]
    ]

]
do ; comment this line to comment example code
[
	view center-face layout [
		styles choice-btn-style
		across
		text1: text "text1"
		; NOTE that first text below is repeated exactly twice
		choice-btn "text1" "text1" "text2" [set-face text1 value]
		text "simple case"
		return
		text2: text "not chosen"
		choice-btn "Choose a text" "1st text" "2nd text" red update false font [color: yellow] with [colors-back: [white blue] colors-fore: [black green]] [set-face text2 value]
		text "This has a fixed text"
		return
		field1: field
		; NOTE the (fixed) list width
		choice-btn "" "1st choice" "2nd choice" update false with [list-size: 80] [set-face field1 value]
		text "This has a fixed width"
		return
		text "This is an example of various pop-downs"
	]
]