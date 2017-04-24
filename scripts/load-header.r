rebol [
	Title: "Load-header"
	File: %load-header.r
	Date: 28/11/03
        Version: 0.0.1
	Author: "Romano Paolo Tenca"
	Purpose: "Load a Rebol header without evaluating it"
	Library: library: [level: 'intermediate platform: 'all type: [] domain: [] tested-under: none support: none license: none see-also: none ]
]

load-header: func [
	"Load and construct a Rebol header object"
	str [file! url! string!]
][
	if str: script? str [
		attempt [
			construct/with first load/next find find str "rebol" "[" system/standard/script
		]
	]
]
