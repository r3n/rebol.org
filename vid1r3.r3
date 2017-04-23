REBOL [
	title: "VID1 for R3"
	file: %vid1r3.r3
	author: "Marco Antoniazzi"
	Copyright: none
	email: [luce80 AT libero DOT it]
	date: 06-04-2016
	version: 0.3.15
	Purpose: "Lets you use VID1 with R3"
	History: [
		0.0.1 [14-08-2013 "Started"]
		0.0.2 [17-08-2013 "Working view,unview,gobs_to_face"] 0.0.3 [17-08-2013 "Added make_edge-polygon-block"]
		0.0.4 [18-08-2013 "Fixed view, gobs_to_face, added gobclipper"] 0.0.5 [21-08-2013 "mimic-do-event"]
		0.0.6 [23-08-2013 "show,update_gobs,to-r3-draw-block"] 0.0.7 [23-08-2013 "VID starts and renders"]
		0.0.8 [24-08-2013 "Fixes, images stock"] 0.0.9 [29-08-2013 "Fixed over and engage"]
		0.0.10 [30-08-2013 "Fixed system/view/metric and images alpha channel for new R3"] 0.0.11 [31-08-2013 "Fixed show screen"]
		0.0.12 [01-09-2013 "Fixed show win, show block, draw text, change image"] 0.0.13 [08-09-2013 "Iterated faces"]
		0.1.0 [10-09-2013 "Improved show, iterated faces"] 0.1.1 [14-09-2013 "Added some alg.shapes, gradient"]
		0.2.1 [21-09-2013 "Added image effects"] 0.2.2 [22-09-2013 "Fixed oval, btn text origin"]
		0.2.3 [28-09-2013 "Fixed text field, text-list"] 0.2.4 [29-09-2013 "Added request-file, started timers"]
		0.2.5 [10-10-2013 "Fixed engage"] 0.3.0 [10-10-2013 "Added timers"]
		0.3.1 [13-10-2013 "Added rgb-to-hsv-to-rgb, various fixes and new natives"]
		0.3.2 [18-10-2013 "Fixed do-events for pop-ups, engage for iterated faces, new natives"]
		0.3.3 [22-10-2013 "Fixed text-list/resize, minor fixes and additions"] 0.3.4 [27-10-2013 "Fixed show win"]
		0.3.5 [29-10-2013 "Added poke native, fixes in draw effect"] 0.3.6 [02-11-2013 "Fixed feel of iterated faces, Added image effects"]
		0.3.7 [10-11-2013 "Added contrast, fixed window title, rate, size-text, pop-ups"] 0.3.8 [17-11-2013 "Added blur, fixed pop-ups"]
		0.3.9 [23-11-2013 "MAJOR PATCH: changed face/action to be a block instead of function, hence patched do-face"]
		0.3.10 [16-12-2013 "Minor speed up of ctx-image-effects funcs"] 0.3.11 [23-02-2014 "Fixed text-list for r3-view_3.0.0.3.3"]
		0.3.12 [20-04-2014 "Changed events timing (for less CPU usage)"] 0.3.13 [01-03-2015 "patched field init, added calling show func in make_gobs_from_face"]
		0.3.14 [31-03-2016 "Fixed event? function, avoid calling screen-face/feel/detect for time events"]
		0.3.15 [06-04-2016 "avoid re-doing script, do gfx-colors.r, added base-effect, patched request-download, partially fixed infinite loop in resizing"]
	]
	library: [
		level: 'advanced
		platform: 'windows
		type: 'module
		domain: [sdk gui vid]
		tested-under: [Saphir-View 2.101.0.3.1 Atronix-View 3.0.0.3.3]
		support: none
		license: {For me (luce80) it is PD, for REBOL Technologies perhaps Apache 2.0 but see original header below}
		see-also: none
	]
	Notes: {
		This is a quite complex script and I desperatly need your help as bug hunters but mainly also
		to "fill in the gaps" since there are a lot of things to add and try.
		Please help me by sending me an email or posting your additions and enhancements on AltMe.
		
		To be able to use this script you must have the Rebol SDK http://www.rebol.net/builds/#section-2
		and change the sdk-dir variable below.
		(If you want to stop dumping events go to ;view-funcs/view/; Window handler/handle-events/handler.)
		If you want to stop dumping events go to ;view-object/system/view/wake-event.

		Why have I done it? Because:
		This script creates gobs from view1 faces. This means that with it you can use
		VID but also RebGUI, Glass, VIDEK.
		VID1 is NOT a very good gui system but it was the default one for R2 and with this script
		you can simplify adaptation of old scripts to R3.
		VID1 is NOT a very good gui system but it IS a good starting point and I am trying to be
		compatible with VID3 so you can choose which one to use.
		
		As of v.0.3.1 I have reached a good degree of compatibility but it is becoming increasingly difficult
		to add features and correct bugs, especially those regarding "bindological" problems. Please help me.
		
		R3 cannot always be patched to behave like R2 so I cannot patch all things. There are also some things
		(mostly natives and functions) that I'm not sure if it is worth it to patch them.
		This means that you will probably need to modify your script to make it R3 compatible but, I hope, only
		a few things.
		
		WARNING: as of v.0.3.9 I have made a MAJOR PATCH changing face/action from function! to block! of the type: [spec body]
		so be very careful !!

		Tested on:
		simple-tooltip-style.r : works with no changes
		vert-horiz-panels.r : works with minor changes (must change "second :action ..." (not supported by R3))
		visual-sorting.r : works with minor changes (throw does not support "empty" argument)
		parse-aid.r : works with minor changes (for decompress and do that do not support strings) , visualize
		  does not work because of pick not supporting reflection (for objects)
		files-renamer.r : works with minor changes (only minor glitches and enlarge text to account for different text size)
		treelist.r : works with no changes
		vid-build.r : works with minor changes
		file-requester.r : works with minor changes
		
		P.S. my never ending gratitude goes to Anton Rolls that created most of the code below. Without his code
		I would never have done this script.
	}
	original-header: [
	Title:  "REBOL/View: Object and Core Functions"
	Version: 2.7.6
	Rights: "Copyright REBOL Technologies 2008. All rights reserved."
	Home: http://www.rebol.com
	Date: 14-Mar-2008

	; You are free to use, modify, and distribute this file as long as the
	; above header, copyright, and this entire comment remains intact.
	; This software is provided "as is" without warranties of any kind.
	; In no event shall REBOL Technologies or source contributors be liable
	; for any damages of any kind, even if advised of the possibility of such
	; damage. See license for more information.

	; Please help us to improve this software by contributing changes and
	; fixes. See http://www.rebol.com/support.html for details.
	]
]

if system/version < 2.101.0 [do make error! "Rebol version 2.101 or later needed"]
if value? 'mimic-do-event [exit] ; avoid re-doing script

;**************

sdk-dir: switch/default system/script/args [
	#[none] "" [%../../sdk-2706031/rebol-sdk-276/source]  ;;;;;<<<<<<------ CHANGE THIS TO THE CORRECT PATH
] [system/script/args]

;**************
draw-mod: import 'draw

; natives (R3-backward)
	foreach word [
		all show size-text offset-to-caret caret-to-offset to-integer second request-file draw
		to-word shift wait to-string pick event? third poke
		][
		set load join 'native- word get word
	]
	show: func [
		"Display a face or block of faces." 
		face [object! block!]
		/local faces subface subgob len win
		][
		faces: compose [(reduce face)]
		while [not tail? faces][
			either all[
				object? face: pick faces 1
				in face 'type
				face/type = 'face
				][
				if not face/show? [face/show?: true]
				case [
					find system/view/screen-face/pane face [ ; a window?
								;print ["face show win " face/data/text length? face/gob/data/gob-clipper length? face/pane len]
						{len: either object? face/pane [1][length? face/pane]
						switch probe (sign? (length? face/gob/data/gob-clipper) - len) [
							1 [ ; face removed
								subgob: face/gob/data/gob-clipper
								while [not tail? subgob] [
									if not find face/pane subgob/1/data/gob-face [
										remove subgob
									]
									subgob: next subgob
								]
								face/gob/data/gob-clipper: head subgob
							]
							-1 [ ; face added ; FIXME: while [not tail?  ...
								subface: make_gobs_from_face either object? face/pane [face/pane][last face/pane] ; calling also feel/redraw 'draw
								subface/parent-face: face 
								append face/gob/data/gob-clipper subface/gob
							]
							0 [ ; face changed
								face: update_gobs_from_face face
							]
						]
						native-show face/gob}
						;print ["face changed " face/gob/text face/gob/parent/text face/gob/parent/offset face/gob/parent/size face/offset face/size]
						; FIXME: this is VERY slow !
						win: face/gob/parent
						win/size: face/size
						clear win ; FIXME: does this clear all gobs?
						face/text: "" ; reset this
						subface: make_gobs_from_face face ; calling also feel/redraw 'draw ; FIXME: should be 'show
						subface/gob/offset: 0x0 ; reset this
						append win subface/gob
						native-show win
						face/size: win/size
					]
					any [face/face-flags = 'screen face = system/view/screen-face] [ ; the screen ?
						either (length? system/view/screen-gob) > length? system/view/screen-face/pane [
							; unview window
							while [not tail? system/view/screen-gob] [
								subgob: first system/view/screen-gob
								if not find system/view/screen-face/pane subgob/data/gob-face [
									remove system/view/screen-gob
								]
								system/view/screen-gob: next system/view/screen-gob
							]
							system/view/screen-gob: head system/view/screen-gob
							native-show system/view/screen-gob
						][
							while [not tail? system/view/screen-face/pane] [
								subface: first system/view/screen-face/pane
								if none? subface/gob [
									break
								]
								system/view/screen-face/pane: next system/view/screen-face/pane
							]
							system/view/screen-face/pane: head system/view/screen-face/pane

							ctx-do-event/target-engage: ; reset these (especially to avoid using old iterator faces)
							ctx-do-event/target-down:
							ctx-do-event/target-down-engage: none
							ctx-do-event/storeindex: 0
							if ctx-do-event/pop-ups = 1 [ctx-do-event/pop-ups: 0 ] ; pop-up closed
							view/new subface
							remove back tail system/view/screen-face/pane ; view already appended it
						]
						
					]
					all [face/parent-face function? get in face/parent-face 'pane] [ ; an iterated face ?
						call-iters/with face/parent-face face/parent-face/gob/data/iter-image ctx-do-event/currindex + 1 ; FIXME: + 1 ?
						native-show face/parent-face/gob
					]
					'else [
						; FIXME: if window's face not opened then skip
						face: update_gobs_from_face face ; calling also feel/redraw 'show
						native-show face/gob
						if all [face/parent-face face/parent-face/parent-face function? get in face/parent-face/parent-face 'pane] [show face/parent-face]
					]
				]
			][
				do make error! "Invalid graphics face object"
			]
			faces: next faces
		]
		; FIXME: recursively call feel/redraw 'draw of overlapped faces (as in R2 but is it useful? (perhaps for iterated faces?))
		; FIXME: account for window/changes
		;exit ; return unset!
		face ; FIXME: better return face ?
	]
	{hide: func [ ; FIXME: TBD
	    "Hides a face or block of faces." 
	    face [object! block!] 
	    /show "Refreshes the area under the face being hidden."
		/local faces
		][
		faces: compose [(face)]
		while [not tail? faces][
			if object? face: pick faces 1 [
				face/show?: false
				face: update_gobs_from_face face
				native-show face/gob
			]
			faces: next faces
		]
	]}
	draw: func [
		{Draws scalable vector graphics to an image (returned).} 
		image [image! pair!] "Image or size of image" 
		commands [block!] "Draw commands"
		][
		native-draw image to-r3-draw-block commands
	]
	size-text: func [
		"Returns the size of the text in a face or graphics object." 
		face [object! gob!]
		/local size face-size gob text
		][
		size: 1x1 text: copy face/text
		if text = "" [text: " " size: 0x1]
		if object? face [
			;gob: attempt [face/gob/data/gob-text] ; this could be outdated
			;if none? gob [
				face-size: face/size
				gob: make gob! [size: face-size text: text]
				gob/text: reduce ['text text]
				insert insert gob/text 'para either face/para [face/para][make system/standard/para []]
				if face/font [insert insert gob/text 'font face/font]
				gob/text: bind gob/text import 'text
			;]
		]
		size * native-size-text gob
	]
	offset-to-caret: func [
		{Returns the offset in the face's text corresponding to the offset pair.} 
		face [object! gob!] "The face containing the text." 
		offset [pair!] "The XY offset relative to the face."
		][
		if object? face [face: any [attempt [face/gob/data/gob-text] make gob! [size: 1000x1000 text: face/text]]]
		first native-offset-to-caret face offset
	]
	caret-to-offset: func [
		{Returns the offset position relative to the face of the character position.} 
		face [object! gob!] "The face containing the text." 
		offset [any-string!] "The offset in the text."
		/local element
		][
		if object? face [face: any [attempt [face/gob/data/gob-text] make gob! [size: 1000x1000 text: face/text]]]
		element: back tail face/text
		native-caret-to-offset face element offset
	]
	to-integer: func [value][to integer! any [:value 0]]
	to-word: func [value][either string? :value [any [attempt [get bind value: to word! :value self] value]][to word! :value]]
	to-string: func [value][either set-word? :value [to string! to-word :value][to string! :value]]
	comment [;lib/to: func [ ; FIXME: too late to patch this ? (also not worth it ?)
		{Converts to a specified datatype.} 
		type [any-type!] "The datatype or example value." 
		spec [any-type!] "The attributes of the new value."
		][
		if type = integer! [return native-to integer! any [:spec 0]]
		native-to type spec
	]
	pick: func [
		{Returns the value at the specified position in a series.} 
		series [series! map! gob! pair! date! time! tuple! bitset! port! object!] ;R2 is series! pair! event! money! date! time! object! port! tuple! any-function!
		index [number! logic! pair!]
		/local result
		][
		if all [series? series index == 0] [return none]
		if all [integer? index index < 0] [index: index + 1]
		result: native-pick series index
		if all [block? series logic? index] [return either all [value? result any-function? get result] [get result][result]]
		result
	]
	poke: func [
		"Replaces an element at a given position."
		series [series! port! map! gob! bitset! tuple!] "(modified)"
		index {Index offset, symbol, or other value to use as index}
		value [any-type!] "The new value (returned)"
		][
		if tuple? series [series/(index): value return series]
		native-poke series index value
	]
	second: func [
		"Returns the second value of a series." 
		series [series! pair! event! money! date! object! port! time! tuple! any-function! struct! event!]
		][
		if function? :series [return bind body-of :series self]
		if object? :series [return append load mold :series values-of :series]
		native-second series
	]
	third: func [
		"Returns the third value of a series." 
		series [series! date! port! time! tuple! any-function! struct! event! object!]
		][
		if object? :series [series: body-of :series forall series [if word? series/1 [change series to-lit-word series/1]] return head series]
		native-third series
	]
	shift: func [
		{Perform a bit shift operation. Right shift (decreasing) by default.} 
		data [integer! binary!] 
		bits [integer!] "Number of bits to shift" 
		/left "Shift bits to the left (increasing)" 
		/logical "Use logical shift (unsigned, fill with zero)" 
		/part "Shift only part of a series. (Unimplemented for R3)" 
		length [integer!]
		][
		data: to integer! data
		bits: negate bits
		if left [bits: negate bits]
		either logical [native-shift/logical data bits][native-shift data bits]
	]
	wait: func [
		"Waits for a duration, port, or both." 
		value [number! time! port! block! none!] 
		/all "Returns all events in a block"
		][
		if any [value = 0.0 value = 0:0] [value: 0.001] ; wait none is "do not wait" but wait 0 is "wait as little as we can"
		if system/view/screen-gob/1 [insert system/ports/system make event! [type: 'time gob: system/view/screen-gob/1]]
		either all [native-wait/all value][native-wait value]
	]
	event?: func ["Returns TRUE for event values."
		value [any-type!]
		][
		any [
			native-event? value
			all [block? value found? find value [block-type mimic-do-event-event]]
		]
	]
	; I am not able to patch these natives:
		; to, decompress, do, throw
; mezz-gfx
	rgb-to-hsv: func [
		"Converts RGB value to HSV (hue, saturation, value)" 
		rgb [tuple!]
		/local r g b minRGB maxRGB delta h s v
		][
		r: rgb/1 / 255
		g: rgb/2 / 255
		b: rgb/3 / 255
		minRGB: min min r g b
		maxRGB: max max r g b
		v: to-integer maxRGB * 255			; v
		delta: maxRGB - minRGB
		if delta = 0 [return v * 0.0.1]
		s: to-integer delta / maxRGB * 255 	; s
		h: case [
			maxRGB = r [g - b / delta]		; between yellow & magenta
			maxRGB = g [b - r / delta + 2]	; between cyan & yellow
			maxRGB = b [r - g / delta + 4]	; between magenta & cyan
		]
		h: h * 60
		if h < 0 [h: h + 360]
		h: to-integer h / 360 * 255			; h
		to-tuple reduce [h s v]
	]
	hsv-to-rgb: func [
		"Converts HSV (hue, saturation, value) to RGB" 
		hsv [tuple!]
		/local h s v chroma hdash x minRGB r g b
		][
		if hsv/2 = 0 [
			; achromatic grey
			return hsv/3 * 1.1.1
		]
		h: hsv/1 / 255 * 360
		s: hsv/2 / 255
		v: hsv/3 / 255

		chroma: s * v
		hdash: h / 60.0
		x: chroma * (1.0 - abs ((mod hdash 2.0) - 1.0))

		switch to-integer hdash [
			0 [r: chroma g: x b: 0]
			1 [r: x g: chroma b: 0]
			2 [r: 0 g: chroma b: x]
			3 [r: 0 g: x b: chroma]
			4 [r: x g: 0 b: chroma]
			5 6 [r: chroma g: 0 b: x]
		]

		minRGB: v - chroma

		r: to-integer r + minRGB * 255
		g: to-integer g + minRGB * 255
		b: to-integer b + minRGB * 255
		to-tuple reduce [r g b]
	]
; mezz-file
	delete-dir: func [
		"Deletes a directory including all files and subdirectories."
		dir [file! url!] 
		/local files
		][
		if all [
			dir? dir 
			dir: dirize dir 
			attempt [files: load dir]
		] [
			foreach file files [delete-dir dir/:file]
		] 
		attempt [delete dir]
	]

; mezz-flow
	throw-on-error: func [
		{Evaluates a block, which if it results in an error, throws that error.} 
		[throw] 
		blk [block!]
		][
		if error? set/any 'blk try blk [throw blk] 
		get/any 'blk
	]
	; these are useful inside structured blocks
	comment-first: ignore-this: func [a b][:b]
	comment-second: ignore-next: func [a b][:a] ; same as "also"
	launch: make function! [[
		{Runs a script as a separate process; return immediately.}
		script [file! string! none!] "The name of the script"
		/args arg [string! block! none!] "Arguments to the script"
		/wait "Wait for the process to terminate"
		/quit
		/local exe
		][
		if file? script [script: to-local-file clean-path script]
		exe: to-local-file system/options/boot
		args: to-string reduce [{"} exe {" "} script {" }]
		if arg [append args arg]
		if quit [lib/quit] ; only for compatibility, place this here instead of in next line to avoid infinite loop
		either wait [call/wait args] [call args]
	]]
; mezz-debug
	disarm: func [
		"Returns the error value as an object." 
		error [error!]
		/local body
		][
		;body: body-of error
		;body/type: to lit-word! body/type
		;body/id: to lit-word! body/id
		;if word? body/arg1 [body/arg1: to lit-word! body/arg1]
		;make object! body
		:error
	]
	form-error: func [
		"Forms an error message"
		errobj [error!] "Error object" ;"Disarmed error"
		/local errtype text arg1 arg2 arg3
		][
		errtype: get in system/catalog/errors errobj/type
		arg1: errobj/arg1
		arg2: errobj/arg2
		arg3: errobj/arg3
		text: get in errtype errobj/id
		if block? text [text: reform bind/copy text 'arg1]
		rejoin [
			"** " errtype/type ": " text newline
			"** Where: " errobj/where newline
			"** Near: " mold/only errobj/near newline
		]
	]
	probe-obj: func [obj [object!]] [print form dump-obj obj :obj]
; mezz-utils
	to-itime: func [
		{Returns a standard internet time string (two digits for each segment)} 
		time [time! number! block! none!] 
		][ ; MUCH faster version than original for R2
		time: make time! time 
		time: form to time! to integer! time ; strip micros
		if 2 = index? find time ":" [insert time "0"]
		if 5 = length? time [insert tail time ":00"] ; not necessary for R3 ?
		head time
	]
;
; gfx-funcs ; make_gobs_from_face
	ctx-image-effects: context [
	colorize: func [image [image!] color [tuple!] depth [integer!]
		/local pos pixel ratio-r ratio-g ratio-b color-r color-g color-b
		][
		ratio-r: color/1 / 255
		ratio-g: color/2 / 255
		ratio-b: color/3 / 255
		depth: min max 0 depth 255
		depth: depth / 255
		repeat pos image [
			; convert to grayscale
			pixel: first pos
			;pixel: (pixel/1 * 30) + (pixel/2 * 59) + (pixel/3 * 11) / 100 ;* 1.1 ; * 1.1 to "enhance" the effect
			pixel: pixel/1 + pixel/2 + pixel/3 / 3 ; simpler non perceptive version
			; colorize
			color-r: pixel * ratio-r color-g: pixel * ratio-g color-b: pixel * ratio-b
			; linerly interpolate from gray to color using depth
			pixel: (1.0 - depth) * pixel
			color: (pixel + (depth * color-r) * 1.0.0) + (pixel + (depth * color-g) * 0.1.0) + (pixel + (depth * color-b) * 0.0.1)
			change/only pos color
		]
		image
	]
	contrast: func [image [image!] value [integer!] /local pos pixel][
		value: min max -255 value 255 ; clip value
		value: value + 255 / 255 ; now value is between 0 and 2
		repeat pos image [
			pixel: first pos
			pixel: (pixel/1 / 255 - 0.5 * value + 0.5 * 255 * 1.0.0) + (pixel/2 / 255 - 0.5 * value + 0.5 * 255 * 0.1.0) + (pixel/3 / 255 - 0.5 * value + 0.5 * 255 * 0.0.1)
			change/only pos pixel
		]
		image
	]
	difference: func [image [image!] value [integer! tuple!] /local pos pixel][
		if integer? value [	value: min max -255 value 255] ; clip value
		value: value * 1.1.1
		repeat pos image [
			pixel: first pos
			change/only pos pixel - value
		]
		image
	]
	grayscale: func [image [image!] /local pos pixel][
		repeat pos image [
			pixel: first pos
			pixel: (pixel/1 * 30) + (pixel/2 * 59) + (pixel/3 * 11) / 100
			change/only pos pixel * 1.1.1
		]
		image
	]
	invert: func [image [image!] /local pos pixel][
		repeat pos image [
			pixel: first pos
			change/only pos complement pixel
		]
		image
	]
	luma: func [image [image!] depth [integer!]
		/local pos pixel d1 d2 color
		][
		depth: min max -255 depth 255 ; clip value
		if depth = 0 [return image]
		either depth > 0 [
			depth: depth / 255
			d1: 1.0 - depth
			d2: depth * 255
			repeat pos image [
	 			pixel: first pos
				; linearly interpolate from color to white using depth
				color: ((d1 * pixel/1) + d2 * 1.0.0) + ((d1 * pixel/2) + d2 * 0.1.0) + ((d1 * pixel/3) + d2 * 0.0.1)
				change/only pos color
			]
		][
			depth: depth + 255 / 255
			repeat pos image [
	 			pixel: first pos
				; linearly interpolate from color to black using depth
				color: (depth * pixel/1 * 1.0.0) + (depth * pixel/2 * 0.1.0) + (depth * pixel/3 * 0.0.1)
				change/only pos color
			]
		]
		image
	]
	multiply: func [image [image!] value [integer! tuple!] /local p pos pixel color][
		value: value * 1.1.1
		repeat pos image [
			pixel: first pos
			color: (value/1 * pixel/1 / 128 * 1.0.0) + (value/2 * pixel/2 / 128 * 0.1.0) + (value/3 * pixel/3 / 128 * 0.0.1)
			change/only pos color
		]
		image
	]
	extend: func ["Extends an image"
		image [image!] size [pair!] offset [pair! none!] thick [pair! none!]
		/local image-dest img1 img2 img3 img4 img5 img6 img7 img8 img9 offset+thick out
		][
		size: round size
		image-dest: make image! size image-dest/alpha: 0
		offset: any [offset as-pair to-integer image/size/x / 2 to-integer image/size/y / 2]
		thick: any [thick size - image/size]
		; FIXME: we could generalize this a little more by adding a new parameter for the size of the median images

		img1: copy/part at image 0x0 offset
		img2: copy/part at image offset * 1x0 offset * 0x1 + 1x0
		img3: copy/part at image offset * 1x0 as-pair image/size/x - offset/x offset/y

		img4: copy/part at image offset * 0x1 offset * 1x0 + 0x1
		img5: copy/part at image offset 1x1
		img6: copy/part at image offset image/size - offset * 1x0 + 0x1

		img7: copy/part at image offset * 0x1 as-pair offset/x image/size/y - offset/y
		img8: copy/part at image offset image/size - offset * 0x1 + 1x0
		img9: copy/part at image offset image/size

		offset+thick: offset + thick
		out: [
			image (img1) (0x0)
			image (img2) [(offset * 1x0) (as-pair offset+thick/x offset/y)]
			image (img3) (offset+thick * 1x0)

			image (img4) [(offset * 0x1) (as-pair offset/x offset+thick/y)]
			image (img5) [(offset) (offset+thick)]
			image (img6) [(as-pair offset+thick/x offset/y) (as-pair size/x offset+thick/y)]

			image (img7) (offset+thick * 0x1)
			image (img8) [(as-pair offset/x offset+thick/y) (as-pair offset+thick/x size/y)]
			image (img9) (offset+thick)
		]
		draw image-dest bind/only compose/deep out draw-mod
		image-dest
	]
	blur: func [
		image [image!]
		/local image-dest
		][
		image-dest: make image! image/size + 1 image-dest/alpha: 0
		; draw an image 1 pixel bigger then original
		draw image-dest bind/only compose/deep [image-filter bilinear resample 2 image (image) [0x0 (image-dest/size)]] draw-mod
		image-dest
	]
	]

	overlap?: func [
		"Returns TRUE if faces or gobs overlap each other." 
		f1 [object! gob!] f2 [object! gob!]
		][
		not not all [
			f1/offset = min f1/offset (f2/offset + f2/size) 
			(f1/offset + f1/size) = max (f1/offset + f1/size) f2/offset 
		]
	]

	to-draw: func [[catch] block [block!]] [bind/only reduce block draw-mod]
	to-shape: func [[catch] block [block!]] [bind/only reduce block import 'shape]
	to-text: func [block [block!]] [bind/only reduce block import 'text]
	
	to-r3-draw-block: func [[catch] block [block!] /local draw-rule draw-words at out value value2 values beg fin stroke-color dash-color fon][
		block: copy/deep block
		stroke-color: dash-color: yellow
		fon: make system/standard/font [
			color: stroke-color
		]

		draw-rule: [
			  'arc pair! pair! number! number! beg: ['opened | 'closed | (insert beg 'opened) ]
			| 'arrow pair! beg: [tuple! | none! | (insert beg none)]
			| 'box pair! pair! beg: [number! | none! | (insert beg 0.0)]
			| 'circle pair! beg: [ pair! | set value number! (change beg to pair! value)]
			| 'ellipse beg: set value pair! set value2 pair! (change/part beg reduce [value - value2 value2 * 2] 2)
			| 'fill-pen beg: [tuple! | image! | (fin: back beg change fin 'grad-pen fin: back fin) :fin]
			| 'grad-pen
				[beg: 1 8 skip fin: (insert/part clear values beg 8)
				(; FIXME:
				out: copy [radial normal 0x0 0.0x10.0 0 1x1 []]
				use [num1 num2] [
				if value: find values word! [out/1: first value values: next value]
				if value: find values word! [out/2: first value]
				if value: find values pair! [out/3: first value]
				if value: find values number! [num1: first value values: next value]
				if value: find values number! [num2: first value out/4: as-pair num1 num2 values: next value]
				if value: find values number! [out/5: first value values: next value]
				if value: find values number! [num1: first value values: next value]
				if value: find values number! [num2: first value out/6: as-pair num1 num2 values: value]
				fin: skip beg (index? values) - 1
				:fin
				] ; use
				)
				]
				[set value block! (append last out value) | some [set value tuple! (append last out value)] fin: (change/part beg head out fin out: copy []) :beg]
			;| 'image ... ; FIXME:
			| 'image-filter word! beg: [['resize | 'resample] [number! | none!] | (insert insert beg 'resize none) skip] 
			| 'line [block! | beg: some [set value pair! (append out value)] fin: (substitute) :beg]
			| 'line-pattern beg: [tuple! | (insert beg dash-color) :beg skip] beg: [some [set value number! (append out value)] fin: (substitute) :beg]
			| 'line-width number! beg: ['variable | 'fixed | (insert beg 'variable )]
			| 'pen beg: set value [tuple! | none!] (either none? value [change beg off][stroke-color: value]) opt [beg: set dash-color tuple! (remove beg) :beg]
			| 'polygon [block! | beg: some [set value pair! (append out value)] fin: (substitute) :beg]
			| 'scale beg: [ pair! | set value number! set value2 number! (change/part beg as-pair value value2 2) :beg]
			| 'skew beg: [ pair! | set value number! (change beg value * 1x0) :beg] ; FIXME: is this correct ?
			| 'spline [block! | beg: some [set value pair! (append out value)] fin: (substitute) :beg] integer! beg: ['opened | 'closed | (insert beg 'opened) ]
			| 'text beg: 1 4 skip fin: (insert/part clear values beg 4)
				(; FIXME:
				append out first any [value1: find values pair! [0x0]]
				append out first any [find next any [value1 []] pair! [#[none]]]
				value1: first any [value: find values word! [raster]]
				append out switch/default value1 [raster aliased ['raster] vectorial anti-aliased ['vectorial]] [fin: back back fin 'raster]
				append/only out bind/only any [find values block! reduce ['font fon 'text first any [find values string! ""]]] import 'text
				)
				(change/part beg head out fin out: copy []) :beg
			| 'transform number! pair! beg: [ pair! | set value number! set value2 number! (change/part beg as-pair value value2 2) :beg] pair!
			| 'translate [beg: [ pair! | set value number! set value2 number! (change/part beg as-pair value value2 2) :beg]]
			| 'triangle pair! pair! pair!
				[beg: 0 4 skip fin: (insert/part clear values beg 4)
				(; FIXME:
				out: copy [none none none 0]
				if value: find values tuple! [out/1: first value values: next value]
				if value: find values tuple! [out/2: first value values: next value]
				if value: find values tuple! [out/3: first value values: next value]
				if value: find values number! [out/4: first value values: next value]
				fin: skip beg (index? values) - 1
				:fin
				change/part beg head out fin out: copy []
				)
				]
			;| 'shape ... ; FIXME: beg: set shapes block! (change beg to-r3-shape-block shapes)
			; all others are R2 draw dialect compatible
			; FIXME: where is pop?
			| skip
			| end
			| a: (print ["error"])
		]
		draw-words: append words-of system/modules/draw system/modules/draw/words
		substitute: does [change/part/only beg head out fin out: copy []]
		out: copy []
		values: copy []
		forall block [
			set/any 'value pick block 1
			if not any [
					scalar? value
					series? value
					find draw-words value 
					any-function? do value
					unset? do value
				][
				change block do value
			]
			;set/any 'value do value
			if none? value [change block false]
			if all [tuple? value not none? value/4] [value/4: 255 - value/4 change block value] ; invert alpha
		] ; reduce block
		pos: head block

		parse head block [some draw-rule | end | at: (print ["err" at])]
		;insert head block [pen 255.255.0 line-cap ?] ; FIXME: add default R2 pen color (face/color) ?
		bind/only head block draw-mod
	]
	
	draw-block-from-effect: func [face [object!]
		/local block size color scale dir grad1 grad2 values value1 diag type angle offset thick shapes effect-rule emit beg fin image image2
		][
		if none? face/effect [return face/image]
		size: face/size - any [attempt [face/edge/size * 2] 0x0]
		either face/image [image: copy face/image ][image: make image! size image/alpha: 0]
		
		;if none? face/effect [return image]
		block: copy/deep face/effect
		forall block [
			set/any 'value pick block 1
			if not any [
					scalar? value
					series? value
					find [arrow cross gradient grid oval] value 
					any-function? do value
					unset? do value
				][
				change block do value
			]
			if none? value [change block false]
			if all [tuple? value not none? value/4] [value/4: 255 - value/4 change block value] ; invert alpha
		] ; reduce block
		size: image/size ;- any [attempt [face/edge/size * 2] 0x0]
		color: any [attempt [face/edge/color] face/color]
		scale: 1 dir: 0x0
		values: copy []
		
		emit: func [block][draw image bind/only compose/deep block draw-mod]
		effect-rule: [
			  'arrow opt [set color tuple!] opt [set scale decimal!]
				(
				value1: size ;* scale ; FIXME:
				emit [
					anti-alias off pen off fill-pen (color)
					triangle (as-pair value1/x * .5 value1/y * .25) (as-pair value1/x * .1 value1/y * .65) (as-pair value1/x - (value1/x * .1) value1/y * .65) none none none 0
				]
				)
			| 'cross opt [set color tuple!]
				(
				emit [pen (color) line [0x0 (size)] line [(size * 0x1 - 1x0) (size * 1x0 - 1x0)]]
				)
			| 'grid beg: 0 4 skip fin: (insert/part clear values beg 4)
				(
				space: 8x8 offset: 8x8 thick: 1x1
				if value1: find values pair! [space: max 0x0 first value1 value1: next value1]
				if value1: find value1 pair! [offset: max 0x0 first value1 value1: next value1]
				if value1: find value1 pair! [thick: max 0x0 first value1 value1: next value1]
				if value1: find values tuple! [color: first value1]
				if space/x > 0 [
					emit [line-width (size/y * 2) variable line-pattern (color) [(space/x) (thick/x)] pen off anti-alias off
						  line [(space + thick - offset * -1x0) (size * 1x0)]]
				]
				if space/y > 0 [
					emit [line-width (size/x * 2) variable line-pattern (color) [(space/y) (thick/y)] pen off anti-alias off
						  line [(space + thick - offset * 0x-1) (size * 0x1)]]]
				)
			| 'oval opt [set color tuple!]
				(
				shapes: bind compose [
					move (size/x / 2 * 1x0)
					hline' (size/x / 2) vline' (size/y) hline' (0 - size/x) vline' (0 - size/y) hline' (size/x / 2)
					arc' (size * 0x1) (size / 2) 0 positive large
					arc' (size * 0x-1) (size / 2) 0 positive large
					close
				] import 'shape
				emit reduce ['anti-alias off 'pen off 'fill-pen (color) 'fill-rule 'even-odd 'shape shapes]
				)
			;| 'round ; FIXME:
			| 'gradient beg: 0 3 skip fin: (insert/part clear values beg 3)
				(
				grad1: any [face/color white] grad2: complement grad1
				diag: square-root size/x * size/x + (size/y * size/y)
				dir: first any [find values pair! [1x0]]
				type: switch/default dir [1x0 -1x0 0x1 0x-1 ['linear]] ['radial]
				angle: switch/default dir [1x0 [0] -1x0 [180] 0x1 [90] 0x-1 [270]] [0]
				diag: switch/default dir [1x0 -1x0 [size/x] 0x1 0x-1 [size/y]] [diag]
				offset: switch/default dir [1x0 1x1 [0x0] -1x0 [diag * 1x0] 0x1 [0x0] 0x-1 [diag * 0x1] 0x0 -1x1 [(size * 1x0)] 1x-1 [(size * 0x1)] -1x-1 [(size * 1x1)]] [0x0]
				if value1: find values tuple! [grad1: first value1 value1: next value1]
				if value1: find value1 tuple! [grad2: first value1]
				emit [pen off fill-pen (grad1) grad-pen (type) normal (offset) (diag * 0x1) (angle) 1x1 [(grad1) (grad2)] box 0x0 (size) 0]
				)
			| 'blur
				(
				size: face/size - any [attempt [face/edge/size * 2] 0x0]
				image2: ctx-image-effects/blur image
				image: make image! size image/alpha: 0
				emit [image (image2) [0x0 (size)]]
				)
			| 'crop set offset pair! set size pair! (
				image2: copy/part at image offset size + offset
				image: make image! size image/alpha: 0
				emit [image (image2) [0x0 (size)]]
				)
			| 'extend beg: 0 2 skip fin: (insert/part clear values beg 2)
				(
				if value1: find values pair! [offset: first value1 value1: next value1]
				if value1: find values pair! [thick: first value1 value1: next value1]
				size: either thick [size + thick] [face/size - any [attempt [face/edge/size * 2] 0x0]]
				image2: ctx-image-effects/extend image size offset thick
				image: make image! size image/alpha: 0
				emit [image (image2) 0x0 ];[0x0 (size)]]
				)
			| 'fit (
				size: face/size - any [attempt [face/edge/size * 2] 0x0]
				image2: copy image
				image: make image! size image/alpha: 0
				emit [image (image2) [0x0 (size)]]
				)
			| 'flip opt [set dir pair!] (
				dir/x: either dir/x = 0 [0][1] 
				dir/y: either dir/y = 0 [0][1] 
				switch dir [
					1x0 [emit [image (image) [(size * 1x0) 0x0 (size * 0x1) (size)]]]
					0x1 [emit [image (copy image) [(size * 0x1) (size) (size * 1x0) 0x0]]]
					1x1 [emit [image (copy image) [(size) (size * 0x1) 0x0 (size * 1x0)]]]
				]
				)
			| 'rotate opt [set angle integer!] (
				image2: copy image
				image: make image! either any [angle = 90 angle = 270] [reverse image/size][image/size] image/alpha: 0
				switch/default angle [
					90  [emit [image (image2) [(size/y * 1x0) (size/x * 0x1 + (size/y * 1x0)) (size/x * 0x1) 0x0]]]
					180 [emit [image (image2) [(size) (size * 0x1) 0x0 (size * 1x0)]]]
					270 [emit [image (image2) [(size/x * 0x1) 0x0 (size/y * 1x0) (size/x * 0x1 + (size/y * 1x0))]]]
				] [emit [image (image2) 0x0]]
				)
			| 'colorize set color tuple! (scale: 255) opt [set scale integer!] (image: ctx-image-effects/colorize image color scale)
			| 'contrast set scale integer! (image: ctx-image-effects/contrast image scale)
			| 'difference set scale [integer! | tuple!] (image: ctx-image-effects/difference image scale)
			| 'grayscale (image: ctx-image-effects/grayscale image)
			| 'invert (image: ctx-image-effects/invert image)
			| 'luma set scale integer! (image: ctx-image-effects/luma image scale)
			| 'multiply set scale [integer! | tuple!] (image: ctx-image-effects/multiply image scale)
			| 'mix set image2 image! (
				emit [image (image2) [0x0 (size)]]
				)
			;| 'draw ; FIXME: to-r3-draw-block ...
			| skip
			| end
			| a: (print ["error"])
		]
		parse head block [some effect-rule | end | at: (print ["err" at])]
		image
	]
	
	make_edge-polygon-block: func [
		size [pair!] edge-size [pair!] color1 [tuple!] type [word! none!]
		/local a b c d e f g h i l bev bez color2 color3
		][
			; A           B
			;  +---------+
			;  |E       F|
			;  | +-----+ |
			;  |/|     |\|
			; I+ |     | +L
			;  |\|     |/|
			;  | +-----+ |
			;  |H       G|
			;  +---------+
			; D           C
		color2: color1 * 0.8 ; FIXME: (bri: rgb-to-hsv color1) * 1.1.0 + (0.0.1 * (third bri * 0.7))
		color3: color1 * 1.3
		a: 0x0
		b: size * 1x0
		c: size
		d: size * 0x1

		e: edge-size
		f: as-pair size/x - edge-size/x	edge-size/y
		g: as-pair size/x - edge-size/x	size/y - edge-size/y
		h: as-pair edge-size/x				size/y - edge-size/y
		
		i: size * 0x.5
		l: size * 1x.5

		bev: reduce ['pen no 'fill-pen color3 'anti-alias no 'polygon reduce [a b f e h d] 'fill-pen color2 'polygon reduce [c b f g h d]]
		bez: reduce ['pen no 'fill-pen color1 'fill-rule 'even-odd 'polygon reduce [i a b c d i e f l g h] 'fill-pen color2 'polygon reduce [h i e f l g f e]]
		switch type reduce [; FIXME: make numbers not absolute
			none [bev/4: color1 bev/10: color1 bev]
			'nubs [bev/4: orange bev/10: orange bev] ; same as none FIXME: add this (I think it is used only in layout.r)
			'bevel [bev]
			'ibevel [bev/4: color2 bev/10: color3 bev]
			'bezel [bez]
			'ibezel [bez/4: color2 bez/10: color1 bez]
		]	
	]

	textinfo: func [ ; FIXME: 
		{Sets the line text information in an object for a face.} 
		face [object!] "The face for which the information is defined." 
		line-info [object!] "The object where the information will be set." 
		line [number! any-string!] "The line to get information for."
		][
		;	start:				; series reference to start of line
		;	num-chars:			; count of number of chars in line
		;	offset:				; xy position of line
		;	size: none			; width and height of line
		;line-info/size: 0x15
		size-text-face-text-info/text: form pick face/text 1
		line-info/size: size-text size-text-face-text-info 
	]

	clear-text-caret: func [car][
		car/caret/1: car/highlight-start/1: car/highlight-end/1: copy [""]
		car/caret/2: car/highlight-start/2: car/highlight-end/2: copy ""
		car
	]

	call-iters: func [
		face [object!]
		image [image!]
		/with item [integer!]
		/local index faces facei face-image
		][
		;image/alpha: either item [255][0]
		index: 1
		while [faces: face/pane face index faces] [
			index: index + 1
			if any [not item index = item] [
				; FIXME: foreach face faces [...
				facei: make_gobs_from_face faces
				faces/parent-face: face
				face-image: to-image facei/gob
				
				change/only at image facei/offset face-image
			]
		]
		image
	]
	
	make_gobs_from_face: func [{Recursively create gobs from given face}
		face [object!]
		/local gobbg gob gobcp gobs image offset size text car subface pane
		][
		; FIXME: if not all [in face 'type face/type = 'face] [return face]
		; call feel/redraw 'show and 'draw
			try [face/feel/redraw face 'draw 0x0] ; FIXME: I should give win-offset? face
			;try [face/feel/redraw face 'show 0x0]
		; create gobs
			if not in face 'gob [append face [gob: #[none]]]
			;if face/gob [clear face/gob face/gob: none] ; we are recreating gobs so clear all before - better NO
			
			gobs: make object! [gob-background: gob-edge: gob-image: gob-effect: gob-draw: gob-text: gob-iter: iter-image: gob-clipper: gob-face: none]

			offset: any [face/offset 0x0]
			size: any [face/size 100x100]

			;print ["make_gobs" face/color face/text]
			; background
			gobbg: make gob! [offset: offset size: size color: face/color]
			gobbg/data: gobs ; FIXME: necessary?
			gobs/gob-background: gobbg
			face/gob: gobbg
			gobs/gob-face: face
			if not face/show? [return face]
			offset: 0x0 ; reset since all others are relative to gobbg (or gobed)
			; edge
			if all [face/edge face/edge/size > 0x0] [
				gob: make gob! [offset: 0x0 size: size]
				offset: face/edge/size
				gob/draw: bind make_edge-polygon-block size offset face/edge/color face/edge/effect draw-mod
				size: size - offset - offset
				gobs/gob-edge: gob
				append gobbg gob
			]
			; image
				gob: make gob! [offset: offset]
				gob/image: draw-block-from-effect face
				gob/size: size ; restore because image could have changed it (!)
				gobs/gob-image: gob
				append gobbg gob
			; effect ; done inside image
			; draw
			; WARNING: translate R2 draw block to R3 draw block !! :(
			if all [in face 'effect face/effect face/effect/draw] [
				gob: make gob! [offset: offset size: size]
				gob/draw: to-r3-draw-block face/effect/draw
				gobs/gob-draw: gob
				append gobbg gob
			]
			; text
			if face/text [
				gob: make gob! [offset: offset size: size]
				;gobtx/text: face/text
				;anti-alias: any [face/font/anti-alias on]
				face/para: make face/para []
				if all [face/para face/font] [
					if face/font/align = 'center [face/para/origin/x: -1] ; try to be compatible (but kind of a hack! and too restrictive)
					if face/font/valign = 'middle [face/para/origin/y: 0] ; try to be compatible (but kind of a hack! and too restrictive)
					append face/para compose [align: (face/font/align) valign: (either face/font/valign = 'center ['middle][face/font/valign])]
				]
				text: face/text
				if not find [none! string!] type?/word face/text [text: form text]
				gob/text: reduce [
					'anti-alias on
					any [all [face/font face/font/align] 'center]
					'caret system/view/text-caret
					'text text
					]
					if face/para [insert insert gob/text 'para face/para]
					if face/font [insert insert gob/text 'font face/font]
					gob/text: bind gob/text import 'text
				
					car: system/view/text-caret
					either same? text head any [system/view/caret ""] [
						car/caret/1: car/highlight-start/1: car/highlight-end/1: back tail gob/text
						car/caret/2: system/view/caret
						car/highlight-start/2: system/view/highlight-start
						car/highlight-end/2: system/view/highlight-end
					][
						clear-text-caret car
					]

				gobs/gob-text: gob
				append gobbg gob
			]
			; iter
			if function? get in face 'pane [
				gob: make gob! [offset: offset size: size]
				image: make image! size
				image/alpha: 0
				gob/image: gobs/iter-image: call-iters face image
				gobs/gob-iter: gob
				append gobbg gob
			]
			; clipper (this is created because clipping is done inside edge)
				gobcp: make gob! [offset: offset size: size]
				gobs/gob-clipper: gobcp
				append gobbg gobcp

			;gobbg/data: face ; FIXME: necessary?
			; FIXME: face/gob: gobs

			; rate
				if all [not find ctx-do-event/timer-list face face/rate] [ ; not in the list
					; it should be, append to the list
					insert insert insert tail ctx-do-event/timer-list face face/rate now/precise
				]
		; scan pane
			if object? get in face 'pane [
				face/pane: make_gobs_from_face face/pane
				face/pane/parent-face: face
				append gobcp face/pane/gob
			]
			if block? get in face 'pane [
				pane: face/pane
				forall pane [
					subface: first pane
					;print [">>" subface/text]
					if object? subface [
						subface: make_gobs_from_face subface
						subface/parent-face: face
						append gobcp subface/gob
					]
				]
				pane: head pane
			]
		;
		foreach subface gobbg/pane [subface/data: gobs]

		face
	]
	update_gobs_from_face: func [{Recursively update gobs from given face}
		face [object!]
		/no-refresh
		/local gobbg gobed gobim gobdr gobtx gobcp gobs offset size text car pos pane ; FIXME: reduce locals number since this is recursive
		][
			if not in face 'gob [return none] ; FIXME: return error ?
			if none? face/gob [return make_gobs_from_face face]
		; FIXME: if not all [in face 'type face/type = 'face] [return face]
		; call feel/redraw 'show
			try [face/feel/redraw face 'show 0x0]
		; update gobs
			
			offset: either face/parent-face [face/offset][0x0] ; if this is a window reset offset
			size: face/size
			
			; background
			gobbg: face/gob/data/gob-background
				gobbg/offset: offset
				gobbg/size: size
				gobbg/color: face/color
			offset: 0x0 ; reset since all other is relative to gobbg (or gobed)
			; edge
			if gobed: face/gob/data/gob-edge [
				gobed/size: size
				offset: face/edge/size
				clear gobed/draw
				gobed/draw: none
				gobed/draw: bind make_edge-polygon-block size offset face/edge/color face/edge/effect draw-mod
				size: size - offset - offset
			]
			; image
			if gobim: face/gob/data/gob-image [
				gobim/offset: offset
				gobim/size: size
				gobim/image: draw-block-from-effect face
			]
			; effect
			; draw
			; WARNING: translate R2 draw block to R3 draw block !! :(
			if gobdr: face/gob/data/gob-draw [
				gobdr/offset: offset
				gobdr/size: size
				gobdr/draw: attempt [to-r3-draw-block face/effect/draw]
			]
			; text
			if gobtx: face/gob/data/gob-text [
				gobtx/offset: offset
				gobtx/size: size
				;gobtx/text: face/text
				;anti-alias: any [face/font/anti-alias on]
				face/para: make face/para []
				if all [face/para face/font] [
					if face/font/align = 'center [face/para/origin/x: -1] ; try to be compatible (but kind of a hack! and too restrictive)
					if face/font/valign = 'middle [face/para/origin/y: 0] ; try to be compatible (but kind of a hack! and too restrictive)
					face/para/align: face/font/align
					face/para/valign: either face/font/valign = 'center ['middle][face/font/valign]
				]
				text: face/text
				if not find [none! string!] type?/word face/text [text: form text]
				gobtx/text: reduce [
					'anti-alias on
					any [all [face/font face/font/align] 'center]
					'caret system/view/text-caret
					'text any [text ""]
				]
				if face/para [insert insert gobtx/text 'para face/para]
				if face/font [insert insert gobtx/text 'font face/font]
				gobtx/text: bind gobtx/text import 'text

				car: system/view/text-caret
				either same? text head any [system/view/caret ""] [
					car/caret/1: car/highlight-start/1: car/highlight-end/1: back tail gobtx/text
					car/caret/2: system/view/caret
					car/highlight-start/2: system/view/highlight-start
					car/highlight-end/2: system/view/highlight-end
				][
					clear-text-caret car
				]
			]
			; clipper (this is created because clipping is done inside edge)
			if gobcp: face/gob/data/gob-clipper [
				gobcp/offset: offset
				gobcp/size: size
			]
			; rate
				if all [not find ctx-do-event/timer-list face face/rate] [ ; not in the list
					; it should be, append to the list
					insert insert insert tail ctx-do-event/timer-list face face/rate now/precise
				]
				if pos: find ctx-do-event/timer-list face [
					either face/rate [
						if face/rate <> pos/2 [ ; needs update because rate changed ?
							pos/2: face/rate 
						]
					][
						; face/rate = NONE so remove face from the list
						remove/part pos 3
					]
				]

			; since our face could be over another face I must update all gobs on the same pane :(((
		unless no-refresh [try [ ; FIXME: try to remove the try or avoid doing this when face's window is not open (see files-renamer.r)
			gobcp: last gobbg/parent/parent/pane ; take clipper
			foreach subgob gobcp/pane [
				if overlap? subgob gobbg [
					foreach subsubgob subgob/pane [
						if subsubgob/draw [
							subsubgob/draw: bind/only subsubgob/draw draw-mod
						]
					]
				]
			]
		]]
		; scan pane
			switch type?/word get in face 'pane [
				block! [
					pane: face/pane
					forall pane [
						update_gobs_from_face/no-refresh first pane
					]
					pane: head pane
				]
				object! [
					update_gobs_from_face/no-refresh face/pane
					face/pane/parent-face: face
					remove face/gob/data/gob-clipper
					append face/gob/data/gob-clipper face/pane/gob
				]
				function! [
					face/gob/data/gob-iter/image: face/gob/data/iter-image: make image! size
					face/gob/data/iter-image/alpha: 0
					call-iters face face/gob/data/iter-image
				]
			]
		face
	]

; gfx-object
	set [font-serif font-sans-serif font-fixed] any [
		select [
			1 ["CGTimes" "CGTriumvirate" "LetterGothic"]
			2 ["times" "arial" "courier new"]
			3 ["times" "arial" "courier new"]
			5 ["baskerville" "zurich" "courier10 bt"]
		] system/version/4
		["times" "helvetica" "courier"]
	]
	face: make object! [
			type: 'face
			offset: 0x0					; position (position of window)
			size: 100x100				; width & height (dimension of window)
			span:						; offset to next area (scaling factor)
			pane:						; subface or block of subfaces
			text: none					; string pointer to text (window name)
			color: 200.200.200			; color or tint of face
			image:						; image
			effect:						; algorithm (symbol)
			data: none					; user defined data field
			edge: make object! [
				color:		200.200.200	; color or tint of edge
				image:					; image used for edge
				effect:		none		; algorithm (symbol)
				size:		2x2			; thickness of edge (xy)
			]
			font: make object! [
				name:		font-sans-serif ; font name
				style:		none		; font style [italic bold ...]
				size:		12			; font size
				color:		0.0.0		; text color or tint
				offset:		2x2			; padding from area
				space:		0x0			; interchar & interline spacing
				align:		'center		; text alignment (left, center, right, justify)
				valign:		'center		; vertical text alignment ( top, center, bottom, justify )
				;angle:		0			; text angle
				shadow:		none		; shadow offset
				;outline:	none		; outline size
			]
			para: make object! [
				origin:		2x2			; origin (offset) of text in area
				margin:		2x2			; right margin
				indent:		0x0			; indent (exdent) of first line
				tabs:		40			; tabspace or index block
				;edit?:		false
				wrap?:		true
				;scroll?:	false
				;filter:		none		; to filter edits
				scroll:		0x0			; pair for scrolling offset
			]
			feel: make object! [		; all fields are functions
				redraw:
				detect:
				over:
				engage: none
			]
			saved-area: none			; bits saved under a transparent image
			rate:	none				; rate at which to call engage
			show?:	true				; face showing
			options: none				; options for window handling
			; internal values
			parent-face:
			old-offset:
			old-size:
			line-list: none
			changes: none
			face-flags: 0
			action: none
			gob: none 					; ADDED for R3
	]
	protect 'face
	size-text-face-text-info: make face [
		edge: none para: none feel: none
		font: make font [align: 'left valign: 'top shadow: none name: font-sans-serif style: []]
	]
;
; view-object ; system/view/wake-event
	view-object: does [
	system/view: make system/view [; append instead of replace

		screen-face: make face [
			pane: []
			feel: make feel [
				event-funcs: []
				detect: func [face event][
			;		if not object? face [print "detect got no face"]
					foreach evt-func event-funcs [
						; The evt-func function returns tristate:
						;	1. event: not my event, try next handler function
						;	2. true: my event, but return event from detect
						;	3. none: my event, return none
						if not event? evt-func: evt-func face event [
							return either evt-func [event][none]
						]
					]
					event
				]
				;-- protect 'detect  !!!CES
			]
		]
		focal-face:
		caret:
		highlight-start:
		highlight-end: 
			none
		title-size: gui-metric 'title-size
		resize-border: gui-metric 'border-size
		no-resize-border: gui-metric 'border-fixed
		line-info: make object! [
			start:				; series reference to start of line
			num-chars:			; count of number of chars in line
			offset:				; xy position of line
			size: none			; width and height of line
		]
		VID: none

		;-- end of C struct
		
		;;;;; added for R3
		text-caret: context [
			caret: copy/deep [[""] ""] ; placeholders
			highlight-start: copy/deep [[""] ""]
			highlight-end: copy/deep [[""] ""]
		]

		event-port: none
		debug: none
		pop-face: none
		pop-list: []

		set 'show-popup func [face [object!] /window window-face [object!] /away /local no-btn feelname] [
			if find pop-list face [exit]
			window: either window [feelname: copy "popface-feel-win" window-face][
				feelname: copy "popface-feel"
				if none? face/options [face/options: copy []]
				if not find face/options 'parent [
					repend face/options ['parent none]
				]
				system/view/screen-face
			]
			; do not overwrite if user has provided custom feel
			if any [face/feel = system/contexts/user/face/feel face/feel = window-feel] [ ;;;;; patched fo R3
				no-btn: false
				if block? get in face 'pane [
					no-btn: foreach item face/pane [if get in item 'action [break/return false] true]
				]
				if away [append feelname "-away"]
				if no-btn [append feelname "-nobtn"]
				face/feel: get bind to word! feelname 'popface-feel
			]
			insert tail pop-list pop-face: face
			append window/pane face
			show window
		]

		set 'hide-popup func [/timeout /local win-face] [
			if not find pop-list pop-face [exit]
			win-face: any [pop-face/parent-face system/view/screen-face]
			remove find win-face/pane pop-face
			remove back tail pop-list
			if timeout [pop-face: pick pop-list length? pop-list]
			ctx-do-event/pop-ups: 1 ;;;; added for R3, FIXME: kind of a hack...
			show win-face
		]

		;wake-event: func [port /local event no-btn][
		;	event: pick port 1
		wake-event: func [event /local pop-res][
			if none? event [	; this is bogus - why no event data
				if debug [print "Event port awoke, but no event was present."]
				return false
			]
			if event/type <> 'time [
			;print ["wake-event:" event/type event/offset event/code mold event/flags]
			]
			either pop-face [
				; there is a modal window up
				; handling the current pop-face
				if in pop-face/feel 'pop-detect [pop-res: pop-face/feel/pop-detect pop-face copy-event event]
				;do event
				if any [pop-res none? in pop-face/feel 'pop-detect] [mimic-do-event event]
				found? all [
					pop-face <> pick pop-list length? pop-list
					; pop-face has been closed
					(pop-face: pick pop-list length? pop-list true)
				]
			] [
				;do event
				mimic-do-event event
				empty? screen-face/pane
			]
			;returns either value
		]

		set 'open-events does [
			if event-port [exit]
			event-port: open [scheme: 'event target: "events"]
			event-port/awake: func [port] [wake-event port]
			insert system/ports/wait-list event-port
		]

		window-feel: make face/feel [
			detect: func [face event][
				; Detect if a key has been pressed, and whether this window
				; has any shortcuts for it.  The system would work better if
				; we knew in advance if a window had a shortcut key and this
				; function could be nulled out.
				either all [
					event/type = 'key
					face: find-key-face face event/key
				][
					if get in face 'action [do-face face event/key]
					none
				][
					event
				]
			]
		]

		;------- Popup windows feels

			; normal popup feel
			popface-feel: make window-feel [
				close-events: [close]
				inside?: func [face event] [face = event/face]
				; ingore outside events
				process-outside-event: func [event] [
					either event/type = 'resize [event] [none]
				]
				; detects ALL events, for all faces
				pop-detect: func [face event] [
					either inside? face event [
						either find close-events event/type [hide-popup none] [event]
					] [
						; event is ouside the popup
						process-outside-event event
					]
				]
			]

			; popup feel for a popup without buttons
			popface-feel-nobtn: make popface-feel [
				append close-events 'up
			]

			; popup feel for /away popup
			popface-feel-away: make popface-feel [
				process-outside-event: func [event] [
					; event is ouside the popup, close the popup
					; fix: don't close on active/inactive
					unless find [move time active inactive] event/type [hide-popup]
					event
				]
			]

			; popup feel for /away popup without buttons
			popface-feel-away-nobtn: make popface-feel-away [
				append close-events 'up
			]

			; popup feel for a popup inside another window
			popface-feel-win: make popface-feel [
				close-events: []
				inside?: func [face event] [within? event/offset win-offset? face face/size]
			]

			; popup feel for a popup without buttons inside another window
			popface-feel-win-nobtn: make popface-feel-win [
				append close-events 'up
			]

			; popup feel for /away popup inside another window
			popface-feel-win-away: make popface-feel-win [
				process-outside-event: get in popface-feel-away 'process-outside-event
			]

			; popup feel for /away popup without buttons inside another window
			popface-feel-win-away-nobtn: make popface-feel-win-away [
				append close-events 'up
			]

		;-------

			;set 'view func [
			;set 'unview func [
	]
	]
; view-images
	view-images: does [
	load-stock: func [
		"Load and return stock image. (Keep cache after first load)"
		name
		/block size ; return block of consecutive images
		/local image
		][
		if not image: find system/view/vid/image-stock name [
			make error! reform ["Image not in stock:" name]
		]
		either block [
			block: copy []
			loop size [
				if not image? second image [change next image load second image]
				append block second image
				image: skip image 3
			]
			return block
		][
			if not image? second image [change next image load second image]
			return second image
		]
	]
	load-stock-block: func [
		"Load a block of stock image names. Return block of images."
		block /local list
		][
		list: copy []
		foreach name block [append list load-stock name]
		list
	]
	system/view/vid/image-stock: reduce [
			'logo make image! reduce [100x24 decompress 64#{
		eJzVmSGQMjEMhWfWYn+JReKwuHM4JBaLw2JxSBwahUaikFgsCovF3tw3dK4TkjQD
		t8s/s09xJU2T1/Sl5Xq93r92otvtzufz2+32XcDpdBqNRk0t13sQVbUQw+HweDyW
		WJLYbreN5NjpdNrI1Xg8DsrJLTCqouaiqboaif+/AaJeZynjfD7XzLR1XFEeb1WU
		xG63q7O0yxVS8GXAIFoauBoMBnZWQr/ft/Yc/6EH1ziDfF0ertfr4XDg2/1+TwmV
		6JpMJm4YQZwBV8y9XC7uQvf7fbPZlFwR6lsbSoXg0LVHtN19ISlrTLTT6ZSwVfpo
		lDVmMAgjyO5drhKWy6XrKuhK7LXLVbAKzMv0E8jFmpWqnenWHnCLKIVRh6t0PwFc
		YzL5VLjrKtcVejKbzaYClLfLVfa5Xq+xYSFZnKpzwYlSKs5dLAuVt4Nq45qqK+k2
		iwDf2h2XXGEQx2+DhM80uFgs0ghfKR4gU2WNsTTAHraV5timCeEy5aa4YlP6DxBV
		dugeqEpwhSXXv80v+EyZxVzhk9LldKfKYVzxAJBllTWiJL2lsPEgy5h0KD81UfL5
		Ob0iEvpdzJVFSa8CbbfdGcKljSq8XJDfRsBZPSb5E1zBRokoxdX1GchRzBU2JMgx
		l6qo9CrmarVaydWlSthrxie4Yn9RgPwnMagm4nKFGT47Aq69DJIDmAalKKljiKap
		lOVRIrA8rjq1vW7JHW9W22X8QetpRNtJP6+lIpdsqFkJyDgsqUFoUbNY9BPannVG
		dt7S/UreGSgJSmXxC7KIucI/55RQ5fFXdWXvYxzbUtFm0FnsrFIYrI797gE+qJYa
		c0X6aVCWFlS4pdXsXdTqVeW1D1cJM9gv61k15SAMdS18/X4luwlCagP7wxuHE317
		BiNwjn/3RW+vDSlI23GY7l7ak5Y2xVUl3s7qHpLfwm43ZHBUQKl72t8e4zPFt+67
		mEMEw5ADyVQa7Nk7VYIVEHwS4diDYqZ1v8lYhX8dNX/Cah1X1fNV6nVQe+6z9HW0
		kSvAQXuXKLcXv4WWclU9HjWlJ5ICrao+UdVD2Xqt/Z8XZ8q+9SRorFRgUwni5wcR
		F9yOIBwAAA==
		}] 0 
			'icon-image make image! reduce [48x48 decompress 64#{
		eJzt2M1rnUUUBnC4SwvZdOPHQq3oolTET8QgpJXYFJT4QQmoxbTUamygEsWPGIpU
		FFIVLKK0IioIBjcRu1IourHFRVdd+B8IxWXXUvzd+9Dh5d5k3psbqAgZDsO8886c
		88w5Z86cmdUvF1e3aIs2TfuvlSenn75utHfv5D33PXDDtm2DePw68socmj14CM0c
		OJzPPjo6fyx1qIwPNYflb6E1h2nD0+l0BvHop5znjiw8sX92/PF9k9MzL7/23sGj
		b7/40htzb76Pjr2zXOitE6eQhjEzs/OmIHMPLSwa+e6HZ5Y/Wznx0dcGZK5fFoie
		er5bF56vL51aD8/tO3bs3rMHkrt27brjzp0a5kaQxjMvvEquGvlMj1+PTk3vvPdB
		9NDE5GP7nkU6oSIoMHxamn51uJUeDeslroLn/kcmDLj74XENsgKmoEpbjU80Rj9Z
		Jp0gDUQzH3zynX5LIBpplLnacOrUxqGOxxgwEDxUZNVhGKITACKazq0RchQVmaJH
		PzDf/PDbp1/9RFxWEUVhi6cxMbEa8rq9qNp0ojGPoEg0S390ouHv9mtlbGys0yu2
		iU98rAJsshDkpkRR+hFIxd+4WR1PlGmwYXqCh/ToVq2H0E5bMcYsGCzh489/ZMRs
		k/GJqbhBftFhC54Dh2NcZjUyJuAtGPrFz4s2hik0Bj9d0YPlFH+OCfS04jEXHlqN
		V2sAY2vznJtvvW14JM2Cc5yKQuLPgYQt1dXxwAx5/BOZxQFwGBlMyo033RLvjfKz
		ueABkpQKHnqIJ6tR1LVJMCmYxO4JXGrqgrCOB/Jsc5C6kW3uOFR1QdlWzY0WhWDY
		52zY0rY1ZrOzRev+yi6IihjdZ92BwXBOrax8jxYWFmDj8xo+z5375fTpLyKuDKZt
		kBIb4+eteKyCDu1K+NV15ZhF7tWr/6A/L11aWlosn6GzZ1eNKePtdxgYjiHUrfE5
		zmyMhRhM7XU8vIJEcq9c+RsVGOXz8uW/5BVNO+aMZoKcX/RZwZNozGQxdB1MH55I
		96lu9shkmlPA4Mk5Nay6jqecUyKD8cPjCQD2wp/bFEWdPLncF88hsc3jQmTFmuvh
		oUlgqFHkbN1ZfXguXvwjzoCVXAsS6dagxQG2zXlmkpA6Hkjscacqr2v64TB4zp//
		tSndXltzCnXlOKN/VLdXMjqoqLTVmQfxDLMEASRbPmdHHU/Sgxw3I+hnmCmWST/J
		hdR1ewUP/bDXev7T1NsIeMST6IfztOKBnPPEXrTUx0osFXgvXPi9BN4R8EDCn5ON
		a9ftxXnASCQ3q8mnGYqRNkWhDeHhzPaL9dJMTvk6nu6tpIc8h10GpwizJc6UQIf/
		hvAwVlKaJHut9qKcXEYgz0FTWJHeh8f4Jh52bMVjsZzHEQlPspokM5X4k5QDpORv
		RUVENwOvtp3LXsWI4mEdD9G5E1FL7gjqOh6eU648DH3m259NLwxJF3ITeHMKgGRW
		bsEUWElOhMd4smXyCipKVlPHE58vWbe5Dg7tJucNpfSl4GbP5voWF0rWV8fTvEKa
		ZS4VudyZPgKGUpL2UHXuTZaZRLr1fBd8LCGUQFQupJazGTD03H1VmJ0Pzwjy2Xqe
		xo1RbJ0HjVyBcRjmUCsl1wpIKNmKMC+3+ARn7bp+cqHIYZcXidQ+m6ZvRWWAYVka
		PJZjbl4Y8rJR7vV1PN0rbW+zZ1ZidR4xUufShOw+Y8Q3ou2dcnm3a2yKvHjEA+FB
		TBZUfsV52LE1/0mkwjMvGzDgmVeU8gCVV4W8q4R/GZMBVpEHqLy0dL1l7nieg3JG
		ZHOxV2u+kWEoyownW1rkJjWKW6rLY1o35Z6YyltBuX7mXtzNK3r9eXMLvNykhsl/
		8syV5I307Is4QPKQwCivZE2JJWplE9FJccWSfcUJcS7PbuvZi/VZKi9vYW56Xt4g
		iU7i3n3vb8GDdKpjaIOTisdP0q8OJHVRWrbGIJ5O73zZfn2LUJ80e008/2EZxLNF
		/wv6F379Sn4AGwAA
		}] 0 
			'btn-up make image! reduce [7x14 decompress 64#{
		eJxd0CEOwDAIhWEOtxv3JtwAMYFBYEhmNgJ5pOunyE8NJaLrj1BemFXOD0REx56T
		u5tZx4AsqjrRSxYR6WiQhZn32M8mKhzxLnsU4NKRYZU5asFx/v4hHyTWtHYmAQAA
		} complement decompress 64#{eJz7f46BgeHcfxAJpBmoAqCG/YcYDQAEYgptYgAAAA==}] 0 
			'btn-dn make image! reduce [7x14 decompress 64#{
		eJxjYGBwQQUMMJHNMACX2owKkAUvXbr0EAzggpfAgBaCEHE02yEAv3YI9+XLl3BB
		IHgJA2jeRw4QAGL9pRYmAQAA
		} complement decompress 64#{eJz7f46BgeHcfxAJpBmoAqCG/YcYDQAEYgptYgAAAA==}] 0 
			'btn-hover make image! reduce [7x14 decompress 64#{
		eJxjYMAJ/t2fBUHIIn8uVUEQXBwiCGQQFIRoRGYAwa/jiUCEzACCn/u8gQiZgUvw
		xxZTIEJm4BeEI7innk6HIjwAAIQnZMEmAQAA
		} complement decompress 64#{eJz7/x8KGBgYICSIBmIyKbgxMHP/AwCiPjHPYgAAAA==}] 0 
			'exclamation make image! reduce [48x48 decompress 64#{
		eJztmKGbqloUxdsEg8FAMEyYYDAYCASDwWAgGAwEg8FAIBgIBsIEg4FgIBgIBAKB
		QCCccAKBYDAYDAaDYcINN7w/4IXxLUAQQRn16tzvfu+ebwcDM/xce++193G//3v+
		yLNZGJuFtvanK6qs6Pg7gsgLR/RM3tVqxNHTMKuFvV3q28Vs7SkrIi1dcekOwxCf
		GM7At3ii1XSF0VXhRBxf2yzUtTdZutLCFnyr+x1h8nTOGu/M+7AyGtRO9CHyioyW
		zhDAVOfwGJk3osDnZ0Twz7WaNWEmYmXAl3udaprHdyQAe2YbT7qzN3f2+uxw1Ko1
		qaojRuyVO1yp26mneTx3Ro02lAG2q4U8ahV/4j4hnDDsaRVlg0z12mWuXpJHgxMe
		j1JrmMgY8TwJKeJBpmYyI/XKba7U4l5N46S/AiRiUr0V8tSvlOgzd2ZjFt+6+K8y
		4rC1l7E8pJTmLQgSHcr4OonyPHy7JvcreF2BMgdxwsppsRCnatvWWUv0iE719vUS
		neVBs1iFPJE4yqDSa5XYWgniEOKe50EZWVIoUT2U6Aukm3gSccwJo0qVYbfcbJSa
		bNVx7LMwMRKhppBCejAPxJmPmfGgwjdLjbeXuaZCgwKeoIqcCdWbh6wVSvTPz12G
		B6/AF8/Xz1Gcd2YqBQYIcTqtGiGkGCaQiDqxRI20RHmk7dpLw3zstuAZCeX8k4k4
		2phBwafE8b7kCSWaHnv/skTrhZ3mWfge3oJcXBIHowrTod+BOOV+r3UNSSyRS81+
		porySD5R0zy2pYMHb7zQ41VNZqAepgNbLxu6dj1PJBFJquhC7xNTPDFDVQGPOjrD
		kxigEE6HXpe7CWYfNZotn1RRrNIx5t00z0gSYLYQIc8TGWAwHQIDfNXns1t59tEE
		MTr5wj6+a8ameYRuE8MIOpw3wGA6lLhGWZb6d8AEPBQSKfGQPRR2mgcv+vz8N+Fp
		sgzSAbvL8AQGGE8Hvl23LfM+nhDJLpAIH7Dooq0Qvk9RPMhIYj4ZA+y2IE5FkcW7
		YfbRHuJMCqoIX7zVCMwEgUKF1zl5ccLpgMd6PHdpdN6ARKyDF+UmyG7twKJ//tj9
		CGOz9tFBVpivQxmH4sAAIU6j9qKMxSsNsFgiz52nJDr2/sf21J8/dpAIirlxpozU
		dOjyrPULlZNBiu3xpIp2mywPsoZF4tQAK51msOSo0/dfFyfh8YgR3ziO9niWZxzy
		ROLAq4UODPBFHHYvLTn3Inl5iQp4MuvxfQZYzAN7JMEFhE0kguWiYKLmSgIFk1mP
		cXe4Zq+4HYlmFuzgAiUF7YMiQeADEoQ0pQ0QG6A+v210Xs0TSjTnCoZsfj1GGZ+9
		OzwKiVqjKGVpe3Ry0yEyQGyAj+rxi0jYHuNVLbM9ZqYDDHA6VZ5ROSc8kMh+PytR
		Zj3G6HQd51GeU4SEuW908xIl0yFajyHOl3eHR51wyHLpa1p6PQ42QJ4j7iMNsPiE
		C/Yg5KknvR8YoBAYINbj/O8DT0fCkEVhA0Z7gzhJj6OMhwP+m2H2h94Xs5lqYOli
		0OPP85yCQ13dngU/sAAmMhxkKvPL0jcf11S0cR23KvQUWy8N+78hU5ljGRNRqPIt
		BveL383y9/zfz3/jwCrnABsAAA==
		} complement decompress 64#{
		eJzl0zEOgDAIQFHvf2kcTIypQPsSB43M73dQiHjdbOuD/JdevycE+sPQ60bgCunK
		2Y7qTuMR6NHgld04+zZIOPsuQJ/yJkBf8CooOfs0aDj7JGh5Ejzsx2DGh2DOA/k1
		WOKh74fpM1jmRwD8Q7MDrjR9uwAJAAA=
		}] 0 
			'help make image! reduce [48x48 decompress 64#{
		eJztmC9s42YYxtnAgYJIizQDAwMDAwOD6GRgYOCTDAIMDKzJICDSGVhagEF0MjDw
		pKiKtEwyMAgwCDCItICAgIIDBQMHDhw4UFBQUE0FB6qpYN3zfV/SOXbsuLnu0H16
		VblJav/yvs/7r4+P38/Ln+Vmla2WyXIxyedRlgTz6SidjJJJkJ6H89kkS9N88Q0w
		Vpv1Yr2crSjGIg2z3wHgJ796STychYNp6E7GThzYsGiEiyCZJIs5/ur/IMk2fySr
		xZSSwCHAGM4iBmBFv8D6oQ8zQ4/Y+K0xHhILBm4cwGMvRbK+2OSbdbrOf1tmhCQ9
		BwYY8Gg8Thu5qu/0fEfxbGK+jWt19DOMvEUvyCu+A6qvD+LqYkPdkiNA8AkiAj/o
		wQCPkD1LGvaFgcm7RtHwijgw8RZM8SzGyT6MX8Nk+pUwUEu0SKAQRoKbH8Q4aEU2
		XPCOLg36/iQ8GQYxGs9n7nSM0CAW7UlKVMzIr7YuOm+8+N1pMIiRMwngFjj8BJID
		5uicrT0L6SlMgEHmQpCnuaWeR+csTbKNcDZpw8PyGrUFnmEwL0Oy4yFIlsb1Vdk2
		0mzeDIPUTtY58hqphDC9MEwhZODpGj3LHzbzzNdLpDZqHQpas2aQ8vEiXV++/3T1
		+frmGnb54c/5KrfHPr4+8cMxF4FHMNWoPmqLzQqyGWczyAaPa4BJV/nDP7Xnw6eP
		2sBuomIuMl93dUV37ToeFOE4n3uzSA+GDZFaXl7Us2zPl/t73bEQlMNIeBGqRsh0
		hdOVeHagSC7WK1Ztmp2DPn4Uhp2r66uuInKWWusiGrIOdO0NqjzIKegBdRilr8E5
		N7e3pef+/fDw/vL956urKpLrDfG4OhchZF2z19VkQe9VeSBjKAf9Gjle5xz00KoT
		BEX+oduB5ctl6d10Pn8lckRIh+5GCpH5uqPJHUWMpnuqztZLOAexQJNC16tzDmat
		0hOHIx8kZyKP2/rRuPTuIs/xLpxQGzJICDw9cTDy9pS8JAUQg0RzsCTXVC3Tcp3R
		eDxNktV6JfaUV3wXXxONEolf4vGD4AiPRSQNHsOxijxTOk6gb2qBKza0BlsnClRE
		RAEYeBZ+wjPK0PpYgbn7csfLEqHtN0qa8si6WuTBDIxgObRbHWlVrHTQgk/UaPY0
		37m9+6sqcnvgArjTk6CTIzxIQ0Uq8sA5bMJBpjfBVAyj6f39fRXGoTBEzHUlqMBz
		pohQYJEHzsFATsVst4dBZK9vb0ow8JVh9QmMwBHlNDYOyiOfycKZsM+TTNBAkc7P
		4qnWRlQnWe2xjDsCs9Mz5AceThb34pWeo/IQHv8ZPIuLdYnHtC0CI/FNYSry9NWO
		KuHzkrpXElFYIGaIobmNlizf54FsaJi6rWAoD3wIwcOZet/cK85Zascj8GAxacr3
		fVOHtm6ZuBUzzTRIQmk1DaLqHPQLgyQXlIbOslcP84yscuO3zxoIzWBoei5KmW73
		mXWR3XXV5qCYIR5JQI2K4qjUv5BcKM7gkev7RcmqySWb+nEZu7t5A82LBIvjROGx
		ckazGAMqeJBiLSV0fVPmkXoK9NlKyWTYUJBZcE7fOTySGTueliHDjFrlQXHj6wpy
		0Tkss0SuI3BRHB/kcekk9g14tmWZOkc19IMwONMsZfppuXCdwrMbw6AcUsBFPozK
		Si6eQRyIdOluwwMBsEmsaLUDobtbBvu0Jkv8K+5H1M8GGHZ6rVvGtoCo0pOR+bxu
		rdjBsIYFGF4WkzQ5yhMmUwxXbEvaWju8I5rZLRRMNsjxIBwfhcHZbDb+JBRdk8w5
		9ldTse2PLaTMM3wXshl4b9vAPB0vfic6b8jcBbO1U6jY5+l/D4iAtdNhnpAk28D3
		Isao7HZUBRIWI1KHqYARptNgHmngwtmEIGGxNXr4+QS2F8eS2buBlvwVUTtxi8Cd
		8T9BwNAMbnsaDztpNrf8IRZ/fE1iBpmZd2zqNqBbU7dDtaHQLYaQoAKDpCvwSO02
		2dTyYF/D4o9dmzyIGi62hFujryPrexJGCNK1QSKQdoAK3Fz0Tj5Y/LFrY73FhvKf
		4ekwuAIm8Riuzmh0OElAo6zrTS974C5slJh8sDdhVaEMPGZgjJ0YzDBcVeeZ7+dF
		zr+GHRxwABsAAA==
		} complement decompress 64#{
		eJzt1TEWwCAIBFHuf2nSalzAyQs2CfWfTtD99NgwCNeN0EmgdVjEXAYZF0HOl6Di
		t6Dmc7DjDXLsDXLsDfJ2b5D//gO+/X3SfWnbx8f3hN6rjnvo80CO/wvs8X8XFpHW
		RaaXpMSvzwUYKd89AAkAAA==
		}] 0 
			'info make image! reduce [48x48 decompress 64#{
		eJzd1vFLE1EcAPA/IbCoLLRgTSpqQ03X3GLUNd20lbFqDBuGSbNVTnaMNXM0LDmG
		zhEqEcFIA10m5ZzdUuuH9F+JfumPWF95dRw3tr17vbsnfvn++O7uw3vf971vqbQP
		Y2GpIBY3WSv+xsrqN+HVx8jYm8L6V9aW0npxez73fSLzIRBK9wbG82siQ4y4sbOc
		33n9Toy/nL81IFjdvPtOjBUJYd6+33iRzj2IzHb7k+Bp40JMSArMzf4JzvsMPO3O
		Yf1JcsxQdA5h7NdiHd1R/UlVMCj1JNXE6EnCxOhDUoXRmkSA0Y5EjNGChIMJ8jOQ
		g+E0pMefsHSNaETC3Bn5I5mZ7Nn22/B16iT8Y5I/JaSmjzSYmh336R6cqppReA4c
		bDTb+ynWktoChgMCg5T1J1taLwdplTfBberxjTqvBx2ddyHNVq/JFiivHzIS2dX+
		+eu39AY+ngJP+RWrROryRiqRCsUfuc/bBH1G7gk+DDcYbfCh2n3JFYFlUPmcJ1RO
		Wv60lV3cmst+GZ9akuYZzKan8Bw6dqZK/cg9sOy8ta+p2WPj/Kv5gvSS3MouIzm5
		GE1mobOp7cAEHrQ5gDllcsN+whXou/dYvj9CZsE3mAKJy/fccSOOjyHwIAyUmeFc
		Z/2JlrrDhos2pygqj4wfm4WVu+nmITXyyDHQOaE/WDqulGNQjDydhsVQ+UhF3aMK
		gyIcm1JLwvQQYMhIOB5iDAGppuc/MWpJ1T1UMKpIVTwUMfikSh7qGEwStFn5vNHY
		ZL/AhTTC4JDarj6CEcho7oE83doLv0j079YIg0OifptokXTD4JB0xlQnMcFUIjHE
		KEgo2WIkEvQ9kKCxEw1XrDD/SJPQbQADnYc5BsUTXoCBHGbguqNG5hgUQ8OJ4waL
		9ZJrL2BQjCaEvYPZ3/EHNW90ggAbAAA=
		} complement decompress 64#{
		eJytlkEOwCAMw/L/T8N1okmYJTguNq0mrd1aT44EcSRISJCQICFBQoKEBAkJJ34R
		Jl4FhxfB41FIeBAyboWRd2HeVyuY+q2l1rsR/uAfwWdRCHelCqk2eNx4ej/uH7+f
		EGXcZwW3YcNdWnETd3zmFxx/v3g+4PmD5xuen3g+4/mP9wveX3g/4v2L9zv+f3h3
		NshYDToACQAA
		}] 0 
			'stop make image! reduce [48x48 decompress 64#{
		eJztmCGUokAYx/sGg4FgIBAIBAKBQCAQCAYDgWAwGAgGgoFgMBgMBIOBYDAYDAbD
		BsMGwoYNFwwGw4YNGwwbNmwwGLz7z8zJ4QHiHureu3e87+3bhdmZH//55vvP8P37
		/+vfvFbT6TIIvvn+U6/31O2ejsdOJ2y3F83mvFa7CsxsthqPvw0Gj91u6Hmh656O
		B9clMJY11bSxYVwWZj2fryaT5XCIt35otRaNxn29nhuAmZnmRFECSQouh8RgoAz0
		xyizanVqGFNdzw9Nm6jqWJbBMxDFoa5fFoaIr+t4XwxxbkjSCOJI0lCSfFEMTLMQ
		DHImC0aSzo840vBPkX7BuG4RmCMkUSQqWdbXwiSRRpYVhuEXwqQg2fY5SNeDSUFq
		NL4WJo40yEMCCavABVfTp5B6gjBynFQe4k2wg04HRe+qMBESeLqC0Ob5YauV5IFR
		wptgB6zIp5KgMn9sNvv9frfd9g2DCJ5oA+fa02v9+NhBwclGwiPwODxfr1SSPHBt
		4siNBsTJUobobFn73Q7DPa/XdUEAUrwB3gWoeLp5fdV43iyX+8cNjnhE0ROERqVS
		5bgkDzFu12WTdWKa0H/Q6TAFFrMZeosUgFu9rdfkwW5nG4Z4d2dXKoNsngHlgThG
		uZzDc3LeO4Iwn0wYUt/zXJ4P6COYXXQTMMZJcRgPksfmOK0Az5guDQ+jr1ZMima1
		CsKw241EA4xcKuFmMruuwcNS0dO0j/d3ALxtNp5t72hSvTw/KxwHnki02/Cw3nr1
		+j52bbfbqqIAJp5UN+PBXPSQHv1+xOM5DmCwWPyTaXMlHoZ07/u/8eSmzfV4sGNn
		tSg+X1/FQ2r12xswkNUO8pmWwdeXF5sa5a15ZHmzXDJZHMsi09RqsT/DxaJ+83xe
		jkZs9MD3AYMOYUPz8ZjdHPR6rRuu98gxn8JQKpXAg7IPQdqCsGaioUjWareph3DM
		7ccHc0xdEADjHKQgdVtV32lS4acty/20DUCcB2XT4ji1VErhoWfPHB5FiRyzbprE
		MTku7phkS2PbbNFBK5vnU/10RAO0eBfUKyWN5+jEncGT65hslNGhSM7G42Yit0eH
		zRhmmU2WdHeX5MHO5+eJG4fcDB4s5Bq1J4Sa4ZhsA6DSvELUjst1tFPt0p2PXi6z
		ZkmeOdum0hN31qQHdEeHtYOAWWStINzvHZqhfZCAAXDzAKMJQhKGzNd8PjGMgP4L
		kzR31X8q4jCNPJgIKdD1Ad30BhdFSoUxZfkETIQ01LTLIqXDKEouzC8kw7gUUgTj
		xWBqqnomzE+k+/uhaRZHYjD+Yd+uURjrjz5MEaRiKqXC2AU+3D0sFlAJHRIqCjak
		v58ZPj0OuweHIvvYwt9aGVKPli9ko0ePt2cGig8SpkbtidicbReEiZB8w0D/Du0f
		Rzy8b27AJUECQ1EoTCvv08pnkTqmiSFw/sUC0c4LyCJTmHazeUGY/9dfdf0As7+1
		bQAbAAA=
		} complement decompress 64#{
		eJzt1CEWADEIQ0Huf2nWta8tCWQVguj5Etw7z96JnAUhxwHgKIA8DgiPAsrfIOF3
		kfMjqHAT+Q6KfAVlb+PHj2/jxfsV/8n/9ya/zzzweyLnQcBZEHIcAI4CyFvsA5uL
		FhUACQAA
		}] 0 
			'check make image! reduce [13x13 decompress 64#{
		eJyNyjEOABAMBdCLuJQbuaaRGDB1MIhJp6ahfiRvfM4H96fkeGg1MaLOxiCzHcds
		97mbedaaur2ObuBIw0c3cKThoxs40vCR9mMD5Bt/d/sBAAA=
		}] 0 
			'check-on make image! reduce [13x13 decompress 64#{
		eJyNzzEKgDAMheEepJfyRl7DozkqDurUoYN08kEgPF6jFP4p+SAkT3Me69hX6To3
		VMqNai0hExMyNmlJIRNjrLWHGYZiEAwzAJv3xpnd8q0YZuEtYfx7b5iZsb++2L9x
		NtILlaNQwvsBAAA=
		}] 0 
			'check-down make image! reduce [13x13 decompress 64#{
		eJyTCWyQIQ4dP7oJE508vguIrl85BUS4lCGrwaUMTQ1WZZhqnjy6iaYMTQ1QAQQh
		K8OlBlkZLjUvXzyEK8OjBoLgyvCogStD8xeaGkxlWI2CKyMGAQBEtVT++wEAAA==
		}] 0 
			'check-down-on make image! reduce [13x13 decompress 64#{
		eJyTCWyQIQ4dP7oJE508vguIrl85BUS4lCGrwaUMrkathgOXMmQ1EGVPHt1EVgYU
		RFMDREA1mMog2tHUICsDGgKXRVbz8sVDuDJcdgHVQBBcGdzvmGrgyuBqIP5CU4Op
		DO5mrMqIQQDKcy89+wEAAA==
		}] 0 
			'check-hover make image! reduce [13x13 decompress 64#{
		eJyTCWyQIQ79uz8LiP5cqoKjX8cT4Yyf+7zhyrCqgXORTXvy6CYQvXzxEIg+fHgF
		RF++fMCqDE0NmjIgG6gMUw0uZWhqfv36AZSCewGiDFMNEAHV/NhiClcGRJhqgAio
		Bq4MaDsQYaqBKHs6nQGiDGgyECEHF8QuCEJTBlEJCXa4AiCCW0oMAgCf8VCt+wEA
		AA==
		}] 0 
			'check-hover-on make image! reduce [13x13 decompress 64#{
		eJyN0DEKwkAQRuE9SK6RU6TKEbxGKm8RzDmsbe3tUomioFZbpIiLiA8GfoYhQuAV
		m+RjhmzVbqt1fc8DfU6dKseNDu9DI7Zo9Oin3a4jPR8XyvlFaZcWWTCBcYbxMph/
		jLwpZeaTfsEzbwgz72sxCnMsjBjbaZoyeWPs3idjTCZ/XbbLCsykXbsAaemaflF5
		Ifj7AQAA
		}] 0 
			'radio make image! reduce [13x13 decompress 64#{
		eJxjYEAFxmlQhAuAZbtXPoUg7IrBCp48uglEL188BKIPH15BFeNVA0RfvnxAUWmc
		hlUNBEGVwYzCqubXrx9wdwIZuNRgKsOqBqEMbC8uNUCE7AWgFqxqsIYJATXExwKh
		OAUAEev+zvsBAAA=
		} complement decompress 64#{eJz7/x8IGBgY/kMBAwQgs8E8BgYkHjKHgTiA2wBUe1BdgOQ2AOGaL9GpAAAA}] 0 
			'radio-on make image! reduce [13x13 decompress 64#{
		eJxjYEAFxmlQhAuAZbtXPoUg7IrBCp48uglEL188BKIPH15BFeNVA0RfvnxAUWmc
		BlejdEABgoBqIAiqDGYUXA3DTAYgUqvhAKr59esH3J1ABsQuuBqIMqAaTGVAxyAb
		ha4MbC/czRAFcDVAhOwFoBa4m+EKUIxCVYlPDfGxQChOAaSW03/7AQAA
		} complement decompress 64#{eJz7/x8IGBgY/kMBAwQgs8E8BgYkHjKHgTiA2wBUe1BdgOQ2AOGaL9GpAAAA}] 0 
			'radio-down make image! reduce [13x13 decompress 64#{
		eJxjYEAFxmlQhAuAZVPa70AQdsVgBcePboKgk8d3ARFUMV4116+cAiIUlcZpWNVA
		EFQZklFoap48uglEcHdClGFVg6YMl5qXLx4inGechksNECF7AagFqxqsYQJXhl0N
		8bFAKE4BH9rfvvsBAAA=
		} complement decompress 64#{eJz7/x8IGBgY/kMBAwQgs8E8BgYkHjKHgTiA2wBUe1BdgOQ2AOGaL9GpAAAA}] 0 
			'radio-down-on make image! reduce [13x13 decompress 64#{
		eJxjYEAFxmlQhAuAZVPa70AQdsVgBcePboKgk8d3ARFUMV4116+cAiIUlcZpcDVK
		BxQgCKIMiKDKkIyCKGCYyQBEajUcTx7dBCK4OyHKgBbB1eBSBnEPslEQZS9fPEQ4
		zzgN7maIArgaIEL2AlALRBnEIrgarGECV4ZdDfGxQChOAWy6vA37AQAA
		} complement decompress 64#{eJz7/x8IGBgY/kMBAwQgs8E8BgYkHjKHgTiA2wBUe1BdgOQ2AOGaL9GpAAAA}] 0 
			'radio-hover make image! reduce [13x13 decompress 64#{
		eJxjYEAFxmlQhAuAZXfPDN25dSWQxK4YrODli4f/7s/6c6kKQkIVY1PzY4spkAEk
		f+7z/nU8EUWlcdqvXz+AaoAKgOjDh1dA9OXLB6AyoGKoMrBRcHPgaoAIYibcnUA3
		A12CpgZk2q8fQJVwZXDTMNUgTAPbCzQNKIKsBqIMiJC9ANQCdDAQAcXhChA2ooYJ
		0EAggtiFRQ1qLEAQMVGGqQAADGnb7vsBAAA=
		} complement decompress 64#{eJz7/x8IGBgY/kMBAwQgs8E8BgYkHjKHgTiA2wBUe1BdgOQ2AOGaL9GpAAAA}] 0 
		'radio-hover-on make image! reduce [13x13 decompress 64#{
		eJxjYEAFxmlQhAuAZY8f3bRz60ogiV0xWMHLFw//3Z/151IVhNw9MxRFJZIaIPr/
		/z+Q/LnP+9fxRBSVxmm/fv2AKFA6oABBX758ACoDKoYqAxsFMQeigGEmAxCp1XBA
		zIQaaJwGdDPQJRCjIGogyoBW/NhiCleGbBpcDbppYHuBpgFFgO6BKIAYBRQBmobs
		BaAWoIOBCGgCxDsQNZhhAhQBSkFksatBigWgFAQRE2WYCgCa/bnw+wEAAA==
		} complement decompress 64#{eJz7/x8IGBgY/kMBAwQgs8E8BgYkHjKHgTiA2wBUe1BdgOQ2AOGaL9GpAAAA}] 0 
			'arrow make image! reduce [13x13 decompress 64#{
		eJxjYACB/7gBAwwA2WuOfMKFICohai7c/gpBR69A0e6zUARRiawMUw2mMqxqtp38
		iKwMroYYZcgKcCnDVANxGLIyrGogRuFXBlSDyzSgFATBw3bpnndoIYw/FhiIi1MA
		qIGXl/sBAAA=
		} complement decompress 64#{eJz7/58BBv7/R7CBPIaBACgu+I/sNgD42gv1qQAAAA==}] 0 
			'arrow-down make image! reduce [13x13 decompress 64#{
		eJxjYACB/7gBAwwA2RXz3+BCEJUQNdtOfpy27T0mWnPk04XbXyHGApUBRYAqIQgo
		BUdL97zDqgxZDS5laGqwKsNUM0iUQUSwIogySAgD2bgQWnzhj1MAWkiJM/sBAAA=
		} complement decompress 64#{eJz7/58BBv7/R7CBPIaBACgu+I/sNgD42gv1qQAAAA==}] 0 
			'arrow-dark make image! reduce [13x13 decompress 64#{
		eJxjYACB/7gBAwwA2S5pfbgQRCVETVrHbgiKa9gAQaHlSyAIohJZGaYaTGVY1fjm
		z0RWBldDjDJkBbiUYaqBOAxZGVY1EKPwKwOqwWUaUAqC4GFrE9eEFsL4Y4GBuDgF
		ALj3GKL7AQAA
		} complement decompress 64#{eJz7/58BBv7/R7CBPIaBACgu+I/sNgD42gv1qQAAAA==}] 0 
			'arrow-dark-down make image! reduce [13x13 decompress 64#{
		eJxjYACB/7gBAwwA2cYuabgQRCVEjW/+TOPQckzkktaX1rEbYixIV2g5UCUEAaXg
		yCauCasyZDW4lKGpwaoMU80gUQYRwYogyiAhDGTjQmjxhT9OAZ6CA8X7AQAA
		} complement decompress 64#{eJz7/58BBv7/R7CBPIaBACgu+I/sNgD42gv1qQAAAA==}] 0
	]
	;-- Legacy image variables:
		logo.gif: load-stock 'logo
		system/view/vid/radio.bmp: load-stock 'radio
		system/view/vid/radio-on.bmp: load-stock 'radio-on
		system/view/vid/icon-image: load-stock 'icon-image
		btn-up.png: load-stock 'btn-up
		btn-dn.png: load-stock 'btn-dn
		exclamation.gif: load-stock 'exclamation
		help.gif: load-stock 'help
		info.gif: load-stock 'info
		stop.gif: load-stock 'stop
	]
; view-feel ; this is vid-feel
	view-feel: does [
	; patched "to integer!"
	system/view/vid/vid-feel/check-radio/redraw: func [face act pos][
		act: pick face/images (to-integer face/data) + either face/hover [5][
			1 + (2 * to-integer face/state)
		]
		either face/pane [face/pane/image: act][face/image: act]
	]
	]

; view-startup
	if error? try [curr-dir: what-dir change-dir sdk-dir][sdk-dir: none]
	view-object ; do patching

	unless none? sdk-dir [

	do %gfx-colors.r
	do %gfx-funcs.r


	do %view-funcs.r
	do %view-vid.r
	do %view-edit.r
	do %view-feel.r
	
	view-feel ; do patching
	
	;do %view-images.r
	view-images ; do patching

	do %view-styles.r
	do %view-request.r

	;-- Must be done prior to loading anything that requires fonts on Linux.
	;layout [text "imanXwin kludge"] ;-throw this one away soon-- okay?
	
	change-dir curr-dir
; view-vid
	base-effect: reduce ['gradient 0x1 base-color + 20 base-color - 40]
	
	svvf/choice-iterator/over: func [face state] [
		face/selected: to-logic all [face/selectable state] ;;;; patched for R3
		show face
	]

	; make an unbound copy of ctx-text/edit-text and patch it
	change
		find pick find pick find b: load mold body-of :ctx-text/edit-text [if word? key] 4 [do select] 3 [del-char]
		[delete]
	; re-make and re-bind the func
	ctx-text/edit-text: func spec-of :ctx-text/edit-text bind bind b ctx-text system/view

	svv/vid-styles/text-list/text-pane: func [face id] bind [
		if pair? id [return 1 + second id / iter/size]
		iter/offset: iter/old-offset: id - 1 * iter/size * 0x1
		if iter/offset/y + iter/size/y > size/y [return none]
		cnt: id: to-integer id + sn ;;;;; patched for R3
		if iter/text: pick data id [
			lines: at data id
			iter
		]
	] svv/vid-styles/text-list
	change find svv/vid-styles/text-list/init first [:self] 'self

	svv/vid-styles/text-list/resize: func [new /x /y /local tmp] bind [
		;-- Resize function. Change all sub-faces to new size.
		either any [x y] [
			if x [size/x: new]
			if y [size/y: new]
		][
			size: any [new size]
		]
		pane/size: sz: size
		sld/offset/x: first sub-area/size: size - 16x0
		sld/resize/y size/y ;;;;;;;; bug fixed for R3
		iter/size/x: first sub-area/size - sub-area/edge/size
		lc: to-integer sz/y / iter/size/y
		self
	] svv/vid-styles/text-list

	change skip tail svv/vid-styles/list/init -4 [
		pane: func [face id /local count spane][
			if pair? id [return max 1 to-integer 1 + second id / subface/size] ;;;;; patched for R3
			subface/offset: subface/old-offset: id - 1 * subface/size * 0x1
			if subface/offset/y + subface/size/y > size/y [return none]
			count: 0
			foreach item subface/pane [
				if object? item [			
					subfunc item id count: count + 1
				]
			]
			subface
		]
	]

	;;
	; WARNING: MAJOR PATCH !! (necessary since I can not modify a function without modifing its context)
	;;
	change/part find svv/vid-styles/text-list/init [act: :action] [act: all [action make function! action]] 2
	
	append svv/vid-styles/field/init [if block? action [action: make function! action]]
	;set 'layout func spec-of :layout bind bind head insert back tail body-of :layout [probe new-face/action if block? new-face/action [new-face/action: make function! new-face/action]] 'system system/view/vid
	
	; WARNING: MAJOR PATCH !! (necessary since I can not modify a function without modifing its context)
	svv/vid-face/multi/block: func [face blk] [
		if pick blk 1 [
			face/action: reduce [[face value] pick blk 1] ;func [face value] pick blk 1
			if pick blk 2 [face/alt-action: reduce [[face value] pick blk 2]]
		]
	]
	do-face: func [face value /local action] [ ; (needs to work for functions and blocks)
		either function? action: get in face 'action [
			action face either value [value][face/data]
		][
			do make function! any [action [[face value][]]] face either value [value][face/data]
		]
		;do get in face 'action face either value [value][face/data]
	]
	do-face-alt: func [face value /local action] [ ; (needs to work for functions and blocks)
		either function? action: get in face 'alt-action [
			action face either value [value][face/data]
		][
			do make function! any [action [[face value][]]] face either value [value][face/data]
		]
		;do get in face 'alt-action face either value [value][face/data]
	]

	request-file: func [
		"Requests a file using a popup list of files and directories."
		/title "Change heading on request."
			title-line "Title line of request"
			button-text "Button text for selection"
		/file name "Default file name or block of file names"
		/filter filt "Filter or block of filters"
		/keep "Keep previous settings and results"
		/only "Return only a single file, not a block."
		/path "Return absolute path followed by relative files."
		/save "Request file for saving, otherwise loading."
		/local filt-block
		][
		filt-block: copy ["Normal (*.*)" "*.*" "REBOL (*.r; *.reb; *.rip)" "*.r; *.reb; *.rip" "Text (*.txt)" "*.txt" "Images (*.jpg; *.gif; *.bmp; *.png)" "*.jpg; *.gif; *.bmp; *.png"]
		if filt [
			filt: compose [(filt)]
			if (length? filt) > 1 [
				forall filt [append first filt ";"]
				remove back tail last filt ; remove last semi-colon
			]
			filt: form filt
			insert insert filt-block rejoin ["Custom (" filt ")"] filt
		]
		; FIXREBOL: request-file with a dir name does not work
		apply :native-request-file [save (not only) file name title (form title-line) true filt-block]
	]

;
	] ; unless none? sdk-dir
; view-funcs
	; The View system handles windowing, events, popups, requestors, and modal
	; operations.  Normally VID provides the contents for these, but users are
	; also allowed to build and display their own windows directly.

	view: func [
		"Displays a window view."
		window [object!] "Window face"
		/new "Creates a new window and returns immediately"
		/offset xy [pair!] "Offset of window on screen"
		/options opts [block! word!] "Window options spec block or flag"
		/title text [string!] "Window bar title"
		/local screen win-face
		][
		if not screen: system/view/screen-gob [return none]
		; FIXME: if not all [in window 'type window/type = 'face] [make error! ...]
		; add gobs to faces
		win-face: make_gobs_from_face window
		;win-face/parent-face: system/view/screen-face ; avoid this to make "win-offset?" work

		; create window gob (otherwise back color is not shown)
			win-face/gob/offset: 0x0
			window: make gob! [
				size: win-face/size
				data: win-face/gob/data
			]
			append window win-face/gob
			win-face/data: window ; store "real" window gob
		;
		opts: compose/deep [flags: [(opts)]]
		if win-face/options [
			win-face/options: compose [(win-face/options)]
			if find win-face/options 'resize [append opts/flags 'resize]
		]
		win-face/face-flags: opts/flags ; store these because they are filtered by gob

		; Convert option block to a map:
		opts: make map! any [reduce/no-set opts []]

		; Window title:
			window/text: any [
				text
				opts/title
				win-face/text
				all [system/script/header system/script/title]
				"REBOL - Untitled" ; never reached because of above ?
			]
			if not find opts/flags 'no-title [
				; erase top face text because it is now on title bar
				if win-face/gob/data/gob-text [win-face/gob/data/gob-text/text: ""]
			]
			if text [win-face/text: text]

			;!!! Add later: use script title - once modules provide that

		; Window offset
			; FIXME: add metrics/border to offset ? or let user do it ?
			; FIXME: should default to centered ?
			; FIXME: add 'at-mouse
			window/offset: any [
				xy
				all [
					opts/offset
					do [
						; 'Center is allowed:
						if word? opts/offset [
							opts/offset: either opts/offset = 'center [screen/size - window/size / 2][100x100]
						]
						opts/offset
					]
				]
				win-face/offset
				50x50
			]
		; Window handler
			either opts/handler [
				handle-events opts/handler
			][
				; Set up default handler, if user did not provide one: ; FIXME: should provide this anyway and let user override or remove it
				handle-events [
					name: 'view-default
					priority: 50
					handler: func [event] [
						print ["view-event:" event/type event/offset event/code mold event/flags]
						mimic-do-event event
						if switch event/type [
							close [true]
							key [event/key = escape]
						][
							unhandle-events self
							; event/window is the gob, event/window/data/gob-face is the window's face
							unview/only event/window/data/gob-face
							;quit ; close console (but is it useful?)
						]
						;native-show event/window ; FIXME: is this necessary?
						none ; we handled it
					]
				]
			]
		; Other options:
			if opts/owner [window/owner: opts/owner]
			if opts/flags [window/flags: opts/flags] ; FIXME: iff resizable gui add 'resize

		; window's feel
			; Use window-feel, not default feel, unless the user
			; has set their own feel (keep user's feel)
			if all [
				system/view/vid
				win-face/feel = system/view/vid/vid-face/feel
			][
				win-face/feel: system/view/window-feel
			]

		; Add the window to the screen. If it is already there, this action
		; will move it to the top:
		unless window = screen [
			append screen window
			append system/view/screen-face/pane win-face
		]

		; Open or refresh the window:
		native-show window

		try [if none? win-face/user-data [win-face/user-data: reduce ['size win-face/size]]] ; useful for resizing guis
		win-face/feel: make win-face/feel [old-size: win-face/size] ; useful for resizing guis
		ctx-do-event/last-size: ctx-do-event/prev-size: win-face/size ; init

		; FIXME: if two windows open rapidily we could receive wrong input, should I flush some events?
		; Wait for the event port to tell us we can return:
		if all [
			not new
			1 = length? screen
		][
			do-events
		]

		; Return window (which may have been created here):
		win-face
	]
	protect 'view ; alarm if someone tries to redefine this

	unview: func [
		"Closes window views. Last opened by default."
		/all "Close all views, including main view"
		/only window [object!] "Close a single view"
		/local screen 
		][
		screen: system/view/screen-gob
		if all [native-show clear screen exit]

		clear ctx-do-event/timer-list ; FIXME: should erase only faces of this window...

		; FIXME: is it better to be less (in)tolerant and give error if invalid window ?
		window: either native-all [object? window in window 'type window/type = 'face in window 'gob] [window/gob/parent] [last screen]
		remove find system/view/screen-face/pane window/data/gob-face ; 
		remove find screen window ; none ok
		native-show screen ; closes it, none ok
	]

	request-download: func [
		{Request a file download from the net. Show progress. Return none on error.} 
		url [url!] 
		/to "Specify local file target." local-file [file! none!] 
		/local prog lo stop data port
		][
		view/new center-face lo: layout compose/deep [
			backeffect [gradient 1x1 water gray] 
			space 10x8 
			vh2 300 gold "Downloading File:" 
			vtext bold center 300 to-string url 
			;prog: progress 300 ;;;;luce80: this currently does not work
			across 
			btn 90 "Cancel" [(bind [stop: true port/spec/timeout: 1 wait 0 close port unview/only lo] 'stop)] ;;;; patched
			stat: text 160x24 middle
		] 
		stop: false 
		if error? try [port: open url] [return none]
		port/spec/timeout: 2
		data: attempt [read port] 
		if to [attempt [write local-file data]]
		;;;;luce80: this currently does not work
		{
		progress: func [total bytes] [
		prog/data: bytes / (max 1 total) 
		stat/text: reform [bytes "bytes"] 
		show [prog stat] 
		not stop
		]
		}
		unview/only lo
		do-events
		if not stop [data]
	]

	
	do-events: func [
		"Waits for window events. Returns when all windows are closed."
		/local gob
	][
		;wait system/view/event-port
		gob: system/view/screen-gob/1
		while [not tail? head system/view/screen-gob] [
			if ctx-do-event/pop-ups = 1 [ctx-do-event/pop-ups: 0 break] ; if pop-up closed exit this func returning to the caller
			insert system/ports/system make event! [type: 'time gob: gob]
			native-wait [system/view/event-port 0.02] ; FIXME: which is the right number to give here ? SEE: Note_on_timer
		]
	]

	init-view-system: func [
		"Initialize the View subsystem."
		/local ep
	][
		; The init function called here resides in this module
		init system/view/screen-gob: make gob! [text: "Top Gob"]
		
		system/view/screen-face/size: system/view/screen-gob/size
		system/view/screen-face/face-flags: 'screen ; to be able to recognize it

		; Already initialized?
		if system/view/event-port [exit]

		; Open the event port:
		ep: open [scheme: 'event]
		system/view/event-port: ep

		; Create block of event handlers:
		ep/locals: context [handlers: copy []]

		; Global event handler for view system:
		ep/awake: func [event /local h] [system/view/wake-event event]; use wake-event for VID pop-ups
		comment [	h: event/port/locals/handlers
			while [ ; (no binding needed)
				all [event not tail? h]
			][
				; Handlers should return event in order to continue.
				event: h/1/handler event
				h: next h
			]
			tail? head system/view/screen-gob ; added head to be prudent
		]
	]

	init-view-system

; view-do-event ; mimic-do-event
	{Event! object
		type	word!			A word that indicates the type of event. See list below.
		port	port!			The port for the event. For the GUI, this is the event port; however, for non-GUI ports, this field is overloaded and can contain other information.
		gob		gob!			The GOB where the event occurred. By default, the window GOB.
		window	gob!			Alias for above.
		offset	pair!			The position (only valid for mouse and size events).
		key		char! word!		Key char or word (only valid for keyboard events). See list below for word-based characters.
		flags	block! none!	A block of possible modifiers: double control shift
		code	integer!		The integer code for a key down event.
		data	file! none!		For a drop-file event, provides the file name.
	}
	; most code taken from mimic-do-event.r author: Anton Rolls 21-Apr-2006
	mold-face: func [face [object! gob!]][
		;reduce [face/offset face/size face/text]
		mold face/text
	]
	mold-event3: func [e][
		remold [;e/1 e/2 e/3 e/4 e/5 e/6  all [e/7 mold-face e/face]  e/8
				e/type e/key e/offset e/code all [e/gob mold-face e/gob] e/flags]
	]
	mold-event: func [e][
		remold [;e/1 e/2 e/3 e/4 e/5 e/6  all [e/7 mold-face e/face]  e/8
				e/type e/key e/offset e/time e/shift e/control all [e/face mold-face e/face] e/double-click]
	]
	; grabbed from transparent-events.r Author: Anton Rolls
	copy-event: func [
		"Make a pseudo-event, that you can use in place of an event! (which at this time is unmodifiable)."
		event [event! block!] "event (or pseudo-event) you want to copy"
		][
		; warning: do not use a static block !
		reduce [
			event/type
			event/key
			event/offset
			now/precise ;event/time
			found? find event/flags 'shift
			found? find event/flags 'control
			event/gob/data/gob-face
			found? find event/flags 'double
			'type event/type
			'key event/key
			'offset event/offset
			'time now/precise
			'shift found? find event/flags 'shift
			'control found? find event/flags 'control
			'face event/gob/data/gob-face
			'double-click found? find event/flags 'double
			'block-type 'mimic-do-event-event ; use this to identify this block as an event!
		]
	]

	ctx-do-event: context [
	
	pop-ups: 0
	
	index: 0
	previndex: 0
	currindex: 0
	storeindex: 0

	timer-list: [] ; <- list of (face, rate, time-stamp)
	tface: rate: time-stamp: none
	last-offset: 0x0
	
	remapped: none
	target: none
	target-engage:
	target-down:
	target-down-engage: none
	
	last-size: 0x0
	prev-size: 0x0

	find-face-deep: func [ ; Author: Anton Rolls 9-May-2007
		"Finds the top face within START-FACE's pane, and any subfaces, within which the point OFFSET is found."
		start-face [object!] "a face to search within"
		offset [pair!] "offset relative to start-face (and edge, if it has one)"
		/pane-path "Return complete path (block of faces) from START-FACE to the found top face."
		/parent parent-face [object! none!] "specify parent-face if you know it hasn't been set by VIEW yet"
		/ignore ignore-faces [block!]
		/local full-path sum pane paren face index iter
		][
		full-path: copy []
		sum: 0x0 - start-face/offset - any [all [start-face/edge start-face/edge/size] 0x0]
		;;if start-face/edge [sum: sum - start-face/edge/size]
		pane: reduce [start-face]
		if not parent [parent-face: start-face/parent-face]
		iter: 0

		while [
			remove-each face pane [
				if function? :face [ ; iterated pane function ? 
					face: all [
						; first call the pane with a pair to figure out the iteration index
						index: face parent-face (offset - sum) ; pane function should return iteration index or NONE
						face parent-face index ; call the pane again with the index to get the iterated face
					]
				]
				any [
					none? face ; NONE might be returned by the pane function
	 				all [ignore find ignore-faces face] ; <---
					;transparent-face? face (offset - sum) ; <--- if implemented would make /ignore redundant
					not face/show?
					not within? (offset - sum) face/offset face/size
				]
			]

			face: all [native-pick pane 1 last pane] ; if there is one, get the last face
		][
			either function? :face [ ; is face a pane function ?
				; first call the pane with a pair to figure out the iteration index
				index: to-integer face parent-face (offset - sum) ; pane function should return iteration index or NONE
				; then call the pane again with the index to get the iterated face
				face: face parent-face index
				insert tail full-path face
			][
				; just a normal face object
				index: 0
				insert tail full-path face
				parent-face: face
			]
			;print ["in face:" mold mold-face face index]
			sum: sum + face/offset
			if face/edge [sum: sum + face/edge/size]
			iter: iter + index

			either get in face 'pane [
				either block? get in face 'pane [
					pane: copy face/pane
				][
					; face/pane must be an object or function
					pane: reduce [get in face 'pane]
				]
			][
				break
			]
		]
		insert full-path iter ; place iteration index at the beginning

		either pane-path [ ; FIXME: or use /all or ...
			next full-path
		][					; ... use /only
			pick back tail full-path 1 ; the last face in the path or NONE if empty ; <- assumed to be a face
		]
	]

	set 'mimic-do-event func [{The heart of the feel system. Translates and dispatches gui events} ; FIXME: is it better to not make this global?
		event [event!]
		/local
		debug 
		mapped-gob window 
		win subface
		previous changed 
		path start-path 
		targ iter iterated?
		;remapped
		do-over
		offset
	][
		;debug: func [mess [block! string! none!]][if all [event/type <> 'time event/type <> 'move] [prin ["mimic-do-e  " event/type " "] print mess]]
		;debug: func [mess [block! string! none!]][prin ["mimic-do-e  " event/type " "] print mess]

		; event/offset is relative to the top-left of the window, and window/edge makes no difference to that.
		
		offset: event/offset

		mapped-gob: map-gob-offset event/gob any [event/offset 0x0]

		; check if windows have moved (should be in step 1 but we need original event) (since R3 does not send 'offset event when left or top win borders are moved)
			if all [event/type = 'resize event/gob/data/gob-face/offset <> event/gob/offset] [
				event/gob/data/gob-face/offset: event/gob/offset
				insert system/ports/system make event! [type: 'resize offset: event/offset gob: event/gob]
				insert system/ports/system make event! [type: 'offset offset: event/gob/offset gob: event/gob]
				exit
			]

		event: copy-event event
		event/3: event/offset: offset ; must restore this otherwise it becomes none (!!??)
		event/time: now/precise ; must update this (??)
		; FIXME: adjust event/face
		;if event/type <> 'time [print ["mimic-do-event   " tab mold-event event]]

		window: event/face

		if event/type = 'move [last-offset: event/offset]
		if event/type = 'scroll-line [event/3: event/offset: 0x0 - event/offset] ; inverted compared to R2 !!!
		if event/type = 'scroll-page [event/3: event/offset: 0x0 - event/offset] ; inverted compared to R2 !!!


		; 1) check windows
		; 2) screen-face DETECT
		; 3) window face DETECT
		; 4) check window flags to see if it was just closed
		; 5) process various parts of close, resize, move, and time events
		; 6) check for focal-face events (keyboard or scroll-wheel)
		; 7) The detect functions for faces along the pane path from the window to the 
		;	target face all get called (if they are present).
		; 8) process ENGAGE or OVER

		; 1) check if windows have moved or resized

			if event/type = 'offset [
				;event/offset: window/offset: window/gob/parent/offset ; reset to correct one
			]
			if event/type = 'resize [
				prev-size: last-size last-size: event/offset

				window/offset: 0x0 ; reset this because this is window face NOT real window
				window/text: "" ; reset this because this is window face NOT real window

				if window/size = prev-size [; try to avoid possible infinite loop
					window/size: event/offset
					clear system/ports/system
					show window ; call "our" show that updates gobs ; FIXME: should I do this in step 5?
				]

				window/offset: window/gob/parent/offset ; reset to correct one
				; FIXME: store OLD size in window face (or do it in "view" or store size difference)
				
			]
			if event/type = 'restore [clear system/ports/system exit]
			if event/type = 'maximize [clear system/ports/system exit]

		; 2) call screen-face DETECT (break if returns NONE)

			if all [attempt [:system/view/screen-face/feel/detect] event/type <> 'time] [if none? system/view/screen-face/feel/detect face event [exit]] ; call DETECT

		; 3) call window face DETECT (break if returns NONE)

			if attempt [:window/feel/detect] [if none? window/feel/detect window event [exit]] ; call DETECT

		; 4) check window flags to see if it was just closed

			if not find system/view/screen-face/pane window [exit]

			; Doesn't seem to show anything useful
			;print ["face-flags:" mold window/face-flags]
			;print ["screen-face/pane/1/face-flags:" mold screen-face/pane/1/face-flags]

		; 5) process various parts of close, resize, move, and time events
		
			if event/type = 'close [ ;<- should also explicitly check that event/face is the window ? (below code may do an unnecessary SHOW)
				;debug ["closing window" mold-face window]

				; remove window from screen-face/pane
				unview/only window ; comment this if using handler instead of wake-event

				{;<--- check if subfaces of this window can still be found in timer-list, if so we have to remove them
					tree-face/code window [
						foreach face list [
							if find timer-list face [
								print ["removing face" mold face/text "of" mold-face find-window face]
								remove/part find timer-list face 3
							]
						]
					]
				}

				exit
			]
			
			if none? event/face [
				;print "No event/face - exit" 
				exit
			]

			if find [active inactive resize] event/type [exit] ; these events are not passed down (luce80 note: but they should IMHO)

			if event/type = 'time [

				forskip timer-list 3 [
					set [tface rate time-stamp] timer-list ; we use the stored rate, not face/rate, which might have changed
					event/3: event/offset: last-offset

					either none? tface/rate [
						timer-list: skip remove/part timer-list 3 -3
					][
						if rate = 0 [rate: 48] ; 0 = top speed
						period: either time? rate [rate][to-time 1 / rate]
						
						;if (to-time (event/time - time-stamp) * 0.001) > period [
						if (difference event/time time-stamp) > period [
						;print ["comparing time-stamp" event/time time-stamp (difference event/time time-stamp) period mold tface/text]
							; update the time-stamp in the list to event/time
							timer-list/3: event/time

							; distribute the event to the face
							;print ["distribute time event to" mold face/text "of" mold-face timer-face's-window: find-window face]

							while [
								if all [tface/feel get in tface/feel 'engage][
									tface/feel/engage tface 'time event ; call ENGAGE
									break
								]
								tface/parent-face
							][
								tface: tface/parent-face ; climb up
							]
						]
					]
				]
				path: system/view/screen-face/pane
				forall path [
					targ: first path
					try [targ/feel/detect targ event]
				]
				exit
			]

		; 6) check for focal-face events (keyboard or scroll-wheel)

			if all [
				event/type = 'key ; FIXME: also 'key-up in R3
				system/view/focal-face 
				system/view/focal-face/feel
				get in system/view/focal-face/feel 'engage
			][
				if not system/view/caret [system/view/caret: tail system/view/focal-face/text] ; check caret (is this enough checking ? see FOCUS)
				system/view/focal-face/feel/engage system/view/focal-face event/type event ; FIXME: call this on step 8 ?
				
				exit ; <--- ???
			]

			if find [scroll-line scroll-page] event/type [
				; These are already sent to window DETECT at step 3 above, and they don't go further at the moment.
				; (potentially these could be sent to focal-face ENGAGE)
				exit
			]

		; 7) Call all DETECT functions to the target face

			; find the target faces
				target: first mapped-gob
				;debug ["target DET" mold target]
				target: target/data/gob-face ; get gob's face
				;probe-obj target

				path: [] ; use static block also as storage
				previous: last path ; used for OVER and ENGAGE
				previndex: index

				path: head insert clear path target
				; go up to window
				start-path: target/gob
				while [start-path <> window/gob] [
					if start-path/data/gob-face [insert path start-path/data/gob-face]
					start-path: start-path/parent ; FIXME: should I use faces instead of gobs? NO! because of over (see check-line)
				]
				path: next path ; skip over the window face
				index: 0
				if any [function? get in target 'pane all [target/parent-face function? get in target/parent-face 'pane]] [
					targ: first head path
					append clear path next index: find-face-deep/pane-path targ (event/offset - any [all [targ/edge targ/edge/size] 0x0])
					index: first head index
					target: last path
				]
			; call detect
				foreach face path [
					;debug ["path" face/text index]
					event/7: event/face: face
					if attempt [:face/feel/detect] [if none? face/feel/detect face event [exit]]
				]


		; 8) process OVER and ENGAGE

			; OVER:
				changed: target <> previous ; used for OVER
				if any [previndex <> index all [
					previous
					previous <> window
					changed
				]][
					iter: previous
					currindex: previndex ; currindex is used by show
					if attempt [:iter/feel/over] [iter/feel/over iter false event/offset]
				]
				; go up until window
				path: back tail path
				until [
					targ: first path
					if all [
						attempt [get in targ/feel 'over]
						targ <> window
						any [changed previndex <> index find window/face-flags 'all-over]
					][
						currindex: index ; currindex is used by show
						targ/feel/over targ true event/offset
						break
					]
					
					path: back path
					head? path
				]

			; ENGAGE:

				targ: all [targ: target-down targ/gob] ; NOTE: R2 has a bug with window's face's edge
				remapped: second map-gob-offset/reverse any [targ target/gob] 0x0
				; go up until window
				path: back tail path
				until [
					target-engage: first path
					if any [target-down-engage all [
						target-engage 
						in target-engage 'feel
						target-engage/feel
						get in target-engage/feel 'engage
						; FIXME: target-engage/show?
						any [
							find [up down alt-up alt-down] event/type ; R2
							find [aux-up aux-down] event/type ; R3
							all [event/type = 'move not none? target-down]
						]
					]][
						do-over: false
						if target-down-engage [target-engage: target-down-engage]
						if find [down alt-down aux-down] event/type [
							target-down: target ; face on which we have clicked
							target-down-engage: target-engage ; first face having an engage func
							storeindex: index
						]
						if find [up alt-up aux-up] event/type [
							if target-down = target [do-over: true]
							target-down: none 
							target-down-engage: none 
							storeindex: 0
						]
						; set action and change event/offset 
							action: event/type
							if action = 'move [; if I place event/type here Rebol crashes
								action: either all [target-down = target currindex = storeindex] ['over]['away] ; 
							]

							event/offset: (
								event/offset - remapped ; relative to down-face
								- (any [all [target-engage/edge target-engage/edge/size] 0x0]) ; except down-face/edge
							)

							if all [storeindex <> 0 any [
								function? get in targ: :target-engage/parent-face 'pane
								function? get in targ: :target-engage/parent-face/parent-face 'pane
								]] [ ; iterated face
								targ: targ/pane targ storeindex
								if targ [
									event/offset: (
										event/offset - (win-offset? targ) ; relative to down-face
										- (any [all [targ/edge targ/edge/size] 0x0]) ; except down-face/edge
									)
								]
							]
						; call engage

							if attempt [:target-engage/feel/engage] [target-engage/feel/engage target-engage action event]

						; call over on "up" event ; FIXME: same as in R2, but is it "formally" correct ?
							if do-over [
								attempt [target-engage/feel/over target-engage true event/offset]
							]
							break
					]

					path: back path
					head? path
				]
		

	]
	] ; ctx-do-event

;
	unless none? sdk-dir [
; view-init

	open-events
;
	]
; none? sdk-dir
	if none? sdk-dir [ ; error? sdk-dir
		; use patched view but without patched VID
		win: make face [
			offset: 30x30
			size: 300x200
			text: "Error"
			edge: none
			pane: reduce [
				make face [
					text: "Please set the correct path^/to SDK sources"
					offset: 10x10
					size: 280x180
					color: gold
					edge: none
					font: make font [size: 16 style: 'bold]
				]
			]
		]
		view win
	]
; tests
	comment {
		Note_on_timer:
		On my system (AMD Athlon II 2.0 GHz) the value 0.01 gives CPU usage at about 50%, the value 0.02 gives less then 10%
	}
	if none? system/script/args [

		var: 20;x10
		pos: 20x20
		widths: 5
		color: green
		win3: make face [
			text: "Face Top"
			offset: 800x100
			size: 400x300
			color: water
			edge: make edge [size: 20x5 color: yellow]
			selected: 0

			iterated-face: make face [
				size: 100x20
				text: "Test"
				edge: none
				feel: make feel [
					;redraw: func [face action position] [print ["iter/draw" action position]]
					;detect: func [face event] [print ["iter/det" event/type event/offset] event] ;none]]
					over: func [face into pos] [print ["iter/ovr" into]]; face/font/color: either into [200.100.100][100.0.0] show face-list]
					engage: func [face action event] [
						print ["Engage" face/data action event/offset]
						if action = 'down [
							selected: face/data
							show face-list
						]
					]
				]
				data: 0
			]

			iter-func: func [face index] [;probe index
				; RETURNS: face, index number, or none
				; ?? index
				either integer? index [
					; Draw needs to know offset and text:
					if index <= 10 [
						iterated-face/data: index
						iterated-face/offset/y: index - 1 * 20
						iterated-face/text: form iterated-face/offset
						iterated-face/color: if selected = index [gold]
						return iterated-face
					]
				][
					; Events need to know iteration number:
					return to-integer index/y / 20 + 1
				]
			]
			feel: make feel [
				redraw: func [face action position] [print ["w/f/draw" action position]]
				;detect: func [face event] [	print ["w/f/det" event/type event/offset face/offset face/size] event]
				over: func [face into pos] [print ["w/f/ovr" into]]
				engage: func [face action event] [print ["w/f/eng" action event/type event/offset]]
			]
			pane: reduce [
				make face [
					text: "Face 1"
					size: 120x100
					rate: none;2
					edge: make edge [size: 10x5 color: orange effect: 'bevel]
					color: red
					effect: [draw [line-width 4.0 pen yellow blue circle 20x20 var polygon 10x10 50x15 40x30 20x20 text 30x30 "ciao"]]
					feel: make feel [
						redraw: func [face action position] [print ["w/p/1/f/draw" action position]]
						;detect: func [face event] [print ["w/p/1/f/det" event/type event/offset] event] ;none]]
						over: func [face into pos] [print ["w/p/1/f/ovr" into]]
						engage: func [face action event] [print ["w/p/1/f/eng" action event/type event/offset]
							if action = 'down [insert effect/draw reduce ['fill-pen blue]]
							if action = 'up [face/rate: 2]
							show face
						]
					]
				]
				;ignore-next ; ignore next face
				face-2: make face [
					offset: 50x50
					size: 175x150;300x220
					text: "Drag me"
					font: make font [size: 16 color: purple]
					;edge: none
					edge: make edge [size: 10x5]
					color: green
					effect: [oval red fit]
					;effect: [luma 100]
					;effect: [contrast 150]
					;effect: [extend 20x40 10x50]
					;image: load %../../local/bay.jpg
					feel: make feel [
						redraw: func [face action position] [print ["w/p/2/f/draw" action position]]
						;detect: func [face event] [print ["w/p/2/f/det" event/type event/offset] event] ;none]
						over: func [face into pos] [print ["w/p/2/f/ovr" into pos]]
						engage: func [face action event /local data] [print ["w/p/2/f/eng" action event/type event/offset]
							data: []
							if action = 'down [change data event/offset]
							if find [over away] action [
								offset: offset + event/offset - do data
								;size: size + event/offset - do data
								text: offset
								show face
							]
						]
					]
					pane: none comment [;reduce [
						make face [
							offset: 10x-10
							size: 50x20
							text: "Face 2.1"
							color: pink
							edge: make edge [effect: 'bevel]
							feel: make feel [
								redraw: func [face action position] [print ["w/p/2/p/1/f/draw" action position]]
								;detect: func [face event] [print ["w/p/2/p/1/f/det" event/type event/offset] event] ;none]
								over: func [face into pos] [print ["w/p/2/p/1/f/ovr" into]]
								engage: func [face action event] [print ["w/p/2/p/1/f/eng" action event/type event/offset];]
									;if action = 'down [data: event/offset]
									if action = 'down [
										data: event/offset face/pane/image: system/view/vid/radio.bmp
										face-2/image: to-image face/gob
										show [face face-2 ]
									]
									if action = 'up [face/pane/image: system/view/vid/radio-on.bmp show face]
									if find [over away] action [
										offset: offset + event/offset - data
										;size: size + event/offset - data
										text: offset
										show face
									]
								]
							]
							;pane: make-face/spec 'check [size: 13x13 color: edge: none]; image: system/view/vid/radio.bmp]
							pane: make face [
									offset: 2x2
									size: 13x13
									;text: "Face 2.1.1"
									color: white
									image: system/view/vid/radio.bmp
									feel: ignore-next none make feel [
										redraw: func [face action position] [print ["w/p/2/p/1/2/f/draw" action position]]
										detect: func [face event] [print ["w/p/2/p/1/2/f/det" event/type event/offset] event] ;none]
										over: func [face into pos] [print ["w/p/2/p/1/2/f/ovr" into]]
										engage: func [face action event] [print ["w/p/2/p/1/2/f/eng" action event/type event/offset]]
									]
							]
						]
					]
				]
				ignore-this ; ignore this face
				make face [
					offset: 170x150
					size: 80x100
					text: "Face 3"
					color: gold
					feel: make feel [
						redraw: func [face action position] [print ["w/p/3/f/draw" action position]]
						detect: func [face event] [print ["w/p/3/f/det" event/type event/offset] event] ;none]]
						over: func [face into pos] [print ["w/p/3/f/ovr" into]]
						engage: func [face action event] [print ["w/p/3/f/eng" action event/type event/offset]]
						;	if action = 'down [insert effect/draw reduce ['fill-pen blue]]
						;	show face
						;]
					]
				]

				face-list: make face [
					text: "Iterating"
					offset: 250x10
					size: 100x220
					color: sky
					edge: none
					effect: [draw [scale -1x1 translate -100x0 line 0x0 100x220]]
					pane: :iter-func
				]
			]
		]

	view/options win3 [resize]; all-over]

	ctx-win4: context [
	a-1: none
	;comment [
	box-lay1: layout/tight/size [text "lay1"] 100x50
	box-lay2: layout/tight/size [text "lay2"] 100x50
	win4: layout [
		at 20x1 box red 50x50 logo.gif [confirm "Right?"] ;[flash "Why?"] [unview]
		box-lays: box white "box" effect [] feel [engage: func [face action event][probe action]] ;with [pane: box-lay1]
		text bold "Bolded text" [face/font/color: face/font/colors/1: any [request-color black] show face]
		check rate 2 feel [engage: func [face action event][if action = 'time [face/data: not face/data show face] ] ]
		scroller 100x16
		check-line "here" ;rate 1 feel [engage: func [face action event][if action = 'time [face/data: not face/data show face] ] ]
		radio-line "radio" red green
		radio-line "radio2" red green
		button "Helloooooo" 100x30 #"^O" [set-face field-1 request-file]
		choice "aaaaaaaaaa" "b" "c" "d" "e" [alert value]
		btn "Hello" 100 green [win4/gob/parent/text: "hoi" native-show win4/gob/parent];feel engage-super: :engage engage: func [face action event][print ["hel" action] engage-super face action event]  ] [print "released"	show win4]
		return
		field-1: field 100 "some text1" [confirm "why?"]
		field 100 "some text2"
		a-1: area "Hello" 100x100
		text-list 100x70 "1" "2" "3" "4" "5" "6" with [append init [flag-face self striped]] [print value]
		rotary "lay1" "lay2" 100 [
			switch value [
				"lay1" 	[box-lays/pane: box-lay1 show box-lays]
				"lay2" 	[box-lays/pane: box-lay2 show box-lays]
			]
		]
		panel [style text text red text "in panel"] edge [size: 1x1]
		list [across text "line" btn "1"] supply [if index = 2 [face/text: form count]]
	]
	win4/text: "[]"
	view/title/options win4 "Test" 'resize
	]
	
	] ; none? system/script/args
;