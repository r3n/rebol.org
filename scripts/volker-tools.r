REBOL[
	Title: "empty. debugging upload"
	File: %volker-tools.r
	Date: 15-Jul-2004
	Purpose: "  Hopefully growing tool-list  "
	Library: [
		level: intermediate 
		platform: 'all 
		type: demo 
		domain: extension 
		tested-under: none 
		support: none 
		license: none 
		see-also: none
	]
]

???: func ["probe value and set word" 'word value] [ ; by Volker
    print [mold :word mold :value]
    set :word :value
]
comment{
??? a: 123
sets a and prints: "a: 123"
related: ? ?? probe
}
