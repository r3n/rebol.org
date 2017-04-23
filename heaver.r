REBOL [
	author: "François Jouen"
	title: "Visual Illusions Series:  Heaver Illusion"
	date: 16-Jun-2005
	File: %heaver.r
    Purpose: {
        show some visual illusions with rebol (view 1.3)
    }
    library: [
        level: 'intermediate
        platform: 'win
        type: [tool demo] 
        domain: [gui]   
        tested-under: "View 1.3 "
        support: none 
        license: 'pd ]
]




c1: 270x190
c2: 370x290
b1x: b3x: 219
b2x: b4x: 321
B1y: b2y: 169
b3y: b4y: 271
rot: 0.0
tr: 255
r: 9
tr: 0

cl: to-tuple  reduce [255 0 0 tr]

target: copy  [
				transform rot 320x240 1.0 1.0 0x0
				fill-pen 0.255.0.0
				pen none
				box c1 c2
]
				

occlusion: copy [ fill-pen cl
				pen none
				box 0x0 100x100]

win: layout/size [
	
	origin 0x0
	across
	at 0x0 t1: tog 100 "Start" "Stop" [either face/state [bx/rate: 15] [bx/rate: none] show bx] 
	btn 100 "Quit" [Quit]
	
	at 0x30 bx: box 640x480 white effect [draw target]
	feel [
		engage: func [f a e][
			rot: rot + 1 if  rot > 180 [rot: 0.0] show bx
		]
	]
	at as-pair b1x b1y  b1: box  100x100 effect [draw occlusion]
	
	at as-pair b2x b2y  b2: box 100x100  effect [draw occlusion]
	at as-pair b3x b3y  b3: box 100x100  effect [draw occlusion]
	at as-pair b4x b4y  b4: box 100x100  effect [draw occlusion]
	
	at 0x520 sl: scroller  520x25 [val: round (sl/data * 50) 
								b1/offset/x: b1x - val  b1/offset/y: b1y - val
								b2/offset/x: b2x + val  b2/offset/y: b2y - val
								b3/offset/x: b3x - val  b3/offset/y: b3y + val
								b4/offset/x: b4x + val  b4/offset/y: b4y + val
								show [b1 b2 b3 b4] ]
		info 100 "Occlusion" center
					
  at 0x550 sl2: scroller  520x25	[ v: round (sl2/data * 50) if t1/state [bx/rate: 15 + v ]]		
 		info 100 "Velocity" center	
 at 0x580 sl3: scroller  520x25 [tr: round (sl3/data * 255) cl: to-tuple  reduce [255 0 0 tr] 
 			show [b1 b2 b3 b4] ]
 		info 100 "Transparency" center
]640x610 
view center-face Win



