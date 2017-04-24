REBOL [
	Title: "RSS feed reader"
	Purpose: "Live Bookmarks"
	Date: 2007-07-20
	Version: 2.0.6
	Author: "Piotr Gapinski"
	Email: {news [at] rowery! olsztyn.pl}
	File: %rss.r
	Url: http://rowery.olsztyn.pl/narg/rebol/rss
	Copyright: "Olsztynska Strona Rowerowa http://www.rowery.olsztyn.pl"
	License: "GNU General Public License (Version II)"
	Library: [
		level: 'intermediate
		platform: 'all
		type: [tool]
		domain: [web]
		tested-under: [
			view 1.3.1  on [Linux]
			view 1.3.2  on [Linux WinXP]
		]
		support: none
		license: 'GPL
	]
	Zmiany: {
		2.0.6 2007-07-20
		- funkcja iconv umozliwia pelna obsluge UTF-8; nieznane znaki sa zamieniane na "."
		- standardem docelowym nie moze byc UTF-8, zrodlowym nie moze byc ASCII
		- local-charset jest inicjalizowany tylko raz na poczatku dzialania skryptu
		2.0.5 2007-07-12
		- znaki UTF-8 skladajace sie z trzech oktetow sa usuwane
		- path-thru potrafi obslugiwac url bez nazwy pliku
		2.0.4 2007-04-03
		- wybieranie rss za pomoca klawiatury powoduje aktualizacje listy kanalow
		2.0.3 2007-03-22
		- read-thru potrafi zapisywac w cache pliki zawierajace znaki specejalne;
		  mozliwe dzieki podmianie funkcji path-thru
		2.0.2 2007-03-12
		- ctx-rss-xml/escape-html domyslnie usuwa nieznane entity html
		- zamienione kody znakow zet i ziet dla utf-8; zobacz standards/utf-8
		- docelowe kodowanie znakow jest uzaleznione od systemu operacyjnego;
			zobacz ctx-rss-xml/to-local-charset
		2.0.1 2007-03-09
		- obsluga polskich znakow w standardzie UTF-8; zobacz ctx-rss-xml/iconv
		- obsluga znacznikow ldquo, rdquo oraz rsquo; zobacz ctx-rss-xml/escape-html
	}
]

if system/version < 1.3.1 [to error! "RSS feed reader requires Rebol/View 1.3.1 or greater"]
secure allow

if error? err: try [
ctx-rss-hosts: context [
	hosts: [
		; [site "nazwa serwisu" url url!-pliku-rss refresh time!-do-odswiezenia]
		; Linux
		[site "Linuxnews.pl" url http://linuxnews.pl/feed/ refresh 1:00]
		[site "jakilinux.org" url http://jakilinux.org/feed/]
		[site "7th Guard"    url http://rss.7thguard.net/7thguard.xml]
		[site "Linux.com"    url http://www.linux.com/index.rss]
		
		; Slackware
		[site "Slackware Changelog" url http://riexc.r1g.edu.lv/stuff/slachrss.php]
		[site "Slackware SSA" url http://dev.slackware.it/rss/slackware-security.xml]
		[site "Develia.org"  url http://www.develia.org/news.rss20.en.xml]
		
		; Software
		[site "KDE-Apps.org" url http://www.kde.org/dot/kde-apps-content.rdf]
		[site "Freshmeat"    url http://freshmeat.net/backend/fm-releases.rdf]
		[site "Google: CakePHP" url http://groups.google.com/group/cake-php/feed/rss_v2_0_msgs.xml]
		[site "Rails Trac"   url http://dev.rubyonrails.org/timeline?milestone=on&ticket=on&ticket_details=on&changeset=on&max=30&daysback=7&format=rss]
		[site "Google: RubyOnRails" url http://groups.google.com/group/rubyonrails/feed/rss_v2_0_msgs.xml]
		[site "Joel on Software" url http://www.joelonsoftware.com/rss.xml]

		; Programming Languages
		[site "REBOLution"   url http://www.rebol.net/blog/carl-rss.xml]
		[site "Rebol3 Front Line" url http://www.rebol.net/r3blogs/rebol3-rss.xml]
		[site "Rebol.org"    url http://www.rebol.org/cgi-bin/cgiwrap/rebol/rss-get-feed.r]
		[site "PHP Home"     url http://www.php.net/news.rss]
		[site "Ruby Home"    url http://www.ruby-lang.org/en/index.rdf]
		[site "Mono Project" url http://www.mono-project.com/news/index.rss2]
		
		; DB
		[site "MySQL"        url http://dev.mysql.com/mysql.rss]
		[site "PostgreeSQL"  url http://www.postgresql.org/news.rss]
		[site "OTN Headlines" url http://www.oracle.com/technology/syndication/rss_otn_news.xml]

		; Amiga
		[site "Polski Portal Amigowy" url http://www.ppa.pl/newsy/b2rss.xml]
		[site "EXEC.pl" url http://www.exec.pl/news.rss]

		; Inne
		[site "Rowery!Olsztyn" url http://www.rowery.olsztyn.pl/wiki/feed.php refresh 2:00]
		[site "DCResource"   url http://www.dcresource.com/newsfeed/news.rdf]
	]

	def-refresh: 1:00

	set 'rss-site has [site] [
		; zwraca liste nazw serwisow rss
		site: copy []
		foreach rss hosts [append site rss/site]
		return site
	]

	set 'load-rss func [
		"Wczytuje RSS serwera okreslonego pozycja w liscie serwerow; Zwraca string! lub none!"
		num [integer!] "numer sajtu"
		/force "wymusza aktualizacje danych"
		/local url dat] [

		attempt [
			url: to-url hosts/:num/url
			dat: either any [not (valid-rss num) force] [read-thru/update url] [read-thru url]
			to-string dat
		]
	]

	set 'valid-rss func [
		"Sprawdza czy dane w cache sa aktulne; Zwraca wartosc logic!"
		num [integer!] "numer sajtu"
		/local max-age] [

		if not attempt [exists? path-thru hosts/:num/url] [return false]
		max-age: any [
			attempt [to-time hosts/:num/refresh]
			def-refresh
		]
		((rss-datetime num) + max-age) > now
	]

	set 'rss-datetime func [
		"Pobiera date pobrania danych do cache; Zwraca wartosc date!"
		num [integer!] "numer sajtu"] [

		any [
			attempt [modified? path-thru hosts/:num/url]
			now
		]
	]
]

ctx-rss-xml: context [
	standards: [
		; tabela standardow zamiany 18 polskich znakow (duze/male)
		windows-1250 [165 198 202 163 209 211 140 143 175 185 230 234 179 241 243 156 159 191]
		iso-8859-2 [161 198 202 163 209 211 166 172 175 177 230 234 179 241 243 182 188 191]
		utf-8 [260 262 280 321 323 211 346 377 379 261 263 281 322 324 243 347 378 380]
		ascii [065 067 069 076 078 079 083 090 090 097 099 101 108 110 111 115 122 122]
	]
	local-charset: select standards any [select [4 ascii 3 windows-1250] (fourth system/version) 'ascii]
	
	to-local-charset: func [
		"Zmienia standard polskich znakow; Zwraca string! po konwersji"
		str [string!] "tekst do konwersji"
		encoding [string! none!] "standard zrodlowy"] [

		encoding: attempt [to-word to-string encoding]
		iconv str any [(select standards encoding) standards/utf-8] local-charset
	]

	iconv: func [
		"Konwertuje polskie znaki w tekscie; Zwraca string! po konwersji"
		str [string!] "tekst do konwersji"
		inp [block!] "tablica konwersji (wejsciowa)"
		out [block!]  "tablica konwersji (wyjsciowa)"
		/local i j c here] [

		; standardem docelowym nie moze byc UTF-8, zrodlowym nie moze byc ASCII
		if any [
			same? inp out 
			same? inp standards/ascii
			out/1 > 255 ; foreach code out [if code > 255 [break/return true]]
		][
			return str
		]
		
		parse/all str [
			any [
				here: skip (
					c: first here
					if all [(inp/1 < 255) (c > 127)] [
						; znaki narodowe maja kod > 127
						any [
							none? i: attempt [index? find inp to-integer c]
							change here to-char out/:i
						]
					]
					if all [(inp/1 > 255) (c > 127)] [
						; UTF-8
						; znaki < 128 sa przepuszczane bez zmian
						either all [(c > 191) (c < 224)] [
							; dwa okrety
							i: ((to-integer c) and 31) * to-integer (power 2 6)
							i: i or (to-integer (second here) and 63)
							remove/part here 2
						][
							; trzy oktety
							i: ((to-integer c) and 15) * to-integer (power 2 12)
							i: i or ((to-integer (second here) and 63) * to-integer (power 2 6))
							i: i or (to-integer (third here) and 63)
							remove/part here 3
						]
						insert here any [
							if none? j: attempt [index? find inp i] ["."]
							to-char out/:j
						]
					]
				) :here
				skip
			]
		]
		head here
	]

	tokens: ["amp" {&} "lt" {<} "gt" {>} "nbsp" { } "apos" {'} "quot" {"} "raquo" {-} "ldquo" {"} "rdquo" {"} "rsquo" {'}]
	escape-html: func [
		"Zamienia encje HTML na tekst; Zwraca string! po konwersji"
		text [string!] "tekst do konwersji"
		/local here there entity] [

		entity: complement charset { :;<>&#}
		parse/all text [
			any [
				here:
				end break

				| "&"
					[
					"#" copy item to ";" skip there: (
						remove/part here there
						attempt [insert here form to-char to-integer item]
					) 
					:here

					| copy item some entity ";" there: (
						remove/part here there
						any [
							none? code: select tokens item
							insert here code
						]
					)
					:here
					]

				| ["<![" "CDATA[" | "]]>"] there: (remove/part here there) :here

				| skip
			] 
		]
		head here
	]

	strip-html: func [
		"Usuwa znaczniki HTML z tekstu; Zwraca string! po konwersji"
		text [string!] "tekst do konwersji"
		/local page] [

		remove-each tag page: load/markup escape-html (trim/lines/tail text) [tag? tag]
		form page
	]

	rss: copy [] ; miejsce na wynikowa tablice informacji
	ctx: copy [] ; kontekst znalezionego znacznika

	emit: func ['scope desc] [
		desc: any [desc ""]
		repend ctx [scope (strip-html desc)]
	]

	parts: [
		["<channel" thru ">" (append rss 'channel ctx: copy [])] | </channel> |
		["<image" thru ">" (repend rss [ctx 'image] ctx: copy [])] | </image> |
		["<items" thru ">"] | </items> |
		["<poll" thru ">" (repend rss [ctx 'poll] ctx: copy [])] | </poll> |
		["<textinput" thru ">" (repend rss [ctx 'textinput] ctx: copy [])] | </textinput> |
		["<item" thru ">" (repend rss [ctx 'item] ctx: copy [])] | </item> |
		[<title> copy title to </title> (emit 'title title)] |
		[<link> copy link to </link> (emit 'link link)] |
		[<url> copy url to </url> (emit 'url url)] |
		[<description> copy desc to </description> (emit 'description desc)] |
		[<pubdate> copy pubdate to </pubdate> (emit 'pubdate pubdate)] |
		[<dc:date> copy pubdate to </dc:date> (emit 'pubdate pubdate)] |
		[<dc:pubdate> copy pubdate to </dc:pubdate> (emit 'pubdate pubdate)] |
		skip
	]

	rules: [
		some parts
		to end (repend rss [ctx])
	]

	set 'parse-rss func [
		"Zamienia RSS XML na blok danych rebol; Zwraca wartosc logic!"
		scope [word!] "zakres danych (channel|image|item|poll|...)"
		dat [string!] "dane xml"
		f [any-function!] "funkcja callback; otrzymuje parametry scope jako argument (block!)"
		/local rc encoding] [

		rc: true
		; pobieranie poszczegolnych newsow (item) oznacza koniecznosc odwiezenia calego rss
		if any [(empty? rss) (scope = 'item)] [
		
			; konwertuj wykryty standard (domyslnie UTF-8)
			any [
				parse/all detab dat [
					to "<?xml" thru "encoding" 2 skip 
					copy encoding to {"}
					thru {?>} to end
				]
				encoding: none
			]
			dat: to-local-charset dat encoding

			clear rss
			clear ctx
			rc: parse/all detab dat rules
		]
		if rc [
			; dla kazdego elementu zakresu (scope) wywolaj funkcje callback
			; parametrem funkcji callback jest blok danych zwiazany z danym zakresem
			; na wszelki wypadek jest sprawdzane czy zakres (scope) jest typu word! co
			; zapobiega przekazywaniu do callback przypadkowych danych
			foreach [item item-data] rss [if all [(word? item) (item = scope)] [f item-data]]
		]
		return rc
	]
]

ctx-rss-display: context [
	def-offset: 4x1 ; odleglosc XY od gornej ramki do pierwszego elementu listy newsow
	def-list-separator: on
	def-list-date: on
	def-list-desc: on
    
	pos-offset: def-offset
	browse-url: none
	list-box: none
	list-pane: none
	last-rss-num: 0

	; funkcje przesuwajace liste newsow (scroll-list) oraz scrollera (scroller-value)
	; przesuniecie slidera powoduje aktualizacje pozycji listy newsow
	scroll-list: func [value [number!]] [
		list-box/offset/y: negate value * (list-box/size/y - gui-news-list/size/y)
		show list-box
	]
	scroller-value: func [distance [number!]] [
		delta-y: gui-news-slider/data + (distance * 20 / pos-offset/y)
		if delta-y < 0 [delta-y: 0]
		if delta-y > 1 [delta-y: 1]
		scroll-list gui-news-slider/data: delta-y
		show gui-news-slider
	]

	; funkcje wybierajace z listy nastepny (next-host) lub poprzedni (prev-host) serwis rss w liscie
	; lista serwisow jest pobierana bezposredniu z VID gui-hosts-list
	next-host: has [data] [
		data: skip gui-hosts-list/data 1
		if not empty? data [gui-hosts-list/data: data]
		index? gui-hosts-list/data
	]
	prev-host: does [index? gui-hosts-list/data: skip gui-hosts-list/data -1]

	clear-display: does [
		; inicjalizuje zmienne gui; funkcja musi byc wywolana przed dostepem do list-pane i list-box
		; odswiezenie gui nastepuje w funkcji display-rss
		pos-offset: def-offset
		list-box: make-face/size 'box as-pair gui-news-list/size/x 1
		gui-news-list/pane: list-box
		list-pane: list-box/pane: copy []
	]

	display-error: func [
		"Wyswietla informacje o bledzie; Odswiezenie gui nastepuje w funkcji display-rss"
		text [string!] "naglowek bledu"
		desc [string! none!] "opis bledu"] [

		clear-display
		hide gui-browse-button
		append-news text none desc none
	]

	parse-rss-items: func [
		"Callback funkcji parse-rss; Dodaje do listy koleny news"
		news [block!] "block danych przekazany przez parse-rss"
		/local link desc date] [

		desc: attempt [news/description]
		link: attempt [news/link]
		date: any [
			attempt [form to-date skip news/pubdate 5]
			attempt [form to-date replace copy news/pubdate "T" " "]
			attempt [news/pubdate]
		]
		attempt [append-news (form news/title) link desc date]
	]
	parse-rss-channel: func [
		"Callback funkcji parse-rss; Pobiera channel/link url do zmiennej globalnej browse-url"
		channel [block!] "block! danych przekazany przez parse-rss"] [

		browse-url: none
		any [
			attempt [
				browse-url: to-url channel/link
				show gui-browse-button
			]
			hide gui-browse-button
		]
	]

	set 'display-rss func [
		"Wyswietla rss serwera okreslonego pozycja w liscie serwerow; Zwraca wartosc logic!"
		num [integer!] "numer sajtu"
		/force "wymusza aktualizacje danych"
		/local desc link nf error list-lay tl][

		either all [(valid-rss num) (not force)][
			; jezeli nie bylo zmiany rss - nie odswiezaj listy
			if (last-rss-num = num) [return true]
			nf: false
			dat: load-rss num
		][
			nf: flash/with "Please Wait..." main-window
			dat: load-rss/force num
		]
		last-rss-num: num

		; upewnij sie ze gui-hosts-list zawiera poprawne dane o wybranym serwerze rss
		gui-hosts-list/data: skip gui-hosts-list/list-data (num - 1)
		gui-hosts-list/text: first gui-hosts-list/data

		attempt [
			; hack! niestety wymaga by drop-down by wczesniej chociaz raz otwarty
			if list-lay: gui-hosts-list/list-lay [
				tl: first list-lay/pane
				; zmien podswietlony element w liscie drop-down zgodnie z wyborem usera
				clear tl/picked
				append tl/picked gui-hosts-list/text
				; przesun liste tak by nowy element byl widoczny
				tl/sld/data: (index? gui-hosts-list/data) / (length? gui-hosts-list/texts)
				do-face tl/sld tl/sld/data
			]
		]

		either not none? dat [
			clear-display
			gui-timer/text: form rss-datetime num

			error: not all [
				parse-rss 'item dat :parse-rss-items
				parse-rss 'channel dat :parse-rss-channel
				not empty? list-pane ; list-pane jest pusty gdy gui-news-list nie zawiera newsow
			]
		][

			; dane nie zostaly zaladowane
			error: true
		]
		if error [display-error {Error reading news feed!} {please check internet connection; press "refresh" button to try again}]
		if nf [unview/only nf]

		; przesun scroller w polozenie wyjsciowe i przelicz pozycje suwaka
		gui-news-slider/data: 0
		gui-news-slider/redrag (gui-news-list/size/y / list-box/size/y)

		show [
			gui-news-slider
			gui-timer
			gui-news-list
			gui-hosts-list
		]

		recycle
		return not none? dat
	]

	make-header: func [
		"Tworzy naglowek wiadomosci wykorzystujac VID button; Zwraca object! VID BUTTON"
		hdr-text [string! none!] hdr-url [url! string! none!] hdr-size [pair!] hdr-offset [pair!]] [

		make get-style 'button [
			size: hdr-size
			offset: hdr-offset
			text: trim/lines/head/tail hdr-text
			edge: make edge [size: 0x0]
			font: make font [align: 'left size: 13]
			user-data: either none? hdr-url [none] [copy hdr-url]
			action: make function! [] [any [(none? user-data) (browse/only user-data)]]
		]
	]
	make-line: func [
		"Tworzy linie oddzielajaca naglowek wiadomosci od jej tresci; Zwraca object! VID BOX"
		line-size [pair!] line-offset [pair!]] [

		make get-style 'box [
			size: line-size ; minimalna wysokosc 'box wynosi 3pix
			offset: line-offset
			edge: make edge [color: coal size: 1x1]
		]
	]
	make-description: func [
		"Tworzy opis wiadomosci wykorzystujac VID txt; Zwraca object! VID TXT"
		desc-text [string! none!] desc-size [pair!] desc-offset [pair!]] [

		make get-style 'txt [
			size: desc-size
			offset: desc-offset
			text: trim/lines/head/tail desc-text
			font: make font [align: 'left color: black]
		]
	]
	make-pubdate: func [
		"Tworzy informcje o dacie publikacji wykorzystujac VID text; Zwraca object! VID TEXT"
		pubdate-text [string! none!] pubdate-size [pair!] pubdate-offset [pair!]] [

		make get-style 'text [
			size: pubdate-size
			offset: pubdate-offset
			text: trim/lines/head/tail pubdate-text
			font: make font [align: 'left color: black name: "arial" size: 11]
		]
	]

	append-news: func [
		"Dodaje pozycje do listy wyswietlanych newsow (list-box); Nie zwraca wartosci"
		text [string!] "tekst do wyswietlenia"
		link [string! none!] "link powiazany z tekstem do wyswietlania lub none!"
		desc [string! none!] "dodatkowe informacje do wyswietlenia lub none!"
		date [string! none!] "data publikacji"
		/local btn btn-size wh] [

		btn-size: as-pair (gui-news-list/size/x - pos-offset/x - 8) (16)
		jobs: [
			; [check this] [do that]
			[true] [make-header text link btn-size pos-offset]
			[def-list-separator] [make-line (as-pair btn-size/x 3) pos-offset]
			[all [def-list-date date]] [make-pubdate date btn-size pos-offset]
			[all [def-list-desc desc]] [make-description desc btn-size pos-offset]
		]

		foreach [check job] jobs [
			if do check [
				btn: do job
				; jezeli tekst nie miesci sie w jednej linijce to zmien wysokosc przycisku (Y)
				if not zero? (wh: size-text btn) [btn/size/y: wh/y + 4]
				append list-pane btn
				list-box/size/y: list-box/size/y + btn/size/y
				pos-offset: as-pair (pos-offset/x) (pos-offset/y + btn/size/y)
			]
		]
		; dodaj odstep miedzy poszczegolnymi newsami
		list-box/size/y: list-box/size/y + 4
		pos-offset/y: pos-offset/y + 4
	]

	set 'look-and-feel stylize [
		cycle-list: drop-down 180 rows 8 texts rss-site black [
			; self/data musi zawierac index? do pozycji elementu w liscie self/list-data
			; z indexu korzystaja wszystkie funkcje gui
			gui-hosts-list/data: find gui-hosts-list/list-data gui-hosts-list/data
			display-rss index? gui-hosts-list/data
		]

		refresh-btn: btn #"r" "Refresh" [display-rss/force index? gui-hosts-list/data]

		browse-btn: btn #"b" "Browse Site" [if not none? browse-url [browse/only browse-url]]

		about-btn: btn-help [browse http://www.rebol.org/cgi-bin/cgiwrap/rebol/view-script.r?script=rss.r]

		news-list: box 336x260 edge [size: 1x1 color: black]

		news-slider: scroller 16x260 edge [size: 1x1 color: black] [scroll-list value]

		refresh-time: info 200 middle form now edge [size: 0x0]
			feel [engage: func [face action event] [if action = 'time [do-face face none]]]
			[display-rss index? gui-hosts-list/data]
	]
        
	insert-event-func [
		switch event/type [
			; obsluga kolka w myszce (przesuwanie listy newsow)
			scroll-line [scroller-value event/offset/y]
			; obslga klawiszy kursora
			key [
				switch event/key [
					up [scroller-value -3]
					down [scroller-value 3]
					left [display-rss prev-host]
					right [display-rss next-host]
				]
			]
		]
		event
	]
]

if get-env "KDEDIR" [
	attempt [
		unprotect 'browse
		browse: func [value [any-string!] /only][call reform ["konqueror" rejoin [{"} value {"}]]]
	]
]

attempt [
	unprotect 'path-thru
	path-thru: func [
		"Return a path relative to the disk cache."
		url /local purl path
	][
		if file? url [return url]
		if not all [purl: decode-url url purl/host] [return none]
		path: rejoin [view-root/public slash purl/host slash any [purl/path ""] any [purl/target ""]]
		any [(suffix? path) append path "index.txt"]
		foreach ch [{?} {*} {"} {<} {>} {|}] [replace/all path ch "_"]
	]
]

img: load 64#{
/9j/4AAQSkZJRgABAQIAAAAAAAD/2wBDAAoHBwgHBgoICAgLCgoLDhgQDg0NDh0V
FhEYIx8lJCIfIiEmKzcvJik0KSEiMEExNDk7Pj4+JS5ESUM8SDc9Pjv/2wBDAQoL
Cw4NDhwQEBw7KCIoOzs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7Ozs7
Ozs7Ozs7Ozs7Ozs7Ozv/wAARCAGQAfQDASIAAhEBAxEB/8QAHwAAAQUBAQEBAQEA
AAAAAAAAAAECAwQFBgcICQoL/8QAtRAAAgEDAwIEAwUFBAQAAAF9AQIDAAQRBRIh
MUEGE1FhByJxFDKBkaEII0KxwRVS0fAkM2JyggkKFhcYGRolJicoKSo0NTY3ODk6
Q0RFRkdISUpTVFVWV1hZWmNkZWZnaGlqc3R1dnd4eXqDhIWGh4iJipKTlJWWl5iZ
mqKjpKWmp6ipqrKztLW2t7i5usLDxMXGx8jJytLT1NXW19jZ2uHi4+Tl5ufo6erx
8vP09fb3+Pn6/8QAHwEAAwEBAQEBAQEBAQAAAAAAAAECAwQFBgcICQoL/8QAtREA
AgECBAQDBAcFBAQAAQJ3AAECAxEEBSExBhJBUQdhcRMiMoEIFEKRobHBCSMzUvAV
YnLRChYkNOEl8RcYGRomJygpKjU2Nzg5OkNERUZHSElKU1RVVldYWVpjZGVmZ2hp
anN0dXZ3eHl6goOEhYaHiImKkpOUlZaXmJmaoqOkpaanqKmqsrO0tba3uLm6wsPE
xcbHyMnK0tPU1dbX2Nna4uPk5ebn6Onq8vP09fb3+Pn6/9oADAMBAAIRAxEAPwDt
aKKKACiiigAooooAKKKKACiiigAooooAKKKKACiiigAooooAKKKKAEoyKCQoyTxV
SWVpG2jOKAFml3HavSprWxL4aQcelSWdnjEkg57Cr+MUAIqqi4AwKXpS9KoXl55f
yIeaAFvb0Rgoh+astiWbcxyTQSWOT1NJQAUtFFACVYtLczyDI+UdahVdzADvW1aQ
CGEDuaAJlUKoA6CloooAKKKKACiiigAoopCwHU0AZuqdQKz60ryI3MgEfOKbHph6
uaAM7BNSJbyueENa8dnCn8OanACjAGKAMuPTWJy5xVuOyhjHTJqzjij8KAGhQvQA
UtFFACUUtJQAlFFBoAQ0UGigCvdQCWM4HNZDqUYqeCK36z763/jUfWgDPooooAKK
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
oAKKKSgAoooNACUUUUAf/9k=
}

main-window: center-face layout [
	backdrop img effect [tile-view]
	key (escape) [unview quit]
	styles look-and-feel
	origin 2x2 space 2x2 across
	gui-hosts-list: cycle-list pad 08x0 refresh-btn
	gui-browse-button: browse-btn about-btn return
	gui-news-list: news-list
	gui-news-slider: news-slider return
	gui-timer: refresh-time rate 00:15:00
]

display-rss 1
view/title main-window "Live Bookmarks"

][
	alert rejoin [{We apologize, an unexpected error occurred (} get in disarm err 'id { error)}]
]
quit
