REBOL [
	file: %vtrend.r
	date: 2004-05-03
	Purpose: {
		This little utility will generate natural looking trends for you. 
		You can set a few parameters and marker points for the trend to make it looking as you wish.
	}
	title: "vTrend"
	author: "Varga Árpád"
	version: 1.0.0
	email: arpicheck@yahoo.com
	Library: [
		level: 'beginner
		platform: 'all
		type: 'tool
		domain: 'math
		tested-under: [view 1.3.2.3.1 on "Windows XP"]
		support: [author: "Arpad Varga" email: arpicheck@yahoo.com]
		license: 'gpl
	]
]

markers: [0x400 400x400]
dragging: false
marker-radius: 8
trend: copy []

dot-feel: [
	engage: func [face action event] [
		if all [action = 'down dragging: find-dot event/offset][start: event/offset]
		if all [action = 'alt-down find-dot event/offset][if 2 < length? markers [remove drag-marker show-markers]]
		if action = 'up [dragging: false]
		if all [dragging find [over away] action] [
			change drag-marker event/offset
			show-markers
		]
	]
]

lay: layout [
	h1 "Trend generator v1.0"
	style f40 field 40
	style tx100 text 100
	guide
	text "max"
	vmax: f40 "255" right
	pad 0x292
	vmin: f40 "0" right
	text "min"
	return
	space 2x2
	box 20x400 ivory effect [draw[pen black line 20x0 0x0 0x399 20x399]]
	return
	im: image 400x400 ivory effect [grid 40x40 0x0 100.100.100 draw []]
	
	across
	pad 328x0
	tx100 "nr. of samples:"
	nos: f40 right "100"
	return
	pad 328x0
	tx100 "noise:"
	smt: f40 right "1"
	return
	pad 0x10
	x-save: check true [either value [show axis-panel][hide axis-panel]]
	text "Save X axis data" [x-save/data: not x-save/data show x-save] font [colors: [0.0.0 60.60.200]]
	pad 0x-10
	axis-panel: panel [
		origin 15x10
		
		across
		text "X axis from:"
		xfrom: field 50 "0"
		
		text "X axis to:"
		xto: field 50 "100"
	] 280x45 edge [size: 1x1]
	return pad 0x30
	text "Right-click on a marker, to delete it." 486 center
	return
	pad 80x20
	btn "Add new marker" 120 [new-marker]
	btn "Create trend" 120 [create-trend]
	btn "Save trend" 120 [save-trend]
	at 90x56 dots: box 400x400 feel dot-feel
]

eff: ['pen marker-color 'fill-pen marker-color]

show-markers: has [bl marker][
	marker-color: pick ['green 'red] (2 < length? markers)
	bl: reduce eff
	markers: head markers
	until [
		if lesser? first first markers  0 [change markers 0x1 * first markers]
		if lesser? second first markers  0 [change markers 1x0 * first markers]
		if greater? first first markers  400 [change markers 400x0 + (0x1 * first markers)]
		if greater? second first markers  400 [change markers 0x400 + (1x0 * first markers)]
		append bl reduce ['circle first markers marker-radius]
		tail? markers: next markers
	]
	markers: head markers
	dots/effect: reduce ['draw bl]
	show dots
]

new-marker: does [
	append markers 200x200
	show-markers
]

find-dot: func [offset /local marker o][
	markers: head markers
	until [
		o: abs offset - first markers
		if all [o/1 <= marker-radius o/2 <= marker-radius][markers: head drag-marker: markers return true]
		tail? markers: next markers
	]
	markers: head markers
	false
]

get-trend: func [w left right 
	/local
	bl plasma
][
	smooth: to-decimal smt/text
	bl: copy []
	loop w [append bl 0]
	plasma: func [x w a b /local plot dis c w1][
		plot: func [ a c ][
			poke bl 1 + a (c * 400)
		]
		dis: func [ n ][
			((random 1000) - 500) * n / trendw / 1000
		]
		either w > 1 [
			w1: w / 2
			c: (a + b) / 2 + dis ((w1 + abs left - right) * smooth)
			if c < 0 [c: 0]
			if c > 1 [c: 1]
			plasma x w1 a c
			plasma x + w1 w1 c b
		][
			plot x (a + b) / 2
		]
	]
	plasma 0 w left right
	bl
]

create-trend: has [
	f a b
][
	if error? try [ 
		a: to-decimal smt/text
		b: to-integer nos/text
	][ request/ok "Number of samples must be a positive integer, noise must be positive real number." return]
	trendw: b
	markers: unique head markers
	sort/compare markers func [a b][ a/1 < b/1 ]
	trend: copy []
	markers: next head markers
	until [
		a: first back markers
		b: first markers
		append trend get-trend to-integer ((b/x - a/x) * trendw) / 400 a/y / 400 b/y / 400
		tail? markers: next markers
	]
	ltrend: length? trend
	markers: head markers
	f: last im/effect
	clear f
	append f reduce ['line]
	x: markers/1/x
	mmax: last markers
	xstep: (mmax/x - x) / (ltrend - 1)
	for i 1 ltrend 1 [append f as-pair x pick trend i x: x + xstep]
	show im
]

save-trend: has[b t tmin tmax]
[
	either not empty? trend [
		if error? try [ 
			tmin: to-decimal vmin/text
			tmax: to-decimal vmax/text
		][ request/ok "Min and max must be positive real number." return]
	
		b: copy []
		either x-save/data [
			if error? try [ 
				xmin: to-decimal xfrom/text
				xmax: to-decimal xto/text
			][ request/ok "X axis FROM and TO must be positive real number." return]
			if lesser? xmax xmin [request/ok "X axis FROM must be lesser then X axis TO." return]
			x: xmin
			xstep: (xmax - xmin) / ((length? trend) - 1)
			foreach t trend [
				append b reduce [x #"^-"]
				append b reduce [(400 - t) * (tmax - tmin) / 400 + tmin #"^/"]
				x: x + xstep
			]
		][
			foreach t trend [append b reduce [#"^/" (400 - t) * (tmax - tmin) / 400 + tmin]]
		]
		write clipboard:// form b
		request/ok "Trend saved to clipboard."
	][request/ok "First generate a trend, then try again."]
]

show-markers
random/seed now
inform lay