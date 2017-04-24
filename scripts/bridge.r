REBOL [
	File: %bridge.r 
	Date: 12-jan-2016 
	Title: "distribution table de bridge"
	Author: Bertrand Thierry
	Purpose: {  Distibuer les 4 mains d'une table de bridge 
				compter les points H, L et les éventuels D
				ainsi que caractériser la distribution }
]

Version: 0.2
Noms-Cartes: ["2" "3" "4" "5" "6" "7" "8" "9" "T" "V" "D" "R" "A"]
Noms-Couleurs: ["Trefle" "Carreau" "Coeur" "Pique"]
Contrat-Hauteur: ["1" "2" "3" "4" "5" "6" "7"]
Contrat-Couleur: ["Trefle" "Carreau" "Coeur" "Pique" "Sans-Atout"]
pointsHonneur: ["A" 4 "R" 3 "D" 2 "V" 1]
donneur: to-integer 0		; la main initiale est en Sud
position: ["Sud" "Ouest" "Nord" "Est"]
Mains: [[]]
pointsD: [[]]
distrib: [[]]
laDonne: [[]]
typeDistrib: [[]]
Jeu-cartes: [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52];
mesPH: 0
;=======================================
; distribution des cartes
;=======================================
distribue: does [
	Donne: []
	laDonne: []
	Nb-Cards: 52
	
	random/seed now
	Jeu-cartes: copy [1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52]	
	While [Nb-Cards > 0]
	[
		Carte: Pick Jeu-cartes random Nb-Cards
		append Donne Carte
		remove find Jeu-cartes Carte
		Nb-Cards: Nb-Cards - 1
	]
	clear Mains;
	for Hd 0 3 1 [
		append/only Mains make block! sort copy/part Donne 13
		remove/part Donne 13
	]
	foreach Main Mains 	[
		Cards-Main: []
		Cards-Couleur: []
		laMain: []
		foreach Card Main [
			append Cards-Main pick Noms-Cartes Card - 1 // 13 + 1
			append Cards-Couleur pick Noms-Couleurs Card - 1 / 13  + 1  
			append/only laMain join join pick Cards-Main Length? Cards-Main " " pick Cards-Couleur Length? Cards-Couleur
		]
		print " "
		append/only laDonne make block! laMain 
		clear laMain
	]
]

majeureCinq: func [ dist ] [
	numC: make integer! pick dist 3 
	numP: make integer! pick dist 4
	make logic! numC > 4 or make logic! numP > 4
]

distribReguliere: func [ tdist ] [
	r1: equal? tdist [ 4 3 3 3 ]
	r2: equal? tdist [ 4 4 3 2 ]
	r3: equal? tdist [ 5 3 3 2 ]
	r1 or r2 or r3
]

distribUnicolore: func [ tdist ] [
	numC: make integer! pick tdist 1
	numP: make integer! pick tdist 2
	make logic! numC > 5 and make logic! nump < 4
]

distribBicolore: func [ tdist ] [
	numC: make integer! pick tdist 1
	numP: make integer! pick tdist 2
	make logic! numC > 4 and make logic! numP > 3
]

distribTricolore: func [ tdist ] [
	equal? tdist [ 4 4 4 1]
]

pointH: func [ main ] [
	pH: to-integer 0 
	pL: to-integer 0 
	nC: to-integer 0
	pD: []
	nbC: []
	c1: make string! first Noms-Couleurs
	cIdx: 1
	foreach chaine main [
		card: make string! first chaine 1
		if not none? find pointsHonneur card [
			ph: ph + first find/tail pointsHonneur card
		]
		coul: make string! skip chaine 2
		either coul = c1 [
			nC: nC + 1
		] 
		[	
			append nbC nC 
			cIdx: cIdx + 1
			c1: make string! pick Noms-Couleurs cIdx
			case [
				nC > 4 [ pL: pL + nC - 4 
						 append pD 0 ]			; points de longueur uniquement ?quid 9eme carte etc...
				nC = 4 [ append pD 0 ]			; ? quid 9eme carte ...
				nC = 3 [ append pD 0 ]
				nC < 3 [ append pD 3 - nC ]		; potentiellement des points de chicane, etc... 
			]
			while [ coul <> c1 ] [
				cIdx: cIdx + 1
				c1: make string! pick Noms-Couleurs cIdx 
				append pD 3 					; chicanes potentielles
				append nbC 0 ]						
			nC: 1
		]
	]
	append nbC nC
	case [
		nC > 4 [ pL: pL + nC - 4 
				 append pD 0 ]			; points de longueur uniquement ?quid 9eme carte etc...
		nC = 4 [ append pD 0 ]			; ? quid 9eme carte ...
		nC = 3 [ append pD 0 ]
		nC < 3 [ append pD 3 - nC ]		; potentiellement des points de chicane, etc... 
	]
	if CIdx <> 4 	[ while [ CIdx < 4 ] ; si pas de piques ...
						[ 	append pD 3 
							append nbC nC 
							cIdx: CIdx + 1 ]
					]
	append/only pointsD make block! pD 
	append/only distrib make block! nbC 
	append/only typeDistrib make block! sort/reverse nbC
	clear pD
	clear nbC
	pH: pH + pL
]

analyseMains: does [
	num: 1
	mesPH: 0
	clear pointsD
	clear distrib
	clear typeDistrib
	foreach main laDonne [
		prin "=============================================="
		player: num + donneur - 1 // 4 + 1 
		prin "main de " 
		prin pick position player 
		prin "=============================================="
		print ""
		foreach chaine main [
			prin chaine
			prin ","
		]
		print " "
		print "-----------------------------------------------------------------------------------------------------------"
		mesPH: pointH main ;
		print join " ayant " join mesPH " points HL" 
		prin " il y a "
		print join pick pointsD num " points D potentiels (si jeu à la couleur ...)"
		print join " distribution par couleur:" pick distrib num 
		print join " type de distribution:" pick typeDistrib num
		either majeureCinq pick distrib num
			[ print " il y a (au moins) une majeure (au moins) cinquieme "]
			[ if distribReguliere pick typeDistrib num 
				[
				print " la distribution est reguliere "]
			]
		if distribUnicolore pick typeDistrib num [print " la main est unicolore"]
		if distribBicolore pick typeDistrib  num [print " la main est bicolore"]
		if distribTricolore pick typeDistrib  num [print " la main est TRIcolore (quelle chance ...) "]
		num: num + 1 ;
	]
]

go: does [
	distribue 
	print join "  Le donneur est en " pick position Donneur + 1	
	analyseMains
	clear laDonne
	clear distrib
	clear typeDistrib
	r: ask "une autre (o)?"
]

r: ask "une donne (o)?"
while [ r == "o" ] 
[
	go
	donneur: donneur + 1 // 4
]


