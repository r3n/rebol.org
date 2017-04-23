REBOL [
	Title: "Google Chart API"
	Version: 0.1.1
	Author: "Christopher Ross-Gill"
	Home: http://www.ross-gill.com/
	Date: 9-Aug-2008
	Exports: [chart]
	File: %charts-api.r
	Purpose: {Generates a URL to access the Google Charts API}
	Library: [
		Level: 'beginner
		Platform: 'all
		Type: [function module tool dialect]
		Domain: [dialects http ldc web]
		License: 'cc-by-sa
	]
]

chart: use [
	root types ; settings
	map uses envelop ; core functions
	form-simple form-color form-list form-lists form-data ; type helpers
][
	root: http://chart.apis.google.com/chart?

	types: [
		line "lc" line/xy "lxy" sparkline "ls"
		bar "bvs" bar/horizontal "bhs"
		pie "p3" pie/flat "p"
		map "t"
	]

	uses: func [proto [block!] spec [block!]][
		proto: context proto
		func [args [block! object!]] compose/only [
			args: make (proto) args
			do bind (spec) args
		]
	]

	map: func [series [any-block!] action [any-function!]][
		series: copy/deep series
		while [not tail? series][
			series: change/part series action series/1 1
		]
		head series
	]

	envelop: func [val [any-type!]][either any-block? val [val][reduce [val]]]

	form-simple: use [to-61 codes][
		codes: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"

		to-61: func [val [number! none!]][
			if none? val [return "_"]
			val: max min 1 val 0
			pick codes 1 + round 61 * val
		]

		func [[catch] data [block!] separator [any-type!]][
			rejoin map data :to-61
		]
	]

	form-color: func [color [tuple!] /local out][
		out: copy ""
		repeat val length? color [
			append out back back tail to-hex color/:val
		]
		lowercase out
	]

	form-list: func [block [block!] separator [char! string!]][
		remove rejoin map block func [val][
			join separator switch/default type?/word val [
				decimal! [round/to val 0.1]
				tuple! [form-color val]
				none! [-1]
			][
				switch/default val [
					color ["bg"] chart ["c"] all ["a"]
					solid ["s"] gradient ["lg"] stripes ["ls"]
				][val]
			]
		]
	]

	form-lists: func [
		block [block!] separator [char! string!] encode [function!]
		/with subseparator [char! string!]
	][
		remove rejoin map block func [block][
			join separator encode block subseparator
		]
	]

	form-data: func [data [block!] /local out val /text /flat /simple /label][
		unless parse data: copy/deep data [some block!][
			data: reduce [data]
		]

		case [
			simple [join "s:" form-lists data "," :form-simple]
			flat [form-lists/with data "," :form-list ""]
			label [form-list data/1 "|"]
			text [join "t:" form-lists/with data "|" :form-list ","]
			true [form-lists/with data "|" :form-list ","]
		]
	]

	uses [
		verbose: false debug: func [val][either verbose [probe val][val]]
		out*: ""
		emit: func ['arg val][repend out* ["&" arg "=" form val]]
		title: none
		size: 320x240
		type: 'line
		simple: false
		data: []
		color: colors: labels: area: bars: none
	][
		clear out*
		emit cht any [select types type form type]
		emit chs size
		emit chd either simple [form-data/simple data][form-data/text data]
		case/all [
			title [emit chtt title]
			any [color color: colors][emit chco form-data reduce envelop color]
			labels [emit chl form-data/label envelop labels]
			area [emit chf form-data area]
			bars [emit chbh form-data bars]
		]
		join root debug next out*
	]
]