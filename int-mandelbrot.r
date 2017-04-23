;Red [
;World [
REBOL [
	Title:		"Mandelbrot fractal ASCII renderer, integer version for Rebol, Red and World"
	Author:		"Marco Antoniazzi"
	file: %int-mandelbrot.r
	; you must comment out all dates and tuples for Red
	date: 28-Dec-2013
	version: 1.0.0
	Purpose: "Show a Mandelbrot fractal on the console"
	License: {
		PD/CC0
		http://creativecommons.org/publicdomain/zero/1.0/
	}
	Notes: {Derived from John Niclasen, Kaj de Vos, Glenn Rhoads.
		Using only simple while loops.
		Change script header to test it with various rebol-ish languages.
	}
	Tabs:		4
	library: [
		level: 'beginner
		platform: 'all
		type: 'function
		domain: [math]
		tested-under: [
			View 2.7.8.3.1
			Saphir-View 2.101.0.3.1
			Red 0.4.1
			World [0 win32 2.1.1]
		]
		support: none
		license: none
		see-also: none
	]
]
if 0 = first load form system/version [
	; for Red v.0.4.1
	mod: func [a [integer!] b [integer!]] [a - (a / b * b)]
]

; using 1000 as a multiplier to use only integer numbers
THRESHOLD: 16 * 1000
MAX_ITERATIONS: 1000

mandelbrot: func [
	x		[integer!]
	y		[integer!]
	/local
		i cr ci zr zi zr2 zi2 zrzi
	][
	cr: y - 500 ;(to-integer 1000 / 2)
	ci: x
	zr: 0
	zi: 0

	i: 0
	while [i < MAX_ITERATIONS] [
		zrzi: zr * zi / 1000
		zr2: zr * zr / 1000
		zi2: zi * zi / 1000
		zr: zr2 - zi2 + cr
		zi: zrzi + zrzi + ci

		if zr2 + zi2 > THRESHOLD [return i]
		
		i: i + 1
	]
	0
]

;start: now/time/precise ; only for Rebol and World

b: " .,:;!/>)|&IH%*#"

y: -1000 
while [y < 1000] [
	x: -1000 
	while [x < 1000] [

		; this is the most difficult part to write in a "multi-rebol-ish compatible" way
		;prin either zero? mandelbrot y x [#"*"] [#" "]
		;prin b/(1 + mod mandelbrot y x 16) ; with Red I must write prin b/(1 + mod (mandelbrot y x) 16) but then it does not work with World 
		m: mandelbrot y x
		prin b/(1 + mod m 16)

		x: x + 26 ;to-integer 1000 / 38 
	]
	prin "^/"
	
	y: y + 50 ;to-integer 1000 / 20 
]

;print ["Elapsed time:" now/time/precise - start] ; only for Rebol and World

halt
