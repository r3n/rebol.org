rebol[
	file: %request-time.r
	Title: "request time" 
	Author: "Tom Conlin"
	Date: 1-Mar-2003
	Purpose: "widget to return a valid time datatype"
	example: [do %request-time.r request-time 4:20]
	library: [ 
		platform: [ all ] 
		see-also: "aclock.r"
		type: 'tool
		Level: 'intermediate
		Domain: [extension gui sound ui]
		Tested-under: [windows firefox ]
		support: ["ask" ]
		License: pd
	]
]


req-time-ctx: make object! [
	time-lay: none
	result: none
	

; precomputed endpoints
big: [
87x5 95x6 103x8 110x11 117x15 124x19 130x24 136x30 141x36 145x42 149x50 152x57 
154x65 155x73 156x80 155x87 154x95 152x103 149x110 145x117 141x124 136x130 
130x136 124x141 117x145 110x149 103x152 95x154 87x155 80x156 73x155 65x154 
57x152 50x149 42x145 36x141 30x136 24x130 19x124 15x118 11x110 8x103 6x95 5x87 
4x80 5x73 6x65 8x57 11x50 15x42 19x36 24x30 30x24 36x19 42x15 50x11 57x8 65x6 
73x5 80x4]

lil: [
85x29 90x30 96x31 101x33 105x35 110x38 114x42 118x46 122x50 125x54 127x59 129x64
130x70 131x75 132x80 131x85 130x90 129x96 127x101 125x105 122x110 118x114 114x118
110x122 105x125 101x127 96x129 90x130 85x131 80x132 75x131 70x130 64x129 59x127
54x125 50x122 46x118 42x114 38x110 35x106 33x101 31x96 30x90 29x85 28x80 29x75 
30x70 31x64 33x59 35x54 38x50 42x46 46x42 50x38 54x35 59x33 64x31 70x30 75x29 
80x28]

sec: [
88x4 96x5 103x7 111x10 118x14 125x18 131x23 137x29 142x35 146x42 150x49 153x57
155x64 156x72 157x80 156x88 155x96 153x103 150x111 146x118 142x125 137x131 
131x137 125x142 118x146 111x150 103x153 96x155 88x156 80x157 72x156 64x155 
57x153 49x150 42x146 35x142 29x137 23x131 18x125 14x118 10x111 7x103 5x96 4x88
3x80 4x72 5x64 7x57 10x49 14x42 18x35 23x29 29x23 35x18 42x14 49x10 57x7 64x5 
72x4 80x3]

edg: [
88x1 96x2 104x4 112x7 119x11 127x16 133x21 139x27 144x33 149x40 153x48 156x56
158x64 159x72 160x80 159x88 158x96 156x104 153x112 149x119 144x127 139x133 
133x139 127x144 119x149 112x153 104x156 96x158 88x159 80x160 72x159 64x158 
56x156 48x153 40x149 33x144 27x139 21x133 16x127 11x120 7x112 4x104 2x96 1x88 
0x80 1x72 2x64 4x56 7x48 11x40 16x33 21x27 27x21 33x16 40x11 48x7 56x4 64x2 
72x1 80x0]

tic-toc: func["emit DRAW clock face @ time t" t[time!]/local h m s drw-blk radius][
	radius: 80x80
	drw-blk: make block! 256
	insert drw-blk 
	either t < 12:00
		[[pen white fill-pen white]]
		[[pen black fill-pen black]]
	for i 1 60 1[
		either zero? i // 5 
		[insert tail drw-blk compose[circle (sec/:i) 2]]       ; hour marks
		[insert tail drw-blk compose[line   (sec/:i) (edg/:i)]]; minute marks 
	]
	s: either zero? t/3 [60][t/3]
	m: either zero? t/2 [60][t/2]
	h: add multiply t/1 // 12 5 to integer! divide t/2 12 
	h: either zero? h [60][h]
	insert tail drw-blk compose[  ; hands
		pen red  line   (RADIUS) (lil/:h)
		pen blue line   (RADIUS) (big/:m)
		pen yellow line (RADIUS) (sec/:s)
	]
	drw-blk
]

the-time: func [start [time! none!] /local lbl alm alarm civil][
	either start [alarm: start][alarm: now/time]
	civil: either greater-or-equal? alarm 13:00:00 
		[alarm // 12:00:00]
		[either zero? alarm/1[alarm + 12:00][alarm]]
	time-lay: layout [
		origin 0x0 
		across
		panel [ size 220x160
			across
			lbl: label 180 coal rejoin[civil either lesser? alarm 12:00 [" AM"][" PM"]tab tab alarm]
			return
			label 60 "Hours:"
			slider 120x16 gray red with[data: alarm/1 / 24]
			[	alarm/1: minimum 23 to integer! value * 24 
				civil: either greater-or-equal? alarm 13:00:00
					[alarm // 12:00:00]
					[either zero? alarm/1[alarm + 12:00][alarm]]
				lbl/text: rejoin[civil either lesser? alarm 12:00 [" AM"][" PM"]tab tab alarm]         
				alm/effect: reduce ['draw tic-toc alarm]  
				show [lbl alm]
			]
			return
			label 60 "Minutes:"
			slider 120x16 gray blue with[data: alarm/2 / 60]
			[	civil/2: alarm/2: minimum 59 to integer! value * 60
				lbl/text: rejoin[civil either lesser? alarm 12:00 [" AM"][" PM"]tab tab alarm]
				alm/effect: reduce ['draw tic-toc alarm]
				show [lbl alm]
			] 
			return 
			label 60 "Seconds:"
			slider 120x16  gray yellow with[data: alarm/3 / 60]
			[	civil/3: alarm/3: minimum 59 to integer! value * 60
				lbl/text: rejoin[civil either lesser? alarm 12:00 [" AM"][" PM"]tab tab alarm]
				alm/effect: reduce ['draw tic-toc alarm]
				 show [lbl alm]
			] 
			return
			pad 16 btn-enter  "Set" 64[hide-popup result: alarm]
			pad 16 btn-cancel "Off" escape 64[hide-popup result: 24:00:00]
		] 
		alm: box 160x160 effect reduce ['draw tic-toc alarm]
	]
]

	set 'request-time func["Returns a time. 0:00:00 thru 23:59:59 are set. 24:00:00 is unset" 
		t [time! none!] /offset xy
	][
		result: either t [t][24:00:00]
		the-time either t [t][now/time]
		either offset [inform/offset/title time-lay xy "what time?"] [inform/title time-lay "what time?"]
		result
	]
]


