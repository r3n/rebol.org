rebol [
    file: %vid-tutorial-async-event-loops.r
    title: "async event loop tutorial"
    author: Maxim Olivier-Adlhoch
    purpose: {Show how to do async event handling with processing loops.}
    date: 2012-11-09
]

processing-active?: false
slice: 0.01 ; change this to change default speed.

cycle-colors: func [][
	processing-active?: true ; set this to false to tell loop to break
	
	direction: 'down
	color: random white
	percent: 1 ; always start with full color
	
	forever [
		switch direction  [
			up [
				percent: percent + slice
				if percent >= 1 [direction: 'down]
			]
			down [
				percent: percent - slice
				if percent <= 0.5 [direction: 'up]
			]
		]
		clr-bx/color: color * percent
		show clr-bx
		unless processing-active? [
			break none
		]
		wait 0.01 ; adding a small delay in the wait slows down 
				  ; processing enough that it should
		          ; bring back cpu usage to marginal values.
		
		;------
		; the following is ESSENTIAL, otherwise, rebol remains alive, 
		; and loops as background task with no GUI.
		if empty? system/view/screen-face/pane [quit]
	]
]


view/new layout [
	across
	clr-bx: box
	return
	pad 20x0
	btn "start" [processing-active?: false wait 0  cycle-colors]
	btn "stop"  [processing-active?: false]
	at 120x20
	scroller 20x100	[
		slice: 0.001 + (value * 0.05)
	]
]


random/seed 3
cycle-colors

do-events
quit

