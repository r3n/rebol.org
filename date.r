REBOL [
	file: %date.r
	date: 18-Feb-2004
	title: "Date Selector"
	author: "Ammon Johnson"
	email: ammon@addept.ws
	purpose: "A simple date selector VID style"
	library: [
		level: 'intermediate
		platform: 'all
		type: ['tool 'demo]
		domain: ['gui 'ui 'user-interface 'vid]
		tested-under: 'winxp
		support: {email me with questions}
		license: none
		comment: {Free to use as-is, acknowledgement is appreciated.
				  Please inform me of any enhancements you make.
				  Provided with NO WARRANTY.}
	]
]

stylize/master [
	date: face with [
		type: 'date
		get-date: has [date] [
			if date: request-date [pane/1/text: date show pane/1]
		]
		size: 100x20
		words: [
			default [new/text: first next args next args]
		]
		resize: func [new] [
			pane/1/size: new - 20x0
			pane/2/offset: as-pair pane/1/size/x 0
		]
		init: [
			pane: reduce [
				make-face/spec 'field [text edge: make edge [size 1x1]]
				make-face/spec 'arrow [data: 'down action: [get-date] edge: make edge [size: 1x1]]
			]
			resize size
			pane/1/text: text
		]
		;flags: [field tabbed]
	]
]

comment {;Uncomment this for an example
view center-face layout [
	date default now/date
	field
]
}