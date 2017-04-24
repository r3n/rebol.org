REBOL [
	Title: 	"Colormatch 1.5"
	File: 	%colormatch15.r
	Author:	"Scot M. Sutherland"
	Verson: 1.5.1
	Date: 15-Mar-2007
	Copyright: "©2006, by Scot M. Sutherland.  All rights reserved."
	Purpose: {Color Match 1.5 simulates very closely the Amiga Version created in 1987.
Junior High students learned how to created accurate colors by typing in numbers into a
multimedia program.
}
    library: [
        level: 'intermediate
        platform: 'all
        type: [game]
        domain: [game]
        plug-in: [size: 196x591]
        tested-under: [product: view version: 1.3.2.3.1]
        support: scots@rebol.com
        license: none
        see-also: none
    ]

	Notes: {
		12-Oct-2006	Rewrite of colormatch for 64 colors, and bigger handles.
					Leaping slider handles added.
	}
]

col-nos: 4
col-fact: 256 / col-nos
random/seed now
s: 10

rand-color: func [/local col v vf] [
	col: copy [] v: 0
	loop 3 [
		v: ((random (col-nos + 1)) - 1) 
		either v > 0 [vf: (v * col-fact) - 1][vf: 0]
		append col vf
	]
	return to-tuple col
]

rank?: func [score /local rank] [
    rank: "Drop Out!"
    if (score > 5) [rank: "Nerd"]
    if (score > 6) [rank: "Geek"]
    if (score > 7) [rank: "Expert"]
    if (score > 8) [rank: "ACE!"]
    return rank
]

s-off: func [c sv z /local color [tuple!] off [pair!] val [integer!] data y sy ][
	y: (to-integer (second parse mold z "x")) - 18
	if sv < 1 [sy: y - 4 off: to-pair reduce [0 sy] color: c * 0 val: 0 data: 1]
	if sv < .95 [sy: y * .75 off: to-pair reduce [0 sy] color: c * .25 val: 1 data: .75]
	if sv < .625 [sy: y * .5 off: to-pair reduce [0 sy] color: c * .5 val: 2  data: .5]
	if sv < .375 [sy: y * .25 off: to-pair reduce [0 sy] color: c * .75 val: 3 data: .25]
	if sv < .05 [off: 0x0 color: c val: 4 data: 0.0]
	return reduce [color off val data]
]

;for x 0 16 1 [probe (x * 16)]

lay: layout [
	style t-box box 150x100
	backdrop forest + 100 effect [gradient 1x1 20.200.80 30.90.50]
	vh1 150 center Gold "Colormatch 1.5" 
		feel [over: func [f a o] [
			prompt/text: either a ["Intuica, Inc. Patent Pending"] ["Move sliders...Click Test."] show prompt]
		]
	prompt: txt white 155 center "Move sliders...Click Test" space 0x0
	frame: box 156x206 edge [size: 3x3 color: gray effect: 'bevel]
	at frame/offset + 3x3 
	targ: t-box rand-color "Target" 
		feel [over: func [f a o] [
			prompt/text: either a ["Start over..."] ["Move sliders...Click Test."] show prompt]
		][
			targ/color: rand-color targ/color 
			test/text: "Test" targ/text: "Target"
			score/text: "10" s: 10
			test/color: r/data: g/data: b/data: 1.0
			r/color: g/color: b/color: 0
			rt/text: gt/text: bt/text: "0"
			show [targ test r g b rt gt bt score]
	]

	test: t-box 150x100 black "Test" 
			feel [over: func [f a o] [
			prompt/text: either a ["Test for a match..."] ["Move sliders...Click Test."] show prompt]
		][
		score/text: s: s - 1
		test/color: r/color + g/color + b/color
		if test/color = targ/color [rank/text: rank? s test/text: "MATCH!"  targ/text: "New Color"]
		show [test score rank targ]
	]
	across space (frame/size / 10) * 1x0
	guide (frame/offset + (frame/size * 0x1) + 15x15)
	rt: vh4 30 "0"	gt: vh4 30 "0" bt: vh4 30 "0" return pad 3x5
	space ((frame/size / 5) - 5 ) * 1x0
	r: slider 20x192 
			feel [over: func [f a o] [
			prompt/text: either a ["Red slider..."] ["Move sliders...Click Test."] show prompt]
		][
 		rv: s-off red r/data r/size
		if find rv none [rv: reduce [black  (r/size * 0x1 - (r/pane/1/size * 0x1) - 0x4) 0 1.0]]
		r/pane/1/offset: second rv
		r/data: fourth rv
		rt/text: third rv 
		r/color: first rv 
		show [r rt]
	]
	g: slider 20x192 
			feel [over: func [f a o] [
			prompt/text: either a ["Green slider..."] ["Move sliders...Click Test."] show prompt]
		][
 		gv: s-off green g/data g/size
		if find gv none [gv: reduce [black  (g/size * 0x1 - (g/pane/1/size * 0x1) - 0x4) 0 1.0]]
		g/pane/1/offset: second gv
		g/data: fourth gv
		gt/text: third gv 
		g/color: first gv 
		show [g gt]
	]
	b: slider 20x192 
			feel [over: func [f a o] [
			prompt/text: either a ["Blue slider..."] ["Move sliders...Click Test."] show prompt]
		][
 		bv: s-off blue b/data b/size
		if find bv none [bv: reduce [black  (b/size * 0x1 - (b/pane/1/size * 0x1) - 0x4) 0 1.0]]
		b/pane/1/offset: second bv
		b/data: fourth bv
		bt/text: third bv 
		b/color: first bv 
		show [b bt]
	]
	return space 5x5 pad 0x20
	vh4 gold "Score: " score: vh4 "10"
	feel [over: func [f a o] [
			prompt/text: either a ["Deduct 1 for each Test"] ["Move sliders...Click Test."] show prompt]
		] return
	vh4 gold "Rank: "  rank: vh4 "Thinking..." left
		feel [over: func [f a o] [
			prompt/text: either a ["ACE!, Expert, Geek or Nerd!"] ["Move sliders...Click Test."] show prompt]
		] return pad -20x0
	do [
		r/data: b/data: g/data: 1.0
		r/color: g/color: b/color: 0
		targ/color rand-color
		r/pane/1/color: red
		g/pane/1/color: green
		b/pane/1/color: blue
	]
]
;probe lay/size

view lay