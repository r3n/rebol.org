REBOL[
	Title: "TextureLab - Texture generator"
	Author: "ReBolek"
	Email: "rebolek>!a!t!<gmail>!d!o!t!<com"
	Date: 31-10-2006
	Version: 0.3.3
	File: %texture-lab.r
	Purpose: "Generate mathematical textures"

	library: [
		level: 'intermediate
		platform: 'all
		type: [tool dialect fun]
		domain: [graphics gui vid]
		tested-under: none
		support: "rebolek>!a!t!<gmail>!d!o!t!<com"
		license: 'bsd
		see-also: none
	]

	History: [
		0.3.3 31-10-2006 "reBolek" [
			"Fifth public release"
			"Fixed: 'texture-lab does not check for its header (can cause problems)"
			"Fixed: disk-cache does not access disk until turned on"
		]
		0.3.2 16-10-2006 "reBolek" [
			"Fourth public release"
			"Fixed: crash when no engine was selected"
		]
		0.3.1 12-10-2006 "reBolek" [
			"Changed: preview window back in main window, resizable"
			"Changed: disk cache is optional"
			"Added: Some missing functions implemented"
		]
		0.3.0 14-6-2005 "reBolek" [
			"Changed: again changed name, this time to TextureLab to make it more consistent with other REBOL tools"
			"Changed: GUI totally rewritten from the very same reason"
		]
		0.2.0 8-6-2005 "reBolek" [
			"Fixed for latest View (1.2.118)"
			"Changed: Preview moved to own window"
			"Changed: everything in one file again for easier distribution"
			"Changed: name changed to TextureX"
			"Changed: default size to 100x100 instead of 40x40"
		]
		0.1.8 8-7-2002 "reBolek" [
			"Fixed: 'texture VID-keyword with block! parametr was bad initialized"
		]
		0.1.7 20-6-2002 "Rebolek" [
			"Fixed: Texture was colorized (in case of one color)  BEFORE post-effect (so effects like 'emboss gave false colors)"
			"Fixed: Pre-effect was applied AFTER main-loop (so it was no PRE-effect at all)"
			"Added: Disk cache finally implemented (limited to cca. 200 bilions different textures ;-)"
			"Fixed: some prefs-values were not initialized - post effect was applied to textures without post effect"
			"Added: you can add user presets + they are saved on disk for later use"
			"Fixed: parser ignores 'tile and 'seed with 'time (all parser related bugs should be gone by now)"
			"Added: 'set-preset function for easier preset maintance."
			"Added: 'texture keyword now supports tuple! value so instead of eg. ** button texture [preset 'concrete red] ** now you can use ** button texture 'concrete red **"
		]
		0.1.6 19-6-2002 "Rebolek" [
			"Third public release - tried to fix all bugs found in second public release (0.9.5)"
			"Fixed: seed field crashes when time! value was inserted"
			"Changed: Cache dialect handling - full dialect is stored with image instead of user's input"
			"Changed: Default texture"
			"Added: /no-init refinement for 'texture - does not init preferences when calling 'texture (useful if you set prefs from outside)"
			"Added: 'glow keyword for 'texture-text styles / makes text 'glow' "
			"Added: new presets [concrete sack-cloath]"
		]
		0.1.5 17-6-2002 "Rebolek" [
			"Second public release"
			"Added: VID patch so most VID styles can now use word 'texture to select texture"
			"Added: All created textures are cached so same textures are not created twice"
			"Source cleaned again"
		]
		0.1.4 16-6-2002 "Rebolek" [
			"Fixed: dialect parser"
			"Added: VID-style 'texture-text for labels and headers"
			"Added: simple help browser"
			"Changed: GUI layout"
			"Source cleaned a little bit (very little..)"
		]
		0.1.3 [
			10-6-2002 "Rebolek" [
				"VID-style supports 'preset keyword"
			]
			27-5-2002 "Rebolek" [
				"Doing something again after half year!"
				"Fixed: When saving, filename was parsed bad and program crashed"
				"Added: background texture as VID style (VERY EARLY version!)"
			]
		]
		0.1.2 26-11-2001 "Rebolek" [
			"First released version"
		]
	]
	Comments: [
		"Cache type is set according to ctx-texture/cache-type . 'disk turns on disk cache, other values turns the disk cache off. Memory cache cannot be turned off."
		"I've found (0.1.7) that 'texture works very ineffeciently and calls itself several times (at least parses prefs), I think more than really needed. I have to look at this (really low priority :)"
		"effects like 'sharpen and 'emboss destroy vertical tileness"
	]
	To-do: [
		"User added texture should be added to texture-list"
		"Engines management"
		"Fix all possible bugs"
		"Possibility for removing VID-texture-patch"
		"Add more presets and engines"
		"Make separate versions with texture engine or VID style only"
		"Add more keywords to VID styles"
	]
]

help-usage: [
"1. How to run it?"
{There are different ways how this script can be used:
Type at console:

	texture			-	run GUI
	texture 'preset-name	-	return image! according to the preset name
	texture [dialect here]	-	return image! as described in dialect

or you can use other functions:

	request-texture	-
		shows requestor, you can select preset and returns image!.

or

	texture-styles	-
		put in your layout [styles texture-styles]
		and two new styles are ready to use:

		texture-tile -
			just supply same dialect as for 'texture.
			The texture is ALWAYS tiled!

		texture-text -
			renders textured text that can be used for labels, logos...
}
"2. How does it work"
{First, noise image is created. If one color is supplied, noise is BW,
with two colors noise is gradiental.

Then the noise is effected using pre-effect.

The result is effected strength-times using engine.

Then the post-effect is applied and if one color was supplied
the result is colorized.

That's all and texture is ready to use.

When using tile, noise picture is created in normal size but then
new picture is made, 9xbigger (grid of 3x3 noise images) and all
effects are applied on that picture. Only the center is cut-out and
used.
}
"3. About"
{Texture Lab version 0.3.3
-------------------------
Written by REBolek aka Boleslav Brezovsky.
(c)2001-2006
}
]

;---support functions

to-type: func [
	{Converts value to desired datatype otherwise returns 'none.
^- If block of datatypes is supplied value is converted to first appropriate datatype.
}
	value		[any-type!]				"Value to convert"
	type		[datatype! block!]		"Datatype or block of datatypes to convert value to."
	/local result
][
	result: none
	type: append copy [] type
	forall type [if not error? try [result: make first type value][break]]
	result
]

;---texture styles

texture-styles: stylize [
	texture-tile: backtile with [
		frozen?: false			; if not frozen? image is made from face to speed things up - DOES NOT WORK NOW!!!
		dialect: copy []
		dialect2: copy []		; because VID evaluates 'multi first and then 'words I must have two dialects to get rid of all params
		append init [
			;prefs/init
			prefs: make *prefs []
			if none? dialect [dialect: copy []]
			ctx-texture/set-preset dialect
			ctx-texture/set-preset dialect2
			dialect: ctx-texture/prefs-to-dialect
			if not found? find dialect 'tile [append dialect 'tile]
			image: texture dialect
		]
		words: [
			preset [new/dialect: select ctx-texture/presets second args next args]
		]
		multi: make multi [
			block: func [face blk][
				if pick blk 1 [
					face/dialect: pick blk 1
					if pick blk 2 [
						face/action: func [face value] pick blk 2
						if pick blk 3 [
							face/alt-action: func [face value] pick blk 3
						]
					]
				]
			]
			size: func [face blk /local dial][
				foreach nr blk [
					switch type?/word nr [
						pair! [repend face/dialect2 ['size nr]]
						integer! [repend face/dialect2 [ nr]]
					]
				]
			]
			color: func [face blk][
				switch length? blk [
					1 [repend face/dialect2 [ pick blk 1]]
					2 [repend face/dialect2 [ pick blk 1 pick blk 2]]
				]
			]
		]
	]
	texture-text: face with [
		size: 1000x100
		dialect: copy []
		dialect2: copy []
		font: make font [
			align: 'left
			valign: 'top
			color: black
			offset: 0x0
		]
		logo: make face [
			edge: none
			size: 1000x100
			color: white
			para: make para [wrap?: none offset: 0x0 margin: 0x0]
		]
		;effect: [blur fit blur key 255.255.255]
		effect: [fit key 255.255.255]
		edge: none
		multi: make multi [
			block: func [face blk][
				if pick blk 1 [
					face/dialect: pick blk 1
					if pick blk 2 [
						face/action: func [face value] pick blk 2
						if pick blk 3 [
							face/alt-action: func [face value] pick blk 3
						]
					]
				]
			]
			size: func [face blk /local dial][
				foreach nr blk [
					switch type?/word nr [
						pair! [repend face/dialect2 ['size nr]]
						integer! [repend face/dialect2 [ nr]]
					]
				]
			]
			color: func [face blk][
				switch length? blk [
					1 [repend face/dialect2 [ pick blk 1]]
					2 [repend face/dialect2 [ pick blk 1 pick blk 2]]
				]
			]
			text: func [face blk][
				if pick blk 1 [
					face/logo/text: pick blk 1
				]
			]
		]
		words: [
			glow [insert head new/effect 'blur args]
			preset [new/dialect: select ctx-texture/presets second args next args]
		]
		init: [
			logo/font: make font []
			ctx-texture/set-preset dialect
			ctx-texture/set-preset dialect2
			dialect: ctx-texture/prefs-to-dialect
			color: none
			logo/size: 2x2 + size-text logo
			logo: to image! make face [edge: none size: 2 * logo/size image: to-image logo effect: 'fit]
			lg: logo/size
			image: to image! make face [
				edge: none
				size: lg
				color: white
				image: texture dialect
				effect: [
					tile
					draw [
						image 0x0 logo 0.0.0
					]
				]
			]
			size: logo/size
		]
		text: none
	]
]

;---

ctx-texture: context [
	;site: http://www.sweb.cz/rebolek/
	;site: %/c/view/
	set 'VID-texture-patch func [
		/local tp
	][
		if not found? find system/view/VID/fw-with 'texture [
			append system/view/VID/fw-with reduce [
				'texture func [new args][
					switch type?/word new/effect [
						none! [new/effect: [tile]]
						word! [new/effect: head insert head [tile] new/effect]
						block! [if	all [not find new/effect 'tile not find new/effect 'tile-view][append new/effect 'tile]]
					]
;					prefs: make *prefs []		;I don't know if this line is needed
					if word? args/2 [args/2: select presets args/2]
					tp: second args
					if tuple? args/3 [append tp args/3 remove skip head args 2]
					set-preset tp
					tp: prefs-to-dialect
					new/image: texture tp
					next args
				]
			]
		]
	]
	VID-texture-patch

	version: 0.3.3
	editor: none
	gui?: false
	invitation: layout [
		h1 "Texture studio is loading"
	]
	*prefs: context [
		size: 100x100
		color: white
		color2: none
		colorize?: false	;aplikuje obarveni od color do color2
		strength: 3
		pre: copy []
		post: copy []
		engine: copy [emboss contrast -10 blur]
		tile?: on
		seed: 0:0:0
	]

	prefs: make *prefs []
	temp-prefs: make *prefs []

;---cache functions

	create-code: has [res][
		res: copy {}
		repeat i 8 [append res #"`" + random 26]
		if find cache-index res [res: create-code]
		res
	]

	cache: copy []
	cache-type: 'memory		; 'disk or 'memory (or none or whatever you want)

	cache-path: dirize view-root/public/_textures
	if equal? 'disk cache-type [if not exists? cache-path [make-dir/deep cache-path]]
	cache-index: either exists? cache-path/cache-index.r [load cache-path/cache-index.r][copy []]
	save-cache-index: does [save cache-path/cache-index.r head cache-index]

	cache-add: func [dialect img /local code][
		set-preset dialect
		code: create-code
		repend cache [prefs-to-dialect img]		;appends to memory-cache
		if cache-type = 'disk [
			repend cache-index [prefs-to-dialect code]	;append to disk cache index
			save-cache-index
			save/png rejoin [cache-path code ".png"] img
		]
		cache: head cache
	]
	cache-get: func [
		dialect
		/local code ;img
	][
		set-preset dialect
		dialect: prefs-to-dialect
		img: select/only cache dialect					;tries to read texture from memory cache.
		if all [cache-type = 'disk none? img] [
			code: select/only head cache-index dialect					;if fails, tries to read from disk cache
			if not none? code [img: load rejoin [cache-path code ".png"]]
		]
		img			;return result (image! or none! if none!, 'texture creates new texture
	]

;-----presets and supporting functions

	current-preset: copy []
	user-presets: either exists? %texture-presets.r [sort/skip load %texture-presets.r 2][copy []]
	presets: [
		bubbles		[28.235.240 6.255.255 10 engine worms]
		clouds		[29.0.255 0.246.255 10 engine [blur]]
		clouds2		[92.209.204 246.255.252 3 engine spots]
		concrete	[180.180.180 3 engine [emboss contrast -10] post [luma 100]]
		forest		[28.204.0 6.76.0 5 engine worms]
		geometric	[112.165.163 20 engine sack]
		grass		[53.164.39 2 engine worms]
		ground 		[204.151.55 10 engine spots]
		halucinate	[85.219.251 0.0.121 10 engine [contrast 100 blur luma 10 sharpen blur]]
		halucinogen	[255.255.205 0.207.0 50 engine [contrast 30 blur luma -10 blur]]
		metal		[233.255.255 5 post [rotate 90 contrast -20 luma 100] engine tiger]
		moon		[209.236.215 100 pre [emboss] engine [sharpen contrast 10 blur luma 10 blur]]
		moon-hills	[208.225.218 20 engine spots post [emboss]]
		plastik		[255.255.255 150 pre [emboss] post [emboss] engine [sharpen contrast 10 blur luma 10 blur reflect 0x1]]
		psycho		[112.165.163 0.123.151 30 engine sack]
		sack-cloth	[112.165.163 20 post [emboss contrast -50 luma 80] engine sack]
		spots		[255.255.255 50 engine spots]
		spots2		[255.255.205 50 engine [sharpen contrast 10 blur luma 10 blur]]
		tribal		[255.255.255 5 engine ethno]
		water		[85.219.251 20 engine worms]
		wood		[126.76.59 5 post [luma 50] engine tiger]
		worms		[255.255.255 20 pre [emboss] engine [sharpen contrast 10 blur luma 10 reflect 1x1]]
	]

	engines: [
		spots 		[multiply 150.150.150 blur luma -20]
		worms 		[sharpen contrast 10 blur luma 10]
		tiger 		[sharpen emboss contrast 10 blur]
		sack		[contrast 50 blur emboss rotate 90]
		ethno		[rotate 90 blur reflect 1x1 contrast 5]
	]

;----rules for parser and supporting functions

	rule-size: [opt ['size] set val pair! (temp-prefs/size: val)]
	rule-color: [opt ['color] set val tuple! (temp-prefs/color: val temp-prefs/color2: none) opt [set val tuple! (temp-prefs/color2: val)]]
	rule-strength: [opt ['strength] set val integer! (temp-prefs/strength: val)]
	rule-pre: ['pre set val block! (temp-prefs/pre: copy val)]
	rule-post: ['post set val block! (temp-prefs/post: copy val)]
	rule-tile: ['tile (temp-prefs/tile?: true)]
	rule-colorize: ['colorize (temp-prefs/colorize?: true)]
	rule-seed: ['seed [set val number! (temp-prefs/seed: val) | set val time! (temp-prefs/seed: val)]]
	rule-preset: ['preset set val word! (set-preset select presets val)]
	rule-engine: use [result tmp][
		result: copy [set val block! (temp-prefs/engine: val)]
		foreach [name engine] engines [
			append result compose/deep [
				|	(to-lit-word name)	(to-paren compose/deep [temp-prefs/engine: [(engine)]])
			]
		]
		compose/deep [
			'engine [
				(result)
			]
		]
	]
	main-rule: compose [ (rule-size) | (rule-color) | (rule-strength) | (rule-seed) | (rule-pre) | (rule-post) | (rule-engine) | (rule-preset) | (rule-tile) | (rule-colorize)]
	set-preset: func [
		dialect
	][
		temp-prefs: make *prefs []
		parse dialect [any [main-rule]]
		prefs: make temp-prefs []
	]
	img: none
	gradient: none
	set-gradient: does [
		gradient: to-image make face [
			size: 256x1
			effect: compose [gradient (prefs/color) (prefs/color2)]
			edge: none
		]
	]

	prefs-to-dialect: does [
		compose/deep [
			size (prefs/size)
			color (prefs/color) (either none? prefs/color2 [][prefs/color2])
			strength (prefs/strength)
			(either prefs/tile? ['tile][])
			(either prefs/colorize? ['colorize][])
			pre [(prefs/pre)]
			post [(prefs/post)]
			engine [(prefs/engine)]
			seed (prefs/seed)
		]
	]

;----the main engine

	set 'texture func [
		dialect [any-type!]
		/no-init						"Leave last preferences"
	][
		unless value? 'dialect [
			gui?: true
			f-image: make face []
	
			if error? try [texturex-preview-resize-func][
				texturex-preview-resize-func: none
				insert-event-func func [f e][
					if all [equal? e/face ~editor equal? e/type 'resize] [
						~editor/size: as-pair 604 max 442 ~editor/size/y
						f-image/size: ~editor/size - 0x242
						~txt-copy/offset/y: ~editor/size/y - 21
						show ~editor ;f-image
					] 
					e
				]
			]

;---ctx-guifunc --- GUI functions are separated from layout to make code more readable			
			ctx-guifunc: context [
				show-preview: does [
					get-gui-settings
					f-image/image: texture/no-init none 
					show f-image 
					current-preset: ctx-texture/prefs-to-dialect
				]
				show-help: does [
					view/new center-face layout [
						origin 2x2
						backeffect [gradient 0x1 water coal]
						across
						space 0x10
						btn "Starting" [w1/text: help-usage/1 w2/text: help-usage/2 show reduce [w1 w2]]
						btn "Usage" [w1/text: help-usage/3 w2/text: help-usage/4 show reduce [w1 w2]]
						btn "About" [w1/text: help-usage/5 w2/text: help-usage/6 show reduce [w1 w2]]
						w1: h1 300 help-usage/1
						return
						w2: info 500x400 help-usage/2 white with [para: make para [tabs 20]]
					]
				]
				save-as-png: has [filename][
					filename: request-file/save/filter  "*.png"
					if not none? filename [
						filename: first filename
						if any [(length? pf: parse filename ".") = 1 (last pf) <> "png"] [filename: to-file append filename ".png"]
						save/png filename f-image/image
					]
				]
				engines: has [tmp engs][
					tmp: copy []
					engs: ctx-texture/engines
					forskip engs 2 [append tmp to string! engs/1]
					tmp
				]
				get-gui-settings: does [
					ctx-texture/prefs: make ctx-texture/prefs [
						size: to pair! ~fld-size/text
						color: ~btn-color/color
						color2: ~btn-color2/color
						colorize?: ~chk-colorize/data
						strength: to integer! ~fld-strength/text
						engine: to block! ~fld-engine/text
						pre: to block! ~fld-preeffect/text
						post: to block! ~fld-posteffect/text
						tile?: ~chk-tile/data
						seed: either 1 < length? parse to string! ~fld-seed/text ":" [to time! ~fld-seed/text][to integer! ~fld-seed/text]
					]
					;ctx-texture/prefs/colorize?: cls
				]
			]
;-------------------------------------------------------------------------------------	
			~editor: layout compose/deep [
				origin 2x2
				style text text white
				style btn btn 80x25
				style h1 h1 250.250.100
				backeffect [gradient 0x1 water coal]
				across
				space 0
				btn "New" [
					~fld-strength/text: "1"
					~sld-strength/data: 0
					~fld-preeffect/text: copy ""
					~fld-posteffect/text: copy ""
					~fld-engine/text: copy ""
					~btn-color/color: white
					~btn-color/text: 255.255.255
					~btn-color2/color: none
					~btn-color2/text: "none"
					show ~editor
					ctx-guifunc/show-preview
				]
				btn "Open" [
					result: copy []
					foreach [name block] ctx-texture/presets [append result to-string name]
					append result "----"
					foreach [name block] ctx-texture/user-presets [append result to-string name]
					value: request-list "Select preset" result				
					if any [none? value value = "----"] [exit]
					;ctx-texture/prefs/init
					ctx-texture/set-preset select append copy ctx-texture/presets ctx-texture/user-presets to-word value
					f-image/image: texture/no-init none
					~fld-strength/text: to-string ctx-texture/prefs/strength
					;~sld-strength
					~fld-seed/text: to-string ctx-texture/prefs/seed
					~chk-tile/data: ctx-texture/prefs/tile?
					~btn-color/color: ctx-texture/prefs/color
					~btn-color/text: to-string ctx-texture/prefs/color
					~btn-color2/color: ctx-texture/prefs/color2
					~btn-color2/text: to-string ctx-texture/prefs/color2
					~fld-preeffect/text: block-to-string ctx-texture/prefs/pre
					~fld-posteffect/text: block-to-string ctx-texture/prefs/post
					~fld-engine/text: block-to-string ctx-texture/prefs/engine
					;show reduce [~fld-strength ~fld-seed ~chk-tile ~btn-color ~btn-color2 ~fld-preeffect ~fld-posteffect ~fld-engine f-image]
					;get-gui-settings
					show ~editor
					current-preset: ctx-texture/prefs-to-dialect
				]
				btn red "Save" [inform layout [h1 "not yet.."]]
				btn red "Save As PNG" [ctx-guifunc/save-as-png]
				bar 3x24
				btn yellow "Dialect code" [view/new center-face layout compose [text (to paren! [ctx-guifunc/get-gui-settings mold/only prefs-to-dialect]) as-is font [size: 14 style: 'bold]]] ;ctx-guifunc/get-gui-settings ctx-guifunc/show-preview]
				box 117x10
				btn "Help" [ctx-guifunc/show-help]
				return
				bar 600
				return
				panel [
					tabs 50
					across
					h1 "Source ------>" return
					space 0x8
					text "Size:" tab 
						~fld-size: field 70 "100x100" [~fld-size/data: ~fld-size/text if error? try [to pair! ~fld-size/text][use 'tmp [tmp: pick [10 25 50 75 100 150 200 300 400] 1 + to integer! ~sld-size/data * 8 ~fld-size/text: rejoin [tmp "x" tmp]] show ~fld-size] ctx-guifunc/show-preview] 
						~sld-size: slider 80x24 with [data: 0.5] [ use 'tmp [tmp: pick [10 25 50 75 100 150 200 300 400] 1 + to integer! ~sld-size/data * 8 ~fld-size/text: rejoin [tmp "x" tmp]] show ~fld-size ctx-guifunc/show-preview]
						return
					text "Seed:" tab ~fld-seed: field 70 "0" [~fld-seed/data: ~fld-seed/text if error? try [to integer! ~fld-seed/text][~fld-seed/text: random 99999 show ~fld-seed] ctx-guifunc/show-preview] btn "random" [~fld-seed/text: random 99999 show ~fld-seed ctx-guifunc/show-preview] return
					text "Pre-Effect:" return
					~fld-preeffect: field 200x60 wrap [ctx-guifunc/show-preview]
				]
				panel [
					tabs 60
					across
					h1 "Engine ------>" return
					space 0x8 text "Strength:" tab 
						~fld-strength: field 40 "30" [~fld-strength/data: ~fld-strength/text if error? try [to integer! ~fld-strength/text][~fld-strength/text: 1 + to integer! ~sld-strength/data ** 2 * 99 ~fld-strength/data: ~fld-strength/text show ~fld-strength] ctx-guifunc/show-preview]
						~sld-strength: slider 100x24 with [data: 0.55] [~fld-strength/text: 1 + to integer! ~sld-strength/data ** 2 * 99 show ~fld-strength ctx-guifunc/show-preview] 
						return
					text "Engine:" tab (tmp: [drop-down 140] append tmp ctx-guifunc/engines tmp) [all [not none? value ~fld-engine/text: block-to-string select engines to word! value show ~fld-engine ctx-guifunc/show-preview]] return
					text "Main-Effect:" return
					~fld-engine: field 200x60 wrap "multiply 150.150.150 blur luma -20" [ctx-guifunc/show-preview]
				]
				panel [
					across
					space 0x8
					h1 "Post-production" return
						text "Colors:" 50
						~btn-color: box 75x24 (ctx-texture/prefs/color) (to string! ctx-texture/prefs/color) font-size 10 [~btn-color/color: request-color/color ~btn-color/color ~btn-color/text: to string! ~btn-color/color show ~btn-color ctx-guifunc/show-preview]
						~btn-color2: box 75x24 (either none? ctx-texture/prefs/color2 [0.0.0][ctx-texture/prefs/color2]) (to string! ctx-texture/prefs/color2) font-size 10 [~btn-color2/color: request-color/color ~btn-color2/color ~btn-color2/text: to string! ~btn-color2/color show ~btn-color2 ctx-guifunc/show-preview]
						return
						~chk-tile: check-line "tile" on font-color white 40x24 [ctx-guifunc/show-preview]
						~chk-colorize: check-line "colorize" font-color white 66x24 [ctx-guifunc/show-preview] 
						~chk-cache: check-line "disk cache" font-color white 92x24 [either value [cache-type: 'disk if not exists? cache-path [make-dir/deep cache-path]][cache-type: 'memory]] 
						;~fld-colorize: field 40 "0" [ctx-guifunc/show-preview]
						return
					text "Post-Effect:" return
					~fld-posteffect: field 200x60 wrap [ctx-guifunc/show-preview]
					
				]
				return
				bar 600
				return
				f-image: image 600x200 effect 'tile
				return
				~txt-copy: text "(c)2001-2006 REBolek"
			]
			ctx-guifunc/show-preview
			view/title/options center-face ~editor "TextureLab" 'resize
			quit
			;view/title center-face editor "TextureX Texture Studio" exit
		]	;if no parrameter supplied, runs GUI
		if none? dialect [dialect: prefs-to-dialect]
		unless no-init [prefs: make *prefs []]
		if word? dialect [dialect: select presets dialect if none? dialect [dialect: copy []]]
		img: cache-get dialect: compose dialect
		if image? img [return img]
		set-preset dialect
		img: make image! either prefs/tile? [prefs/size][prefs/size + 6x6]
		random/seed prefs/seed
		if not none? prefs/color2 [set-gradient]
		repeat i (length? img) [
			either none? prefs/color2 [
				poke img i random 255.255.255 ;prefs/color
			][
				poke img i pick gradient random 256
			]
		]
		if prefs/tile? [
			img: to image! make face [
				edge: none
				size: img/size * 3
				image: img
				effect: 'tile
			]
		]
		img: to image! make face [
			image: img
			size: img/size
			edge: none
			effect: copy prefs/pre
			repeat i prefs/strength [
				append effect prefs/engine
			]
			effect
		]
		img: to image! make face [
			edge: none
			size: either prefs/tile? [img/size / 3][img/size - 6x6]
			effect: either prefs/tile? [compose/deep [draw [image (- img/size / 3) img]]][[draw [image -3x-3 img]]]
		]
		img: to image! make face [
			image: img
			size: img/size
			edge: none
			effect: copy []
			append effect prefs/post
			if none? prefs/color2 [append effect compose [grayscale colorize (prefs/color)]]
		]
		if prefs/colorize? [
			img1: to image! layout compose/deep [origin 0 image img effect [grayscale colorize (prefs/color)]]
			img2: to image! layout compose/deep [origin 0 image img effect [grayscale invert colorize (prefs/color2)]]
			img: to image! layout [origin 0 image img1 effect [add img2]]
		]
		cache-add dialect img
		img
	]
	select-engine: func [	"Returns engine name or input if engine does not exist"
		block
		/local eng
	][
		either none? eng: find/only engines block [block][first back eng]
	]
	change-engine: func [block][prefs/engine: to-block block f-engine/text: block-to-string block show f-engine]
	set 'block-to-string func [block ][head trim remove back tail remove mold block ]

;----request texture function

	set 'request-texture func [/local rt result][
		rt: center-face layout compose [
			label "Select texture:"
		(
			result: copy [text-list 100x140]
			foreach [name block] presets [append result to-string name]
			append/only result [
				datas: select presets to-word value
				unview self
				result: texture datas
			]
			result
		)
		]
		result: none
		view rt
		result
	]
]

texturex: :texture

texturex
