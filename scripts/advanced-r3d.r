REBOL [ 
	Title: "Advanced R3D demo" 
	Author: "Massimiliano Vessi" 
	Email: maxint@tiscali.it 
	Date: 09-Oct-2012 
	version: 3.1.6
	file: %advanced-r3d.r 
	Purpose: "R3D demo"
	;following data are for www.rebol.org library 
	;you can find a lot of rebol script there 
	library: [ 
		level: 'intermidiate 
		platform: 'all type: [demo tool] 
		domain: [animation graphics] 
		tested-under: [windows linux] 
		support: none 
		license: [gpl] 
		see-also: none 
		] 
	] 


if not exists? %3D-models/ [make-dir %3D-models/ ]

change-dir %3D-models/

if not exists? %r3d2.r [ request-download/to http://www.rebol.org/download-a-script.r?script-name=r3d2.r  %r3d2.r  ]

do %r3d2.r


if not exists? %palms.jpg [ request-download/to http://www.rebol.com/view/demos/palms.jpg  %palms.jpg  ]
img: load-image %palms.jpg

list-3d: [Apple.off          asu.off            dragon.off         goblet.off
head.off           heart.off          helm.off           house.off
king.off           klingon.off        mushroom.off       pear.off
r2.off             seashell.off       space_shuttle.off  space_station.off
Sword01.off        teapot.off         volks.off          x29_plane.off ]

foreach item list-3d [
	item2: to-file item 
	if not exists? to-file item2 [  request-download/to (join http://www.maxvessi.net/rebsite/3D-models/ item)  item2    ]
	]



Transx:  300
Transy:  290
Transz: 320
projection: 256
hr: 1
model:  cube-model
color2: color: red ;color2 is the backup of the color
colorb2: colorb: black ;background
backg: 0
dimx: dimy: dimz: 100
reset-3d: func [] [dimx: dimy: dimz: 100] ;to reset view
translx: transly: translz: 0
rotx: roty: rotz: 0

; Set some camera
Lookatx:  Lookaty:  Lookatz: 100.0       ; starting camera will look this position
no-cull: false




;model: reduce [cube-model (r3d-scale dimx dimy dimz) red ]							 


do update-3d: func [		
	] [            ; This "update" function is where
	world: copy []           ; everything is defined.
	properties: r3d-compose-m4 reduce [ 
	r3d-scale dimx dimy dimz
	r3d-translate translx transly translz	
	r3d-rotateX rotx
	r3d-rotateY roty
	r3d-rotateZ rotz
	]
	object: reduce [ model  properties color]
	append world reduce [  object ]
	camera: r3d-position-object   reduce [Transx Transy Transz]  reduce [Lookatx Lookaty Lookatz]  reduce [sine hr 0 cosine hr] 
	either no-cull [RenderTriangles: render/no-cull world camera (r3d-perspective projection)  400x360][
	RenderTriangles: render world camera (r3d-perspective projection)  400x360]
	switch backg [
		0 [ none ] 
		1 [ insert  RenderTriangles [image 0x0 400x360 logo.gif] ]
		2 [ insert  RenderTriangles [
			pen none
			fill-pen linear 0x0 0 90 90  1 1 blue sky brown 
			box 0x0 400x360 			
			] ]
		]
	;probe RenderTriangles    ; This line demonstrates what's going on
	]                            ; under the hood.  You can eliminate it.



view layout [
	panel [	
	scrn: box 400x360 black effect [draw RenderTriangles]  ; basic draw
	return 
	h2 "Objects"
	radio-line true "Box made of 12 triangle faces" [model: cube-model  no-cull: false  update-3d show scrn ]	
	radio-line  "Cube red made of 6 square faces" [model: cube2-model no-cull: false   update-3d show scrn ]	
	radio-line  "Triangular pyramid" [model: pyramid-model 	no-cull: false update-3d  show scrn ]	
	radio-line  "Square pyramid transparent red" [model: square-pyramid-model no-cull: false   update-3d show scrn ]	
	radio-line  "Octagonal prysm" [model: prysm-8-model  no-cull: false update-3d    show scrn ]
	radio-line  as-is "Just a face, faces have just one side shown, ^/ move RotationZ to see it" [model: wall-model no-cull: false  projection: 256 update-3d show scrn ]
	panel [
		across
		btn "Load OFF file..." [
			no-cull: true
			off-file: request-file/only/filter/title "*.off" "Select a OFF file:" "Load"  
			model: r3d-Load-OFF  off-file
			; calculate default scale from model/3 if it exists
			modelsize: 1.0
			modelsize: model/3 
			if modelsize < 1.0 [ modelsize: 1.0 ]
			defaultScale: 512 / modelsize
			dimx: dimy: dimz:  defaultScale
			update-3d 
			show scrn
			]
		btn "Reset dimensions" [reset-3d update-3d show scrn]
		return 
		text italic 250 {Since not all models have a correct normal face orientation, 
		I turned off back face culling for the model downloaded. I can be slow on old PC.}	
		]
	]
	panel [
		h2 "Camera"
		panel 142.101.117  [	
			label "TransX" 
			slider  60x16 [Transx:  300 - (value * 600 )   update-3d show scrn]
			label "TransY" 
			slider 60x16 [Transy: 290 - (value * 600 )  update-3d show scrn]    
			label "TransZ" 
			slider 60x16 [Transz:  320 - (value * 600)  update-3d show scrn]
			return 
			label "LookatX" 
			slider 0.17 60x16 [Lookatx: (value * 600 ) update-3d show scrn]    
			label "LookatY" 
			slider 0.17 60x16 [Lookaty: (value * 600 ) update-3d show scrn]    
			label "LookatZ" 
			slider 0.17 60x16 [Lookatz: (value * 600 ) update-3d show scrn]
			return 
			label "Projection" 
			slider 0.5 60x16 [projection: (value * 500 )
				if projection = 0 [projection: 0.1]
				update-3d 
				show scrn
				]
			label "UP vector" 
			slider 60x16 [hr: (value * 360 )
				if hr = 0 [hr: 0.1]
				update-3d 
				show scrn
				]	
			]
		return
		h2 "Objects properties"		
		panel 0.51.64  [
			label "DeformX"
			slider 0.17  60x16 [dimx:  value * 600    update-3d show scrn]
			label "DeformY"
			slider 0.17  60x16 [dimy:  value * 600    update-3d show scrn]
			label "DeformZ"
			slider 0.17  60x16 [dimz:  value * 600    update-3d show scrn]
			return 
			label "TransX" 
			slider  60x16 [translx:  value * 600    update-3d show scrn]
			label "TransY" 
			slider  60x16 [transly:  value * 600    update-3d show scrn]
			label "TransZ" 
			slider  60x16 [translz:  value * 600    update-3d show scrn]
			return 
			label "RotationX"
			slider  60x16 [rotx:  value * 360    update-3d show scrn]
			label "RotationY"
			slider  60x16 [roty:  value * 360    update-3d show scrn]
			label "RotationZ"
			slider  60x16 [rotz:  value * 360    update-3d show scrn]
			]
		return	
		h2 "Color and bitmap"
		panel 39.80.0 edge [size: 5x5 color: 39.80.0 ] [			
			across			
			radio true  [color: color2 update-3d show scrn]
			label "Object with color" 
			button 39.80.0 "Change color" [
				color: request-color  
				if none? color [color: color2] 
				color2: color   
				update-3d 
				show scrn
				]
			return 				
			radio   [color2: color  color: img  update-3d show scrn]
			label 	"Object with image"
			return 
			panel [				
				across			
				radio true  [
					backg: 0
					colorb: colorb2 
					scrn/color: colorb
					update-3d
					show scrn
					]
				label "Bakcground with color" 
				button 39.80.0 "Change color" [
					colorb: request-color  
					if none? colorb [colorb: colorb2] 
					colorb2: colorb   
					scrn/color: colorb
					show scrn
					]
				return 	
				radio   [backg: 1 update-3d show scrn]
				label 	"Background with image"	
				return 	
				radio   [backg: 2 update-3d show scrn]
				label 	"Background 3D"	
				]
			]
		]
	]