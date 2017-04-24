REBOL [
	title: "PhotoTrackr DPL converter"
	purpose: "Converts memory dumps of the PhotoTrackr GPS (DPL) logger to OziExplorer/GPX formats"
	author: "pijoter"
	date: 2009-07-15/14:05:52+2:00
	file: %phototrackr-converter.r
	License: "GNU General Public License (Version II)"
    Library: [
        replaced-by: %dpl700-converter.r
        level: 'intermediate
        platform: 'all
        type: [tool]
		domain: [file-handling]
		tested-under: [
			view 1.3.1  on [Linux]
			view 2.7.6  on [Linux WinXP]
        ]
		support: none
		license: 'GPL
    ]
]

sr: context [
	d: make hash! 60

	unpack: func [record [binary!] /local blk b] [
		blk: make block! 6

		; MTK CHIPSET: lon lat datetime alt spd tag
		foreach b [4 4 4 2 1 1] [
			append blk reverse copy/part record b
			record: skip record b
		]
		return blk
	]

	datetime: func [dtime [binary! integer!] /local d t] [
		if binary? dtime [dtime: to-integer dtime]
		if (dtime = -1) [return now]

		d: to-date reduce [
			((shift dtime 26) and 63) + 2000 ;; Y
			((shift dtime 22) and 15) ;; M
			((shift dtime 17) and 31) ;; D
		]

		t: to-time reduce [
			((shift dtime 12) and 31) ;; H
			((shift dtime 6) and 63) ;; Mi
			dtime and 63 ;; S
		]

		to-date rejoin [d "/" t]
	]

	location: func [lat [binary! integer!] lon [binary! integer!]] [
		if binary? lat [lat: to-integer lat]
		if binary? lon [lon: to-integer lon]

		if (lat < 0) [lat: (lat - (to-integer #{80000000})) * -1]
		if (lon < 0) [lon: (lon - (to-integer #{80000000})) * -1]

		return reduce [
			(to-integer (lat / 1000000)) + (((lat / 1000000) - (to-integer (lat / 1000000))) * 100 / 60)
			(to-integer (lon / 1000000)) + (((lon / 1000000) - (to-integer (lon / 1000000))) * 100 / 60)
		]
	]

	filter: func [b [block!] tag [block! integer!]] [
		tag: to-block tag
		remove-each point (copy b) [not found? find tag point/tag]
	]

	waypoints: func [b [block!]] [self/filter b 254]

	tracklogs: func [b [block!] /local t blk segments] [
		blk: make block! 500
		segments: make block! 10

		t: self/filter b [99 255]
		foreach point t [
			if all [(not empty? blk) (point/tag = 99)] [
				append/only segments blk
				blk: copy []
			]
			append/only blk point
		]
		if not empty? blk [append/only segments blk]
		return segments
	]

	decode: func [sr [binary!] config [object!]
		/local lat lon dtm alt spd tag date stamp points i] [
		i: 0
		forskip sr 16 [
			set [lon lat dtm alt spd tag] (self/unpack sr)
			if (lon = #{FFFFFFFF}) [
				print [i "/" (any [attempt [((index? sr) - 1) / 16] "??"]) "records"]
				print ["from" (first self/d) "to" pick self/d ((length? self/d) - 1)]
				break
			]

			date: self/datetime dtm
			if all [
				any [(none? config/start) (date >= config/start)]
				any [(none? config/stop)  (date <= config/stop) ]
			][
				i: i + 1

				stamp: dt/to-stamp/date date
				points: any [
					select self/d stamp
					make block! 10000
				]

				set [lat lon] (self/location lat lon)
				repend/only points [
					'lat lat
					'lon lon
					'alt (to-integer alt)
					'spd (to-integer spd) * 1.852
					'tag (to-integer tag)
					'created date
				]

				if ((length? points) = 1) [repend self/d [stamp points]]
			]
		]
	]

	save: func [dump [object!] /local w t f stamp log] [
		;; zapis do plikow
		f: get in dump 'save

		foreach [stamp log] self/d [
			w: waypoints log
			t: tracklogs log

			if function? :f [attempt [f stamp w t]]
		]
		unset [d w t f]
		recycle
	]
]

dt: context [
	to-epoch: func [date [date!] /local res] [
		either res: attempt [to integer! difference date 1970-01-01/00:00:00]
			[res]
			[date - 1970-01-01/00:00:00 * 86400.0]
	]

	from-epoch: func [val [integer!] /zone tz /local date time] [
		val: to-time val
		date: 1970-01-01 + round/down val / 24:00:00
		time: val // 24:00:00
		(to-date rejoin [date "/" time]) + (any [(if value? zone [tz]) (00:00)])
	]

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

	to-stamp: func [dtm [date!] /date] [
		dtm: any [
			if date [self/to-human/date dtm]
			self/to-human dtm
		]
		remove-each ch dtm [found? find "-/:" ch]
	]

	to-gpx-date: func [date [date!]] [
		append replace (self/to-human date) "/" "T" "Z"
	]
]

sr-gpx: context [
	WPT-SUFFIX: {.gpx}
	TRK-SUFFIX: {.gpx}

	out: none

	save: func [name [string!] w [block!] t [block!] /local created gpx] [
		self/out: make block! 1000

		created: any [
			attempt [t/1/1/created] ;; pierwszy punkt, pierwszy segment
			attempt [w/1/created] ;; pierwszy waypoint
			now
		]

		attempt [
			if not empty? w [waypoints name w]
			if not empty? t [tracklogs name t]
		]

		if not empty? out [
			insert head out rejoin [
				{<?xml version="1.0" ?>} LF
				{<gpx version="1.0"} LF
				{     creator="sr-gpx.r http://rowery.olsztyn.pl/rebol"} LF
				{     xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"} LF
				{     xmlns="http://www.topografix.com/GPX/1/0"} LF
				{     xsi:schemaLocation="http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd">} LF
				{  <time>} dt/to-gpx-date (created) {</time>} LF
			]
			repend out [{</gpx>} LF]

			gpx: to-file join name TRK-SUFFIX

			print gpx
			write/direct/binary gpx form self/out
		]
	]

	waypoints: func [name [string!] w [block!] /local i point] [
		i: 0

		foreach point w [
			i: i + 1

			append out rejoin [
				{  <wpt lat="} (round/to point/lat 0.000001) {" lon="} (round/to point/lon 0.000001) {">} LF
				{    <ele>} (round/to point/alt 0.01) {</ele>} LF
				{    <name>} (dt/to-stamp point/created) {</name>} LF
				{    <sym>Flag, Blue</sym>} LF
				{    <desc>speed } (round/to point/spd 0.01) { km/h</desc>} LF
				{    <time>} (dt/to-gpx-date point/created) {</time>} LF
				{  </wpt>} LF
			]
		]
	]

	tracklogs: func [name [string!] t [block!] /local i point created track-segment] [
		created: any [(attempt [t/1/1/created]) now]
		append out rejoin [
			{  <trk>} LF
			{    <name>} dt/to-stamp/date created {</name>} LF
			{    <number>} 1 {</number>} LF
		]

		i: 0
		foreach segment t [
			i: i + 1
			append out rejoin [{    <trkseg>} LF]

			foreach point segment [
				append out rejoin [
					{      <trkpt lat="} (round/to point/lat 0.000001) {" lon="} (round/to point/lon 0.000001) {">} LF
					{        <ele>} (round/to point/alt 0.01) {</ele>} LF
					{        <time>} (dt/to-gpx-date point/created) {</time>} LF
					{        <speed>} (round/to point/spd 0.01) {</speed>} LF
					{      </trkpt>} LF
				]
			]
			append out rejoin [ {    </trkseg>} LF ]
		]

		append out rejoin [{  </trk>} LF]
	]
]

sr-ozi: context [
	WPT-SUFFIX: {.wpt}
	TRK-SUFFIX: {.plt}

	save: func [name [string!] w [block!] t [block!]] [
		if error? try [
			if not empty? w [waypoints name w]
			if not empty? t [tracklogs name t]
		][
			print ["error!" name "format" WPT-SUFFIX TRK-SUFFIX]
		]
	]

	to-ozi-alt: func [alt [number!]] [alt * 3.28083931316019]
	to-ozi-date: func [date [date!]] [
		date: dt/to-epoch date
		(date / 86400) + 25569.0
	]

	waypoints: func [name [string!] w [block!] /local wpt i out point] [
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
				dt/to-stamp point/created ","
				(round/to point/lat 0.000001) ","
				(round/to point/lon 0.000001) ","
				(to-ozi-date point/created) ","
				"0,0,3,0,65535,"
				reform [(dt/to-stamp point/created) "speed" (round/to point/spd 0.01) "km/h"] ","
				"0,0,0,"
				to-ozi-alt (round/to point/alt 0.01) ","
				"8.25,0,17"
				CRLF
			]
		]

		wpt: to-file join name WPT-SUFFIX

		print wpt
		write/direct/binary wpt form out
	]

	tracklogs: func [name [string!] t [block!] /local plt i out track-segment] [
		out: make block! 1000
		i: 0

		foreach segment t [
			foreach point segment [
				i: i + 1
				track-segment: pick [1 0] (point = first segment)

				append out rejoin [
					(round/to point/lat 0.000001) ","
					(round/to point/lon 0.000001) ","
					track-segment ","
					to-ozi-alt (round/to point/alt 0.01) ","
					to-ozi-date (point/created) ","
					dt/to-human/date (point/created) ","
					dt/to-human/time (point/created) CRLF
					;; (round/to point/spd 0.01) CRLF
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

		print plt
		write/direct/binary plt form out
	]
]

use [data config] [
	data: read/binary to-file first any [request-file halt]

	config: make object! [
		start: none	;; date from
		stop: none ;; date to
	]

	sr/decode data config
	sr/save sr-gpx ;; -> gpx 1.0
	;; sr/save sr-ozi ;; -> oziexplorer
]
halt
