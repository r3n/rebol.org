REBOL [
	file: %button.r
	date: 18-Feb-2004
	title: "VID Button Set"
	author: "Ammon Johnson"
	email: ammon@addept.ws
	purpose: "A simple VID Button set.  Includes Ok, Cancel, Toggle and Choice"
	library: [
		level: 'intermediate
		platform: 'all
		type: ['tool 'demo]
		domain: ['gui 'ui 'user-interface 'vid]
		tested-under: 'winxp
		support: {email me with questions}
		license: none
		comment: {Free to use as-is, acknowledgement is appreciated.
				  Please inform me of any enhancements you make.
				  Provided with NO WARRANTY.}
	]
]

stylize/master [
	button: button middle center with [
		size: 120x25
		font: make font [color: 220.220.220 colors: [220.220.220 240.240.240]]
		effect: [colorize 125.0.150 extend]
		edge: none
		image: do decompress #{
789CA5944B6EDC300C86F73CC514BD806CEBB99444E912451659044150645FA0
C8DDCB87672C61EA4C8BF05BD8FAA57F486928BF3FFF7CB9BCBD3FBFBE7CBBFC
48BFD6EDF2FD37982F0418CFAC85B14D40664D8CCE4E0E51740D1427840151EC
C218276824A64AB4C0803E46AA674C143432533A53ED018C039DD60CA34D7FEE
1E1807BA74B71506ED67803E265B65F01F00CDB0DB9069DB63D40563B6968574
82CCEACAEBFFACD9FA63469BBAA06F8FB9DF5A8F0CE8E38C299BBCF77200E360
E4FEFC3B0AC34E60DA964C4F3679EF2701E360B235E6CC3699F518D4B548EC45
9E4562C074416D2BA3D7E3CCB53789B8AE4D229721237366CB9E3156D89B4473
7AC66E4219905BADF1B72FC917E23FCCF0C1DFBCDECBEABC8D36BA54648BE8C0
3A121CE16D403AAEB8D808DBB21962B129DADE5DA1C12D1D2DEDCD95A906DB5A
3DBE7822BA05D16F53B5CE62F676AACB3992DC28390F2485490A98C1C7498AB4
284D27E01249793A16477FA52F439D2455926EF7FB90702EBE5E8D47F18533CE
C5531161DA8F37547C8E66BD295BA0668286610D9ECE1783753597D6B8DF4D4A
7C9DD392B1FAEB2508A81D88D4D61D3E9EFE0043447DE6BE060000
}
		font: make font [colors: [200.200.200 240.240.240] shadow: none]
		insert tail init [color: none]
	]
	ok-button: button effect reduce ['extend 'colorize green] #"^M" font [colors: [0.0.0 80.80.80]]
	esc-button: ok-button effect reduce ['extend 'colorize red] #"^["
	toggle: toggle center with [
		image: get in (get-style 'button) 'image
		font: make font [color: 255.255.255 colors: [0.0.0 100.100.100] shadow: false]
		effect: [extend]
		edge: none
		append init [color: none]
	]
	choice: choice with [
		image: get in (get-style 'button) 'image
		effect: reduce ['colorize maroon 'extend]
		edge: none
		append init [color: none]
	]
]

;comment {;Uncomment for example
view layout [
	button "Button" 150
	ok-button "Ok Button" 150
	esc-button "Cancel Button" 150
	toggle "Toggle Up"  "Toggle Down"
	choice "One" "Two" "Three"
]
;}