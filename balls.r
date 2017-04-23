REBOL [
	title: "Balls"
	date: 2010-05-21
	file: %balls.r
	author: "Endo"
	version: 1.0.0
	purpose: "Fun for begginers. Cute balls moving around. Give it a try you will like it."
	Library: [
		level: 'begginer
		platform: none
		type: 'fun
		domain: [graphics animation]
		tested-under: none
		license: public-domain
		see-also: none
	]
]

give-me-ball: func [pos color] [
	compose [
		fill-pen (color)
		circle (pos) 30
		fill-pen white
		circle (pos - 14x5) 8
		fill-pen black
		circle (pos - 12x4) 3
		fill-pen white
		circle (pos - 0x5) 9
		fill-pen black
		circle (pos - 2x6) 3
	]
]

move-it: does [
	draw-block: copy []
	forskip balls 2 [
		append draw-block give-me-ball first balls second balls
	]
	compose/deep [
		draw [
			(draw-block)
		]
	]
]

random/seed now

balls: [
	150x150	red
	160x60	green
	180x80	blue
	180x120	yellow
	190x40	purple
	180x180	maroon
	130x190	brown
	180x200	gray
]

range: [-1 0 1]

window: layout [
	backcolor white
	bx: box 450x300 snow rate 60 feel [
		engage: func [f action e] [
			if action = 'time [
				bx/effect: move-it
				forskip balls 2 [
					change balls add first balls as-pair random/only range random/only range
				]
				show bx
			]
		]
	]
]

view window
