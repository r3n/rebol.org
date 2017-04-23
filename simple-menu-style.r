REBOL [
	title: "Menu style example"
	file: %simple-menu-style.r
	author: "Marco Antoniazzi directly derived from Nick Antonaccio"
	email: [luce80 AT libero DOT it]
	date: 30-10-2010
	version: 0.0.1
	Purpose: {A quick way to add a simple menu to VID GUIs}
	comment: {You are strongly encouraged to post an enhanced version of this script}
	Category: [util vid view]
	library: [
		level: 'beginner
		platform: 'all
		type: 'how-to
		domain: [gui vid]
		tested-under: [View 2.7.6.3.1]
		support: none
		license: none
		see-also: %choice-button-menu-example.r
	]
]

menu-Options: [
    "Open File..." [attempt [a1/text: read request-file/only show a1]]
    "Copy to Clipboard" [do-face b1 1]
    "Paste from Clipboard" [a1/text: read clipboard:// show a1]
    "______________________^/" []
    "About..." [alert "This menu is just a choice button widget :)"]
    "______________________^/" []
    "Halt" [halt]
    "Quit" [quit]
]
menu-Help: [
    "About..." [alert "This menu is just a choice button widget :)"]
]

menu-color: 235.240.245
view center-face layout [
    size 440x250 
    origin 0x0  space 0x0 backdrop 253.253.253 across
    ;box menu-color 8x20
    style menu-list choice left menu-color 1x20 with [
        para: [indent: 6x0 origin: 0x0 margin: 0x0]
        font: [style: none  shadow: none  colors: [black 5.5.255]]
        colors: reduce [menu-color menu-color - 20]
		edge: none
    ] feel [
        engage: func [face action event][
            if (action = 'down) or (action = 'up) [
                choose/style/window/offset extract face/menu 2 func [face parent][
                    parent/data: find parent/texts face/text
                    do-face parent parent/text: face/text
                ] face face/parent-face (face/offset + (face/size/y * 0x1))
            ]
        ]
    ][do select face/menu value  face/text: face/texts/1  show face]
    m1: menu-list "Options" 170 with [menu: menu-Options]
	pad (size-text m1) + 10 - m1/size * 1x0
    m2: menu-list "Help" 100 with [menu: menu-Help]
    box menu-color 2000x20
	origin 20x40  space 20x20  below
    a1: area wrap with [colors: [254.254.254 248.248.248]]
    b1: btn "Submit" [write clipboard:// a1/text alert "Copied"]
]
