REBOL [
	title: "Altme chat reader/exporter"
	author "Didier Cadieu"
	email: "didec | wanadoo - fr"
	file: %altme-chat-reader.r
	date: 03-june-2010
	version: 1.2.1
	purpose: {
		Display or export to html the content of an Altme chat group.

		Can be used in interractif or command-line mode.

		For usage, run the script with "-?" argument :
		"rebol.exe -s altme-chat-reader.r -?"
	}
	history: [
		1.0.0 02-06-2004 {first release.}
		1.0.1 04-08-2004 {CSS stylesheet changed for Firefox compatibility.}
		1.1.0 06-08-2004 {New display chat function, now realtime whatever the size of the group.}
		1.1.1 07-08-2004 {Add event filtering while scrolling the display chat window.
						  Also change the HTML export for a more english form.}
		1.2.0 27-01-2005 {}
		1.2.1 03-06-2010 {Some bugs removed. Html export enhanced with newlines in message as <BR>}
	]
	comment {
		There is still bugs to remove but it works.
	}
	library: [
	        level: 'advanced
	        platform: 'all
	        type: 'tool
	        domain: [gui html ui user-interface vid text-processing]
	        tested-under: [view 2.7.8.3.1 on "Windows 2k - Seven"]
	        support: none
	        license: 'bsd
	        see-also: none
	    ]

]

;*** Vars to adapt to your system installation if you do not want to set them each time
altme-path: %./
world-name: ""
group-name: ""
dest-file: %""
cmd-line: none

;***** Shorcuts to usefull functions
foreach w [hilight? hilight-range?] [
	if not value? w [set :w get in ctx-text :w]
]


;***** From Romano/Gabriele : the events consuming functions
context [
comment {
	set 'win-offset? func [
		{Given any face, returns its window offset. Patched by Romano Paolo Tenca}
		face [object!]
		/local xy
	] [
		xy: 0x0
		if face/parent-face [
			xy: face/offset
			while [face: face/parent-face] [
				if face/parent-face [
					xy: xy + face/offset + either object? face/edge [face/edge/size] [0]
				]
			]
		]
		xy
	]
}
	system/view/wake-event: func [port /local event no-btn p-f] bind [
		event: pick port 1
		if none? event [
			if debug [print "Event port awoke, but no event was present."]
			return false
		]
		awake event
	] in system/view 'self
	awake: func [event /local no-btn p-f] bind [
		either not p-f: pop-face [
			do event
			empty? screen-face/pane
		] [
			either all [
				event/type = 'key
				event/key = escape
			] [hide-popup] [
				either any [
					p-f = event/face
					all [
						event/face
						same? p-f/parent-face find-window event/face
						within? event/offset win-offset? p-f p-f/size
					]
				] [
					no-btn: false
					if block? get in p-f 'pane [
						no-btn: foreach item p-f/pane [if get in item 'action [break/return false] true]
					]
					if any [all [event/type = 'up no-btn] event/type = 'close] [hide-popup]
					do event
				] [
					either p-f/action [
						if not find [move time inactive] event/type [
							hide-popup
						]
						if find [time inactive resize close] event/type [do event]
					] [
						if find [resize offset time] event/type [do event]
					]
				]
				none? find pop-list p-f
			]
		]
	] in system/view 'self
	free: true
	set 'eat func [/only blk [block!]] [
		if free [
			free: false
			any [only blk: [move]]
			until [
				only: pick system/view/event-port 1
				not all [only find blk only/type]
			]
			if only [awake only]
			free: true
		]
	]
]

;***** Based on the %links.r script from R-Forces website (thanks to the authors)
ctx-link: context [
	links-list: []
	non-white-space: complement white-space: charset reduce [#" " newline tab cr #"<" #">"]
	to-space: [some non-white-space | end]
	skip-to-next-word: [some non-white-space some white-space]
	match-pattern: func [pattern url color] [
		compose [
			mark:
			(pattern) (either string? pattern [[to-space end-mark:]] [])
			(to-paren compose [
				append links-list copy/part mark end-mark
			])
			any white-space
		]
	]
	link-rule: clear []
	insert link-rule [some white-space |]
	foreach [pattern url color] reduce [
		"http://"    none                  none
		"www."       [join http:// text]   none
		"ftp://"     none                  none
		"ftp."       [join ftp:// text]    none
		"do http://" none                  crimson
		"do %"       none                  crimson
		["do [" (end-mark: second load/next skip mark 3) :end-mark]
					 [first reduce [load text text: copy/part text 2]]
										   crimson
	] [
		insert insert tail link-rule match-pattern pattern url color '|
	]
	insert tail link-rule 'skip-to-next-word
	; GC bug fixed now!
	use [mark end-mark text offset] [bind link-rule 'mark]

	set 'find-hyperlinks func [face] [
		clear links-list
		error? try [parse/all face/text [any link-rule]]
		links-list
	]
]

;*** Making Paths
build-paths: does [
	if not exists? worlds-path: to-file join altme-path %worlds/ [return 0]
	if not exists? world-path: join worlds-path dirize to-file world-name [return 1]
	if not exists? chat-path: join world-path %chat/ [return 2]
	3
]

worlds-list: copy []
groups-list: copy []
group-names-list: copy []
users-list: copy []

;*** Loadind the list of worlds
load-worlds-list: has [p wl] [
	wl: read worlds-path
	remove-each w wl [any [not find w "/" w = %temp/]]
	clear worlds-list
	forall wl [append worlds-list copy/part p: to-string first wl (length? p) - 1]
]

;*** Loading and filtering users and group list
load-users-set: does [
	users-data: load/all join world-path %users.set

	clear users-list
	clear groups-list
	foreach line users-data [
		parse line [
			set num integer!
			skip
			set nam string!
			to block!
			set bl block! (
				either find bl 'group [
					append groups-list reduce [num nam]
				] [
					append users-list reduce [num nam]
				]
			)
			to end
		]
	]
	append clear group-names-list sort extract next groups-list 2
]

;*** Loading chat file for this number
load-chat-name: func [chat-name [string!] /local pos msg date grp usr color zero blk text fg bg style] [
	if not pos: find groups-list chat-name [
		alert rejoin [ {The group "} chat-name {" was not found in this world !!}]
		quit
	]

	chat-data: load/all join chat-path [pick pos -1 ".set"]

	chat-data: next chat-data
	chat-list: copy []
	style: []
	foreach line chat-data [
		style: copy []
		bg: snow
		fg: black
		set [msg date grp usr color zero blk text] line
		parse blk [ 'font into [any ['b (append style 'bold) | 'i (append style 'italic) | 'fg set fg tuple! | 'bg set bg tuple!]]]
		append/only chat-list reduce [usr color text fg bg date style msg]
	]
]

to-htmlcolor: func [ color [ tuple! ] /local col c ] [
    join "#" [
        to-string copy/part at to-hex color/1 7 2
        to-string copy/part at to-hex color/2 7 2
        to-string copy/part at to-hex color/3 7 2
    ]
]

form-date: func [date /local d] [
	d: date
	d/time: d/time - d/zone + now/zone
	d/zone: 0:0
	rejoin [d/day "/" d/month "/" d/year " " d/time]
]

;*** Make all the job to export file
export-html: func [/no-browse /local emit result] [
	if empty? dest-file [alert "Enter a file name for saving first !" exit]

	result: make string! 1000
	emit: func [d] [append result d]

	emit rejoin [
		{<html><head><title>Altme group "} group-name {" content</title>
		<style type="text/css">
		td.u {font-weight: bold; text-align: right;}
		td.t {white-space: normal;}
		td.d {font-stretch: condensed; font-size: small;} </style></head><body>}
	]
	emit join {<h2>Content of group "} [group-name {" on } now/date { at } now/time </h2>]
	emit {<table style="width: 100%; text-align: left;" border="1" cellpadding="2" cellspacing="1">
		 <thead style="text-align: center; vertical-align: top; background-color: rgb(204, 204, 204);">
		 <tr><th style="width: 100px;">User </th><th>What they said </th>
		 <th style="width: 100px;">Date </th></tr>
		 </thead>
		 <tbody style="text-align: left; vertical-align: top;">}

	foreach line chat-list [
		emit join {<tr><td class="u" style="color: } [to-htmlcolor line/2 {;">} select users-list line/1 ":</td>"]
		emit join {<td class="t" style="} [
			any [(if line/4 <> black [join " color: " [to-htmlcolor line/4 ";"]]) ""]
			any [(if line/5 <> snow [join " background-color: " [to-htmlcolor line/5 ";"]]) ""]
			any [(if find line/7 'bold [" font-weight: bold;"]) ""]
			any [(if find line/7 'italic [" font-style: italic;"]) ""]

			{">} replace/all line/3 newline <br> {</td>}
		]
		emit join {<td class="d">} [form-date line/6 {</td></tr>^/}]
	]
	emit {^/</tbody></table></body></html>}

	write dest-file result
	if not no-browse [browse dest-file]
]

old-display-chat: func [/new /offset coord /local flh] [
	cnt: 0 lng: length? chat-list
	coord: any [coord 10x10]

	flh: flash "Generating..."
	make-msg-line: func [line [block!] vert-offset [integer!] /local lay t1 t2 t3] [
		lay: layout/tight compose [
			space 0x0 across
			style tx text font-size 11 with [color: snow]
			t1: tx 100 font [color: line/2] right bold (join select users-list line/1 ":")
			t2: tx 550 as-is font [color: line/4 style: line/7] line/3 with [color: line/5]
			t3: tx 110 form-date line/6 gray
		]
		t1/size/y: t3/size/y: max t1/size/y t2/size/y
		t1/offset/y: t2/offset/y: t3/offset/y: vert-offset
		lay/pane
	]

	scroll: func [of /local nb] [
		nb: f-chat/pane/size/y - f-chat/size/y
		f-chat/pane/offset/y: negate max 0 min nb of/y * 21 - f-chat/pane/offset/y
		f-sld/data: max 0 min 1 negate f-chat/pane/offset/y / max 1 nb
		show [f-chat f-sld]
	]

	scroll-feel-lay: func [lay] [
		lay/feel: make lay/feel [
			detect: func [face event /local nb] [
				switch event/type [
					scroll-line [scroll event/offset]
;					resize [resize max min-size win-lay/size]
				]
				event
			]
		]
	]

	chat-lay: layout/offset [
		across origin 8x8 space 0x4
		backdrop effect [gradient 1x1 100.100.100 150.150.180]
		vh2 join "Altme '" [group-name "' group contents"]
		pad 200x0 btn "HTML Export" [export-html] return
		f-chat: box 750x550 edge [size: 2x2 color: 150.150.150 effect: 'ibevel] with [
			append init [pane: layout/tight/size [] size]
		]
		f-sld: scroller 16x550 [f-chat/pane/offset/y: negate max-y - f-chat/size/y * value show f-chat]
	] coord
	max-y: 0
	foreach line chat-list [
		append f-chat/pane/pane sub: make-msg-line line max-y
		max-y: max-y + 1 + sub/1/size/y
	]
	f-chat/pane/size/y: max-y
	f-sld/redrag f-chat/size/y / max 1 max-y
	f-sld/step: 1 / max 1 lng

	unview flh
	view/new chat-lay
	scroll-feel-lay chat-lay
	if not new [do-events]
]

display-chat: func [/new /offset coord /local flh lng foffset-idx t1 t2 t3 fake-offset max-offset max-y] [
	lng: length? chat-list

	coord: any [coord 10x10]

	flh: flash/offset "Generating..." coord

	make-msg-line: func [vert-offset /local lay] [
		lay: layout/tight compose [
			space 0x0 across
			style tx text font-size 11 with [color: snow]
			t1: tx 100 right bold ""
			t2: txmsg 543 as-is "" font []
			t3: tx 117 gray snow - 5.5.5 ""
		]
		t1/offset/y: t2/offset/y: t3/offset/y: vert-offset
		lay/pane
	]

	;*** Dichotomical search of the immediate lower or equal y offset
	find-offset: func [offset /local b e c] [
		b: 0 e: lng
		while [e - b > 1] [
			either offset < pick offset-idx to-integer (c: e + b / 2) [
				e: to-integer c
			][
				b: to-integer c
			]
		]
		b
	]

	;*** Fill/resize/move the faces with messages according the offset
	scroll: func [of /absolute /local nb o oi oi2 sub i fcp cl oy sy] [
;tms: now/time/precise
		either absolute [fake-offset: 0 o: 1][o: 21]
		nb: max-offset - f-chat/size/y
		fake-offset: max 0 min nb of/y * o + fake-offset
		o: find-offset fake-offset
		fcp: f-chat/pane/pane
		i: 1
		until [
			cl: chat-list/:o
			oi: at offset-idx o
			oi2: oi/2
			oi: oi/1
			;fcp/:i/text: form o
			fcp/:i/text: join select users-list cl/1 ":"
			fcp/:i/font/color: cl/2
			fcp/:i/offset/y: oy: oi - fake-offset
			fcp/:i/size/y: sy: oi2 - oi - 1
			fcp/:i/show?: true
			i: i + 1
			fcp/:i/text: cl/3
			fcp/:i/font/colors/1: fcp/:i/font/colors/2: fcp/:i/font/color: cl/4
			fcp/:i/color: cl/5
			fcp/:i/font/style: cl/7
			fcp/:i/offset/y: oy
			fcp/:i/size/y: sy
			fcp/:i/show?: true
			i: i + 1
			fcp/:i/text: form-date cl/6
			fcp/:i/offset/y: oy
			fcp/:i/size/y: sy
			fcp/:i/show?: true
			i: i + 1
			o: o + 1
			any [o > lng oi - fake-offset > f-chat/size/y]
		]
		fcp: at fcp i
		while [not tail? fcp] [fcp/1/show?: false fcp: next fcp]
		f-sld/data: max 0 min 1 fake-offset / max 1 nb
		show [f-chat f-sld]
;print now/time/precise - tms
	]

	scroll-feel-lay: func [lay] [
		lay/feel: make lay/feel [
			detect: func [face event /local nb] [
				switch event/type [
					scroll-line [scroll event/offset]
;					resize [resize max min-size win-lay/size]
				]
				event
			]
		]
	]

	;*** Chat window
	chat-lay: layout/offset [
		across origin 8x8 space 0x4
		backdrop effect [gradient 1x1 100.100.100 150.150.180]
		vh2 join "Altme '" [group-name "' group contents"]
		pad 200x0 btn "HTML Export" [export-html] return
		f-chat: box 750x550 edge [size: 2x2 color: 150.150.150 effect: 'ibevel] with [
			append init [pane: layout/tight/size [] size]
		]
		f-sld: scroller 16x550 [
			scroll/absolute max-offset - f-chat/size/y * value * 0x1
			eat
			show f-chat
		]
	] coord


	;*** Generate enough faces for worst case (1 line per message) and the window size
	max-y: 0
	until [
		append f-chat/pane/pane sub: make-msg-line max-y
		(max-y: max-y + 1 + sub/1/size/y) > (f-chat/size/y + 50)
	]
	;*** Compute message offset according each text size
	offset-idx: make block! lng
	append offset-idx max-offset: fake-offset: real-offset: 0
	foreach line chat-list [
		t1/text: join select users-list line/1 ":"
		t2/text: line/3
		t2/font/style: line/7
		append offset-idx max-offset: max-offset + 5 + pick (max size-text t1 size-text t2) 2
	]

	scroll 0x0
	f-sld/redrag f-chat/size/y / max 1 last offset-idx
	f-sld/step: 1 / max 1 lng

	unview/only flh
	view/new chat-lay
	scroll-feel-lay chat-lay
	if not new [do-events]
]

run-code: func [/text txt /selected /local start end][
    if all [
    	any [
			all [
				selected
		        hilight?
		        set [start end] hilight-range?
		    ]
		    all [
		    	text
		    	start: txt
		    	end: tail txt
			]
		]
		confirm "Confirm that you want to run this code?"
	] [
		act: copy/part start end
		; make the string a valid script
		if not script? act [act: join "REBOL []^/" act]
		; add an 'halt to the end to see the results
		append act "^/halt"

		write %tempcode.r act
		launch %tempcode.r
	]
]

stylize/master [
	field-path: box with [
		size: 250x24
		fld: but: path: none
		mode: 'Open
		update: func [value] [
			append clear file to-file value
			do-face self file
		]
		append init [
			use [sz slf eff] [
				slf: self
				file: any [file %""]
				text: any [all [file to-string file] ""]
				sz: any [size 220x24]
				size/y: max size/y 24
				but: make-face/spec 'button [
					size: as-pair 22 sz/y
					parent-face: slf
					user-data: slf/user-data
					action: func [face value /local cmd][
						value: either empty? fld/text [%./][to-file fld/text]
						cmd: copy [request-file/title/file]
						if mode <> 'Open [append first cmd mode]
						append cmd reduce [any [face/user-data to-string mode] "Ok" value]
						if block? value: do cmd [
							value: first value
							append clear fld/text to-string value
							show fld
							update value
						]
					]
				]
				image: load #{
					4749463839610F000D00830000000000848400FF00FFFFFF00FFFFFFFFFFFFFF
					FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF21F904
					000000FF002C000000000F000D0000043250C83981A558822A76CE97E5812231
					10624A01676B9A63F7BA67CCBE696EE141EFFB96DA6FB801A0863F8F0509ACE8
					549308003B
				}
				eff: but/effects
				forall eff [
					append first eff reduce [
						'draw compose [
							image (but/size - image/size / 2 - 1x2) (image) 255.0.255
						]
					]
				]
				image: none
				sz/x: sz/x - but/size/x
				fld: make-face/spec 'field [
					text: slf/text size: sz parent-face: slf
					action: func [face value][
						if all [mode = 'path #"/" <> last value] [append value #"/"]
						update face/text
					]
				]
				but/offset/x: fld/size/x
			]
			append pane: copy [] reduce [fld but]
		]
		multi: make multi [file: func [face blk][if pick blk 1 [face/file: first blk]]]
		words: [req-title [new/user-data: second args next args] save [new/mode: 'Save args] path [new/mode: 'path args]]
	]

	txmsg: text font-size 11 with [
		color: snow
		alt-action: func [face value][write clipboard:// face/text request/ok/type "Text copied." 'info]
		remove/part init 3 ; remove the feel/hot that I don't want
		feel: make feel bind bind [
			engage: func [face act event /local url txts fncs lnks][
				switch act [
					down [
						either equal? face focal-face [unlight-text] [focus/no-show face]
						caret: offset-to-caret face event/offset
						show face
						face/action face face/text
					]
					up [
						if highlight-start = highlight-end [unfocus]
					]
					over [
						if not-equal? caret offset-to-caret face event/offset [
							if not highlight-start [highlight-start: caret]
							highlight-end: caret: offset-to-caret face event/offset
							show face
						]
					]
					key [
						if 'copy-text = select keymap event/key [
							copy-text face unlight-text
						]
					]
					alt-up [
						txts: copy []
						fncs: copy []
						foreach [t f] [
							"Copy text to clipboard" [write clipboard:// face/text request/ok/type "Text copied." 'info]
							"Do text" [run-code/text face/text]
							"Do selected text" [run-code/selected]
							"Do nothing, thanks" []
						] [
					 		append txts t
					 		append fncs func [face value] :f
					 	]
					 	lnks: find-hyperlinks face
					 	foreach t lnks [
					 		append txts join "Browse" t
					 		append fncs func [face value] reduce ['browse t]
					 	]
						choose/style/offset txts func [face] [
							do pick fncs index? find txts face/text face face/text
						] get-style 'chbut event/offset + win-offset? face
;						choose/style/window/offset txts func [face] [
;							do pick fncs index? find txts face/text face face/text
;						] get-style 'chbut chat-lay event/offset + win-offset? face
						false
					]
				]
			]
		] in ctx-text 'self in system/view 'self
	]

	chbut: choice 300x24 red  blue [
		print face/text
	]
]

interactif-mode: does [
	read-chat: func [/display /export /local p] [
		either exists? p: to-file f-altme/text [altme-path: p] [alert "Path to Altme is incorrect !" exit]
		if build-paths < 3 [return false]
		load-users-set
		load-chat-name group-name
	]

	update-all: func [/no-group /init /local r p lng] [
		r: build-paths
		either r >= 1 [
			load-worlds-list
			f-world/sld/redrag f-world/lc / max 1 length? worlds-list
			f-world/sld/data: 0
			if init [alter f-world/picked world-name]
			show f-world
		] [hide f-world]
		either r >= 3 [
			if not no-group [
				load-users-set
				f-group/sld/redrag f-group/lc / max 1 length? group-names-list
				f-group/sld/data: 0
			]
			either p: find group-names-list group-name [
				if init [
					alter f-group/picked group-name
					lng: length? group-names-list
					;f-group/sn: max p: subtract index? p 1 subtract lng: length? group-names-list f-group/lc
					f-group/sld/data: max 0 min 1 (subtract index? p 1) / (1 + lng - f-group/lc)]
			][clear group-name]
			show f-group
			build-paths
		] [hide f-group]
		f-status/text: copy world-name
		all [not empty? group-name append f-status/text join " | " group-name]
		show f-status
		either all [not empty? group-name] [show f-buttons] [hide f-buttons]

	]

	main-lay: layout [
		backdrop effect [gradient 1x1 100.100.100 150.150.180]
		style fpath field-path 328
		style pan panel edge [size: 2x2 color: 110.110.110 effect: 'ibevel]
		origin 4x4 space 4x4
		vh3 join "Altme Chat reader / HTML exporter " system/script/header/version
		vtext "Path to Altme.exe program :"
		f-altme: fpath altme-path [update-all] path req-title "Select the Altme.exe file in its installation directory"
		across
		pan [
			space 4x2 origin 4x4
			vtext "World Name :"
			f-world: text-list 150 data worlds-list [world-name: value update-all] with [show?: false]
		]
		pan [
			space 4x2 origin 4x4
			vtext "Group Name :"
			f-group: text-list 150 data group-names-list [group-name: value update-all/no-group] with [show?: false] return
		] return
		vtext "File where to export :" return
		f-file: fpath dest-file save return
		pan [
			across origin 4x2 space 4x4
			f-status: vtext 184x22 yellow
			f-buttons: panel [
				across
				btn "View" 60 [all [read-chat display-chat/new/offset main-lay/offset + 10x10]]
				btn "Export" 60 [all [dest-file read-chat export-html]]
			]
		]
;		return btn "Monitor" [do %/E/rebol/view/anamonitor.r]
	]
	view/new main-lay
	update-all/init
	do-events
]

;======== Start of program =========

go: 0
usage: false
if block? args: system/options/args [
	parse args [
		any [
			"-path" set p string! (altme-path: to-file load p go: go or 1) |
			"-world" set p string! (world-name: to-string p go: go or 2) |
			"-group" set p string! (group-name: to-string p go: go or 4) |
			"-file" set p string! (dest-file: to-file load p go: go or 8) |
			"-quiet" (alert: func [t][]) |
			"-log" (alert: func [t][write/lines/append %altme-chat-reader.log t]) |
			"-do" set p string! (cmd-line: p) |
			"-interractif" (go: -1) |
			["?" | "?" | "-help"] (usage: true) |
			skip (usage: true)
		]
	]
]

if all [not usage go <= 0] [interactif-mode quit]

either all [not usage go >= 7] [
	if build-paths < 3 [alert "Wrong parameters, check altme-dir,^/ world name and group name then try again!" exit]
	load-users-set
	load-chat-name group-name
	either none? dest-file [
		display-chat
	] [
		export-html/no-browse
	]
	if cmd-line [do load cmd-line]
	quit
] [
	inform layout [
		backcolor black
		vh4 either go = 0 [system/script/header/title]["Something is wrong in your command line arguments !"]
		vtext yellow either go = 0 [""] [form args]
		pad 0x10
		vtext as-is rejoin [
{USAGE:
	} to-local-file system/options/boot " -s "	to-local-file any [system/options/script join what-dir system/script/header/file] { [options]

	Where options are :	[-path ALTMEPATH] [-world WORLDNAME] [-group GROUPNAME]
				[-file FILENAME] [-do "COMMAND LINE"] [-quiet] [-log] [-interractif]

	-path ALTMEPATH		= ALTMEPATH is the path to the running Altme.exe program in rebol format.
					   If there is spaces in the name, use http syntax or double quote to enclose it.
					   I.e.: -path %/c/program files/altme/
	-world WORLDNAME		= WORLDNAME is the name of the Altme world to access.
					   If there is spaces in the name, use double quote to enclose it.
	-group GROUPNAME		= GROUPNAME is the name of the group to read or export.
					   If there is spaces in the name, use double quote to enclose it.

			This third 3 options are used to initialize the interractif mode. The following
			one process the export in HTML without user interraction.

	-file FILENAME		= FILENAME is the full path to the file where to export in rebol format.
					   If there is spaces in the name, use http syntax or double quote to enclose it.
					   I.e.: -file %/c/temp/chat.html
	-do "COMMAND LINE"	= "CMD LINE" is the command to applied to the export file after export.
					   Use 'dest-file in the code as the name of the file where the chat was export.
					   For example, you can execute a command to copy the file by FTP :
					   "write ftp://user:pass@my-site.com read dest-file"
	-quiet				= without this options, the errors that occur are displayed in a window.
					   This option desactivate the windows, except this usage window.
	-log				= use this options instead of -quiet to redirect the error in the file
					   altme-chat-reader.log
	-interractif			= force the interractif mode in case that you have specified the -file option.
}
		]
	]
	quit
]
