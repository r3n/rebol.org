Rebol [
	Title: "Dice roller generator" 
	File: %dice-roller.r
	Author: "Massimiliano Vessi" 
	Date: 2010-12-31 
	Version: 1.0.1
	email: maxint@tiscali.it
	Purpose: {From an idea of Adrew Martin a dice rolling generator for
		role-playing game like D&d or D20.} 
	Library: [ 
	level: 'beginner
	platform: 'all 
	type: [tool demo ] 
	domain: [all] 
	tested-under: [view 2.7.7.3.1 Windows Linux ] 
	support: maxint@tiscali.it 
	license: 'gpl
	see-also: none ] 
	]
random/seed now
roll: func [ formula [string!] /local temp temp2 result test ] [
	;test if good formula:
	test: parse formula [integer! "d" integer!]
	either test [
		temp:  parse formula "d"
		temp2:  reduce [(to-integer temp/1)   (to-integer temp/2)]
		result: 0
		loop temp2/1 [ result:  result + (random temp2/2)	] 		
		result][
			"Invalid formula"
			]
	]
	
view/title layout [
	vtext {Type your formula for dice roll (like 2d6) and push "Roll" button.}
	across
	vlab "Formula:"
	aa: field  [
		insert bb/text ( reform [aa/text ":^/" tab (roll aa/text) newline ] ) 
		show bb
		]	 
	btn "Roll" [
		insert bb/text ( reform [aa/text ":^/" tab (roll aa/text) newline ] ) 
		show bb
		]
	return 
	bb: area 	
	] "Dice roller generator"