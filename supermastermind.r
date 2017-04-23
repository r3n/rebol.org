rebol[ title: "Supermastermind"
	Author: "Massimiliano Vessi" 
	Email: maxint@tiscali.it 
	Date: 23-11-2011 
	version: 2.0.5
	file: %supermastermind.r 
	Purpose: "The old clasic game Mastermind"
	;following data are for www.rebol.org library 
	;you can find a lot of rebol script there 
	library: [ 
		level: 'beginner 
		platform: 'all 
		type: [tutorial game ] 
		domain: [ vid gui] 
		tested-under: [windows linux] 
		support: none 
		license: [gpl] 
		see-also: none 
		] 
	]

;load configuration settings
either exists? %.supermastermind.conf [ 
	configuration: do load %.supermastermind.conf 
	] [
	configuration: make object! [
		hi-score_hard: copy [ ] 
		hi-score_easy:  copy [ ] 
		hystory_b: [backdrop sienna across tabs 100 ]  ;the history block
		hyst_offset: 0x0 ; the history layout offset
		difficulty: "Easy"
		secret: copy [] ;the secret code
		playing: false
		counter: 0
		]
	]

;loading image
either exists? %.supermastermind.png [ foto: load %.supermastermind.png ] [
	either  ( error?  [ foto: load  http://www.maxvessi.net/rebsite/supermastermind.png] ) [ foto:  logo.gif ] [
		foto: load  http://www.maxvessi.net/rebsite/supermastermind.png
		save/png %.supermastermind.png foto
		]
	]

colors: [ blue red black maroon green magenta orange white ]

random/seed now

saveall: does [ 	save %.supermastermind.conf  configuration ]

;secret code creation function, used for a new game
create_code: does [ 
	secret: copy []
	either configuration/difficulty = "Easy" [ secret: copy/part random colors 5 ] [ 		
		for i 1 5 1 [
			append secret (  copy/part random colors 1 )
			]		
		]
	configuration/secret: secret	
	saveall	
	]

either (configuration/secret = [] ) [ create_code] [ secret: configuration/secret ]


;color convertion functions


convert: func [ text ] [ 
	if text = "blue" [return 0.0.255]
	if text = "red" [return 255.0.0]
	if text = "black" [return 0.0.0]
	if text = "maroon" [return 128.0.0]
	if text = "green" [return 0.255.0]
	if text = "magenta" [return 255.0.255]
	if text = "orange" [return 255.150.10]
	if text = "white" [return 255.255.255]	
	]
	
	
riconvert: func [ text ] [ 
	if text = 0.0.255 [return "blue" ]
	if text =  255.0.0 [return "red"]
	if text = 0.0.0  [return "black"]
	if text = 128.0.0  [return "maroon" ]
	if text = 0.255.0  [return "green" ]
	if text = 255.0.255  [return "magenta"]
	if text = 255.150.10  [return "orange"]
	if text = 255.255.255  [return "white" ]	
	]

;layouts



secret_lay:  layout  reduce [
	'backdrop 'sienna 
	'across 
	'box 100x30 secret/1 (to-string secret/1)
	'box 100x30 secret/2 (to-string secret/2)
	'box 100x30 secret/3 (to-string secret/3)
	'box 100x30 secret/4 (to-string  secret/4)
	'box 100x30 secret/5 (to-string  secret/5)
	]
secret_lay/offset: 0x0

hidden_lay:  layout  [
	backdrop sienna
	h1 brown  configuration/difficulty
	at 199x0
	box 300x50 brown  font [ size: 24 color: sienna] "?     ?     ?     ?     ?"	
	]	
hidden_lay/offset: 0x0

lost_lay: layout [
	across
	backdrop sienna 	
	title yellow "YOU LOST!"  
	return 
	text italic "Sorry, maybe next time you'll be more lucky!"
	button "New game" [ configuration/playing: false  
		create_start  
		]
	return
	image foto
	]
lost_lay/offset: 0x0

win_lay: layout [ 
	across
	backdrop sienna 	
	title yellow "YOU WIN!" 
	return
	text italic "Congratulation!"
	button "New game" [ 
		configuration/playing: false   
		create_start  
		]
	return
	image foto
	]
win_lay/offset: 0x0	

	
;check colors



check_col: func [blocco] [
	youwin: false
	blocco2: copy blocco
	configuration/counter: configuration/counter + 1
	solve_b: copy [ ]
	append configuration/hystory_b  [ return text white]
	append configuration/hystory_b to-string configuration/counter
	blocco_secret: reduce secret
	blocco_secret2: copy blocco_secret
	;black
	foreach item blocco_secret [		
		either item = (first blocco) [ 
			append solve_b "b"  
			remove blocco
			remove blocco_secret2
			] [ blocco: next blocco 
			   blocco_secret2: next blocco_secret2
			]
		]
	;now it puts all the black pegs, if there are 5 pegs, the user won
		if (length? solve_b) = 5 [  youwin: true  ]	
	;white
	blocco: head blocco
	blocco_secret2: head blocco_secret2
	foreach item blocco [
		if find blocco_secret2 item [ 
			remove find blocco_secret2 item 
			append solve_b "w"
			]
		]		
	foreach item solve_b [
		if item = "b" [ append configuration/hystory_b [bbutton 20x20 0.0.0] ]
		if item = "w"  [ append configuration/hystory_b [bbutton 20x20 255.255.255] ]
		]	
	if (length? solve_b) < 5 [
		pads: 5 - (length? solve_b)
		for i 1 pads 1 [ append configuration/hystory_b [pad 20] ]
		]
	append configuration/hystory_b reduce [ 'tab 'box 50x30 blocco2/1 'box 50x30 blocco2/2  'box 50x30 blocco2/3  'box 50x30 blocco2/4  'box 50x30 blocco2/5  ]
	either configuration/counter > 10 [
		configuration/hyst_offset:  configuration/hyst_offset - 0x38
		hystory/pane: layout/offset  configuration/hystory_b  configuration/hyst_offset
		] [
		hystory/pane: layout/offset  configuration/hystory_b  0x0
		]		
	show hystory			
	if youwin [ 		
		configuration/playing: false
		hystory/pane: win_lay  
		code/pane: secret_lay 
		show  [ code  hystory ]
		if configuration/difficulty = "Easy" [ append/only configuration/hi-score_easy  reduce [configuration/counter  " " (request-text/title "Insert your name:") ] ]
		if configuration/difficulty = "Hard" [ append/only configuration/hi-score_hard  reduce [configuration/counter  " " (request-text/title "Insert your name:") ]]		
		]
	saveall
	
	]	


scroll-panel-vert: func [pnl bar][
        pnl/pane/offset/y: negate bar/data *
            (max 0 pnl/pane/size/y - pnl/size/y)
        show pnl
    ]

;start_layout
start_lay: [
	across
	backdrop sienna 
	title yellow {Try to guess the secret combination} 	
	return 
	]
either  configuration/playing  [
	append start_lay [				
		text reform [ "Your current game: move " configuration/counter  ", difficulty"  configuration/difficulty]
		return 
		text italic "What do you want to do?"
		button "Resume game" [
			hystory/pane: layout/offset  
			configuration/hystory_b  configuration/hyst_offset
			show hystory  			
			]
		button 100x35 "Star a new game" [create_start]
		return 
		image foto
		]
	] [
		append start_lay [			
			text {A new combination is ready, difficulty:}				
			cc: choice "Easy"  "Hard" [ configuration/difficulty: value  create_start]
			do [cc/text: configuration/difficulty show cc]
			return 
			text "You can start to play, just make your combination and press TRY."
			return
			image foto
			]
		configuration/hystory_b: [
			backdrop sienna 						
			across 
			tabs 100		
			style bbutton box  effect [oval] edge [color: sienna]
			style box box  effect [oval] edge [color: sienna]
			]
		configuration/hyst_offset: 0x0
		configuration/counter: 0
		configuration/playing: true
		]
start_lay: layout/offset start_lay 0x0




create_start: does [
	start_lay: layout/offset [		
		across
		backdrop sienna
		title yellow {Try to guess the secret combination} 
		return 
		text {A new combination is ready, difficulty:}				
		cc: choice "Easy"  "Hard" [ configuration/difficulty: value  create_start]
		do [cc/text: configuration/difficulty show cc]
		return
		text "You can start to play, , just make your combination and press TRY."
		return
		image foto
		] 0x0
	if value? 'difficulty [ difficulty/text: configuration/difficulty show difficulty ]
	create_code	
	configuration/counter: 0
	configuration/hystory_b: copy [backdrop sienna across tabs 100 ]
	configuration/hyst_offset: 0x0 
	hystory/pane: start_lay
	hidden_lay:  layout  [
		backdrop sienna
		h1 brown  configuration/difficulty
		at 199x0
		box 300x50 brown  font [ size: 24 color: sienna] "?     ?     ?     ?     ?"	
		]
	secret_lay:  layout  reduce [
		'backdrop 'sienna 
		'across 
		'box 100x30 secret/1 (to-string secret/1)
		'box 100x30 secret/2 (to-string secret/2)
		'box 100x30 secret/3 (to-string secret/3)
		'box 100x30 secret/4 (to-string  secret/4)
		'box 100x30 secret/5 (to-string  secret/5)
		]
	secret_lay/offset: 0x0
	hidden_lay/offset: 0x0
	code/pane: hidden_lay		
	show [hystory  code]
	configuration/playing: true							
	saveall 
	]	


	
	
view/title layout [	
	backdrop sienna
	title  "Super Mastermind"
	code: box  600x50
	do [	code/pane: hidden_lay] 
	across		
	hystory: box 600x400 frame brown
	do [	hystory/pane: start_lay 	]
	s1: scroller 16x400 0.99 brown brown [scroll-panel-vert hystory s1]	
	return
	b1: box 100x30 blue "blue"
	b2: box 100x30 blue "blue"
	b3: box 100x30 blue "blue"
	b4: box 100x30 blue "blue"
	b5: box 100x30 blue "blue"
	return
	choice  "blue" "red" "black" "maroon" "green" "magenta" "orange" "white" [b1/text: value b1/color:  convert value show b1]
	choice "blue" "red" "black" "maroon" "green" "magenta" "orange" "white" [b2/text: value b2/color:  convert value show b2]
	choice "blue" "red" "black" "maroon" "green" "magenta" "orange" "white" [b3/text: value b3/color:  convert value show b3]
	choice "blue" "red" "black" "maroon" "green" "magenta" "orange" "white" [b4/text: value b4/color:  convert value show b4]
	choice "blue" "red" "black" "maroon" "green" "magenta" "orange" "white" [b5/text: value b5/color:  convert value show b5]
	at 560x525 button  60x65  "TRY" [ if configuration/playing [check_col reduce [b1/color b2/color b3/color b4/color b5/color] ] ]
	return
	box black 600x2
	return
	
	button "Help" [ 
		view/new/title layout [ 
			title "Help" 
			h2 "Rules"
			text 500 { The codebreaker (you) tries to guess the pattern, in both order and color. Each guess is made by placing a row of code pegs on the decoding board. Once placed, the codemaker (PC) provides feedback by placing from zero to four key pegs in the small holes of the row with the guess. A colored or black key peg is placed for each code peg from the guess which is correct in both color and position. A white peg indicates the existence of a correct color peg placed in the wrong position. If there are duplicate colours in the guess, they cannot all be awarded a key peg unless they correspond to the same number of duplicate colours in the hidden code. For example, if the hidden code is white-white-black-black and the player guesses white-white-white-black, the codemaker will award two colored pegs for the two correct whites, nothing for the third white as there is not a third white in the code, and a colored peg for the black. No indication is given of the fact that the code also includes a second black.} 
			h2 "No combination (easy)"
			text 500 {This game type has the following rule: sercet code hasn't color repetitions. All five colors are totally different. A skilled player wins in less 12 moves. However you can try any number of time.}
			h2 "Combination (hard)"
			text 500 {This game type allows ripetitions in secret code (like "blue" "blue" "blue", it's harder to win. A skilled player should win this game less than 16 moves. However you can try any number of time.}
			h3 "Author"
			text 500 rejoin ["Made by Massimiliano Vessi, you can contact me write to: " "maxint" "@" "tiscali.it" ]
			] "Help Supermastermind"
					]
	button "High scores" [
		backhs: reduce [ 'gradient  1x1 random white  random white random white]
		sort configuration/hi-score_hard  
		sort configuration/hi-score_easy
		view/new/title  layout [ 
			backdrop effect backhs
			h2 "HIGH SCORE HARD GAME" 
			text-list data configuration/hi-score_hard  
			return
			box black 1x230
			return
			vh2"HIGH SCORE EASY GAME" 
			text-list data configuration/hi-score_easy 
			] "Supermastermind High-Score" 
		]	
	text "Difficulty:" 
	difficulty: choice	"Easy"  "Hard" [ configuration/difficulty: value  ]
	do [ difficulty/text: configuration/difficulty]
	button "New game" [
		if (confirm "Are you sure that you want to interrupt this game and start a new one?" ) [ 
			configuration/playing: false 				
			create_start  
			] 
		]
	button red "Surrender" [ 
		if configuration/playing [
			if (confirm "Are you sure you want to surrender and loose the game?" ) [ 
				configuration/playing: false 				
				hystory/pane: lost_lay 
				code/pane: secret_lay 
				show [ hystory code ]
				]				
			saveall 
			]
		]
	return
	text reform [ "Version:" system/script/header/version ]
	] "Supermastermind"