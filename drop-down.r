REBOL [
	file: %drop-down.r
	date: 20-Feb-2004
	title: "VID Dropdown"
	author: "Ammon Johnson"
	email: ammon@addept.ws
	version: 0.0.7
	purpose: "A simple dropdown VID style"
	library: [
		level: 'intermediate
		platform: 'all
		type: ['tool 'demo]
		domain: ['gui 'ui 'user-interface 'vid]
		tested-under: 'winxp
		support: {email me with questions}
		license: none
		comment: {Free to use as-is, acknowledgement is appreciated.
				  Please inform me of any enhancements you make.
				  Provided with NO WARRANTY.}
	]
]

Stylize/master [
	drop-down: face with [
		get-selected: lay-options: options: unview-options: field: arrow: none
		size: 120x20
		color: 255.255.255
		words: [
			data [new/data: first next args next args]
		]
		resize: func [
			"dynamically changes the size of the faces within the style"
			new [pair!] "The new size"
			/arr "Set the width of the arrow button"
			arr-size [Number! Integer!] "New arrow button width"
		] [
			size: new
			if arr [arrow/size/x: arr-size]
			field/size: new - as-pair arrow/size/x 0
			arrow/size/y: new/y
			arrow/offset: new - arrow/size
			options/size/x: size/x
			options/sub-area/size/x: field/size/x
			options/sld/size/x: arrow/size/x + arrow/edge/size/x
			options/sld/offset/x: field/size/x
			lay-options/size/x: size/x
		]
		init: [
			lay-options: layout [
				origin 0x0
				options: text-list #"^(Esc)" (size + 0x150 )[
					if not empty? options/picked [
						field/text: copy first options/picked
						show field
					]
					unview/only lay-options
					remove-event-func :unview-options
					action field field/text
				]
			]
			lay-options/options: reduce ['no-border 'no-title 'parent self]
			unview-options: func [f "face" e "event"] [
				if all [e/type = 'inactive e/face = lay-options] [
					unview/only lay-options
					remove-event-func :unview-options
				]
				e
			]
			get-selected: does[
				either 1.2.8.31 <= system/version [
                         	    options/data: data ; for later view 1.3 betas
                                ][
            	                    options/lines: data
                                ]
				options/update
				lay-options/offset: (screen-offset? field) + as-pair 0 size/y
				insert-event-func :unview-options
				view/new lay-options
			]
			pane: reduce [
				field: make-face 'field
				arrow: make-face/spec 'arrow [
					size: 16x20
					data: 'down
					action: [get-selected]
				]
			]
			field/color: color
			field/colors: colors
			if text [field/text: text]
			if none? data [data: texts]
			if none? data [data: copy []]
			if all [not empty? text not found? find data text][insert data text text: none]
			resize size
		]
	]
]

; the field and arrow are accessible via dropdown/field and dropdown/arrow
; The options layout and the text-list are accessible via dropown/lay-options dropdown/options

comment {;Uncomment for an example
view layout [
	d: drop-down "Test" data ["1" "2" "3"]
	box with [pane: get in layout [
			origin 0x0
			drop-down 100 "Yup" "Maybe" "Nope"
		] 'pane
	]
	button "resize" [d/resize 100x20 show face/parent-face]
]
}
;halt

