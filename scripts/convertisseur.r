REBOL[    
	Title: "Convertisseur"
    Date:  10-Jun-2004
    Version:  1.0.0
    File: %convertisseur.r
    Author: "Philippe Le Goff "
    Purpose: "convert Francs vs Euros"
    Email: %lp--legoff--free--fr
    note: {- v. 1.0.0 : convert Francs vs Euros  }
    library: [
        level: 'beginner 
        platform: all 
        type: 'tool 
        domain: [user-interface] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]

]
; convertisseur Euros - francs
reduc: func[ num [integer!] str  /local temp ][
	temp: parse to-string str {.}
	return to-string rejoin [ temp/1 {.} (copy/part head temp/2 num ) ]
]
fen:  [
	style texto text 60 font-size 14 font-name "Courrier" font-color white 
	style fieldo field 80 font-size 12 font-name "Courrier" font-color blue 
	tabs [10 60 100]
	backdrop  effect [ gradient 0x1 10.10.0 blue  ]
	across
	texto "Francs : " 
	tab
    field-francs: fieldo "0" [ 
	    field-euros/text: reduc 4 ( (to-decimal field-francs/text) / 6.55957 ) 
	    show field-euros 
    ]
    return
	across
	texto "    Euros :  "
	tab
    field-euros: fieldo "0"  [ 
    field-francs/text: reduc 4 ((to-decimal field-euros/text) * 6.55957  )
    show field-francs
    ]
 	return
]
view/new/title center-face  layout fen "Convertisseur Francs-Euros"
do-events
