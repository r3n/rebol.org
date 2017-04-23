REBOL [
	Title: "Rich Text Format style"
	Date: 27-07-2013
	Version: 0.0.4
	File: %simple-rich-text-style.r
	Author: "Marco Antoniazzi"
	Rights: "Copyright (C) 2013 Marco Antoniazzi"
	Purpose: {A quick way to add simple rich-text to VID GUIs}
	comment: {You are strongly encouraged to post an enhanced version of this script}
	eMail: [luce80 AT libero DOT it]
	History: [
		0.0.1 [13-07-2013 "Started"]
		0.0.2 [14-07-2013 "Working parsing and drawing"]
		0.0.3 [17-07-2013 "Variuos fixes"]
		0.0.4 [27-07-2013 "Variuos fixes"]
	]
	Category: [text vid gfx]
	library: [
		level: 'intermediate
		platform: 'all
		type: 'function
		domain: [gui text]
		tested-under: [View 2.7.8.3.1]
		support: none
		license: 'PD
		see-also: none
	]
	Notes: {This is a very simple implementation. Format is similar to RTF.
		"\b" starts or stops bold (acts as a switch)
		"\i" starts or stops italic (acts as a switch)
		"\u" starts or stops underline (acts as a switch)
		"\cf(<tuple>)" starts coloring text with color <tuple>
		"\cb(<tuple>)" starts coloring background of text with color <tuple>
		"\cn" reset color to default
		"\n" reset all to default
		
		Currently unimplemented Font facets: space/x, shadow
		Currently implemented Para facets: origin, scroll

		Algorithm:
		translate a text such as:
			test: {Nel mezzo del \bcammin\b di nostra vita
			mi \i\uritrovai\u\i \cf(0.0.255)in una \b\uselva oscura\u\b
			che \cb(255.255.0)la diritta via\n era smarrita
			}
		to a block
			test-block: [
			[[[] none 0.0.0 none] "Nel mezzo del " [[bold] none 0.0.0 none] "cammin" [[] none 0.0.0 none] " di nostra vita"]
			[[[] none black none] "mi " [[italic underline] 255.0.0 0.0.0 none] "ritrovai" [[] none 0.0.255 none] " in una " [[bold underline] 255.255.0 0.0.0 none] "selva oscura"]
			]
		and draw using AGG to the face's effect/draw
	}
	Todo: { implement all font and para facets}
]

rich-text-ctx: context [
	set 'rich-text-style stylize/master [
		rich-text: base-text with [
			effect: [draw []]
			colors: reduce [none none]
			font/colors: reduce [font/color none]

			draw-block: copy []
			min-size: -1x-1
			line-height: none
			rtf: none
			highlight-pen: none
			cursor-pen: green + 20
			cursor-pos: 0x0
			cursor-size: 2x10
			pen-pos: 0x0
			feel: make face/feel [
				redraw: func [face action position] [;probe action
					if action = 'show [
						face/draw_rich-text
					]
				]
			]
			; parse_rich-text
				rtf-rules: context [
					var: color: none
					dest: copy []
					clear-prop: []
					prop: copy [] ;
					emit: func [value][insert tail dest any [value ""]]
					emit-prop: func [][insert/only tail dest copy/deep prop]
					txt: [copy var to "\" (emit var)]
					comm: [
					   "\cu" (prop/4: 1 emit-prop prop/4: none emit "") 
					 | "\t" (prop/4: 2 emit-prop prop/4: none emit "") ; tab
					 | "\b" (alter prop/1 'bold)
					 | "\i" (alter prop/1 'italic)
					 | "\u" (alter prop/1 'underline)
					 | "\n" (prop: copy clear-prop)
					 | "\cn" (prop/2: clear-prop/2 prop/3: clear-prop/3) 
					 | "\cf(" copy color to ")" skip (prop/3: any [attempt [to tuple! color] 0.0.0])
					 | "\cb(" copy color to ")" skip (prop/2: any [attempt [to tuple! color] 255.255.255])
					 | "\\" (emit-prop emit "\")
					 | "\" (emit-prop emit "\")
					]
					comms: [some comm (emit-prop)]
					last-txt: [copy var to end (emit var)]
					rtf: [any [comms | txt] last-txt]
				]
				parse_rich-text: func [text [string!] /local line] [
					if empty? text [text: " "]
					line: copy text
					replace/all line "^-" "\t"
					data: parse/all copy line "^/"
					rtf-rules/clear-prop: reduce [[] font/colors/2 font/colors/1 none]
					rtf-rules/prop: reduce [[] font/colors/2 font/colors/1 none]
					clear rtf-rules/clear-prop/1 ; clear static dirty blocks
					clear rtf-rules/prop/1 ; 
					until  [
						line: first data
						insert/only rtf-rules/dest copy/deep rtf-rules/prop ; continue with previous line settings
						parse/all line rtf-rules/rtf
						if block? rtf-rules/dest/2 [remove rtf-rules/dest]
						change/only data copy rtf-rules/dest
						clear rtf-rules/dest
						data: next data
						tail? data
					]
					data: head data
				]
			;
		
			set-font: func [styl [word! block!] size [integer!] /local font] [
				if styl = 'normal [styl: []]
				size-text-face/font/style: compose [(styl)]
				size-text-face/font/size: max size 2
			]
			; low-level draw
				draw-text: func [text [string!] dim [pair!] tab /local pos] [
					pos: pen-pos
					if tab [dim/x: tab] ; FIXME: wrong calc
					if highlight-pen [insert tail draw-block compose [pen none fill-pen (highlight-pen) box (pos) (pos + dim)]]
					if none? tab [insert tail draw-block compose [pen (font/color) fill-pen none font (make font []) text anti-aliased (pos) (text)]]
					pen-pos/x: pen-pos/x + dim/x ; advance pen ("cursor") position
				]
			;
			; draw_rich-text
				aligns: [left 0 center 1 right 2 top 0 middle 1 bottom 2]
				draw_rich-text: func [/no-draw /local start-data tot-dim alignment edge-size-x xj line-width line-gap text-dim pos curry cursor] [
					if all [none? text none? data] [exit]
					if text [
						rtf: copy any [text ""]
						text: none
						clear data
						parse_rich-text rtf
						size-text-face/font/name: font/name
						if min-size <> -1x-1 [min-size: (self/draw_rich-text/no-draw) + (edge-size? self) + (any [all [para (para/origin * 2)] 0x0])]
					]
					start-data: data
					tot-dim: 0x0
					curry: 0
					edge-size-x: (any [all [edge edge/size edge/size/x] 0]) + any [all [para para/origin/x] 0]
					line-gap: pick to pair! font/space 2
					xj: 0
					alignment: aligns/(font/align)
					; calc line height once
						set-font [bold] font/size
						line-height: second size?-text ""
						set-font [bold italic] font/size
						line-height: max line-height second size?-text ""
					if none? no-draw [
						clear draw-block
						; calc vertical alignment
						curry: size/y - min-size/y - 2 / 2 * aligns/(font/valign)
						curry: curry + para/scroll/y + para/origin/y 
						; skip out of sight lines
						if curry < 0 [
							pos: to integer! (abs curry) / (line-height + line-gap)
							start-data: at data pos + 1
							curry: curry + ((line-height + line-gap) * pos)
						]
					]
					; calc each line length, align it and draw it
					foreach line start-data [
						if all [none? no-draw curry > size/y] [break] ; skip out of sight lines
						; calc total line length
							line: head line
							line-width: 0
							forskip line 2 [
								if none? line/2 [line/2: ""]
								set-font line/1/1 font/size
								; calc and also cache piece dimensions
								text-dim: size?-text line/2
								insert tail line/1 as-pair text-dim/x line-height
								line-width: line-width + text-dim/x 
								tot-dim/x: max tot-dim/x line-width
							]
						if none? no-draw [
							; justify
								; general formula to get start position given type of justification
								xj: size/x - edge-size-x - edge-size-x - line-width / 2 * alignment
							; draw text
								pen-pos: as-pair xj + para/origin/x + para/scroll/x curry
								line: head line
								forskip line 2 [
									font/color: line/1/3
									styl: line/1/1
									if styl = 'normal [styl: []]
									font/style: compose [(styl)]
									highlight-pen: line/1/2
									draw-text line/2 last line/1 all [line/1/4 para/tabs]
								]
						]
						curry: curry + line-height + line-gap
					]
					
					tot-dim/y: curry - line-gap
					effect/draw: draw-block
					tot-dim 
				]
			;
			init: [;probe 'init
				change font/colors font/color
				min-size: (draw_rich-text/no-draw) + (edge-size? self) + (any [all [para (para/origin * 2)] 0x0])
				if size/x < 0 [size/x: min-size/x]
				if size/y < 0 [size/y: min-size/y]
				size: min size (system/view/screen-face/size - 100x100)
			]
		]
	]
	; font functions
		size-text-face: make face [
			edge: none para: none feel: none
			font: make font [align: 'left valign: 'top shadow: none name: font-sans-serif style: []]
		]
		size?-text: func [text [string!] /local result] [
			size-text-face/text: head insert tail copy text join "^/" text
			; caret-to-offset is more precise in calculating width (not for an italic font)
			result: caret-to-offset size-text-face tail size-text-face/text
			; since caret-to-offset (nor size-text) does NOT give good results we try to improve them
			result/x: result/x + either find size-text-face/font/style 'italic [size-text-face/font/size / 8][0]
			result/y: result/y + (result/y - size-text-face/font/size / 2)
			result
		]
] ; rich-text-ctx

do ; just comment this line to avoid executing examples
[; example code
	test: trim/with {The \u\iquick\i\u \cf(139.69.19)brown\cn \bFOX\b
		\cb(55.0.250)\cf(139.169.19)jumps\n over
		the \cb(255.255.0)lazy\n dog
	} #"^-"

	main-win: layout [ ; big spaces and edge only for testing purposes
		do [sp: 40x40] origin sp space sp 
		rt: rich-text (test) -1x150 center middle red orange font [size: 20 name: font-serif space: 0x10] edge [size: 20x10 effect: 'bevel color: yellow]
		btn "Hello" [set-face rt "Hello"]
	]

	view/title/options center-face main-win "Rich-Text" [resize]
]