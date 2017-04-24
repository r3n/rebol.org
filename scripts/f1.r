Rebol [title: "F1 demo"
	Date: 23-11-2012	
	File: %f1.r 
	Version: 1.0.0 
	Author: "Massimiliano Vessi" 
	Purpose: "Simple car game, just t show how to scroll images"
	Library: [ 
		level: 'beginner 
		platform: 'all 
		type: [game demo] 
		domain: [animation game graphics gui vid visualization] 
		tested-under: [winxp linux] 
		support: none 
		license: gpl
		see-also: none 
		]
]


car: [translate 180x0 
	pen off
	fill-pen crimson
	box 10x10  40x20
	fill-pen red
	polygon 20x20 30x20 30x60 25x70 20x60
	fill-pen crimson
	box 15x62 35x67
	fill-pen black
	box 5x25 15x35
	box 35x25 45x35	
	box 5x50 15x60
	box 35x50 45x60
	pen black
	line 15x30 20x30
	line 35x30 30x30
	line 15x55 20x55
	line 35x55 30x55
	pen crimson
	fill-pen none
	circle 25x35 4 7
	pen off
	fill-pen blue
	circle 25x32 3
	]

s: 10 ;car speed of translating

move-s: func [ b] [
	if b = #"a" [ car/2/x:    car/2/x - s ] 
	if b = #"d" [ car/2/x:   car/2/x + s ]   
	if b = #"s" [car/2/y:   car/2/y + s ] 
	if b = #"w" [car/2/y:  car/2/y - s ] 		
	repeat i 2 [
		if car/2/:i < 0 [car/2/:i: 0 ] 
		if car/2/:i > 350 [car/2/:i: 350 ] 
		]
	show aa
	]


out:  []
st: false

percorso1: [ pen off 
		fill-pen green box -150x0 90x10
                      fill-pen red box 90x0 95x10
		  fill-pen gray box 95x0 305x10
		  fill-pen red box 305x0 310x10
		  fill-pen green box 310x0 600x10
		  ]
percorso2: [  pen off 
		fill-pen green box -150x0 90x10
                      fill-pen white box 90x0 95x10
		  fill-pen gray box 95x0 305x10
		  fill-pen white box 305x0 310x10
		  fill-pen green box 310x0 600x10
		  ]		  

;counters
contatore: a: b:  contatore2: 0
;track, V = victroy, S = straight, L= turn left, R = turn right
;you can edit this track:
gara1: "vsssssrrrrrrssssssssllllllllllllllrrrrrrrsllsllsrrrrrrsssrrrlllsssrrllrrllrrllsv"

; this keep all track variations
list-b: copy []

;this move the background (TRACK)
sfondo: func [gara ][		
		loop 2 [remove out] ;this remove the first translation, then we put the new corret one translation
		;if we ended the track, the track become straigth
		if  (length? gara) <= 0 [ 
			gara:  copy "s"  
			bb/text: reform [ "Your time is" time/text]  
			bb/font/color: white  
			time/feel: none ;this stop the timer
			]
		;this take actual track letter	
		g: first gara
		;this translate all of one line down (10px)
		insert out [translate 0x10]
		;this select what to do to the track
		switch g [
			#"s" [ a: 0 ]
			#"r"  [a:  1  ]
			#"l" [a:  -1]				
			]	
		b: b + a ;this is the absolute translation to insert at the beggining, this make game more fun
		++ contatore
		++ contatore2
		;every 15 lines we move to the next part of the track
		if contatore2 > 15 [contatore2: 0   remove gara  ]							
		;V is to draw black lines	
		if g = #"v" [contatore2: contatore2 + 2 
			insert out [fill-pen black box 95x0 305x10 ] 
			]
		;this alternate strips red and white
		if contatore > 3 [ 
			contatore: 0
			either st [ st: false] [st: true]
			]
		either st [insert out percorso1 ] [insert out percorso2]
		;this is necessary for relative translation between lines	
		insert out reduce ['translate as-pair a 0]	
		;this insert the starting absolute translation
		insert out reduce ['translate as-pair b 0]
		insert list-b a ;list-b contains all relative translation		
		clear skip list-b 36 ;this short list-b to the first 36 elements
		;this is used to calculate the position of the last background line, so we can know if car is inside the track
		c: b
		foreach item list-b [ c: c + item]		
		;this short out to the first 1616 elements
		clear skip out 1616		
	out 	
	]
	
;let's create the first background (just 40 lines of stripes)
loop 40 [sfondo gara1]

view layout [
	at 0x0 
	bb: box black 400x400  rate 0 feel [engage: func [f a e][
		f/effect: reduce [ 'draw sfondo gara1] 
		f/rate: f/rate + 1 ;speed automatically increase
		if f/rate > 100 [f/rate: 100] ;maximum speed is 100
		speed/text: to-string f/rate		
		;this checks if car is inside track and reduces speed
		either  any [  ;condition
				car/2/x <  (95 + c)
				car/2/x >  (260 + c)
				] [  ;if true
					f/rate: f/rate - 7   if bb/rate < 0 [bb/rate: 1 ]   
					f/text: "BACK ON TRACK"
					f/font/color: red
					] [ 	if f/text =  "BACK ON TRACK"  [f/text: none] ]		
		show [f speed] 
		]] 
	at 0x0 
	aa: box 400x400 effect [
		draw car
		flip 0x1
		] 
	key keycode [#"a" left] [ move-s #"a"    bb/rate: bb/rate - 2  if bb/rate < 0 [bb/rate: 1 ]]		
	key keycode [#"d" right ] [ move-s #"d"  bb/rate: bb/rate - 2 if bb/rate < 0 [bb/rate: 1 ] ]		
	panel [
		label "Speed:"
		label "Time"
		return 
		speed: text "0000"
		time: text "00:00:00" rate 1 feel [
			engage: func [f a e][  f/text: (to-time f/text) + 1    show f ]
			]
		return	
		text italic 250 {Try to do your best time: if you go out of the track, you slow; 
			if you move the car, you slow. You may use keyboard arrows or A and D to move the car.}
		]
	]