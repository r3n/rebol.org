REBOL [
	Title: {Indexing}
	Purpose: {Indexing of values.}
	File: %indexing.r
	Date: 4-Mar-2013
	Version: 1.0.0
	Author: "Brett Handley"
	Web: http://www.codeconscious.com
	Library: [
		level: 'intermediate
		platform: 'all
		type: [tool function]
		domain: [utility]
		tested-under: [
			View 2.7.8.3.1 on [Win7] {Basic tests.} "Brett"
		]
		support: none
		license: 'apache-v2.0
		see-also: none
	]
	history: [
		1.0.0 [4-Mar-2013 "Initial version." "Brett Handley"]
	]
	comment: {Not guaranteed}
]


; Originally series-to-index was written 2-Sep-2002 and named build-index. Now rewritten to use index-writer.
series-to-index: func [
	"Index the elements of a series. Returns hash where pairs are keys and block of index positions where key occurs."
	series [series!]
	/local index result
][
	index: index-writer result: make hash! divide length? series 15
	repeat i length? series [index/append pick series i i]
	result
]


index-to-series: func [
	{Creates block from hash index as returned from series-to-index (i.e. positions must be integer!).}
	index [series!] {Pairs of keys and key occurrence index positions e.g [key1 [4 6 8 ...] key2 [...] ...}
	/into {Collects results into result.} result [series!]
][
	if not into [result: make block! 100]
	foreach [key positions] index [
		foreach position positions [
			if position > length? result [append result array (position - length? result)]
			poke result position :key
		]
	]
	result
]

;
; This form of this interface is a bit of an experiment.
;
; You should probably unset the index-writer function you create when you are finished with it.
;

index-writer: func [
	{Returns a function that maintains/queries an index. Use a hash! for efficiency with larger data sets.}
	index [any-block!] {Pairs of keys and unique key location identifiers e.g [key1 [4 6 8 ...] key2 [...] ...}
][
	use [-index-][
		-index-: index
		make function! [
			{This function maintains/queries an index. Use 'value to return index.}
			key
			/append {Adds a new key location combination. (locations are kept unique)} app-key-location
			/remove {Removes a location for a key.} rem-key-location
			/delete {Removes key and location list pair.}
			/get {Returns locations for key.}
			/exists {Returns true if key exists.}
			/located {Returns true if location is found for key.} located-key-location
			/partial {Partial match of supplied key against index keys where supplied key is pattern. Returns the index keys that match.}
			/pattern {Tries to find an index key that used as a pattern will match against the supplied key. Returns the longest index key that matches.}
			/local pos pos2
		][
			pos: find/skip/only -index- :key 2
			if append [
				if not found? pos [insert pos: tail -index- reduce [:key make block! 5]]
				if not found? pos2: find/only second pos :app-key-location [insert/only tail second pos :app-key-location]
				return
			]
			if remove [
				if found? pos [
					if found? pos2: find/only second pos :rem-key-location [system/words/remove pos2]
					if empty? second pos [system/words/remove/part pos 2] ; Remove key with no locations.
				]
				return
			]
			if located [
				if found? pos [
					found? pos2: find/only second pos :rem-key-location
				]
			]
			if exists [return found? pos]
			if get [return if found? pos [second pos]]
			if delete [
				if found? pos [system/words/remove/part pos 2]
				return
			]
			if key = 'spec? [return -index-]
			if partial [
				if not series? :key [make error! {/partial requires key to be series! type}]
				use [candidates][
					candidates: copy []
					foreach [iky locations] -index- [if find/match :iky :key [system/words/append/only candidates :iky]]
					sort candidates
					return candidates
				]
			]
			if pattern [
				if not series? :key [make error! {/pattern requires key to be series! type}]
				key: copy/deep :key
				while [not found? pos][
					system/words/remove back tail key
					if empty? key [key: none break]
					pos: find/skip/only -index- :key 2
				]
				return key
			]
		]
	]
]