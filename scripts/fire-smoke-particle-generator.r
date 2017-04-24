rebol [
    title: "Fire and Smoke particles generator."
    purpose: "A particle engine demo which generates fire and smoke, with a lot of control and some compositing built-in"
    version: 1.0.2
    date: 2010-09-18
    file: %fire-smoke-particle-generator.r
    library: [ 
        level: 'intermediate 
        platform: 'all
        type: [demo fun ] 
        domain: [animation game graphics math visualization ] 
        tested-under: [view 2.7.7]
        support: none 
        license: 'MIT
    ] 
]

;save %particle-fire-setup.r fire-setup
;save %particle-smoke-setup.r smoke-setup


;----------------------------------
;- SETUP PROPERTIES
;-     fire-setup:
fire-setup: any [
	all [
		exists? %particle-fire-setup.r
		attempt [load %particle-fire-setup.r]
	]
load decompress 64#{
eJztl19qwzAMxt8Hu0MukKB/tuUD7Cgb7HVPPf7sMGiULI4VGuhgpVCX74f6WZLl
dIxwG0mG15fyGWHAAaZQvn18fr0PY5bbGKAh0kKcyLwsS7dROlktjFAfi7GauMMy
ZVZKGEHmxdu44kM0ph/P58JjPx/ZyZOPD2zKCxMHBZKYcV4Em/myWYzLzLOEmDJg
XWyC16KidOOlVD7aNleTTuCivbFRu2klF62WXrBlsc42UR9a6tiLzod4UfJ+MWmZ
DXRGXJ1Zjwi2QftFDPbgrFW0s2yrYtpVW46P1NhS59m866qtzvs9q0pTjeddRTth
YEJ7Piyt1scBXXuun1Zw0S4nSqaqR75rPrmTzjY0/5J83VXLDzHsqGWHi3uCpwR8
f2/G1nPAiZZz/JHwqov/DI1JzH1/gAc7pv/pn0tP4nU0dTuhuZj6LDhdidfZdCHu
NOPDA5jHpCNc1IeTC2d1eXfizq3WPxR873edomBOgUHnxYavt5uLl0vjMxaOxcGT
k1cnH0/EBwcvLp6yfd445JNtnzb/DRBrc6mbEAAA
}
]

;-     smoke-setup:
smoke-setup: any [
	all [
		exists? %particle-smoke-setup.r
		attempt [load %particle-smoke-setup.r]
	]
load decompress 64#{
eJytlDEOwzAIRfdKuYMvgGRTTMmBOkVVhy4cP5C5n0pWN8tPmM8HQ2OaE1vbbt3p
3hu3EefP6308G42pAbmC/Tu8GHh1ZycFcXuVUBMKgI+oQ/8PTQqovBppGQmNNQzT
vKmACTYv1SDvStbXmJozkBmuwRfNB5iaEImGzRTmKtD6UIRKEpQwGSohe4f6UzAV
F2RzgRSiMfOy/NdwI8gqFMPr4hKEOv8DSgXhOjkBDzAYsvkEAAA=
}]


;----------------------------------
;- SMOKE PROPERTIES
;-     smoke-lift:
smoke-lift: 5

;-     smoke-clr:
smoke-clr: 175.175.175

;-     smoke-opacity:
smoke-opacity: 0.0.0.160

;-     smoke-life:
smoke-life: 2

;-     smoke-life-variance:
smoke-life-variance: 1


;----------------------------------
;- FIRE PROPERTIES
;-     fire-life:
fire-life: 1

;-     fire-life-variance:
fire-life-variance: 0.5


;-     fire-clr:
fire-clr: gold

;-     fire-Opacity:
fire-Opacity: 0.0.0.150


;- ENVIRONMENT CONTROLS
;-     wind-strength:
wind-strength: 3

;-     air-turbulence:
air-turbulence: 5x5 ; a which adds random variation in all directions to all particle movement note that this value becomes +/- n


;- GENERAL VIEW AND SIMULATION CONTROLS

unless exists? %house.png [ 
	house-url: http://www.pointillistic.com/open-REBOL/moa/files/house.png
	branches-url: http://www.pointillistic.com/open-REBOL/moa/files/branches.png
	print "--------------------------------------------------------------"
	print "this script will download two images from the web to your disk."
	print "they will be saved  at the same location as this script."
	print "--------------------------------------------------------------"
	print ""
	probe house-url
	probe branches-url
	print ""
	ask"press enter to continue..."
	write/binary %house.png read/binary house-url
	write/binary %branches.png read/binary branches-url
]
bg-img: load %house.png
fg-img: load %branches.png

;-     view-scale:
view-scale: 0.5

;-     view-offset:
view-offset: 0x0

;-     view-origin:
view-origin: 200x200

;-     paused?:
paused?: false

;-     update?:
update?: false

;-     gradients?:
gradients?: none


;-     gen-rate:
gen-rate: 400



;-     particles:
; stored as sets of:  position [pair!] velocity [pair!] age [decimal!] life [decimal!]
; 		
;
;		 position: last pair position of a particle
;
;		 velocity: its last known velocity in termes of /second
;
;		 age:  its current age, accumulated via all previous move-particles()
;
;		 life: particle's life expectancy
;
;		 type: particle type as a word, used for later use. (ex: fire generates smoke, smoke dies)
;
particles: []


;-     particle-items:
particle-items: 5



;-     birth-points:
; stored as sets of:  
; 		position [pair!] velocity [pair!] life [decimal!] life-variance [decimal!] type [word!]
;
;		 position: birth place of a particle
;
;		 velocity: launch velocity
;
;		 life: particle's minimal life expectancy
;
;		 life-variance: a paiitcle's life variance  (a random amount added to life at each birth)
;
;		 type: particle type as a word, used for later use. (ex: fire generates smoke, smoke dies)
;
birth-points: []

append birth-points fire-setup
append birth-points smoke-setup


;-     birth-point-items:
birth-point-items: 5

;-     simulation:
;
; holds the particle draw block
simulation: make block! 100000





;-   
;- FUNCTIONS
;------------------------
;-     birth-particles()
;------------------------
birth-particles: func [
	rate [integer!] "number of particles to generate"
	density [decimal!]  "a percentage for each birth points (usually equal to time delta)"
	/local pos vel life type life-variance origins
][
	;print to-time rate
	unless empty? birth-points [
		origins: (length? birth-points) / birth-point-items
		loop rate [
			birth-point: at birth-points (birth-point-items * (random origins) - birth-point-items + 1)
			set [pos vel life life-variance type] birth-point
			if density > ( (0.0001 * random 10000)) [
				;prin "!"
				insert particles reduce [
					pos 
					vel 
					0.0 
					(life + random life-variance) 
					type
				]
			]
		]
	]
]


;-----------------
;-     distance()
;-----------------
distance: func [
	a
	b
][
	square-root (power (b/x - a/x) 2) + power (b/y - a/y) 2
]




;------------------------
;-     age-particles()
;------------------------
age-particles: func [
	delta [decimal!] "how much age to add to particles"
	/local pos vel age life type 
][
	;prin ">"

	unless empty? particles [
		;delta: delta - (0.000001 * random 10000)
		until [
			set [pos vel age life type] particles
			either age > life [
				; particle is too old  we must kill it
				remove/part particles particle-items
			][
;				print "---"
;				?? pos
;				?? vel
;				?? age
;				?? life
;				?? type
				vel: variate-velocity pos vel age delta type
				age: age + delta
				
				; for now the only real property is position, but eventually, we could
				; fork this process to a per particle process, to allow more powerfull
				; effects like death based on proximity, collisions, color variance, etc.
				pos: pos + (vel * delta) ; unfortunately the integer nature of R2 pairs can make some movements static. 
				                         ; one way to cure this is to multiply the amounts and downscale them via a scale matrix in AGG.
				change particles reduce [pos vel age]
				particles: skip particles particle-items
			]
			tail? particles
		]
		particles: head particles
	]
]

;------------------------
;-     variate-velocity()
;------------------------
variate-velocity: func [
	pos vel age delta type
][
	; no variance for now
	; eventually, each type will have an algorithm to control movement, which might even require
	; particle list inspection (proximity, etc)
	
	switch/default type [
		smoke [
			vel: vel + (age * wind-strength * 1x0) 
			vel: vel + (smoke-lift * 0x-1 )
			vel: vel + (random (2 * air-turbulence)) - air-turbulence
		]
		fire [
			;vel: vel + (smoke-lift * 0x-1 )
			vel: vel + (age * wind-strength * 1x0) 
			vel: vel + (random (2 * air-turbulence)) - air-turbulence
		]
	][
		vel
	]
]

;-----------------
;-     hose-fire()
; removes particle sources near position.
;-----------------
hose-fire: func [
	blk [block!]
	offset [pair!]
	/local pos vel life life-variance type
][
	
	until [
		set [pos vel life life-variance type] blk
		either (10 > distance pos offset) [
			; particle is too old  we must kill it
			remove/part blk birth-point-items
		][

			blk: skip blk birth-point-items
		]
		tail? blk
	]
]



;------------------------
;-     generate-simulation-results()
;
; returns a draw block which represents the particles
;
; the particles types are currently hard-coded, but can
; this can easily be modified for more control.
;------------------------
generate-simulation-results: func [
	/local pos vel age life type fade clr fade-clr rad age-ratio
][
	; first we clear previous simulation results.
	clear simulation
	append simulation [
		pen none 
		; center the view
		translate view-origin 
		translate view-offset 
		scale view-scale view-scale
	]
	prin "."
	

	foreach [pos vel age life type] particles [
		switch type [
			smoke [
				
				either gradients? [
					fade-clr: 0.0.0.255 - smoke-opacity
					fade: (smoke-opacity + (fade-clr * (age / life)))
					rad: (60 * age / 5)
					clr: smoke-clr + fade
					append  simulation compose [
						fill-pen radial (pos) 0 (rad) 0 1 1 (clr )(clr + (fade * .08))(clr + 0.0.0.255)
						circle (pos) (rad)
					
					]
				][
					fade-clr: 0.0.0.255 - smoke-opacity
					fade: (smoke-opacity + (fade-clr * (age / life)))
					append  simulation compose [
						fill-pen (smoke-clr + fade)
						circle (pos) (40 * age / 5)
					
					]
				]
			]
		
			fire [
				fade: (life - age ) / life
				spent: age / life
;				either gradients? [
;					clr:   red + 0.20.0 + (gold + 0.0.30 * fade)
;					iclr: clr
;					if fade > .75 [
;						iclr: white - clr
;						iclr: clr + ( iclr * (fade - 0.75 * 4 ));white * 0.75 + (white * fade
;					]
;					clr: clr + fire-Opacity
;					fade: 0.0.0.255 - fire-opacity
;					rad: 7 * (life - age) / life
;					append  simulation compose [
;						;pen black
;						fill-pen radial (pos) 0 (rad) 0 1 2 (iclr )((clr + (fade / 2)))(clr + 0.0.0.255)
;						circle (pos) (rad * 2) (rad * 4)
;					]
;				][
					rad: 3
					rad: either spent < 0.2 [
						clr:   red + 0.20.0 + (gold + 0.0.30 * fade)
						clr: gold * (0.2 - spent * 2) + clr
						spent * rad * 5
					][
						clr:   red + 0.20.0 + (gold + 0.0.30 * fade)
						1 - (spent - 0.2 * 1.25) * rad
					]
					
					clr: clr + fire-Opacity
					append  simulation compose [
						fill-pen (clr)
						circle (pos) (rad) (rad * 1.4)
					]
;				]
			]
		]
	
	]
]


; show the console behind the rest.
print ""

;-  
;- WINDOW:
win: view/new/options layout [
	style scroller scroller 300x15
	style text text right 110x18
	space 2x2
	across
	simulation-pane: box with [
		image: bg-img 
		text: none
		color: none
		effect: [draw simulation ]
		size: 400x400
		offset: 50x50
		edge: none
		rate: 30
	]
	return
	;-     commands
	btn 100 "pause" [
		paused?: not paused? 
		face/text: either paused? ["play"]["pause"] 
		simulation-pane/feel/last-time: now/precise - 0:0:0.006
		show face
	]
	btn 100 "reset"[
		clear birth-points
		clear particles
	]
	btn 100 "restart"[
		clear particles
	]
	return
	pad 0x5
	text -1x-1"use gradients (CPU intensive)"
	pad 0x2
	check [
		gradients?: face/data
		update?: true
	]

	origin 420x20
	
	h3 "Environment:" left
	return

	text  "Wind"
	scroller  0.1 [
		wind-strength: face/data * 30
		?? wind-strength
	]
	return
	
	text "Turbulence"
	scroller  0.2 [
		air-turbulence: face/data * 30x30
		?? air-turbulence
	]
	return
	
	pad 0x10
	h3 "Birth Control:"
	return
	
	;-     particle properties
	text "Rate" 
	scroller 260x15 0.4 [
		gen-rate: to-integer (face/data * 1000)
		?? gen-rate
		rate-txt/text: to-string gen-rate
		show rate-txt
	]
	rate-txt: text right 40x15 "200" edge [size: 1x1 effect: 'ibevel] para [origin: 0x-2]
	return

	text "Fire life"
	scroller  0.2 [
		fire-life: face/data * 3
		fire-life
	]
	return
	
	text "Smoke life"
	scroller  0.2 [
		smoke-life: face/data * 3
		smoke-life
	]
	return
	
	pad 0x20
	h3 "Looks"
	return
	
	text "Smoke Opacity"
	scroller  0.2 [
		smoke-Opacity: 0.0.0.255 * (1 - face/data)
		smoke-Opacity
		update?: true
	]
	return
	
	text  "Smoke Darkness" 
	scroller  0.93 [
		smoke-clr: white * (1 - face/data)
		smoke-clr
		update?: true
	]
	return
	
	text "Fire Opacity"
	scroller  0.4 [
		fire-Opacity: 0.0.0.255 * (1 - face/data)
		fire-Opacity
		update?: true
	]
	return
	
	pad 0x20 
	h3 "view:"
	return

	text "Scale"
	scroller  [
		view-scale: face/data * 30
		view-scale: (3 * face/data) + 0.5
		update?: true
	]
	space 5x5
	return
	pad 0x20
	h3 "Notes:"
	return
	pad 20x0
	text left as-is 400x140 wrap {*Click for new fire origin, right-click for smoke!
*Shift Click & Drag to move the whole setup.
*Control-Click near a particle source to REMOVE it.
*If you reduce Fire or Smoke Life *before* creating new fires or smoke sources, they will die out sooner (i.e. smaller flames).
*Rate is shared accross all particle sources, so the more sources you have, the more you will have to crank up the rate.
*When too many particles are visible, refresh will start to slow down, but speed is preserved.}
	return
	origin 20x20
][all-over]


fg-pane: make face [

	size: 400x400
	text: none
	effect: none
	image: fg-img
	edge: none
]

fg-pane/effect: [merge]
simulation-pane/pane: fg-pane

;-  
;------------------------
;- simulation-feel()
;------------------------
simulation-pane/feel: make face/feel [
	last-time: now/precise
	current-time: none
	drag-pos: none
	setup: none
	engage: func [face action event][
		;?? action
		switch action [
			over [
				if drag-pos [
					view-offset: event/offset - drag-pos
					update?: true
				]
			]
			away [
			]
			time [
				if any [update? not paused?] [
					unless paused? [
						current-time: now/precise
						delta: to-decimal difference current-time last-time
						birth-particles gen-rate (delta * 2)
						age-particles delta
						last-time: current-time
					]
					generate-simulation-results

					prin (length? particles) / particle-items
					show simulation-pane
					update?: false
				]
			]
			;-    -down
			down [
				either event/shift [
					drag-pos: event/offset - view-offset
				][
					either event/control [
						hose-fire birth-points ( ((event/offset  - view-origin - view-offset) * (1 / view-scale)) )
						hose-fire fire-setup ( ((event/offset  - view-origin - view-offset) * (1 / view-scale)) )
						hose-fire smoke-setup ( ((event/offset  - view-origin - view-offset) * (1 / view-scale)) )
					][
						setup: compose [
							( ((event/offset  - view-origin - view-offset) * (1 / view-scale)) )
							0x-60
							(fire-life)
							(fire-life-variance)
							fire
						]
						append birth-points setup
						append fire-setup setup
					]
				]
			]
			up [
				drag-pos: none
			]
			;-    -alt-down
			alt-down [
				setup: compose [
					( ((event/offset  - view-origin - view-offset) * (1 / view-scale)) )
					0x-30
					(smoke-life)
					(smoke-life-variance)
					smoke
				]
				append birth-points setup
				append smoke-setup setup
			]
		]
		
	]
]

;- start
do-events

save %particle-fire-setup.r fire-setup
save %particle-smoke-setup.r smoke-setup
