REBOL [
	Author: "Ashley G Truter"
	File: %win-requestors.r
	Date: 29-Jun-2009
	Title: "Native Windows requestors"
	Purpose: {
		A set of four Windows native requestors that approximate and extend the functionality
		of the REBOL request* functions.
	}
	Usage: {
		cscript/alert text [string!]
			"Flashes an alert message to the user. Waits for a user response."
			/title title-text [string!]
		cscript/request text [string!]
			"Requests an answer to a simple question."
			/title title-text [string!]
			/ok
			/confirm
			/type [word!]
		cscript/request-dir
			"Requests a directory."
			/title text [string!]
			/dir file [file!]
			/no-make "No make option"
		cscript/request-text
			"Requests a text string be entered."
			/title title-text [string!]
			/prompt prompt-text [string!]
			/default text [string!]
	}
	library: [
		level: 'intermediate
		platform: 'windows
		type: [tool module]
		domain: [gui ui user-interface]
		tested-under: [view 2.7.6 WinXP]
		support: none
		license: 'public-domain
		see-also: none
	]
]

cscript: make object! [

	*script: make function! [cmd [string!] /v] [
		write %tmp.vbs cmd
		call/wait/output/shell "cscript /nologo tmp.vbs" v: copy ""
		delete %tmp.vbs
		trim/lines v
	]

	alert: make function! [
		"Flashes an alert message to the user. Waits for a user response."
		text [string!]
		/title title-text [string!]
	] [
		*script rejoin [
			{WScript.Echo MsgBox(}
			mold text
			{,4144,}		; 4096 + 48
			mold any [title-text "Dialog"]
			{)}
		]
		true
	]

	request: make function! [
		"Requests an answer to a simple question."
		text [string!]
		/title title-text [string!]
		/ok
		/confirm
		/type icon [word!] "Valid values are: alert, help, info, stop"
		/local v opt
	] [
		opt: 4096 + case [	; System-Modal
			OK		[0]		; OK,Default-Button-1,Application-Modal
			Confirm	[4]		; Yes-No
			true	[3]		; Yes-No-Cancel
		]					; 1 OK-Cancel 2 Abort-Retry-Ignore 5 Retry-Cancel
		opt: opt + switch/default icon [
			alert	[48]	; Exclamation
			help	[32]	; Question
			info	[64]	; Information
			stop	[16]	; Critical
		] [0]
		;	256 Default-Button-2
		;	512 Default-Button-3
		;	768 Default-Button-4
		v: *script rejoin [
			{WScript.Echo MsgBox(}
			mold text
			{,} opt {,}
			mold any [title-text "Dialog"]
			{)}
		]
		;	1 OK
		;	2 Cancel
		;	3 Abort
		;	4 Retry
		;	5 Ignore
		;	6 Yes
		;	7 No
		pick reduce [true none 'Abort 'Retry 'Ignore true false] to integer! v
	]

	request-dir: make function! [
		"Requests a directory."
		/title text [string!]
		/dir file [file!]
		/no-make "No make option"
		/local v
	] [
		;	&H0001 return-only-fsdirs
		;	&H0002 dont-go-below-domain
		;	&H0004 status-text
		;	&H0008 return-fs-ancestors
		;	&H0010 edit-box
		;	&H0020 validate
		;	&H0200 no-new-folder
		;	&H1000 browse-for-computer
		;	&H2000 browse-for-printer
		;	&H4000 browse-include-files
		either empty? v: *script rejoin [
			{set s=CreateObject("Shell.Application")^/set v=s.BrowseForFolder(0,}
			mold any [text "Select a directory:"]
			either no-make [{,&H0208,}] [{,&H0008,}]
			mold either file [to-local-file file] ["c:"]
			{)^/WScript.Echo v.ParentFolder.ParseName(v.Title).Path}
		] [
			none
		] [
			dirize to-rebol-file v
		]
	]

	request-text: make function! [
		"Requests a text string be entered."
		/title title-text [string!]
		/prompt prompt-text
		/default text
	] [
		*script rejoin [
			{v=InputBox(}
			mold any [prompt-text "Enter text below:"]
			{,}
			mold any [title-text "Dialog"]
			{,}
			mold any [text ""]
			{)^/WScript.Echo v}
		]
	]
]