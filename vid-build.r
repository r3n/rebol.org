REBOL [
	Title: "VID_build"
	Date: 12-Nov-2013
	Version: 0.8.6
	File: %vid-build.r
	Author: "Marco Antoniazzi"
	Copyright: "(C) 2012-2013 Marco Antoniazzi"
	Purpose: "Easily create VID guis"
	eMail: [luce80 AT libero DOT it]
	History: [
		0.0.1 [14-Mar-2010 "First version"]
		0.0.2 [31-Mar-2010 "Enhancements"]
		0.0.3 [21-Apr-2010 "Enhancements and bug fixes"]
		0.0.4 [11-Sep-2010 "Enhancements"]
		0.0.5 [18-Sep-2010 "Enhancements"]
		0.0.6 [24-Sep-2010 "Enhancements and bug fixes"]
		0.0.7 [26-Sep-2010 "Added style button and sensor"]
		0.0.8 [09-Oct-2010 "gui window reopens where it was closed"]
		0.0.9 [01-Nov-2010 "Enhancements and bug fixes"]
		0.6.0 [03-Jan-2011 "Added a few keyboard shortcuts, undo, redo, prefs, help, clear and bug fixes"]
		0.6.5 [08-Jan-2011 "Window's offset and size in prefs, added panel, gui to clip, find and bug fixes"]
		0.6.6 [16-Feb-2011 "Minor bug fixes and retouches"]
		0.6.7 [17-May-2011 "Added possibility to skip initial popup, Save button"]
		0.7.0 [02-Jun-2011 "Added gradient, edge, font, para labs"]
		0.7.1 [03-Jun-2011 "Minor bug fixes and retouches"]
		0.7.2 [23-Jun-2011 "Minor bug fixes"]
		0.7.3 [24-Aug-2011 "Minor bug fixes (but hard to solve ;( )"]
		0.7.4 [28-Aug-2011 "Added info style, reload most recently saved file and minor source retouches"]
		0.8.0 [14-Dec-2011 "Reimplemented panels, added lists and source retouches"]
		0.8.1 [01-Jan-2012 "Minor bug fix"]
		0.8.2 [22-Aug-2012 "Refresh without closing win and Added a little waiting time for slow Linux refresh"]
		0.8.3 [16-Jun-2013 "Fixed is_style? for add-facet"]
		0.8.4 [13-Aug-2013 "Fixed bugs in gui loading and commenting and Added sending bug report"]
		0.8.5 [27-Oct-2013 "Adapted to Rebol 3 (with vid1r3.r3)"]
		0.8.6 [12-Nov-2013 "Fixed show-instructions for R3"]
	]
	Notes: {
	- Shortcuts: Undo <Ctrl+z>, Redo <Ctrl+r>, Cut <Ctrl+x>, Copy <Ctrl+c>, Paste <Ctrl+v>, Save <Ctrl+s>, edit style <F2>, Quit <Esc>,
		Select previous <Up>, next <Down>, some previous <Pg-Up>, some next <Pg-Down>
		first <Home>, last <End>, Mouse-wheel also scrolls
	- Pay attention not to erase first and last lines of panels and lists
	- Pay A LOT OF attention not to create an empty list
	}
	Todo: {
		- save also offset of window
		- link or redo of vid-ancestry, effect-lab, paint
		- build rebol header
	}
	Category: [util vid view]
	library: [
		level: 'intermediate
		platform: 'all
		type: 'tool
		domain: [gui vid]
		tested-under: [View 2.7.8.3.1 2.7.8.4.3 Saphir-View 2.101.0.3.1]
		support: none
		license: 'BSD
		see-also: none
	]
	thumbnail: http://i40.tinypic.com/ixy1ow.png
]

;***** set correct path to vid1r3.r3 and sdk sources (or use empty string to use default path to sdk) *****
if system/version > 2.7.8.100 [do/args %../../r3/local/vid1r3.r3 %../../sdk-2706031/rebol-sdk-276/source]

docs: http://www.rebol.com/docs/view-guide.html ; change to suit your needs

err?: func [blk /local arg1 arg2 arg3 message err][;11-Feb-2007 Guest2
	if not error? err: try blk [return :err]
	err: disarm err
	set [arg1 arg2 arg3] reduce [err/arg1 err/arg2 err/arg3]
	message: get err/id
	if block? message [bind message 'arg1]
	alert rejoin ["ERROR: " form reduce message ". THE PROGRAM WILL TERMINATE."]
	;undo
	;save_file
	launch/quit system/options/script
]
err? [
;do [
;prin: print: func [val] [to-error form get/any 'val] ; uncomment to redirect console output to alerts
system/view/vid/error: func [msg spot] [to-error [msg]] ; patch VID error function to keep it silent
; add widget
	widget_inc: func [widget [string!] text [string!]][
		rejoin [widget { "} text form counter {"}]
	]
	add_new_widget: func [new-widget [string!] /no-lay /local str-counter] [
		str-counter: reverse head change copy "0000" reverse to-string counter ; pad left with 0s
		new-widget: copy new-widget
		insert new-widget rejoin ["L" str-counter ": "]
		counter: counter + 1
		unless no-lay [add_to_undo-list]
		
		either empty? gui-list/data [
			append gui-list/data new-widget
		][
			if empty? gui-list/picked [append gui-list/picked first gui-list/data] ; security check
			insert find/tail gui-list/data first gui-list/picked new-widget
		]

		append clear gui-list/picked new-widget
		unless no-lay [update_list_and_layout]
		new-widget
	]
	add_new_text: func [new-widget [string!] /local new-text] [
		if new-text: request-text/default join "New text" counter [
			add_new_widget rejoin [new-widget { "} new-text {"}] 
		]
	]
	add_panel: func [/list /local picked] [
		add_to_undo-list
		add_new_widget/no-lay rejoin [{} either list [{list}] [{panel}] { edge [size: 1x1] [}]
		add_new_widget/no-lay {origin 0}
		picked: add_new_widget/no-lay {space 4x4}
		if list [picked: add_new_widget/no-lay {text "Hello"}]
		add_new_widget/no-lay {]}
		append clear gui-list/picked picked ; select penultimate line
		update_list_and_layout
	]
;
; clip , undo
	remove_selected: func [/local picked] [
		if empty? gui-list/data [exit]
		add_to_undo-list

		picked: find gui-list/data first gui-list/picked
		clear gui-list/picked
		either tail? next picked [ ; is last line?
			append gui-list/picked first back picked
		][
			append gui-list/picked first next picked
		]
		remove picked

		update_list_and_layout
	]
	copy_selected: does [
		if empty? gui-list/data [exit]
		copied: copy first find gui-list/data first gui-list/picked
		remove/part copied length? "L0000: "; remove line label
	]
	paste_selected: does [
		if empty? copied [exit]
		add_new_widget copied
	]

	add_to_undo-list: does [
		insert/only undo-list copy gui-list/data
		if not empty? gui-list/picked [insert pick-list first gui-list/picked]
		saved?: no
	]
	undo: does [
		if empty? undo-list [exit]
		insert/only redo-list copy gui-list/data
		append pick-list gui-list/picked
		gui-list/data: take undo-list
		clear gui-list/picked
		if not empty? gui-list/data [
			append gui-list/picked either empty? pick-list [first gui-list/data][take pick-list]
		]
		update_list_and_layout
	]
	redo: does [
		if empty? redo-list [exit]
		insert/only undo-list copy gui-list/data
		insert pick-list gui-list/picked
		gui-list/data: take redo-list
		clear gui-list/picked
		if not empty? gui-list/data [
			append gui-list/picked either empty? pick-list [first gui-list/data][take/last pick-list]
		]
		update_list_and_layout
	]
;
; move , replace , select , find
	move_selected: func [/up /down /local picked dir new-index] [
		if empty? gui-list/data [exit]
		dir: either up [-1] [1]
		new-index: dir + index? picked: find gui-list/data first gui-list/picked
		if any [(new-index < 1) (new-index > length? gui-list/data)] [exit]

		add_to_undo-list

		move picked dir
		update_list_and_layout
	]
	replace_line: func [lab [string!] line [string!] /local old-line] [
		line: rejoin [lab line]
		if empty? gui-list/data [add_new_widget line exit]
		old-line: find/only gui-list/data first gui-list/picked
		if old-line = line [exit] ; unmodified line
		add_to_undo-list

		change/only old-line line
		append clear gui-list/picked line
		update_list_and_layout
	]
	select_line: func [dir [word!] /local old-index new-index] [
		if empty? gui-list/data [exit]
		dir: switch/default dir [
				up [-1]
				down [1]
				page-up [negate visible-lines]
				page-down [visible-lines]
				home [-10000] ; a great number
				end [10000] ; a great number
			] [exit]
		new-index: dir + old-index: index? find gui-list/data first gui-list/picked
		new-index: min max 1 new-index length? gui-list/data
		if new-index = old-index [exit]

		append clear gui-list/picked pick gui-list/data new-index
		show gui-list/update
		change_style
	]
	find_in_list: func [face /local start line found] [
		if empty? gui-list/data [focus window exit]
		start: gui-list/data
		if all [text-found? text-searched = face/text] [start: next find gui-list/data gui-list/picked]
		foreach line start [if find line face/text [found: line break]]
		either found [
			append clear gui-list/picked found
			show gui-list/update
			change_style
			text-found?: yes
			text-searched: copy face/text
			focus face
		] [
			focus window ; to unfocus edit-style
		]
	]
;
; update
	change_style: does [
		if empty? gui-list/data [
			clear edit-style/text
			clear lab
			exit
		]
		; avoid Ctrl to erase selection
		either empty? gui-list/picked [append gui-list/picked back-picked][back-picked: copy first gui-list/picked]
		selected-line: first gui-list/picked
		edit-style/text: copy line: find/tail selected-line " "
		lab: copy/part selected-line line
		show edit-style
		text-found?: no
	]
	rebuild_gui-list: func [/reset /local temp-list str-counter re-counter] [
		clear gui-list/data
		temp-list: main-list
		if main-list <> reduce [min-layout] [
			re-counter: 0
			forall temp-list [
				if reset [
					str-counter: reverse head change copy "0000" reverse to-string re-counter ; pad left with 0s
					head change first temp-list load rejoin ["L" str-counter ":"]
					re-counter: re-counter + 1
				]
				append gui-list/data mold/only first temp-list
			]
		]
		clear gui-list/picked
	]
	update_list_and_layout: has [temp-list] [
		show gui-list/update
		change_style
		
		;should I recycle ?
		new-win-layout: copy def-layout
		either empty? gui-list/data [
			; use a minimum layout to show a prettier window
			insert new-win-layout form min-layout
		][
			; reconstruct layout
			temp-list: copy gui-list/data
			forall temp-list [append new-win-layout join first temp-list "^/"] ; add  newline to let add comments
		]
		new-win-layout: load new-win-layout
		reopen_window
	]

	reopen_window: func [/local view-err?] [
		new-win/pane: none recycle
		new-win/pane: layout/tight new-win-layout
		new-win/size: new-win/pane/size
		show new-win
		window/changes: 'activate
		focus window
	]
	rebuild_script: func [the-script /local temp-main-list] [
		clear the-script
		temp-main-list: copy mold/only new-win-layout
		while [pos: find/any temp-main-list "L????:"] [temp-main-list: change/part pos "^/" 6]
		append the-script entab mold load head temp-main-list
	]
;
; prefs
	open_prefs: func [btn /local face] [
		win-options: copy temp-options
		foreach face win-checks/pane [
			if face/style = 'check-line [
				face/data: found? find win-options to-word face/text
			]
		]
		prefs-win-pos/text: new-win/offset
		prefs-win-size/text: new-win/size 
		prefs-win-title/text: new-win/text 
		field-min-size/text: either find win-options 'min-size [to-string win-options/min-size] [copy ""]
		inform/title/offset prefs-layout "Preferences" btn/size * 0x1 + screen-offset? btn
	]
	set_prefs: does [
		remove/part find win-options 'min-size 2
		if (trim field-min-size/text) <> "" [append win-options reduce ['min-size to-pair field-min-size/text]]
		update_list_and_layout
		unview/only new-win
		wait 0.1
		view/new/title/offset/options new-win win-title new-win/offset win-options
		prefs-layout/changes: 'activate
		focus prefs-layout
	]
	prefs-layout: layout [
		origin 4x4 space 4x4 
		across
		text "Window pos:"
		prefs-win-pos: info 65 return
		text "Window size:"
		prefs-win-size: info 65
		below
		h4 "Window title:" 
		prefs-win-title: field 150 [win-title: face/text set_prefs]
		h4 "Window options:"
		win-checks: panel [
			origin 0 space 4x4
			style check-line check-line [alter win-options to-word face/text set_prefs]
			check-line "no-title"
			check-line "no-border" 
			check-line "resize" 
			check-line "all-over" 
			check-line "activate-on-show"
		]
		Across 
		text "min-size"
		field-min-size: field 90 [either all [(trim face/text) <> "" error? try [face/text: to-string to-pair form reduce load face/text]] [focus face] [show face set_prefs]] return 
		btn 72 "OK" green + 50 [hide-popup temp-options: win-options]
		btn 72 "Cancel" [hide-popup win-options: temp-options update_list_and_layout]
	]
;
; send email
	open_send_bug-report: func [btn][
		inform/title/offset emailer-layout "Send bug report" screen-offset? btn
	]
	send_bug-report: func [/local email host sending err][
		if any [
			"" = trim get-face field-from
			"" = trim get-face field-subject
			"" = trim get-face area-message
		][alert "You must fill ALL fields" exit]
		sending: flash "Sending..."
		err: error? try [
			email: system/user/email
			system/user/email: to-email get-face field-from
			host: system/schemes/default/host
			system/schemes/default/host: "out.alice.it"

			send/header
				to email! rejoin ['luce80 #"@" 'alice.it]
				get-face area-message
				make system/standard/email [
					from: to-email get-face field-from
					subject: get-face field-subject
				]
		]
		unview/only sending
		either err [
			alert "Error sending email."
		][
			hide-popup 
			request/ok/type "Your email has been sent. Thank you." 'info
		]
		; restore old values
		system/user/email: email
		system/schemes/default/host: host
	]
	emailer-layout: layout [
		do [sp: 4x4] origin sp space sp 
		Across 
		style text text 100 
		style btn btn 110 
		style field field 220 
		h3 "Send me a bug report:" 
		txt underline "(ALL fields are mandatory)" 
		return 
		text "From:"    field-from: field (form any [attempt [system/user/email] ""]) return 
		pad 104x-4 txt {No spam, ever.} font-size 11 return
		text "Subject:" field-subject: field "VID_build bug report" return 
		text "Message:" return 
		area-message: area 324x150 
		return 
		indent 100 
		btn "Send" [send_bug-report]
		btn "Cancel" [hide-popup]
	]
;
; add facets
	remove_facet_and_block: func [word [word!]/local line str] [
		line: to-block first gui-list/picked
		if str: find line word [remove/part str 2]
		mold/only next line
	]
	is_style?: has [line] [
		line: copy first gui-list/picked
		foreach word [": across" ": below" ": return" ": guide" ": at" ": tab" ": origin" ": space" ": pad" ": indent" ": panel" ": list" ": ]"] [
			if find lowercase line word [return false]
		]
		true
	]
	change-styles: func [style facet subfacet value /local f v][;Author: "Carl Sassenrath" from Font-lab.r
		;start: find style/pane start
		;foreach f start [
			f: in style facet
			if subfacet <> 'none [f: in get f subfacet]
			either block? value [
				if not block? get f [set f either none? get f [copy []][reduce [get f]]]
				either v: find get f value [remove v][head insert get f value]
			][set f value]
		;]
		;show style
	]
	chg: func ['facet 'subfacet value] [;Author: "Carl Sassenrath" from Font-lab.r
		change-styles text-font-sample facet subfacet value show text-font-sample
	]
	chg-eff: func [pos value] [box-gradient-sample/effect/:pos: value show box-gradient-sample]
	chg-edge: func ['subfacet value] [change-styles box-edge-sample 'edge subfacet value show box-edge-sample]
	chg-para: func ['subfacet value] [change-styles box-para-sample 'para subfacet value show box-para-sample]
	add_gradient: has [result faces-vals] [
		rtn: func [value] [result: value hide-popup]
		faces-vals: copy []
		foreach face gradient-layout/pane [append faces-vals get-face face]
		append/only faces-vals copy box-gradient-sample/effect
		inform/title/offset gradient-layout "Add a gradient" window/offset + window/size - gradient-layout/size
		switch result reduce [
			yes [; keep modifications and return new effect
				rejoin [remove_facet_and_block 'effect { effect } mold box-gradient-sample/effect]
			]
			none [; reset previous values and return none
				foreach face gradient-layout/pane [set-face face take faces-vals]
				box-gradient-sample/effect: take faces-vals
				none
			]
		]
	]
	add_edge: has [result faces-vals] [
		rtn: func [value] [result: value hide-popup]
		faces-vals: copy []
		foreach face edge-layout/pane [append faces-vals get-face face]
		faces-vals: load mold append/only faces-vals second box-edge-sample/edge
		inform/title/offset edge-layout "Add an edge" window/offset + window/size - edge-layout/size
		switch result reduce [
			yes [rejoin [remove_facet_and_block 'edge { edge } mold third load trim/lines mold box-edge-sample/edge]]
			none [
				foreach face edge-layout/pane [set-face face take faces-vals]
				box-edge-sample/edge: do head clear skip take faces-vals 3 ;re-make edge object
				none
			]
		]
	]
	add_font: has [result faces-vals] [
		rtn: func [value] [result: value hide-popup]
		faces-vals: copy []
		foreach face font-layout/pane [append faces-vals get-face face]
		faces-vals: load mold append/only faces-vals second text-font-sample/font
		inform/title/offset font-layout "Add a font" window/offset + window/size - font-layout/size
		switch result reduce [
			yes [rejoin [remove_facet_and_block 'font { font } mold third load trim/lines mold text-font-sample/font]]
			none [
				faces-vals: reduce faces-vals ; need this for toggles logic and slider-pair but...
				foreach face font-layout/pane [set-face face take faces-vals]
				text-font-sample/font: do head clear skip take faces-vals 3 ; ...must do this for font object
				none
			]
		]
	]
	add_para: has [result faces-vals] [
		rtn: func [value] [result: value hide-popup]
		faces-vals: copy []
		foreach face para-layout/pane [append faces-vals get-face face]
		faces-vals: load mold append/only faces-vals third box-para-sample/para
		inform/title/offset para-layout "Add a para" window/offset + window/size - para-layout/size
		switch result reduce [
			yes [rejoin [remove_facet_and_block 'para { para } mold third load trim/lines mold box-para-sample/para]]
			none [
				foreach face para-layout/pane [set-face face take faces-vals]
				box-para-sample/para: make face/para take faces-vals
				none
			]
		]
	]
;
; layouts
	spc: 4x4
	stylize/master [
		slider-pair: slider 40x23 0.1 with [
			minv: 1
			maxv: 20
			coo: 'cx
			pair: 0x0
			target: none
			action-post: none
			words: reduce [
				'min func [new args] [new/minv: second args next args]
				'max func [new args] [new/maxv: second args next args]
				'target func [new args] [new/target: second args next args]
				'action-post func [new args] [new/action-post: func [face value] second args next args]
				'cx func [new args] [new/coo: 'cx args]
				'cy func [new args] [new/coo: 'cy args]
			]
		] [
			num: to-integer round face/maxv - face/minv * value + face/minv
			either 'cx = face/coo [
				remove/part face/target/text find face/target/text "x"
				insert face/target/text to-string num
			][
				remove/part find/tail face/target/text "x" tail face/target/text 
				insert find/tail face/target/text "x" to-string num
			]
			face/pair: to-pair face/target/text
			show face/target
			face/action-post face value
		]
		slider-int: slider 115x23 0.0 with [
			minv: 1
			maxv: 20
			target: none
			action-post: none
			words: reduce [
				'min func [new args] [new/minv: second args next args]
				'max func [new args] [new/maxv: second args next args]
				'target func [new args] [new/target: second args next args]
				'action-post func [new args] [new/action-post: func [face value] second args next args]
			]
		] [set-face face/target to-integer round face/maxv - face/minv * value + face/minv face/action-post face value]
		colorbox: box with [
			access: make object! [
				set-face*: func [face [object!] value [tuple! none!]] [if value [face/text: form face/color: value]]
				get-face*: func [face [object!]] [face/color]
			]
		]
		choice: choice with [access: ctx-access/text]
		toggle: toggle with [
			access: make object! [
				set-face*: func [face [object!] value ][face/data: face/state: value]
				get-face*: func [face [object!]][not not face/data] ; two not give correct result also for none
			]
		]
	]
	gadgets-layout: layout/offset [
		origin 0 space spc
		style box box 50x20 font [size: 12 color: black shadow: none]
		across
		button 78 "button" [add_new_widget widget_inc "button" "New button"]
		toggle 78 "toggle" [add_new_widget {toggle "UP" "Down" sky water}]
		btn 40 "btn" [add_new_widget widget_inc "btn" "New button"] return
		rotary 78 "rotary" [add_new_widget {rotary "item 1" "item 2" "item 3"}]
		choice 78 "choice" [add_new_widget {choice "choice 1" "choice 2" "choice 3"}]
		tog 40 "tog" [add_new_widget {tog " UP " "Down"}] return
		check-line "check" [add_new_widget widget_inc "check-line" "check this"]
		radio-line "radio" [add_new_widget widget_inc "radio-line" "choose this"]
		pad 0x4 led 12x12 [add_new_widget {led 12x12}] pad 0x-4 text "led" [add_new_widget {led 12x12}]
		label "sensor" [add_new_widget {sensor 0x0 keycode [#"^(ESC)"] [unview] }] return
		arrow up [add_new_widget {arrow up}]
		arrow down [add_new_widget {arrow down}]
		arrow left [add_new_widget {arrow left}]
		arrow right [add_new_widget {arrow right}]
		box "box" 108 white - 20 [add_new_widget {box white}] return
		box "panel" 100 edge [size: 1x1 effect: 'ibevel color: black] [add_panel]
		box "list" 100 edge [size: 1x1 effect: 'ibevel color: black] [add_panel/list] return
		label "Progress:" [add_new_widget {progress}] pad 0x4 progress 120 pad 0x-4 return
		label "Separator:" [add_new_widget {bar}] pad 0x10 bar 120 pad 0x-10 return
		label "Horizontal Slider:" [add_new_widget {slider 120x16 0.5}] pad 0x3 slider 50x16 0.5 return
		label "Vertical Slider:" [add_new_widget {slider 16x120 0.5}] pad 70x-30 slider 16x50 0.5 return
		label "Horizontal Scroller:" [add_new_widget {scroller 120x16 0.5}] scroller 50x16 0.5 return
		label "Vertical Scroller:" [add_new_widget {scroller 16x120 0.5}] pad 78x-30 scroller 16x50 0.5 return
		field 100 "field" [add_new_widget {field}]
		drop-down 100 with [text: "drop-down" list-data: ["item 1" "item 2" "item 3"]] [add_new_widget {drop-down 200 with [text: first list-data: ["item 1" "item 2" "item 3"]]} ] return
		area 100x48 "area" [add_new_widget {area 200x48}]
		text-list 100x48 data ["1st line" "2nd line" "3rd line" "4rd line"] [add_new_widget {text-list 200x48 "1st line"}] return
	] spc
	text-layout: layout/offset [
		origin 0 space spc
		below
		text "Normal text" [add_new_text {text}]
		text "Bold text" bold [add_new_text {text bold}]
		text "Italic text" italic [add_new_text {text italic}]
		text "Underlined text" underline [add_new_text {text underline}]
		label "Label text" [add_new_text {label}] return
		title "Title" [add_new_text {title}]
		h1 "Heading 1" [add_new_text {h1}]
		h2 "Heading 2" [add_new_text {h2}]
		h3 "Heading 3" [add_new_text {h3}]
		h4 "Heading 4" [add_new_text {h4}]
		info "info" 100 [add_new_widget {info "info"}]
	] spc
	gradient-layout: layout/offset [
		origin spc space spc
		do [directs: ["horiz" 1x0 "vert" 0x1 "horiz-vert" 1x1 "rev-horiz" -1x0 "rev-vert" 0x-1 "rev-horz-vert" -1x-1]]
		style text text 50 left
		Across
		btn "Remove EFFECT" 190 [replace_line lab remove_facet_and_block 'effect]
		return
		text "Direction" 80
		choice data extract directs 2 [chg-eff 2 select directs value]
		return
		text "Color 1"
		colorbox "200.0.0" 130x23 200.0.0 edge [size: 1x1 color: silver effect: 'bevel] [set-face face value: request-color chg-eff 3 value]
		return
		text "Color 2"
		colorbox "0.0.200" 130x23 0.0.200 edge [size: 1x1 color: silver effect: 'bevel] [set-face face value: request-color chg-eff 4 value]
		return
		box-gradient-sample: box "Sample" 190x190 effect [gradient 1x0 200.0.0 0.0.200]
		return
		btn "Add gradient" 90 [rtn yes]
		btn "Cancel" 90 [rtn none]
	] spc
	edge-layout: layout/offset [
		origin spc space spc
		style text text 50 right
		Across
		btn "Remove edge" 190 [replace_line lab remove_facet_and_block 'edge]
		return
		text "Size"
		txt-edge-size: txt "2x2" 40 bold center
		slider-pair cx target txt-edge-size action-post [chg-edge size face/pair]
		slider-pair cy target txt-edge-size action-post [chg-edge size face/pair]
		return
		text "Color"
		colorbox "128.128.128" 130x23 128.128.128 edge [size: 1x1 color: silver effect: 'bevel] [set-face face value: request-color chg-edge color value]
		return
		text "Effect"
		choice "bevel" "ibevel" "bezel" "ibezel" "nubs" 130 [chg-edge effect to-word value]
		return
		box-edge-sample: box "Sample" 190x50 edge [size: 2x2 color: gray effect: 'bevel]
		return
		btn "Add edge" 90 [rtn yes]
		btn "Cancel" 90 [rtn none]
	] spc
	font-layout: layout/offset [
		origin spc space spc
		style toggle toggle 60
		style text text 52 right
		style txt txt "0x0" 46 bold center
		Across
		btn "Remove font" 190 [replace_line lab remove_facet_and_block 'font]
		return
		text "Type"
		choice-font-type: choice 115 "Sans-Serif" "Serif" "Fixed" [chg font name pick reduce [font-sans-serif font-serif font-fixed] index? choice-font-type/data]
		return
		toggle "Bold" [chg font style [bold]]
		toggle "Italic" font [style: [italic]] [chg font style [italic]]
		toggle "Lined" font [style: 'underline] [chg font style [underline]]
		return
		toggle "Left--" of 'horz-align [chg font align 'left]
		toggle "-Center-" of 'horz-align [chg font align 'center]
		toggle "--Right" of 'horz-align [chg font align 'right]
		return
		toggle "^^Top" of 'vert-align [chg font valign 'top]
		toggle "- Middle" of 'vert-align [chg font valign 'middle]
		toggle "_Bottom" of 'vert-align [chg font valign 'bottom]
		return
		text "Size"
		txt-font-size: txt "12" 30
		slider-int 95 0.6 target txt-font-size action-post [chg font size to-integer get-face txt-font-size]
		return
		text "Space"
		txt-font-space: txt
		slider-pair 0.0 min 0 cx target txt-font-space action-post [chg font space face/pair]
		slider-pair 0.0 min 0 cy target txt-font-space action-post [chg font space face/pair]
		return
		text "Shadow"
		txt-font-shadow: txt
		slider-pair 0.5 min -10 max 10 cx target txt-font-shadow action-post [chg font shadow face/pair]
		slider-pair 0.5 min -10 max 10 cy target txt-font-shadow action-post [chg font shadow face/pair]
		return
		text "Color"
		colorbox "0.0.0" 130x23 0.0.0 edge [size: 1x1 color: silver effect: 'bevel] [set-face face value: request-color chg font color value]
		return
		text-font-sample: text "AaBbCc" 190 center edge [size: 2x2 effect: 'ibevel] 
		return
		btn "Add font" 90 [rtn yes]
		btn "Cancel" 90 [rtn none]
	] spc
	para-layout: layout/offset [
		origin spc space spc
		style text text 50 right
		style txt txt "0x0" 50 bold center
		style field field 100
		style slider-pair slider-pair 0.5 min -10 max 10
		Across
		btn "Remove para" 190 [replace_line lab remove_facet_and_block 'para]
		return
		text "Origin"
		txt-para-origin: txt "2x2"
		slider-pair 0.6 cx target txt-para-origin action-post [chg-para origin face/pair]
		slider-pair 0.6 cy target txt-para-origin action-post [chg-para origin face/pair]
		return
		text "Margin"
		txt-para-margin: txt "2x2"
		slider-pair 0.6 cx target txt-para-margin action-post [chg-para margin face/pair]
		slider-pair 0.6 cy target txt-para-margin action-post [chg-para margin face/pair]
		return
		text "Indent"
		txt-para-indent: txt
		slider-pair cx target txt-para-indent action-post [chg-para indent face/pair]
		slider-pair cy target txt-para-indent action-post [chg-para indent face/pair]
		return
		text "Scroll"
		txt-para-scroll: txt
		slider-pair cx target txt-para-scroll action-post [chg-para scroll face/pair]
		slider-pair cy target txt-para-scroll action-post [chg-para scroll face/pair]
		return
		text "Tabs"
		txt-para-tabs: txt "40" 30
		slider-int 95 (40 / (100 - 1)) min 1 max 100 target txt-para-tabs action-post [chg-para tabs to-integer get-face txt-para-tabs]
		return
		text "Wrap"
		check on [chg-para wrap? value]
		return
		box-para-sample: text left as-is {AaBbCc
	DdEeFfGg this is a sample long line to test wrapping} 190 edge [size: 2x2 effect: 'ibevel] para [] ; <- clone para so it is not shared (thanks Anton)
		return
		btn "Add para" 90 [rtn yes]
		btn "Cancel" 90 [rtn none]
	] spc
;
window: layout [
	style choice choice white - 20 font [style: none size: 11 colors: [0.0.0 255.150.55] shadow: none]
	origin spc space spc
	across
	btn "Load..." [load_gui] pad -4
	btn "Reload" [load_gui/recent]
	btn "Save" yellow #"^s" [save_file] pad -4
	btn "as..." yellow [save_file/as]
	btn "Save as REBOL..." yellow [save_file/as/reb]
	btn "Reopen window" green + 100 [unview/only new-win wait 0.1 view/new/title center-face new-win "Test"]
	btn ":(" [open_send_bug-report face]
	btn "?" sky [browse docs] return
	btn "Undo" #"^z" [undo]
	btn "Redo" #"^r" [redo]
	btn "Copy gui to clipboard" [rebuild_script gui-script write clipboard:// gui-script]
	btn "Clear gui" orange [if not empty? gui-list/picked [here-at: false add_to_undo-list clear gui-list/data update_list_and_layout]]
	text "Find:" para [origin: 2x4] field 80 with [alter self/flags 'tabbed] [find_in_list face]
	btn "Prefs" [open_prefs face] return
	h3 "Choose auto-layout:" return
	choice "Across" "Below" 60x22 [add_new_widget face/text]
	btn "Return" [add_new_widget {return}]
	btn "Guide" [add_new_widget {guide}]
	btn "here: at" [add_new_widget {here: at} here-at: true]
	btn "at here" [either here-at [add_new_widget {at here}][alert {"here: at" not found, add it.}]]
	btn "tab" [add_new_widget {tab}]
	choice "origin 10x10" "space 10x10" "pad 10x10" "tabs 100" "indent 10" 90x22 [add_new_widget value]
	btn "style" [
		if not empty? gui-list/picked [
			add_new_widget rejoin [{style } form this-style: second to-block first gui-list/picked { } this-style { red}]
		]
	] return
	h3 "Choose element to add:" return
	rotary "Gadgets" "Text" 220x24 gray + 100 font [colors: [0.0.0 255.150.55] shadow: none] [
		switch value [
			"Gadgets" 	[panels/pane: gadgets-layout show panels]
			"Text" 		[panels/pane: text-layout show panels]
		]
	]
	btn "Cut" #"^x" gadgets-layout/size / 3x1 * 1x0 + -16x24 [copy_selected remove_selected]
	btn "Copy" #"^c" gadgets-layout/size / 3x1 * 1x0 + -16x24 [copy_selected]
	btn "Paste" #"^v" gadgets-layout/size / 3x1 * 1x0 + -16x24 [paste_selected]
	arrow 'up 24x24 [move_selected/up] arrow 'down 24x24 [move_selected/down] return
	panels: box gadgets-layout/size + (spc * 4) edge [size: spc effect: 'ibevel] with [pane: gadgets-layout]
	gui-list: text-list panels/size data copy [] [change_style] with [
		update: func [/local item tot-rows visible-rows] [
			tot-rows: length? data visible-rows: lc
			sld/redrag visible-rows / max 1 tot-rows
			if item: find data picked/1 [
				either visible-rows >= tot-rows [
					sld/step: 0.0
					sld/data: 0.0
					sn: 0
				][
					sld/step: 1 / (tot-rows - visible-rows)
					sld/data: (index? item) / tot-rows ; simple but it works
					if sld/data < sld/step [sld/data: 0]
					sn: to-integer sld/data / sld/step
				]
			]
			self
		]
		append init [
			iter/para/origin: -40x0 ; hide labels (should be size-text something)
			iter/para/wrap?: false
			sld/action: func [face value] [ ;patched
				if sn = value: max 0 to-integer value * ((length? slf/data) - lc) [exit] ; I always hated that "1 +" !
				sn: value 
				show sub-area
			]
		]
	] return
	h3 "Edit style:"
	key (escape) (0x0 - spc) [ask_close]
	key keycode [f2] [if not empty? gui-list/data [focus edit-style]] return
	edit-style: field panels/size * 2x0 - 104x0 + 4x38 wrap [
		if (trim face/text) = "" [
			remove_selected
			exit
		]
		either attempt [layout to-block compose load 
				either any [
					found? find first gui-list/picked ": panel"
					found? find first gui-list/picked ": list"
					][join face/text "text]"][face/text]
				][
			if (type? lab) <> string! [lab: copy/part selected-line line] ; "lab" used as get-word !!
			replace_line lab face/text
		] [
			focus edit-style
		]
	]
	choice "color" "gradient" "edge" "font" "para" "file..." "show?: no" "show?: yes" "comment" "uncomment" [
		hide-popup
		if all [edit-style/text <> "" is_style?][
			switch value [
				"color" 	[repend edit-style/text [" " any [request-color ""]]]
				"gradient" 	[edit-style/text: any [add_gradient edit-style/text]]
				"edge"		[edit-style/text: any [add_edge edit-style/text]]
				"font"		[edit-style/text: any [add_font edit-style/text]]
				"para"		[edit-style/text: any [add_para edit-style/text]]
				"file..."	[if file: choose_file [repend edit-style/text [" " mold to-file file]]]
				"show?: no" [either not sh?: find/tail edit-style/text "show?: " [append edit-style/text { with [show?:  no]}][change sh? " no"]]
				"show?: yes" [either not sh?: find/tail edit-style/text "show?: " [append edit-style/text { with [show?: yes]}][change sh? "yes"]]
			]
			replace_line lab edit-style/text
		]
		if all [edit-style/text <> ""][
			switch value [
				"comment" 	[if not find edit-style/text "comment" [insert edit-style/text {do [comment [} append edit-style/text {]]}]]
				"uncomment" [if find edit-style/text "do [comment [" [replace edit-style/text {do [comment [} "" remove/part back back tail edit-style/text 2]]
			]
			replace_line lab edit-style/text
		]
	] return
]
window/feel: make window/feel [
	detect: func [face event][
		case [
			event/type = 'key [
				if system/view/focal-face/feel = ctx-text/edit [ ; editing has precedence (if not escaping)
					either event/key = (escape) [change_style focus window return none][return event]
				]
				if face: find-key-face face event/key [
					if get in face 'action [do-face face event/key]
					return none
				]
				if word? event/key [select_line event/key]
				return none
			]
			event/type = 'scroll-line [either event/offset/y < 0 [select_line 'up] [select_line 'down] ]
			event/type = 'close [ask_close return none]
		]
		event
	]
]
; file
	ask_close: does [
		either not saved? [
			switch request ["Exit without saving?" "Yes" "Save" "No"] reduce [
				yes [quit]
				no [if save_file [quit]]
			]
		][
			quit
		]
	]
	save_file: func [/as /reb /local file-name filt ext response script] [
		if empty? gui-list/data [return false]
		if none? gui-name [as: true]

		either reb [
			filt: "*.r"
			ext: %.r
			script: "script"
		][
			filt: "*.rbl"
			ext: %.rbl
			script: "block"
		]
		if as [
			file-name: request-file/title/keep/only/save/filter join "Save as Rebol " script "Save" filt
			if none? file-name [return false]
			if not-equal? suffix? file-name ext [append file-name ext]
			response: true
			if exists? file-name [response: request/confirm rejoin [{File "} last split-path file-name {" already exists, overwrite it?}]]
			if response <> true [return false]
			gui-name: file-name
			gui-dir: first split-path file-name
		]
		flash join "Saving to: " gui-name

		either reb [
			script: copy rejoin [{REBOL [^/^-comment: "} now/date { GUI automatically generated by VID_build. Author: Marco Antoniazzi"^/]
			^/^/view/title/options center-face layout ^/^	}]
			rebuild_script gui-script append script gui-script
			append script rejoin [{ "} win-title {" [} win-options {]}]
			;print script
			write gui-name script
		][
			main-list: copy []
			insert main-list compose/only/deep ['VID_build_gui-block [counter (counter) version 3 win-title (win-title) win-options (win-options)]]
			foreach line gui-list/data [insert/only tail main-list line]
			save gui-name head main-list
		]
		wait 1.3
		unview
		saved?: yes
	]
	load_gui: func [/recent /local file-name temp-list version] [
		either recent [
			if temp-list: attempt [read gui-dir] [
				sort/compare temp-list func [a b] [not none? all [(any [modified? a 1-1-61]) > (any [modified? b 1-1-61]) %.rbl = suffix? a]]
			]
			file-name: either temp-list [first temp-list] [[none]]
		] [
			until [
				file-name: request-file/title/keep/only/filter "Load a gui block" "Load" "*.rbl"
				if none? file-name [exit]
				exists? file-name
			]
		]
		gui-name: file-name
		temp-list: any [attempt [load file-name] [VID_build_gui-block 0]]
		if not-equal? first temp-list 'VID_build_gui-block [exit]
		main-list: temp-list
		counter: second main-list
		clear win-options
		win-title: "VID_build"
		if block? counter [ ; compatibility
			win-prefs: counter
			counter: win-prefs/counter
			if (win-title: to-string win-prefs/win-title) = "" [win-title: "VID_build"]
			temp-options: win-options: win-prefs/win-options
			version: attempt [win-prefs/version] ; compatibility
		]
		remove/part main-list 2

		either all [version version >= 3] [
			gui-list/data: copy main-list
		][
			rebuild_gui-list/reset
		]
		append clear gui-list/picked last gui-list/data
		update_list_and_layout
		new-win/offset: system/view/screen-face/size - new-win/pane/size / 2
		show new-win
		undo-list: copy [] redo-list: copy []
		saved?: true
	]
	choose_file: func [/local file-name] [
		until [
			file-name: request-file/title/keep/only "Choose a file" "Open"
			if none? file-name [return none]
			exists? file-name
		]
		file-name
	]
;
; main

	counter: 0
	line: ""
	lab: " "
	copied: []
	main-list: copy []
	undo-list: copy []
	redo-list: copy []
	pick-list: copy []
	win-options: copy []
	temp-options: copy []
	win-title: "VID_build"
	saved?: yes
	text-found?: no
	here-at: false
	text-searched: ""
	gui-script: copy {}
	back-picked: copy []
	visible-lines: 0
	show-instructions?: 1 s-i: none ; DO NOT CHANGE THIS LINE
	gui-name: none
	gui-dir: what-dir ;%. ;;;;; not supported by R3 !

	min-layout: [size 100x100]
	new-win: layout min-layout
	def-layout: { do [sp: 4x4] origin sp space sp }
	new-win-layout: copy def-layout

	view/new/title/options window "VID_build" []

	if show-instructions? = 1 [
		inform layout [text as-is trim/auto {
			This is a simple, fast VID GUI builder.
			The knowledge of REBOL VID System is required.

			Instructions:

				1) Click on some "styles" below the "Gadgets" button
				2) Experiment with the other elements
				3) Save the layout as a Rebol block or a Rebol program
			}
			check-line "Don't show me again" with [data: not show-instructions?] [s-i: read/string %vid-build.r if s-i: find/tail s-i "show-instructions?:" [write %vid-build.r head change next s-i 0] ]
			key (escape) [hide-popup]
		]
	]
	wait 0.3 ; to not confuse user
	view/new/title center-face new-win "Test"
	window/changes: 'activate
	focus window
	do-events
;
]
