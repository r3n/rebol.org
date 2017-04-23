REBOL [
	title: "PhotoTrackr DPL700 to GPX/PLT converter"
	purpose: "Converts memory dumps of the Gisteq PhotoTrackr GPS logger (MTK) to GPX/OziExplorer formats"
	author: "pijoter"
	date: 3-Oct-2009/15:44:16+2:00
	file: %dpl700-converter.r
	license: "GNU General Public License (Version II)"
	library: [
		level: 'intermediate
		platform: 'all
		type: [tool]
		domain: [file-handling]
		tested-under: [
			view 2.7.6  on [Linux WinXP]
		]
		support: none
		license: 'GPL
	]
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

sr: context [
	log: make block! 60

	chipset: context [
		;; MTK CHIPSET
		;; 4b lon 4b lat 4b datetime 2b alt 1b spd 1b tag
		map: [
			8 'location ;; lon lat
			4 'datetime ;; created
			2 'altitude ;; alt
			1 'speed    ;; spd
			1 'tag      ;; tag
		]

		unpack: func [
			"zamienia binarny rekord danych na block! opisujacy punkt"
			record [binary!] "16bajtow"
			/local blk chunk n f] [

			blk: make block! 6
			foreach [chunk n] self/map [
				f: get in self n
				append blk (f (copy/part record chunk))
				record: skip record chunk
			]
			return blk
		]

		location: func [
			"konweruje binarne dane chipsetu MTK na block! wspolrzednych geograficznych"
			lonlat [binary!] "8bajtow" /local lon lat] [

			lon: to-integer reverse copy/part lonlat 4
			lat: to-integer reverse copy/part (skip lonlat 4) 4

			if (lon <> -1) [
				if (lat < 0) [lat: (lat - (to-integer #{80000000})) * -1]
				if (lon < 0) [lon: (lon - (to-integer #{80000000})) * -1]

				lat: (to-integer (lat / 1000000)) + (((lat / 1000000) - (to-integer (lat / 1000000))) * 100 / 60)
				lon: (to-integer (lon / 1000000)) + (((lon / 1000000) - (to-integer (lon / 1000000))) * 100 / 60)
			]

			reduce [
				'lat (round/to lat 0.000001)
				'lon (round/to lon 0.000001)
			]
		]

		datetime: func [
			"konweruje binarne dane chipsetu MTK na date!"
			dtm [binary!] "4bajty" /local date time] [

			dtm: to-integer reverse dtm

			if (dtm <> -1) [
				date: to-date reduce [
					((shift dtm 26) and 63) + 2000 ;; Y
					((shift dtm 22) and 15) ;; M
					((shift dtm 17) and 31) ;; D
				]

				time: to-time reduce [
					((shift dtm 12) and 31) ;; H
					((shift dtm 6) and 63) ;; Mi
					dtm and 63 ;; S
				]

				dtm: to-date rejoin [date "/" time]
			]

			reduce ['created (dtm)] ;; GMT
		]

		altitude: func [
			"konweruje binarne dane chipsetu MTK na wysokosc (m)"
			alt [binary!] "2bajty"] [

			reduce ['alt (to-integer reverse alt)]
		]

		speed: func [
			"konweruje binarne dane chipsetu MTK na predkosc (km)"
			spd [binary!] "1bajt"] [

			reduce ['spd round/to ((to-integer spd) * 1.852) 0.01] ;; mi to km
		]

		tag: func [
			"konweruje binarne dane chipsetu MTK na znacznik (tag)"
			tag [binary!] "1bajt"] [

			reduce ['tag (to-integer tag)]
		]
	]

	decode: func [
		"zamienia binarne dane gps na block! z poszczegolnymi punktami"
		sr [binary!] "zrzut danych GPS"
		/from start [date!] "warunek daty (od)"
		/to stop [date!] "warunek daty (do)"
		/local point points i] [

		i: 0
		forskip sr 16 [
			point: self/chipset/unpack sr
			if (point/lon = -1) [
				printd [i "/" (any [attempt [((index? sr) - 1) / 16] "??"]) "records found"]
				break
			]

			if all [
				any [(none? from) (point/created >= start)]
				any [(none? to)  (point/created <= stop)]
			][
				i: i + 1

				stamp: dt/to-stamp/date point/created
				points: any [(select self/log stamp) (make block! 4000)]
				append/only points point

				;; nowy stamp musi byc dodany do globalnej listy
				if (first points) = point [repend self/log [stamp points]]
			]
		]
	]

	filter: func [
		"zachowuje tylko punkty o wybranych tagach"
		points [block!] "punkty"
		tag [block! integer!] "tag do filtrowania"
		/local blk] [

		tag: to-block tag
		blk: make block! (length? points)

		foreach point points [
			all [
				found? find tag point/tag
				append/only blk point
			]
		]
		blk
	]

	waypoints: func [
		"zwraca block! zawierajacy tylko waypointy"
		points [block!] "punkty"] [

		self/filter points 254
	]

	tracklogs: func [
		"zwraca block! zawierajacy tylko tracklogi w podziale na segmenty"
		points [block!] "punkty"
		/local t blk segments] [

		blk: make block! 500
		segments: make block! 10

		t: self/filter points [99 255]
		foreach point t [
			;; podziel tracklog na segmenty gdy tag = 99
			if all [(not empty? blk) (point/tag = 99)] [
				append/only segments blk
				blk: copy []
			]
			append/only blk point
		]
		if not empty? blk [append/only segments blk]
		segments
	]

	save: func [
		"zapisuje dane za pomoca funkcji save z obiektu dump"
		dump [object!] "obiekt zapisujacy dane do pliku"
		/as name [string! file!] "nazwa pliku (bez rozszerzenia)"
		/local log w t f stamp points] [

		f: get in dump 'save
		if not function? :f [return false]

		log: self/log

		;; zapisywanie do pliku o wybranej nazwie oznacza polaczenie
		;; wszystkich dostepnych danych w jedna liste
		any [
			none? as
			empty? name: to-string name
			attempt [
				blk: make block! 20000
				foreach [stamp points] log [append blk points]
				log: reduce [name blk]
			]
		]

		;; zapis do plikow "stamp"
		foreach [stamp points] log [
			w: self/waypoints points
			t: self/tracklogs points

			attempt [f stamp w t]
			unset [w t]
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
				{<gpx version="1.1"} LF
				{     creator="georss.r http://rowery.olsztyn.pl/rebol"} LF
				{     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"} LF
				{     xmlns="http://www.topografix.com/GPX/1/1"} LF
				{     xsi:schemaLocation="http://www.topografix.com/GPX/1/1 http://www.topografix.com/GPX/1/1/gpx.xsd">} LF
				{  <metadata>} LF
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
							{      <speed>} (spd) {</speed>} LF
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
								{          <speed>} (spd) {</speed>} LF
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
				attempt [t/1/1/encoding] ;; pierwszy trackpoint, pierwsza sekcja
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

csv: context [
	comment {
		waypoint i tracklogi w oddzielnych plikach (takze dla segmentow tracklogu)
		format: "opis" lat lon wysokosc predkosc data/utworzenia
	}

	WPT-SUFFIX: {_w.txt}
	TRK-SUFFIX: {.txt}

	save: func [name [string!] w [block!] t [block!]] [
		if error? try [
			if not empty? w [self/waypoints name w]
			if not empty? t [self/tracklogs name t]
		][
			print ["error!" name "format" WPT-SUFFIX TRK-SUFFIX]
		]
	]

	waypoints: func [name [string!] w [block!] /local wpt i out point] [
		out: make block! 100
		i: 0

		foreach point w [
			i: i + 1
			append out reform [
				rejoin [{"wpt} i {"}]
				point/lat
				point/lon
				point/alt
				point/spd
				dt/normalize (point/created)
				LF
			]
		]

		wpt: to-file join name WPT-SUFFIX
		printd [wpt "/" (length? w) "waypoints"]
		write/direct wpt form out
	]

	tracklogs: func [name [string!] t [block!] /local trk i out point] [

		i: 0

		foreach segment t [
			i: i + 1
			out: make block! 1000

			foreach point segment [
				append out reform [
					point/lat
					point/lon
					point/alt
					point/spd
					dt/normalize (point/created)
					LF
				]
			]

			trk: to-file rejoin [name {_} i TRK-SUFFIX]
			printd [trk "/" (length? segment) "tracklog-points"]
			write/direct trk form out
		]
	]
]

printd: func [message [block! string!]] [
	any [
		system/options/quiet
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

getopts: func [cmds [string!] cases [block!]
	/default case [block!]
	/local args cmd opts opt rcs] [

	args: any [system/script/args ""]
	args: parse args none

	cmds: parse cmds ":"
	rcs: make block! length? cmds

   forall cmds [
		cmd: first cmds
		if found? opts: find args (join "--" cmd)  [
			set [opt optargs] opts
			;; parametr opcji nie moze byc taki sam jak opcja
			any [
				none? optargs
				(length? optargs) <= 2
				not found? find head cmds (skip optargs 2)
				optargs: none
			]
			if (opt = (join "--" cmd)) [(append rcs cmd) (switch cmd cases)]
		]
	]

	any [
		if all [empty? rcs function? case] [do case]
		true
	]
]

;### main ###

system/options/quiet: false
net-watch: false
if all [net-watch none? system/script/args] [system/script/args: "--verbose"]

output: make block! 3
filename: none

printd [
	system/script/header/title LF 
	system/script/header/purpose LF
]

getopts "file::gpx:ozi:kml:csv:help:quiet:verbose" [
	"file" [filename: optargs]
	"gpx" [append output gpx]
	"ozi" [append output ozi]
	"csv"	[append output csv]
	"kml"	[append output kml]
	"help" [
		print [
			system/script/header/file 
			"--file {filename} --gpx --ozi --kml --csv --help --quiet --verbose"
		]
		hold quit
	]
	"quiet" [system/options/quiet: true]
	"verbose" [
		net-watch: true
		echo to-file rejoin ["log_" (dt/to-stamp now) ".txt"]
	]
]

net-utils/net-log ["main/getopts" output filename]

if empty? output [append output gpx]
if none? filename [
	args: parse any [system/script/args ""] none
	if all [(not empty? args) (not found? find first args "--")] [filename: first args]
	if all [view? none? filename] [filename: request-file/title/filter/only "Select SR file" "Load" "*.sr"]
]

either all [
	not none? filename
	attempt [exists? file: to-file filename]
][
	printd ["reading file" mold form second (split-path file) "..."]
	sr/decode (read/binary file)
	foreach format output [sr/save format]
	printd "done."
][
	print ["memory dump file not found!" form any [filename ""]]
	print [system/script/header/file "--help"]
]

hold quit

