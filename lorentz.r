REBOL [
	Title:		"Lorentz Attractor"
	Date:		24-Feb-2009
	Version:	1.0.0
	File:		%lorentz.r
	Author:		"John Niclasen"
	Purpose:	{
		Visualization of the Lorentz Attractor.
	}
]

context [

hsv2rgb: func [
	H S V
	/local
		RGB
		var_h var_i
		var_1 var_2 var_3
		var_r var_g var_b
][
	RGB: 0.0.0
	either S = 0		;HSV values: 0 ÷ 1
	[
		RGB/1: to-integer V * 255
		RGB/2: to-integer V * 255
		RGB/3: to-integer V * 255
	][
		var_h: H * 6
		if var_h >= 6 [var_h: 0]		;H must be < 1
		var_i: to-integer var_h
		var_1: V * (1 - S)
		var_2: V * (1 - (S * (var_h - var_i)))
		var_3: V * (1 - (S * (1 - (var_h - var_i))))
	
		switch var_i [
			0 [var_r: V			var_g: var_3	var_b: var_1]
			1 [var_r: var_2		var_g: V		var_b: var_1]
			2 [var_r: var_1		var_g: V		var_b: var_3]
			3 [var_r: var_1		var_g: var_2	var_b: V	]
			4 [var_r: var_3		var_g: var_1	var_b: V	]
			5 [var_r: V			var_g: var_1	var_b: var_2]
		]
	
		RGB/1: to-integer var_r * 255		;RGB results: 0 ÷ 255
		RGB/2: to-integer var_g * 255
		RGB/3: to-integer var_b * 255
	]
	RGB
]

sigma: 3.0
rho: 26.5
beta: 1.0
x: 0.0
y: 1.0
z: 1.0
dt: 0.005
ddt: [x (sigma * (y - x)) y (rho * x - (x * z) - y) z (x * y - (beta * z))]
nx: ny: nz: none
dx: dy: dz: none
h: 0.0
s: 1.0
v: 1.0
c: red

map: make image! 800x400

do-step: does [
	dx: do ddt/x
	dz: do ddt/z
	nx: x + (dx * dt)
	ny: y + ((do ddt/y) * dt)
	nz: z + (dz * dt)

	a: either zero? dx [pi / 2] [arctangent/radians dz / dx]
	s: (cosine/radians a) ** 0.4 + 0.2 * 5.0 / 6.0
	;v: 2.0 - ((cosine/radians a) ** 0.5 + 0.8 * 5.0 / 9.0) / 2.0
	v: 1.2 - s * 5.0 / 6.0
	c: hsv2rgb h s v
	draw map reduce [
		'scale 0.1 0.1
		'line-width 20.0 'line-cap 'square 'line-join 'round
		'pen black
		'line
		as-pair (4000 + round x * 240.0) (4000 - round z * 80.0)
		as-pair (4000 + round nx * 240.0) (4000 - round nz * 80.0)
		'pen c
		'line
		as-pair (4000 + round x * 240.0) (4000 - round z * 80.0)
		as-pair (4000 + round nx * 240.0) (4000 - round nz * 80.0)
	]
	x: nx
	y: ny
	z: nz
	if 1.0 < h: h + 0.0002 [h: 0.0]
]

main: layout [
	origin 0
	i: image map rate 50 feel [
		engage: func [f a e] [
			if a = 'time [
				loop 8 [do-step]
				show i
			]
		]
	]
	at 0x0
	key #"^q" [unview]
]

view/title main "Lorentz Attractor"

]	; context

