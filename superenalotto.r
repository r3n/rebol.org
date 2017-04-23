REBOL [	
	Title: "Superenalotto extractor"
	Version: 2.0.9
	Author: "Massimiliano Vessi"
	file: %superenalotto.r
    Email: maxint@tiscali.it
    Date: 07-Jul-2009 
	Purpose: {Simple random number generator.}
	
 ;following data are for www.rebol.org library
 ;you can find a lot of rebol script there
 library: [ 
           level: 'beginner 
           platform: 'all 
           type: [tutorial tool] 
           domain: [math vid gui] 
           tested-under: [windows linux] 
           support: none 
           license: [gpl] 
           see-also: none 
          ] 
	
	]

	
;FOREWORDS
;Supernalotto is a national lotery	
;in Italy
;you have to guess six numbers from 1 to 90
;you have, usually, two row to fill
;prizes are very very high (around € 100'000'000)
;good luck!
;UPDATE: Now in Italy is possible to choose another numer: the "SuperStar"... in addition... bleah!!!
	
;Initialize the random generator	
random/seed now

header-script: system/script/header

version: "Version: "
append version header-script/version

;This function extract 6 random number
;and sort them , and then verify they are
;all different
funz_estr: func [] [
    prova: []
	until [
	    verifica: true
		prova: head prova
		clear prova
		loop 6 [
		      wait random 6
		    p1/data: p1/data + 0.08
		    show p1
			insert prova random 90
	 		]
		sort prova
		forall  prova [
		   
    		if  (index?  prova) = 6 [break]
			if (( first prova ) = ( second prova))  [ verifica: false ]
			]
			
		verifica
		]
	prova: head prova
	return prova
]





;This layout is a simple window that 
;it appears and show "Elaborazione..."
;(Elaborazione means Thinking in Italian)

thinking: layout [ 
	h2 "Elaborazione..."
	p1: progress
	]

	
	
	
	
;A info window
info: layout  [
 		h2 "INFO"
  		text "Author: Massimiliano Vessi"
  		text "email:  maxint@tiscali.it"
        text version
  		button "Close" [unview] 
  		]
	
;The main window with the button to extract
;numbers

view layout [
	title "SuperEnalotto extractor"
	across
	a1: box  50x50 "---"
	
	a2: box  50x50 "---"
	
	a3: box 50x50 "---"
	
	a4: box 50x50 "---"
	
	a5: box 50x50 "---"
	
	a6: box 50x50 "---"
	
	stella1: box 50x50  effect [draw [ fill-pen red polygon  5x20 18x20  25x0 32x20 45x20 35x30 41x50 25x40 9x50 15x30 ] ]
	return
	b1: box 50x50 "---"
	
	b2: box 50x50 "---"
	
	b3: box 50x50 "---"
	
	b4: box 50x50 "---"
	
	b5: box 50x50 "---"
	
	b6: box 50x50 "---"
	

	
	return
	button "Estrazione" [
		view/new thinking 
		estrazione: copy funz_estr
		wait random 3
		estrazione2: copy funz_estr
		a1/text: estrazione/1
		a2/text: estrazione/2
		a3/text: estrazione/3
		a4/text: estrazione/4
		a5/text: estrazione/5
		a6/text: estrazione/6
		b1/text: estrazione2/1
		b2/text: estrazione2/2
		b3/text: estrazione2/3
		b4/text: estrazione2/4
		b5/text: estrazione2/5
		b6/text: estrazione2/6
		stella1/text: random 90		
		unview thinking
		p1/data: 0
		show [a1 a2 a3 a4 a5 a6 b1 b2 b3 b4 b5 b6 stella1 ]
		]
	button "info" [view/new/title  info	"Info"]
		
]