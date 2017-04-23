REBOL [
	title: "Mini-edit-do"
	file: %mini-edit-do.r
	author: "Marco Antoniazzi"
	Copyright: "(C) 2012 Marco Antoniazzi. All Rights reserved"
	email: [luce80 AT libero DOT it]
	date: 12-05-2012
	version: 0.5.4
	Purpose: "Helps test short programs (substitutes console)"
	History: [
		0.0.1 [30-04-2012 "First version"]
		0.5.1 [01-05-2012 "Fixed using view and quit"]
		0.5.2 [05-05-2012 "Added undo and redo"]
		0.5.3 [10-05-2012 "Fixed last probe"]
		0.5.4 [12-05-2012 "Added halt and other minor fixes"]
	]
	comment: {30-Apr-2012 GUI automatically generated by VID_build. Author: Marco Antoniazzi.
		Derived directly from ParseAid.r
	}
	library: [
		level: 'intermediate
		platform: 'all
		type: 'tool
		domain: [debug testing]
		tested-under: [View 2.7.8.3.1]
		support: none
		license: 'BSD
		see-also: %parse-aid.r
	]
	todo: {
		- ask to save before exit if something modified
		- scroll-wheel
		- options: 
			- set max area-results length
			- set max dumped obj length
			- choose between head or tail of dumped obj
	}
]

; patches
	old-length: 0
	old-prin: :prin old-print: :print ; use these to output to console
	old-quit: :quit
	quit: does [
		; closing all windows (except ours) is similar to quitting ...
		foreach face next System/view/screen-face/pane [unview/only face]
	]
	halt: does [] ; avoid opening console
	prin: func [value] [
		either (100000 + old-length) > length? get-face area-results [ ; avoid fill mem
			set-face area-results append get-face area-results form reduce value
			system/view/vid/vid-feel/move-drag area-results/vscroll/pane/3 1 ; autoscroll down
			wait 0.0001 ; avoid blocking the gui
		][
			alert "ERROR. Probable infinite loop."
			reset-face area-results
			throw
		]
	]
	print: func [value] [prin value prin newline]
	probbed: none
	probe: func [value] [probbed: value print mold :value :value]
	*isolator: context [ ; taken from "REBOL Word Browser (Dictionary)" Author: "Carl Sassenrath"
		view: func
			first get in system/words 'view
			head insert copy/deep second get in system/words 'view [new: true]
	]
	ctx-text/back-word: func [str /local s ns] [
		set [s ns] svv/word-limits
		any [all [ns: find/tail/reverse str ns ns: find/reverse ns s next ns] head str]
	]
;
context [ ; protect our functions from being redefined
; file
	change_title: func [/modified] [
		clear find/tail main-window/text "- "
		if modified [append main-window/text "*"]
		append main-window/text to-string last split-path any [job-name %Untitled]
		main-window/changes: [text] show main-window
	]
	open_file: func [/local file-name job] [
		until [
			file-name: request-file/title/keep/only/filter "Load a rules file" "Load" "*.r"
			if none? file-name [exit]
			exists? file-name
		]

		job-name: file-name
		job: read file-name
		set-face area-test job

		named: yes
		change_title
		saved?: yes
	]
	save_file: func [/as /local file-name filt ext response job] [
		;if empty? job [return false]
		if not named [as: true]

		if as [
			filt: "*.r"
			ext: %.r
			file-name: request-file/title/keep/only/filter "Save as Rebol file" "Save" filt
			if none? file-name [return false]
			if not-equal? suffix? file-name ext [append file-name ext]
			response: true
			if exists? file-name [response: request rejoin [{File "} last split-path file-name {" already exists, overwrite it?}]]
			if response <> true [return false]
			job-name: file-name
			named: yes
		]
		flash/with join "Saving to: " job-name main-window

		job: get-face area-test
		write job-name job

		wait 1.3
		unview
		change_title
		saved?: yes
	]
; do
	err?: func [blk /local arg1 arg2 arg3 message err][;11-Feb-2007 Guest2
		if not error? err: try blk [return :err]
		err: disarm err
		set [arg1 arg2 arg3] reduce [err/arg1 err/arg2 err/arg3]
		message: get err/id
		if block? message [bind message 'arg1]
		print ["**ERROR:" form reduce message]
		print ["**Near:" either block? err/near [mold/only err/near][err/near]]
		none
	]
	test: func [/local result temp] [
		if get-face check-clear-res [reset-face area-results old-length: 0]
		err? [
			probbed: none
			doing: true
			set/any 'result do bind load get-face area-test *isolator
			doing: false
			old-length: old-length + length? get-face area-results
			if not unset? get/any 'result [
				if any-function? :result [probe mold :result exit]
				if object? result [
					if 10000 < length? temp: mold/only result [result: copy/part temp 10000 append result "..."]
				]
				if not equal? probbed result [probe result]
			]
		]
	]
; gui
	;do %area-scroll-style.r ;Copyright: {GNU Less General Public License (LGPL) - Copyright (C) Didier Cadieu 2004} 
	do decompress ; %area-scroll-style.r Copyright: {GNU Less General Public License (LGPL) - Copyright (C) Didier Cadieu 2004} 
		64#{
		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
		d0zT9CAeX7clsTQOh+EPhP58hdkbAAA=
		}
	rezize-faces: func [siz [pair!] /move] [
		area-test/ar/line-list: none ; to reactivate auto-wrapping

		text-results/offset: text-results/offset + (siz * 0x1)
		area-results/offset: area-results/offset + (siz * 0x1)
		resize-face/no-show area-test area-test/size + (siz * 1x1)
		resize-face/no-show area-results area-results/size + (siz * 1x0)
		if move [
			resize-face/no-show area-results area-results/size + (siz * 0x-1)
		]
	]
	feel-move: [
		engage-super: :engage
		engage: func [face action event /local prev-offset] [
			engage-super face action event
			if find [over away] action [
				prev-offset: face/offset
				face/offset: 0x1 * (face/old-offset + event/offset) ; We cannot modify face/old-offset but why not use it?
				face/offset: 0x1 * second confine face/offset face/size area-test/offset + 0x100 area-results/offset + area-results/size - 0x100
				face/offset: face/offset + 4x0 ; ?? must add spacing

				if prev-offset <> face/offset [
					rezize-faces/move (face/offset - prev-offset * 0x1)
					show main-window
				]
			]
		]
	]
	;append system/view/VID/vid-styles area-style ; add to master style-sheet
	main-window: center-face layout [
		styles area-style
		do [sp: 4x4] origin sp space sp
		Across
		btn "(O)pen..." #"^O" [open_file]
		btn "(S)ave" #"^S" [save_file]
		pad (sp * -1x0)
		btn "as..." [save_file/as]
		btn "Undo" #"^z" [area-test/undo]
		btn "(R)edo" #"^r" [area-test/redo]
		btn "(D)o script" #"^D" yellow [test area-test]
		btn "H(a)lt" #"^A" red [if doing [doing: false make error! "Halt"]]
		btn "Clear (T)est" #"^T" [reset-face area-test]
		btn "Clear R(e)sults" #"^e" [reset-face area-results old-length: 0]
		pad 0x1
		check-clear-res: check-line "before every do"
		return
		Below
		style area-scroll area-scroll 650x200 hscroll vscroll font-name font-fixed para [origin: 2x0]; Tabs: 16]
		text-test: text bold "Test"
		area-test: area-scroll {print "Hello world!"} with [append init [deflag-face self/ar 'tabbed]]
		button-balance: button "-----" 650x6 gray feel feel-move edge [size: 1x1] font [size: 6]
		text-results: text bold "Results"
		area-results: area-scroll silver read-only
		key escape (sp * 0x-1) [ask_close]
	]
	main-window/user-data: reduce ['size main-window/size]
	insert-event-func func [face event /local siz] [
		if event/face = main-window [
			switch event/type [
				close [
					ask_close
					return none
				]
				resize [
					face: main-window
					siz: face/size - face/user-data/size     ; compute size difference
					face/user-data/size: face/size          ; store new size

					rezize-faces siz
					button-balance/offset: button-balance/offset + (siz * 0x1)
					button-balance/size: button-balance/size + (siz * 1x0)
					show main-window
				]
				scroll-line [either event/offset/y < 0 [scroll-drag/back/page area-test/vscroll] [scroll-drag/page area-test/vscroll]]
			]
		]
		event
	]
	ask_close: does [
		either not saved? [
			switch request ["Exit without saving?" "Yes" "Save" "No"] reduce [
				yes [old-quit]
				no [if save_file [old-quit]]
			]
		][
			if confirm "Exit now?" [old-quit]
			;quit
		]
	]
; main
	doing: false
	
	job-name: none
	named: no
	saved?: yes
	main-title: join copy System/script/header/title " - Untitled"
	view/title/options main-window main-title reduce ['resize 'min-size main-window/size + system/view/title-size + 8x10 + system/view/resize-border]
] ; context