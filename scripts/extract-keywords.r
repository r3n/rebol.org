REBOL [
	Author: "Ashley G Truter"
	File: %extract-keywords.r
	Date: 28-Jun-2009
	Title: "Extract REBOL keywords"
	Purpose: {
		Generic function to extract and format REBOL 'keywords', typically to create a syntax highlight file
		for an editor that doesn't support REBOL.
	}
	Usage: {
		write/lines %smultron.txt extract-keywords/html "^-^-<string>" "</string>"
	}
	library: [
		level: 'intermediate
		platform: 'all
		type: [tool function]
		domain: [editor]
		tested-under: [view 2.7.6 [WinXP MacOSX]]
		support: none
		license: 'public-domain
		see-also: none
	]
]

extract-keywords: make function! [
	"Extracts REBOL function names into a list of keywords suitable for an editor."
	prefix [string!] "Text prior to each keyword"
	suffix [string!] "Text following each keyword"
	/html "Encode embedded HTML characters"
	/local words vals
] [
	words: copy []
	vals: second system/words
	foreach word first system/words [
		if any-function? first vals [
			if html [
				word: form word
				replace/all word "<" "&lt;"
				replace/all word ">" "&gt;"
			]
			insert tail words rejoin [prefix word suffix]
		]
		vals: next vals
	]
	sort words
]