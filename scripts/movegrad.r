#! /usr/bin/rebol
rebol [
        File: %movegrad.r
        Date: 05-Feb-2011
	Title: "Moving Gradients"
	Author: "François Jouen"
	Version: 1.0
	Needs: [view 1.3.2]
	Rights: {}
        Purpose: {Graphical Animations with Gradients}
        library: [
        level: 'intermediate
        platform: 'all
        type: [graphic]
        domain: [gui]
        tested-under: all plateforms
        support: none
        license: 'BSD
        see-also: none
        ]
]

_grad-offset: 0x0 ; this allows directional motion 
_grad-start-rng: 90.0 ; to create lines
_grad-stop-rng: 180.0 ;to create lines
_grad-angle: 0 ; 0 for horizontal motion and 90 for vertical motion
_grad-scale-x: 1 ; allows modifying frequency in x range
_grad-scale-y: 1 ; allows modifying frequency in y range
_grad-color-1: silver ; this can be modified for playing with colors
_grad-color-2: snow ; this can be modified for playing with colors
_grad-color-3: silver ; this can be modified for playing with colors


velocity: 1
mov: false
direction: "right"
ssize: 800x600; tested up 1600x1200

; for repeated linear gradient
grad: [
	fill-pen linear '_grad-offset 
	repeat '_grad-start-rng '_grad-stop-rng '_grad-angle '_grad-scale-x '_grad-scale-y 
	'_grad-color-1
	'_grad-color-2
	'_grad-color-3
	box 
]


; controls stimulus motion direction
motion: func [to-where] [
	while [mov] [
	     switch to-where [
	   		"right"	[ _grad-offset/x: _grad-offset/x + velocity]
	   		"left"	[ _grad-offset/x: _grad-offset/x - velocity]
	   		"up"    [_grad-offset/y: _grad-offset/y - velocity]
	   		"down"  [_grad-offset/y: _grad-offset/y + velocity]
	    ]
		wait 0; for keyboard events
		show stimulus 
 	]
]


MainWin: layout [
	across
	stimulus: box ssize effect [draw grad]
	return 
	text "Direction"
	arrow 24x24 effect [fit arrow 0.0.0 0.7 rotate 270 ]  [_grad-angle: 0 direction: "left" show stimulus]
	arrow 24x24 effect [fit arrow 0.0.0 0.7 rotate 0] [_grad-angle: 90 direction: "up" show stimulus]
	arrow 24x24 effect [fit arrow 0.0.0 0.7 rotate 180] [_grad-angle: 90 direction: "down" show stimulus]
	arrow 24x24 effect [fit arrow 0.0.0 0.7 rotate 90] [_grad-angle: 0 direction: "right" show stimulus]
	text "Velocity"
	sl: slider 200x24 [velocity: sl/data * 9 + 1 vit/text: round/to velocity 0.01 show vit ]
	vit: info 50  "1"
	btn "Start" [mov: true motion direction ]
	btn "Stop" [mov: false ]
	btn "Zero" [_grad-offset: 0x0 show stimulus]
	btn "Quit" [Quit]
]


view/new center-face MainWin 

insert-event-func [
	if (event/type = 'close)  and (event/face = MainWin) [quit]
	[event]
]
do-events