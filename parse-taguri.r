REBOL [
	Title: "Tag URI Parser"
	Date: 29-Jan-2007
	Author: "Christopher Ross-Gill"
	Home: http://www.ross-gill.com/
	File: %parse-taguri.r
	Purpose: "Converts a Tag URI to Metadata"
	Example: "probe read tag:rebol.org,2007:TagURI"
	Library: [
		level: 'intermediate
		platform: 'all
		type: 'protocol
		domain: [markup protocol scheme web xml]
		tested-under: [core 2.6.2.2.4 OSX]
		license: 'cc-by
		support: none
	]
]

context [
	chars-u: charset [#"a" - #"z" #"A" - #"Z" #"0" - #"9" "-_."]
	chars-n: charset "0123456789"
	deplus: func [str][replace/all str #"+" #" "]

	parse-uri: func [uri /local info][
		info: context [
			domain: date: name: none

			either parse/all uri [
				"tag:"
				copy domain some chars-u #","
				copy date [4 chars-n opt [#"-" 2 chars-n opt [#"-" 2 chars-n]]] #":"
				copy name to end
			][
				date: to-date head change copy "2000-01-01" date
				name: dehex deplus name
			][
				domain: date: name: none
			]
		]
		if info/domain [info]
	]

	net-utils/net-install tag context [
		port-flags: system/standard/port-flags/pass-thru

		init: func [[catch] port spec][
			unless all [
				url? spec
				port/locals: parse-uri spec
			][make error! reform ["Spec Error:" spec]]
		]

		open: func [port][port/state/flags: port/state/flags or port-flags]

		copy: func [port][port/locals]

		close: func [port][port/locals: none]
	] 0
]