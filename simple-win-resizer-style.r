REBOL [
	title: "window resizer style example"
	file: %simple-win-resizer-style.r
	author: "Marco Antoniazzi"
	email: [luce80 AT libero DOT it]
	date: 28-03-2011
	version: 0.1.0
	Purpose: {A quick way to add a simple window resizer to VID GUIs}
	comment: {Inspired by smallnote.r of Alain Goyé. 
		Drag the gadget in the bottom-right corner to resize the window.
		You are strongly encouraged to post an enhanced version of this script}
	History: [
		0.1.0 [28-03-2011 "First version"]
		0.2.0 [01-05-2011 "Minor source retouches"]
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
	]
]

stylize/master [
	win-resizer: box 21x21 edge [size: 1x1 effect: 'ibevel color: 128.128.128.50]
		effect [
			draw [
				line-width 1
				pen 255.255.255.50 line 3x20 20x3 line 8x20 20x7 line 12x20 20x12
				pen 128.128.128.50 line 4x20 20x4 line 9x20 20x9 line 14x20 20x14
			]
		]
		feel [
			engage: func [face action event /local root-face] [
				if flag-face? face disabled [exit]
				if action = 'down [face/data: event/offset] 
				if action = 'up [face/data: none] 
				if all [face/data find [over away] action] [
					face/offset: max (face/user-data + 0x4) face/offset + event/offset - face/data
					root-face: find-window face
					root-face/size: face/offset + face/size
					show root-face
				]
			]
		]
]

win: layout [
	here: at sizer: win-resizer at here
	the-area: area 150x150 System/script/header/comment wrap on
]

; put sizer on window's bottom-right corner and keep it there
sizer/user-data: sizer/offset: win/size - sizer/size 
; store the win size
win/user-data: win/size

; put this function after layout because resize and maximize are not passed to faces feel.
win/feel: make win/feel [
	detect: func [face event] [
		switch event/type [
			resize [
				sizer/offset: face/size - sizer/size show sizer
				; the check is done because there are utilities that automatically expand the window (but do not trigger an maximize event)
				; 62 is correct for Win7, but probably it is not for other versions
				either face/size <> (System/view/screen-face/size - 0x62) [deflag-face sizer disabled][flag-face sizer disabled]
				
				the-area/size: the-area/size + face/size - face/user-data
				face/user-data: face/size          ; store new size
				show the-area
			]
			maximize [
				deflag-face sizer disabled ; this shouldn't be necessary!
				flag-face sizer disabled
			]
		]
		event
	]
]

view/options win compose [resize min-size (win/size + 16x38)] ;16x38 is window's border size in win7
