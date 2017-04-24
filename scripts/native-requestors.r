REBOL [
	Author:	"Ashley G Truter"
	File:	%native-requestors.r
	Date:	15-Jul-2009
	Title:	"Native requestors"
	Purpose: {
		Replaces a number of REBOL requestors with native equivalents.
		Windows requires COMLib.r from http://anton.wildit.net.au/rebol/os/windows/COMLib/

		REQUESTOR			Mac	Win
		alert				Y	Y
		confirm				Y	Y
		request				Y	Y
		request-color		Y	N
		request-date		N	N
		request-dir			Y	Y
		request-download	N	N
		request-file		N	N
		request-list		Y	N
		request-pass		Y	N
		request-text		Y	Y
		say (new)			Y	Y
		
		Added following requestors/funcs:
			open-file
			save-file
			send-keys (Windows uses tmp.vbs)
	}
	Notes: {
		Windows can probably use COMDLG32.DLL (http://support.microsoft.com/kb/153929) for request-color
		and the Win32 API for many of these funcs.

		The send-keys use of VBS is an ugly hack. Much better to use COMLib or Win32 API ... but I havn't
		figured out how yet.
	}
	library: [
		level: 'intermediate
		platform: [windows mac]
		type: [tool function]
		domain: [dialogs]
		tested-under: [view 2.7.6 [WinXP MacOSX]]
		support: none
		license: 'public-domain
		see-also: none
	]	
]

make object! [

	OS: either 3 = fourth system/version [
		;
		;	Windows
		;
		COMLib: do %COMLib.r
		COMLib/initialize
		do bind [
			sapi5: make function! [
				"Use SAPI 5 for text to speech."
				text [string!]
				/local tts
			][
				tts: CreateObject "Sapi.SpVoice"
				CallMethod [tts ".Speak(%s)" text]
				release tts
			]

			vbscript: make function! [
				cmd [string!]
				/string
				/local MS_script result
			][
				MS_script: CreateObject "MSScriptControl.ScriptControl"
				PutValue [MS_script ".Language = %s" "VBScript"]
				PutValue [MS_script ".AllowUI = %s" "TRUE"]
				PutValue [MS_script ".UseSafeSubset = %s" "0"]
				result: either string [
					GetString [MS_script ".Eval(%s)" cmd]
				][
					GetInteger [MS_script ".Eval(%s)" cmd]
				]
				release MS_script
				result
			]

			BrowseForFolder: make function! [
				prompt [string!] "Prompt text"
				dir [string!] "Starting directory"
				/local MS_shell obj result
			][
				MS_shell: CreateObject "Shell.Application"
				obj: GetObject reduce [MS_Shell {.BrowseForFolder(%d,%s,%d,%s)} 0 prompt 8 dir]
				result: either zero? obj [none] [
					obj: GetObject [obj {.Self}]
					dirize to-rebol-file GetString [obj {.Path}]
				]
				obj: none
				release MS_shell
				result
			]
		] COMLib/api

		'Win
	][
		;
		;	Mac OSX
		;
		osascript: make function! [
			cmd [string!]
			/local v
		][
			call/output/error rejoin [
				{osascript -e 'tell app "System Events"' -e 'activate' -e '}
				cmd
				{' -e 'end'}
			] v: copy "" copy ""
			trim/lines v
		]
		
		set 'request-color make function! [
			"Requests a color."
			/title text [string!] "Title text"		; not supported
			/color clr [tuple!] "Default color"
			/local v
		][
			v: copy "choose color"
			all [
				color
				insert tail v reform [
					" default color"
					*list reduce [256 * first clr 256 * second clr 256 * third clr]
				]
			]
			either empty? v: parse osascript v "," [none] [
				to tuple! reduce [
					to integer! (to integer! first v) / 256
					to integer! (to integer! second v) / 256
					to integer! (to integer! third v) / 256
				]
			]
		]

		set 'request-list make function! [
			"Requests a selection from a list."
			prompt [string!]
			items [block!]
			/title text [string!]
			/default val [any-type!]
			/local v
		][
			v: reform [
				"choose from list " *list/force items
				"with title" mold any [text ""]
				"with prompt" mold any [prompt "Please make your selection:"]
			]
			all [default insert tail v join " default items " *list/force to block! val]
			either "false" = v: osascript v [none] [v]
		]

		set 'request-pass make function! [
			"Requests a password."
			/title text [string!]
			/local v
		][
			either empty? v: osascript join {display dialog "Password:" hidden answer true default answer "" with title} mold any [text "Password"] [none] [v: copy skip v 14 copy/part v -1 + index? find/last v ","]
		]
		
		'Mac
	]

	;
	;	Helper func
	;
	
	delims: either OS = 'Win [copy "()"] [copy "{}"]

	*list: make function! [block [block!] /force /local v] [
		v: copy delims
		foreach item block [
			insert back tail v join either any [force string? item] [mold form item] [form item] ","
		]
		head remove back back tail v
	]

	;
	;	Native requestors
	;

	set 'request-dir make function! [
		"Requests a directory."
		/title text [string!] "Title text"
		/dir path [file!] "Set starting directory"
		/local v
	][
		either OS = 'Win [
			BrowseForFolder any [text "Select a directory:"] either dir [to-local-file path] ["C:"]
		][
			v: join "choose folder with prompt " mold any [text ""]
			all [dir insert tail v join " default location alias " mold join "Macintosh HD" replace/all to-local-file path "/" ":"]
			either empty? v: osascript v [none] [dirize to-rebol-file replace/all find next v ":" ":" "/"]
		]
	]

	set 'request-text make function! [
		"Requests a value."
		/title text [string!] "Title text"
		/prompt string [string!] "Prompt string"
		/default value [any-type!] "Default value"
		/local v
	][
		text:	any [text "Dialog"]
		string:	any [string "Enter text below:"]
		value:	form any [value ""]
		either OS = 'Win [
			vbscript/string rejoin ["InputBox" *list reduce [string text value]]
		][
			either empty? v: osascript reform ["display dialog" mold string "default answer" mold value "with title" mold text] [
				none
			][
				v: copy skip v 14
				copy/part v -1 + index? find/last v ","
			]
		]
	]

	set 'request make function! [
		"Requests an answer to a simple question."
		prompt [string!]
		/title text [string!]
		/ok
		/confirm
		/type icon [word!] "Valid values are: alert, help, info, stop"
		/local v opt
	][
		either OS = 'Win [
			opt: 4096 + case [OK [0] Confirm [4] true [3]]
			all [type opt: opt + select [alert 48 help 32 info 64 stop 16] icon]
			v: vbscript join "MsgBox" *list reduce [prompt opt any [text "Dialog"]]
		][
			v: reform ["display dialog" mold prompt "with title" mold any [text ""]]
			insert tail v join " buttons " case [
				ok		[*list ["OK"]]
				confirm	[*list ["Yes" "No"]]
				true	[*list ["Yes" "No" "Cancel"]]
			]
			insert tail v join " default button " mold either ok ["OK"] ["Yes"]
			all [type insert tail v join " with icon " select [alert "caution" help "note" info "note" stop "stop"] icon]
;			all [type insert tail v join " with icon alias " mold "Macintosh HD:Users:Ash:REBOL:Projects:BAS-Buster:Icons:alert.icns"]
			v: copy skip osascript v 16
		]
		select reduce ["Yes" true "No" false "Cancel" none "" none 1 true 2 none 6 true 7 false] v
	]
	
	set 'alert make function! [
		"Flashes an alert message to the user. Waits for a user response."
		value [any-type!]
		/title text [string!]
	][
		request/ok/type/title form value 'alert any [text "Alert"]
	]
	
	set 'confirm make function! [
		"Confirms a user choice."
		question [any-type!] "Prompt to user"
		/title text [string!]
	][
		request/confirm/type/title form question 'help any [text "Confirm"]
	]

	set 'open-file make function! [
		/dir path [file!] "Default file name"
	][
		all [ 
			local-request-file path: reduce ["Open" "" clean-path %. either dir [compose [(path)]] [copy []][][] false false]
			join third path first fourth path
		]
	]

	set 'save-file make function! [
		/dir path [file!] "Default file name"
	][
		all [ 
			local-request-file path: reduce ["Save" "" clean-path %. either dir [compose [(path)]] [copy []][][] false true]
			join third path first fourth path
		]
	]

	set 'send-keys make function! [
		url [url!]
		keystrokes [block!]
		/local cmd
	][
		browse url
		wait 3
		either OS = 'Win [
			cmd: copy "^"+{TAB}{TAB}^""
			foreach token keystrokes [
				insert back tail cmd switch/default token [
					#"^-" ["{TAB}"]
					#"^/" ["{ENTER}"]
				] [token]
			]
			write %tmp.vbs join {set s=WScript.CreateObject("WScript.Shell")^/s.AppActivate "Windows Internet Explorer"^/s.SendKeys } cmd
			call/wait %tmp.vbs
			delete %tmp.vbs
		][
			cmd: copy {'}
			foreach token keystrokes [
				insert back tail cmd join " & " switch/default token [
					#"^-" ["tab"]
					#"^/" ["return"]
				] [mold token]
			]
			call join {osascript -e 'tell app "Safari" to activate' -e 'tell app "System Events" to keystroke } skip cmd 3
		]
	]

	set 'say: make function! [
		"Speaks text."
		text [string!]
		/using voice [string!]	; Mac only
	][
		either OS = 'Win [
			sapi5 text
		][
			call rejoin [
				{osascript -e 'say }
				mold text
				either using [rejoin [{ using } mold voice {'}]] [{'}]
			]
		]
		true
	]
]

do [
	alert "This is an alert."
	confirm "This is the confirm requestor."
	request "This is the base request function."
	request-color
	;request-date
	request-dir
	;request-download
	;request-file
	request-list "This is the request-list requestor." ["List" "of" "items"]
	request-pass
	request-text
	say "This is the new say function."
	open-file
	save-file
	send-keys http://www.rebol.com reduce [tab "R3" newline]
	all [3 = fourth system/version COMLib/cleanup]
]