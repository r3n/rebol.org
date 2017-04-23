REBOL[
	Title: "Wall Street"
	File: %wall-street.r
	Date: 5-6-2007
	Purpose: "Small nice demo"
	Verison: 0.2.0
	Library: [
		level: 'intermediate
		platform: 'all
		type: [demo]
		domain: [html visualization web vid]
		tested-under: none
		support: "rebolek[at]gmail[dot]com"
		license: 'MIT
		see-also: none
	]
]

url: http://finance.google.com/finance

extend: func [string length /with znak][
	if (length? string) > length [return copy/part string length]
	join string rejoin array/initial length - (length? string) either with [znak][" "]
]

de-url: func [text][
	foreach [co cim]["&amp;" "&" "&quot;" {"}][replace/all text co cim]
	text
]

upd-func: func [total bytes][
	obrazovka/txt: rejoin [bytes " bytes read."]
	show obrazovka
	true
]

get-data: does [
	rule=: [
		thru "finance?q=" copy symbol to {"}
		thru {title="} copy title to {"}
		thru {<td width=} thru {<span} thru {>} copy price to "<"
		thru {<td width=} thru {<span} thru {>} copy change1 to "<"
		thru {<td width=} thru {<span} thru {>} copy change2 to "<"
		thru {<td width=} thru {>} copy mktcap to "<"
	]
	rule=act: [
		append result rejoin [ 
		"|"	extend/with de-url title 25 "."
		"|"	extend symbol 4
		"|"	extend price 7
		"|" extend rejoin [change1 " " change2] 15
		"|" extend trim/all mktcap 8
		"|" newline
		]
	]
	;page: read url
	page: read-thru/update/progress url :upd-func
	result: rejoin [
		"^/GOOGLE Finance - recent quotes^/"
		rejoin array/initial 65 "-"
		"^/|Company name             |Symb|Price  |Change         |Mkt cap |^/"
		rejoin array/initial 65 "-"
		newline
	]
	
	parse page [thru "Recent quotes" some [rule= (do rule=act)] to end]
	append result rejoin array/initial 65 "-"
	append result "^/^/^/^/^/^/^/^/^/^/^/^/^/"
	append result rejoin array/initial 30 "-"
	append result "REBOL"
	append result rejoin array/initial 30 "-"
	result
]

;GUI

fuj: stylize [
	cara: face with [
		size: 100x3
		color: green
		effect: [merge alphamul 127]
		init: []
		rate: 0
		feel: make feel [
			engage: func [face action event][
				switch action [
					time [
						face/size/x: face/parent-face/size/x
						face/offset/y: face/offset/y - 1
						if face/offset/y < 0 [face/offset/y: face/parent-face/size/y]
					]
				]
				show face
			]
		]
	]
	bordel: face with [
		color: 0.50.0
		txt: copy ""
		font: make font [
			name: "courier"
			size: 13
			align: 'left
			style: 'bold
			color: 127.255.127
		]
		para: make para [wrap?: no]
		position: 0
		rate: 0
		feel: make feel [
			engage: func [face action event][
				switch action [
					down [
						face/position: 0
						face/txt: copy "^/Preparing to download data...^/"
						show face
						face/txt: get-data
					]
					time [
						face/text: copy/part face/txt face/position
						face/position: face/position + 1
						if face/position > length? face/txt [face/position: 0]
						append face/text to char! 32 + random 96
						show face
						wait .01
						remove back tail face/text
						show face
					]
				]
			]
		]
		init: []
		multi: make multi [
			text: func [face blk][
				if pick blk 1 [
					face/txt: pick blk 1
				]
			]
		]
	]
]

siz: size-text make face [size: 10000x10 text: rejoin array/initial 65 "-" font: make font [name: "courier" size: 13 style: 'bold]]

view layout [
	styles fuj
	origin 0
	space 0
	backcolor 0.0.0
	obrazovka: bordel (siz * 1x26 + 3x3)
decompress #{
789CC592B10AC2400C86779F229B4AD17750280E2A48159CA3097AF47A91DC69
A9F4E1B5DD3A58AA45FD9723CBF77F21174DFA251A94D02FE52B42D42CEA4AD8
B33D4AC610044AD8CF562BD8EE9238DE3D276524D61F387C9272D02CFBFF2D72
3521B0834301493C17CB298CAAC75BBCC15CF92E379F16E316028071FE6294A9
822C44491C2CF898CAD04360CD8C43DBEAD07F8B3AA2E654771962AC5C964216
D6A86774DD086F3B7CE19A1B65EF2193ABAFBF3749EEAC200161C0E9771C1E5B
65C06620040000
}
	cara
]