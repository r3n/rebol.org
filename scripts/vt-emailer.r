REBOL [
	Title: "REBOL/View Desktop - Emailer"
	file: %vt-emailer.r
	Version: 1.2.0
	Author: "Didier Cadieu"
	email: didec@wanadoo.fr
	Date: 30-october-2004
	purpose: {
		It's an enhancement of the original emailer released in the ViewDesktop.
		It handles file attachments.
	}
	History: [
		1.0.0 {Original release from REBOL Technologie (by Carl Sassenrath)}
		1.1.0 {Adding files attachment handling :
			   - new emailer/attach refinement working like 'send/attach
			   - modified layout to manage attached files
			   Require View 1.2.8+
			  }
		1.2.0 {Adding "copy to myself" checkbox and change 'send logic}
	]
	Rights: "Copyright REBOL Technologies 1999-2003"
	Tabs: "Tabspace is 4. PLEASE KEEP IT THAT WAY."
	License: {
		This software is the property of REBOL Technologies and is
		licensed to you under the terms of the REBOL/View Desktop
		License (included in this distribution).
	}
	library: [
		level: 'advanced platform: 'all type: [module function] domain: [ui vid]
		tested-under: "View 1.2.8 and 1.2.46 WinXP" license: 'lgpl support: "email or altme"
	]
 ]

alive?: true

ctx-emailer: context [
	f-to: f-cc: f-copy: f-join: f-email: f-subject: f-msg: none

	;-- Emailer layout:
	lo: [
		style tx text bold 80x24 right
		style btn button 80x24
		style fld field 300x24
		style bts button 40x24										; ADDED
		across origin 6x6 space 2x1
		tx "To:"      f-to: fld return
		tx "CC:"      f-cc: fld return
		tx "From:"    f-email: info 180 para []						; CHANGED
		pad 7x2 f-copy: check pad 0x-2 text bold "Copy to myself" return		; ADDED
		tx "Subject:" f-subject: fld return
		tx "Attach:"    f-join: text-list 300x50 data [] return		; ADDED
		tx "Message:" f-msg: area wrap 300x200 return
	    at f-join/offset * 0x1 + 5x24 space 0x4						; ADDED
	    bts "Add" [add-file]
	    bts "Rem" [del-file]
		below at f-msg/offset + f-msg/size * 0x1 + 5x-82			; CHANGED
		btn "Send" #"^S" [submit-email]
		btn "Clear" [clear-all]
		btn "Close" escape [close-em]
	]

	clear-all: does [
		; Clear emailer fields:
		clear-fields lo
		f-email/text: form system/user/email
		clear f-join/data											; ADDED
		clear f-msg/text
		f-msg/line-list: none
		show lo
		focus f-to
	]

	; THIS FUNC ADDED
	add-file: has [f r] [
		; Request and add file(s) to attach list:
		f: request-file/title/keep "File(s) to attach" "Add"
		if not none? f [
			r: union f-join/data f
			append clear f-join/data r
			refresh-f-join
		]
	]

	; THIS FUNC ADDED
	del-file: has [f r] [
		; Remove selected file(s) from attach list:
		if not any [none? f-join/picked empty? f-join/picked] [
			r: exclude f-join/data f-join/picked
			append clear f-join/data r
			clear f-join/picked
			refresh-f-join
		]
	]
	
	; THIS FUNC ADDED
	refresh-f-join: does [
		; Update slider and display the attach list:
		f-join/sn: f-join/sld/data: 0
		f-join/sld/redrag f-join/lc / max 1 length? f-join/data
		show f-join
	]

	submit-email: has [sending user hdr subject files cmd args] [
		; Send the email:
		; Check file(s) existense
		; THIS LOOP ADDED
		foreach f f-join/data [
			if not exists? to-file f [
				alert rejoin [
					"File '" f "' not found : sending canceled !! "
					"Check attached file(s) and try again."
				] exit
			]
		]
		sending: flash "Sending..."
		either error? try [
			if empty? f-to/text [error-out-here]
			user: load/all f-to/text
			if not empty? f-cc/text [append user load/all f-cc/text]
			hdr: make system/standard/email [subject: f-subject/text]
			if not empty? f-to/text [hdr/to: copy f-to/text]
			if not empty? f-cc/text [hdr/cc: copy f-cc/text]
			; WAS :
			;send/header user f-msg/text hdr
			; CHANGED BY
			; Handling attached files and copy myself
			cmd: copy [send header]
			args: copy [user f-msg/text hdr]
			if not empty? f-join/data [
				files: copy []
				foreach f f-join/data [append files to-file f]
				append cmd 'attach
				append args 'files
			]
			if f-copy/data [
				append cmd 'only
				append user system/user/email
			]
			do join reduce [to-path cmd] args
			
;			either empty? f-join/data [
;				send/header user f-msg/text hdr
;			] [
;				files: copy []
;				foreach f f-join/data [append files to-file f]
;				send/header/attach user f-msg/text hdr files
;			]	; END OF THIS CHANGE
		][
			unview/only sending
			alert "Error sending email. Check fields and check your network setup."
		][
			unview/only sending
			close-em
			alert "Your email has been sent."
		]
	]

	close-em: does [
		; Close the emailer view:
		unview/only lo
	]

	set 'emailer func [
		"Pops up a quick email sender."
		/to "Specify a target address"
		target [string! email!]
		/subject "Specify a subject line"
		what [string!]
		/attach "Specify files to attached"				; ADDED
		files [block! file!]							; ADDED
		/local req
	][
		if block? lo [lo: layout lo  center-face lo]
		if not alive? [
			alert "Email cannot be sent when offline."
			exit
		]
		if not all [system/user/email system/schemes/default/host] [
			req: request [{Your email settings are missing from the network preferences.
				Set them now?} "Setup" "Ignore" "Cancel"]
			if none? req [exit]
			if req [set-user]
		]
		clear-all
		; NEXT 4 LINES ADDED
		if attach [
			if file? files [files: reduce [files]]
			foreach f files [append f-join/data to-string f]
		]
		if to [f-to/text: copy target]
		if subject [f-subject/text: copy what]
		focus f-to
		view/new/title lo "Emailer"
	]
]

; If launch alone, then run it
if not system/script/parent/header [emailer do-events]
;--- if you want to test uncomment one of this line:
;emailer do-events
;emailer/attach %a-file.txt do-events
;emailer/attach [%a-file.txt %another.r] do-events