rebol [
	title: "Blood"
	description: "liquid-based generic RPG-style character-editor"
	note: "will download and save slim.r and liquid.r from rebol.org in the same directory as this script."

	; -- basic rebol header --
	file: 		%blood.r
	version:	0.1.1
	date: 		2009-03-07
	author:		"Maxim Olivier-Adlhoch"
	copyright:	"Copyright (c) 2009 Maxim Olivier-Adlhoch"

	;-- REBOL.ORG header --
	library: [
		level:          'intermediate
		platform:       'all
		type:           [ demo ]
		domain:         [ external-library scientific vid]
		tested-under:   [win view 2.7.5 2.7.6 sdk 2.7.5 2.7.6]
		support:        "http://www.pointillistic.com/open-REBOL/moa/steel/liquid/index.html"
		license:        'MIT
	]


	;-- extended rebol header --
	purpose:	"Usefull example to demo and learn how to use liquid."
	notes:		"Needs STEEL|LIBRARY MANAGER (slim) package and liquid.r to be installed prior to usage."
	license:    {Copyright (c) 2009, Maxim Olivier-Adlhoch

		Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
		and associated documentation files (the "Software"), to deal in the Software without restriction, 
		including without limitation the rights to use, copy, modify, merge, publish, distribute, 
		sublicense, and/or sell copies of the Software, and to permit persons to whom the Software 
		is furnished to do so, subject to the following conditions:
		
		The above copyright notice and this permission notice shall be included in all copies or 
		substantial portions of the Software.}
		
	disclaimer: {THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
		INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR 
		PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE 
		FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ]
		ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
		THE SOFTWARE.}

]

;-------------------------------------
; SLIM LIBRARY DOWNLOADER
;-------------------------------------
unless exists? %slim.r [
	either confirm "Download SLiM Module Manager from rebol.org?" [
		unless data: request-download/to http://www.rebol.org/download-a-script.r?script-name=slim.r clean-path  %slim.r [
			alert "User canceled download or network error, we will now quit."
			quit
		]
	][
		alert "SLiM is required for this application, we will now quit."
		quit
	]
]

do %slim.r
slim/voff
unless slim/open/expose 'liquid 0.7.0 [liquify link content fill !plug attach] [
	either confirm "Download liquid data flow module from rebol.org?" [
		unless data: request-download/to http://www.rebol.org/download-a-script.r?script-name=liquid.r clean-path  %liquid.r [
			alert "User canceled download or network error, we will now quit."
			quit
		]
	][
		alert "liquid data flow module is required for this application, we will now quit."
		quit
	]
]	


;-------------------------------------
; START OF APPLICATION
;-------------------------------------
liquid-lib: slim/open/expose 'liquid 0.7.0 [liquify link content fill !plug attach]


; this tells slim to expose the various vprinting functions within the global space, 
; allowing the application to benefit from the engine very easily.
slim/vexpose


;-----------------
;- LIQUID CLASSES
;-----------------
;- !int-range-srv
; a plug which is used as a server for automated piping management by other plugs.
;
; a pipe server is just another plug, but it acts as a centralised subordinate for any plugs
; sharing a value.  all all attached piped plugs, will synchronise amongst themselves when you fill
; any one of the pipe "clients".
;
; this plug will be created on the fly by the !int-range plug when it creates a pipe server for itself.
; note that any other plug (plug-b) which attaches to a plug (plug-a) which creates a pipe, will also be connected to
; the pipe's (plug-a) server.
;
; this means the order in which you attach piped plugs in important, if you want to properly share a specific
; pipe server.
;-----------------
!int-range-srv: make !plug [
	min-value: 1
	max-value: 10
	prev-value: none
	valve: make valve [
		type: 'int-range
		;-----------------
		;- !purify()
		; this function is used to normalize the liquid stored within a plug, 
		; after any and all processing, containment, filling, etc.
		; it returns a boolean indicating if the purification was able to clean the data
		; properly.
		;
		; in this case we are always able to normalize the value
		;-----------------
		purify: func [
			plug
		][
			vin [{int-range-srv/process()}]
			; brute force way to make sure datatype is valid, and its within bounds
			plug/liquid: plug/prev-value: max plug/min-value min plug/max-value any [
				attempt [
					switch/default type?/word plug/liquid [
						logic! [either plug/liquid [max-value][min-value]]
					][
						to-integer plug/liquid
					]
				]
				plug/prev-value
				0
			]
			vout
			true
		]
	]
]


;- !sum
; add up all number values which are linked to this plug.
!sum: make !plug [
	valve: make valve [
		;-----------------
		;-     process()
		;-----------------
		process: func [
			plug
			data
			/value ; faster than:  /local value
		][
			vin [{!sum/process()}]
			plug/liquid: 0
			foreach value data [
				if number? value [
					plug/liquid: plug/liquid + value
				]
			]
			vout
		]
		
		
	]
]
;- !subtract
; from the first value linked, substract all other links.
; ignores any non number being linked as an error prevention.
!subtract: make !plug [
	valve: make valve [
		;-----------------
		;-     process()
		;-----------------
		process: func [
			plug
			data
			/value ; faster than:  /local value
		][
			vin [{!subtract/process()}]
			plug/liquid: 0 ; an integer by default.
			if 0 < length? data [
				plug/liquid: data/1
				foreach value next data [
					if number? value [
						plug/liquid: plug/liquid - value
					]
				]
			]
			vout
		]
	]
]

;- !int-range
; this is a plug which will always clamp its liquid within a range of two values.
; the pipe-server-class has a default range of 1 to 10, but this can be easily
; changed... see !ability class below to see how to do so.
!int-range: make !plug [
	valve: make valve [
		type: 'int-range
		pipe-server-class: !int-range-srv
	]
]


;- !ability
; preset range of 1 to 25
!ability: make !plug [
	valve: make valve [
		type: 'ability
		pipe-server-class: make !int-range-srv [ min-value: 1 max-value: 25]

	]
]


;- !signal
; this class is simply used to call a function whenever data within the flow changes.
; note that we didn't set this plug to stainless? since our dependencies will
; force us to clean up first, so our callback will always happen before our observers.
;
; if this plug is at the edge of a graph, simply set its stainless? attribute to true if appropriate.
!signal: make !plug [
	;-----------------
	;- callback()
	;-----------------
	callback: func [
		data
	][
		vin [{!signal/callback()}]
		vout
	]
	
	valve: make valve [
		type: 'signal
		;-----------------
		;- purify()
		;-----------------
		purify: func [
			plug
		][
			vin [{!signal/purify()}]
			plug/callback plug/liquid
			vout
			true
		]
	]
]
	


;- !character
!character: make !plug [
	;-----------------
	; instance data
	;-----------------
	;-    abilities
	str: none
	dex: none
	int: none
	
	skills: none
	
	max-points: none
	ability-total: none
	points-left: none
	
	;-----------------
	; class methods and values
	;-----------------
	valve: make valve [
		type: 'character
		
		;-----------------
		;-    setup()
		;-----------------
		setup: func [
			plug
			/local p
		][
			vin [{!character/setup()}]
			; abilities
			plug/str: liquify/fill/piped !ability 12
			plug/dex: liquify/fill/piped !ability 12
			plug/int: liquify/fill/piped !ability 12
			
			; create the ability total sum node
			p: plug/ability-total: liquify !sum
			; link it to our abilities
			link p plug/str
			link p plug/dex
			link p plug/int
			
			; set the max-points range
			plug/max-points: p: liquify/fill/piped !int-range 40
			; the pipe? attribtue is a pointer to the pipe server built internally when the plug became piped
			p/pipe?/min-value: 3
			p/pipe?/max-value: 75

			; create the points-left value, which is simply max-points minus ability totals
			plug/points-left: p: liquify !subtract 
			link p plug/max-points
			link p plug/ability-total
			
			vout
		]
		
	]
	
	
]


;- GUI


;- facets
bg-color: gray

base-font:  make face/font [name: "Trebuchet MS" color: black style: none size: 12 colors: reduce [black black]]
right-font: make base-font [align: 'right]
left-font: make base-font [align: 'left]
error-right-font: make right-font [color: red style: 'bold colors: reduce [red red]]
error-font: make base-font [color: red style: 'bold colors: reduce [red red]]
link-font: make base-font [color: white shadow: 1x1 colors: reduce [white gold]]
link-hi-font: make link-font [color: gold shadow: 1x1]
link-off-font: make link-font [color: gray shadow: none]

black-edge: make face/edge [color: black style: none size: 1x1]
error-edge: make black-edge [color: red]







liquid-lib/voff

;- STYLES
styles: stylize/master  [
	;-     label
	label: text font right-font
	
	;-     link
	link: text font link-font with [
		init: []
		feel: make feel [
			over: func [face state][
				face/font: either state [link-hi-font][link-font]
				show face
			]
			engage: func [ face action event ][
				unfocus
				if action = 'down [
					unfocus
					do-face face face/text
				]
			]
		]
	]
	
	;-     liquid-label
	liquid-label: label with [
		plug: none
		;-----------------------
		; format()
		;
		; note, we can add a function called format and it will be called before refreshing the face text
		; ex:
		;    format: func [data][ rejoin ["label: " data ]]
		;-----------------------

		
		;-----------------
		;-         setup()
		;
		; this creates the plug we use to link to (and thus display) data.
		;
		; it can be run before internal init,
		; otherwise, the init is improved to call setup if not yet called
		;-----------------
		setup: func [
		][
			vin [{liquid-label/init()}]
			
			; will eventually link to the actual data
			;-         plug []
			plug: liquify/with !plug  [
				face: none
				stainless?: true ; this makes the plug always refresh when its liquid changes, forcing it to cleanup.
				
				valve: make valve [
					;-----------------
					;-             Purify()
					;
					; we use this to refresh the text's label and visuals, reusing its string
					;-----------------
					purify: Func [
						plug
						/text ; shortcut to /local text
					][
						vin [{liquid-label/purify()}]
						if plug/face [
							; reuse the string or create one, if face/text is none
							plug/face/text: head any [plug/face/text copy ""]
							clear plug/face/text
							text: any [
								all [in plug/face 'format plug/face/format plug/liquid]
								to-string plug/liquid plug/liquid
							]
							append plug/face/text text
							; we can't call show until the face is properly setup
							if plug/face/parent-face [
								show plug/face
							]
						]
						vout
						true
					]
				]
			]
			plug/face: self
			append init [unless object? plug [setup]]
			vout
		]		
	]

	;-     liquid-field
	liquid-field:  field edge [size: 1x1] [if face/plug [fill face/plug face/text]] with [
		plug: none
		size: 25x25
		
		;-----------------
		;-         setup()
		;
		; this creates the plug we use to attach to another liquid.
		;
		; since we attach the ability within the layout, we call setup just prior there,
		; otherwise, the init is improved to call setup if not yet called
		;-----------------
		setup: func [
		][
			vin [{liquid-field/init()}]
			
			; will eventually attach to the actual ability 
			;-         plug []
			plug: liquify/piped/with !plug  [
				face: none
				stainless?: true ; this makes the plug always refresh, when its pipe changes, forcing it to cleanup.
				
				valve: make valve [
					;-----------------
					;-             Purify()
					;-----------------
					purify: Func [
						plug
					][
						vin [{ability-ctrl/purify()}]
						plug/liquid: to-string plug/liquid
						if plug/face [
							plug/face/text: any [plug/face/text copy ""]
							clear plug/face/text
							append plug/face/text plug/liquid
							show plug/face
						]
						vout
						true
					]
				]
			]
			plug/face: self
			vout
		]
		
		append init [unless object? plug [setup]]
	]	
	
	
	;-     ability-nudge -
	ability-nudge-: link "-" 15x25 [
		; face action
		nudge-increment: content face/ability 
		fill face/ability nudge-increment + face/amount
	] with [ amount: -1 ability: none] 	



	;-     ability-nudge +
	ability-nudge+: ability-nudge- "+" with [
		amount: 1 ; how much does this node nudge the ability
		ability: none ; the ability we will edit (character's plug, not the gui)
		character: none ; the character we are nudging, must be set BEFORE calling setup.
		plug: none ; our overflow detection, which nullifies the button! (link is only active if points-left is above 0)
		
		feel-backup: feel ; when the link is disabled, we store its feel here
		
		;-        setup()
		; here we have a dependency which is based on the character (like the ability in )
		; this means, we must create and set the character BEFORE creating nudges.
		setup: func [][
			plug: liquify/with !plug [
				stainless?: true
				face: none
				current-state: none
				valve: make valve [
					;-----------------
					;-            process()
					; we use this plug only to trigger changes based on DEPENDENCY changes 
					;
					; the nice side-effect is that the effect of our face action, will eventually
					; trickle back to this plug, since this plug is based on the accumulated value
					; of all abilities.
					;-----------------
					process: func [
						plug
						data
						/state
					][
						vin [{ability-nudge+/process()}]
						if 2 = length? data [
							state: (data/2 < data/1)
							if state <> plug/current-state [
								either state [
									plug/face/feel: plug/face/feel-backup
									plug/face/font: link-font
								][
									plug/face/feel: none
									plug/face/font: link-off-font
								]
								plug/current-state: state
								if plug/face/parent-face [
									show plug/face
								]
							]
						]
						vout
					]
				]
			]
			plug/face: self
			link plug character/max-points
			link plug character/ability-total
		]
		append init [unless object? plug [setup]]
		
	] 
	


]

;- INSTANCE DATA
character: char*: liquify !character  ; char* is used to differentiate from the style's internal character attribute

;- declare some words which store gui elements
gui-pnt-left: none


;- HELP WINDOW
help-window: layout[
	area 600x630 para [wrap?: true]{ Welcome to Blood, a liquid-based generic RPG-type character editor.
	
This is a simple application used to demonstrate the fundamentals of the liquid dataflow module.
	
USAGE:
------
All of the character abilities are bound to the value 1 to 25.  There is no way you can cause them to go out of bounds.

By clicking on the little +/- besides them, you can nudge the related ability as long as you follow the rules.  Either the limit of 25 is reached, or you have gone beyond the Maximum number of points allowed for the character.

The + will actually disactivate themselves whenever to break or meet the limits allowed for the abilities.

The fields do allow you to go beyond the max points, this is to allow you freedom in editing the values, knowing that you will lower another ability afterwards.

The total of all abilities is always kept up to date, it will even tell you how much points you have left or by how much you have gone beyond the max points limit.

The Max points is also linked in real time to all the values, so that if you lower or raise it, all the dependencies will automatically reflect the change instantly.

NOTES:
------
The data binding is NOT BUILT WITHIN THE INTERFACE, its the DATA WHICH IS SELF-BOUND, and the interface will always react to the data, since they are linked or piped together. Try typing something other than a number.

VERBOSITY:
---------
You can switch application and liquid verbosity in real-time thanks to the built-in capabilities of the slim library manager, called vprint.  There is also a subset of the featurebase included in a simple 'DOable module on rebol.org, named vprint.r .

NEXT RELEASE:
------------
I will build another version of the tool which adds skills selection and editing.  The skills will be related to the abilities and will reflect any change in ability in real-time.

}

]


;- WINDOW
window:  layout [
	across
	space 1x5
	label "Max points:" 120
	liquid-field 25 with [setup attach plug character/max-points]
	return
	pad 0x30
	label 75 "Strength:"
	ability-nudge- with [ability: character/str]
	liquid-field with [setup attach plug character/str]
	ability-nudge+ with [ability: char*/str character: char* setup]
	return
	label 75 "Intelligence:"
	ability-nudge- with [ability: character/int]
	liquid-field with [setup attach plug character/int]
	ability-nudge+ with [ability: char*/int character: char* setup]
	return
	label 75 "Dexterity:"
	ability-nudge- with [ability: character/dex]
	liquid-field with [setup attach plug character/dex]
	ability-nudge+ with [ability: char*/dex character: char* setup]
	return
	box 120x1 black black
	return
	label 75 "Total:"
	pad 17x0
	liquid-label 25 black white edge black-edge  with  [
		feel: none 
		setup 
		link plug character/ability-total
		face*: self
		
		; we'll just add a little alert which tells us that we have gone beyond the bounds of max-points.
		alert: liquify/with !signal [
			stainless?: true
			last-value: none
			;-----------------
			;-     callback()
			;-----------------
			callback: func [
				data
			][
				vin [{callback()}]
				vprint ["points left: " data]
				data: (data < 0)
				if data <> last-value [
					either data [
						face*/edge: error-edge
						face*/font: error-font
						; could also do this within gui-pnt-left directly,
						; but just included this here to show how flexible it all can be
						; built up.  this node being a global alert is a logical place to
						; handle any alert-type side-effects of going beyond the max-points limit.
						if gui-pnt-left[gui-pnt-left/font: error-font]
					][
						face*/edge: black-edge
						face*/font: base-font
						if gui-pnt-left [gui-pnt-left/font: left-font]
					]
					if face*/parent-face [
						show face*
					]
					if all [
						gui-pnt-left
						gui-pnt-left/parent-face
					][
						show gui-pnt-left
					]
					last-value: data
				]
				vout
			]
		]
		link alert character/points-left
		
	]
	gui-pnt-left: liquid-label 80 font [align: 'left] with [
		format: func [data][
			case [
				data < 0 [
					rejoin ["(Over by " data * -1 ")"]
				]
				data > 0 [
					rejoin ["(" data " Left)"]
				]
				
				data = 0 ["(All spent)"]
				
			]
		]
		setup
		link plug character/points-left
	]
	return
	
	pad 0x30
	label "verbosity: "
	return
	check off [ either value [print "app code verbosity enabled..." von][print "app code verbosity disabled..." voff]]
	label "app code"
	return
	check off [either value [print "liquid module verbosity enabled..." liquid-lib/von][print "liquid module verbosity disabled..." liquid-lib/voff]]
	label "liquid internals"
	

	return
	pad 0x30
	btn "help" [view/new help-window]
	
	pad 100
	btn "quit" [quit]
] 


view/offset window 50x50 


