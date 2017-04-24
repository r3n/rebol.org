REBOL [
	File: %line-intersection-demo.r
	Date: 10-Jan-2004
	Title: "Line Intersection Demo"
	Purpose: {Demonstrate an algorithm used to detect an intersection between two line segments.}
	Library: [
		level: 'intermediate
		platform: 'all
		type: [function FAQ]
		domain: [ui user-interface graphics gui animation]
		tested-under: [view 1.2.1.3.1 on W2K]
		support: none
		license: 'public-domain
		see-also: none
	]
	Version: 1.0.0
	Author: "Claude Precourt"
	Acknowledgements: ["Paul Bourke"]
	Web: http://astronomy.swin.edu.au/~pbourke/geometry/lineline2d/
]

line-intersect?: func [
		pt1 [pair!] pt2 [pair!] pt3 [pair!] pt4 [pair!]
		/local denom ua ub
	][
		denom: ((pt4/y - pt3/y) * (pt2/x - pt1/x)) - ((pt4/x - pt3/x) * (pt2/y - pt1/y))
		if denom = 0 [print "parallel" return false] ;; lines are parallel
		ua: (((pt4/x - pt3/x) * (pt1/y - pt3/y)) - ((pt4/y - pt3/y) * (pt1/x - pt3/x))) / denom
		ub: (((pt2/x - pt1/x) * (pt1/y - pt3/y)) - ((pt2/y - pt1/y) * (pt1/x - pt3/x))) / denom
		either (ua >= 0) and (ua <= 1) and (ub >= 0) and (ub <= 1) [return true][return false]
]

img-data: to-image layout [origin 0x0 box black 512x512]
view layout [
	img: image img-data
	across
	button "Test" [
		pt1: to-pair reduce [random 512 random 512]
		pt2: to-pair reduce [random 512 random 512]
		pt3: to-pair reduce [random 512 random 512]
		pt4: to-pair reduce [random 512 random 512]
		either line-intersect? pt1 pt2 pt3 pt4 [
			pen-color: red
			status-text/text: "YES"
		][
			pen-color: white
			status-text/text: "NO"
		]
		img-data: to-image layout [origin 0x0
			box black 512x512 effect [
				draw [pen pen-color line pt1 pt2 line pt3 pt4]   
			]
		]
		img/image: img-data
		show [img status-text]
	]
	button "Quit" [quit]
	text bold "  Intersection?"
	status-text: text 150x24 "-"
]