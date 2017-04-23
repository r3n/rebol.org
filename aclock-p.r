rebol[
	date: 19-sept-2004
	file: %aclock-p.r
	Title: "pluginable analog alarm clock"
	Author: "Tom Conlin"
	Purpose: "aproximate an analog clock and add alarm"
	library: [ 
		platform: [ all plugin ] 
		plugin: [size: 160x160 version: {http://www.rebol.com/plugin/rebolb4.cab#Version=0,5,0,0} ]
		tested-under: [windows firefox]
		see-also: "request-time.r"
		type: [demo tool]
		Level: 'intermediate
		Domain: [gui sound]
		Tested-under: [windows firefox ]
		support: ["ask" ]
		License: pd
	]
]

do http://www.rebol.org/cgi-bin/cgiwrap/rebol/download-a-script.r?script-name=request-time.r
ring: load ring-url: http://www.cs.uoregon.edu/~tomc/Buzzer_2.wav

;;; Globals
RADIUS: 80x80    ; a pair for ovals
ALARM:  24:00:00 ; a time not reachable -- so is off
MAIN-CLOCK-FACE:  make block! 180
SIN:              make block! 61
COS:              make block! 61

for i 6 360 6[
	insert tail SIN reduce [sine i]
	insert tail COS reduce [negate cosine i]
]

;;; set the "once per resize" elements
draw-face: func[rad [pair!] 
	/local clock-face  ;;; big-hand-end lil-hand-end sec-hand-end tic
][
	;system/script/title: to-string now/date ;;; try to change title each day
	clock-face:   make block! 180	
	big: make block! 64
	lil: make block! 64
	sec: make block! 64
	edg: make block! 64
	big-hand: RADIUS * .95
	lil-hand: RADIUS * .66
	tic:      RADIUS - 3x3
	for i 1 60 1[
		insert tail big RADIUS + to pair! reduce[to integer! ((big-hand/1) * SIN/:i) to integer! ((big-hand/2) * COS/:i)]
		insert tail lil RADIUS + to pair! reduce[to integer! ((lil-hand/1) * SIN/:i) to integer! ((lil-hand/2) * COS/:i)]
		insert tail sec RADIUS + to pair! reduce[to integer! ((tic/1     ) * SIN/:i) to integer! ((tic/2     ) * COS/:i)]
		insert tail edg RADIUS + to pair! reduce[to integer! ((radius/1  ) * SIN/:i) to integer! ((radius/2  ) * COS/:i)]
		either zero? i // 5 
			[insert tail clock-face compose[circle (sec/:i) 2 ]]; hour marks 
			[insert tail clock-face compose[line   (sec/:i) (edg/:i)]]; minute marks
	]
	clock-face
]

main-clock-face: draw-face RADIUS

;;; return a block of DRAW to display the hands
tock: func[t [time! none!] rad [pair!] /local result h m s][
	result: compose [pen black fill-pen black]
	if not t [t: now/time]
	s: either zero? t/3 [60][t/3]
	m: either zero? t/2 [60][t/2]
	h: add multiply t/1 // 12 5 to integer! divide t/2 12.0
	h: either zero? h [60][h]
	either equal? rad RADIUS
		[insert tail result main-clock-face]
		[insert tail result copy draw-face rad]
	insert tail result compose[  ; hands
		pen red    line (RADIUS) (lil/:h)
		pen blue   line (RADIUS) (big/:m)
		pen yellow line (RADIUS) (sec/:s)
	]
	result
]

;;; user select sounds, images...
request-url: func [u [url!] /local ][
	request u
]
aclock: [
    origin 0x0
    clk: box silver RADIUS * 2
    rate 0:0:01
    feel[
        engage: func [face action event] [
            face/effect: reduce ['draw tock none RADIUS show clk]
            if action = 'down [ALARM: request-time ALARM]
            if action = 'alt-down [ring: load ring-url: request-url ring-url]
            if all[ greater? now/time ALARM  lesser? now/time add ALARM 0:0:02][ 
               wait 0
               bell: open sound://
               insert bell ring
               wait bell
               wait .1
               close bell
               ;alert rejoin ["DING!" " " ALARM]
            ]; end alarm check
        ]
    ]
]

insert-event-func [
    switch event/type [    
        resize [
            clk/size: face/pane/1/size 
            RADIUS: clk/size / 2
            main-clock-face: draw-face RADIUS
            show clk 
        ]
    ]
    event
]

view/options layout aclock[resize no-border]
