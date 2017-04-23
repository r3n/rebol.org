Rebol [
	title: "Who wants to be a Millionaire"
	Author: "Massimiliano Vessi" 
	Email: maxint@tiscali.it 
	Date: 24-Aug-2012
	version: 1.0.2 
	file: %millionaire.r 
	Purpose: "Who wants to be a Millionaire game" 
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

random/seed now

if not exists? %millionair_files/ [ make-dir  %millionair_files/ ]

cd %millionair_files/

if not exists? %highscores.txt [ save %highscores.txt  [] ]

hscores: load %highscores.txt

requestedfiles: [ %questions.csv  %logo.jpg ]

foreach item requestedfiles [
	if not exists? item [ 		
		request-download/to rejoin [http://www.maxvessi.net/rebsite/millionaire/ to-url item]   item 
		]
	]


csv-import: func [
    "Import a CSV file transforming it in a series."
    file [file!] "CSV file"
    /local temp temp2 temp3 temp4
    ] [
    temp: read/lines file
    temp2: copy []
    foreach item temp [
	temp3: copy []	
	parse item  [{"} copy temp4 to {","} (append temp3 temp4) some [ thru {","} copy temp4 to {","} (append temp3 temp4)] thru {","} copy temp4 to {"} (append temp3 temp4)  ]
	append/only temp2 temp3 
	]	
    return temp2    
    ]
    

questions: csv-import %questions.csv

;editor questions
;question CSV is organized this way: 
;"questionID","body","a","b","c","d","correct","level"
;now I organize question fo level
;creating quetion1, quetion2, ..., question15 blocks
for i 1 15 1 [
	set (to-word join "question" i ) copy []		
	foreach item questions [				
		if (last item) = (to-string i) [  ;it's the level requested
			append/only (get to-word join "question" i ) item
			]
		]
	
	]

;print question1 

;starting level
level: 1
;extraction function
q_extr: func [ /local tmp] [
	; mix and extract a question for the current level
	q: copy random get to-word join "question" level
	;let create the question and the set of answers
	bodyq: q/1/2
	
	qq: reduce [q/1/3 q/1/4 q/1/5 q/1/6  ]
	;let's find the correct answer
	tmp: (to-integer q/1/7) + 2 ; the first answer is in position 3 in the block
	correct:  q/1/:tmp	
	qq: copy random qq	
	]

q_extr


higscoreslay: layout [
	title "HIGH SCORES"
	table-hs: text-list data hscores
	btn-cancel [unview]
	]

view layout [
	style buttona button [ 		
		either face/text = correct [
			temp:  get to-word join "a" level 
			temp/color: green
			++ level	
			either  level > 15 [ 
				Alert "You win $ 1'000'000. You are a millionaire!"
				name: request-text/title "Please insert your name"
				append/only hscores reduce [ (level - 1) " " name ]
				sort hscores
				reverse hscores
				save %highscores.txt hscores				
				view/new higscoreslay
				level: 1
				q_extr
				the_q/text: bodyq
				aa/text: qq/1
				bb/text: qq/2
				cc/text: qq/3
				dd/text: qq/4
				a1/color:  a2/color:  a3/color:  a4/color:  a5/color:  a6/color:  a7/color:  a8/color:  a9/color:  a10/color:  a11/color:  a12/color:  a13/color:  a14/color:  a15/color:  167.173.201
				show [the_q aa bb cc dd  a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15]				
				] [
					q_extr
					the_q/text: bodyq
					aa/text: qq/1
					bb/text: qq/2
					cc/text: qq/3
					dd/text: qq/4						
					show [the_q aa bb cc dd temp]
					]
			] [
				alert "You lost"  
				;put high score
				name: request-text/title "Please insert your name"
				append/only hscores reduce [ (level - 1) " " name ]
				sort hscores
				reverse hscores
				save %highscores.txt hscores				
				view/new higscoreslay
				level: 1
				q_extr
				the_q/text: bodyq
				aa/text: qq/1
				bb/text: qq/2
				cc/text: qq/3
				dd/text: qq/4
				a1/color:  a2/color:  a3/color:  a4/color:  a5/color:  a6/color:  a7/color:  a8/color:  a9/color:  a10/color:  a11/color:  a12/color:  a13/color:  a14/color:  a15/color:  167.173.201
				show [the_q aa bb cc dd  a1 a2 a3 a4 a5 a6 a7 a8 a9 a10 a11 a12 a13 a14 a15]
				]
		]
          across
	title  "Who wants to be a Millionaire"
	return 
	panel [
		across
		image  150x90 (load-image %logo.jpg)
		panel [
			buttona "Restart" 
			button "High scores" [view/new higscoreslay ]
			button "Help" [notify  {Push the button with the solution to the given question. Try to solve all 15 questions.
				If you need to contact me, my email is maxint@tiscali.it}]
			]
		return 
		h3 red 300 center  "Question:"
		return 
		the_q: text center middle  300x100 bodyq
		return 
		bar navy 310
		return 
		aa: buttona 150x70  qq/1
		bb: buttona 150x70  qq/2
		return
		cc: buttona 150x70  qq/3
		dd: buttona 150x70  qq/4
		]
	panel 167.173.201 [
		
		a15: text "$ 1'000'000"
		a14: text "$ 300'000"
		a13: text "$ 150'000"
		a12: text "$ 70'000"
		a11: text "$ 35'000"
		a10: text "$ 16'000"
		a9: text "$ 8'000"
		a8: text "$ 4'000"
		a7: text "$ 2'000"
		a6: text "$ 1'000"
		a5: text "$ 500"
		a4: text "$ 300"
		a3: text "$ 200"
		a2: text "$ 100"
		a1: text "$ 50"		
		] edge [size: 2x2 color: navy]	
	]