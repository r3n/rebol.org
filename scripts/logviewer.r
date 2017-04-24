REBOL [
	File: %logviewer.r
	Date: 13-Oct-2006
	Purpose: "Monitor log files. Please read included readme for further information"
	Title: "Logviewer"
	Author: "Daniel Szmulewicz"
	Mail: mailto:danielsz@freeshell.org
	library: [
	        level: 'intermediate
	        platform: 'all
	        type: [tool]
	        domain: [visualization ]
	        tested-under: "Windows"
	        support: "email me"
	        license: 'cc-by
	        see-also: "logging"
		]
	readme: {
						Logviewer
						*********
	
		Definition
		----------
	
		This program is intended to monitor log files easily
		from within one console window.
	
		Explanation
		-----------
	
		Most software produce some sort of logging of activity.
		A mail client, a web server, a firewall, all write log
		files in their home directory or in a user-defined
		location. If you're used to monitor these log files, you
		know how cumbersome it is to have a peek at them: they
		are scattered on your hard drive! But that is not all:
		most often, the last entries, those that are of prime
		interest, are to be found at the bottom of the file.
		Things  get even more complicated if you want to monitor
		a log file in real time. In one word, monitoring log
		files can be a drag.
	
		Here comes Log viewer, a small application designed to
		help you in this task. It is very simple of use. On the
		left side is a list of entries which correspond, on the
		right, to the content of a log file. The log file is
		read continually, so you can monitor it in real time.
		You also have control over how often the file is reread
		(the refresh rate).
	
		Note: In the unix world, last is a command-line utility
		serving that purpose. Logviewer can be seen as a propped
		up visual enhancement of last.
	
		More detail
		-----------
	
		A word on the refresh rate. If the slider is set to its
		minimum position (default), the selected file will be
		read one time every second. This is normally sufficient.
		In some cases, when you monitor in real time a file that
		is updated very quickly, you might want to increase the
		refresh rate.
		When the slider is set to its maximum position, the
		selected file will be read ten time every second.
	
		A word on the sorting of log files. Generally, logging
		consists of appending entries at the end of a file, but
		not always. Some software inserts entries at the top of
		the log file. In that case, you have an option in the
		advanced settings that allows you to read that type of
		log files.
	
		A word on the names of log files. A scenario. Suppose
		that your mail client keeps a log file of its activity
		(pop3 handshakes, mail fetches, etc.). If this program
		just uses one file, always the same, say log.txt, then
		you will create an entry in Log viewer to indicate that
		file, and that's the end of the story. But what if your
		mail client doesn't log all the time to the same file?
		What if it uses the date of the day to create its log
		file, for instance (12-12-2002.txt). In that case, log
		viewer is useless for you,  would you think, since you
		can't reference a particular log file... Wrong. Log
		viewer allows you to use code instead of the path of the
		file you want to monitor. How? All you have to do is
		insert the appropriate rebol code in the ini file.
	
		The following example constructs a file based on the
		date, looking back in the directory until it finds one:
	
		[num: 0
		    until [
			filename: now/date - num
			if filename/day < 10 [filename: head insert to-
			string filename "0"]
			filename: rejoin [%/path-to-your-directory filename
			".txt"]
			set 'num (get 'num) + 1
			exists? filename
		    ]
		    filename
		]
	
		A word on the ini file. The format of the ini file is as
		follows:
		Spaces separate the entries. Four entries per line.
		First is a one word description of the log file. The
		second is the full path and it has to be quoted. The
		third is whether it is a standard logfile, or reversed
		(last lines inserted at top). The fourth is the refresh
		rate.
	
		The slider overrides the individual refresh rate
		settings associated to the entries, but it doesn't
		remember them. This is better, so you can experiment
		with the slider, and then only select your preference in
		the advanced settings. Again, normally the default is
		fine. Depending on the power and resources of your
		equipment, you can set it higher than default.
	
		Contact
		-------
	
		If you want to contact the author, send email to
		danielsz@freeshell.org
		The homepage of logviewer can be found at
		http://danielsz.freeshell.org/code/mine/logviewer
	
		Agreement
		---------
	
		This program is licensed under Creative Commons. 
		http://creativecommons.org/licenses/by/2.5/
		You can do anything with it, including modifying the 
		source, as long as you respect the license. 
		Have fun!
	
		Rebol
		-----
	
		This program needs the rebol interpreter to run.
		Rebol/view is to be found at the official rebol site:
		http://www.rebol.com
	
	
	}
]

; some preliminary helper functions

quoted?: func [string [string! file! url!]] [
	either all [(first string) = #"^"" (last string) =  #"^""] 
		[true]
		[false]
]
quote: func [string [string! file!]] [insert string "^"" append string  "^""]
unquote: func [string [string! file!]] [remove string string: skip string ((length? string) - 1) remove string head string]

; ini file functions and defaults

inifile: %data.ini
inifilebak: append copy inifile ".bak"
backup-ini: does [
							if exists? inifilebak [delete inifilebak]
							rename inifile inifilebak
					]


write-ini: func [log [object!]] [
		write/append/lines inifile reform [:log/title switch type?/word :log/original [block! [mold :log/original] string! [quote copy log/original] url! [quote copy log/original]] to-integer :log/down :log/rate]
		]

; serialization

proto-log: make object! [
				title: path: down: rate: none
]

initialize: does [
	
	; what if inifile doesn't exists?
	if not exists? inifile [
			write inifile {readme "readme.txt" 0 1}
			if not exists? %readme.txt [write %readme.txt system/script/header/readme]										
		]
	
	; what if inifile is empty or contains invalid characters for blocks?
	if any [error? data: try [to-block read inifile] empty? data][
		backup-ini 
		write inifile data {readme "readme.txt" 0 1}
		if not exists? %readme.txt [write %readme.txt system/script/header/readme]
		data: to-block read inifile
		] 
	
	; what if inifile isn't a valid one?
		if not parse data [some [word! [string! | block! | url!] integer! integer!]] [
		backup-ini 
		write inifile {readme "readme.txt" 0 1}
		if not exists? %readme.txt [write %readme.txt system/script/header/readme]
		data: to-block read inifile
		]
	
	logs: make block! ((length? data) / 4) 
	forskip data 4 [
			object: make proto-log [
			title: to-string first data
			original: second data
			path: switch type?/word original [block! [do load original] string! [to-rebol-file either quoted? copy original [unquote copy original] [copy original]] url! [to-rebol-file to-string original]]
			down: to-logic third data
			rate: fourth data
			]
		append logs object
	]	

	; prepare block of data for data list, alternatively, use 'supply with 'list

	bl: make block! (length? logs)
	forall logs [append bl form get in first logs 'title]
	logs: head logs
	bl: head bl
]

initialize

; default values
logfile: logs/1
user-selection: false 
button.gif: load debase/base decompress #{
789CD592490EE5300844F77D1A26DBB06430F73F52E3485FEA2B743D39916244
18EA8F1C31D9AC6C1B9700E002A8393FA93CB81FB91E866014F6E9E663FF233A
8FA8C7E1C7E41F52556C5D7CE079249EA55A151C55FBE1FD58F1C83671EE4FA6
A853E127E8C7C2C7EDBA97B81EF9E9F823CEA33F401F5F24F7050482FF44846D
20B070B6423C277F37BF3D8DF685844CE24487F974535D0EA5ED64B72E703556
129B806B29BC81C9E068CC3062DE92746DA67D253145F9D856706038A24BB6D5
CCAE35F2DC89E98EEE7310712BE3C6DE35D5396C020C3C207A758A3634329EA5
2FDB760C715C048E399B3B48CAE0A6CE2EBE7C4F7C00D975C0ED34CBEB807181
79F8A48C1D5350B0F55842C75337DCD36FDCE498849129D3F1CEED9596E59291
94B7E6FF05638B6D54AB4E3948D9587257D5DC6610695DCC6BFEEA718F98DE45
617A84C646A5E0DD53CAE929716C199D5D6F0433752627CDB192F03C1C02897C
656ABC3659CFD88CC52D8F8EF908F6ECCB8224EBC5A0B31C3D4BF0CE7E71D2C5
5F4D3AC53387030000
} 16

form-styles: stylize [
small-button: button 60x18 button.gif font-size 9 with [edge: [size: 0x0 color: black] effects: [[fit][fit brighten 80]] font: [colors: [255.255.248 black]]]
]

calibrate: func [number [number!]] [to-integer ((number * 10) + 1)]
decalibrate: func [number [number!]] [(number - 1) / 10]

;edit user-selection entry
edit-logfile: func [log [object!] /local ui-title ui-path ui-rate ui-down tampon] [
	either user-selection [
		
		entry-form: layout [
				origin 8x8
				styles form-styles
				backdrop black
				vtext bold "Edit log file"
				box  260x4 effect [gradient 1x0 145.9.43 0.0.0] across
				panels: box 260x200 return
				small-button "Ok" [save-data]
				small-button "Cancel"	[unview]
				]
		
		basic: layout [
				origin 0x0
				styles form-styles
				backdrop black
				across
				vtext font-size 9 "Description:" return    
				ui-title: field 120x24 logfile/title return
				vtext font-size 9 "Path:" return
				ui-path: field 165x24 to-string to-local-file logfile/path return
				vtext font-size 9 "Ctrl + v to paste from clipboard..." 
				indent 10 
				small-button "Browse..." [tampon: request-file if not none? tampon [ui-path/text: to-local-file first tampon show ui-path]] return
				box  260x4 effect [gradient 1x0 145.9.43 0.0.0] return
				small-button "Advanced" [panels/pane: advanced show panels]
				]

		advanced: layout [
				origin 0x0
				styles form-styles
				backdrop black
				across
				vtext font-size 9 "Refresh rate:" return 
				ui-rate: slider 100x16 return
				ui-down: check not to-logic logfile/down vtext font-size 9 "Read first lines of log file" return
				box  260x4 effect [gradient 1x0 145.9.43 0.0.0] return
				small-button "Back"	[panels/pane: basic show panels]
				do [ui-rate/data: decalibrate logfile/rate show ui-rate]	
			]
	
		save-data: func [/local validation object] [
			validation: true
;					forall logs [if (get in first logs 'title) = ui-title/text [validation: false request/ok "That name exists! Please chose a unique name..."]]
					if any [empty? ui-title/text empty? ui-path/text] 
						[validation: false request/ok "please fill in the form"]
					if (not exists? to-rebol-file ui-path/text) [validation: false request/ok reform [ui-path/text "doesn't exist"]]
					if validation	[
								log/title: trim ui-title/text
								log/original: to-string copy ui-path/text
								log/path: to-rebol-file ui-path/text 
								log/down: not ui-down/data
								log/rate: calibrate ui-rate/data
								backup-ini
								forall logs [write-ini first logs]
								initialize
								logfile: log
								con/rate: logfile/rate
								sl/data: decalibrate logfile/rate 
								show sl
								clear tl/data
								insert tl/data bl
								show tl
								unview
						]

		]	
	
			basic/offset: 0x0
			advanced/offset: 0x0
			panels/pane: basic
			view/new entry-form
	
	]
				[request/ok "Nothing selected!"]
	
]
; delete user-selection entry
delete-logfile: does [
	either user-selection 
		[if request/confirm reform ["Are you sure you want to delete" logfile/title "?"] 
			[
			backup-ini
			forall logs [if not (get in first logs 'title) = logfile/title [write-ini first logs]]
			initialize
			logfile: logs/1
			con/rate: logfile/rate
			sl/data: decalibrate logfile/rate
			show sl
			clear tl/data
			insert tl/data bl
			show tl
			]
		]
		[request/ok "Nothing selected!"]
]
; add logfile interface
add-logfile: func [/local ui-title ui-path ui-rate ui-down tampon] [
		
		entry-form: layout [
		origin 8x8
		styles form-styles
		backdrop black
		vtext bold "Add log file"
		box  260x4 effect [gradient 1x0 145.9.43 0.0.0] across
		panels: box 260x200 return
		small-button "Ok" [save-data]
		small-button "Cancel"	[unview]
		]
		
		basic: layout [
		origin 0x0
		styles form-styles
		backdrop black
		across
		vtext font-size 9 "Description:" return    
		ui-title: field 120x24 return
		vtext font-size 9 "Path:" return
		ui-path: field 165x24 return
		vtext font-size 9 "Ctrl + v to paste from clipboard..." 
		indent 10 
		small-button "Browse..." [tampon: request-file if not none? tampon [ui-path/text: to-local-file first tampon show ui-path]] return
		box  260x4 effect [gradient 1x0 145.9.43 0.0.0] return
		small-button "Advanced" [panels/pane: advanced show panels]
		]

	advanced: layout [
		origin 0x0
		styles form-styles
		backdrop black
		across
		vtext font-size 9 "Refresh rate:" return 
		ui-rate: slider 100x16 return
		ui-down: check vtext font-size 9 "Read first lines of log file" return
		box  260x4 effect [gradient 1x0 145.9.43 0.0.0] return
		small-button "Back"	[panels/pane: basic show panels]
		]
		
		save-data: func [/local validation object] [
			validation: true
			forall logs [if (get in first logs 'title) = ui-title/text [validation: false request/ok "That name exists! Please chose a unique name..."]]
			if any [empty? ui-title/text empty? ui-path/text] 
				[validation: false request/ok "please fill in the form"]
			if (not exists? to-rebol-file ui-path/text) [validation: false request/ok reform [ui-path/text "doesn't exist"]]
			if validation	[
					object: make proto-log [
 						title: trim ui-title/text
						original: to-string copy ui-path/text
						path: to-rebol-file ui-path/text
						down: not ui-down/data
						rate: calibrate ui-rate/data
					]
					append logs object
					logs: head logs
					backup-ini
					forall logs [write-ini first logs]
					initialize
					logfile: object
					con/rate: logfile/rate
					sl/data: decalibrate logfile/rate
					show sl
					clear tl/data
					insert tl/data bl
					show tl
					unview
				]
			]
	basic/offset: 0x0
	advanced/offset: 0x0
	panels/pane: basic
	view/new entry-form
]


; main user interface

console: layout [
		styles form-styles
		backdrop black
		across
		box  280x4 effect [gradient 1x0 145.9.43 0.0.0] return
    tl: text-list 100x280 data bl [user-selection: true repeat num (length? logs) [if value = form logs/:num/title [logfile: logs/:num con/rate: logfile/rate sl/data: decalibrate logfile/rate show sl]]]
    space 6
		con: area wrap 580x280 font-name font-fixed with [
			rate: logfile/rate
			feel: make feel [
					engage: func [face action event data /local buffer] [
						either logfile/down [
							either not error? try [buffer: open/read/direct/binary/skip logfile/path either (size? logfile/path) > 2048 [((size? logfile/path) - 2048)] [0]] [
								data: copy buffer
								close buffer
								data: parse/all to-string data "^M" 
								; what to do if content is only one line
								data: either (length? data) > 1 [insert first data newline next head reverse data] [either empty? data [compose ["File is empty"]][data]]
								clear face/text
								face/line-list: none
								; if first character of data is newline, remove it
								face/text: either (first (first data)) = newline [replace data first data find/tail first data newline] [data]
								show face
								]
								[
									clear face/text
									face/line-list: none
									data: reform [now/time "Could not find log file, file may be locked, check data.ini..."]
									face/text: data
									show face
								]
							]
						[
							either not error? try [buffer: open/direct/read/binary logfile/path] [
								data: copy/part buffer 2048
								close buffer
								clear face/text
								face/line-list: none
								face/text: either none? data [compose ["File is empty"]] [parse/all to-string data "^M"]
								show face
								]
								[
									clear face/text
									face/line-list: none
									data: reform [now/time "Could not find log file, file may be locked, check data.ini..."]
									face/text: data
									show face
								]
						]
					 ]
					]
			]
	return
	small-button "Add..." [add-logfile] small-button "Edit" [edit-logfile logfile] small-button "Delete" [delete-logfile] small-button "Open" [call reduce ["notepad" logfile/path]]
	indent 80 vtext bold "Refresh rate:" vtext "slower" sl: slider 100x16 [con/rate: calibrate sl/data show con] vtext "faster" return
	;set slider
	do [sl/data: decalibrate logfile/rate show sl]
	]

view console