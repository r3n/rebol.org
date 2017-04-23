rebol [
	; -- basic rebol header --
	file:       %glayout.r
	version:    0.5.4
	date:       2006-11-17
	title:      "glayout - GLASS-based layout engine"
	author:     "Maxim Olivier-Adlhoch"
	copyright:  "(c)2004-2006, Maxim Olivier-Adlhoch"

	;-- slim parameters --
	slim-name:  'glayout
	slim-requires: [package [view 1.2.1 link 1.0.2 ViewDLL 1.2.47] ]
	slim-id: 0
	slim-prefix: 'gl
	slim-version: 0.9.4

	; -- extended rebol header --
	purpose:    "replace vid dialect layout while keeping its basic featureset"
	notes:      "You need to install slim to use this library (get it at www.rebol.org).   IMPORTANT, this toolkit patches some things direcly in the system words, to fix/change RT code."
	web:        http://www.rebol.org/cgi-bin/cgiwrap/rebol/view-script.r?script=glayout.r
	e-mail:     "m o l i a d -- a e i -- c a" ; remove spaces, fill in @ and .
	original-author: "Maxim Olivier-Adlhoch"


	library: [
		level:          'intermediate
		platform:       'all
		type:           [ dialect module ]
		domain:         [ external-library extension gui ui user-interface vid]
		tested-under:   [win view 1.3.2 sdk 2.6.2]
		support:        "same as author"
		license:        'MIT
	]

	;- HISTORY \
	history: {
		v0.0.1 - 2004-03-01
			-basic layout tests started
			-group style
			-button style
			-text and related styles
			-elasticity working

		v0.1.0 - 2004-03-08
			-first working alpha
			-fully integrated to rebol package downloader
			-elasticity and stretching finally debuged
			-scroller style
			-vpane, hpane, vform, hform, box styles

		v0.1.1 - 2004-03-05
			-filler style
			-spacer style
			added some words into vid layout dialect, namely: def-size, min-size,

		v0.1.3 - 2004-03-08
			-started working on scrolling pane style

		v0.1.5 - 2004-03-11
			-now a slim library
			-started clean up
			-started file requester

		v0.2.0 - 2004-03-18
			-fully cleaned up (now using mkspec)

		v0.2.1 - 2004-03-21
			-heavy work done on file requester,
			-actual browsing capabilities in filebox-sizing spec
			-added static-size support for groups...

		v0.2.2 - 2004-03-23
			-debuging strange vid issues (font coloring, vid init in dialect)
			-implementation of browse callback in file req.
			-added word! support to browse-path, which allows ingenious navigation like 'parent

		v0.2.3 - 2004-03-24
			-fixed scrollbar resizing when panes change sizes (content or pane box itself).
			-included Romano Paolo Tenca's modal window path v1.0.4

		v0.3.0 - 2004-03-28
			-fixed initial parent-face issue.  now groups must set parent face in calc-faces
			-added MODAL mode to view which allows modal windows.
			-added request-text modal requester
			-abort-request is now modal
			-fixed last bug in layout algorythm
			-filler now only fills stretch area
			-new elastic style replaces previous filler style

		v0.3.1 - 2004-03-29
			-fixed view problem with initial size, where windows would pop up and then slide
			 to their real place.

		v0.3.2 - 2004-04-01
			-file requestor now fully functional (rename, new dir and delete function on files and dirs).
			-changed feel handling of file requester to allow more granular reuse of code.
			  each action type now translates into a function and a sparkle function added to cause visual
			  refresh when state changes.
			-added /title refinement to view

		v0.3.3 - 2004-04-05
			-added the check (checkbox) style into glayout. it is a fixed-size gadget, so change its size by using static-size

		v0.3.4 - 2004-04-07
			-finally fixed some of the scrollpane's scroll bar issues. the main being that
			 when scroll bars appeared, the viewable size did not adjust.  this meant that
			 an amount of content equal to the scroller widths, would be out of bounds and unviewable.
			 Now, when a scrollbar appears, the pane review sizes and scroller ranges adjust
			 to compensate for the scroller eating up a little interior space.
			-the filebox now also forces a complete filebox refresh when a rename occurs, this is to
			 force the pane and scrollbars to reset themselves according to the new name width, adjusting/
			 addind/removing scrollbars as needed.

		v0.3.5 - 2004-04-08
			-fixed ongoing issue about resizing window and layout not resizing.


		v0.3.6 - 2004-04-27
			-fixed minor issue in filereq where viewer would not refresh after a file delete.

		v0.3.7 - 2004-07-03
			-finishing pane style so that it adds scrollers by itself...
			-fixed deep issue about mkspec placing group-specific values AFTER user specified blk, causing user overides to be ignored...
			-replaced pane style name by scrollpane.  making it clear that it adds scrollbars when needed.
			-added pre-layout()  to group faces. It lets you edit any supplied layout block before actually building it. This
			 allows groups to enforce or validate a layout (like the scrollpane which adds the scrollers)
			-added post-layout() to group faces.  It allows you to edit the face structure or initialise internal data based
			 on contents of groups, like the scrollpane which setups its scrollers to point to the content...

		v0.3.8 - 2004-07-25
			-added static-resize mode to groups.  This allows them to be sized normally, but without reacting to
			 further events... will allow sizing bars much more easily.
			-changed the filereq method name to request-file... to make it more consistent.
			-added static-size keyword to basic layout extension.
			-set text-area default edge to [ibevel 2x2]
			-added ui snapshot system. press CTRL + SHIFT + i to snaphot , CTRL + SHIFT + o to save (opens a file requestor)
			 this works in ALL UIS even ones which have mouse activity and pop-ups

		v0.3.8.1 - 2004-07-31
			-added progress style.
			-progress style now has smart auto label option (in %)

		v0.3.8.2 - 2004-08-05
			-added set-value to scroller style... setting this to something between 0 and 1 will :
				* sets face/data
				* refresh the scroller
				* call its action
			-reflect-value to scroller style...

		v0.3.8.3 - 2004-08-13
			-start of work on table style
			-added code-area style added it is not a permanent style...

		v0.3.8.4 - 2004-08-21
			-added region object which handles nifty region comparisons.

		v0.4.1   - 2006-03-13
			- fixed for view 1.3.2
			- added frame class (explorer)

		v0.4.2   - 2006-03-20
			- fixed popup management for view 1.3.2.  glayout now supports only view 1.3.2 (it might work on older versions but is not tested)
			- added popup-menu function
			- added popup-menu on frame class (frame)
			- added support for no-title on popups allows borderless popups
			- added menu-item class
			- added popup-face class
			- added choice style which uses the pop up menu.

		v0.4.2.1 - 2006-03-28
			- fixed popup resizing (window feel etc)

		v0.4.2.2 - 2006-04-07
			- fixed popup closing which would disable complete event queue

		v0.4.3 - 2006-07-11
			- added new no update option to choice gadgets, which prevents their selection from being displayed in the button.
			- added safe mode to modal glview function which prevents a popup's edges in all directions from going outside visible screen area!
			  this means popup menus now slide within view when they are too high or wide.  yeah!

		v0.4.5 - 25-Aug-2006/18:00:47 (MOA)
			- Added inspector requester, which allows us to browse rebol data through a finder type browser.

		v0.4.6 - 5-Sep-2006/11:31:31 (MOA)
			-menu-items for choice do not wrap anymore
			-new menu-choice gadget style to simulate usual menu bars.
			-added canvas widget, a static-size box
			-improved static-sizing, so it resizes if you change the static-size
			-suppling a pair to the static-sizing, will specify the static-size by default.

		v0.4.7 - 11-Sep-2006/10:47:13 (MOA)
			-added support for changes facet of faces within scrollpane. scrolling is now REAL TIME !

		v0.4.8 - 12-Sep-2006/4:06:48 (MOA)
			-field/area input handling hook management now part of default glayout install use assign-key-event-callback func to assign a callback to the input handling like so:  gl/assign-key-event-callback my-field-face [face event][ ; your call back func body! which returns true or false to indicate if you consumed the event]

		v0.4.9 - 12-Sep-2006/6:26:56 (MOA)
			-lookdev of new button style

		v0.4.10 - 15-Sep-2006/0:27:25 (MOA)
			-clean up of unused glayout code. all code stored in bump.r backups, so can come back to it later. (removed 20k of code!)

		v0.4.11 - 21-Sep-2006/17:31:47 (MOA)
			-added top-face function
			-added support for scroll-wheel automatically in all scrollpanes
			-fixed little event-related issue when closing windows!

		v0.4.12 - 21-Sep-2006/17:43:45 (MOA)
			-pre release round of code cleanup, removed more than 20k!  total reduction is now ~43k (from 162kb down to 119kb) ! with no usable difference in features or added bug.

		v0.4.13 - 22-Sep-2006/1:08:51 (MOA)
			-added make-face wrapper within glayout
			-improved modal window edge detection... added 20 pixels to bottom to counter start bar of most desktops

		v0.4.14 - 22-Sep-2006/6:49:45 (MOA)
			-removed nagging print statement when saving out screen-grabs.
			-rebuilt the window snapshot, so that we can now clip the view before saving!
			-added fine control to scroll-wheel (shift scrolling does so by 1px amounts)
			-replaced window snapshot layout so we don't need external images anymore.
			-fixed long-standing issue where adding elastics would consume 10x10 pixels for nothing... all the time!

		v0.4.15 - 26-Sep-2006/2:07:15 (MOA)
			-added capacity to snapshot a single face (whatever is under cursor). Putting cursor over a pane will snapshot that pane (and contents).


		v0.4.16 - 27-Sep-2006/22:54:16 (MOA)
			-added auto-enter hotkey support to request-confirm
			-added inform request


		v0.4.17 - 24-Oct-2006/21:46:12 (MOA)


		v0.4.18 - 24-Oct-2006/21:50:51 (MOA)
			-finished pulldown menuing style with sub menus and fully automatic sub menu poping and closing without clicks. 

		v0.4.19 - 31-Oct-2006/13:48:23 (MOA)
			-MANY little issues fixed, in many areas of GLayout.  
			-This is a big release.

		v0.5.0 - 31-Oct-2006/13:52:20 (MOA)
			-LICENSE CHANGE TO MIT (totally free)
			-simple version stamp, release

		v0.5.1 - 31-Oct-2006/15:32:57 (MOA)
			-removed an unwanted probe statement

		v0.5.2 - 2-Nov-2006/1:58:51 (MOA)
			-fixed little VID incompatibilities in low-level wake-event fixes

		v0.5.3 - 16-Nov-2006/23:50:10 (MOA)
			-fixed popup menues which would close one more popup than needed.  I now use the /type arg of hide-popup.
			-added switch pad (tab-pane style)
			-automatic popup menus on buttons
			-added popup on switchpad so we can select panes even if there are more choices than is visible in gui.
			-adds 'CENTER sizing and CENTER group so we can now easily center statically sizing objects!
			-adds margins as a default facet, not all support it, but its now so easy to access...
			-implement margins in center
			-fixed shrinking now fully supported in x y and xy modes.
			-added two color spec for button
			-added corner support in dialect for fields
			-fixed field rendering when corners are round

		v0.5.4 - 17-Nov-2006/0:00:32 (MOA)
			-button popups now mouse relative, instead of face relative

	
}
	;- HISTORY /


	license:    {Copyright (c) 2004-2006, Maxim Olivier-Adlhoch

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



;- SLIM/REGISTER
slim/register [
	*gl: self
	view*: system/view
	make-face*: get in system/words 'make-face
	vid-view: get in system/words 'view
	layout*: get in system/words 'layout
	face*: face
	focus*: none
	key-focus-action: none	; set this to a func so that key events get passed through a hot-key type filter.
							; return true if you used the event, false otherwise.

	popup-windows: [] ; we will store popups here

	; images loaded from disk to use as edges when saving out shapshots.
	snapshot-windows-title:       none
	snapshot-windows-bottom-edge: none
	snapshot-windows-left-edge:   none
	snapshot-windows-right-edge:  none

	glayout-ui-clipboard: none ; acts as a pointer to a ui which you want to freeze.  use CTRL-SHIFT + i to grab and CTRL-SHIFT + o to save out.


	;-
	;- GLAYOUT/--init--
	--init--: does [
		focus*: :focus
		focus: func [face /no-show ][
			if function? :key-focus-action [
				key-focus-action: none
			]
			either no-show [
				focus*/no-show face
			][
				focus* face
			]
		]

		;- find snapshot window images?
		if file? rsrc-path [
			either exists? append copy rsrc-path %snapshot-windows-title.png [
				vprint "THERE ARE BORDERIZE ICONS"
				snapshot-windows-title:       load/resource %snapshot-windows-title.png
				snapshot-windows-bottom-edge: load/resource %snapshot-windows-bottom-edge.png
				snapshot-windows-left-edge:   load/resource %snapshot-windows-left-edge.png
				snapshot-windows-right-edge:  load/resource %snapshot-windows-right-edge.png
			][
				vprint "THERE ARE NO BORDERIZE ICONS"

			]
		]

		sleep-event: false ; test to fix the show-popup bug.

		;-    win-offset?
		system/words/win-offset?: func [
			{Given any face, returns its window offset. Patched by Ana}
			face [object!]
			/window-edge
			/x
			/y
			/local xy
		][
			xy: 0x0
			if face/parent-face [
				xy: face/offset
				while [face: face/parent-face][
					either face/parent-face [
						xy: xy + face/offset + either face/edge [face/edge/size][0]
					][
						if window-edge [xy: xy + either face/edge [face/edge/size][0]]
					]
				]
			]
			any [
				all [x xy/x]
				all [y xy/y]
				xy
			]
		]


		;-    screen-offset?
		system/words/screen-offset?: func [
			{Given any face, returns its screen absolute offset. Patched by Ana}
			face [object!]
			/local xy
		][
			xy: face/offset
			while [face: face/parent-face][
				xy: xy + face/offset + either face/edge [face/edge/size][0]
			]
			xy
		]




;		;-  *  wake-event
		view*/wake-event: func[port /local event no-btn face consumed?] bind [
			event: pick port 1
			if none? event [
				if debug [print "Event port awoke, but no event was present."]
				return false
			]



			if event/type = 'key [
				if function? :key-focus-action [
					; if gl-event-func used up the event, we shouldn't continue
					consumed?: key-focus-action event/face event
				]
				unless consumed? [
					if event/shift [
						if event/key = 'f8 [
							vprint "UI grabbed in glayout snapshot buffer"
							either event/control [
								glayout-ui-clipboard: borderize-image/no-window to-image top-face event/face event/face/last-moved
							][
								glayout-ui-clipboard: borderize-image to-image find-window event/face
							]
							if glayout-ui-clipboard [
								clipfile: request-file/title "save grabbed ui in png format" "save"
								if file? clipfile [
									save/png clipfile glayout-ui-clipboard
									glayout-ui-clipboard: none ; free memory !
									vprint "Saved ui snapshot"
								]
							]
						]
					]
				]
			]

			if event/type = 'move [
				face: event/face ; necessary cause event is an event! datatype, not an object!
				if all [
					face 
					in face 'last-moved
				][
					face/last-moved: event/offset
				]
			]

			if event/type = 'scroll-line [
				face: event/face
				if in face 'last-moved [
					face: top-face/type event/face event/face/last-moved 'scrollpane
					; find the top-most scroller!
					if face [
						either event/shift [
							face/vscroll/pixels either event/offset/y > 0 [1][-1]
	
						][
							; do not scroll more than visible portion  (or you risk getting a division by 0 error)
							face/vscroll/by  min max (-0.95 * face/v-scroller/scale) (0.05 * event/offset/y) (face/v-scroller/scale * .95)
						]
					]
				]
			]


			either pop-face [
				either event/type = 'resize [
					do event
					false
				][
					either same? event/face pop-face [
						do event
					][
						if all [
							in pop-face 'auto-close
							pop-face/auto-close = true
							find [down alt-down] event/type
						][
							hide-popup
						]
					]

					if sleep-event [
						sleep-event: false
						pop-face: pick pop-list length? pop-list
						return true
					]

					false
				]
			] [
				do event
				empty? screen-face/pane
			]
		] in view* 'self


		;-    show-popup
		system/words/show-popup: func[
			face [object!]
			/options opt
			/window window-face [object!]
			/away
			/local no-btn feelname
		] bind [
			if find pop-list face [
				print "ERROR: TRYING TO POPUP THE SAME FACE TWICE!"
				return
			]

			window: either window [feelname: copy "popface-feel-win" window-face] [
				feelname: copy "popface-feel"
				face/options: any [face/options opt copy []]
				if not find face/options 'parent [
					repend face/options ['parent none]
				]
				system/view/screen-face
			]
			if any [face/feel = system/words/face/feel face/feel = window-feel] [
				no-btn: false
				if block? get in face 'pane [
					no-btn: foreach item face/pane [if get in item 'action [break/return false] true]
				]
				if away [append feelname "-away"]
				if no-btn [append feelname "-nobtn"]
			]
			insert tail pop-list pop-face: face
			append window/pane face
			show window
		]  in view* 'self



		;-    hide-popup
		system/words/hide-popup: func [
			/timeout
			/type tp "use this to prevent closing unrelated popups (used for popmenus)"
			/local win-face 
		] bind [
			win-face: last pop-list
			if any [
				not type
				tp = win-face/type ; normal vid use should never reach this line, so we need not verify /type existence.
			][
				remove back tail pop-list
				if pop-face [
					win-face: any [pop-face/parent-face system/view/screen-face]
					remove find win-face/pane pop-face
					;tells current wake-event to die
					sleep-event: true
		
					show win-face
				]
				if timeout [pop-face: pick pop-list length? pop-list]
			]
		] in view* 'self


		true
	];




	;-
	;- VARIOUS FUNCTIONS
	;-------------------------------------


	;--------------------
	;-     no-over()
	;--------------------
	no-over: func [
		"clear the all-over option for window related to face"
		face [object!]
	][
		face: find-window face
		if face: find face/options 'all-over [
			remove face
		]
	]


	;--------------------
	;-     all-over()
	;--------------------
	all-over: func [
		"set the all-over option for window related to face"
		face [object!]
	][
		face: find-window face
		unless find face/options 'all-over [
			append face/options 'all-over
			probe sort first face
			probe face/gl-class
			show face
		]
	]


	;--------------------
	;-     top-face()
	;--------------------
	top-face: func [
		face [object!] "starting face for test"
		point [pair!] "point to verify"
		/type tp [word!] "top-most gl-class of this type"
		/local lcl-face i rval
	][
		rval: either within? point win-offset? face face/size [
			any [
				either none? face/pane [
					face
				][
					i: 1
					while [
						all [
							block? face/pane
							(i <= length? face/pane)
							(none? lcl-face: top-face face/pane/:i point )
						]
					][
						i: i + 1
					]
					any [lcl-face face]
				]
				face
			]
		][
			none
		]
		if all [type rval][
			face: rval ; this is the very top most face under point.
			until [
				any [
					rval: all [
						in face 'gl-class ; must at least be a glayout widget (not just a component face)
						face/gl-class = tp
						face
					]
					( face: face/parent-face
					none? face) ; exit when we have reached window
				]
			]
		]
		unless object? rval [
			rval: none
		]
		rval
	]


	;--------------------
	;-     screen-size()
	;--------------------
	screen-size: func [
		"returns accessible desktop screen size"
		/y
		/x
	][
		either x [
			system/view/screen-face/size/x
		][
			either y [
				system/view/screen-face/size/y
			][
				system/view/screen-face/size
			]
		]
	]

	;----------------------
	;-     popup-face()
	;----------------------
	popup-face: func [
		face
		/options opt
	][
		unless find view*/screen-face/pane face [
			append popup-windows face
			append view*/screen-face/pane face
			show view*/screen-face
			append view*/pop-list face
			do-events
		]

	]


	;-     popup-menu()
	popup-menu: func [
		face [object! pair!]
		choices
		/submenu
		/local ctx subtext off
	][
		;print "POPUP MENU!!!!!!!!"
		unless empty? choices [

			ctx: context copy/deep [
				gblk: copy []
				selection: none
				close-method: copy []
				foreach item choices [
					switch type?/word item [
						string! [
							append gblk compose[
								menu-item (to-string item) [selection: face/text hide-popup/type 'popmenu] with [cls-method: close-method]
							]
						]
						
						block! [
							append gblk  compose/deep [
								menu-item ( to-string first item) with [choices: (reduce [next item]) cls-method: close-method] ;[selection: face/text hide-popup]
							]
						]
						
						word! [
							switch item [
								separator [
									append gblk [box menu-item-bg with [ cls-method: close-method gl-layout: func [size /local start end][self/size: start: end: size start/x: 2 end/x: size/x - 2 start/y: end/y: size/y / 2 self/effect: compose/deep [draw [pen (menu-item-bg - 40.40.40) line (start) (end) pen white line (start + 0x1) (end + 0x1)]] stretch: 1x0]]]
									
								]
							]
						]
					]
				]
				gblk: reduce ['vform 'edge [color: menu-item-bg] gblk]

				off: any [
					all [pair? face face]
					(screen-offset? face)
				]
				
					
				if object? face [
					either submenu [
						off/x: off/x + face/size/x
					][
						off/y: off/y + face/size/y
					]
				]
				
				gui: glview/modal/no-border/no-resize/safe/offset/auto-close/opt/type intglayout gblk off ['all-over] 'popmenu
				gblk: none
				off: none
				gui: none
				menu-action: none
			]

			; a menu item is trying to control its close method, allowing sub menus to be a bit less
			; frenzied
			unless empty? ctx/close-method [
				either subtext: find ctx/close-method string! [
					ctx/selection: pick subtext 1
				][
					if subtext: find ctx/close-method 'hover-close [
						ctx/selection: 'hover-close
					]
				]
			]
			
			
			
			return ctx/selection
		]
	]



	;----------------------
	;-     borderize-image()
	;----------------------
	borderize-image: func [
		img
		/no-window
		/local size edge-size top-size gui caption ok? win
	][
		;either image? snapshot-windows-title [

			gui: view/modal/center compose/deep [
				column [
					spane: scrollpane [
						row [
							(either no-window [
								[
									column  [
										column [
											canvas img/size with [image: img static-size: img/size color: none]
										]
										elastic bg-clr + 30.30.30
									]
									elastic bg-clr  + 30.30.30
								]
							][
								caption: append copy "REBOL - " request-text/auto-enter/title "Window title"
								[
									column  [
										vblack [
											
											vform edge [color: 150.150.150 size: 2x2] [
												row [
													text caption with [color: Navy font: make font [color: white style: 'bold shadow: none]]
												]
												canvas img/size with [image: img static-size: img/size color: none]
											]
										]
										elastic bg-clr + 30.30.30
									]
									elastic bg-clr  + 30.30.30
								]
							])
						]
					]
					do [
						spane/calc-sizes
						spane/def-size: spane/content/def-size + 0x1
					]
					row [
						elastic
						column [
							button "reset size" [win: find-window face win/size: win/def-size show win]
							button "save" [ok?: true hide-popup]
							button "cancel" [hide-popup]
						]
						elastic
					]
				]
			]
			
			; now can clip image directly within borderize viewer!!! very usefull
			either ok? [
				;view to-image spane/container
				to-image spane/container
			][
				none
			]
	;	][img]
	]


	;----------------------
	;-     get-word-wrap()
	;----------------------
	get-word-wrap: func [
		"Returns a block with a face's text, split up according to how it currently word-wraps."
		face "Face to scan.  It needs to have text, a size and a font"
		/line-count "Return the number of lines current face needs to wrap all included text."
		/apply "Place the resulting block within the face's line-list property."
		/offset "Include individual lines offset in resulting block (adds a pair! after each text)"
		/local txti counter blk rval
	][
		;only react if there is a font setup.
		either none? face/font [
			vprint/error "face/font is not set, cannot determine word wrapping"
		][
			rval: none
			counter: 0
			txti: make system/view/line-info []
			either line-count [
				while [textinfo face txti counter ] [
					counter: counter + 1
				]
				rval: counter
			][
				blk: copy []
				while [textinfo face txti counter ] [
					insert tail blk copy/part txti/start txti/num-chars
					if offset [insert tail blk txti/offset]
					counter: counter + 1
				]
				if apply [face/line-list: blk]
				rval: blk
			]
		]

		; free memory & return
		txti: none
		blk: none
		return first reduce [rval rval: none]
	]
	;----------------------
	;-     get-lines-fast()
	;----------------------
	; like preceding function but meant to be very fast...
	;----------------------
	get-lines-fast: func [
		"Returns a block with a face's text, split up according to how it currently word-wraps."
		face "Face to scan.  It needs to have text, a size and a font"
		/local txti counter text
	][

		counter: 0
		txti: make system/view/line-info []
		while [textinfo face txti counter ] [
			counter: counter + 1
		]

		; free memory & return
		txti: none
		return counter
	]





	;----------------
	;-     last?()
	; false if list is empty
	;----
	last?: func [serie][
		either not (tail? serie)[
			either (pick serie 2) [false][true]
		][false]
	]



	;---------------
	;-     coord()
	;---------------
	; if you supplied an integer as the first argument (pair) then it will automatically
	; convert that into pair and it expects you to supply a /spair or /fpair refinement.
	;---------------
	coord: func [ pair direction /s /f /spair /fpair][
		either direction = 'horizontal [
			if integer?  pair [
				pair: to-pair reduce [pair pair]
			]
			if s [return pair/x]
			if f [return pair/y]
			if spair [return to-pair reduce [pair/x 0]]
			if fpair [return to-pair reduce [0 pair/y]]
		][
			if integer?  pair [
				pair: to-pair reduce [0 pair]
			]
			if s [return pair/y]
			if f [return pair/x]
			if spair [return to-pair reduce [0 pair/y]]
			if fpair [return to-pair reduce [pair/x 0]]
		]
		pair
	]



	;-------------------
	;-     oriented-add()
	;-----
	; a plus b
	;-------------------
	oriented-add: func [
		a [pair!] b [pair!] direction [word!]
	][
		either direction = 'horizontal [
			return to-pair reduce [(a/x + b/x) a/y]
		][
			return to-pair reduce [a/x (a/y + b/y)]
		]
	]
	;-------------------
	;-     oriented-cumulate()
	;-----
	; a plus b (and accumulate largest of secondary coord)
	;-------------------
	oriented-cumulate: func [
		a [pair!] b [pair!] direction [word!]
	][
		either direction = 'horizontal [
			return to-pair reduce [(a/x + b/x) (max a/y b/y)]
		][
			return to-pair reduce [(max a/x b/x) (a/y + b/y)]
		]
	]



	;-------------------
	;-     split-path()
	;-----
	; a fixed version of split-path which always returns the dir first.
	; if path is a dir, then the file is returned as none
	;-------------------
	split-path: func [path [file! string!]/absolute /local blk dir][
		path: to-file path
		blk: find/last/tail path "/"
		either blk [
			blk: reduce [to-file copy/part path blk either tail? blk [none][to-file blk]]
		][
			; there is no path part
			if absolute [ dir: what-dir]
			blk: reduce [dir to-file path]
		]
		return blk
	]


	;-------------------
	;-     dir?()
	;-----
	dir?: func [path][
		path: to-string path
		path: find/last/tail path "/"
		either path [
			either tail? path [true][false]
		][
			false
		]
	]

	;-------------------
	;-     absolute?()
	;-----
	absolute?: func [path][
		((pick (to-string path) 1 ) = #"/")
	]


	;-------------------
	;-     remove-duplicates()
	;-----
	remove-duplicates: func [val [string!] char [string!] /local ptr pre post][
		val: append copy val char
		val: head parse/all val char
		if (first val) = "" [pre: true ]
		if (last val) = "" [post: true ]
		val: next exclude val [""]
		forall val [
			insert val char
			val: next val
		]
		val: to-string head val
		if pre [val: head insert val "/"]
		if post [insert tail val "/"]
		head val
	]



	;--------------------
	;-     make-face()
	;--------------------
	make-face: func [
		"simple wrapper around view's make-face"
		gl-class [word!]
		spec [block!]
	][
		make-face*/styles/spec gl-class gstyle spec
	]


	;-
	;- SETUP BASE VIEW OBJECTS
	;-     colors
	high-color: hi-clr: gold

	bg-clr: gray ;+ 30.30.30
	bg-img: bg-clr
	field-error-color: red
	field-color: 255.220.120

	file-box-files: red ; gold
	file-box-dirs: green ; white

	menu-item-bg: 230.230.230
	
	
	;-     edges
	edit-file-edge: make face/edge [color: navy size: 2x2 effect: none]
	file-dir-edge: make face/edge [size: 1x1 effect: 'bevel color: bg-clr]
	file-dir-edge-pressed: make face/edge [size: 1x1 effect: 'ibevel color: bg-clr]

	debug-edge-spec: [color: red size: 2x2 effect: none]
	debug-edge: make face/edge debug-edge-spec

	black-edge-spec: [color: black effect: none size: 1x1]
	black-edge: make face/edge black-edge-spec
	red-edge: make black-edge [color: red size: 2x2]
	green-edge: make black-edge [color: green size: 2x2]
	blue-edge: make black-edge [color: blue size: 2x2]
	white-edge: make black-edge [color: white size: 2x2]
	

	
	
	;-     fonts
	base-font: make face/font [
		size: 13
		color: black
		style: none
		name: "trebuchet ms"
		shadow: none
		valign: 'middle
		align: 'center
	]

	vtext-font: make base-font [
		color: white
		shadow: 1x1
	]

	carved-font: make base-font [
		colors: reduce [white gold]
		color: white
		shadow: -1x-1
	]

	field-font: make base-font [
		align: 'left
		color: black
		style: [bold]
	]

	field-error-font: make field-font [
		style: [bold italic]
		shadow: -1x-1
		color: white
		size: 12
	]


	toggle-font: make base-font [
		size: 13
		color: gold
		colors: reduce [gold]
		shadow: 1x1
		align: 'left
		style: none
	]


	toggle-font-hi: make toggle-font [
		color: black
		colors: reduce [black]
		shadow: 0x0
		style: [bold italic]
	]

	file-box-files-font: make toggle-font [
		style: [bold italic]

		colors: reduce [white]

	]

	file-box-dir-font: make toggle-font [
		color: white
		shadow: -1x-1
		align: 'left
		style: [bold italic]
		size: 12
		colors: reduce [white]
	]


	banner-font-spec: [size: 14 shadow: none style: [ bold ]]

	menu-font: make base-font [color: black shadow: none size: 11 style: none align: 'left ]


	button-font: make base-font [colors: reduce [ white gold] color: colors/1 shadow: 1x1 style: 'bold align: 'center]


	;-     effects
	field-effect: [ gradmul 1x1 140.140.140 90.90.90 ]
	banner-fx: compose [ gradmul 0x1 (bg-clr * 1.1) (bg-clr * 1.2) ]
	pane-banner-fx: reduce [ 'gradmul 1x0 black bg-clr ]


	;-
	;- FIELD INPUT HOOKS
	;-     !key-hook
	!key-hook: context [
		face: none
		hook: none

		;----------------------
		;-         hookup-field()
		hookup-field: func [
			fc [object!]
			/all "all fields sharing the same feel as the supplied face will be hooked"
			/local blk bword engage
		][
			self/face: fc
			unless all [
				; apply the hook to this field/area only.
				face/feel: make face/feel []
			]
			engage: get in face/feel 'engage
			blk: at third second :engage 6
			bword: second second  :engage
			change/only blk bind bind (compose/deep [unless hook face event (blk)]) bword self
		]
	]

	;-     assign-key-event-callback()
	assign-key-event-callback: func [
		face [object!]
		func-args [block!]
		func-body [block!]
		/local ctx
	][
		ctx: make !key-hook reduce [first [hook:] 'func func-args func-body]
		ctx/hookup-field face

	]




	;-
	;---------------------------------------------------------------------------------------------------------------------------
	;- MKSPEC
	;---------------------------------------------------------------------------------------------------------------------------
		mkspec: func [
		"Returns a vid spec with all glayout features."
		blk  "the block to change"
		/words wblk [block!]"a block which contains words and function body pairs to set in vid spec"
		/group "add some of the group specific attributes and setups"
		/local word effect spec val iblk
	][

		spec: copy/deep [
			gl-class: 'base
			direction: 'horizontal ; can also be 'vertical

			pane-size: 0x0
			margins: none	; for any styles which supports it, this will add extra space around content.
			min-size: none	; panes which layout, will get set, those which are gadgets will only get resized, if they are none
			def-size: none	; panes which layout, will get set, those which are gadgets will only get resized, if they are none
			init-def-size: none ; experimental... you can now set the size of a group within VID block directly !
			manual-min-size: none ; experimental, set this to enforce a manual minimum size in any gadget.
								; this is usefull to open windows larger than default size, or to setup slide bars to user-set prefs...
			static-size: -1x-1 ;
			elasticity: 0x0	; does this pane benefit from stretching (calculated from children in min-size)
							; if no faces benefit from elasticity, then all will use up the space.
							; otherwise, only elastic face with get spacing!
			stretch: 1x1	; this means that the face will follow stretching, so that it is always resized to a
							; pane which is larger or smaller. (down to min-size)

			user-layout: none ; this is called on all faces for which it is set, AFTER the engine has done its gl-layout.

			;------------------
			; selection management
			select: none		; set to a function to handle select events
			de-select: none		; set to a function to handle de-select events

			;------------------
			; set-dirty?		; an option which asks layout to set dirty state of a face when it is resized...
			set-dirty?: False

			;------------------
			;-    refine-vid
			;------------------
			; note that all effects can use the 'tmp and val word as it is declared as a local word.
			; you can now also add supplemental local words by adding them to a block which must be the first thing
			; within the refine spec
			;------------------
			refine-vid: func [
				blk
				/local word effect words args f
			][
				if none? self/words [self/words: copy []]

				; actually add words to new style
				foreach [word effect] blk [
					; redefine the args so we have two local words to use.
					args: [new args /local tmp val]
					if block? words: pick effect 1 [
						vprint ["will add words : [" words "] to local vars of facet func"]
						args: append copy args words
					]
					insert insert self/words word f: func args effect
				]

				; release memory !
				word: none
				effect: none
				blk: none
				f: none
			]


			;-----------------
			;-    VID extensions
			;-----------------
			self/refine-vid [
				;-         -data
				data [
					; simply set the data value...
					new/data: pick args 2
					return next args
				]



				;-         -shrink
				shrink [
					; shrink def-size to min-size
					new/def-size: -1x-1
					return args
				]

				;-         -hshrink
				hshrink [
					; shrink def-size to horizontal min-size
					if new/def-size [
						new/def-size/x: -1
					]
					return args
				]

				;-         -vshrink
				vshrink [
					; shrink def-size to vertical min-size
					if new/def-size [
						new/def-size/y: -1
					]
					return args
				]

				;-         -margins
				; not all types support margins in their layout, but all can now use it directly.
				margins [
					either find [integer! pair!] type?/word val: pick args 2 [
						if integer? val [
							val: to-pair reduce [val val]
						]
	
						new/margins: val
						args: next args
					][
						vprint ["margin error:!  'margins expects integer! or pair! argument, but received: " type? val ]
					]
					; free mem
					val: none
					tmp: none
					new: none
					args
				]
				
				;-         -min-size
				min-size [
					; set min-size to pair or width if integer
					if none? new/min-size [new/min-size: 0x0]
					switch type?/word val: pick args 2 [
						pair! [
							if val/x [
								new/min-size/x: val/x
							]
							if val/y [
								new/min-size/y: val/y
							]
							args: next args
						]
						integer! [
							if val [
								new/min-size/x: val
							]
							args: next args
						]
					]
					return args
				]


				;-         -def-size
				def-size [
					; set def-size to pair or width if integer
					if none? new/min-size [new/def-size: 0x0]
					if not pair? new/def-size [new/def-size: 0x0]
					switch type?/word val: pick args 2 [
						pair! [
							if val/x [
								new/def-size/x: val/x
							]
							if val/y [
								new/def-size/y: val/y
							]
							args: next args
						]
						integer! [
							if val [
								new/def-size/x: val
							]
							args: next args
						]
					]
					if new/group? [new/init-def-size: new/def-size]
					return args
				]


				;-         -static-size
				static-size [
					if none? new/static-size [
						static-size: -1x-1
					]
					switch type?/word val: pick args 2 [
						pair! [
							new/static-size: val
							args: next args
						]
						integer! [
							if val [
								new/static-size/x: val
							]
							args: next args
						]
					]
				]
				;-         -stretch
				stretch [
					if none? new/stretch [
						new/stretch: 0x0
					]
					switch type?/word val: pick args 2 [
						pair! [
							new/stretch: val
							args: next args
						]
						integer! [
							if val [
								new/stretch/x: val
							]
							args: next args
						]
					]
				]
				
				;-         -elx
				elx [
					either none? new/elasticity [
						new/elasticity: 1x0
					][
						new/elasticity/x: 1
					]
					
					args
				]
				;-         -ely
				ely [
					either none? new/elasticity [
						new/elasticity: 0x1
					][
						new/elasticity/y: 1
					]
					
					args
				]

			]



			;--------------------
			;-    refresh()
			;--------------------
			refresh: func [
				""
			][
				vin/tags ["glayout." gl-class "refresh()"] [refresh]
				self/calc-sizes
				layout self/size
				show self
				vout/tags [refresh]
			]

			;-----------------
			;-    layout
			layout: func [
				size [pair! none!]
			][
				vin ["glayout." gl-class "/layout(" size ")"]
				if none? size [
					size: self/size
				]
				if self/set-dirty? [ self/dirty?: True ]
				gl-layout size
				user-layout size
				vout
			]



			;-----------------
			;-    calc-sizes
			calc-sizes: has [tmp] [
				vin ["gl." gl-class "/calc-sizes(" text ")"]
				if none? min-size [
					min-size: self/edge-size
				]

				if none? min-size [
					min-size: 0x0
				]

				if manual-min-size [
					min-size: max min-size manual-min-size
				]

				if none? def-size [
					def-size: self/min-size
				]
				if unset? def-size [
					def-size: none
				]
				vout
			]


			;-----------------
			;-    gl-layout
			gl-layout: func [size][
				vin ["gl." gl-class "/gl-layout(" text  ": " size ")"]
				self/size: size
				vout
			]


			;-----------------
			;-    edge-size
			edge-size: func [/x /y /local tmp] [
				tmp: either none? edge [0x0][edge/size * 2]
				return any [
					all [ x tmp/x]
					all [ y tmp/y]
					tmp
				]
			]


			;-----------------
			;-    inner-size
			inner-size: func [/x /y /local tmp] [
				tmp: edge-size
				return any [
					all [ x (self/size/x - tmp/x)]
					all [ y (self/size/y - tmp/y)]
					self/size - tmp
				]
			]


			;-----------------
			;-    elastic?
			elastic?: does [
				((coord/s elasticity direction) > 0)
			]


			;-----------------
			;-    stretch?
			stretch?: does [
				((coord/s stretch direction) > 0)
			]


		]

		;-    group stuff
		append spec either group [
			[
			group?: true       ; is this face a group or a simple gadget, usefull especially for setup.

			; groups which have selection gadgets use this as their common reference
			selection: none
			stylesheet: none

			;------------------
			; selection management
			;------------------
			; currently only support single-item management.
			;------------------


			; change the block before it is parsed...
			;-        pre-layout
			pre-layout: func [block][
				return block
			]

			; change the face/pane After it is layed out
			; you are not allowed to change its size at this point.
			;-        post-layout
			post-layout: does []




			;-        select
			select: func [face /multi][
				either multi [
					if not (block? selection) [
						selection: copy []
					]
					; do not append face twice
					if not found? find selection face [
						append selection face
					]
				][
					either object? selection [
						; do not de-select object if it is currently sel
						if selection <> face [
							selection/de-select
							self/selection: face
						]
					][
						self/selection: face
					]
				]

				; always call select, it might need refreshing, even if its already selected.
				face/select
				face: none
			]

			;-        de-select
			de-select:  func [
				/only "In single selection mode, only deselect if current selection matches supplied face in multi mode if its not specified the every thing is de-selected."
					face "face to deselect"

				;/all "In multi selection mode, deselect all items in current list"
			][
				vprint "deselecting:"

				either block? selection [
					either only [
						;face/de-select
						if (face: find selection face) [
							;remove face
							face: first reduce [first face remove face]
							face/de-select
							show face
						]
					][
						foreach face head selection [
							face/de-select
							show face
						]
						clear head selection
					]
				][
					if object? selection [
						either (any [
							system/words/all [only (face = selection)]	; if only is set and face matches
							(not only)						; if only isn't set
						])[
							selection/de-select
							self/selection: none
						][
							selection/de-select
						]
					]
				]
				face: none
			]

			;-        multi
			multi: make multi [
				vin "glayout/multi()"
				; use the vid's block handler to call layout on content of block and assign it to ourself
				block: func [
					face blk
					/local spec
				][
					spec: pick blk 1
					if block? spec [
						; do stuff to block before
						spec: face/pre-layout spec


						spec: glayout spec
						if object? spec [
							face/pane: spec/pane

							; this funtion is called whenever the group initalises itself. it is mainly meant to be used
							; so that groups can add stuff to themselves AFTER, or to change their contents.
							face/post-layout
						]

					]
				]
				vout
			]
			]
		][
			;-    non-group stuff
			[
				group?: false ; is this face a group or a simple gadget, usefull especially for setup.
			]
		]


		; add class overides
		append spec blk

		; memory management trick, deallocates the ptr, but still returns the block...
		return first reduce [spec spec: none]
	]




	;-  
	;---------------------------------------------------------------------------------------------------------------------------
	;- TEXT-SIZING
	;---------------------------------------------------------------------------------------------------------------------------
	text-sizing: mkspec [
		gl-class: 'text

		margins: 10x4 ; will be added to def size, but not min-size


		def-size: 60x25


		;-    multi
		multi: make multi [
			;-         size()
			size: func [
				face blk
				/local spec val
			][
				if val: pick blk 1 [
					if integer? val [
						face/def-size/x: val + face/edge-size/x
					]
					if pair? val [face/def-size: (val) + (face/edge-size)]
				]
			]
		]



		;-    calc-sizes
		calc-sizes: has [
			tmp mem mem-style
		][
			vin ["gl." gl-class "/calc-sizes(" text ")"]
			; set min-size
			if not string? text [text: "" ]
			if none? min-size [
				if tmp: size-text self [
					min-size: to-pair reduce [(tmp/x + to-integer tmp/y ) (tmp/y + to-integer (tmp/y * 0.25))]
				][
					if min-size = 0x0 [
						; in some circumstances, the face is not visible, so size-text cannot function!
						min-size: 5x5
					]
				]
			]


			if manual-min-size [
				min-size: max min-size manual-min-size
			]

			if def-size = none [
				def-size: -1x-1
			]
			
			
			if def-size/x = -1 [
				def-size/x: min-size/x + margins/x
			]
			if def-size/y = -1 [
				def-size/y: min-size/y + margins/y
			]

			; overload sizes if static-size is set
			if static-size/x <> -1 [
				self/def-size/x: static-size/x
				self/min-size/x: static-size/x
				self/elasticity/x: 0
				self/stretch/x: 0
			]
			if static-size/y <> -1 [
				self/def-size/y: static-size/y
				self/min-size/y: static-size/y
				self/elasticity/y: 0
				self/stretch/y: 0
			]
			vout
		]
	]


	;-  
	;-
	;---------------------------------------------------------------------------------------------------------------------------
	;- GROUP-SIZING
	;---------------------------------------------------------------------------------------------------------------------------
	group-sizing: mkspec/group [
		gl-class: 'group
		static-resize: 0x0	; only resize layout first time.

		;-    calc-sizes
		calc-sizes: func [
			/local size min
		][
			vin ["gl." gl-class "/calc-sizes(" text ")"]
			if static-size = none [
				static-size: -1x-1
			]
			elasticity: 0x0
			min-size: 0x0

			; did the user specify a def-size for this group within vid-block!
			; note this probably does not support shrinking right now... its just a test...
			either init-def-size [
				def-size: init-def-size
				init-def-size: 0x0
			][
				def-size: 0x0
			]
			stretch: 0x0
			; should go into children
			if block? pane [
				foreach item pane [
					either in item 'def-size [
						item/parent-face: self
						item/calc-sizes

						; just in case calc-size isn't adjusting def-size properly
						item/def-size: max item/def-size item/min-size
						stretch: oriented-cumulate stretch item/stretch self/direction

						; adjust our sizes according to our children's size, cumulatively
						elasticity: oriented-cumulate elasticity item/elasticity self/direction
						min-size: oriented-cumulate min-size item/min-size self/direction
						def-size: oriented-cumulate def-size item/def-size self/direction
					][
						vprint/error "no def-size! gadgets HAVE to be built using glayout..."
					]
				]
			]

			self/def-size: def-size + self/edge-size
			self/min-size: min-size + self/edge-size
			if manual-min-size [
				min-size: max min-size manual-min-size
			]
			self/def-size: max def-size min-size

			;  --NEW--
			if static-resize/x = 1[
				self/static-size/x: any [
					if (static-size/x <> -1) [static-size/x]
					self/def-size/x
				]
			]

			if static-resize/y = 1[
				self/static-size/y: any [
					static-size/y
					self/def-size/y
				]
			]

			; overload sizes if static-size is set
			if static-size/x <> -1 [
				self/def-size/x: static-size/x
				self/min-size/x: static-size/x
				self/elasticity/x: 0
				self/stretch/x: 0
			]
			if static-size/y <> -1 [
				self/def-size/y: static-size/y
				self/min-size/y: static-size/y
				self/elasticity/y: 0
				self/stretch/y: 0
			]


			vout
		]


		;-    layout-shrink
		layout-shrink: func [
			setup
			/local face dir largest space shrink available items size acc val blk
		][
			vin "layout-shrink()"
			blk: copy setup/pane
			dir: direction
			largest: none

			space: abs coord/s setup/space dir

			;-----------
			; loop until we have set all faces
			while [not tail? blk] [
				acc: 0
				;----------
				; find the largest remaining face in block
				forall blk [
					face: first blk
					if (val: coord/s face/min-size dir) >= acc [
						acc: val
						largest: face
					]
				]
				blk: head blk
				face: largest
				size: coord/s face/def-size dir

				; find out how much smaller the face can really be.
				available: (coord/s (face/def-size - face/min-size) dir)
				items: (length? blk)
				shrink: to-integer (space / items)

				if available < shrink [
					shrink: available
				]
				space: space - shrink
				face/size: (coord/spair (size - shrink) dir) + (coord/fpair face/size dir)

				remove find blk face

				blk: head blk
			]
			vout
			coord/spair space dir
		]



		;-----------------------------------------
		;-    gl-layout
		;-----------------------------------------
		gl-layout: func [
			size  ; what size has our parent allowed us for our layout?
			/local elasticity-total face extra-space dir current-offset amount div child current-size faces faces-left x-space
		][
			vin ["glayout." gl-class "/gl-layout(" text  ": " size ")"]

			dir: self/direction

			; used for intra face refresh... when the refresh IS NOT cause by a window resize
			if none? size [
				either none? self/size [
					size: self/def-size
				][
					size: self/size
				]
			]

			; the pane MUST be set to the size
			self/size: size

			either block? self/pane [
				; add up all elasticity
				extra-space: size - def-size ; - self/edge-size

				; our children must not include our internal edge (edge was added in calc-sizes anyways)
				size: size - self/edge-size

				current-offset: 0x0



				either (coord/s extra-space self/direction) >= 0 [
					;------------------------------
					;
					;       STRETCH MODE
					;
					;--------------------------------
					; there is extra-space
					faces: length? pane

					; used for equal size only...
					x-space: extra-space
					faces-left: faces
					forall pane [

						face: first pane
						amount: any [ face/def-size 0x0]
						; calculate strech side size
						either self/elastic? [
							; is this an elastic face?
							if (coord/s face/elasticity dir) > 0 [
								amount: amount + mod: ((coord/s extra-space dir) / ((coord/s self/elasticity dir) / (coord/s face/elasticity dir)))
								x-space: x-space - mod
							]
						][
							if self/stretch? [
								if (coord/s face/stretch dir) > 0 [
									mod: ((coord/spair extra-space  dir ) / ((coord/s self/stretch dir) / (coord/s face/stretch dir)))
									amount: amount + mod
									x-space: x-space - mod
								]
							]
						]

						either (coord/f face/stretch dir) [
							amount: (coord/spair amount dir) + (coord/fpair size dir)
						][
							; restrict size to something between min and default size.
							amount: (coord/spair amount dir) +  min ((max (coord/fpair face/min-size dir) (coord/fpair size dir)) (coord/fpair face/def-size dir))
						]

						; in any case, we must be sure that the last item in a group is not smaller or larger
						; than the pane it is in !
						;
						; - this might cause some refresh issues for items which might get set to a size smaller
						;   than their min sizes.
						face/offset: current-offset


						face/layout amount
						current-offset: oriented-add current-offset amount dir
						faces-left: faces-left - 1
					]
				][
					;--------------------------
					;
					;-       Shrink mode
					;
					;--------------------------
					vprint "we will squash items down, but not past their minimum."
					; separate non/elastic panes into two lists,
					; we want to shrink non-elastic nodes first, since they do not
					; benefit from extra space.  when there is not enough space, then
					; these can logically consume the shortage first.
					nel-pane: copy []
					el-pane: copy []
					pane: head pane
					foreach sub-face pane [
						append either (coord/s sub-face/elasticity dir) = 0 [nel-pane][el-pane] sub-face
					]

					; send non-elastic ones first
					shrink-setup: make object! [
						pane: nel-pane
						space: abs extra-space
					]

					either (remaining-space: layout-shrink shrink-setup) [
						; if there is still extra space, then send elastic ones
						shrink-setup: make object! [
							pane: el-pane
							space: remaining-space
						]
						if (remaining-space: layout-shrink shrink-setup) <> 0x0 [
							vprint "ERROR!!!! RESIZE is smaller than pane's minimum size!"
							vprint remaining-space
						]
					][
						foreach face el [
							face/size: coord/spair face/def-size dir
						]
					]

					;-------------------
					; calculate fixed-direction size and add-up all offsets
					;---
					foreach face pane [
						either (coord/f face/stretch dir) [
							amount: (coord/fpair size dir)
						][
							; restrict size to something between min and default size.
							amount:  min ((max (coord/fpair face/min-size dir) (coord/fpair size dir)) (coord/fpair face/def-size dir))
						]

						face/offset: current-offset
						face/layout oriented-add amount face/size dir

						current-offset: oriented-add current-offset face/size dir
					]
				]
				pane: head pane
			][
				unless none? pane [
					vprobe/error "pane must be a block!!!"
				]
			]
			vout
		]
	]



	;-  
	;-
	;---------------------------------------------------------------------------------------------------------------------------
	;- CENTER sizing
	;---------------------------------------------------------------------------------------------------------------------------
	; simple group which allows only one item, and centers it in any extra space it is provided (wrt def-size)
	center-sizing: mkspec/group [
		gl-class: 'center-group
			
		content: none ; will be set to our content
		no-stretch: 0x0 ; will not stretch internals above their def-size for any direction set to 1
		margins: 0x0
		
		;-    refine-vid
		self/refine-vid [
			;-      -no-stretch
			no-stretch [
				; simply set the no-stretch word...
				new/no-stretch: 1x1
				return args
			]
			;-      -no-stretch
			no-stretch-x [
				; simply set the no-stretch word...
				new/no-stretch/x: 1
				return args
			]
			;-      -no-stretch
			no-stretch-y [
				; simply set the no-stretch word...
				new/no-stretch/y: 1
				return args
			]
		
		]

		;-    multi
		multi: make multi [
			vin "glayout/multi()"
			; use the vid's block handler to call layout on content of block and assign it to ourself
			block: func [
				face blk
				/local spec
			][
				spec: pick blk 1
				if block? spec [
					; do stuff to block before
					spec: face/pre-layout spec

					
					spec: glayout spec
					
					if object? spec [
						
						face/pane: spec/pane
						
						if (length? face/pane) > 1 [
							print "Center-sizing style can only contain one face"
						]
						face/content: face/pane/1
						
						; this funtion is called whenever the group initalises itself. it is mainly meant to be used
						; so that groups can add stuff to themselves AFTER, or to change their contents.
						face/post-layout
					]

				]
			]
			vout
		]
		
		
		;--------------------
		;-    calc-sizes()
		;--------------------
		calc-sizes: func [
			""
		][
			vin/tags ["calc-sizes()"] [calc-sizes]
			
			vout/tags [calc-sizes]
			content/calc-sizes
			
			min-size: content/min-size + edge-size
			def-size: content/def-size + (margins * 2) + edge-size
			either no-stretch/x [
				elasticity/x: 0
				stretch/x: 0
			][
				elasticity/x: content/elasticity/x
				stretch/x: content/stretch/x
			]
			either no-stretch/y [
				elasticity/y: 0
				stretch/y: 0
			][
				elasticity/y: content/elasticity/y
				stretch/y: content/stretch/y
			]
			
			if pair? content/manual-min-size [
				manual-min-size: content/manual-min-size + edge-size
			]
			if pair? content/static-size [
				static-size: content/static-size + edge-size
			]
		]
		
		
		;--------------------
		;-    gl-layout()
		;--------------------
		gl-layout: func [
			""
			size
			/local content-size
		][
			vin ["glayout." gl-class "/gl-layout(" text  ": " size ")"]
			
			content-size: 0x0
			
			
			content-size/x: any [
				all [
					content/static-size/x <> -1
					content/static-size/x
				]
				all [no-stretch/x = 1
					content/def-size/x
				]
				max (size/x - edge-size/x - margins/x - margins/x) content/def-size/x
			]
			
			content-size/y: any [
				all [
					content/static-size/y <> -1
					content/static-size/y
				]
				all [no-stretch/y = 1
					 content/def-size/y
				]
				max (size/y - edge-size/y - margins/y - margins/y) content/def-size/y
			]
			
			content/layout content-size 
			
			self/size: size
			content/offset: (inner-size - content/size) / 2
			
			show content
			vout/tags [gl-layout]
		]
		
		

	]

	;-  
	;-
	;---------------------------------------------------------------------------------------------------------------------------
	;- POPUP sizing
	;---------------------------------------------------------------------------------------------------------------------------
	popup-sizing: append copy text-sizing [
		gl-class: 'popup

		choices: none
		callback: none

		gblk: none

		spec: none

		;-        popup
		popup: func [
			/local gui off
		][
			off: (screen-offset? self)
			off/y: off/y + size/y
			gui: glview/modal/no-border/no-resize/offset intglayout gblk off
		]

		;-        feel
		feel: make feel [
			redraw: none
			over: none
			detect: none
			engage: func [face action event][
				if action = 'down [
					face/popup

				]
			]
		]

		;-        multi
		multi: make multi [
			vin "glayout/popup-sizing/multi()"
			; use the vid's block handler to call layout on content of block and assign it to ourself
			block: func [
				face blk
				/local spec item
			][
				spec: pick blk 1
				face/choices: copy []
				if block? spec [
					face/gblk: spec
				]
			]
			vout
		]
	]

	;-  
	;-
	;---------------------------------------------------------------------------------------------------------------------------
	;- SCROLLER-SIZING
	;---------------------------------------------------------------------------------------------------------------------------
	; scroller supports a special mode in which calc-sizes is only called AFTER its layout has been done.
	scroller-sizing: mkspec [
		gl-class: 'scroller
		bar-width: 20
		bar-text: none	; set this to a function or a string... whatever is returned is place in the bar's text attribute
						;    ex: does [rejoin [ (to-integer face/data * 100) "%"]]
		scale: .25		; 0 - 1  value which scales the bar
		axis: 'y ; make the scroler compatible with older versions of rebol/view
		prev-size: none
		prev-scale: none


		feel: make feel [
			;-----------------------------
			;-    feel/engage
			;-----------------------------
			engage:	func [face action event][
				if action =	'down [
					show face
				]
			]


			; slightly improved slider redraw, automatically scales to barsize
			;-----------------------------
			;-    feel/redraw
			;-----------------------------
			redraw: func [
				face act pos
				/local vertical? bar bar-corner corner
			][
				either object? face/pane [
					bar: face/pane
				][
					bar: face/pane/1
				]
				; a scroller MUST be within a group for it to determine its direction
				vertical?: 'vertical = face/parent-face/direction

				if any [
					face/prev-size <> face/size
					face/prev-scale <> face/scale
				][
					face/prev-size: face/size
					face/prev-scale: face/scale
					face/state: none

					either vertical? [
						bar/size/y: face/size/y * face/scale
						bar/size/x: face/inner-size/x
					][
						bar/size/x: face/size/x * face/scale
						bar/size/y: face/inner-size/y
					]
				]
				if face/data <> face/state [
					face/data: max 0 min 1 face/data
					pos: face/size - bar/size - (2 * face/edge/size)
					either vertical? [
						bar/offset/y: face/data * pos/y
					][
						bar/offset/x: face/data * pos/x
					]
					face/state: face/data
					bar/text: face/bar-text
					show bar
				]
			]
		]

		edge: make edge [size: 1x1 color: 150.150.150 style: 'bevel]

		;-    calc-sizes
		calc-sizes: has [tmp] [
			vin ["gl." gl-class "/calc-sizes(" text ")"]
			either self/parent-face/direction = 'vertical [
				self/direction: 'vertical
				self/axis: 'y ; support rebol direction word
				min-size: 7x15
				if none? def-size [
					def-size: to-pair reduce [bar-width 200]
				]
				stretch: 0x1
			][
				self/direction: 'horizontal
				self/axis: 'x ; support rebol direction word
				min-size: 15x7
				if none? def-size [
					def-size: to-pair reduce [200 bar-width]
				]
				stretch: 1x0
			]
			if manual-min-size [
				min-size: max min-size manual-min-size
			]

			vout
		]


		;-    gl-layout
		gl-layout: func [
			size
			/local bar-size bar
		][
			vin ["gl." gl-class "/gl-layout(" text  ": " size ")"]
			; do we change size or this simply a bar/value refresh...
			either none? size [
				size: self/size
			][
				self/size: size
			]
			vout
		]
	]









	;-  
	;-
	;---------------------------------------------------------------------------------------------------------------------------
	;- BOX-SIZING
	;---------------------------------------------------------------------------------------------------------------------------
	box-sizing: mkspec [
		gl-class: 'box	
		stretch: 1x1
		min-size: 0x0
		def-size: 10x10
		gl-class: 'box
		elasticity: 1x1
		calc-sizes: none
		edge: none
	]






	;-  
	;-
	;---------------------------------------------------------------------------------------------------------------------------
	;- FIELD-SIZING
	;---------------------------------------------------------------------------------------------------------------------------
	field-sizing: mkspec [
		gl-class: 'field
		elasticity: 1x0
		stretch: 1x0	; Only stretch in x, the field should NEVER start stretching in the y direction.
		def-size: 200x20
		color: bg: wheat
		para: make face/para [wrap?: off]

		corner: 3
		font: field-font


		;-    refine-vid
		self/refine-vid [
			;-      -corner
			corner [
				either integer? pick args 2 [
					new/corner: pick args 2
					;if new/corner <> 0 [
					;	new/font: make new/font [offset/x: offset/x + (new/corner / 2)]
					;]
					return next args
				][
					return args
				]
			]
		]

		;-    multi
		multi: make multi [
			;-         size()
			size: func [
				face blk
				/local spec val
			][
				if val: pick blk 1 [
					if integer? val [
						face/def-size/x: val + face/edge-size/x
					]
					if pair? val [face/def-size: (val) + (face/edge-size)]
				]
			]
		]



		;-    gl-layout()
		gl-layout: func [
			size
			/local bg
		][
			self/size: size
			
			; slightly colorize BG
			
			
			bg: color
			
			
			
			effect: compose/deep [
			  draw [
				pen none
				fill-pen 0.0.0.128
				box 1x1 (corner)
			  ]
			  grayscale rotate 90 emboss rotate 90 contrast 20 ; colorize (color)
			  draw [
				pen 0.0.0.200 line-width 1
				box 1x1 (size - 1x1) (max 0 corner - 1)

;				fill-pen radial
;				  (as-pair size/x / 2 size/y) ; grad-offset
;				  ;normal
;				   0 ; start-rng
;				   (size/y) ;stop-rng
;				   0 ;  grad-angle
;				   20 2 ; scale (x y)
;				  (bg * 2)  ; clr 1
;				  (bg * 0.8)  ; clr 2
;				  (bg * 0.6)  ; clr 3
				fill-pen bg
				pen black
				line-width 1
				box 1x1 (size - 2x2) (max 0 corner)


				pen none
				fill-pen linear (0x0) (0) (2) 90 10 1
				 255.255.255.255
				 255.255.255.150
				 255.255.255.100
				box (as-pair 2 0) (as-pair size/x  size/y - 2) (max 0 corner)
			  ]
;			  draw [
;				pen none
;				fill-pen radial (size / 2)  (size/y) 0 10 1
;				  255.255.255.150 255.255.255.220 255.255.255.255
;				box 3x3 (as-pair size/x - 3 size/y / 2) (max 0 corner)
;			  ]
			]
		]

		;-    calc-sizes
		calc-sizes: has [tmp mem] [
			vin ["field/calc-sizes(" text ")"]
			if none? min-size [
				min-size: to-pair reduce [font/size * 2 font/size + 8 ]
			]

			if manual-min-size [
				min-size: max min-size manual-min-size
			]

			if static-size [
				if static-size/x <> -1 [
					self/min-size/x: static-size/x
					if self/stretch [
						self/stretch/x: 0
					]
					if self/elasticity [
						self/elasticity/x: 0
					]
				]
				if static-size/y <> -1[
					self/min-size/y: static-size/y
					if self/stretch [
						self/stretch/y: 0
					]
					if self/elasticity [
						self/elasticity/y:  0
					]
				]
			]

			vout
		]
	]

	;-  
	;-
	;---------------------------------------------------------------------------------------------------------------------------
	;- BUTTON-SIZING
	;---------------------------------------------------------------------------------------------------------------------------
	button-sizing: append copy/deep text-sizing [

		gl-class: 'button	
		remove/part find init [if :action] 3
		color: bg-clr
		corner: none
		up-fx: none
		dn-fx: none
		outline: none
		deep?: false
		flat?: false
		actuated?: false ; has the down button really been pressed on this button?
		
		def-size: 75x25
		
		popup-choices: none
		popup-action: none
		
		
		clip?: none  ;  'right , 'left or 'both

		text-off-left: 0 ; a value added to the x scrolling value of a para

		picture: [] ; set some additional draw cmds here and they will be appended after the button's own dynamic stuff

		font: button-font

		up-para: para: make para [scroll: 0x-1]
		dn-para: make para [scroll: 0x0]

		over?: false

		;-    multi
		multi: make multi [
			;-         color()
			color: func [
				face blk
				/local spec val
			][
				either 1 < length? blk  [
						face/color: blk/1
						face/outline: blk/2
						face/deep?: true
;					if val: pick blk 1 [
;						
;					if val: pick blk 2 [
;						face/color: val
;						face/deep?: true
;					]
				][
					if val: pick blk 1 [
						either face/deep? [
							face/color: val
						][
							face/outline: val
						]
					]
				]
			]
		]
		
		;-    refine-vid
		self/refine-vid [
			;-      -deep
			deep [
				; simply set the deep? word...
				new/deep?: true
				return args
			]

			;-      -corner
			corner [
				either integer? pick args 2 [
					new/corner: pick args 2
					return next args
				][
					retuen args
				]
			]
		]

		;-    feel [::]
		feel: make feel [
			redraw: none

			;-       engage()
			engage: func [face action event][
				switch action [
					alt-down [
						if face/popup-choices [
							lbl: popup-menu ((screen-offset? face) + event/offset) face/popup-choices
							
							if all [
								string? lbl 
								get in face 'popup-action]
							 [
								face/popup-action face lbl
							]
						]
					]
					down [
						face/actuated?: true
						face/effect: face/dn-fx
						face/para: face/dn-para
						face/over?: true
						show face
						if (get in face 'down-callback) [
							down-callback face action event
						]
					]
					up [
						face/actuated?: false
						face/effect: face/up-fx
						face/para: face/up-para

						show face
						if face/over? [
							do-face face true
						]
						
					]
					over [
						if face/actuated? [
							face/effect: face/dn-fx
							face/para: face/dn-para
							face/over?: true
							show face
						]
					]
					away [
						face/effect: face/up-fx
						face/para: face/up-para
						face/over?: false
						show face
						
					]
				]
			]
		]


		;-----------------------------------------------------------------
		;-    gl-layout()
		;-----------------------------------------------------------------
		gl-layout: func [
			size
			/local hclr clr 
		][
			self/size: size

			if none? corner [
				corner: size/y / 2
			]

			; setup outline color
			unless outline [
				either color <> bg-clr [
					outline: color
				][
					outline: bg-clr + 50.50.50
				]
			]

			if font/align = 'left [
				up-para: para: make up-para [scroll/x:  corner / 2 + text-off-left]
				dn-para:       make dn-para [scroll/x:  corner / 2 + text-off-left]
			]

			bxs: 0x0 ;box-start
			bxe: size ;box-end
			
			switch clip? [
				right [ bxe/x: bxe/x + corner + 2 ]
				left [ bxs/x: bxs/x - corner - 0 ]
				both [  bxe/x: bxe/x + corner + 2   bxs/x: bxs/x - corner - 0] 
			]
		
		
			either deep? [
				outline-trp: 100
				grad1: color * 2
				grad2: color * .5
				grad3: color * .3
			][
				outline-trp: 50
				grad1: bg-clr * 2
				grad2: bg-clr * .6
				grad3: bg-clr * .8
			]
			
			
			
			;------------------
			;-       up-fx
			up-fx: effect: compose/deep [
			
				; CLEAR BG
				draw [
					pen (bg-clr) line-width 2
					fill-pen (bg-clr)
					box (bxs -1x-1) (bxe) 0

				]

				; DRAW BG
				draw [
					pen none
					fill-pen radial
					(as-pair bxe/x / 2 bxe/y) ; grad-offset
					;normal
					0 ; start-rng
					(bxe/y) ;stop-rng
					0 ;  grad-angle

					(bxe/x / 20) 2 ; scale (x y)
					(grad1 )   ; clr 1
					(grad2)  ; clr 2
					(grad3)  ; clr 3
					box (bxs + 2x2) (bxe - 3x3) ( max 0 corner )
				]

				; DRAW OUTLINE
				draw [
					pen (to-tuple reduce [outline/1 outline/2 outline/3 outline-trp]) line-width 3
					fill-pen none
					box (bxs + 1x1) (bxe - 2x2) (max 0 corner )
				]


				; DRAW THIN SHADOWS
				draw [
					pen (0.0.0.50) line-width 1
					fill-pen none
					box (bxs) (bxe - 1x1) (max 0 corner )
					pen (0.0.0.250) line-width 1
					fill-pen none
					box (bxs + 2x2) (bxe - 3x3) (max 0 corner - 1 )
				]
				
				(unless flat? [
					; DRAW REFLECTION
					compose/deep [draw [
						pen none
						fill-pen radial (bxe / 2) normal  (bxe/y) 0 10 1
						255.255.255.150 255.255.255.220 255.255.255.255
						box (bxs + 3x3) (as-pair bxe/x - 3 (bxe/y / 2 + 1)) (max 0 corner )
					]]
				])

				(picture)
			]
			

			;---------------------
			;-       dn-fx
			dn-fx: compose/deep [
				draw [
					pen none fill-pen 0.0.0.128
					box (bxs + 1x1) (corner )
				]
				grayscale rotate 270
				emboss rotate 90

				; DRAW BG
				draw [
					pen none
					fill-pen radial
					(as-pair bxe/x / 2 bxe/y) ; grad-offset
					;normal
					0 ; start-rng
					(bxe/y) ;stop-rng
					0 ;  grad-angle

					(bxe/x / 20) 2 ; scale (x y)
					(color * 2 )  ; clr 1
					(color * 0.4)  ; clr 2
					(color * 0.2)  ; clr 3
					box (bxs + 2x2) (bxe - 3x3) (max 0 corner )
				]

				; DRAW THIN SHADOWS
				draw [
					pen (30.30.30.50) line-width 1
					fill-pen none
					box (bxs) (bxe - 1x1) (max 0 corner )
					pen (30.30.30.0) line-width 1
					fill-pen none
					box (bxs + 2x2) (bxe - 3x3) (max 0 corner - 1 )
				]
				draw [
					pen none
					fill-pen radial (bxe / 2) normal  (bxe/y) 0 10 1
					255.255.255.150 255.255.255.220 255.255.255.255
					box (bxs + 3x3) (as-pair bxe/x - 3 (bxe/y / 2 + 2)) (max 0 corner )
				]
				(picture)

			] ; end dn-fx
		]
	]


	;-  
	;-
	;---------------------------------------------------------------------------------------------------------------------------
	;- CHOICE sizing
	;---------------------------------------------------------------------------------------------------------------------------
	choice-sizing: append copy button-sizing [
		gl-class: 'choice
		label: "Selection: "
		corner: 3
		deep?: true
		color: gold
		unselected-text: ""
		text: unselected-text

		text-off-left: 25

		update-text: true  ; if set to false, the button label is not updated when chosen.
		split-bar?: true

		font: make button-font [align: 'left]

		;-        picture
		pic-off: 3x3
		picture: compose/deep [
			draw [
				pen black
				line-width 1
				triangle (3x4 + pic-off) (15x4 + pic-off) (9x14 + pic-off) white white white

				;--------------------------------------
				; uncomment to add vertical separator
				line (19x2 + pic-off) (19x15  + pic-off)
				pen 255.255.255.128
				line (20x2 + pic-off) (20x15 + pic-off)
			]
		]

		unselect: func [][
			text: join label unselected-text
			show self
		]

		choices: none
		callback: func [label][
			print [label " selected"]
		]
		value: none

		gblk: none

		spec: none

		;-        select
		select: func [
			selection
		][
			if string? selection [
				value: selection
				if update-text [
					text: join label selection
				]
				show self
				
				; just here for backwards compatibility, you should now use the action func
				either function? :action [
					do-face self value
				][
					callback selection
				]
			]
		]

		down-callback: func [
			face action event /local selection
		][
			selection: popup-menu face face/choices
			if selection [
				face/select selection
			]
		]


		;-        multi
		multi: make multi [
			vin "glayout/choice-sizing/multi()"
			; use the vid's block handler to call layout on content of block and assign it to ourself
			block: func [
				face blk
				/local spec item
			][
				if block? spec: pick blk 1 [
					;probe spec
					face/choices: spec ; we do not copy the supplied block you can thus remotely edit the block and callup popup will be up to date
				]
				if block? spec: pick blk 2 [
					;probe spec
					face/action: func [face data] spec
				]
			]
			text: func [
				face blk
				/local spec item
			][
				spec: pick blk 1
				if string? spec [
					face/label: spec
					face/text: join face/label face/unselected-text
				]
			]
			vout
		]

	]
	

	
	
		
	;-  
	;---------------------------------------------------------------------------------------------------------------------------
	;- MENU sizing
	;---------------------------------------------------------------------------------------------------------------------------
	menu-sizing: append copy text-sizing [
		gl-class: 'menu
		color: bg-clr
		effect: none
		font: make menu-font [align: 'left]

		base-fx: compose [gradient 0x1 (bg-clr * 1.4) (bg-clr * 1.15) ] 
		hi-fx: none
		
		choices: none
		callback: func [label][
			print [label " selected"]
		]
		value: none
		
		effect: base-fx
		
		;-        feel
		feel: make feel [
			redraw: none
			;-            engage
			engage: func [face action event][
				if action = 'down [
					selection: popup-menu face face/choices
					
					if string? selection [
						
						face/action face rejoin ["/" face/text "/" selection]
					]
					face/color: bg-clr
					face/effect: compose [gradient 0x1 (bg-clr * 1.4) (bg-clr * 1.15) ] 
					show face
				]
			]
			
			;-            over
			over: func [face action offset][
				either action [
					face/color: gold
					face/effect: hi-fx
				][
					face/color: bg-clr
					face/effect: base-fx
				]
				
				show face
			]
			
			detect: none
		]
		
		;-        init
		init: [
			if none? size [size: 1x1]
		    ;if all [not flag-face? self as-is string? text] [trim/lines text]
    		if none? text [text: copy ""]
   			change font/colors font/color
		]
		;probe feel
		;probe init

		;-        multi
		multi: make multi [
			vin "glayout/menu-sizing/multi()"
			; use the vid's block handler to call layout on content of block and assign it to ourself
			block: func [
				face blk
				/local spec item
			][
				
				if block? spec: pick blk 1 [
					face/choices: spec ; we do not copy the supplied block you can thus remotely edit the block and callup popup will be up to date
				]
				if block? spec: pick blk 2 [
					face/action: func [face data] spec
				]
			]
			
			vout
		]

	]
	
	
	;-  
	;- MENU-ITEM-SIZING
	menu-item-sizing: append copy text-sizing [
		choices: none
		
		; This is used by item to tell its associated menu, why it generate a hide-popup.
		; This will allow it to return a word instead of a string so that the sub-popups do not
		; Quit automatically, in circumstances, where its obviously not the goal.
		cls-method: none
		
		sub-arrow-scale: .35
		
		margins: 20x8
		min-size: 20x5
		font: menu-font
		static-size/y: font/size + margins/y
		effect: none
		
		sub-menu-shown: false
		
		
		;--------------------
		;-    over-arrow?()
		;--------------------
		over-arrow?: func [
			""
			face
			offset
		][
			vin/tags ["over-arrow?()"] [over-arrow?]
			vout/tags [over-arrow?]
			offset/x > (face/size/x - (face/size/y * face/sub-arrow-scale * 2))
		]
		
		
		
	

		;-    calc-sizes
		calc-sizes: has [
			tmp mem mem-style
		][
			vin ["gl." gl-class "/calc-sizes(" text ")"]

			; set min-size
			if not string? text [text: "" ]
			;if none? min-size [
				if tmp: size-text self [
					min-size: to-pair reduce [(tmp/x + to-integer tmp/y ) (tmp/y + to-integer (tmp/y * 0.25))]
				][
					if min-size = 0x0 [
						; in some circumstances, the face is not visible, so size-text cannot function!
						min-size: 5x5
					]
				]
			;]
			
			; if we draw a triangle, add space for it.
			if block? choices [
				;print "Will increase menu-item min-size"
				min-size/x: min-size/x + (sub-arrow-scale * min-size/y * 2)
			]

			if def-size = none [
				def-size: min-size + margins 
			]

			if manual-min-size [
				min-size: max min-size manual-min-size
			]

			; overload sizes if static-size is set
			if static-size/x <> -1 [
				self/def-size/x: static-size/x
				self/min-size/x: static-size/x
				self/elasticity/x: 0
				self/stretch/x: 0
			]
			if static-size/y <> -1 [
				self/def-size/y: static-size/y
				self/min-size/y: static-size/y
				self/elasticity/y: 0
				self/stretch/y: 0
			]

			vout
		]
		
		
		
		
		;-    feel/
		feel: make feel [
			;-        redraw()
			redraw: func [face /local size c1 c2 c3 center off][
				if all [
					block? face/choices
					none? face/effect
				][
					size: face/size/y * face/sub-arrow-scale
					off: size * 0.5
					center: face/size/y / 2
					
					c1: to-pair reduce [face/size/x - size - off - 1   center - off]
					c2: to-pair reduce [face/size/x - size - off - 1   center + off]
					c3: to-pair reduce [face/size/x - off - 1          center]
					face/effect: compose/deep [
						draw [
							fill-pen black
							pen black 
							polygon (c1) (c2)  (c3)
						]
					]
				]
			]
			
			;-        engage()
			engage: func [
				face action event
				/local choice
			][
				if find [down  alt-down] action [
					either block? face/choices [
						choice: popup-menu/submenu face face/choices
						switch type?/word choice [
							none! [
								hide-popup/type 'popmenu
							]
							string! [
								append face/cls-method rejoin [face/text "/" choice]
								hide-popup/type 'popmenu 
							]
						]
					][
						do-face face face/text
					]
				]
			]
			
			;-        over()
			over: func [face action offset /local opt][
				;	print ["^/--------OVER() " face/text " " action]
				either action [
					face/color: gold
					show face
					if block? face/choices [
						
						either over-arrow? face offset [
							unless sub-menu-shown [
								append face/cls-method 'open-sub
								choice: popup-menu/submenu face face/choices
								;print choice
								switch type?/word choice [
									word!  [
										if choice = 'hover-close [
											append face/cls-method 'showing-self
											show find-window face
										]
									]
									none! [
										hide-popup/type 'popmenu
									]
									string! [
										append face/cls-method 'ignore-selection
										append face/cls-method rejoin [face/text "/" choice]
										append face/cls-method 'hover-close
										hide-popup/type 'popmenu
									]
								]
								sub-menu-shown: true
							]
						][
							; re-allow sub menu to be shown
							sub-menu-shown: false
						]
					]
				][
					face/color: 230.230.230
					show face
					either find face/cls-method 'open-sub [
						; this effectively ignores one level of ignore when closing a window
						remove find face/cls-method 'open-sub
					][
						either find face/cls-method 'showing-self [
							remove find face/cls-method 'showing-self
						][
							either find face/cls-method 'ignore-selection [
								remove find face/cls-method 'ignore-selection
								hide-popup/type 'popmenu
								
							][
								if any [
									(((win-offset?/y face) + offset/y - 1) <= 0 )
									offset/x >= face/size/x
									offset/x <= 0
								][
									append face/cls-method 'hover-close
									hide-popup/type 'popmenu
								]
							]
						]
					]
				]
			]
		]
	]

	;-  
	;-
	;---------------------------------------------------------------------------------------------------------------------------
	;- STATIC-SIZING
	;---------------------------------------------------------------------------------------------------------------------------
	static-sizing: mkspec [
		gl-class: 'static
		elasticity: 0x0
		stretch: 0x0
		static-size: 15x15
		def-size: none
		min-size: none
		color: bg-clr


		;-    calc-sizes
		calc-sizes: has [tmp mem] [
			vin ["gl." self/gl-class "/calc-sizes(" text ")"]
			if pair? static-size [
				min-size: static-size
				def-size: static-size
			]
			vout
		]

		;-    multi
		multi: make multi [
			size: func [
				face blk
				/local spec
			][
				if pick blk 1 [
					if integer? first blk [
						face/static-size: (to-pair reduce [first blk first blk]) + face/edge-size
					]
					if pair? first blk [face/static-size: (first blk) + (face/edge-size)]
				]
			]
		]

		gl-layout: func [size][
			self/size: static-size
		]
	]


	;-  
	;---------------------------------------------------------------------------------------------------------------------------
	;- FRAME-SIZING
	;---------------------------------------------------------------------------------------------------------------------------
	frame-sizing: append copy group-sizing [
		gl-class: 'frame
		direction: 'vertical
		label: "Frame"
		frame-state: []
		user-data: none

		; put a pointer the group containing the whole frames, so it auto-resizes
		scrollpane2refresh: none

		indent: 20

		text: "Frame!"

		stretch: 1x0
		min-size: 100x0
		def-size: 100x10
		elasticity: 0x0
		edge: none

		opened-font: make base-font [size: size + 2 align: 'left style: [ italic bold ]]
		closed-font: make opened-font [ style: [bold]] ; [align: 'left shadow: 1x1 color: white]

		closed-edge: make face/edge [effect: none size: 0x0 color: red]
		opened-edge: make face/edge [effect: none size: 1x0 color: (white * 0.8)]

		opened-bg: white
		closed-bg: white

		opened-effect: [draw [
			pen black
			line-width 0.5
			triangle 3x4 13x4 8x13 gold gold white white gold ]]

		closed-effect: [draw [
			pen black
			line-width 0.5
			triangle 4x3 13x8 4x13  gold  white gold
		]]


		; pointer to face which contains all items and subfolder (generated in pre-layout)
		container: none
		top-lvl: none

		; pointer to face which allows each frame to indent itself
		indent-face: none

		; pointer to titlebar face
		titlebar: none


		;-    open-frame
		open-frame: func [/local face][
			titlebar/opened: true
			titlebar/font: opened-font
			titlebar/effect: opened-effect
			titlebar/color: opened-bg
			container/edge: none
			top-lvl/static-size/y: -1

			container/edge: opened-edge

			if 0 = length? container/pane [
				refresh-container self
			]

			either scrollpane2refresh [
				scrollpane2refresh/calc-sizes
				scrollpane2refresh/layout scrollpane2refresh/size
				show scrollpane2refresh
			][
				self/calc-sizes
				self/layout self/def-size
				show self
			]
		]

		;-    close-frame
		close-frame: func [/local face][
			titlebar/opened: false
			titlebar/font: closed-font
			titlebar/effect: closed-effect
			titlebar/color: closed-bg
			container/edge: none

			top-lvl/static-size/y: 0
			container/edge: none

			either scrollpane2refresh [
				scrollpane2refresh
				scrollpane2refresh/content/calc-sizes
				scrollpane2refresh/layout scrollpane2refresh/size
				show scrollpane2refresh
			][
				self/calc-sizes
				self/layout self/def-size
				show self
			]
		]


		;-------------------------
		;-    frame-action
		;
		; you should replace this if you intend on actually doing something when user
		; clicks on items or folders
		;-------------------------
		frame-action: func [face event][
			either in face 'label [
				print ["titlebar: " face/label]
			][
				print ["item:" face/text]
			]
		]


		;-    items
		items: func [
			item-face
			/local samples lbl blk
		][
			blk: copy []
			samples: 10
			lbl: "1234567890"

			; This is a default system allowing to test the frame.
			; you should replace this by setting your own items listing function
			loop random samples [
				append/only blk reduce [random/only [item folder] copy/part random copy lbl random 10]
			]
		]

		;-    clear-container
		clear-container: func [][
			clear head container/pane
		]


		;-    add-item
		add-item: func [
			label
			action
			usr-data
			/local face
		][
			face: make-face 'text [
				label: none
				user-data: usr-data
				size: 100x5 ; cures little bug
				para: make para [scroll: 18x0]
				stretch/y: 0
				select: func [face event][print ["item selected: " face/text]]

				; contextual menu setup
				popup-choices: none
				popup-action: func [face selection][print ["POPUP: " selection]]

				feel: make feel [
					engage: func [face action event][
						if action = 'down [
							face/select face event
						]
						if action = 'alt-down [
							if all [block? face/popup-choices not empty? face/popup-choices][
								selection: popup-menu face face/popup-choices
								face/popup-action face selection
							]
						]
					]
				]
			]
			face/color: white
			face/text: label
			face/label: label
			unless none? :frame-action [
				face/select: :frame-action
			]
			append container/pane face
			face
		]


		;-    add-folder
		add-folder: func [
			label
			action
			usr-data
			/local face tbar *frame-action
		][
			vin "add-folder()"
			*frame-action: :frame-action ; just back up action so we can push it to sub folders
			face: intglayout/pane reduce copy/deep ['frame label [] 'with reduce [label: none to-set-word 'frame-action 'first reduce[:frame-action]]]
			face: face/1
			face/frame-action: :frame-action
			face/items: get in self 'items ; perpetuate root frame browse/list methods
			face/refresh-container: get in self 'refresh-container ; perpetuate root frame browse/list methods
			face/label: label
			face/titlebar/user-data: usr-data
			face/user-data: usr-data
			face/close-frame
			face/scrollpane2refresh: self/scrollpane2refresh
			face/stretch/y: 0
			append container/pane face
			vout
			face
		]



		;-    refresh-container
		refresh-container: func [
			frame-face
			/review
			/local item
		][
			frame-face/clear-container
			foreach item frame-face/items frame-face [
				either item/1 = 'folder [
					frame-face/add-folder item/2 (get in frame-face 'frame-action) (random copy item/2)
				][
					frame-face/add-item item/2 (get in frame-face 'frame-action) (random copy item/2)
				]
			]
		]

		;-    get-frame
		;----------------------
		; supply any frame view gadget, title, item or frame, and returns the frame object in which
		; it is contained.  as such, this func should be included in all faces and subclasses of a frame
		get-frame: func [
			face
			/local iterate
		][
			vin "get-frame()"
			iterate: true
			while [
				face
			][
				if all [
					(in face 'gl-class)
					face/gl-class = 'frame
				] [
					vout
					return face
				]
				face: face/parent-face
			]
			vout
			none
		]


		;-    pre-layout
		pre-layout: func [
			spec
			/local frm
		][
			vin ["gl." gl-class "/pre-layout"]
			frm: self
			insert spec copy/deep [
				frame-titlebar with [frame: frm get-frame: get in frm 'get-frame]

				row white with [stretch/y: 0 ] [
					row white static-size 16x-1 []
					column [] with [stretch/y: 0 elasticity: 0x0]
				]
			]

			vout
			head spec
		]

		;-----------------------
		;-    post-layout
		post-layout: does [
			titlebar: pane/1
			top-lvl: pane/2
			container: pane/2/pane/2
			label: text
			close-frame
			titlebar/label: self/text
			titlebar/text: self/text
			titlebar/user-data: self/user-data
			unless none? :frame-action [
				titlebar/select: :frame-action
			]
		]

	]










	;-  
	;---------------------------------------------------------------------------------------------------------------------------
	;- SCROLLPANE-SIZING
	;---------------------------------------------------------------------------------------------------------------------------
	scrollpane-sizing: mkspec/group [
		gl-class: 'scrollpane
		elasticity: 1x1
		stretch: 1x1
		scroller-width: 20
		v-scroller: none
		h-scroller: none
		v-group: none
		h-group: none
		h-action: [face/scrollpane/content/changes: 'offset face/scrollpane/content/offset/x: (face/data * (face/scrollpane/container/inner-size/x - face/scrollpane/content/size/x )) show face/scrollpane/content]
		v-action: [ face/scrollpane/vscroll/at face/data]

		container: none ; dynamic face which holds the user-provided group.  This makes it easier everywhere.
						; also makes it easier to replace the inside group directly.
		content: none


		;-    vscroll
		vscroll: func [
			/at at-amount [integer! decimal!] "an explicit value of total scrollable view (integer value can only be 0 or 1)"
			/by by-amount [integer! decimal!] "a fractional amount of total scrollable view (integer value can only be 0 or 1)"
			/pixels px-amount [integer!] "exact pixel offset amount"
			/nudge pg-amount [decimal! integer!] "an amount proportional to visible portion of inner pane"
			/local offset
		][
			content/changes: 'offset
			if at [
				content/offset/y: (at-amount * (container/inner-size/y - content/size/y ))
				show content
			]
			if pixels [
				;probe ( container/inner-size/y - content/size/y )
				;probe px-amount
				vscroll/by -1 * (px-amount * (any [
					attempt [1 / ( container/inner-size/y - content/size/y ) ]
					0]
				))
				;show content
			]
			if by [
				v-scroller/data: min max (v-scroller/data + by-amount)  0 1
				show v-scroller
				vscroll/at v-scroller/data
			]
		]

		;-    pre-layout
		pre-layout: func [
			spec
		][
			vin ["gl." gl-class "/pre-layout"]
			insert spec copy/deep [
				box edge []

				vpane [
					scroller
						with [scrollpane: none   bar-width: scroller-width]
						edge [color: black effect: none]
						v-action
				]
				hpane [
					scroller
						with [scrollpane: none   bar-width: scroller-width]
						edge [color: black effect: none]
						h-action
				]
			]

			vout
			head spec
		]


		;-----------------------
		;-    post-layout
		post-layout: does [
			vin ["gl." gl-class "/post-layout"]

			; content
			container: self/pane/1
			content: self/pane/4 ; user supplied group
			container/pane: reduce [content]
			remove find self/pane content ; remove the content from OUR pane
			content/edge: make content/edge []

			; scrollers
			v-group: self/pane/2
			h-group: self/pane/3
			v-scroller: v-group/pane/1
			h-scroller: h-group/pane/1

			v-scroller/scrollpane: self
			h-scroller/scrollpane: self
			vout
		]


		;-----------------------
		;-    calc-sizes
		calc-sizes: has [size min face] [
			vin ["gl." gl-class"/calc-sizes(" text ")"]
			if none? min-size [
				min-size: 0x0
			]

			min-size: 0x0

			if manual-min-size [
				min-size: max min-size manual-min-size
			]

			foreach face head pane [
				face/parent-face: self
			]

			v-group/calc-sizes
			h-group/calc-sizes
			content/calc-sizes

			if none? self/def-size [
				def-size: 30x30
			]

			vout
		]



		;-----------------------
		;-    resize-container
		resize-container: func [
			size
		][
			vin ["gl." gl-class "/resize-container()" ]
			container/size: size

			; determine what scrollbars are needed
			if content/def-size/y > container/inner-size/y [
				; adjust container for scroller taking up some space within scrollpane
				container/size/x: size/x - edge-size/x - scroller-width
			]

			if content/def-size/x > container/inner-size/x [
				; adjust container for scroller taking up some space within scrollpane
				container/size/y: size/y - edge-size/y - scroller-width
			]

			; adjust opposing scrollbar if one was needed.
			if content/def-size/y > container/inner-size/y [
				; adjust container for scroller taking up some space within scrollpane
				container/size/x: size/x - edge-size/x - scroller-width
			]

			vout
		]



		;-----------------------
		;-    gl-layout
		gl-layout: func [
			size
			/precalculated
			/local bar-size bar tmp width area blk
		][
			vin ["gl." gl-class "/gl-layout(" text  ": " size ")"]
			self/size: size
			content/calc-sizes
			resize-container size

			content/layout max content/def-size container/inner-size
			content/edge/size: 0x0
			content/edge/color: red

			v-scroller/scale: container/inner-size/y / content/size/y
			h-scroller/scale: container/inner-size/x / content/size/x

			show v-scroller

			if v-scroller/scale >= 1 [
				v-scroller/data: 0
			]

			if h-scroller/scale >= 1 [
				h-scroller/data: 0
			]

			; refresh container offset
			do-face h-scroller h-scroller/data
			do-face v-scroller v-scroller/data

			; resize scroller bars
			v-group/layout  to-pair reduce [(inner-size/x - container/size/x) container/size/y]
			v-group/offset:  to-pair reduce [container/size/x 0]
			h-group/layout  to-pair reduce [ container/size/x (inner-size/y - container/size/y)]
			h-group/offset:  to-pair reduce [ 0 container/size/y]

			vout
			return none
		]

	]


	;-  
	;---------------------------------------------------------------------------------------------------------------------------
	;- TAB-SIZING
	;---------------------------------------------------------------------------------------------------------------------------
	tab-sizing: mkspec/group [
		gl-class: 'tabpane
		elasticity: 1x1
		stretch: 1x1
		def-size: 100x100
		min-size: 100x100
		edge: red-edge
		edge: none
		margin: 5
		
		tab-font: make base-font [shadow: 1x1 colors: reduce [white gold] style: 'italic]
		
		; value contains the currently visible tab.
		value: none
		
		; when generating button, this will set tab panes roundness
		corner: 3
		container: none ; dynamic face which holds the user-provided group.  This makes it easier everywhere.
						; also makes it easier to replace the inside group directly.
		content: none
		bar: none
		choices: none
		

		; this is a backup of all allocated panes which can be viewed.
		panes: none


		;-    refine-vid
		self/refine-vid [
			;-      -corner
			corner [
				either integer? pick args 2 [
					new/corner: pick args 2
					return next args
				][
					retuen args
				]
			]
		]


		;--------------------
		;-    select()
		;--------------------
		select: func [
			""
			idx [integer! string! object!]
			/local  button
		][
			vin/tags ["select()"] [select]
			;print "==============|"
			;probe idx
			;probe value
			;probe length? panes
			
			; get face associated to idx
			if string? idx [
				if idx: find choices idx [
					idx: index? idx
				]
			]
			
			
			if idx = value [return]
			
			clear container/pane
			append container/pane pick panes idx
			show container
			
			if value [
				button: bar/pane/(value)
				button/color: white * .75
				button/flat?: false
				button/picture: none
				;button/corner: 1
				button/refresh
			]
			
			button: bar/pane/(idx)
			button/color: hi-clr
			button/picture: compose/deep [draw [line-width 1.5 pen black fill-pen none box 2 2x2 (button/size - 2x3)]]
			;button/corner: 10
			button/flat?: false
			button/refresh
			
			value: idx
			vout/tags [select]
		]


		;--------------------
		;-    select-action()
		;--------------------
		select-action: func [
			""
			face
			value
		][
			vin/tags ["select-action()"] [select-action]
			select face/text
			vout/tags [select-action]
		]

		;-    multi
		multi: make multi [
			; we use the block as a master block which will contain all the other panes.
			; to simplify the dialect, all blocks are assumed to be vertical by default.
			block: func [
				face blk
				/local spec label
			][	
				;probe blk
				spec: pick blk 1
				if block? spec [
					; do stuff to block before
					spec: face/pre-layout spec

					face/bar: first glayout/pane [row []]
					face/container: first glayout/pane [column edge [color: bg-clr size: 2x2] []]
				
					foreach item spec [
						switch type?/word item [
							block! [
								 ;print "ONE TAB TO SETUP"
								 face/choices: any [face/choices copy []]
								 face/panes: any [face/panes copy []]
								 append face/choices any [label "tab"]
								 item: first glayout/pane compose/deep [column [ (item)]]
								 append face/panes item
							]
							
							string! [
								;print ["next block's label: " item]
								label: item
								
							]
						]
					]
					face/pane: copy []
					face/bar/color: none
					
					append face/pane face/container
					append face/pane face/bar
					
					
					face/refresh-bar
		
					;probe face/choices


;					if object? spec [
;						face/pane: spec/pane
;
;						; this funtion is called whenever the group initalises itself. it is mainly meant to be used
;						; so that groups can add stuff to themselves AFTER, or to change their contents.
;					]
					face/post-layout

				]
			]
		]

		;--------------------
		;-    refresh-bar()
		;--------------------
		refresh-bar: func [
			"update bar based on choices"
			/local choice i spec tab corner 
		][
			vin/tags ["refresh-bar()"] [refresh-bar]
			; remove current buttons
			clear bar/pane
			
			tab: self
			
			i: 1
			foreach choice choices [
				any[
					all [ (i = 1) clip:  ['right]  corner: tab/corner ]
					all [ ( i = (length? choices)) clip: ['left]  corner: tab/corner ]
					all [ clip: ['both] corner: 6 ]
				]
				
				append bar/pane make-face 'button compose [
					font: tab-font
					action: :select-action
					color: white * .75
					deep?: true
					text: (choice)
					corner: (corner)
					clip?: (first clip)
					popup-choices: choices
					popup-action: func [face label][ tab/select label]
				]
				
				i: i + 1
			]
			append bar/pane make-face 'elastic []
			vout/tags [refresh-bar]
		]


		;-    pre-layout
		pre-layout: func [
			spec
		][
			vin ["gl." gl-class "/pre-layout"]
			vout
			head spec
		]


		;-----------------------
		;-    post-layout
		post-layout: does [
			vin ["gl." gl-class "/post-layout"]

	
			vout
		]


		;-----------------------
		;-    calc-sizes
		calc-sizes: has [size min face pane] [
			vin ["gl." gl-class"/calc-sizes(" text ")"]

			;probe first bar
			bar/calc-sizes
			;probe bar/min-size
			;probe bar/def-size
			container/calc-sizes
			foreach pane panes [
				pane/calc-sizes
			]
			vout
		]


		;-----------------------
		;-    gl-layout
		gl-layout: func [
			size
			/precalculated
			/local bar-size tmp width area blk pane pane-size
		][
			vin ["gl." gl-class "/gl-layout(" text  ": " size ")"]
			
			self/size: size

			bar/size: (make pair! reduce [self/inner-size/x - container/edge/size/x - margin 25]) 
			bar/offset: make pair! reduce [container/edge/size/x + margin 0]
			bar/layout bar/size
			container/size: make pair! reduce [self/inner-size/x (self/inner-size/y - (bar/size/y / 2))]
			container/offset: make pair! reduce [0 (bar/size/y / 2)]
			
			
			pane-size: as-pair  (container/inner-size/x - (margin * 2))   (container/inner-size/y - (margin * 2) - container/offset/y)
			
			foreach pane panes [
				pane/offset: as-pair margin margin + container/offset/y
				pane/layout pane-size 
				;pane/edge: red-edge
			
			]
			;print "++++++++++++++++++"
			
			
			vout
			return none
		]

	]



	;-  
	;---------------------------------------------------------------------------------------------------------------------------
	;- FILEBOX-SIZING
	;---------------------------------------------------------------------------------------------------------------------------
	filebox-sizing: append copy group-sizing [
		gl-class: 'filebox
		old-path: none			; used by build-layout to detect if user changed the path
		current-dir: none		; set by user to change the path to list within.
		current-file: none		; holds the currently selected path. if user types a path, by hand, this path should be set to none,
								; so that layout can unselect it.
		dir-exists?: true		; does current-dir exist?
		direction: 'vertical

		selection: none			; note that this can be a file OR a dir, if it was right-clicked.

		; call backs to execute when the filebox gets hit.
		browse-callback:  none
		
		color: white

		;-    VID extensions
		self/refine-vid [
			;-        -browse-path
			browse-path [
				either find [file! string! word!] type?/word val: pick args 2 [
					new/browse-path/only val
					args: next args
				][
					vprint ["glayout/filebox error:! browse-path expects file! string! or word! argument, but received: " type? val ]
				]
				val: none
				tmp: none
				new: none
				args
			]
		]


		;--------------------
		;-    browse-path
		;--------------------
		; completely refresh the window's content with stuff from a new directory or filename.
		; any method (including picking files in the browser) which want to change the
		; current-dir should use this, so as to call the parent's callback.
		;--------------------
		browse-path: func [
			path  [file! word! string!] "the path to set within the file req. if path is a word! then you can send it commands, like 'parent"
			/update "call show on parent"
			/only "only set the paths and set flags. no refresh of ANY kind"
			/forced "force a refresh of the filebox, even if the dir has not changed"
			/local success val file problem
		][
			vin "browse-path()"

			if string? path [
				if error? (tmp: try [path: to-file path]) [
					error-request "browse error!" "" "path is bad" "ok"
					path: 'current
				]
			]
			if word? path [
				switch path [
					parent [
						;path: current-dir
						path: to-string current-dir
						path: find/last path "/"


						either path [
							path: to-file copy/part head path path
						][
							path: current-dir
						]
					]
					current [
						path: current-dir
					]
				]
			]
			if file? path [
				path: clean-path path
				if ( set [path file] split-path to-file path file? path) [
					if forced [
						old-path: none
					]

					current-dir: path
					if not none? file [
						current-file: file
					]
					dir-exists?: exists? current-dir
				]
			]
			problem: self/build-layout ; nothing will happen if path did not change!

			if not only [
				self/parent-face/parent-face/layout self/parent-face/parent-face/size ; rebuild visuals and let it resize to its nominal size
				if update [
					show self/parent-face/parent-face
				]
			]
			browse-callback self ; call this function whenever the visuals change. this is in order to resize scrollers or whatever.
			path: file: success: problem: none
			vout
		]





		;--------------------
		;-    build-layout
		;--------------------
		; internal func which checks if paths have changed and if so rebuilds internal visuals
		;--------------------
		build-layout: func [/local flist dlist dir blk fbox item err dirpath problems dirlist][

			; error checking
			problem: none ; if this stays none, then it means that all went well.  set it to a descriptive word, when a problem does occur.

			if old-path <> current-dir [
				fbox: self
				dlist: copy []
				flist: copy []
				blk: copy [

					; FILE
					;-----------
					style file toggletext
						para [wrap?: off]
						with [
							edit-state: none
							low-font: make low-font [
								color: black
								size: 12
								colors: reduce [black]
								shadow: none
							]
							hi-font: make hi-font [
								size: 12
							]
							color: white
							font: low-font


							select: func [][
								self/state: on
								either self/edit-state [
									edge: file-dir-edge-pressed
									color: field-color
									effect: field-effect
									font: field-font
									focus self
								][
									color: gold
									font: hi-font
									edge: none
									effect: none
								]
								show self
							]

							de-select: func [][
								self/edit-state: off
								state: off
								color: white
								font: low-font
								effect: none
								edge: none
								if not none? old-text [
									text: old-text
									old-text: none
								]
								unfocus
								show self
							]

							; event-handling
							do-key: func [event /local err][
								switch/default event/key [
									; delete
									;#"^~" [
									;	vprint "==========="
									;]

									; escape
									#"^[" [
										parent-face/de-select self
										show self
									]

									; enter/return
									#"^M" [
										rename-file
										parent-face/parent-face/browse-path/forced/update 'current
									]

									; tab
									#"^-"[
										rename-file
									]
								][
									; vprobe face/old-text
									system/words/ctx-text/edit-text self event 'key
								]
							]

							do-down: func [event][
								either edit-state [
									view*/caret: offset-to-caret self event/offset
									view*/highlight-start:
									view*/highlight-end: none
									show self
								][
									unfocus
									self/parent-face/select self
									do-face self self/text ; refresh browser file-bar
								]
							]

							do-alt-down: func [event][
								either self/state [
									self/edit-state: on
									parent-face/select self
									show self
								][
									unfocus
									self/parent-face/select self
								]
							]

							do-over: func [event][
								if not-equal? view*/caret offset-to-caret self event/offset [
									if not view*/highlight-start [view*/highlight-start: view*/caret]
									view*/highlight-end: view*/caret: offset-to-caret self event/offset
									show self
								]
							]



							; rename-file
							rename-file: func [/local val err][
								val: self/text
								either found? (find val "/") [
									error-request "file rename error!"  "" {invalid name, name cannot contain "/"} "ok"
									text: old-text
								][
									either old-text = val [
										error-request "file rename error!" "" "A file or directory with the^/same name already exists" "ok"
									][
										either (error? err: try [rename self/dirpath val self/text: val] )[
											err: disarm err
											error-request "file rename error!"  err/code to-string err/id "ok"
											text: old-text
										][
											self/dirpath: rejoin [first split-path self/dirpath self/text]
										]
									]
								]
								old-text: none
								unfocus
								parent-face/de-select
								show  self
							]
						]
						feel [
							engage: func [face action event][
								switch action [
									down [
										face/do-down event
									]
									over [
										face/do-over event
									]
									alt-down [
										face/do-alt-down event
									]
									key [
										face/do-key event
									]
								]
							]

							redraw:	none

						]


					;----------------------------------
					; DIR
					;-------
					style dir file with [
						old-text: none
						edit-state: off

						; de-select
						de-select: func [][
							edit-state: off
							state: off
							unfocus
							sparkle
							show self
						]

						; sparkle
						sparkle: func [][
							either state [
								either edit-state [
									edge: file-dir-edge-pressed
									color: field-color
									effect: field-effect
									font: field-font
								][
									color: gold
									font: hi-font
									edge: none
									effect: none
								]

							][
								font: file-box-dir-font
								effect: [gradmul 0x1 120.120.120 135.135.135 gradcol 1x0 135.130.100 88.88.88 ]
								edge: file-dir-edge
								color: bg-clr + 40.40.40
							]
						]
						sparkle ; force an initial update


						; do-down
						do-down: func [event][
							either self/edit-state [
								view*/caret: offset-to-caret self event/offset
								view*/highlight-start:
								view*/highlight-end: none
								show self
							][
								either event/offset/x < (self/size/x * .66) [
									do-face self event
								][
									parent-face/select self
								]
							]
						]

						; rename-file
						rename-file: func [/local val err][
							val: self/text
							either (length? parse/all self/dirpath "/") <= 2 [
								error-request "file rename error!"  "" "cannot rename root drives" "ok"
								text: old-text
							][
								either (length? parse/all val "/") > 1 [
									error-request "file rename error!"  "" {invalid name, new name can only have "/" at the end.} "ok"
									text: old-text
								][
									val: remove-duplicates append copy val "/" "/"
									either old-text = val [
										error-request "file rename error!" "" "A file or directory with the^/same name already exists" "ok"
									][
										if (error? err: try [rename self/dirpath val self/text: val] )[
											err: disarm err
											error-request "file rename error!"  err/code to-string err/id "ok"
											text: old-text
										]
									]
								]
							]
							old-text: none
							unfocus self
							parent-face/de-select self
							show  self
						]
					]

					; ERROR-TXT
					style error-txt text font [
						color: red
						shadow: -1x-1
						size: 16
						style: [bold italic]
						align: 'center
					] red black
				]

				if none? (dir: first split-path current-dir) [
					dir: what-dir
				]


				; make sure we really have a path to list...
				if not none? dir [
					either exists? dir [
						; try to access the path... if its not accessible, then setup an error condition!
						either (error? err: try [ dirlist: sort read dir]) [
							err: disarm err
							blk: append copy blk compose/deep [  error-txt (rejoin ["ACCESS ERROR: " err/id ]) ]
							append blk reduce ['def-size parent-face/size]
						][
							foreach item dirlist [
								append  either dir? item [dlist][flist] item
							]
							foreach item dlist [
								either absolute? item [
									dirpath: item
								][
									dirpath: to-file append copy dir item
								]

								append blk reduce compose/deep copy [
									'dir to-string item [
										face/parent-face/parent-face/browse-path/update face/dirpath
									] [face/color: white show face]
									'with [
										dirpath: (dirpath)
									]
								]
							]
							foreach item flist [
								dirpath: to-file append copy dir item
								append blk reduce compose/deep copy [
									'file to-string item [
										face/parent-face/parent-face/browse-path face/dirpath
									]
									'with [dirpath: (dirpath)]
								]
							]
						]
					][
						blk: append copy blk [error-txt "Invalid Directory Path!"]
						if face/parent-face [
							append blk reduce ['def-size face/parent-face/size]
						]
					]

					;--------------------
					; build the list in view
					append blk [filler white]
					blk: append/only copy [vgroup] blk
					self/pane: glayout/pane blk
					self/calc-sizes

					;----------------
					; set pane
					self/offset/y: 0
					old-path: current-dir
					blk: none
				]
			]
			err: item: flist: dlist: dirlist: dir: dirpath: blk: fbox: none

			return problem
		]

		;-----------------
		;-    layout
		layout: func [size [pair! none!]/local x y][
			if none? size [
				size: self/size
			]
			x: max self/def-size/x size/x
			y: self/def-size/y
			size: to-pair reduce [x y]
			gl-layout size
			user-layout size
		]
	]








	;-
	;- gl-resize-feel
	gl-resize-feel: [
		feel [
			resizing: none
			positioning: none
			gl-resize: func [amount /local offset][
				offset: amount - resizing
				if (((abs offset/y) >= 10) OR ((abs offset/x) >= 10)) [
					resizing: amount
					win/size: (win/size + offset)
					show win
				]
			]
			gl-position: func [amount /local offset][
				offset: amount - positioning
				win/OFFSET: (win/offset + offset) - 3x23
				show win
			]
			engage: func [face action event /local offset][
				switch action [
					alt-down [
						resizing: event/offset
					]
					alt-up [
						resizing: none
					]
					down [
						positioning: event/offset
					]
					up [
						positioning: none
					]
					over [
						if resizing [
							gl-resize event/offset
						]
						if positioning [
							gl-position event/offset
						]
					]
					away [
						if resizing [
							gl-resize event/offset
						]
						if positioning [
							gl-position event/offset
						]
					]
				]
			]
		]
	]




	;-  
	;------------------------
	;- GSTYLE-blk
	gstyle-blk: [
		;-        -gadget styles
		;-             *field
		field: field with field-sizing
			;field-color
			feel [redraw: none]
			edge [size: 0x0 color: 150.150.150 effect: 'ibevel]
			effect field-effect

		;-             *scroller
		scroller: slider with scroller-sizing edge [size: 1x1]
		
		;-             *button
		button: button [print face/text]
			with button-sizing
			para [wrap?: off]
			edge none


		check: check white with append static-sizing [static-size: 15x15]edge [size: 2x2 color: 0.0.0]

		toggle: toggle

		;-             *toggletext
		toggletext: toggle
			with append copy text-sizing [
				select: func [][
					color: hi-clr
					font: hi-font
					show self
				]
				de-select: func [][
					color: low-clr
					font: low-font
					show self
				]
				support-edit-mode: true
				static-size/y: 20
				hi-font: toggle-font-hi
				low-font: toggle-font
				font: low-font
				hi-clr: gold
				low-clr: bg-clr
				old-text: none
				para: make para [wrap?: false]
			]
			edge [size: 0x0]
			bg-clr
			feel [
				over: none
				redraw: none
				detect: none
				engage: func [face action event ][
					switch action [
						down [
							if in face 'old-text [
								if not none? face/old-text [
									face/text: face/old-text
									face/old-text: none
									unfocus
									show face
								]
							]
							face/parent-face/select face
							do-face face face/text
						]
						alt-down [
							if in face 'old-text [
								unfocus
								if not none? face/old-text [
									face/text: face/old-text
									face/old-text: none
								]
							]
							face/old-text: copy face/text
							focus face
							face/parent-face/select face
							do-face face face/text
							do-face-alt face face/text
							show face
						]

						key [
							either event/key = #"^[" [
								unfocus face
								face/text: face/old-text
								face/old-text: none
								show face
							][
								system/words/ctx-text/edit-text face event action
							]
						]
					]
				]
			]
		toggletext-odd: toggletext  bg-clr + 20.20.20



		;-        -text-based styles
		text: text with text-sizing font [size: 12 valign: 'middle] para [wrap?: no]
		wtext: text font [color: white]
		vtext: vtext with text-sizing font [valign: 'middle align: 'center]
		hitext: vtext font [color: gold]
		rvtext: vtext font [align: 'right]
		lvtext: vtext font [align: 'left]
		grp-text: vtext font carved-font
		vh3: vh3 with text-sizing font [valign: 'middle]
		header: text font [size: 17 shadow: -1x-1 style: [bold italic] align: 'center ] gold edge [size: 0x0 color: red]
		banner: header font banner-font-spec black bg-clr edge [size: 1x1 effect: 'bevel color: bg-clr] effect banner-fx
		page-banner: header font banner-font-spec black bg-clr edge [size: 1x1 effect: 'bevel color: bg-clr] effect banner-fx
		pane-banner: page-banner  margins 10 effect pane-banner-fx edge none font [color: white align: 'left]
		;-             *text-area
		text-area: area with box-sizing edge [size: 2x2 effect: 'ibevel color: bg-clr]

		;-             *frame titlebar (tree-view)
		frame-titlebar: text 100  para [scroll: 16x0] with [
			label: none ; use instead of text cause we use draw for the label
			frame: none
			stretch: 1x0
			opened: false
			select: func [face event][print ["title selected: "  face/text]]

			refresh-container: func [face][face/parent-face/refresh-container face/parent-face]

			feel: make face/feel [
				over: none
				detect: none
				redraw: none
				engage: func [face action event][
					if action = 'down [
						either event/offset/x < 16 [
							either not face/opened [
								;draw opened
								face/frame/open-frame
							][
								;draw closed
								face/frame/close-frame
							]
						][
							face/select face event
						]
					]
					if action = 'alt-down [
						face/frame/refresh-container face/frame
						face/frame/open-frame
					]
				]
			]
		]

		;-        -layout styles
		hgroup: box edge [size: 0x0 effect: 'ibevel color: bg-clr] with group-sizing
		row: hgroup
		hpane: hgroup edge [size: 1x1 ]
		hform: hpane edge [effect: 'bevel]
		hblk: hpane edge black-edge-spec
		hblack: hblk
		hred: hblk edge [color: red]
		vgroup: hgroup  with [direction: 'vertical]
		column: vgroup
		vpane: vgroup edge [size: 1x1]
		vform: vpane edge [effect: 'bevel]
		vblk: vpane edge black-edge-spec
		vblack: vblk
		vred: vblk edge [color: red]

		;-             *center
		center: box with center-sizing

		;-             *frame
		frame: box with frame-sizing
		
		;-             *tabpane
		switchpad: box with tab-sizing

		;-             *popup
		popup: text with popup-sizing

		;-             *choice
		choice: text with choice-sizing


		;-             *menu-group
		; this will eventually be replaced by a real menu bar handler, but at least now 
		; it allows us to easily put menu labels over a similar looking bg
		menu-group: hform with [effect: compose [gradient 0x1 (bg-clr * 1.4) (bg-clr * 1.15) ] ]

		;-             *menu-item
		menu-item: box menu-item-bg edge none para [wrap?: false scroll: 5x0]
			with menu-item-sizing
			

		;-             *menu-choice
		menu-choice: text with append copy menu-sizing [
			update-text: false
			color: bg-clr
			def-size: -1x25
			manual-min-size: 0x25

		]
		 edge [size: 0x0] font [align: 'left shadow: none color: white] para [scroll: 0x0]

		;-             *scrollpane
		scrollpane: box edge [size: 0x0 effect: 'ibevel color: bg-clr] with scrollpane-sizing

		basebox: box

		box: box with box-sizing

		canvas: box with static-sizing

		spacer: box with [
			gl-class: 'spacer
			elasticity: 0x0
			stretch: 0x0
			multi: make multi [
				size: func [
					face blk
					/local spec
				][
					if pick blk 1 [
						if integer? first blk [
							face/def-size: (to-pair reduce [first blk first blk]) + face/edge-size
						]
						if pair? first blk [face/def-size: (first blk) + (face/edge-size)]
						face/min-size: 2x2
					]
				]
			]

		]
		elastic: box with [
			color: none
			min-size: 0x0
			def-size: 0x0
			gl-class: 'filler
			calc-sizes: has [tmp] [
				vin ["gl." gl-class "/calc-sizes(" text ")"]
				if none? min-size [min-size: 0x0]
				if manual-min-size [
					min-size: max min-size manual-min-size
				]
				if none? def-size [def-size: min-size]

				if self/parent-face [
					self/elasticity: either self/parent-face/direction = 'vertical [0x1][1x0]
				]
				vout

			]
		]

		filler: box with [
			gl-class: 'filler
			stretch: 1x1
			elasticity: 0x0
			calc-sizes: has [tmp] [
				vin ["gl." gl-class "/calc-sizes(" text ")"]
				if none? min-size [min-size: 0x0]
				if manual-min-size [
					min-size: max min-size manual-min-size
				]
				if none? def-size [def-size: min-size]
				vout
			]
		]



		;-        -OTHERS
		key: key with static-sizing
		
		;-              *filebox
		filebox: vgroup with filebox-sizing

		;-              *backdrop
		backdrop: backdrop bg-clr with [effect: none]


		;-              *progress
		progress: progress with append copy field-sizing [
			label: " %"
			text: none
			set-dirty?: True

			font: make toggle-font-hi [align: 'center]

			feel/redraw: func[face act pos /local label-width][
				
				face/data: max 0 min 1 face/data
				if ((face/data <> face/state) OR (face/dirty? = true)) [
					face/dirty?: False
					either face/size/x > face/size/y [
						face/pane/color: black
						face/pane/size/x: max 1 face/data * face/size/x
						face/pane/size/y: face/size/y - second face/edge-size
					] [
						face/pane/size/y: max 1 face/data * face/size/y
						face/pane/offset: face/size - face/pane/size
					]

					; print label in progress...
					if not none? face/label [
						face/pane/text: rejoin [ (to-integer face/data * 100) face/label]
						face/pane/font: face/font
						label-width: size-text face/pane
						either label-width/x > face/pane/size/x [
							face/text: face/pane/text
							face/pane/text: none
							face/pane/font/color: black
						][
							face/text: ""
							face/pane/font/color: high-color
						]
					]

					face/state: face/data
					show face/pane
				]
			]
			edge [size: 2x2 effect: 'ibevel color: bg-clr]

			;-    multi
			;probe multi
			multi: make multi [
				text: func [
					face blk
					/local spec
				][
					if pick blk 1 [
						print "SETTING PROGRESS VALUE"
						face/label: pick blk 1
					]
				]
			]

;			refine-VID [
;				label [
;					new/text: ""
;					return args
;				]
;			]
		]






	]

	if ((slim/as-tuple/digits system/version 3) >= 1.2.10) [
		append gstyle-blk [
			BTN: BTN 75x20 [print face/text] with text-sizing para [wrap?: off]
		]
	]
	if ((slim/as-tuple/digits system/version 3) <= 1.2.7) [
		append gstyle-blk [
			btn: button
		]
	]


	;---------------------------
	;-    gstyle
	gstyle: stylize gstyle-blk

	;-  
	;-------------------
	;- GLAYOUT
	;-------------------
	*layout: get in system/words 'layout
	intglayout: glayout: layout: func [
		spec  "the block of hierarchical VID panes to create."
		/parent prt "use the stylesheet of parent."
		/pane "return pane for easy insertion of the layout within another group."
		/local gface lcl-style
	][
		vin "GL/GLAYOUT()"
		lcl-style: gstyle
		if prt [
			if prt/stylesheet [
				lcl-style: prt/stylesheet
			]
		]

		if (find spec 'style) [lcl-style: copy lcl-style]
		gface: *layout/origin/styles spec 0x0 lcl-style
		vout
		return either pane [
			pane: gface/pane gface/pane: none
			gface: none
			pane
		][gface]
	]







	;-
	;-------------------------
	;- VIEW
	;-------------------------
	glview: view: func [
		face [object! block! image!]
		/offset off "simply reposition somewhere on screen (default is in center)"
		/size init-size "open the window with a preset size"
		/modal "only focus events to this window, only one modal window can receive events at a time..."
		/center "center in screen"
		/title title-text
		/on-close close-blk [block!]
		/with stylesheet "not implemented"
		/no-border "open window without borders"
		/no-resize "open window without resizing ability"
		/auto-close "hide window if events out of popup"
		/opt user-options "supply manual window options"
		/safe "make sure edges are within screen boundaries"
		/type wintype
		/local tmp gstyle offmem options
	][
		vin "GL/VIEW()"
		if block? face [
			face: glayout face
		]

		if image? face [
			view/center/modal compose/deep [
				column [
					canvas (face/size) (face) with [color: none]
					button blue + 100.100.0 deep corner 3 "close" [hide-popup]
				]
			]
			return
		]

		;-   window
		face: make face mkspec [
			type: wintype
			auto-close: false ; used for popup style modal windows
			size: 5x5	; will be reset later
			gl-class: 'window
			glsize: 5x5

			last-moved: 0x0 ; wake event sets this every time a move cursor is done. refer to this value for event which have no proper cursor offset (like scroll-line)
			close-action: either on-close [
				func [face] close-blk
			][none]

			;-------------------
			;-     calc-sizes
			calc-sizes: has [size] [
				vin "window/calc-sizes()"
				either block? pane [
					pane/1/calc-sizes
					min-size: pane/1/min-size + (self/edge/size * 2)
					if manual-min-size [
						min-size: max min-size manual-min-size
					]

					def-size: pane/1/def-size + (self/edge/size * 2)
					elasticity: pane/1/elasticity

					if (length? pane) > 1 [
						vprint/error ["THERE ARE TOO MANY ITEMS IN PANE: " length? pane]
						vprint/error "ONLY THE FIRST ITEM IN WINDOW SPEC WILL BE USED"
					]
				][
					vprint/error "WINDOW HAS NO CHILDREN"
				]
				vout
			]


			;-------------------
			;-     gl-layout
			gl-layout: func [
				size
				/local size-mem
			 ][
				vin ["gl."gl-class"/gl-layout("text")"]
				if size = none [size: self/def-size]
				self/pane/1/offset: 0x0
				self/size: size
				self/pane/1/layout size - self/edge-size
				vout
			]

			ignore-resize: False


			;-------------------
			;-     alt-detect
			alt-detect: func [
				face
				event
				/local size
			][
				switch event/type [
					resize [
						size: face/size
						; make sure we have some size to start with
						if size = none [
							size: face/def-size
						]
						; DO NOT STRETCH IF NO ONE NEEDS IT !
						if (face/elasticity/x) = 0 [
							size/x: min face/def-size/x size/x
						]
						if (face/elasticity/y) = 0 [
							size/y: min face/def-size/y size/y
						]
						size: max size face/min-size

						either size <> face/size [
							face/size: size
							show face
							face/old-size: none
						][
							face/layout size
							show face
						]
					]
					close [
						either find system/view/pop-list face [
							hide-popup
						][
							if in face 'close-action [
								face/close-action face
							]
						]
					]
				]
				event
			]



			;-------------------
			;-     reset-feel
			reset-feel: does [
				set in feel 'detect :alt-detect
			]

		]

		show face
		face/color: bg-clr

		;-    ---modal---
		either modal [
			if auto-close [
				face/auto-close: true
			]
			face/offset: 0x0
			options: append copy ['activate-on-show] any [user-options []]
			unless no-resize [append options 'resize]
			if no-border [append options 'no-title]
			face/calc-sizes
			face/size: face/def-size
			face/layout face/def-size
			face/reset-feel

			if center [
				face/offset: (view*/screen-face/size - face/size) / 2
			]

			if off [
				face/offset: face/offset + off
			]

			if safe [
				face/offset: min face/offset ((screen-size - 10x30) - face/size)
				face/offset: max face/offset 5x5
			]

			if title [ face/text: title-text]
			show-popup/options face options

			do-events

			vout
			return (none)  ; there is no need for a return value... the requester supplies its own...
		][
			face/calc-sizes
			either pair? init-size [
				face/size: init-size
			][
				face/size: face/def-size
			]
			face/layout face/size
			if title [ face/text: title-text]
			
			options: copy any [
				user-options
				[resize]
			]

			either offset [
				face: vid-view/new/options/offset face options off
			][
				either center [
					face: vid-view/new/options/offset face options (view*/screen-face/size  - face/size ) / 2
				][
					face: vid-view/new/options face options
				]
			]
			face/reset-feel

			show face
			vout
			return face
		]

	]






	;-
	;---------------------
	;- REQUEST-ERROR
	;---------------------
	error-request: request-error: func [
		banner-msg [string!] "requester main title"
		err-code [string! integer!]
		msgb [string!]
		button-msg [string!]
		/help "add a help button besides the button-msg"
			action [block!] "a block to execute when help button is pressed"
	][
		err-code: to-string err-code
		view/modal/center compose/deep [
			vgroup [
				spacer 10
				hgroup [
					spacer 10
					hpane [
						hblk[
							vgroup edge [color: black effect: none][
								spacer 300x10 ; minimum width
								hgroup bg-clr - 50.50.50 [
							elastic
									header banner-msg font [color: red + 50.50.50 shadow: 1x1 ft-style: 'bold]
							elastic
								]
								spacer 10
								hgroup [
									vtext as-is rejoin ["ERROR " err-code ": "] font [style: 'bold align: 'right] shrink
									vtext as-is msgb font [align: 'left]
								]
								spacer 10
							]
						]
					]
					spacer 10
				]
				spacer 10
				hgroup [
					elastic
					row [ (
						;switch the row block between a help and no help version
						either help [
							reduce [
								'row reduce [
									'button red 'deep 'button-msg [hide-popup] 'hshrink
									'button blue 'deep "help"   'hshrink action
								]
							]
						][
							[
								button button-msg  red with [deep?: true] [hide-popup] hshrink
							]
						]
					)]
					elastic
				]
				spacer 10
			]
		]
	]


	

	;-
	;- REQUEST-CONFIRM
	; gl/request-confirm/title/buttons/auto-enter "test request!" ["ok" "cancel"] "ok"
	request-confirm: func [
		/title
			title-text
		/label
			label-text
		/buttons
			button-text
		/auto-enter
			def-button
		/local ctx button
	][
		if none? title-text [title-text: "confirm!"]
		if none? label-text [label-text: title-text]

		button-text: any [button-text ["ok" "cancel"] ]
		buttons: copy []
		
		if auto-enter [
			key-focus-action: func [face event][
				if event/key = #"^M" [
					hide-popup
				]
				key-focus-action: none
				
			]
		]

		foreach button button-text [
			append buttons compose [ button (button) (either def-button = button [gold][])[ctx/answer: face/text hide-popup]]
		]

		ctx: context [
			answer: none
			ui: layout compose/deep [
				column [
					spacer 20
					vh3 label-text font [shadow: 1x1 style: none]
					spacer 20
					row [
						spacer 20
						elastic
						row [
							(buttons)
						]
						elastic
						spacer 20
					]
					;spacer 10
					key  #"a" [print "bob" ]
				]
			]
			ui/text: title-text
		]

		view/modal/center ctx/ui

		; release references to data to allow garbage collection
		buttons: button: button-text: label-text: title-text: none
		return first reduce [ctx/answer ctx: none]
	]
	;-
	;- REQUEST-TEXT
	request-text: func [
		/title
			title-text
		/label
			label-text
		/ok
			ok-text
		/auto-enter
		/local ctx
	][
		if none? title-text [title-text: "Enter text"]
		if none? label-text [label-text: title-text]
		if none? ok-text [ok-text: "ok"]

		ctx: context [
			f: text: ""
			quit-on-enter: auto-enter
			ui: layout [
				vblk [
					HEADER label-text
					spacer 5
					row [
						spacer 5
						f: field def-size 300  [text: face/text if quit-on-enter [hide-popup]]
						spacer 5
					]
					spacer 5
					row [
						filler
						button "ok" (if auto-enter [gold]) [hide-popup]
						button "cancel"  [text: none hide-popup ]
						filler
					]
					spacer 5
				]
			]
			focus f
			ui/text: title-text
		]


		view/modal/center ctx/ui

		; release references to data to allow garbage collection
		label-text: none
		title-text: none
		ok-text: none
		return first reduce [ctx/text ctx: none]
	]


	;
	;- INFORM
	;--------------------
	inform: func [
		"a simple modal dialog to which you must simple press ok button"
		title [string!]
	][
		request-confirm/title/buttons/auto-enter title ["ok"] "ok"
	]

	;
	;- REQUEST-FILE
	;--------------------
	request-file: func [
		/title "change browser information"
			window-title
			button-title
		/path "initial file to highlight or directory to list"
			init-path [file! string! word!]
		/dir "return only dir part"
		/file "return only file part"
		;/filter
		;	fspec {specify a filter to apply on file list (supports only "*")}
		;/keep "remeber previous setup, file position and even layout if possible"
		;/session "like keep but allows multiple sessions. "
		;	sid "setting none will actually load the same setup as /keep."
		;/multi "allows to select more than one file.  will then resturn a block! instead of a file! type (even if only one file is selected)"
		;/relative "ask system to return path relative to another path"
		;	rpath "the reference path to use."
		;/locked "the user cannot browser to another path, he can only choose a file in the path you specified in /file"
		;/open "attempts to return a file which do not exist will fail."
		;/save "attempting to overwrite a file will actually cause a (are you sure) requester"
		;/confirm-msg "in case you want a custom message for your confirm"
		/local tlist path-field file-field ctx val err
	][
		; one difference is that all returned paths are absolute, which makes some part of the process safer.
		;  if you need to know the path part then use split on the returned path(s)
		vin "glayout/filereq"

		 window-title: either none? window-title ["select-file or directory"][window-title]
		 button-title: either none? button-title ["ok"][button-title]

		if none? init-path [init-path: %/]
		ctx: context [
			spane: none
			tlist: none
			dir-field: none
			file-field: none
			err
			rval: none
			ui: copy/deep [
				hgroup [
					spacer 5
					vgroup [
						spacer 5
						header window-title
						spacer 5
						hgroup [
							vtext "path: "  def-size 40
							dir-field: field to-string init-path [tlist/browse-path/update face/text]
							button "..." corner 2 hshrink [tlist/browse-path/update 'parent]
						]
						spacer 10
						hgroup [
							style button button corner 2
							button "refresh" [
								tlist/browse-path/update/forced 'current
							]
							button "root" [
								tlist/browse-path/update %/
							]
							button "new dir" [
								val: request-text/label "new directory path:"
								if not none? val [
									if not none? tlist/current-dir [
										; clean up path
										val: rejoin [to-string tlist/current-dir "/" val "/"]
										val: remove-duplicates val "/"
										val: to-file to-string val

										either exists? val [
											error-request "Directory already exists!" "a" "b" "abort!"
										][
											either (error? err: try [make-dir/deep val]) [
												err: disarm err
												error-request "make dir error" to-string err/code to-string err/id "continue!"
											][
												tlist/browse-path/update val
											]
										]
									]
								]
							]
							button "delete" [
								if all [
									object? tlist/pane/1/selection
									file? tlist/pane/1/selection/dirpath
									exists? tlist/pane/1/selection/dirpath
								][
									either (error? err: try [ delete tlist/pane/1/selection/dirpath none]) [
										err: disarm err
										either ((read first split-path tlist/pane/1/selection/dirpath) <> [])[
											error-request "directory delete error!" err/code "Directory is not empty, cannot delete" "ok"
										][
											error-request "file delete error!" to-string err/code to-string err/id "ok"
										]
									][
										tlist/browse-path/update/forced 'current
									]
								]
							]

						]
						vpane [
							hblk [
								spane: scrollpane white min-size 75x100 def-size 100x400 [
									column [
										tlist: filebox browse-path init-path
									]
								]
							]
						]
						spacer 10
						hgroup [
							vgroup [
								filler
								hgroup  [
									vtext "file: " min-size 40x10 def-size 20x10 with [stretch: 0x0] font [align: 'right]  ;edge [color: red size: 2x2]
									file-field: field [tlist/current-file: face/text]
								]
								filler
							]
							spacer 30
							column [
								button "ok" [ rval: vprobe reduce [tlist/current-dir tlist/current-file] hide-popup ]
								button red deep"cancel" [ hide-popup ]
							]
							spacer 15
						]
						spacer 10
					]
					spacer 5
				]
				do [
					spane/content/color: white
				
					tlist/browse-callback: func [fb-pane][
						vin "browse-callback()"
						dir-field/text: fb-pane/current-dir
						file-field/text: fb-pane/current-file
						either fb-pane/dir-exists? [
							dir-field/font: field-font
							dir-field/color: field-color
						][
							dir-field/font: field-error-font
							dir-field/color: field-error-color
						]
						show dir-field
						show file-field
						spane/calc-sizes
						spane/content/calc-sizes
						spane/layout spane/size
						show spane
						vout
					]
				]
			]
		]

		view/modal/center/title ctx/ui window-title ; evaluation stops here until this window is closed.

		if ctx/rval [
			either dir [
				ctx/rval: pick ctx/rval 1
			][
				either file [
					ctx/rval: pick ctx/rval 2
				][
					ctx/rval: rejoin exclude ctx/rval reduce [none]
				]
			]
		]

		; ctx/rval
		vout
		ctx/spane: ctx/tlist: ctx/dir-field: ctx/file-field: ctx/ui: none

		return  first reduce [ctx/rval ctx/rval: none ctx: none]
	]



	;---------------------------------------------------------------------------
	;- REQUEST-INSPECTOR
	;---------------------------------------------------------------------------
	request-inspector: func [
		dataset
		/title ttl
		/local ctx
	][
		context copy/deep [
			inspect: txt-block: panes: inspect-pane: inspector: win: none

			win: gl/view/center/size [
				column [
					header "INSPECTING..."
					inspector: scrollpane [
						row []
					]
				]
			] 600x250

			panes: inspector/content/pane



			;--------------------
			;-    attr-blk?()
			;--------------------
			attr-blk?: func [
				""
				blk [block!]
			][
				; keep only first of data pairs in block 
				all [
					even? length? blk
					not parse blk [some any-word!] ; if its a list of words, we should return it as such...
					parse extract blk 2 [some any-word!]
				]
			]
			
			


			;--------------------
			;-    inspect()
			;--------------------
			inspect: func [
				data
				title [string!] "data label for this pane"
				depth [integer!]
				/local pane
			][
				vin "glayout/request-inspector/inspect()"
				if (pane: pick back tail panes 1 )[
					pane/static-size/x: 220
				]
				pane: first gl/layout/pane inspect-pane :data title depth
				pane/manual-min-size: 400x0

				append clear at panes depth pane
				win/refresh
				vout
			]

			;-    inspect-pane
			inspect-pane: func [
				"returns a pane layout spec (block!) which you can then display using gl/layout/pane or gl/view directly"
				data
				title [string!] "data label for this pane"
				depth [integer!] "Used to call inspect at the proper depth"
				/local vblk blk item-data rblk blk-ctr bnr-ttl
			][
				vin "glayout/request-inspector/inspect-pane()"
				vblk: copy []

				switch/default (type?/word :data) [
					object! [
						foreach item sort next first data [
							; special case for unset values
							either error? item-data: try [item-data: get in data item][
								item-data: disarm item-data
								either item-data/id = 'no-value [
									append vblk compose/deep [
										toggletext 50 (rejoin [to-string item " (unset!)"]) with [idata: [(item-data)]] [inspect unset! (to-string item) (depth + 1)]
									]

								][
									to-error item-data
								]

							][
								switch/default type?/word :item-data [
									block! [
										append vblk compose/deep [
											toggletext 50 (rejoin [to-string item " (block!)"]) with [idata: [(item-data)]] [inspect get in face 'idata (to-string item) (depth + 1)]
										]
									]
									word! [
										append vblk compose/deep [
											toggletext 50 (rejoin [to-string item " (word!)"]) with [idata: (to-lit-word item-data)] [inspect get in face 'idata (to-string item) (depth + 1)]
										]
									]
									function! [
										append vblk compose/deep [
											toggletext 50 (rejoin [to-string item " (function!)"]) with [idata: first [(:item-data)]] [inspect get in face 'idata (to-string item) (depth + 1)]
										]
									]
								][
									append vblk compose/deep [toggletext 50 (rejoin [to-string item " (" type?/word :item-data ")"]) with [idata: (:item-data)] [inspect get in face 'idata (to-string item) (depth + 1)]]
								]
							]
						]
					]
					string! [
						append vblk txt-block data
					]
					block! [
						; ATTRIBUTE PAIRS? [word value   word value   word value   ...]
						either attr-blk? data [
							vprint "--------ATTRIBUTE PAIRS----------"
							foreach item extract data 2 [
								; special case for unset values
								either error? item-data: try [item-data: select data item][
									item-data: disarm item-data
									either item-data/id = 'no-value [
										append vblk compose/deep [
											toggletext 50 (rejoin [to-string item " (unset!)"]) with [idata: [(item-data)]] [inspect unset! (to-string item) (depth + 1)]
										]
	
									][
										to-error item-data
									]
	
								][
									switch/default type?/word :item-data [
										block! [
											append vblk compose/deep [
												toggletext 50 (rejoin [to-string item " (block!)"]) with [idata: [(item-data)]] [inspect get in face 'idata (to-string item) (depth + 1)]
											]
										]
										word! [
											append vblk compose/deep [
												toggletext 50 (rejoin [to-string item " (word!)"]) with [idata: (to-lit-word item-data)] [inspect get in face 'idata (to-string item) (depth + 1)]
											]
										]
										function! [
											append vblk compose/deep [
												toggletext 50 (rejoin [to-string item " (function!)"]) with [idata: first [(:item-data)]] [inspect get in face 'idata (to-string item) (depth + 1)]
											]
										]
									][
										append vblk compose/deep [toggletext 50 (rejoin [to-string item " (" type?/word :item-data ")"]) with [idata: (:item-data)] [inspect get in face 'idata (to-string item) (depth + 1)]]
									]
								]
							]						
							rblk: copy []
							data: extract next head data 2
							blk-ctr: 0
							
							forall data [
								blk-ctr: blk-ctr + 1
								gt: either odd? blk-ctr [bg-clr] [bg-clr + 20.20.20]
								item-data: first data
								append rblk compose/deep [
									wtext 100  static-size -1x20 (copy/part mold :item-data 100) with [color: (gt)]
								]
							]
							vblk: compose/deep [
								row [
									vform [ (vblk) ]
									vblack [ (rblk) ]
								]
							]
						
						][
							; BASIC BLOCK OF DATA
							blk-ctr: 0
							forall data [
								;print "^/---"
								item-data: first data
								;probe copy/part mold/all item-data 500
								item: to-string index? data
								blk-ctr: blk-ctr + 1
								gt: either odd? blk-ctr ['toggletext]['toggletext-odd]
								switch/default type?/word :item-data [
									block! [
										append vblk compose/deep [
											(gt) 50 (rejoin [to-string item " (block!)"]) static-size -1x20 with [idata: [(item-data)]] [inspect get in face 'idata (to-string item) (depth + 1)]
										]
									]
									word! [
										append vblk compose/deep [
											(gt) 50 (rejoin [to-string item " (word!)"]) static-size -1x20 with [idata: (to-lit-word item-data)] [inspect get in face 'idata (to-string item) (depth + 1)]
										]
									]
									set-word! [
										append vblk compose/deep [
											(gt) 50 (rejoin [to-string item " (word!)"]) static-size -1x20 with [idata: (to-string item-data)] [inspect get in face 'idata (to-string item) (depth + 1)]
										]
									]
									function! [
										append vblk compose/deep [
											(gt) 50 (rejoin [to-string item " (function!)"]) static-size -1x20 with [idata: first [(:item-data)]] [inspect get in face 'idata (to-string item) (depth + 1)]
										]
									]
								][
									append vblk compose/deep [(gt) 50 (rejoin [to-string item " (" type?/word :item-data ")"]) static-size -1x20 with [idata: (:item-data)] [inspect get in face 'idata (to-string item) (depth + 1)]]
								]
							]
							rblk: copy []
							data: head data
							blk-ctr: 0
							forall data [
								blk-ctr: blk-ctr + 1
								gt: either odd? blk-ctr [bg-clr] [bg-clr + 20.20.20]
								item-data: first data
								append rblk compose/deep [
									wtext 100  static-size -1x20 (copy/part mold :item-data 100) with [color: (gt)]
								]
							]
							vblk: compose/deep [
								row [
									vform [ (vblk) ]
									vblack [ (rblk) ]
								]
							]
						]
					]
				][
					; txt-block will mold the data if its not a string.
					append vblk txt-block :data
				]
				append vblk 'elastic

				vblk: compose/deep [
					row [
						vpane [
							row def-size 250x0 []
							banner  (either string? title [title][mold/all title]) font [style: [italic bold] ] edge [effect: 'bevel color: bg-clr size: 1x1]
							scrollpane [
								vpane [(vblk)]
							]
						]
						row static-size 5x5 []
					]
				]

				vblk: compose/deep [column [(vblk)]]
				vout

				vblk
			]


			;-    txt-block
			txt-block: func [
				data "any data is converted to string!"
				/local line blk
			][
				blk: copy []

				unless string? :data [
					data: mold/all :data
				]

				foreach line (parse/all data "^/") [
					append blk compose [lvtext as-is (line)]
				]
				blk: compose [column (blk)]
			]

			inspect dataset any [ttl "/"] 1
		]
	]
]
