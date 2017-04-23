REBOL [
	title: "Ticker style example"
	file: %simple-ticker-style.r
	author: "Marco Antoniazzi"
	email: [luce80 AT libero DOT it]
	date: 06-05-2012
	version: 0.0.1
	Purpose: {A quick way to add a simple ticker to VID GUIs}
	comment: {You are strongly encouraged to post an enhanced version of this script}
	History: [
		0.0.1 [06-05-2012 "First version"]
	]
	Category: [util vid view]
	library: [
		level: 'beginner
		platform: 'all
		type: 'how-to
		domain: [gui vid]
		tested-under: [View 2.7.8.3.1]
		support: none
		license: none
		see-also: none
	]
]

ticker-style: stylize [
	ticker: sensor 0x0 rate none feel [
		engage: func [face action event][
			if action = 'time [
				face/data: face/data + face/rate
				do-face face face/data
			]
		]
		] with [
		stopped: false ; start immediatly (unless rate is none)
		data: 0:0:0
		words: [
			start [new/data: second args next args]
			stopped [new/stopped: true args]
		]
		stop: does [rate: none show self]
		set: func [time [time!]] [rate: time show self]
		append init [
			size: 0x0 ; since we are clickable try to avoid it
			if stopped [rate: none]
		]
	]
]
;comment [ ;uncomment this and comment next line to comment example code
do [
	view center-face layout [
		styles ticker-style
		do [sp: 20x20] origin sp space sp
		across
		pad (sp * -1x0) ; erase space created by ticker
		; instead of using the time and 'stopped we could have used: rate none
		ticking: ticker 0:0:1 start 0:0:0 stopped [text-time/text: to-itime value show text-time]
		text-time: text "00:00:00"
		btn "Start" [ticking/set 0:0:1] ; normally this time is equal to the initial one
		btn "Stop" [ticking/stop]
		btn "Reset" [text-time/text: to-itime ticking/data: 0:0:0 show text-time]
	]
]