REBOL [
	Title: "Numbers " 
    File: %numbers.r
    Author: "Lami Gabriele"
    Email: koteth@gmail.com
	Date:    10-July-2009
	Purpose: "Number structure visual analyzer"
]
ena: 121
positions: []
dimPal: 3 

unitar: func [ ele enne ][ either (( (ele // enne) == 1 ) or (( ele // enne) == (enne - 1)))[ 1  ] ["-"] ]

evaluateUni: func [ en ] [
	for j 1 en 1[ st: copy "" 
		for i 1 en 1[ 
			append st unitar i * j en 
			sr: square-root en   
			if ( unitar i * j en ) == 1  [ append positions ( as-pair i j  ) * 350 / en + 23x23 ]
		]
	]
 	positions
]
evaluateUni ena

refre: does[ 	
	positions: copy []
	evaluateUni ena
	pis: copy []
	posi: copy positions
	foreach p posi[ insert tail pis  reduce[ 'fill-pen 160.209.215.100 'circle p dimPal ]  ]
	out: form ( length? positions ) / 2 == ( ena - 1 )
	insert tail pis reduce [  'text 230x5 join "numero primo: "   out ]
	scrn/effect/draw: copy []
	append scrn/effect/draw pis
	show scrn	
]

refreNoEval: does[ 	
	pis: copy []
	posi: copy positions
	foreach p posi[ insert tail pis  reduce[ 'fill-pen 160.209.215.100 'circle p dimPal ]  ]
	out: form ( length? positions ) / 2 == ( ena - 1 )
	insert tail pis reduce [  'text 230x5 join "prime number: "   out ]
	scrn/effect/draw: copy []
	append scrn/effect/draw pis
	show scrn	
]
lay: layout [  

	scrn: box 400x400 black effect [
		draw [ text "unit" ]
		rotate 50
		gradmul 180.180.210 180.60.255
	]
	slider 200x16 ena / 300 [
 		ena: to-integer value * 300
		inpNum/data: form ena
		inpNum/text: form ena
		show inpNum
		refre
	]
	inpNum: field form ena [
		print to-integer inpNum/text
	 	ena: to-integer inpNum/text    	
	]
	at 330x460
	btn "Change"  [ 
		refre 
	]	
	slider 100x15 dimPal / 10 [
		dimPal: to-integer  value    * 10 
		refreNoEval 
	]
]

view lay 