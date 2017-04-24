REBOL [
	file: %group.r
	date: 18-Feb-2004
	title: "VID Group"
	author: "Ammon Johnson"
	email: ammon@addept.ws
	purpose: "A simple group VID style with enable/disable capability"
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
	group: face with [
		state: True
		size: 200x100
		color: none
		edge: make edge [size: 1x1 effect: 'ibevel]
		words: [
			pane [new/data: first next args next args]
		]
		init: [
			either data [
				data: layout/origin data 5x5
				size: data/size
				pane: get in data 'pane
			][pane: []]
			;insert pane reduce [make face []]
			;pane/1/size: size
		]
		disable: has [img sz] [
			img: to image! self
			;sz: size
			append pane reduce [
				make face [
					offset: -2x-2
					type: 'disable
					color: none
					effect: [merge multiply 100.100.100]
				]
			]
			edge: make edge [color: 128.128.128]
			set in (last pane) 'size size + 3x3
			state: false
			show self
		]
		enable: does [
			if (get in (last pane) 'type) = 'disable [
				remove skip tail pane -1
			]
			edge: make edge [color: 200.200.200]
			state: true
			show self
		]
	]
]

comment {;Uncomment for example
view layout [
	g: group pane [button "test" [request/ok "Testing..."]]
	button "disabled" [either g/state [g/disable face/text: "Disabled" show face][g/enable face/text: "Enabled" show face]]
]
}