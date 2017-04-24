Rebol [
	Title: "EuroJackpot extractor" 
	File: %eurojackpot.r 
	Author: "Massimiliano Vessi" 
	Date: 2012-6-20
	Version: 0.0.2
	email: maxint@tiscali.it
	Purpose: {EuroJackpot is a transnational lottery in Europe,
	Participating countries are (in alphabetical order) Denmark, 
	Estonia, Finland, Germany, Italy, the Netherlands and Slovenia.
	The goal is to choose the five correct numbers out of 50 plus 2 out of another 8 numbers.
	If you are lucky, please send me an email.
	} 
Library: [ level: 'beginner
	platform: 'all 
	type: [demo game] 
	domain: [all] 
	tested-under: [view 2.7.8.3.1 Windows Linux ] 
	support: maxint@tiscali.it 
	license: 'gpl
	see-also: none ] 
	]

random/seed now
;let's create the series with the number required
longserie: copy []
shortserie:  [1 2 3 4 5 6 7 8]

for i 1 50 1 [
	append longserie i
	]
	
;extraction function	
extraction: func [] [
	the5:  copy/part (random longserie) 5
	the2: copy/part (random shortserie) 2
	sort the5
	sort the2
	]

view/title layout [ 
	across
	Title "EuroJackpot extractor"
	return
	a1: text "xxx"
	a2: text "xxx"
	a3: text "xxx"
	a4: text "xxx"
	a5: text "xxx"
	return
	b1: text red "xx"
	b2: text red "xx"
	return
	aa: button 100x30 "Extract numbers" [ 
		
		extraction
		a1/text: the5/1
		a2/text: the5/2
		a3/text: the5/3
		a4/text: the5/4
		a5/text: the5/5
		b1/text: the2/1
		b2/text: the2/2
		show [a1 a2 a3 a4 a5 b1 b2]
		]
	] "EuroJackpot extractor"