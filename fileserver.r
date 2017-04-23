REBOL [
	Title: "Obscure File Server"
	Purpose: "Share files over HTTP protocol +NLS"
	Author: "pijoter"
	Date: 2-Sep-2009/21:04:51+2:00
	File: %fileserver.r
	Log: %fileserver.log
	Home: http://rowery.olsztyn.pl/rebol
	License: "GNU General Public License (Version II)"
	Library: [
		level: 'intermediate
		platform: 'all
		type: [tool]
		domain: [file-handling web tcp other-net]
		tested-under: [
			view 2.7.6  on [Linux WinXP]
		]
		support: none
		license: 'GPL
	]
	Tabs: 3
]

dt: context [
	to-human: func [dt [date!] /date /time /local pad d t s] [
		pad: func [val n] [head insert/dup val: form val #"0" (n - length? val)]

		dt: rejoin [
			(pad dt/year 4) #"-" (pad dt/month 2) #"-" (pad dt/day 2)
			#"/" to-itime any [dt/time 0:00]
		]

		any [
			if date [copy/part dt 10]
			if time [copy/part (skip dt 11) 8]
			dt
		]
	]

	to-stamp: func [dt [date!] /date] [
		dt: any [
			if date [self/to-human/date dt]
			self/to-human dt
		]
		remove-each ch dt [found? find "-/:" ch]
	]

	to-gmt: func [date [date!]] [
		any [
			zero? date/zone
			attempt [
				date: date - date/zone
				date/zone: 0:00
			]
		]
	]
]

log: context [
	FILE: any [attempt [system/script/header/log] %fileserver.log]

	emit: func [info] [
		if block? info [info: reduce info]
		attempt [write/append/lines self/FILE reform [(dt/to-stamp now) (form info)]]
	]
]

fs: context [
	DENY-DOT: true
	DENY-DIR: [
		;; katalogi systemow SCM
		%.git/ %.cvs/ %.svn/
	]
	DENY-FILE: reduce [
		;; plik serwera i logow
		any [attempt [system/script/header/file] %fileserver.r]
		any [attempt [system/script/header/log] log/FILE]
	]
	SORT-METHOD: 'name ;; 'date 'name 'size

	paths: make hash! 256

	deny-file?: func [file [file!] /local rc] [
		rc: any [
			found? find self/DENY-FILE file
			if self/DENY-DOT [self/is-dot? file]
		]
		net-utils/net-log ["fs/deny-file?" file "deny?" (to-logic rc)]
		return rc
	]
	deny-dir?: func [dir [file!] /local rc] [
		rc: any [
			found? find self/DENY-DIR dir
			if self/DENY-DOT [self/is-dot? dir]
		]
		net-utils/net-log ["fs/deny-dir?" (dir) "deny?" (to-logic rc)]
		return rc
	]
	deny-subdir?: :deny-dir?

	to-dir: func [target [string! file!]] [dirize to-file target]
	is-dir?: func [target [string! file!]] [#"/" = last target]
	is-file?: func [target [string! file!]] [not self/is-dir? target]
	is-dot?: func [target [string! file!]] [#"." = first target]

	make-id: func [path [string! file!]] [enbase/base (checksum/method (form path) 'MD5) 16]
	is-id?: func [id [string!]] [equal? 32 (length? id)]

	update-paths: func [dir [string! file!]
		/local hash dir-content bag item info dirs files path] [

		dir: clean-path (self/to-dir dir)
		hash: make hash! 64

		any [
			dir-content: attempt [sort read dir]
			return hash ;; pusta mapa plikow
		]

		if found? find [date size] self/SORT-METHOD [
			attempt [
				bag: make block! (2 * length? dir-content)
				foreach item dir-content [
					info: info? dir/:item
					repend bag [(get in info self/SORT-METHOD) item]
				]
				sort/skip/reverse bag 2
				clear dir-content
				foreach [value item] bag [append dir-content item]
				unset 'bag
			]
		]

		;; sortuj oddzielnie pliki i katalogi
		dirs: remove-each target (copy dir-content) [
			any [
				self/is-file? target
				self/deny-dir? target
			]]

		files: remove-each target dir-content [
			any [
				self/is-dir? target
				self/deny-file? target
			]]

		foreach item (union dirs files) [
			path: dir/:item
			repend hash [(self/make-id path) path]
			;; net-utils/net-log ["fs/update-paths" "item" (item) "is-dir?" (is-dir? target)]
		]

		;; TODO: nie modyfikuj gloablnej listy za kazdym przeladowaniem katalogu
		self/paths: union/skip self/paths hash 2
		return hash
	]
	local-path: func [id [string! none!]] [select self/paths id]

	mime-map: [
		%.html "text/html"
		%.htm  "text/html"
		%.png  "image/png"
		%.jpg  "image/jpeg"
		%.gif  "image/gif"
		%.txt  "text/plain"
		%.lha  "application/octet-stream"
		%.mp3  "audio/mp3"
		%.rar  "application/x-rar-compressed"
		%.rtf  "application/rtf"
		%.zip  "application/x-zip-compressed"
		%.r    "text/plain"
		%.reb  "text/plain"
		%.pl   "text/plain"
		%.php   "text/plain"
		%.py   "text/plain"
		%.jsp  "text/plain"
		%.js   "text/plain"
		%.css  "text/plain"
	]

	mime?: func [path [string! file!]] [
		any [
			attempt [select self/mime-map (suffix? to-file path)]
			"application/octet-stream"
		]
	]
]

net: context [
	DENY-IP: []
	;; DENY-IP: [255.255.255.255]
	ALLOW-IP: [
		;; zaufane hosty
	]

	SERVER-PORT: 8080

	BUFFER-SIZE: 1024 * 1024 * 1 ; 1M

	mime: none
	status: none

	response: [
		200 "OK" "Everything is just fine"
		400 "Bad Request" "Malformed request:"
		401 "Unauthorized" "No permission to access:"
		403 "Forbidden" "No permission to access:"
		404 "Not Found" "Resource was not found:"
		410 "Gone" "Resource is no longer available:"
	]

	server-ip: has [ip port interfaces ifc] [
		ip: make block! 5

		append ip [127.0.0.1]
		attempt [
			port: open tcp://
			interfaces: get-modes port 'interfaces
			foreach ifc interfaces [append ip get in ifc 'addr]
			close port
		]
		if not empty? self/DENY-IP [self/ALLOW-IP: union self/ALLOW-IP ip]
		sort unique ip
	]
	server-url: does [rejoin [http:// (first self/server-ip) ":" (self/SERVER-PORT)]]
	server-dir: does [what-dir]
	server-path: func [path [file!]] [find/tail (form path) (head remove back tail (form self/server-dir))]
	url?: func [port [port!]] [rejoin ["http://" (port/local-ip) ":" (port/local-port)]]

	deny-ip?: func [ip] [
		if any [
				empty? self/DENY-IP
				found? find self/ALLOW-IP ip
			] [return false]

		to-logic any [
			found? find self/DENY-IP ip
			found? find self/DENY-IP 255.255.255.255
			found? find self/DENY-IP 'all
		]
	]

	send-header: func [port [port!] mime [string!]
		/with custom-header [string!]
		/error err-num [integer!]
		/local header status] [

		attempt [
			self/status: status: any [(if error [err-num]) 200]
			self/mime: mime
			header: rejoin [
					"HTTP/1.1 " (status) " " (select self/response status) CRLF
					"Content-Type: " (mime) "; charset=" (content/encoding) CRLF
					"Content-Language: " (content/language) CRLF
					"Expires: " (to-idate now) CRLF
					"Date: " (to-idate now) CRLF
					"Connection: close" CRLF
			]
			if with [append header custom-header]
			append header CRLF

			net-utils/net-log ["net/send-header" "size" (length? header) "header" (header)]
			write-io port header (length? header)
		]
	]

	send-page: func [port [port!] buffer [string! binary!]
		/error err-num [integer!]
		/local mime] [

		mime: "text/html"
		all [
			any [
				if error [self/send-header/error port mime err-num]
				self/send-header port mime
			]
			write-io port buffer (length? buffer)
		]
	]

	send-error: func [port [port!] err-num [integer!] message [string! binary!]
		/local err body] [

		err: any [
			attempt [find self/response err-num]
			self/response
		]

		body: rejoin [""
			<html> LF
			<head> LF
				<title> (second err) </title> LF
				<basefont face="tahoma,arial"/> LF
			</head> LF
			<body>
				<h2> "SERVER-ERROR" </h2> LF
				<p> (third err) "&nbsp;" (to-string message) <br/> (to-idate now) </p> LF
			</body>
			</html>]

		self/send-page/error port body err-num
	]

	send-file: func [port [port!] path [string! file!]
		/local dir file mime size disposition fh buffer part bytes] [

		set [dir file] split-path path
		size: size? path
		mime: fs/mime? file
		disposition: rejoin [
			"Content-Disposition: inline; filename=" {"} (form file) {"; size="} (size) {"} CRLF
			"Content-Length: " (size) CRLF
		]

		net-utils/net-log ["net/send-file" (path) "size" (size) "mime" (mime)]

		all [
			self/send-header/with port mime disposition
			attempt [
				fh: open/binary/direct/read path
				buffer: make binary! self/BUFFER-SIZE
				part: 0

				forever [
					bytes: read-io fh buffer self/BUFFER-SIZE

					if zero? bytes [break]

					part: part + 1
					net-utils/net-log ["net/send-file" (file) "part" (part) "bytes" (bytes)]

					write-io port buffer bytes
					clear buffer
				]
				close fh
				unset 'buffer

				size
			]
		]
	]

	get-id: func [port [port!]
		/local buffer space chars resource valid?] [

		buffer: copy port

		space: [some { }]
		chars: complement charset { }
		resource: make string! 40

		valid?: to-logic all [
			parse/all buffer ["GET" space "/" [opt [copy resource some chars]] space "HTTP" to end]
			not empty? resource
		]

		net-utils/net-log ["net/get-id" "id" (resource) "valid?" (valid?) "buffer" (to-string buffer)]
		if valid? [resource]
	]
]

content: context [
	language: "pl,en"
	encoding: any [
		select [3 "windows-1250" 4 "utf-8"] fourth system/version
		"iso-8859-1"
	]

	make-index: func [dir [string! file!]
		/local output prev-path prev-dir id path target item f l s] [

		output: make string! 1024

		;; wyswietlaj "parent-dir" tylko gdy nie jestesmy w glownym katalogu
		if not equal? dir net/server-dir [
			set [prev-path prev-dir] (split-path dir)
			id: fs/make-id prev-path

			append output rejoin [{<li><a href="} (id) {">..</a> :: (<a href="} (id) {">parent dir</a>)</li>} LF]
		]

		foreach [id path] (fs/update-paths dir) [
			target: second (split-path path)
			item: any [
				attempt [
					f: info? path

					;; wielkosc pliku w ludzkim formacie
					l: length? (to-string f/size)
					s: any [
						if l <  4 [join form f/size "B"]
						if l <  7 [join form (round/to (f/size / 1024) 0.01) "K"]
						if l < 10 [join form (round/to (f/size / 1048576) 0.01) "M"]
						join form (round/to (f/size / 1073741824) 0.01) "G"
					]

					select [
						file [{<li><a href="} (id) {">} (target) {</a> :: } (s) {</li>} LF]
						directory [{<li><a href="} (id) {">} (target) {</a> :: (dir)</li>} LF]
					] f/type
				]
				[{<li><a href="} (id) {">} (target) {</a></li>} LF]
			]
			append output (rejoin item)
		]

		path: net/server-path dir
		rejoin [""
			<html> LF
			<head> LF
				<title> "FileServer" </title> LF
				{<meta http-equiv="Content-Type" content="text/html; charset=} (self/encoding) {"/>} LF
				{<meta http-equiv="Content-Language" content="} (self/language) {"/>} LF
				{<meta name="generator" content="} (system/script/header/title) {"/>} LF
				{<meta name="author" content="} (system/script/header/author) {"/>} LF
				<basefont face="tahoma,arial"/> LF
			</head> LF
			<body> LF
				<h2> {Index :: } (path) </h2> LF
				<ul> LF (trim output) </ul> LF
				<font size="-2"> LF
				{Any inaccuracies in this index may be explained by the fact that it has been prepared with the help of a computer.} <br/> LF
				{Page generated by <a href="http://www.rebol.org/cgi-bin/cgiwrap/rebol/view-script.r?script=fileserver.r">REBOL FileServer</a> :: }
				(form to-idate now) LF
				</font> LF
			</body> LF
			</html> LF
		]
	]

	handle: func [port [port!]
		/local start id resource-id path resource-path dir target bytes err-num stop t] [

		start: now/precise

		;; odtworz lokalna sciezke na podstawie ID z URI
		;; jezeli ID istnieje ale nie pasuje do pliku (brak wpisu w fs/paths
		;; lub z brak pliku) to generuj blad 404
		any [
			if id: net/get-id port [path: any [(fs/local-path id) (net/server-dir)]]
			id: fs/make-id (path: net/server-dir)
		]

		either (id = fs/make-id path) [
			;; zachowaj kopie sciezki dostepu to pliku i wygenerowany id
			;; oryginal moze byc modyfikowany przez doklejanie nazwy pliku
			resource-path: path
			resource-id: id

			if dir? path [
				;; wirtualny plik indeksu dla katalogow zawierajacy
				;; wygenerowana liste zawartosci (podkatalogow oraz plikow)

				path: rejoin [path "index.html"]
				id: fs/make-id path
			]

			set [dir target] (split-path path)
			bytes: any [
				;; sprawdz ograniczenia dostepu
				if (net/deny-ip? port/host) [net/send-error port 401 (net/url? port)]
				if (fs/deny-subdir? (second split-path dir)) [net/send-error port 410 resource-id]
				if (fs/deny-file? target) [net/send-error port 410 resource-id]

				;; generuj index tylko gdy oryginalny path nie zawiera nazwy pliku (doklejony "index.html")
				if all [(fs/is-dir? resource-path) (equal? (form target) "index.html")] [net/send-page port (self/make-index dir)]

				;; o ile to mozliwe wyslij plik
				if not exists? path [net/send-error port 404 resource-id]
				net/send-file port path
			]

			if zero? bytes [bytes: self/send-error port 404 resource-id]
		][
			;; jezeli nie mozna przypisac sciezki do CRC (z powodu braku wpisu
			;; w fs/file-map lub braku CRC) uzyj pusty ciag znakow. W przypadku
			;; braku CRC suma kontrolna bedzie generowana dla zmiennej resource-path

			resource-path: {}
			resource-id: any [id (fs/make-id resource-path)]
			err-num: any [if (fs/is-id? resource-id) [404] 400]

			bytes: net/send-error port err-num resource-id
		]

		stop: now/precise

		;; loguj polozenie wzgledem udostepnianego katalogu
		resource-path: any [
			if all [resource-path (not empty? resource-path)] [net/server-path resource-path]
			{}
		]

		log/emit [
			port/host
			resource-id
			rejoin [{"} resource-path {"}]
			net/mime
			net/status
			bytes
			t: to-decimal (difference stop start)
		]

		net-utils/net-log ["content/handle" "bytes" (bytes) "time" t "speed" (round/to (bytes / t) / 1024 0.01) "KB/sec"]
		bytes
	]
]

;; 

net-watch: false
system/options/quiet: true

either view? [
	;; rebol/view
	view/new gui: layout/size [] 185x140
	gui/pane: layout/tight [
		box white 185x40
		at 5x10 h1 "Server Running"
		at 5x50 text to-string net/server-url
		at 5x70 patr: text 200 "Pages transmitted: 0"
		at 5x85 bytr: text 200 "Bytes transmitted: 0.0M"
		across at 5x110 space 4x2
		btn "Browse server" [browse net/server-url]
		btn "Show directory" [browse net/server-dir] return
		do [
			insert-event-func [
				if equal? event/type 'close [attempt [(close client) (close server)] quit]
				event
			]
		]
	]
	show gui
][
	;; rebol/core
	unprotect 'alert
	alert: func [message] [print message ask "press-enter^/"]

	any [
		system/options/quiet
		foreach ip net/server-ip [print rejoin [{Server URL: } "http://" ip ":" net/SERVER-PORT]]
	]
]

any [
	server: attempt [open/binary/direct/no-wait rejoin [tcp://: net/SERVER-PORT]]
	do [
		message: rejoin [
			{Looks like a Web Server is already running on your computer (port } net/SERVER-PORT {).}
			{Turn it off first, then try again.}
		]
		alert message
		quit
	]
]

pages: 0
bytes: 0.0

forever [
	wait server
	wait client: first server

	if error? err: try [size: content/handle client] [
		print disarm err
		alert "an unexpected error occurred!"
		quit
	]

	if view? [
		pages: pages + 1
		bytes: bytes + size

		patr/text: join "Pages transmitted: " pages
		bytr/text: rejoin ["Bytes transmitted: " round/to (bytes / 1048576) 0.01 "M"]
		show [patr bytr]
	]

	close client
]
