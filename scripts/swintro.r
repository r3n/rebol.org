REBOL [
	Title: {"Star Wars" reminiscent intro}
	Date: 29-Jun-2005
	Author: "Bohdan Lechnowsky"
	File: %swintro.r
	Purpose: {
		To demonstrate AGG and 3D-type calculations using Rebol
	}
	Notes: {
		Thanks to Anton Rolls via AltME Rebol3 world for his excellent modifications
	}
	Library: [
		level: 'intermediate
		platform: 'all
		type: [demo fun]
		domain: [graphics visualization]
		tested-under: none
		support: none
		license: none
		see-also: none
	]
]

fovsz: 640x480 ;system/view/screen-face/size

layout compose [starfield: image (fovsz) black]

starfield: to-image starfield

loop 1000 [
	col: random 255
	starcol: to-tuple reduce [col col col]
	poke starfield random fovsz/x * fovsz/y starcol
]

view/new layout/offset/origin compose [
	b: image starfield effect [draw []] rate 30 feel [
		engage: func [face action event][
			if action = 'time [update-image]
		]
	]
] either fovsz = system/view/screen-face/size [0x0][20x20] 0x0

hvector: func [x y v][
	(fovsz/x / fov) * (fov / 2 + either zero? pos/2 - y [90][arctangent (pos/1 - x) / (pos/2 - y)])
]

vvector: func [y z v][
	(fovsz/y / fov) * (fov / 4 + either zero? pos/2 - y [90][arctangent (pos/3 - z) / (pos/2 - y)])
]

map: parse/all trim/auto {A New Beginning

	Rebol HQ, led by their jedi leader,
	Carl Sassenrath, has begun
	preparations to strike back against
	Darth Gates at the Redmond system
	during a time of growing unrest
	among the netizens of the Empire.
	
	As the Empire works to complete
	construction of their hailed
	planetary domination device, code
	named "Longhorn Death Star", small
	centers of resistance continue to
	gain support among the
	oppressed masses.
	
	Even with mounting support, only
	One is powerful enough to overcome
	the dark side of the Force --
	
	Rebol/View 1.3
} "^/"

mapimg: copy []

foreach line map [
	b1: layout/origin compose/deep [text (line) 840 center font-size 48 sky black (either any [line = map/1 line = last map]['bold][])] 0x0
	append mapimg to-image b1
]

pos: [0 30 20]
dir: [0 0]

fov: 45

l: pos/2
update-image: does [
	agg: clear []
	x: 0 y: 0
	foreach item mapimg [
		y: y + 5
		if y < pos/2 [
			append agg compose [
				image (item)
				(to-pair reduce [hvector x + 15 y dir/1 vvector y 0 dir/2])
				(to-pair reduce [hvector x - 15 y dir/1 vvector y 0 dir/2])
				(to-pair reduce [hvector x - 15 y + 5 dir/1 vvector y + 5 0 dir/2])
				(to-pair reduce [hvector x + 15 y + 5 dir/1 vvector y + 5 0 dir/2])
				black
			]
		]
	]
	b/effect/draw: agg

	show b

	pos/2: l
	either l < 200 [l: l + 0.2][quit]
]

do-events