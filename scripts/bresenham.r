REBOL [
    title:      "Bresenham Line"
	file:       %bresenham.r
    author:     "Semseddin (Endo) Moldibi"
    version:    1.0.0
    date:       2010-08-08
    purpose:    "Returns all pairs in a block for line specified by P0/P1."
    Library: [
        level: 'beginner
        platform: 'all
        type: 'function
        domain: 'math
        tested-under: none
        support: "semseddin/at/gmail.com"
        license: 'public-domain
        see-also: none
    ]
]

BresenhamLine: funct [p0 [pair!] p1 [pair!]] [
	result: make block! 32

	if p0 = p1 [return append result p0]

	x0: p0/x x1: p1/x
	y0: p0/y y1: p1/y

	steep: greater? abs (y1 - y0) abs (x1 - x0)
	if steep [
		t: x0	x0: y0	y0: t
		t: x1	x1: y1	y1: t
	]
	if x0 > x1 [
		t: x0	x0: x1	x1: t
		t: y0	y0: y1	y1: t
	]
	deltax: x1 - x0
	deltay: abs (y1 - y0)
	error: 0
	deltaerr: deltay / deltax
	ystep: either y0 < y1 [1] [-1]
	y: y0
	for x x0 x1 1 [
		p: either steep [as-pair y x] [as-pair x y]
		append result p
		error: error + deltaerr
		if error >= 0.5 [
			y: y + ystep
			error: error - 1.0
		]
	]
	result
]

;probe BresenhamLine 13x5 25x17
;halt
