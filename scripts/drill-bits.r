REBOL [
	Title:		"Drill Bits"
	Author:		MikeL
	File:		%drill-bits.r
	Date:		08-Aug-2005
    Purpose: {A VID drill program to help memorize facts 
	using repeated multiple choice question and answers.}	
	Copyright:		none
	Version: 		0.9
	History: 	[
		'orig	07-April-2001
        'one-three    06-Aug-2005
        ]	
	library: [
        level: 'intermediate
        platform: 'all
        type: [tool]
        domain: [ftp game]
        tested-under: [view 1.3.1.3.1 on "W2K"]
        support: none
        license: none
        see-also: none
    ]		
]

do reset-counters: func [] [
	right-clicks: wrong-clicks: 0
]
; 
; button-index is used to match buttons to answers
; 

button-index: 0


maximum-displayed-answers: 10


drill-data-files: []

color-right: reduce [green - 40]
color-wrong: reduce [255.0.0 - 40]

color-not-selected:  [silver + 10 silver]

stylize/master [
	answer-button: btn 20x40 water water
	
	 	with [
			append init compose [
 				show?: false
				user-data: make object! [
					selected?: false
					index: (button-index: button-index + 1)
				]
 			]
		]

	answer: btn 600x40 water + 40 water
        left font-size 17
		[
		
			face/user-data/selected?: true
			either face/user-data/right? [				
				face/colors: color-right
				picked-right/text: form right-clicks: right-clicks + 1
				show picked-right
			][				
				face/colors: color-wrong
				picked-wrong/text: form wrong-clicks: wrong-clicks + 1
				show picked-wrong
			]
			show face
		]
 	with [append init [
		show?: false
		user-data: make object! [
			selected?: false
			right?: false
		]
     ]
    ]
	
]
sample-data: {Title "Sample Questions"
icon  http://www.rebol.com/graphics/reb-logo.gif
author MikeL
date  04-Aug-2005
questions [
 [
   Q "What is the capital of Estonia?"
   right [{Tallinn}]
   wrong ["Helsinki" "Tartu" "Kunda"]
 ]
 [
  Q "What is the capital of Denmark?"
   right [{Copenhagen}]
   wrong ["Randers" "Aalborg" "Odense"] 
 ]  
 [
   Q "What country has Tallinn as its capital?"
   right [{Estonia}]
   wrong ["Finland" "Latvia" "Russia"]
  ]
 [
   Q "The British government decided that the colonies should help pay for their debt. What caused their debt?"
	right ["The Seven Years War"]
	wrong ["The Queen's Jewels" "Tea" "Gambling"]
 ]  
 [
   Q "Which of these is true about the Seven Years War which started in 1754?"
	right [
		"Started in North America and spread to Europe"
		"Pitted the French against the English"
		"Included the American colonies on the British side"
		"George Washington fought in it for the British"
		"Started in the Ohio Valley"
		"Caused George Washington to build Fort Necessity"
		"Ended in 1760 one year after Quebec fell"
	]
	wrong [
		"Wolfe lived to see the end of the war"
		"Ended on the Plains of Abraham"
		"The French soldiers were experienced and fought well to defend Quebec City"
	]
 ]  
  
]
}drill-data-path: %./data/

if not exists? drill-data-path [
	if "y" = ask {Do you want to create the data directory now? } [
		make-dir drill-data-path
		if "y" = ask {Do you want to store a sample file with the .dat extension? } [		
			write drill-data-path/%sample.dat sample-data	
			alert {The next time you run this script it should detect the sample script for selection.}
		]		
	]
]
foreach file read drill-data-path [
    if find file ".dat" [
		if not none = find read drill-data-path/:file "questions" [
			append drill-data-files file
        ]
	]
]

either 1 = length? drill-data-files [	; if only 1, use it
	the-file: pick drill-data-files 1
][ 					; else let the user select the data file that they want
	view file-selector: layout [
		size 800x600 across
		txt "Pick a quiz file. Cancel will use a default file."
		return text-list data drill-data-files [
			the-file: value
			unview/only file-selector]
		return button "Cancel" [			
			the-file: none
			unview/only file-selector
		]
	]
]

data: either none = the-file [
	load sample-data
][
	load drill-data-path/:the-file
]




quiz-graphic: either none = select data 'icon [
	load-thru/binary http://www.rebol.com/graphics/reb-logo.gif
][	
	data/icon
]
do randomize: func [] [
	random/seed now/precise
	q-and-a: random data/questions
]
number-of-questions: length? q-and-a
topic: pick q-and-a (i: 1)

answer: make object! [
	my-text: none
	right?: true
]

answer-list: [a1 a2 a3 a4 a5 a6 a7 a8 a9 a10]
button-list: [b1 b2 b3 b4 b5 b6 b7 b8 b9 b10]
set-ui-value: func [
    index-value
    text-value
    right?
    show?
][
	ui-answer: get pick answer-list index-value
	ui-button: get pick button-list index-value
	ui-answer/user-data: compose [right? (right?) selected? false]
	ui-answer/text: uppercase/part form text-value 1
	either show? [
		ui-answer/state: false
		ui-answer/user-data/selected?: false
		show [ui-answer ui-button]
    ][
		hide [ui-answer ui-button]
    ]
]
back-to-default-color: does [
	foreach answer answer-list [
        an-answer: get answer
        an-answer/colors: color-not-selected
    ]
]

show-q-a: does [
	q/text: topic/q
	show q
	answers: copy []

    back-to-default-color

	foreach wrong-answer topic/wrong [
		insert tail answers make answer [
			my-text: wrong-answer
			right?: false
		]
	]
	foreach right-answer topic/right [
		insert tail answers make answer [
			my-text: right-answer
			right?: true
		]
	]
	j: 0
	foreach entry sort/compare answers func [a b][(a/my-text) < b/my-text]
		[
            either maximum-displayed-answers > j [
                set-ui-value (j: j + 1) entry/my-text entry/right? true
            ][

            ] ; message/text ["Sorry question " topic/question " has too many answers. Limited to " maximum-displayed-answers "."] show message ]
		]
	for k (j + 1) 10 1 [set-ui-value k none false false]

	question-number/text:  rejoin [form i " of " form number-of-questions ]
	show question-number
	how-many: length? topic/right

	right-answers/text: reduce ["This question has " form how-many either 1 = how-many
		[" right answer"]
		[" right answers"]
    ]
	picked-right/text: form right-clicks
	picked-wrong/text: form wrong-clicks
	show [right-answers picked-right picked-wrong]
]

drill-layout: layout [
	across size 660x680
	backdrop ivory
	
	image quiz-graphic 50x50
	
	title data/title
	pad 80
	arrow 24x24 left keycode [up left] [
		topic: pick q-and-a i: max 1 (i - 1)
		show-q-a
		]
	question-number: btn water 60x24
	arrow 24x24 right keycode [down right] [
		topic: pick q-and-a (i: min (i + 1) length? q-and-a)
		show-q-a
	]

	return txt "Question" red font-size 18
	pad 10 right-answers: txt  240x18 black bold ""
	picked-right: btn 40 color-right/1 60x24 [alert {This is how many answers you have clicked in this session that are right. They turned a green color when you clicked them.}]


	pad 10 picked-wrong: btn 40 color-wrong/1 60x24  [alert {This is how many answers you have clicked in this session that are wrong. They turned a red color when you clicked them.}]
	pad 10 btn "Doc" 40 [browse http://www3.sympatico.ca/cybarite/rebol/drill-bit-documentation.html]
	btn 60 "Restart" [
		randomize
		topic: pick q-and-a i: 1
		reset-counters
		show-q-a
	]
	btn 40 question-number/size "Quit" [quit]
	return q: txt 600x70 topic/Q blue font-size 18
	return box 626x5 red
	return b1: 	answer-button "A" a1: 	answer
	return b2: 	answer-button "B" a2: 	answer
	return b3: 	answer-button "C" a3: 	answer
	return b4: 	answer-button "D" a4: 	answer
	return b5: 	answer-button "E" a5: 	answer
	return b6: 	answer-button "F" a6: 	answer
	return b7: 	answer-button "G" a7: 	answer
	return b8: 	answer-button "H" a8: 	answer
	return b9: 	answer-button "I" a9: 	answer
	return b10:	answer-button "J" a10: 	answer
]
topic: pick q-and-a i: 1
show-q-a

for i 1 length? answers 1 [
	a-question-identifier: get pick button-list i
	a-question-identifier/show?: true
	an-answer: get pick answer-list i
	an-answer/show?: true
]
view drill-layout
