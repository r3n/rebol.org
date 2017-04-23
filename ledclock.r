REBOL [

  title: "Led Clock"
    Date: 11-Oct-2010
    Version: 1.0
    Author: "François Jouen"

    File: %ledclock.r

    Purpose: { A simple demo with leds}

    library: [
        level: 'intermediate
        platform: 'all
        type: [tool demo] 
        domain: [gui]   
        tested-under: 'win 'Mac OSX 
        support: none 
        license: 'pd 
    ]   
]



pix: [
    0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0
	0 0 0 0 0 0 0 0 0 0
]

pix0: [
    0 0 0 0 0 0 0 0 0 0
    0 1 1 1 1 1 1 1 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 1 1 1 1 1 1 1 0
	0 0 0 0 0 0 0 0 0 0
]

pix1: [
    0 0 0 0 0 0 0 0 0 0
    0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 0 0
]

pix2: [
    0 0 0 0 0 0 0 0 0 0
    0 1 1 1 1 1 1 1 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 1 1 1 1 1 1 1	1 0
	0 1 0 0 0 0 0 0 0 0
	0 1 0 0 0 0 0 0 0 0
	0 1 0 0 0 0 0 0 0 0
	0 1 0 0 0 0 0 0 0 0
	0 1 0 0 0 0 0 0 0 0
	0 1 0 0 0 0 0 0 0 0
	0 1 0 0 0 0 0 0 0 0
	0 1 1 1 1 1 1 1 1 0
	0 0 0 0 0 0 0 0 0 0
]

pix3: [
    0 0 0 0 0 0 0 0 0 0
    0 1 1 1 1 1 1 1 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 1 1 1 1 1 1 1	1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 1 1 1 1 1 1 1 1 0
	0 0 0 0 0 0 0 0 0 0
]

pix4: [
    0 0 0 0 0 0 0 0 0 0
    0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 1 1 1 1 1 1	1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 0 0
]

pix5: [
    0 0 0 0 0 0 0 0 0 0
    0 1 1 1 1 1 1 1 1 0
	0 1 0 0 0 0 0 0 0 0
	0 1 0 0 0 0 0 0 0 0
	0 1 0 0 0 0 0 0 0 0
	0 1 0 0 0 0 0 0 0 0
	0 1 0 0 0 0 0 0 0 0
	0 1 0 0 0 0 0 0 0 0
	0 1 0 0 0 0 0 0 0 0
	0 1 1 1 1 1 1 1	1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 1 1 1 1 1 1 1	1 0
	0 0 0 0 0 0 0 0 0 0
]
pix6: [
    0 0 0 0 0 0 0 0 0 0
    0 1 1 1 1 1 1 1 1 0
	0 1 0 0 0 0 0 0 0 0
	0 1 0 0 0 0 0 0 0 0
	0 1 0 0 0 0 0 0 0 0
	0 1 0 0 0 0 0 0 0 0
	0 1 0 0 0 0 0 0 0 0
	0 1 0 0 0 0 0 0 0 0
	0 1 0 0 0 0 0 0 0 0
	0 1 1 1 1 1 1 1	1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 1 1 1 1 1 1 1 0
	0 0 0 0 0 0 0 0 0 0
]

pix7: [
    0 0 0 0 0 0 0 0 0 0
    0 1 1 1 1 1 1 1 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0	1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 0 0
]

pix8: [
    0 0 0 0 0 0 0 0 0 0
    0 1 1 1 1 1 1 1 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 1 1 1 1 1 1	1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 1 1 1 1 1 1 1 0
	0 0 0 0 0 0 0 0 0 0
]

pix9: [
    0 0 0 0 0 0 0 0 0 0
    0 1 1 1 1 1 1 1 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 0 0 0 0 0 0 1 0
	0 1 1 1 1 1 1 1	1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 0 0 0 0 0 0 0 1 0
	0 1 1 1 1 1 1 1 1 0
	0 0 0 0 0 0 0 0 0 0
]

color: 0.0.0
color2:  0.0.255
plot: copy [] 
plot1: copy []
plot2: copy []
plot3: copy []
plot4: copy []
plot5: copy []
plot6: copy []


lasth: lastm: 0

update_led: func [p plot]
[  
	repeat y 19 
		[ repeat x 10 [
	    	col: pick p (y * 10) - 10 + x 
	    	either col = 0 [color: 0.255.0] [color: 255.0.0] 
			append plot compose [ pen none
			;fill-pen (color) box (xy: 10 * as-pair x - 1 y - 1) (xy + 10)
			fill-pen (color) circle (xy: 10 * as-pair x y ) (4)
			] 
		]
	]
]


get_time: does [
   ;what time is it?
    tmp: now/time
 	h: first tmp 
 	; hour is changed? if yes update and refresh. if no go to minutes
 	if h <> lasth [
 		if h < 10 [ hh: 0 hhh: h]
 		if h >= 10 [
 	           str: to-string h
 	           hh: to-integer to-string first str
 	           hhh: to-integer to-string second str]
 	
 		switch hh [ 0 [update_led pix0 plot1]
	            1 [update_led pix1 plot1]
	            2 [update_led pix2 plot1]
		]
		switch hhh [0 [update_led pix0 plot2]
	            1 [update_led pix1 plot2]
	            2 [update_led pix2 plot2]
	            3 [update_led pix3 plot2]
	            4 [update_led pix4 plot2]
	            5 [update_led pix5 plot2]
	            6 [update_led pix6 plot2]
	            7 [update_led pix7 plot2]
	            8 [update_led pix8 plot2]
	            9 [update_led pix9 plot2]
		]
	
	
		b1/effect: reduce ['draw plot1]
 		b2/effect: reduce ['draw plot2]
 		show [b1 b2]
	]
 	;minutes are changed? same story  : if not go to sec      
 	m: second tmp
 	if m <> lastm [
 		if m < 10 [mm: 0 mmm: m]
 		if m >= 10 [
 	           str: to-string m
 	           mm: to-integer to-string first str
 	           mmm: to-integer to-string second str]
 		switch mm [ 0 [update_led pix0 plot3]
	            1 [update_led pix1 plot3]
	            2 [update_led pix2 plot3]
	            3 [update_led pix3 plot3]
	            4 [update_led pix4 plot3]
	            5 [update_led pix5 plot3]           
		]
		switch mmm [0 [update_led pix0 plot4]
	            1 [update_led pix1 plot4]
	            2 [update_led pix2 plot4]
	            3 [update_led pix3 plot4]
	            4 [update_led pix4 plot4]
	            5 [update_led pix5 plot4]
	            6 [update_led pix6 plot4]
	            7 [update_led pix7 plot4]
	            8 [update_led pix8 plot4]
	            9 [update_led pix9 plot4]
		]
		
	    b3/effect: reduce ['draw plot3]
	    b4/effect: reduce ['draw plot4]
	    show [b3 b4]
	   
	]
    ; process sec 
 	if error? try [s: third tmp] [s: 0] 
 	if s < 10 [ss: 0 sss: s]
 	if s >= 10 [
 	           str: to-string s
 	           ss: to-integer to-string first str
 	           sss: to-integer to-string second str]

	
	switch ss [ 0 [update_led pix0 plot5]
	            1 [update_led pix1 plot5]
	            2 [update_led pix2 plot5]
	            3 [update_led pix3 plot5]
	            4 [update_led pix4 plot5]
	            5 [update_led pix5 plot5]           
	]
	switch sss [ 0 [update_led pix0 plot6]
	            1 [update_led pix1 plot6]
	            2 [update_led pix2 plot6]
	            3 [update_led pix3 plot6]
	            4 [update_led pix4 plot6]
	            5 [update_led pix5 plot6]
	            6 [update_led pix6 plot6]
	            7 [update_led pix7 plot6]
	            8 [update_led pix8 plot6]
	            9 [update_led pix9 plot6]
	]
	
	b6/effect: reduce ['draw plot6]
	b5/effect: reduce ['draw plot5]
	show [b5 b6]
	; last measure
	lasth: h
	lastm: m
]

;everything to 0
reset: does [
	update_led pix0 plot1
	update_led pix0 plot2
	update_led pix0 plot3
	update_led pix0 plot4
	update_led pix0 plot5
	update_led pix0 plot6
	b1/effect: reduce ['draw plot1]
	b2/effect: reduce ['draw plot2]
	b3/effect: reduce ['draw plot3]
	b4/effect: reduce ['draw plot4]
	b5/effect: reduce ['draw plot5]
	b6/effect: reduce ['draw plot6]
	show [b1 b2 b3 b4 b5 b6]
]

; simple window
view center-face layout/size [ across
              backdrop color2
              origin 0x0
              space 0x0
              at 5x5
              	b1: box color2 115x205 effect reduce ['draw plot1] 
              	b2: box color2 115x205 effect reduce ['draw plot2] 
              	; this small box for timing
              at 230x180
              	bb: box 10x10 red with [rate: none]
	              feel [engage: func [face action event]
	              [switch action [time [get_time]]
                 ]
                ]  
              at 240x5 
              	b3: box color2 115x205 effect reduce ['draw plot3] 
              	b4: box color2 115x205 effect reduce ['draw plot4] 
              at 465x180 box 10x10 red
              at 475x5
              	b5: box color2 115x205 effect reduce ['draw plot5] 
              	b6: box color2 115x205 effect reduce  ['draw plot6] 
              at 145x220 btn 100 "Start" [lasth: lastm: 0 bb/rate: 1 show bb] 
              	pad 5 btn 100 "Stop" [bb/rate: none show bb] 
              	pad 5 btn 100 "Reset" [bb/rate: none show bb reset]
              	pad 5 btn 100 "Quit" [quit]
              do [reset] 
] 705x250

 
