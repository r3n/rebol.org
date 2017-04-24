REBOL [
	Title: { Upload library-script - upload a script to rebol.org}
	File: %upload-library-script.r
	Date: 15-Jul-2004
	Purpose: "  upload a script to rebol.org  "
	Usage: {
		Request a token on
		http://www.rebol.org/cgi-bin/cgiwrap/rebol/lds-library-tokens.r
		Read your email.
		Paste it when this script asks. (note the token is stored on disk then).
		Select your upload-script in requester.
		Upload and edit header until it "upload" says ok.
	}
	Version: 1.1.1
	Author: "Volker Nitsch"
	History: [
		1.1.2 <Volker Nitsch> "added upload-note-field"
		1.1.1 <Volker Nitsch> "%validate-script.r now fixed for external download"
		1.1.0 <Volker Nitsch> "Faster local check, auto-update"
		1.0.0 <Volker Nitsch> "Usable to upload scripts to rebol.org"
	]
	Credits: [
		{Sunanda for lds, the header-checker and explanations}
	]
	Library: [
		level: 'intermediate
		platform: 'all
		type: tool
		domain: [file-handling gui other-net vid web]
		tested-under: none
		support: none
		license: GPL
		see-also: none
	]]


print "-uploaders console for logging-"


rebol []

???: func ['word value] [;Volker
	print [mold :word mold :value]
	set :word :value
]

; /link lacks it.
if not value? 'construct [
	construct: func [block /with object] [
		make either object [object] [object!]
		disinfect block
	]
]

; [context disinfect block] is like construct
; check i all?
disinfect: func [; by Volker
	"removes values which could be executed by make. only top-level"
	block
	/local value hot word out
] [
	out: copy []
	parse block [any [
			set word ['none | 'true | 'false] (
				append out get in system/words word
			)
			|
			set word [word! | lit-word!] (append out to-lit-word word) ;grrr
			|
			set hot [get-word! | paren!
				| path! | set-path!
			] ;(probe :hot)
			|
			set value any-type! (append/only out value)
		]]
	out
]


rebol []

config: any [
	attempt [construct load config-file: %lds-config-d.txt]
	[]
]
config: make context [
	upload-file: none
	files: copy []
	filters: none
] config

save-config: does [
	save/all config-file third config
]



rebol []

modules: [
	http://www.rebol.org/library/public/ %lds-local.r
	http://www.rebol.org/library/public/ %validate-script.r
]

download-lds: does [
	foreach [url file] modules [
		load-thru/to join url file file
		do file
	]
	if not config/filters [
		res2: lds/send-server 'list-search-filters []
		config/filters: res2/data
		save-config
	]

]

download-lds
library-tags: config/filters

update-me: does [
	if confirm "checking for updates?" [
		flash "downloading"
		foreach [url file] modules [
			attempt [delete file]
		]
		config/filters: none
		save-config
		download-lds
		probe
		load-thru/update/to join http://www.rebol.org/library/scripts-download/
		???
		file: %upload-library-script.r file
		unview
		alert "Script fresh downloaded. Now restart script."
	]
]


rebol [title: "support for tokens"]

token-file: %lds-library-token.txt

if not all [
	exists? file: token-file
] [
	inform layout [
		backdrop gray
		across title "Enter library-token"
		text "(kind of rebol-cooky)"
		below
		text 400 trim system/script/header/usage as-is
		button "get token" [
			browse http://www.rebol.org/cgi-bin/cgiwrap/rebol/lds-library-tokens.r
		]
		pad 0x5
		label join {paste token, or write it directly to } file
		f-token: area
		across
		button "OK" [hide-popup token: if "" <> s: f-token/text [s]]
		button "Cancel" [quit]
	]
	if all [not token not exists? file] [quit]
	if token [write file token]
]

delete-bad-token: does [
	delete token-file
	alert "bad token - get a new one, restart script!"
	quit
]
if not attempt [
	token: decompress first load/all read token-file
	set [token-owner token-id] parse token "/"
] [
	delete-bad-token
]






rebol [title: "checking and uploading"]

upload: func [scr note /really] [

	lds/send-server/use-token 'contribute-script compose [
		mode (either not really ["check"] ["update"])
		note (note) script (scr)
	]

]

quick-check: does [
	res: validate-script/from-local f-script/text library-tags
	res: make context [revised-script: ""] res
	either empty? res/error-messages [
		show-check-result join "Local reply: "
		msg: "Looking good. You should check online" reduce ["upload" msg] ""
	] [
		show-check-result "Local reply: Problems with script"
		res/error-messages res/revised-script
	]
]
show-check-result: func [why msg-blk revised /local proposals tags lib-hdr msg] [
	proposals: [
		"title" [probe mold rejoin [" - " mold second split-path file " - " now]]
		"file" [mold second split-path file]
		"date" [mold now]
		"purpose" [mold "  Please edit me!  "]
		"lib-head" [
			lib-hdr: second load/all revised
			lib-hdr: select lib-hdr [library:]
			mold lib-hdr
		]
	]
	msg: copy ""
	foreach [field help] msg-blk [
		proposal: switch/default field proposals [
			mold '?
		]
		if "lib-head" = field [field: "library"] ;patch
		tags: either find first library-tags w: to-word field [
			rejoin ["" newline "; " mold library-tags/:w]
		] [""]
		repend msg [
			"; " help tags newline
			newline uppercase/part field 1 ": " proposal
			newline newline]
	]
	f-status/text: uppercase/part why 1
	f-comment/text: msg f-comment/line-list: none
	show lay
	alert why
]
upload-lay-content: has [res revised w] [
	flash join "checking " mold file
	res: upload scr f-note/text
	unview
	any [
		if res/status = [810 40 "bad token"] [
			delete-bad-token
		]
		if [210 30 "problems with script"] = res/status [
			revised: either w: in res/data 'revised-script [decompress get w] [copy ""]
			show-check-result join "Server-reply: " res/status/3 res/data/validation revised

		]
		if any [
			[0 10 {Looking good. Use mode update to add the new script}] = res/status
			[0 10 "Looking good. Use mode update to update the script"] = res/status
		] [
			if confirm third res/status [
				flash join "really uploading " mold file
				???
				res: upload/really f-script/text f-note/text
				unview
				alert join "real upload: " mold res/status
			]
		]
	]
]
save-lay: does [
	if f-script/text <> read file [
		write file f-script/text
	]
]
if file: request-file/only/title/file "script to upload?" "Edit" config/upload-file [
	config/upload-file: file
	save-config
	scr: read file
	lay: layout [
		backdrop gray
		title 620 "Upload this file to rebol.org?" left
		across f-status: h1 "No replies yet:" 500 left
		below
		across f-comment: area 620x180 wrap silver
		slider 16x180 [scroll-para f-comment face]
		below
		across h1 "With script: " text mold file
		below
		across f-script: area 620x180 scr wrap font-name font-fixed
		slider 16x180 [scroll-para f-script face]
		below
		across label "Why upload?" f-note: field 500
		below
		across label "token-id" text mold token-id
		label "token-owner" text mold token-owner
		below
		across
		button "quit" [quit]
		button "save&check&upload" [save-lay upload-lay-content] 150
		button "save" [save-lay]
		button "save&quick check" [save-lay quick-check] 150
		button "update me" [update-me]
	]
	attempt [quick-check]
	view lay
]
