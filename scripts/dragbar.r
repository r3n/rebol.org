rebol [
    Author: "Ammon Johnson"
    email: ammon@addept.ws
    purpose: {A VID Titlebar Style}
    TBD: {add actual OS minimizing...}
    Title: "VID Titlebar"
    Date: 31-Jan-2004
    file: %dragbar.r
	version: 0.0.4
	history: [
		0.0.4 "Added Anton Roll's 'fat cross' code for the close button" "Ammon Johnson"
		0.0.3 "Various improvements including set-title a function to set the title text" "Ammon Johnson"
		0.0.2 "Converted it to an Actual Style" "Ammon Johnson"
	]
    Library: [
        level: 'intermediate
        platform: 'all
        type: [demo]
        domain: [gui]
        tested-under: [command 2.5.6.3.1 on [WinXP] "Ammon"]
        support: {email me with questions}
		license: none
		comment: {Free to use as-is, acknowledgement is appreciated.
				  Please inform me of any enhancements you make.
				  Provided with NO WARRANTY.}
        see-also: "win-maker.r"
    ]
	notes: {very useful for creating a multi-document application interface}
]

stylize/master [
	drag-bar: face with [
		maximize: minimize: max-size: set-title: none
		feel: make feel [
			engage: func [f a e][
				if a = 'down [
					mouse-pos: e/offset
				]
				if find [over away] a [
					f/parent-face/offset: f/parent-face/offset + (e/offset - mouse-pos)
					show f/parent-face
				]
			]
		]
		resize: func [new [pair!] /local min-size /pn3s] [
			min-size: size: new
			min-size/x: min size/x size/y
			min-size/y: min-size/x
			foreach btn pane [
				if btn/type = 'btn [btn/size: min-size - 4x4]
			]
			use [ibox origin][
				ibox: pane/3/size * 0.75
				origin: (pane/3/size * 0.25) / 2
				pane/3/effect/draw: compose [
					fill-pen 255.255.255 255.255.255
					polygon (ibox * 1x0 / 4 + origin) (ibox * 2x1 / 4 + origin) (ibox * 3x0 / 4 + origin)
					(ibox * 4x1 / 4 + origin) (ibox * 3x2 / 4 + origin) (ibox * 4x3 / 4 + origin)
					(ibox * 3x4 / 4 + origin) (ibox * 2x3 / 4 + origin) (ibox * 1x4 / 4 + origin)
					(ibox * 0x3 / 4 + origin) (ibox * 1x2 / 4 + origin) (ibox * 0x1 / 4 + origin)
					(ibox * 1x0 / 4 + origin)
				]
			]
			either size/x > size/y [
				pane/3/offset: size - min-size + 2x2
				pane/2/offset: size - min-size + 2x2 - as-pair min-size/x 0
				pane/1/offset: size - min-size + 2x2 - (2 * as-pair min-size/x 0)
			][
				pane/3/offset: size - min-size + 2x2
				pane/2/offset: size - min-size + 2x2 - as-pair 0 min-size/y
				pane/1/offset: size - min-size + 2x2 - (2 * as-pair 0 min-size/y)
			]
			show self
		]
		maximize: does [
			if not parent-face/size = max-size [
				parent-face/size: max-size
				show parent-face
			]
		]
		minimize: does [
			if not parent-face/size = (size + offset)[
				if parent-face/size = as-pair 112 size/y + offset/y [exit]
				max-size: parent-face/size
				parent-face/size: size + offset
				show parent-face
			]
		]
		init: [
			pane: reduce [
				make face [
					type: 'btn
					state: off
					text: ""
					font: make font [
						size: 14
						align: 'center
						valign: 'center
						color: first colors: [255.255.255 0.0.0]
						shadow: 2x2
					]
					action: [maximize]
					edge: make edge [size: 1x1 effect: 'bevel color: 128.128.128]
					feel: rebol/view/vid/vid-feel/hot
					effect: [merge fit arrow 255.255.255 .7 rotate 180]
				]
				make face [
					type: 'btn
					state: off
					text: ""
					font: make font [
						size: 14
						align: 'center
						valign: 'center
						color: first colors: [255.255.255 0.0.0]
						shadow: 2x2
					]
					action: [minimize]
					edge: make edge [size: 1x1 effect: 'bevel color: 128.128.128]
					feel: rebol/view/vid/vid-feel/hot
					effect: [merge fit arrow 255.255.255 .7]
				]
				make face [
					type: 'btn
					state: off
					text: ""
					font: make font [
						align: 'center
						valign: 'center
						color: first colors: [255.255.255.0.0]
						shadow: 2x2
						style: 'bold
					]
					action: [quit]
					edge: make edge [size: 1x1 effect: 'bevel color: 128.128.128]
					feel: rebol/view/vid/vid-feel/hot
					effect: [merge draw []]
				]
			]
			set-title: func [t [string!] /new /local txt-img] [
				txt-img: to image! layout compose [
					origin 0x0
					backdrop (color)
					vtext (t) font (font)
				]
				either new [
					append pane get in layout compose/deep [origin 0x0 image (txt-img)] 'pane
					pane/4/feel: make feel [
						engage: func [f a e][
							if a = 'down [
								mouse-pos: e/offset
							]
							if find [over away] a [
								f/parent-face/parent-face/offset: f/parent-face/parent-face/offset + (e/offset - mouse-pos)
								show f/parent-face/parent-face
							]
						]
					]
				][
					pane/4/image: txt-img
				]
				either size/y > size/x [
					pane/4/effect: [rotate 270]
					pane/4/size/x: pane/4/image/size/y
					pane/4/size/y: pane/4/image/size/x
					pane/4/offset/x: (size/x - pane/4/size/x) / 2
					pane/4/offset/y: pane/1/offset/y - 6 - pane/4/size/y
				][
					pane/4/size: pane/4/image/size
					pane/4/offset/y: (size/y - pane/4/size/y) / 2
				]
				show pane/4
			]
			if color [
				foreach f pane [
					f/edge/color: color
				]
			]
			if size/y > size/x [
				change skip tail pane/1/effect -1 90
				append pane/2/effect [rotate 270]
			]
			resize size
			if text [set-title/new text text: none]
		]
	]
]

comment { ;Uncomment this for an example
view/options layout [
    origin 5x5
	space 5x5
    at 0x0 d: drag-bar "First Bar" 250x25 maroon font [size: 14 style: 'italic]
	across
	at 0x25 drag-bar "Second Bar" 30x500 forest
    pad 5x5 button "Change Title" [d/font/style: none d/set-title "New Title"]
	button "unview" [unview]
][no-title]

halt
}