rebol [
	title:   "GLayout demo"
	file:	%glayout-demo.r
	version:  0.9.1
	date:     2006-11-17
	purpose:  "Demonstration of GLayout's features and capabilities."
	library: [
		level:          'beginner
		platform:       'all
		type:           'demo
		domain:         [ gui ui user-interface vid graphics]
		tested-under:   [win view 1.3.2 sdk 2.6.2]
		support:        "http://www.pointillistic.com/open-REBOL/moa/steel/glayout/glayout-demo.html"
		license:        'MIT
		see-also: 		"glayout.r"
	]

]


no-do-quit: func [][
	request/ok "I QUIT!  ...^/   I needs some files from the net which where not downloaded."
	quit
]


;---------------------------------------------
; GET BASE FILES FOR TESTING END-USERS
;---------------------------------------------
if all [
	not value? 'slim
	not exists? %slim.r
][
	either request/confirm "SLiM not found. Download it from Rebol.org?" [
		either request/confirm join "it will be saved as: " to-local-file join clean-path what-dir "slim.r" [
			request-download/to http://www.rebol.org/cgi-bin/cgiwrap/rebol/download-a-script.r?script-name=slim.r  %slim.r
		][
			no-do-quit
		]
	][
		no-do-quit
	]
	
]


; start slim for the rest...
; if user installed a local copy of slim for this test
if exists? %slim.r [
	do %slim.r
]


; at this point slim is operational

unless slim/open 'glayout 0.5.4  [
	either confirm "GLayout not found or is not up to date. Download it from Rebol.org?"  [
		either request/confirm join "it will be saved as: " to-local-file join clean-path what-dir "glayout.r" [
			request-download/to http://www.rebol.org/cgi-bin/cgiwrap/rebol/download-a-script.r?script-name=glayout.r  %glayout.r
		][
			no-do-quit
		]
	][
		no-do-quit
	]
	
]

slim/vexpose
voff

unless slim/find-path %glayout.r [
	no-do-quit
]




;---------------------------------------------
; APPLICATION START
;---------------------------------------------
gl: slim/open 'glayout none

;- PANES
;-    default-pane
default-pane: gl/layout/pane [
	column [
		elastic
		header "welcome to GLayout Demo"
		vtext as-is  "This is a very simple overview of many of GLayout's capabilities"
		vtext as-is  "There will be more added as time permits, but at least, for now"
		vtext as-is  "you know a bit of what it can do out of the box."
		spacer 30
		vh3 "Select items in the menu to start your tour"
		spacer 15
		hitext "(Note that menu bug is now fixed  :-)"
		elastic
	]
]


;-    prefs-pane
prefs-pane: gl/layout/pane [
	column [
		row [
	 		vtext "Enables/disables GLayout's indented console printing"
	 		elastic
	 	]
		row [
			rvtext "verbosity: " min-size 100
			column [
				filler
				vpane [
					check false [either value [gl/von slim/von von][print "OFF" slim/voff gl/voff voff]]
				]
				filler
			]
			elastic
		]
		elastic
	]
]



;-    inspector-pane
inspector-pane: gl/layout/pane [
	scrollpane [
		column [
			spacer 15
			header "the GLayout inspector"
			spacer 15
			lvtext "The inspector is a requestor which allows you to scan and browse native rebol values"
			lvtext "It uses a Finder-type interface and allows you to go into objects and blocks"
			lvtext "there are still a few minor bugs, like hitting unset! values but, its already very usefull"
			lvtext "(browsing system/words will always crash it, so don't)"
			spacer 30
			vtext "take a test spin!"
			insp-fld: field "system/view"
			
			row [
				button corner 2 "system/view"[insp-fld/text: copy face/text show insp-fld]
				button corner 2 "system/script"[insp-fld/text: copy face/text show insp-fld]
				button corner 2 "slim" [insp-fld/text: copy face/text show insp-fld]
				button corner 2 "slim/libs/GLayout" [insp-fld/text: copy face/text show insp-fld]
			]
			spacer 15
			row [
				elastic
				button "inspect!" gold [try [do compose [gl/request-inspector/title (load insp-fld/text) (insp-fld/text)]]]
				elastic
			]
			elastic
		]
	]
]

;-    snapshot-pane
snapshot-pane: gl/layout/pane [
	scrollpane [
		column [
			spacer 15
			header "Integrated Gui snapshot, cropping and saving"
			spacer 15
			lvtext "GLayout helps you in making your docs."
			lvtext "You can snapshot any currently viewed window, live, by hitting Shift-F8"
			lvtext "You can also snapshot a face or pane, under the cursor, live, by hitting Ctlr-Shift-F8"
			lvtext "for now those keys are hard-coded, but this can be very easily changed, even by you."
			spacer 30
			header "Window Title"
			lvtext "Unless you pressed Ctrl, GLayout will ask you for a window title, which will be"
			lvtext "automatically added to the layout in the next step (cropping), to make it resemble"
			lvtext "a plain OS-independent window."
			spacer 30
			header "Cropping"
			lvtext "when the snapshot requestor appears, you are greeted with a resizeable window."
			lvtext "the portion of the image you actually see, is the portion which will be saved out!"
			lvtext "so with very simple resize, and scrolling of the gui, you can zero in on a part"
			lvtext "of the GUI or a specific gadget!"
			spacer 30
			header "Saving"
			lvtext {Once you press "save", a file browser will appear, allowing you to place a .png image}
			lvtext {anywhere on your disk.  A current limitation, is that you MUST add ".png" extension }
			lvtext {yourself, cause GLayouts won't.  You can only save in PNG format for now.}
			spacer 30
			
			header "go ahead, press Shift-F8"

			elastic
		]
	]
]


;-    reqs-pane
reqs-pane: gl/layout/pane [
	scrollpane [
		column [
			spacer 15
			vh3 "Prebuilt requestors"
			spacer 30
			
			vtext "Although adding your own requestors, popup and modal dialogs in glayout is dead easy"
			vtext "we have cooked up a few of them for you."
		]
	]
]


;-    labels-pane
;labels-pane: gl/layout/pane [
labels-pane:  [
	scrollpane [
		column [
			spacer 15
			vh3 "Label styles:"
			spacer 30
			
			banner "Banner"
			header "Header"
			vh3 "vh3"
			grp-text "grp-text"
			text "text"
			wtext "wtext"
			vtext "vtext"
			lvtext "lvtext"
			rvtext "rvtext"
			elastic
		]
	]
]



;-    buttons-pane
;buttons-pane: gl/layout/pane [
buttons-pane:  [
	scrollpane [
		column [
			spacer 15
			vh3 "Button styles:"
			spacer 30
			
			header left "button:"
			vtext "corner control:"
			row [
				button corner 12 "12" shrink
				button corner 9 "9" shrink
				button corner 5 "5" shrink
				button corner 4 "4" shrink
				button corner 3 "3" shrink
				button corner 2 "2" shrink
				button corner 1 "1" shrink
			]
			spacer 20
			vtext left "outline color control:"
			row [
				button "default"
				button gold "gold"
				button red "red"
				button blue "blue"
			]
			
			spacer 20
			vtext left "deep color control:"
			row [
				button gold deep "gold"
				button red deep "red"
				button blue deep "blue"
				button black deep "black"
			]
			
			spacer 20
			vtext left "mix and match:"
			row [
				button gold white "gold white"
				button red gold "red gold"
				button blue black "blue black"
				button black gray "black gray"
			]
			spacer 50
			
			header left "btn:"
			row [
				btn "btn"
				btn gold "btn gold"
				btn 200.200.200 "btn 200.200.200"
			]
			
			spacer 30
			elastic
		]
	]
]


;-    popups-pane
;popups-pane: gl/layout/pane [
popups-pane: [
	scrollpane [
		column [
			spacer 15
			vh3 "Popup styles"
			header left "Drop-down menus" 
			hform [
				menu-choice "Menu-choice 1" ["one" "two" separator "three" "four" ["submenu" "AAA" "BBB" "CCC"]] [gl/inform join "Selected: " data]
				menu-choice "Menu-choice 2" ["one" "two" separator "three" "four" ["submenu" "AAA" "BBB" "CCC"]] [gl/inform join "Selected: " data]
				menu-choice "Menu-choice 3" ["one" "two" separator "three" "four" ["submenu" "AAA" "BBB" "CCC"]] [gl/inform join "Selected: " data]
				menu-choice "Menu-choice 4" ["one" "two" separator "three" "four" ["submenu" "AAA" "BBB" "CCC"]] [gl/inform join "Selected: " data]
			]
			spacer 30
			header left "choice" 
			vtext "just choose the top choices, to see compound effects on bottom choice:"
			row [
				choice "Color: " ["white" "gold" "red" "blue" "green" "black" ] font []  [
					face/color: do load data
					face/refresh
					pop-chc/color: face/color
					pop-chc/refresh
				]
				choice "Font: " ["white" "gold" "red" "blue" "green" "black" ] font []  [
					face/font/color: do load data
					face/refresh
					pop-chc/font/color: face/font/color
					pop-chc/refresh
				]
				choice "Outline: " ["white" "gold" "red" "blue" "green" "black"] font [] corner 10 with [outline: white] [
					face/outline: do load data
					face/refresh
					pop-chc/outline: face/outline
					pop-chc/refresh
				]
			]
			pop-chc: choice font [] "result: " ["looks good" "I like it :-)" "GLayout?"] [gl/inform data]
			elastic
		]
	]
]


;-    toggles-pane
;toggles-pane: gl/layout/pane [
toggles-pane:  [
	scrollpane [
		column [	
			spacer 15
			vh3 "Toggle styles"
			spacer 30
			header left "toggle text"
			vpane [
				cl: vblack [
					toggletext "one"
					tgl: toggletext "two"
					toggletext "three"
				]
			]
			spacer 10
			header left "Check marks"
			row [
				
					vtext right "check 1"
					center [check ] 
				
					vtext right "check 2" shrink
					center [check true ] 
					
				;row [
					vtext right "check 3 (in a pane)" 
					;column [filler vpane [check]  filler]
					center[hpane [check edge [size: 1x1]]]
					filler
				;]
			]
			elastic
		]
	]
]
			


;-    field-pane
;field-pane: gl/layout/pane [
field-pane:  [
	scrollpane [
		column [	
			spacer 15
			vh3 "Field styles"
			spacer 30
			header left "fields"
			field "field"
			spacer 10
			field blue "blue field"
			spacer 10
			vtext left "corner control:"
			row [
				field 30 corner 10 "10"
				field 30 corner 5 "5"
				field 30 corner 2 "2"
				field 30 corner 1 "1"
			]
			vtext {Field with input filter (america phone number: ###-###-####)}
			tel-fld: field 
			spacer 30
			header left "text area"
			text-area def-size 200x100 "Text-area"
			elastic
		]
	]
]


;-    groups-pane
;groups-pane: gl/layout/pane [
groups-pane:  [
	scrollpane [
		row [
			column [
				spacer 15
				vh3 "Group styles:"
				spacer 30
				row [header def-size 100 "center (new!)" lvtext elx "Centers content." ]
				vtext left "Inner-margins support for stretchy content (here its 100x10)"
				center margins 100x10 edge gl/black-edge [
					column [
						field
						row [
							button "1" button "2" button "3"
						]
					]
				]
				vtext left "Centers static content. (still offers margins)"
				center margins 100x10 edge gl/black-edge [
					canvas "100x100 canvas" edge gl/red-edge 100x100
				]
				spacer 20
				
				row [header def-size 100 "row" lvtext elx "borderless horizontal group:" ]
				row [button "1" button "2" button "3"]
				spacer 20
				
				row [header def-size 100 "column" lvtext elx "borderless vertical group:" ]
				column [ button "1" button "2" button "3"]
				spacer 20
				
				
				row [header def-size 100 "hpane" lvtext elx "inset horizontal group:" ]
				hpane [ button corner 2 "1" button corner 2 "2" button corner 2 "3"]
				spacer 20
				
				row [header def-size 100 "vpane" lvtext elx "inset vertical group:" ]
				vpane [ button corner 2 "1" button corner 2 "2" button corner 2 "3"]
				spacer 20
				
				
				row [header def-size 100 "hform" lvtext elx "outset horizontal group:" ]
				hform [ button corner 2 "1" button corner 2 "2" button corner 2 "3"]
				spacer 20
				
				row [header def-size 100 "vform" lvtext elx "outset vertical group:" ]
				vform [ button corner 2 "1" button corner 2 "2" button corner 2 "3"]
				spacer 20
				
				
				
				row [header def-size 100 "hblack" lvtext elx "horizontal black-edged group:" ]
				hblack [ button corner 2 "1" button corner 2 "2" button corner 2 "3"]
				spacer 20
				
				row [header def-size 100 "vblack" lvtext elx "vertical black-edged group:" ]
				vblack [ button corner 2 "1" button corner 2 "2" button corner 2 "3"]
				spacer 20
				
				row [header def-size 100 "nesting" lvtext elx "All groups can be nested indefinitely:" ]
				vpane [
					banner "horizontal:"
					hform [
						vpane [
							banner "vertical:"
							button "1" corner 2
							button "2" corner 2
							button "3" corner 2
						]
						vpane [
							banner "vertical:"
							hpane [
								banner "horizontal:"
								button "1" hshrink corner 2
								button "2" hshrink corner 2
								button "3" hshrink corner 2
							]
							hpane [
								banner "horizontal:"
								button "1" hshrink corner 2
								button "2" hshrink corner 2
								button "3" hshrink corner 2
							]
						]
					]
				]
				spacer 20
				
				
				row [header def-size 100 "scrollpane" lvtext elx "automatic scrollable container:" ]
				scrollpane def-size 100x100[
					row [
						column [
							button "1"
							button "2"
							button "3"
							button "5"
							button "6"
							elastic
						]
						column [
							button "1"
							button "2"
							button "3"
							button "5"
							button "6"
							elastic
						]
						column [
							vtext "Use mouse scrollwheel to scroll this scrollgroup"
							vtext "Advanced algorythm, adapts scroll speed to content vs viewable"
							hitext "Adjust X window size and scrollbars will disapear"
							vtext "No default edges allow you to easily control visuals to what you need."
							hitext "Note how scrollwheel support works even if panes are nested"
							hitext "(the group styles viewer is within a scrollpane)"
							vtext "note how resizing the window keeps scroller's position as much it can"
							hitext "shift-clicking while using scrollwheel will nudge one pixel at a time"
							vtext "Note that even due to the amount of graphic heavy gadgets in this group "
							vtext "(draw using buttons) the scrolling is real time"
							elastic
						]

						column [
							button "1"
							button "2"
							button "3"
							button "5"
							button "6"
							elastic
						]
						column [
							button "1"
							button "2"
							button "3"
							button "5"
							button "6"
							elastic
						]
					]
				]
				spacer 20
				
				elastic
				
			]
			spacer 15 
		]
	]
]






;-    others-pane
;others-pane: gl/layout/pane [
others-pane: [
	scrollpane [
		column [
			spacer 15
			vh3 "Other styles:"
			spacer 20
			row [
				spacer 15
				column [
					row [
						header "scroller" elastic
					]
					row [
						scroller
					]
					vtext "with a little VID styling:"
					hpane [
						scroller edge [color: black]
					]
					spacer 30
					row [
						header "progress" elastic
					]
					progress with [data: 0.33 rate: 2]
						feel [
							engage: func [
								face action event
							][
								if action = 'time [
									face/data: face/data + 0.01
									if face/data > 1 [face/data: 0]
									show face
								]
							]
						]
					
					
					spacer 30
					row [
						header "filebox" elastic
					]
					fbx-path: lvtext to-string clean-path what-dir
					hpane [ vblack [
						fbx-scroll: scrollpane def-size 200x200 [
							column [	
								fbx: filebox browse-path what-dir
								do [
									fbx/browse-callback: func [fb-pane][
										vin "browse-callback()"
										fbx-scroll/refresh
										fbx-path/text: rejoin [to-string clean-path fbx/current-dir]
										show fbx-path
										vout
									]
								]
							]
						]
					]]
					row [
						button "root" [fbx/browse-path/update %/]
						button "up" [fbx/browse-path/update 'parent]
					]
					
					spacer 20
					
				]
				
				spacer 15
			]
		]
		;elastic
	]
]

styles-list:  ["labels" "buttons" "fields" "toggles" "groups" "popups" "others"]


;-    styles-pane

style-panes: [
	"labels" [labels-pane]
	"buttons" [buttons-pane]
	"fields"  [field-pane]
	"toggles" [toggles-pane]
	"groups" [groups-pane]
	"popups" [popups-pane]
	"others" [others-pane]
]

style-panes: reduce [
	"labels"  labels-pane
	"buttons" buttons-pane
	"fields"  field-pane
	"toggles" toggles-pane
	"groups"  groups-pane
	"popups"  popups-pane
	"others"  others-pane
]


styles-pane: gl/layout/pane [
	;row [
		;button hshrink deep gold corner 2 "<" [ gui-pane-choice/select slide-gadget-pane/prev ]
		;button hshrink deep gold corner 2 ">" [gui-pane-choice/select slide-gadget-pane/next ]
		;gui-pane-choice: choice elx min-size 150 "Pane: " styles-list [switch-gadget-pane data]
		
		
	;]
		stylespad: switchpad style-panes corner 4
	;spacer 5
	;pane-types: column def-size 500x200 [elastic]
]

gl/assign-key-event-callback tel-fld  [
		face
		event
][
	;prin event/key
	idx: index? system/view/caret
	new-string: head insert at copy face/text idx event/key
	
	digit: charset [#"0" - #"9" #"#"]
	threes: [ 1 3 digit ]
	fours: [1 4 digit ]
	
	parse-rule: [
	    ; (###)###-#### 
	    [ "(" 0 1 [ threes 0 1 [")"  0 1 [threes 0 1 ["-" 0 1 fours ]]]]] |
	    ; ###-###-#### 
	    [ threes "-" threes "-" 0 1 fours] |
	    ; ###-#### 
	    [threes "-" 0 1 fours] | 
	    ; ###
	    [ threes] ; just simplifies above rules...
	]
	if any [
		ignore: (either (error? err: try [ result: parse/all new-string [parse-rule]]) [
			rule-area/colors: reduce [black black]
			rule-area/font: make face/font [color: white]
			show rule-area
			false
		][
			result
		])
		ignore: found? find [#"^M" #"^-" up down left right home end #"^~" #"^H"] event/key
		event/key = #"^["
	][
		unless ignore [
			unfocus face
		]
	]
	not ignore
]


cl/select tgl
show cl



;-  
;- GUI funcs

;--------------------
;-    req-demos()
;--------------------
req-demos: func [
	""
	type [string!]
][
	vin/tags ["req-demos()"] [req-demos]
	switch type [
		"confirm" [
			gl/request-confirm/title/buttons/auto-enter "This is a request-confirm type modal dialog." ["ok" "not ok" "doh!"] "not ok"
			gl/request-confirm/title/label/buttons/auto-enter "title has its own refinement!" "You can edit all text, auto enter button, and buttons"  ["not" "don't" "no" "never" "cancel" "escape"] "not"
		]
		"inform" [gl/inform "Inform: ultra basic modal dialog"]
		"file..."	[val: gl/request-file/title/path "select file:" "select-file:" %/ gl/inform rejoin ["selected: " val]]
		"text" [gl/request-text/auto-enter "enter some text:"]
		"error" [gl/request-error/help "your error title" "001" "Error description which can span multiple lines^/^/The help button below, is an option you can specify ^/to which you assign an action, which is run when the button is pressed.^/Using browse to open your tool's online docs or opening a help pane, for example." "ok label"  [browse http://www.pointillistic.com/open-REBOL/moa/steel/]]
	]
	
	vout/tags [req-demos]
]

;--------------------
;-    switch-toolbox()
;--------------------
switch-toolbox: func [
	tool [string! none!]
][
	vin/tags ["switch-toolbox()"] [switch-toolbox]
	
	toolbox/pane: switch/default tool [
		"gadget types" [styles-pane]
		"popups" [popups-pane]
		"prefs"  [prefs-pane]
		"gui snapshots" [snapshot-pane]
		"inspector" [inspector-pane]
	][
		default-pane
	]
	
	gui/refresh
	vout/tags [switch-toolbox]
]


;--------------------
;-    slide-gadget-pane()
;--------------------
slide-gadget-pane: func [
	""
	/next
	/prev
	/local pane
][
	vin/tags ["slide-gadget-pane()"] [slide-gadget-pane]
	pane: gui-pane-choice/value
	if none? pane [
		pane: skip tail style-panes -2
	]
	
	
	if any [prev next ][
		if pane: find style-panes pane [
			if next [
				pane: skip pane 2
				if tail? pane [
					pane: head pane
				]
			]
			if prev [
				if head? pane [
					pane: tail pane
				]
				pane: skip pane -2
			]
		]
	]
	if block? pane [
		pane: pick pane 1
	]	
	vout/tags [slide-gadget-pane]
	pane
]


;--------------------
;-    switch-gadget-pane()
;--------------------
switch-gadget-pane: func [
	""
	pane [string! none! word!]
	/local panes prev next
][
	vin/tags ["switch-gadget-pane()"] [switch-gadget-pane]
	
	

	vprobe pane
	stylespad/select pane
	;pane-types/pane: switch pane style-panes 
	;gui/refresh
	vout/tags [switch-gadget-pane]
]

;--------------------
;-    next-style-pane()
;--------------------
next-style-pane: func [
	""
][
	vin/tags ["next-style-pane()"] [next-style-pane]
	vprint gui-pane-choice/value
	
	vout/tags [next-style-pane]
]

;--------------------
;-    menu-handler()
;--------------------
menu-handler: func [
	""
	selection
	/local pane val
][
	vin/tags ["menu-handler()"] [menu-handler]
	selection: next parse/all selection "/"
	
	vprobe remold ["Selected: " selection]
	;probe selection

	switch selection/1 [
		"features" [
			switch selection/2 [
				"requestors" [
					req-demos selection/3
				]
				"inspector" [
					switch-toolbox "inspector"
				]
				"gadget types" [
					switch-toolbox "gadget types"
				]
				"Gui snapshots" [
					switch-toolbox "gui snapshots"
				]
			]
		]
		"styles" [
			switch-toolbox "Gadget Types"
			stylespad/select selection/2
		]
		"help" [
			switch selection/2 [
;				"pane" [	
;					vprint "I WILL SWITCH PANE!"
;					;switch-toolbox selection/3
;					gui-pane-choice/select selection/3
;				]
				"prefs" [
					switch-toolbox "prefs"
				]
				"splash screen" [
					switch-toolbox none
				]
				
				"about..." [
					gl/view/modal/center [
						column [
							header "about..."
							vpane [
								vblack [
									lvtext rejoin ["GLayout version: " gl/header/version]
									lvtext rejoin ["Demo version: " system/script/header/version]
									hitext para [wrap?: true] "Note that this window is modal, just like a dialog"
									hitext para [wrap?: true] "This allows you to easily make your own dialogs, using"
									hitext para [wrap?: true] "the same GLayout dialect, only add /modal to the 'view call."
									vtext para [wrap?: true] "Also note that this modal window is resizable"
								]
							]
							elastic
							
							spacer 10
							row [
								elastic 
								button "close" [hide-popup]
								elastic
							]
							spacer 10
						]
					]
				]
			]
		]
		
	]
	vout/tags [menu-handler]
]








;-  
;- MAIN GUI

gui: gl/view/center compose/deep [
	column [
		hform gray effect [gradient 0x1 (gray * 1.4) (gray * 1.15) ] [
			project-menu: menu-choice effect [gradient 0x1 (gray * 1.4) (gray * 1.15) ] "Features" [["Requestors" "confirm" "inform" "file..." "text" "error" ] "GUI snapshots" "Inspector"] [menu-handler data]
			menu-choice "styles" [ (styles-list) ][menu-handler data]
			edit-menu: menu-choice "help" [ "about..." "splash screen" separator "prefs" ][menu-handler data]
			;pane-menu: menu-choice "Panes" styles-list
			elastic [color: none]
		]

		spacer 5
		row [
			spacer 5 
			;vpane [ 
				;vblack [
					toolbox: column def-size 550x300 []
			;	]
		;	]
			spacer 5 
		]
		spacer 5
		row [
;			vtext "Take the tour"
;			hpane [
;				button hshrink corner 2 "<"
;				button hshrink corner 2 ">"
;			]
;			vtext hshrink "next: "
;			hitext hshrink left "styles"
			elastic
			hpane [
				button corner 2 "Quit" [quit]
			]
			spacer 20
		]
		spacer 5
	]
	
]

;switch-toolbox "Gadget Types"
switch-toolbox none
;gui/refresh
; styles-pane/pane/1/refresh

do-events

