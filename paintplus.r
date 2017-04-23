REBOL [
    Title: "Paint "
    Date: 22-May-2001/17:15:51-7:00
    Version: 1.0.0
    File: %paintplus.r
    Author: "Frank Sievertsen"
    Purpose: "The world's smallest paint program."
    library: [
        level: 'intermediate 
        platform: [all]
        type: 'tool 
        domain: [GUI] 
        tested-under: 1.3.1.3.1
        support: none 
        license: 'BSD 
        see-also: none
    ]
    Comment: {
    	17-Nov-2005
    	
    	Modified by Graham to load in a Rebol image, and a block containing draw dialected commands.
    	Thanks to Anton for suggestion on how to do the free hand draw.
    	Supports the arrow command, free hand draw, line width, and text tools.
    	Can't yet load in draw dialect with text commands.
    
    	useage: paint image [image! none!] data [block!]
    	
    	paint none [] ; brings up empty canvas
    	paint load %logo.png [] ; brings up the logo.png as the canvas
    	paint load %logo.png [[pen 0.0.0 line-width 2 fill-pen none box 147x90 191x117]] ; applies the draw to the logo
    	
    }
]

context [
	color: fill-color: start: draw-image: draw-pos: tmp: file-name: fs: fn: fontatt: fontlist: none
	line-width: 2
	type: 'box oldtype: 'box
	undos: [] redos: []
	my-text: copy "Hello there"
	select-text: does [
		view/new/title center-face layout [across
			attribute1cg: check label black "bold" 
			attribute2cg: check label black "italic" 
			attribute3cg: check label black "underline" return
			attribute1rg: radio of 'fontstyle l: label black "Sans Serif"
			attribute2rg: radio of 'fontstyle label black "Serif"
			attribute3rg: radio of 'fontstyle label black "Fixed"
			return
			text "Size" font [] fontsz: field "20" 40 [if error? try [fs: to-integer face/text] [face/text: 14 show fontsz]] return
			deftextarea: area 400x100 return
			btn "OK" [my-text: copy deftextarea/text unview
				if error? try [fs: to-integer fontsz/text] [fs: 14]
				fontatt: copy []
				fn: copy "Sans Serif"
				if attribute1cg/data [append fontatt [bold]]
				if attribute2cg/data [append fontatt [italic]]
				if attribute3cg/data [append fontatt [underline]]
				fn: copy case [
					attribute1rg/data ["Sans Serif"]
					attribute2rg/data ["Serif"]
					attribute3rg/data ["Fixed"]
					true ["Sans Serif"]
				]
				append fontlist make face/font compose/deep [style: [(fontatt)] size: (fs) name: (fn)]
	
			] pad 300 btn "Cancel" [unview]
		] "Text Requester"
	]

	draw: func [offset /local tmp bl] [
		bl: copy []
		all [
			either all [oldtype = type type = 'free-hand] [
				oldtype: type
				repend bl [start offset]
				false
			] [true]

			either all [oldtype = 'arrow type <> 'arrow] [append bl [arrow 0x0] true] [true]

			append bl compose [pen (color/color) line-width (line-width) fill-pen (fill-color/color)]

			either type = 'text [
				append bl compose [font (last fontlist) text (my-text) (offset)]
				false
			] [true]

			switch/default type [
				arrow [append bl [arrow 1x2 line]]
				free-hand [append bl [line]]
			] [append bl type]

			append bl start

			either type = 'circle [
				append bl reduce [tmp: offset - start
					to-integer square-root add tmp/x ** 2 tmp/y ** 2
				]
			] [append bl offset]
			
			if type = 'arrow [
				append bl [ arrow 0x0 ]
			]
		]
		bl
	]

	redo-draw: does [
		append/only undos draw-pos
		draw-pos: insert draw-pos last redos
		remove back tail redos
		show draw-image
	]
	undo-draw: does [
		append/only redos copy last undos
		draw-pos: clear last undos
		remove back tail undos
		show draw-image
	]
	
	set 'paint func [
		image-data [image! none!] {load a REBOL image}
		redos-data [block!] {read in draw dialect commands}
		/local ln data
	] [
		undos: copy []
		redos: copy []
		fontlist: copy []
		type: 'box
		if not empty? redos-data [
			redos: copy/deep redos-data
		]
		if none? image-data [
			image-data: to-image layout [ box 300x300 ]
		]
		view center-face lay: layout compose/deep [
			backdrop effect compose [gradient 1x1 (sky) (water)]
			across
			draw-image: image (image-data) effect [draw []]
			feel [engage: func [face action event] [
					if all [type start] [
						if find [over away] action [
							if type <> 'free-hand [clear draw-pos]
							append draw-pos draw event/offset
							if type = 'free-hand [start: event/offset]
							show face
						]
						if action = 'up [
							append/only undos draw-pos
							draw-pos: tail draw-pos
							start: none
							oldtype: type
						]
					]
					if all [type action = 'down] [
						start: event/offset
					]
				]]
			do [if error? try [
					draw-pos: draw-image/effect/draw
					while [not empty? redos] [redo-draw]
				] [
					alert "Error in image data - discarded"
				]
			]
			guide
			style text text [
				tmp: first back find face/parent-face/pane face
				tmp/feel/engage tmp 'down none
				tmp/feel/engage tmp 'up none
			]
			label "Tool:" return
			radio [type: 'line] text "Line" font []
			mark: at
			return
			radio [type: 'free-hand] text "Free" font []
			return
			radio true [type: 'box] on text "Box" font []
			return
			radio [type: 'circle] text "Circle" font []
			return
			radio [type: 'arrow] text "Arrow" font []
			return
			radio [type: 'text select-text] text "Text" font []
			return
			button "Undo" [if not empty? undos [
					undo-draw
				]]
			return
			button "Clear" [
				while [not empty? undos] [undo-draw]
				oldtype: none
			] return
			button "Redo" [if not empty? redos [
					redo-draw
				]] return
			button "Save" [
				if r: request-file [
					save/all r/1 undos
				]
			]
			return
			button "Print" [save/png %picture.png to-image draw-image

				write %picture.html {<html>^/<body>^/<IMG SRC="picture.png">^/</body>^/</html>}
				browse %picture.html
			]
			return
			button "Dump" [
				print "undos" probe undos
			]
			at mark
			guide
			style color-box box 15x15 [
				oldtype: none
				face/color: either face/color [request-color/color face/color] [request-color]
				; face/color: request-color
			] ibevel
			color: color-box 0.0.0 text "Pen"
			return
			fill-color: color-box text "Fill-pen"
			return
			widthfld: field "2" 20 [oldtype: none if error? try [line-width: to-integer face/text] [face/text: line-width: 2 show face]] label "Width"
		]

	]
]
