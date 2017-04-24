REBOL [
	Title: "Mini-MetaDB"
	Author: "Christopher Ross-Gill"
	Version: 1.0.0
	Date: 16-Mar-2010
	File: %metadb.r
	Purpose: "Simple associative database for managing metadata"
	Comment: "Extracted from QuarterMaster project"
	Usage: [
		; change value 'root before use
		write meta/Subject/key "Value"
		read meta/Subject/key
		read meta/Subject
		write meta/(probe "Subject")/key "Value"
	]
	Library: [
		level: 'intermediate
		platform: 'all
		type: [module database]
		domain: [database db]
		tested-under: [view 2.7.6.2.4]
		support: none
		license: 'cc-by-sa
	]
]

meta: use [root with url-encode add-protocol get-port-flags][

root: %/Path/To/Files/ ; folder where values are to be stored

with: func [object [any-word! object! port!] block [any-block!] /only][
	block: bind block object
	either only [block] :block
]

url-encode: use [ch sp encode][
	ch: #[bitset! 64#{AAAAAIJ0/wP+//8H/v//RwAAAAAAAAAAAAAAAAAAAAA=}]
	encode: func [text][change/part text join "%" enbase/base to-string text/1 16 1]

	func [text [any-string!] /wiki][
		sp: either wiki [#"_"][#"+"]

		parse/all copy text [
			copy text any [
				  text: some ch | #" " (change text sp)
				| #"_" (all [wiki encode text]) | skip (encode text)
			]
		]
		text
	]
]

add-protocol: func ['name id handler /with block][
	unless in system/schemes name [
		system/schemes: make system/schemes compose [
			(to-set-word name) #[none]
		]
	]

	set in system/schemes name make system/standard/port compose [
		scheme: name
		port-id: (id)
		handler: (handler)
		passive: #[none]
		cache-size: 5
		proxy: make object! [host: port-id: user: pass: type: bypass: #[none]]
		(block)
	]
]

get-port-flags: use [codes][
	codes: [read 1 write 2 append 4 new 8 binary 32 lines 64 direct 524288]

	func [port words][
		remove-each word copy words [
			word: select codes word
			word <> (port/state/flags and word)
		]
	]
]

meta: use [sw*][
	sw*: system/words

	add-protocol meta 0 context [
		port-flags: system/standard/port-flags/pass-thru

		init: func [port url /local spec][
			unless all [
				url? url
				spec: find/tail url meta
				spec: parse/all spec "/"
				parse spec with/only port [
					set host string!
					(target: join lowercase url-encode/wiki host %.r)
					set path opt string!
					(path: all [path to-word path])
				]
			][
				raise ["Metadata URL <" url "> is invalid."]
			]
		]

		open: func [port][
			with port [
				state/flags: state/flags or port-flags
				locals: any [
					attempt [load root/:target]
					sw*/copy []
				]
			]
		]

		copy: func [port][
			with port [either path [sw*/select locals path][locals]]
		]

		insert: func [port data][
			with port [
				remove-each [key val] locals [key = path]
				if all [path data][repend locals [path data]]
				new-line/all/skip locals true 2
			]
		]

		close: func [port][
			if [write] = get-port-flags port [write][
				with port [save/all root/:target locals]
			]
		]
	]

	meta://
]

]