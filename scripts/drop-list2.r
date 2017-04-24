rebol [
	title: "drop-list2 widget for REBGUI"
	author: "Robert Paluch 2009"
	nick: "bobik"
	email: "robert.paluch@seznam.cz"
	version: 0.1.0
        date: 9-aug-2009
        file: %drop-list2.r
	Purpose: {
	 Extension of original drop-list widget.
	 Widget receives data as pairs [value1 text1 value2 text2 ...]
	 Widget has extension of function PICKED with options /values returning block of selected row(pair)
	}
	Note: "Totally based on Ashley's widget drop-list :-)"
        Need: "rebgui"
]

do %rebgui.r

append-widget [
drop-list2: make rebface [
	tip:	{
		USAGE:
			drop-list2 "a" data [1 "a" 22 "b" 333 "c"]
			drop-list2  data [1 "a" 22 "b" 333 "c"]
			drop-list2 data (SQL "select id,name from names")

		DESCRIPTION:
			Single column selection list with hidden values list.
			Values in 'data' are structured as pairs [value1 text1 value2 text2 ....]
			To get current choice use function PICKED with option /values
	}
	indexes: copy []
	size:	25x5
	text:	""
	color:	CTX-REBGUI/colors/outline-light
	data:	[]
	edge:	outline-edge
	font:	default-font
	para:	make default-para [margin: as-pair CTX-REBGUI/sizes/slider + 2 2]
	feel:	make default-feel [
		engage: make function! [face action event][
			face/pane/feel/engage face/pane action event
		]
	]
	action:	make default-action [
		on-unfocus: make function! [face] [
			hide-popup
			face/hidden-text: face/hidden-caret: none
			true
			;face/action face	; causes problems when set-focus used from another widget to assign and then shift focus
		]
	]
	options:	[info]
	hidden-caret: hidden-text: none
	;	Accessor functions
	picked: make function! [/values /local i] [
		i: attempt [index? find data text]
		if none? i [return none]
		if values [return reduce [(pick indexes i)  (pick data i)] ]
		return i
	]
	
	rebind:	make function! [] [
		color: colors/outline-light
		para/margin/x: CTX-REBGUI/sizes/line + 2
	]
	init:	make function! [/local p tBlk] [
		unless block? data [gui-error "drop-list expected data block"]
		
		indexes: copy []
		tBlk: copy []
		foreach [a b] data [
			append indexes a
			append tBlk b
		]
		data: copy tBlk
		
		para: make para []	; avoid shared para object for scrollable input widget
		p: self
		pane: make arrow [
			tip:	none
			offset:	as-pair p/size/x - p/size/y + 1 1
			size:	as-pair p/size/y - 4 p/size/y - 4
			span:	if all [p/span find p/span #W] [#X]
			edge:	none
			action:	make default-action [
				on-click: make function! [face /filter-data fd [block!] /local data p v lines oft] [
					unless filter-data [ctx-rebgui/edit/unfocus]	; unfocus if arrow pressed
					p: face/parent-face
					all [find p/options 'no-click exit]
					data: either fd [fd] [p/data]
					unless zero? lines: length? data [
						oft: either (lines * CTX-REBGUI/sizes/line) < (p/parent-face/size/y - p/offset/y - p/size/y) [
							;	fits below
							p/offset + as-pair 0 p/size/y - 1
						][
							either (lines * CTX-REBGUI/sizes/line) <= (p/parent-face/size/y - 4) [
								;	fits bottom
								as-pair p/offset/x p/parent-face/size/y - 2 - (lines * CTX-REBGUI/sizes/line)
							][
								;	align to bottom
								as-pair p/offset/x p/parent-face/size/y - 2 - (CTX-REBGUI/sizes/line * to integer! p/parent-face/size/y / CTX-REBGUI/sizes/line)
							]
						]
						if v: choose p p/size/x oft data [
							p/text: form v
							p/hidden-text: p/hidden-caret: none
							p/action/on-click p
							either p/type = 'drop-list [show p ctx-rebgui/edit/unfocus] [set-focus p]
						]
					]
				]
			]
		]
		pane/init	; draw arrow
	]
]
]

;;here is example of usage...
comment {
display "DROP-LIST2 Example" [
	dl1: drop-list2 "a" data [1 "a" 22 "b" 333 "c"] 
	button 50 "Picked/values" [alert mold dl1/picked/values]
	return
	
	dl2: drop-list2 data [100 "aaa" 200 "bbb" 333 "ccc"] 
	button 50 "Picked/values" [alert mold dl2/picked/values]
]

do-events
}