REBOL [
	Title: "GeoRSS converter"
	Purpose: "Converts GeoRSS xml to GPX/KML/OziExplorer formats"
	Author: "pijoter"
	Date:  7-Oct-2009/21:04:06+2:00
	File: %georss.r
	Home: http://rowery.olsztyn.pl/rebol
	License: "GNU General Public License (Version II)"
	Library: [
		level: 'intermediate
		platform: 'all
		type: [tool]
		domain: [file-handling web]
		tested-under: [
			view 2.7.6  on [WinXP Linux]
		]
		support: none
		license: 'GPL
	]
	Tabs: 3
]

dt: context [
	to-epoch: func [dt [date!]] [
		;; epoch to czas gmt
		any [
			attempt [to-integer (difference dt 1970-01-01/00:00:00)]
			(dt - 1970-01-01/00:00:00) * 86400
		]
	]

	from-epoch: func [value [integer!] /zone tz [time!] /local date time dt] [
		value: to-time value
		date: 1970-01-01 + (round/down value / 24:00:00)
		time: value // 24:00:00

		dt: to-date rejoin [date "/" time]
		dt/zone: any [(if value? zone [tz]) 0:00]
		dt + dt/zone
	]

	normalize: func [dt [date!] /date /time /local pad d t s] [
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

	to-stamp: func [dt [date!] /date /time] [
		dt: any [
			if date [self/normalize/date dt]
			if time [self/normalize/time dt]
			self/normalize dt
		]
		remove-each ch dt [found? find "-/:" ch]
	]

	to-gmt: func [dt [date!]] [
		any [
			zero? dt/zone
			attempt [
				dt: dt - dt/zone
				dt/zone: 0:00
			]
		]
		dt
	]

	to-iso: func [dt [date!]] [
		dt: self/to-gmt dt
		append (replace (self/normalize dt) "/" "T") "Z"
	]
]

lang: context [
	local-encoding: 'iso-8859-1
	standards: [
		; tabela standardow zamiany znakow (DUZE/male)
		windows-1250 [165 198 202 163 209 211 140 143 175 185 230 234 179 241 243 156 159 191]
		iso-8859-2 [161 198 202 163 209 211 166 172 175 177 230 234 179 241 243 182 188 191]
		utf-8 [
			; pl
			260 262 280 321 323 211 346 377 379
			261 263 281 322 324 243 347 378 380
			; de
			196 203 207 214 220 223
			228 235 239 246 252 223
			; sk
			193 196 268 270 201 205 313 317 327 211 212 340 352 356 218 221 381
			223 228 269 271 233 237 314 318 328 243 244 341 353 357 250 253 382
			; cz
			193 268 270 201 282 205 327 211 344 352 356 218 366 221 381
			225 269 271 233 283 237 328 243 345 353 357 250 367 253 382
		]
		iso-8859-1 [
			; pl
			065 067 069 076 078 079 083 090 090
			097 099 101 108 110 111 115 122 122
			; de
			065 069 073 079 085 083
			097 101 105 111 117 115
			; sk
			065 065 067 068 069 073 076 076 078 079 079 082 083 084 085 089 090
			097 097 099 100 101 105 108 108 110 111 111 114 115 116 117 121 122
			; cz
			065 067 068 069 069 073 078 079 082 083 084 085 085 089 090
			097 099 100 101 101 105 110 111 114 115 116 117 117 121 122
		]
	]
	local-charset: does [select self/standards self/local-encoding]

	check: func [
		"Sprawdza standard znakow danych rss/xml; Zwraca word! nazwy standardu"
		text [string! binary!] "rss/xml do sprawdzenia" /local encoding] [

		encoding: none

		parse/all detab to-string text [
			to "<?xml" thru "encoding" 2 skip
			copy encoding to {"}
			thru {?>} to end
		]

		to-word any [encoding 'utf-8]
	]

	to-ascii: func [
		"Zamienia polskie znaki na ASCII; Zwraca string! po konwersji"
		text [string! binary!] "tekst do konwersji"
		encoding [string! word! none!] "standard zrodlowy" /local text-charset] [

		text-charset: any [
			select self/standards (to-word encoding)
			self/standards/utf-8
		]

		to-string self/iconv text text-charset self/standards/iso-8859-1
	]

	to-local-charset: func [
		"Zmienia standard polskich znakow; Zwraca string! po konwersji"
		text [string! binary!] "tekst do konwersji"
		encoding [string! word! none!] "standard zrodlowy" /local text-charset] [

		text-charset: any [
			select self/standards (to-word encoding)
			self/standards/utf-8
		]

		if (self/local-encoding = 'utf-8) [text: self/clean text]
		to-string self/iconv text text-charset self/local-charset
	]

	clean: func [
		"Czysci tekst ze znaku #352 (2 oktety)"
		text [string! binary!] "tekst do konwersji" /local here c i j] [

		parse/all text [
			any [
				here: skip (
					c: first here

					if (c > 127) [
						; UTF-8
						; znaki < 128 sa przepuszczane bez zmian
						i: 0
						either all [(c > 191) (c < 224)] [
							; dwa okrety
							i: ((to-integer c) and 31) * to-integer (power 2 6)
							i: i or (to-integer (second here) and 63)
						][
							; trzy oktety
							i: ((to-integer c) and 15) * to-integer (power 2 12)
							i: i or ((to-integer (second here) and 63) * to-integer (power 2 6))
							i: i or (to-integer (third here) and 63)
						]

						; znak #352 powoduje problemy przy wczytywaniu pliku do programow zarzadzajacych GPX
						; najlepiej zamienic go na ASCII
						if i = 352 [
							remove/part here 2
							insert here  any [
								if none? j: attempt [index? find self/standards/utf-8 i] [#"."]
								to-char self/standards/iso-8859-1/:j
							]
						]
					]
				) :here
				skip
			]
		]
		head here
	]

	unicode?: func [text-charset [block!]] [same? text-charset self/standards/utf-8]
	ascii?: func [text-charset [block!]] [same? text-charset self/standards/iso-8859-1]

	iconv: func [
		"Konwertuje polskie znaki w tekscie; Zwraca string! po konwersji"
		text [string! binary!] "tekst do konwersji"
		inp [block!] "tablica konwersji (wejsciowa)"
		out [block!] "tablica konwersji (wyjsciowa)" /local here unicode c i j] [

		all [
			any [
				(same? inp out)
				(self/unicode? out) ;; unikod nie moze byc standardem docelowym
				(self/ascii? inp) ;; ascii nie moze byc zrodlowym
			]
			return text
		]

		unicode: unicode? inp

		parse/all text [
			any [
				here: skip (
					c: first here

					either not unicode [
						if c > 127 [
							; znaki narodowe maja kod >= 127
							any [
								none? i: attempt [index? find inp (to-integer c)]
								change here (to-char out/:i)
							]
						]
					][
						if (c > 127) [
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
								if none? j: attempt [index? find inp i] [#"."]
								to-char (out/:j)
							]
						]
					]
				) :here
				skip
			]
		]
		head here
	]
]

html: context [
	tokens: [
		"lt" {<} "gt" {>} "amp" {&} "nbsp" { } "apos" {'}
		"quot" {"} "raquo" {-} "ldquo" {"} "rdquo" {"} "rsquo" {'}
	]

	escape: func [
		"Zamienia encje HTML na tekst; Zwraca string! po konwersji"
		text [string!] "tekst do konwersji"	/local here there entity] [

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
							none? (code: select tokens item)
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

	strip-tags: func [
		"Usuwa znaczniki HTML z tekstu; Zwraca string! po konwersji"
		text [string!] "tekst do konwersji" 
		/allow tags [block! tag!] "znaczniki ignorowane"
		/local allow-tags page] [

		contains?: func [tags [block!] tag [tag!]] [found? attempt [find tags to-tag first (parse (to-string tag) none)]]
		allow-tags: make block! []
		if tags [append allow-tags tags]

		page: load/markup (self/escape (trim/lines text))
		comment {
			replace/all text {<br>} LF
			page: load/markup (self/escape (trim text))
		}
		remove-each tag page [
			all [
				tag? tag
				not contains? allow-tags tag
			]
		]
		form page
	]
]

rss: context [
	rss: copy [] ; miejsce na wynikowa tablice informacji
	ctx: copy [] ; kontekst znalezionego znacznika

	round-location: func [value [string! number!]] [
		any [
			number? value
			value: to-decimal value
		]
		round/to value 0.000001
	]

	round-alt: func [value [string! number!]] [
		any [
			number? value
			value: to-decimal value
		]
		round/to value 0.01
	]

	emit-text: func [tag [word!] text [string! none!]] [
		text: any [text {}]
		repend self/ctx [tag (html/strip-tags/allow text [<a> </a> <img>])]
		any [
			select self/ctx 'encoding
			repend self/ctx ['encoding (form lang/local-encoding)]
		]
	]

	emit-decimal: func [tag [word!] value [number! none!]] [
		value: any [value 0.0]
		repend self/ctx [tag value]
	]

	emit-date: func [tag [word!] date [string! none!]] [
		repend self/ctx [
			tag any [
				attempt [to-date (skip date 5)]
			 	now
			]
		]
	]

	emit-point: func [point [string! none!] /local lat lon] [
		point: html/strip-tags any [point {0.0 0.0}]
		set [lat lon] parse point none

		self/emit-decimal 'lat (self/round-location lat)
		self/emit-decimal 'lon (self/round-location lon)
	]

	emit-poslist: func [poslist [string! none!] /local blk lat lon] [
		track: html/strip-tags any [poslist {0.0 0.0}]
		blk: make block! 100

		repend self/ctx ['track (parse poslist none)]
	]

	emit-alt: func [alt [string! number! none!]] [
		alt: any [attempt [to-decimal alt] 0]
		self/emit-decimal 'alt (self/round-alt alt)
	]

	parts: [
		["<channel" thru ">" (
				append self/rss 'channel
				self/ctx: copy []
			)
		] | </channel> |
		["<item" thru ">" (
				repend self/rss [ctx 'item]
				self/ctx: copy []
			)
		] | </item> |
		[<title> copy title to </title> (emit-text 'title title)] |
		[<description> copy text to </description> (emit-text 'description text)] |
		[<pubdate> copy date to </pubdate> (emit-date 'created date)] |
		[<georss:point> copy point to </georss:point> (emit-point point)] |
		[<georss:elev> copy alt to </georss:elev> (emit-alt alt)] |
		[<gml:poslist> copy poslist to </gml:poslist> (emit-poslist poslist)] |
		skip
	]

	rules: [
		some parts
		to end (repend self/rss [self/ctx])
	]

	make-track: func [t [block!] /local blk i lat lon] [
		blk: make block! 100
		i: 0

		foreach [lat lon] t/track [
			i: i + 1

			repend/only blk [
				'title any [(select t 'title) i]
				'encoding lang/local-encoding
				'lat (self/round-location lat)
				'lon (self/round-location lon)
				'created t/created
			]
		]

		return blk
	]

	decode: func [
		"Zamienia RSS XML na blok danych rebol; Zwraca wartosc logic!"
		text [string! binary!] "dane xml" /local encoding] [

		clear self/rss
		clear self/ctx

		encoding: lang/check text
		text: lang/to-local-charset text encoding

		parse/all (detab text) self/rules
	]

	save: func [
		"Zapisuje dane rss za pomoca funkcji save z obiektu dump"
		dump [object!] "obiekt zapisujacy dane do pliku"
		/as name [string! file!]  "nazwa pliku (bez rozszerzenia)" /local f w t rss-name] [

		f: get in dump 'save
		if not function? :f [return false]

		w: make block! 100
		t: make block! 10

		foreach [tag data] self/rss [
			if (tag = 'item) [
				any [
					if all [(select data 'lat) (select data 'lon)] [append/only w data]
					if select data 'track [append/only t (make-track data)]
				]
			]
		]

		;; jezeli istnieje to wykorzystaj nazwe z RSS
		name: form any [
			if as [name]
			if rss-name: attempt [select self/rss/channel 'title] [
				attempt [
					rss-name: lang/to-ascii rss-name self/rss/channel/encoding
					trim/all remove-each ch rss-name [found? find "/?:\" ch]
				]
			]
			reform ["Unknown" (dt/to-stamp now)]
		]

		all [
			not empty? name
			attempt [f name w t]
		]
	]
]

host: context [
	windows?: does [system/version/4 = 3]
	linux?: does [system/version/4 = 4]
]

gpx: context [
	WPT-SUFFIX: {.gpx}
	TRK-SUFFIX: {.gpx}

	out: none

	save: func [name [string!] w [block!] t [block!] /local encoding i gpx] [
		self/out: make block! 1000

		if error? try [
			if not empty? w [self/waypoints name w]
			if not empty? t [
				self/tracklogs name t
				;;self/routes name t
			]
		][
			print ["error!" name "format" WPT-SUFFIX]
		]

		if not empty? out [
			encoding: any [
				attempt [t/1/1/encoding] ;; pierwszy trackpoint, pierwsza sekcja
				attempt [w/1/encoding] ;; pierwszy waypoint
				"UTF-8"
			]

			insert head self/out rejoin [
				{<?xml version="1.0" encoding="} encoding {"?>} LF
				{<gpx version="1.1"} 
				{ creator="} reform [system/script/header/file http://rowery.olsztyn.pl/rebol] {"} 
				{ xmlns="http://www.topografix.com/GPX/1/1"}
				{ xmlns:rmc="urn:net:trekbuddy:1.0:nmea:rmc"} 
				{ xmlns:gpxx="http://www.garmin.com/xmlschemas/GpxExtensions/v3"}
				{ xmlns:gpxtpx="http://www.garmin.com/xmlschemas/TrackPointExtension/v1"}
				{ xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"} 
				{ xsi:schemaLocation="http://www.topografix.com/GPX/1/1}
				{ http://www.topografix.com/GPX/1/1/gpx.xsd}
				{ http://www.garmin.com/xmlschemas/GpxExtensions/v3}
				{ http://www8.garmin.com/xmlschemas/GpxExtensions/v3/GpxExtensionsv3.xsd}
				{ http://www.garmin.com/xmlschemas/TrackPointExtension/v1}
				{ http://www8.garmin.com/xmlschemas/TrackPointExtensionv1.xsd">} LF
				{  <metadata>} LF
				{    <link href="http://rowery.olsztyn.pl/rebol">} LF
				{      <text>} system/script/header/file {</text>} LF
				{    </link>} LF
				{    <name>} (join name TRK-SUFFIX) {</name>} LF
				{    <time>} (dt/to-iso now) {</time>} LF
				{  </metadata>} LF
			]
			repend self/out [{</gpx>} LF]

			gpx: to-file join name TRK-SUFFIX

			i: 0 foreach segment t [i: i + (length? segment)]
			printd [gpx "/" (length? w) "waypoints" (i) "tracklog-points" (length? t) "segments"]

			attempt [write/direct/binary gpx form self/out]
		]
	]

	waypoints: func [name [string!] w [block!] /local i description point alt spd] [
		i: 0

		foreach point w [
			i: i + 1

			if desc: select point 'description [
				desc: trim/lines replace/all desc LF {; }
				if empty? desc [desc: none]
			]

			append out rejoin [
				{  <wpt lat="} (point/lat) {" lon="} (point/lon) {">} LF
				{    <name><![CDATA[} any [(select point 'title) (dt/to-stamp point/created)] {]]></name>} LF
				{    <desc><![CDATA[} any [desc (dt/to-stamp point/created)] {]]></desc>} LF
				{    <sym>Waypoint</sym>} LF
				{    <time>} (dt/to-iso point/created) {</time>} LF
				any [
					if alt: select point 'alt [
						rejoin [{    <ele>} (alt) {</ele>} LF]
					]
					""
				]
				any [
					if spd: select point 'spd [
						rejoin [
							{    <cmt>speed } (spd) { km/h</cmt>} LF
							{    <extensions>} LF
							{      <gpxx:WaypointExtension>} LF
							{        <gpxx:DisplayMode>SymbolAndName</gpxx:DisplayMode>} LF
							{      </gpxx:WaypointExtension>} LF
						;;	{      <rmc:speed>} (spd) {</rmc:speed>} LF ;; http://www.symbianos.org/bugs/56
							{    </extensions>} LF
						]
					]
					""
				]
				{  </wpt>} LF
			]
		]
	]

	tracklogs: func [name [string!] t [block!] /local i point created alt spd] [
		created: any [(attempt [t/1/1/created]) now]

		append out rejoin [
			{  <trk>} LF
			{    <name>} name {</name>} LF
			{    <cmt>} reform [(dt/to-stamp/date created) "/" (length? t) "segments"] {</cmt>} LF
			{    <number>} 1 {</number>} LF
		]

		i: 0
		foreach segment t [
			i: i + 1
			append out rejoin [{    <trkseg>} LF]

			foreach point segment [
				append out rejoin [
					{      <trkpt lat="} (point/lat) {" lon="} (point/lon) {">} LF
					{        <time>} (dt/to-iso point/created) {</time>} LF
					any [
						if alt: select point 'alt [
							rejoin [{        <ele>} (alt) {</ele>} LF]
						]
						""
					]
					any [
						if spd: select point 'spd [
							rejoin [
								{        <cmt>speed } (spd) { km/h</cmt>} LF
								{        <extensions>} LF
								{          <rmc:speed>} (spd) {</rmc:speed>} LF ;; http://wiki.trekbuddy.net/index.php/Howtos
								{        </extensions>} LF
							]
						]
						""
					]
					{      </trkpt>} LF
				]
			]
			append out rejoin [{    </trkseg>} LF]
		]

		append out rejoin [{  </trk>} LF]
	]

	routes: func [name [string!] t [block!] /local i segment created point n alt] [
		i: 0
		foreach segment t [
			i: i + 1

			name: any [(select segment/1 'title) name]
			created: any [(select segment/1 'created) now]

			append out rejoin [
				{  <rte>} LF
				{    <name><![CDATA[} name {]]></name>} LF
				{    <cmt>} (dt/to-stamp/date created) {</cmt>} LF
				{    <number>} i {</number>} LF
			]

			foreach point segment [
				append out rejoin [
					{    <rtept lat="} (point/lat) {" lon="} (point/lon) {">} LF
					{      <time>} (dt/to-iso point/created) {</time>} LF
					any [
						if alt: select point 'alt [
							rejoin [{      <ele>} (alt) {</ele>} LF]
						]
						""
					]
					{    </rtept>} LF
				]
			]
			append out rejoin [{  </rte>} LF]
		]
	]
]

ozi: context [
	WPT-SUFFIX: {.wpt}
	TRK-SUFFIX: {.plt}
	ALT_NOT_VALID: -777

	save: func [name [string!] w [block!] t [block!]] [
		if error? try [
			if not empty? w [self/waypoints name w]
			if not empty? t [self/tracklogs name t]
		][
			print ["error!" name "format" WPT-SUFFIX TRK-SUFFIX]
		]
	]

	to-ozi-alt: func [point [block!] /local alt] [
		any [
			if alt: select point 'alt [round/to (3.28083931316019 * alt) 0.01]
			ALT_NOT_VALID
		]
	]

	to-ozi-date: func [point [block!] /local date] [
		date: any [
			if date: select point 'created [dt/to-epoch date]
			dt/to-epoch now
		]
		(date / 86400) + 25569.0
	]

	to-ozi-title: func [point [block!] /local title] [
		any [
			if title: select point 'title [replace/all title {,} { }]
			dt/to-stamp point/created
		]
	]

	to-ozi-description: func [point [block!] /local desc spd] [
		any [
			if desc: select point 'description [
				desc: replace/all desc {,} { }
				desc: trim/lines (replace/all desc LF {; })
				if empty? desc [desc: none]
			]
			if spd: select point 'spd [
				reform [
					(dt/to-stamp point/created)
					"speed" (spd) "km/h"
				]
			]
			dt/to-stamp point/created
		]
	]

	waypoints: func [name [string!] w [block!] /local out i title description wpt spd alt point] [
		out: make block! 100
		i: 0

		append out rejoin [
			"OziExplorer Waypoint File Version 1.1" CRLF
			"WGS 84" CRLF
			"Reserved 2" CRLF
			"Reserved 3" CRLF
		]

		foreach point w [
			i: i + 1

			append out rejoin [
				i ","
				(self/to-ozi-title point) ","
				(point/lat) ","
				(point/lon) ","
				(to-ozi-date point) ","
				"0,0,3,0,65535,"
				(self/to-ozi-description point) ","
				"0,0,0,"
				(self/to-ozi-alt point) ","
				"8.25,0,17" CRLF
			]
		]

		wpt: to-file join name WPT-SUFFIX
		printd [wpt "/" (length? w) "waypoints"]
		write/direct/binary wpt form out
	]

	tracklogs: func [name [string!] t [block!] /local plt i out new-segment] [
		out: make block! 1000
		i: 0

		foreach segment t [
			foreach point segment [
				i: i + 1
				new-segment: to-integer (point = first segment)

				append out rejoin [
					(point/lat) ","
					(point/lon) ","
					(new-segment) ","
					(self/to-ozi-alt point) ","
					(self/to-ozi-date point) ","
					(dt/normalize/date point/created) ","
					(dt/normalize/time point/created) CRLF
				]
			]
		]

		insert (head out) rejoin [
			"OziExplorer Track Point File Version 2.1" CRLF
			"WGS 84" CRLF
			"Altitude is in Feet" CRLF
			"Reserved 3" CRLF
			"0,2,255," name ",0,0,2,8421376" CRLF
			i CRLF
		]

		plt: to-file join name TRK-SUFFIX
		printd [plt "/" (i) "tracklog-points" (length? t) "segments"]
		write/direct/binary plt form out
	]
]

kml: context [
	WPT-SUFFIX: {.kml}
	TRK-SUFFIX: {.kml}

	out: none

	save: func [name [string!] w [block!] t [block!] /local encoding i kml] [
		self/out: make block! 1000

		if error? try [
			if not empty? w [self/waypoints name w]
			if not empty? t [self/tracklogs name t]
		][
			print ["error!" name "format" WPT-SUFFIX]
		]

		if not empty? out [
			encoding: any [
				attempt [t/1/1/encoding] ;; pierwsza sekcja, pierwszy trackpoint
				attempt [w/1/encoding] ;; pierwszy waypoint
				"UTF-8"
			]

			insert head self/out rejoin [
				{<?xml version="1.0" encoding="} encoding {"?>} LF
				{<kml xmlns="http://www.opengis.net/kml/2.2">} LF
				{  <Document>} LF
				{    <name><![CDATA[} (form join name self/TRK-SUFFIX) {]]></name>} LF
				{    <open>1</open>} LF
				{    <description><![CDATA[} http://rowery.olsztyn.pl/rebol {]]></description>} LF
				{    <Style id="track">} LF
				{      <LineStyle>} LF
				{        <color>73ff0000</color>} LF
				{        <width>5</width>} LF
				{      </LineStyle>} LF
				{    </Style>} LF
				{    <Style id="point">} LF
				{      <IconStyle>} LF
				{        <Icon>} LF
				{          <href>http://maps.google.com/mapfiles/ms/micons/red-dot.png</href>} LF
				{        </Icon>} LF
				{      </IconStyle>} LF
				{      <LabelStyle>} LF
				{        <color>ffffffff</color>} LF
				{        <colorMode>normal</colorMode>} LF
				{        <scale>1</scale>} LF
				{      </LabelStyle>} LF
				{    </Style>} LF
			]

			repend self/out [
				{  </Document>} LF
				{</kml>} LF
			]

			kml: to-file join name TRK-SUFFIX

			i: 0 foreach segment t [i: i + (length? segment)]
			printd [kml "/" (length? w) "waypoints" (i) "tracklog-points" (length? t) "segments"]

			attempt [write/direct/binary kml form self/out]
		]
	]

	waypoints: func [name [string!] w [block!] /local title desc alt] [

		append self/out rejoin [
			{    <Folder>} LF
			{      <name>Waypoints</name>} LF
			{      <description>} (name) {</description>} LF
		]

		foreach point w [

			title: any [(select point 'title) (dt/to-stamp point/created)]
			desc: any [(select point 'description) (dt/to-stamp point/created)]
			alt: any [(select point 'alt) 0]

			append self/out rejoin [
				{      <Placemark>} LF
				{        <name><![CDATA[} (title) {]]></name>} LF
				{        <description><![CDATA[} (desc) {]]></description>} LF
				{        <styleUrl>#point</styleUrl>} LF
				{        <TimeStamp>} LF
				{          <when>} (dt/to-iso point/created) {</when>} LF
				{        </TimeStamp>} LF
				{        <Point>} LF
				{          <coordinates>} (rejoin [point/lon "," point/lat "," alt]) {</coordinates>} LF
				{        </Point>} LF
				{      </Placemark>} LF
			]
		]

		append self/out rejoin [
			{    </Folder>} LF
		]
	]

	tracklogs: func [name [string!] t [block!] 
		/local segment-start segment-stop begin end i point] [

		segment-start: func [segment [block!]] [select first segment 'created]
		segment-stop: func [segment [block!]] [select last segment 'created]

		begin: dt/to-iso any [(segment-start first t) now]
		end: dt/to-iso any [(segment-stop last t) now]

		append self/out rejoin [
			{    <Folder>} LF
			{      <name><![CDATA[} "Tracklogs" {]]></name>} LF
			{      <description><![CDATA[} (reform [(begin) "/" (end) "/" (length? t) "segments"]) {]]></description>} LF
		]

		i: 0
		foreach segment t [
			i: i + 1
			coordinates: make block! []

			foreach point segment [
				append coordinates rejoin [point/lon "," point/lat "," any [(select point 'alt) 0]]
			]

			begin: dt/to-iso any [(segment-start segment ) now]
			end: dt/to-iso any [(segment-stop segment) now]

			append self/out rejoin [
				{      <Placemark>} LF
				{        <name><![CDATA[} (rejoin [name "." i]) {]]></name>} LF
				{      <description><![CDATA[} (reform [(begin) "/" (end)]) {]]></description>} LF
				{        <styleUrl>#track</styleUrl>} LF
				{        <TimeSpan>} LF
				{          <begin>} (begin) {</begin>} LF
				{          <end>} (end) {</end>} LF
				{        </TimeSpan>} LF
				{        <LineString>} LF
				{          <tessellate>1</tessellate>} LF
				{          <altitudeMode>clampToGround</altitudeMode>} LF
				{          <coordinates>} (form coordinates) {</coordinates>} LF
				{        </LineString>} LF
				{      </Placemark>} LF
			]
		]

		append self/out rejoin [
			{    </Folder>} LF
		]

	]
]

printd: func [message [block! string!]] [
	any [
		;; system/options/quiet
		print message
	]
]

hold: does [
	any [
		system/options/quiet
		not host/windows?
		ask "^/press enter"
	]
]

;### MAIN ###

lang/local-encoding: 'utf-8
system/options/quiet: true

printd [
	system/script/header/title LF
	system/script/header/purpose LF
]

georss: [
	"czech-castles" http://maps.google.pl/maps/ms?ie=UTF8&hl=pl&vps=3&jsv=166d&msa=0&output=georss&msid=100165282220402807004.00043895e978f7e1f6152
	"czech-beer" http://maps.google.pl/maps/ms?ie=UTF8&hl=pl&vps=1&jsv=166d&msa=0&output=georss&msid=101139604405476279389.00043959d3879d1bab701
	"slovakia-unesco" http://maps.google.pl/maps/ms?ie=UTF8&hl=pl&vps=2&jsv=166d&msa=0&output=georss&msid=113068378107650564808.000435fe926ad3622f93c
]

foreach [name url] georss [
	text: read/binary url
	rss/decode text
	rss/save/as gpx (to-file name)
	;; rss/save/as kml (to-file name)
	;; rss/save ozi
]

hold quit

