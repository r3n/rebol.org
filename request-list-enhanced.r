rebol [
	Title: "Request List Enhanced"
	Date:  10-Dec-2005
	Author: ["Mike Yaunish"]
	Version: 0.9.1
	Email: [%mike.yaunish--shaw--ca]
	file: %request-list-enhanced.r
	Comment: {Text-list Improvements by Carl Sassenrath & Updates by Paul Tretter.
              request-list-auto-fill from REBOL mailing list author unknown. 
              request-list-enhanced by Mike Yaunish. 
    }
    Rights: "Copyright 2000-2005 REBOL Technologies. All rights reserved."
	License: {
		Users can freely modify and publish this code under the condition that it is
		executed only with languages from REBOL Technologies, and user must include this
		header as is. All changes may be freely included by other users in their software
		(even commercial uses) as long as they abide by these conditions.
	}
	Purpose: {
		An enhancement to the regular request-list that allows selecting items from a request list 
		by typing in the first few characters of the item. Works with text, word and number lists.
		Designed to make optimum use of the keyboard. 
		- New refinement request-list-enhanced/return-index will return the index of the item not the value.
		- Keys used; cursor up, down, page-up, page-down, control+home, control+end, escape
	}             
	History: [
		0.9.0 [ 9-Dec-2005 {Initial beta version published to rebol.org} mike.yaunish@shaw.ca ]
        0.9.1 [ 12-Dec-2005 {Changed the following behaviours so that the user can't escape without a valid selection:
        					 - Changed the behaviour when the enter key is pressed with a non-matching string.
        					 - Added handling of tab key and shift+tab to move up and down the list.}
        ]
    ]
	library: [
        level: 'advanced
        platform: 'all
        type: [function module tool demo]
        domain: [gui patch ui]
        tested-under: [View 1.3.1 on [win2k] ]
        domain: [ftp game]
        tested-under: none
        support: none
        license: 'public-domain
        see-also: none
    ]
]

request-list-enhanced-ctx: make object! [
	request-list-styles: stylize [
		request-list-auto-fill: field with [
			feel: make feel [
				engage: func [
					face act event index
				] [

					switch act [
						down [
							either face <> system/view/focal-face [
								focus face
							] [
								system/view/highlight-start: system/view/highlight-end: none system/view/caret: offset-to-caret face event/offset show face
							]
						]
						over [
							if system/view/caret <> offset-to-caret face event/offset [
								if not system/view/highlight-start [
									system/view/highlight-start: system/view/caret
								]
								system/view/highlight-end: system/view/caret: offset-to-caret face event/offset show face
							]
						]
						key [
							ctx-text/edit-text face event act 
							; Added these event keys here because insert-event-func has caused some 
							; problems with previously opened windows.
							switch event/key [
								down [move-selection 1]
								#"^-" [ ; tab key
									either event/shift [
									   	move-selection -1    
									][
										move-selection 1   	    
									]	    	    
								]
								page-down [move-selection (a-text-list/lc - 1)]
								page-up [move-selection (-1 * (	a-text-list/lc - 1)	)]
								home [
									if event/control [move-selection (-1 * (length? a-text-list/data))]
								]
								end [if event/control [move-selection (length? a-text-list/data)]
								]
								up [move-selection -1]
								#"^M" [ ; return key
									face/action face face/text
								]
							]	    
							if all [
								char? event/key not empty? face/text find ctx-text/keys-to-insert event/key
							] [
								search face
							]
						]
					]
				]
			]
			search: func [
				face /local word
			] [
				word: copy face/text
				foreach item face/user-data [
					if equal? word copy/part item (
						length? word
					) [
						face/text: copy item system/view/focal-face: face system/view/highlight-start: skip face/text length? word system/view/highlight-end: tail face/text system/view/caret: tail face/text
						show face
						if flag-face? face search-action [
							face/search-action face
						]
						exit
					]
				]
			]

			words: [
				data [
					new/user-data: second args next args
				]
				search-action [
					flag-face new search-action args
				]
			]
		]
		; end of request-list-auto-fill style. ********************************************************************************************************************

		request-text-list: txt 200x200 with [
			feel: none
			color: snow
			colors: reduce [snow snow - 32	]
			sz: ; size of the list window
			iter: ; the text face displayed on each line
			sub-area: ; the face that shows the list
			sld: ; scroll bar face
			sn: ; scroll bar integer offset into the data
			lc: ; lines of text to display
			picked: ; selected items
			picked-index: ; current index of picked item
			cnt: ; current index into the data
			act: ; action taken on click
			action-single: ; action taken on single click
			slf: ; pointer to list-face (self)

			text-pane: func [
				face id
			] [
				if pair? id [
					return 1 + second id / iter/size
				]
				iter/offset: iter/old-offset: id - 1 * iter/size * 0x1
				if iter/offset/y + iter/size/y > size/y [
					return none
				]
				cnt: id: id + sn
				if iter/text: pick data id [
					if flag-face? slf format [
						iface: slf/iter reduce first iter-format
					]
					iter
				]
			]

			update: has [
				item value old-sn cur-index old-index
			] [
				sld/redrag lc / max 1 length? data
				if item: find data picked/1 [
					old-sn: sn
					cur-index: index? item
					if not all [( cur-index > old-sn ) ( cur-index < ( old-sn + lc + 1 )) ] [
						either cur-index <= old-sn [
							sn: max (cur-index - 1)	0
						] [
							sn: cur-index - lc
						]
						old-index: cur-index
					]
					sld/data: ((max 1 sn) / (length? data) )
				] [
					sld/value: 0.0
					pane/offset: 0x0
				]
				self
			]

			resize: func [
				new /x /y /local tmp
			] [
				either any [
					x y
				] [
					if x [
						size/x: new
					]
					if y [
						size/y: new
					]
				] [
					size: any [
						new size
					]
				]
				pane/size: sz: size
				sld/offset/x: first sub-area/size: size - 16x0
				sld/resize/y: size/y
				iter/size/x: first sub-area/size - sub-area/edge/size
				lc: to-integer sz/y / iter/size/y
				self
			]

			append init [
				sz: size
				sn: 0
				slf: :self
				act: :action
				if none? data [	data: any [	texts copy [] ]
				]
				picked: copy [
				]
				iter: make-face/size 'txt sz * 1x0 + -16x20
				iter/para: make self/para [
					origin: 2x0
				]
				iter/font: make self/font [
				]
				lc: to-integer sz/y / iter/size/y: second size-text iter
				iter/feel: make iter/feel [
					redraw: func [
						f a i
					] [
						iter/color: color
						if flag-face? slf striped [
							iter/color: pick next colors odd? cnt
						]
						if all [
							find picked iter/text cnt = picked-index
						] [
							iter/color: svvc/field-select
						]
					]
					engage: func [
						f a e
					] [
						if a = 'down [
							if cnt > length? slf/data [
								exit
							]
							; If not extended selection, clear other selections:
							if not e/control [
								f/state: cnt clear picked
							]
							alter picked f/text
							picked-index: cnt
							if flag-face? slf single-click [
								do :single-click-action slf f/text
							]

							if e/double-click [
								do :act slf f/text
							]
						]
						if a = 'up [
							f/state: none
						]
						show pane
					]
				]
				pane: layout/size [
					origin 0 space 0
					sub-area: box slf/color sz - 16x0 ibevel with [
						pane: :text-pane
					]
					at sz * 1x0 - 16x0
					sld: scroller sz * 0x1 + 16x0 [
						if sn = value: max 0 to-integer value * ((
								1 + length? slf/data
							)
							- lc
						) [
							exit
						]
						sn: value
						show sub-area
					]
				]
				size
				pane/offset: 0x0
				sld/redrag lc / max 1 length? data
			]

			words: [
				data [
					new/text: pick new/texts: second args 1 next args
				]
				striped [
					flag-face new striped args
				]
				single-click [
					flag-face new single-click args
				]
				format [
					flag-face new format iter-format: next args
				]
			]
		]
	]
    
    select-this-item: func [new-index] [
		a-text-list/picked-index: new-index
		a-text-list/picked: reduce [to-string (	pick a-text-list/data a-text-list/picked-index )]
		show a-text-list/update
		a-field/text: copy first a-text-list/picked
		show a-field
		focus a-field
	]
    
	move-selection: func [direction /local new-index] [
		new-index: ((a-text-list/picked-index) + direction)
		if (new-index < 1) [
		    new-index: 1
		]
		if (new-index > (length? a-text-list/data)) [
			new-index: length? a-text-list/data
		]
		select-this-item new-index
	]
	
	set 'request-list-enhanced func [
	    titl [ string!] {Title of requester}
		alist [	block! ] {List of data}
		/offset where [pair!]  "xy -- Offset of window on screen"
		/return-index "return the index value"
		/local return-value all-strings orig-alist
	] [ 
	    all-strings: true
	    orig-alist: copy alist
	    alist: copy []
	    foreach i orig-alist [ 
	        either type? i <> string![
	            all-strings: false
	            append alist to-string i        
	        ][
	            append alist i           
	        ]                
	    ]
		inform/title/offset l: layout [
			styles request-list-styles
			a-text-list: request-text-list
			single-click ; default action is double-click
			with [
				single-click-action: func [
					f v
				] [
					a-field/text: copy first a-text-list/picked show a-field
					focus a-field
				]
			]
			data alist [
				; double-click-action
				return-the-selection 
			]
			across
			a-field: request-list-auto-fill data alist search-action
			with [
				search-action: func [f] [
					a-text-list/picked-index: index? find a-text-list/data f/text
					a-text-list/picked: reduce [to-string (	pick a-text-list/data a-text-list/picked-index)	]
					show a-text-list/update
				]
			] [
				return-the-selection
			]
			return
			button "OK" [ return-the-selection	]
			button "CANCEL" keycode escape [ return-the-selection/value none	]
			do [
				return-the-selection: func [ /value the-value ] [
				    either value [ 
				        return-value: the-value
				        hide-popup
				    ][
    		        	either (a-field/text = first a-text-list/picked) [
    		        		either return-index [
    			        		return-value: a-text-list/picked-index
    				        ] [
    				            either not all-strings [
    				                return-value: pick orig-alist a-text-list/picked-index
    				            ][
    				                return-value: first a-text-list/picked           
    				            ]                
    					        
    				        ]
    				        hide-popup
    			        ][
    			           focus a-field
    			        ]	    
    			    ]
		        ]
		        select-this-item 1
			]
		] titl either offset [where] [ system/view/screen-face/size - l/size / 2 ]
		return return-value
	]
]
; *** end of object ***

demo: does [
	sample-word-list: sort first system/words
	sample-numeric-list: [ 1 2 3 4 12 13 14 15 31 32 33 34 35 36 125 305 315 344 678 987 1003 ]
	sample-text-list: []
	foreach i first system/words [ append sample-text-list to-string i ]
	sort sample-text-list
	view layout [ 
		across 
		button 150 keycode 'F3 "word list ^-(F3)" [ g/text: type? f/text: request-list-enhanced "Type some text in:" sample-word-list  show [ f g ]] return
		button 150 keycode 'F4 "text list ^-(F4)" [ g/text: type? f/text: request-list-enhanced "Type some text in:" sample-text-list  show [ f g ]] return
		button 150 keycode 'F5 "numberic ^- (F5)" [ g/text: type? f/text: request-list-enhanced "Type some numbers in:" sample-numeric-list  show [ f g ] ] return
		button 150 keycode 'F6 "return-index ^- (F6)" [ g/text: type? f/text: request-list-enhanced/return-index "Type some text in:" sample-text-list  show [ f g ] ] return
		return
		label "return type:" g: field  return
		label "return value:" f: field 
		
	]
]
; uncomment line below to see how it works 
; demo halt
