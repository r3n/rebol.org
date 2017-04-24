REBOL [
	file: %wizard.r
	date: 17-Feb-2004
	title: "Wizard"
	author: "Ammon Johnson"
	email: ammon@addept.ws
	purpose: "A simple Wizard VID style"
	version: 0.0.3
	history: {
		0.0.3 "Added the ability to use a predefined layout for a step" "Ammon Johnson"
	}
	library: [
		level: 'advanced
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
	wizard: face with [
		current-step: steps: next-step: prev-step: none
		size: none
		type: 'Wizard
		action: does [quit]
		words: [
			steps [new/steps: first next args next args]
		]
		resize: func [new [pair!] /window] [
			self/size: new
			if window [parent-face/size: new + (self/offset * 2) show parent-face]
			pane/1/size: new - 0x30
			pane/4/offset: new - pane/4/size - 15x5
			pane/3/offset: new - (as-pair pane/3/size/x * 2 pane/3/size/y) - 25x5
			pane/2/offset: new - (as-pair pane/2/size/x * 3 pane/2/size/y) - 15x5
			show self
		]
		init: [
			next-step: does [
				if current-step = (length? steps) [
					do steps/:current-step/2
				]
				if current-step < (length? steps) [
					do steps/:current-step/2
					current-step: current-step + 1
					pane/1/pane: steps/:current-step/1
					if  current-step = (length? steps) [
						pane/3/text: "Finish"
					]
					show self
				]
			]
			prev-step: does [
				if current-step > 1 [
					pane/3/text: "Next >"
					current-step: current-step - 1
					do steps/:current-step/3
					pane/1/pane: steps/:current-step/1
					show self
				]
			]
			pane: reduce [
				make face []
				make-face/spec 'button [size: 75x20 text: "< Prev" action: [prev-step]]
				make-face/spec 'button [size: 75x20 text: "Next >" action: [next-step]]
				make-face/spec 'button [size: 75x20 text: "Cancel"]
			]
			if steps [
				use [max-size] [
					max-size: any [size 0x0]
					for i 1 (length? steps) 1 [
						either object? try [get/any steps/:i/1/1] [
							steps/:i/1: do steps/:i/1
							steps/:i/1/offset: 0x0
							max-size: max max-size steps/:i/1/size
						][
							steps/:i/1: layout/offset steps/:i/1 0x0
							max-size: max max-size steps/:i/1/size
						]
					]
					current-step: 1
					pane/1/pane: steps/1/1
					if not size [size: max-size + 0x30]
				]
			]
			pane/4/action: :action
			resize size
		]
	]
]

comment { ;Uncomment this section for an example...
step1: layout [
	across
	Code "Welcome to the first step!"
	return
	text 400 {If you don't supply a size for your wizard then it will
		auto-size itself to the size of the largest layout in steps.
		Clicking the 'Next' button executes the Validation Code.
		To stop the wizard from progressing to the next step
	if the requirements for this step are not met, simply use 'exit.
	For example, if you don't check the box below you will not be able
	to progress to the next step. The validation Code block is below...}
	return
	ck: check text "Ok to continue." [ck/data: either ck/data[false][true] show ck]
	return
	code {if not ck/data [exit]}
]
view c: center-face layout [
	origin 0x0
	w: wizard steps [
		[ ;Begin First Step
			[ ;Begin First Step Layout
				step1
			] ;End First Step Layout
			[ ;Begin First Step Validation Code
				if not ck/data [exit]
			] ;End First Step Validation Code
			[ ;Begin First Step Reload Code
				ck/state: false
			] ;End First Step Reload Code
		] ;End First Step
		[ ;Begin Second Step
			[ ;Begin Second Step Layout
				code "This is the second step."
				text 400 "Since the Validation Code is an empty block, clicking 'Next' will simply load the next page."
			][ ;Begin Second Step Validation Code
			] ;End Second Step Validation Code
			[ ;Begin Second Step Reload Code
			] ;End Second Step Reload Code
		] ;End Second Step
		[ ;Begin Third Step
			[ ;Begin Third Step Layout
				code "Last step" text 400 "Notice that the Next button's text automatically changed to 'Finish' because this is the last page. The cancel button simply DOES the wizard's action block.  The default action block is [quit]." code "I hope you enjoy using this style!"
			] ;End Third Step Layout
			[ ; Begin Third Step Validation Code
				request/ok "You have successfully completed the Wizard Tutorial" quit
			] ;End Third Step Validation Code
			[ ;Begin Third Step Reload Code
			] ;End Third Step Reload Code
		] ;End Third Step.  To add more steps simply follow the pattern
	]
]
halt
}