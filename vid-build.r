REBOL [
	Title: "VID_build"
	Date: 26-Sep-2010
	Version: 0.0.7
	File: %vid-build.r
	Author: "Marco Antoniazzi"
	Purpose: "Easily create VID guis"
	eMail: [luce80 AT libero DOT it]
	History: [
		0.0.1 [14-Mar-2010 "First version"]
		0.0.2 [31-Mar-2010 "Enancements"]
		0.0.3 [21-Apr-2010 "Enancements and bug fixes"]
		0.0.4 [11-Sep-2010 "Enancements"]
		0.0.5 [18-Sep-2010 "Enancements"]
		0.0.6 [24-Sep-2010 "Enancements and bug fixes"]
		0.0.7 [26-Sep-2010 "Added style button and sensor"]
		0.0.8 [09-Oct-2010 "gui window reopens where it was closed"]
	]
	Bugs: {if attempt [layout ...] [...] does not work correctly}
	Category: [util vid view]
	library: [
		level: 'intermediate
		platform: 'all
		type: 'tool
		domain: [gui vid]
		tested-under: [View 2.7.6.3.1]
		support: none
		license: 'BSD
		see-also: none
	]
]

counter: 0
line: ""
copied: []
main-list: copy []
widget_to_block: func [widget [block!] text [string!]][
	join widget [join text form counter]
]
add_new_widget: func [new_widget [block!]] [
	insert new_widget load rejoin ["L" counter ":"]
	counter: counter + 1

	either empty? gui-list/data [
		clear main-list
		append/only main-list new_widget
		append gui-list/data mold/only new_widget
	][
		insert/only find/only/tail main-list to-block first gui-list/picked new_widget
		insert find/tail gui-list/data first gui-list/picked mold/only new_widget
	]

	clear gui-list/picked
	append gui-list/picked mold/only new_widget
	update_list_and_layout
]
add_new_text: func [new_widget [block!] /local new_text] [
	if new_text: request-text/default join "New text" counter [
		add_new_widget join new_widget copy/deep new_text 
	]
]
remove_selected: func [/local picked] [
	if empty? gui-list/data [exit]
	remove find/only main-list to-block first gui-list/picked

	picked: find gui-list/data first gui-list/picked
	clear gui-list/picked
	either tail? next picked [ ; is last line?
		append gui-list/picked first back picked
	][
		append gui-list/picked first next picked
	]
	remove picked

	; use a minimum layout to show a prettier window
	if empty? gui-list/data [
		main-list: reduce [min-layout]
		counter: 0
	]
	update_list_and_layout
]
copy_selected: func [] [
	if empty? gui-list/data [exit]
	copied: copy first find/only main-list to-block first gui-list/picked
	remove copied ; remove line label
]
paste_selected: func [] [
	if empty? gui-list/data [exit]
	if empty? copied [exit]
	add_new_widget copy copied
]
move_up_selected: func [] [
	if empty? gui-list/data [exit]
	if equal? first gui-list/data first gui-list/picked [exit]
	move find/only main-list to-block first gui-list/picked -1

	move find gui-list/data first gui-list/picked -1
	update_list_and_layout
]
move_down_selected: func [] [
	if empty? gui-list/data [exit]
	if equal? last gui-list/data first gui-list/picked [exit]
	move find/only main-list to-block first gui-list/picked 1

	move find gui-list/data first gui-list/picked 1
	update_list_and_layout
]
replace_line: func [lab [string!] line [string!]] [
	line: rejoin [lab line]
	if empty? gui-list/data [add_new_widget copy load line exit]
	change/only find/only main-list to-block first gui-list/picked load line
	
	change/only find/only gui-list/data first gui-list/picked line
	clear gui-list/picked
	append gui-list/picked line
	update_list_and_layout
]
change_style: func [] [
	if empty? gui-list/data [
		clear edit-style/text
		clear lab
		exit
	]
	selected-line: first find gui-list/data first gui-list/picked ; 
	edit-style/text: copy line: find/tail selected-line " "
	lab: copy/part selected-line line
	show edit-style
]
update_list_and_layout: does [
	gui-list/update 0 0
	show gui-list
	change_style
	
	;should I recycle ?
	new-win-layout: copy def-layout
	forall main-list [append new-win-layout load first main-list] ; reconstruct layout
	main-list: head main-list
	reopen_window
]

reopen_window: func [/local new-win-offset] [
	;probe new-win-layout
	new-win-offset: new-win/offset
	unview/only new-win
	new-win: none
	new-win: layout new-win-layout 
	either counter = 1 [
		view/new/options center-face new-win []
	][
		view/new/offset/options new-win new-win-offset []
	]
	window/changes: 'activate
	focus window
]
min-layout: [size 100x100]
new-win: layout min-layout
def-layout: [do [sp: 4x4] origin sp space sp]
new-win-layout: copy def-layout

spc: 4x4

gadgets_layout: layout/offset [
	origin 0 space spc
	across
	button 78 "button" [add_new_widget widget_to_block [button] "New button"]
	toggle 78 "toggle" [add_new_widget copy [toggle "UP" "Down" sky water]]
	btn 40 "btn" [add_new_widget widget_to_block [btn] "New button"] return
	rotary 78 "rotary" [add_new_widget copy [rotary "item 1" "item 2" "item 3"]]
	choice 78 "choice" [add_new_widget copy [choice "choice 1" "choice 2" "choice 3"]]
	tog 40 "tog" [add_new_widget copy [tog " UP " "Down"]] return
	check-line "check" [add_new_widget widget_to_block [check-line] "check this"]
	radio-line "radio" [add_new_widget widget_to_block [radio-line] "choose this"]
	pad 0x4 led 12x12 [add_new_widget copy [led 12x12]] pad 0x-4 text "led" [add_new_widget copy [led 12x12]]
	label "sensor" [add_new_widget copy [sensor 0x0 keycode [#"^(ESC)"] [unview] ]] return
	arrow up [add_new_widget copy [arrow up]]
	arrow down [add_new_widget copy [arrow down]]
	arrow left [add_new_widget copy [arrow left]]
	arrow right [add_new_widget copy [arrow right]] box 100x20 "box" white - 20 [add_new_widget copy [box 100x100 white]] return
	label "Progress:" [add_new_widget copy [progress]] pad 0x4 progress 120 pad 0x-4  return
	label "Separator:" [add_new_widget copy [bar]] pad 0x10 bar 120 pad 0x-10 return
	label "Horizontal Slider:" [add_new_widget copy [slider 120x16 with [data: 0.5]]] pad 0x3 slider 50x16 with [data: 0.5] return
	label "Vertical Slider:" [add_new_widget copy [slider 16x120 with [data: 0.5]]] pad 70x-30 slider 16x50 with [data: 0.5] return
	label "Horizontal Scroller:" [add_new_widget copy [scroller 120x16 with [data: 0.5]]] scroller 50x16 with [data: 0.5] return
	label "Vertical Scroller:" [add_new_widget copy [scroller 16x120 with [data: 0.5]]] pad 78x-30 scroller 16x50 with [data: 0.5] return
	field 100 "field" [add_new_widget copy [field]]
	drop-down 100 with [text: "drop-down" list-data: ["item 1" "item 2" "item 3"]] [add_new_widget copy [drop-down 200 with [text: first list-data: ["item 1" "item 2" "item 3"]]] ] return
	area 100x48 "area" [add_new_widget copy [area 200x48]]
	text-list 100x48 data ["1st line" "2nd line" "3rd line" "4rd line"] [add_new_widget copy [text-list 200x48 "1st line"]] return
] spc
text_layout: layout/offset [
	origin 0 space spc
	below
	text "Normal text" [add_new_text [text]]
	text "Bold text" bold [add_new_text [text bold]]
	text "Italic text" italic [add_new_text [text italic]]
	text "Underlined text" underline [add_new_text [text underline]]
	label "Label text" [add_new_text [label]] return
	title "Title" [add_new_text [title]]
	h1 "Heading 1" [add_new_text [h1]]
	h2 "Heading 2" [add_new_text [h2]]
	h3 "Heading 3" [add_new_text [h3]]
	h4 "Heading 4" [add_new_text [h4]]
] spc
window: layout [
	origin spc space spc
	across
	btn "Open new window" green + 100 [view/new center-face new-win]
	btn "Load gui block" [load_gui]
	btn "Save as..." yellow [save_file]
	btn "Save as REBOL..." yellow [save_file/reb] return
	h3 "Choose auto-layout:" return
	tog "Across" "Below" [add_new_widget copy reduce [to-word face/text]]
	btn "Return" [add_new_widget copy [return]]
	btn "Guide" [add_new_widget copy [guide]]
	btn "here: at" [add_new_widget copy [here: at]]
	btn "at here" [add_new_widget copy [at here]]
	btn "tab" [add_new_widget copy [tab]]
	choice "origin 10x10" "space 10x10" "pad 10x10" "tabs 100" "indent 10" 100x22 white - 20 with [font: [style: none size: 11 colors: [0.0.0 5.10.255] shadow: none]] [
		add_new_widget copy load value
	]
	btn "style" [
		if not empty? gui-list/picked [
			add_new_widget copy reduce ['style this-style: second to-block first gui-list/picked this-style 'red]
		]
	] return
	h3 "Choose element to add:" return
	rotary "Gadgets" "Text" 220x24 gray + 100 with [font: [colors: [0.0.0 255.150.55] shadow: none]] [
		switch value [
			"Gadgets" 	[panels/pane: gadgets_layout show panels]
			"Text" 		[panels/pane: text_layout show panels]
		]
	]
	btn "Cut" gadgets_layout/size / 3x1 * 1x0 + -16x24 [copy_selected remove_selected]
	btn "Copy" gadgets_layout/size / 3x1 * 1x0 + -16x24 [copy_selected]
	btn "Paste" gadgets_layout/size / 3x1 * 1x0 + -16x24 [paste_selected]
	arrow 'up 24x24 [move_up_selected] arrow 'down 24x24 [move_down_selected] return
	panels: box gadgets_layout/size + (spc * 4) edge [size: spc effect: 'ibevel]
	do [panels/pane: gadgets_layout   lab: " "]
	gui-list: text-list panels/size data copy [] [change_style] return
	h3 "Edit style:"
	key keycode [#"^(ESC)"] [if system/view/focal-face = edit-style [change_style] ] return
	edit-style: field panels/size * 2x0 - 104x0 + 4x38 wrap [
		if (trim face/text) = "" [
			remove_selected
			exit
		]
		if attempt [layout to-block compose load face/text] [
			replace_line lab face/text
		]
	]
	choice "color" "gradient" "edge" [
		if edit-style/text <> "" [
			switch value [
				"color" 	[repend edit-style/text [" " request-color]]
				"gradient" 	[append edit-style/text { effect [gradient 200.0.0 0.0.200]}]
				"edge" 		[append edit-style/text { edge [size: 2x2 effect: 'bevel color: red]}]
			]
			replace_line lab edit-style/text
		]
	] return
]

save_file: func [/reb /local file-name filt ext response script] [
	if empty? main-list [exit]

	either reb [
		filt: "*.r"
		ext: %.r
	][
		filt: "*.rbl"
		ext: %.rbl
	]
	file-name: request-file/title/keep/only/filter "Save as Rebol script" "Save" filt
	if equal? file-name none [exit]
	if not suffix? file-name [append file-name ext]
	if not-equal? suffix? file-name ext [append file-name ext]
	response: true
	if exists? file-name [response: request rejoin ["File " last split-path file-name " already exists, overwrite it?"]]
	if response <> true [exit]
	flash join "Saving to: " file-name

	either reb [
		script: copy reform [{REBOL []^/^/view center-face layout [^/^-} mold/only def-layout "^/"]
		forall main-list [append script reform ["^-" mold/only first main-list "^/"] ]
		append script "]"
		;print script
		write file-name script
	][
		insert main-list reduce ['VID_build_gui-block counter]
		save file-name main-list
		remove/part main-list 2
	]
	wait 2
	unview
]
load_gui: func [/local file-name] [
	file-name: request-file/title/keep/only/filter "Load a gui block" "Load" "*.rbl"
	if equal? file-name none [exit]
	main-list: load file-name
	if not-equal? first main-list 'VID_build_gui-block [exit]
	counter: second main-list
	remove/part main-list 2
	
	clear gui-list/data
	forall main-list  [append gui-list/data mold/only first main-list]
	clear gui-list/picked
	append gui-list/picked last gui-list/data
	update_list_and_layout
]

quit_prog: func [face event] [
    either all [event/type = 'close event/face = window][quit][event]
]
insert-event-func :quit_prog

view/new/title/options  window "VID_build" []

inform layout [text as-is {This is a simple, fast VID GUI builder.
The knowledge of REBOL VID System is required.

Instructions:

	1) Click "Open new window"
	2) Click on some "styles" below the "Gadgets" button
	3) Experiment with the other elements
	4) Save the layout as a Rebol block or a Rebol program
}]

do-events
