REBOL [
	Title: "fileserver"
	Purpose: "tool for serving files from the current directory"
	Comment: "fileserver with national language support"
	Date: Version: 2005-11-11
	Author: "Piotr Gapinski"
	Email: {news [at] rowery! olsztyn.pl}
	File: %fileserver.r
	Copyright: "Olsztynska Strona Rowerowa http://www.rowery.olsztyn.pl"
	License: "GNU General Public License (Version II)"
	Library: [
		level: 'intermediate
		platform: 'all
		type: [tool]
		domain: [web tcp other-net]
		tested-under: [
			view 1.3.1 on [winxp]
			core 2.6.0 on [winxp linux]
		]
		support: none
		license: 'GPL
	]
	History: [2005-11-11 2005-07-14 2005-07-10 2005-07-08 2005-07-06]
]

fileserver-ctx: context [

	web-dir:	what-dir
	recursive:	true
	index-file: 	%index.html
	log-file: 	%fileserver.log

	web: compose [
		net allow shell throw file throw 
		(web-dir) [allow read] 
		(log-file) [allow write]
	]
	secure :web

	set 'server-port 8080
	set 'page-language "PL"
	set 'page-encoding any [
		select [3 "windows-1250"] fourth system/version
		"iso-8859-2"
	]

	to-dir: func [d] [to-file dirize d]

	deny-dir?: func [d] [either recursive [false] [all [(dir? d) (web-dir <> (to-dir d))]]]
	deny-file?: func [p] [found? find [%.log %.r] (suffix? to-file p)]
	deny-ip?: func [d ip] [false]

	mime-type?: func [p /local mime-map] [
		mime-map: [
			%.html	"text/html"
			%.htm	"text/html"
			%.png	"image/png"
			%.jpg	"image/jpeg"
			%.gif	"image/gif"
			%.txt	"text/plain"
			%.lha	"application/octet-stream"
			%.mp3	"audio/mp3"
			%.rar	"application/x-rar-compressed"
			%.rtf	"application/rtf"
			%.zip	"application/x-zip-compressed"
			%.r	"text/plain"
			%.jsp	"text/plain"
		]

		any [
			select mime-map attempt [suffix? to-file p]
			"application/octet-stream"
		]
	]

	set 'server-url does [
		any [
			attempt [rejoin [http:// (read join dns:// read dns://) ":" server-port]]
			join http://127.0.0.1: server-port
		]
	]

	set 'server-home does [web-dir]

	emit-log: func [b] [
		if block? b [b: reduce b]
		attempt [write/append/lines log-file rejoin [now " " form b]]
	]

	make-crc: func [p] [checksum/method p 'MD5]
	to-bin-crc: func [ph] [debase/base ph 16]
	to-str-crc: func [h] [enbase/base h 16]

	file-map: make hash! 128

	build-local: func [ph] [
		attempt [
			if not binary? ph [ph: to-bin-crc ph]
			select file-map ph
		]
	]

	build-hash: func [d /local b p h name] [
		d: clean-path to-dir d
		h: make hash! 64

		b: any [
			attempt [sort read to-dir d]
			return h
		]

		foreach f b [
			p: d/:f
			any [
				all [dir? p deny-dir? p]
				deny-file? p
				repend h [(make-crc p) p]
			]
		]

		file-map: union/skip file-map h 2
		return h
	]

	build-index: func [d] [
		o: make string! 4096

		if not equal? d web-dir [
			set [pp pd] (split-path d)
			ph: to-str-crc make-crc pp

			append o build-markup pick [
				{<li><a href="/">../</a> :: (dir)</li>^/} 
				{<li><a href="<% ph %>">../</a> :: (dir)</li>^/}
			] (equal? pp web-dir)

		]

		foreach [h p] (build-hash d) [
			f: second (split-path p)
			ph: to-str-crc h

			append o build-markup any [
				attempt [
					fi: info? p
					select [
						file {<li><a href="<% ph %>"><% f %></a> :: <% fi/size %> b</li>^/}
						directory {<li><a href="<% ph %>"><% f %></a> :: (dir)</li>^/}
					] fi/type
				]
				{<li><a href="<% ph %>"><% f %></a></li>^/}
			]
		]
 
		p: find/tail form d (head remove back tail form web-dir)
		return build-markup {<html>
<head>
<title>FileServer Index :: <% p %></title>
<meta http-equiv="Content-Type" content="text/html; charset=<% page-encoding %>"/>
<meta http-equiv="Content-Language" content="<% page-language %>"/>
<meta name="generator" content="<% system/script/header/title %>"/>
<meta name="author" content="news [at] rowery! olsztyn.pl"/>
<basefont face="tahoma,arial"/>
<link rel="shortcut icon" href="http://www.rowery.olsztyn.pl/osrimg/favicon.ico"/>
</head>
<body>
<h2>Index :: <% p %></h2>
<ul>
<% trim/tail o %>
</ul>
<font size="-2">
Any inaccuracies in this index may be explained by the fact that it has been prepared with the help of a computer.<br/>
Page generated by <a href="http://www.rebol.org/cgi-bin/cgiwrap/rebol/view-script.r?script=fileserver.r">REBOL FileServer</a> :: <% form now %>
</font>
<script language="JavaScript" type="text/javascript" src="http://www.rowery.olsztyn.pl/lib/clock.js"></script>
</body>
</html>
}
	]

	send-page: func [http-port file dat mime] [
		attempt [
			insert dat join "HTTP/1.0 " [
				"200 OK" CRLF
				"Content-Type: " mime "; charset=" page-encoding CRLF
				"Content-Language: " page-language CRLF 
				"Content-Disposition: inline; filename=" {"} file {"} CRLF
				CRLF
			]
			write-io http-port dat length? dat
		]
		200
	]

	errors: [
		400 "Forbidden" "No permission to access:"
		404 "Not Found" "File was not found:"
	]

	send-error: func [http-port err-num file /local err response] [
		err: any [
			attempt [find errors err-num]
			errors
		]

		attempt [
			insert http-port join "HTTP/1.0 " [
				err-num " " err/2 CRLF
				"Content-Type: text/html; charset=" page-encoding CRLF
				"Content-Language: " page-language CRLF 
				CRLF
				<html> LF
				<head> <title> err/2 </title> <basefont face="tahoma,arial"/> </head> LF
				<body> LF
				<h2> "SERVER-ERROR" </h2> LF
				<p> err/3 " " file <br/> now </p> LF
				</body> LF
				</html>
			]
		]
		err-num
	]

	buffer: make string! 10240
	space: [some " "]
	chars: complement charset " "

	set 'serve func [http-port /local t-start p dat mime response uri] [
		response: 400
		t-start: now/precise

		clear buffer
		any [
			attempt [ while [not empty? http-request: first http-port] [repend buffer [http-request newline]] ]
			return response
		]

		repend buffer ["Address: " http-port/host newline] 
		uri: copy {}

		net-utils/net-log ["buffer" buffer]

		any [
			attempt [parse/all buffer ["GET" space "/" opt [copy uri some chars] space to end]]
			return response
		]

		net-utils/net-log ["uri" uri "empty?" empty? trim uri]

		either empty? trim uri [
			p: web-dir/:index-file
			uri: to-str-crc (make-crc p)
		][

			p: build-local uri
			if dir? (to-file p) [p: p/:index-file]
		]

		net-utils/net-log ["local-path" (form p) "empty?" empty? (form p)]
		net-utils/net-log ["mime-type" mime-type? (form p)]
		net-utils/net-log ["deny-ip?" http-port/host deny-ip? (form p) http-port/host]
		net-utils/net-log ["deny-path?" deny-file? (form p)]

		dat: copy #{}
		mime:"text/plain"
		uri: copy/part uri 32

		response: any [
			if (none? p) [send-error http-port 404 uri]
			if (deny-ip? p http-port/host) [send-error http-port 400 http-port/host]
			if (all [dir? p deny-dir? p]) [send-error http-port 400 uri] 
			if (deny-file? p) [send-error http-port 400 uri]
			if not attempt [
				set [d f] (split-path p)
				any [
					if all [
						equal? f index-file
						not exists? p
					] [dat: build-index d]

					dat: read/binary p
				]
			][send-error http-port 404 uri]
			send-page http-port f dat (mime: mime-type? p)
		]

		net-utils/net-log ["response" response]

		emit-log [
			http-port/host
			uri
			rejoin [{"} find/tail form p (head remove back tail form web-dir) {"}]
			mime 
			response 
			length? dat 
			to-decimal difference now/precise t-start
		]
		response
	]
]

net-watch: false
if (not view?) [alert: func [t] [print t ask "press-enter"]]
 
any [
	listen-port: attempt [open/lines join tcp://: server-port]
	do [
		alert "Looks like a Web Server is already running on your computer. Turn it off first, then launch FileServer again."
		quit
	]
]

if view? [
	view/new visu: layout/size [] 175x160
	visu/pane: layout/tight [
		box white 180x45
		at 5x10 h1 "Server Running"
		at 5x60 patr: text 200 "Pages transmitted: 0"
		at 5x80 text to-string server-url
		across at 5x110 space 4x2
		btn "Browse me!" [browse server-url] 
		btn "Show webdir" [browse server-home] return
		at 5x140 text "www.rebol.net" blue [browse http://www.rebol.net]
		do [
			insert-event-func [
				if equal? event/type 'close [attempt [close listen-port] quit]
				event
			]
		]
	]
	show visu
]

pages: 0
forever [
	if view? [
		patr/text: join "Pages transmitted: " pages
		show patr
	]

	http-port: first wait listen-port

	any [
		attempt [serve http-port]
		do [
			alert {We apologize, an unexpected error occurred!}
			quit
		]
	]
	close http-port

	pages: pages + 1
	net-utils/net-log ["pages" pages]
]