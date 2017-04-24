REBOL [
	Title: "FIREBOLEK"
	Date: 2-8-2005
	Version: 1.0.1
	History: [
		2-8-2005 1.0.1 "Fixed for newer View versions, contact informations updated"
		27-10-2001 1.0.0 "Initial version"
	]
	File: %fire.r
	Author: "Rebolek"
	Purpose: "Well-known fire-demo for your pleasure"
	Email: %rebolek--gmail--com
	Web: http://krutek.info
	library: [
		level: 'intermediate 
		platform: 'all
		type: [demo tutorial]
		domain: [animation gui graphics vid] 
		tested-under: [view 1.3.1 on "WinXP"]
		support: none 
		license: 'public-domain
		see-also: none
	]	
]
view layout [
	box 150x150 with [
		edge: none
		img: image: make image! 150x150
		pos: 0x0
		rate: 20
		text: "FIREBOLEK"
		font: make font [size: 24 color: 255.125.0]
		basic: [draw [image pos img]]
		effects: reduce [
			append copy basic [blur luma -10]
			append copy basic [sharpen luma -10 blur]
			append copy basic [contrast 10 blur luma -5]
		]
		effect: first effects
		feel: make feel [
			engage: func [f a e][
			 pos: make pair! reduce [(random 3)  - 2 -1]
				switch a [
					down [f/effects: next f/effects if tail? f/effects [f/effects: head f/effects] f/effect: first f/effects show f]
					time [show f repeat i f/size/x - 4 [poke f/image (f/size/x * f/size/y) - i - 2 (random 255.0.0 + random 0.127.0) * 3] f/img: to-image f]
				]
			]
		]
	]
	text 150 {classical fire demo for REBOL^/
press on fire to see other effects.^/   
Written by ReBolek, 2001 in 15 mins.^/
We need new category on Assembly:^/
less-than-kb-demo ;-)} with [font: make font  [size: 9]]
]