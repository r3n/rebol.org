REBOL [
    Title: "My Clipboards"
    Purpose: "Manage multiple clips. So have more than just one choice when [copy]/paste; Could be helpful if repeat of pasting of a set of contents is needed."
    Be-Aware: "It takes control of your clipboard. And it doesn't handle binary contents well. So turn the program off if your to copy from MS Office or alike."
    Date: 1-Jul-2005
    Version: 1.0
    File: %undetermined.r
    Author: "Z. Yao"
    library: [
        level: 'intermediate
        platform: 'win
        type: 'tool
        domain: 'text
        tested-under: [view 1.3.1.3.1 on WinXP]
        support: none
        license: none
        see-also: none
    ]
]

archive-file: %myClipsArchive.txt
rotaryClips: [ ] 

f-size: 315x300
d-size: 220x255

trigit: func  [face text] [
    clear face/text
    face/line-list: none
    face/text: text
    show face
]

myredraw: func [face data clip-pos] [
	either  clip-pos = 0 [ 
		clip-pos: to-integer face/text 
		if clip-pos > length? rotaryClips [clip-pos: length? rotaryClips ]
		] [
		face/text: to-string clip-pos 
		]
	selection: pick data clip-pos
	if selection = none [ selection: ""]
       	trigit clipdisp copy selection
	show face
    	write/binary clipboard:// selection

]

MyClips: layout [
     size f-size
  ;  origin 20x10
     backdrop black

    space  1
    at 5X5 vh1 "my ClipBoards"
    at 250x5 button "<" 25x25 [
	s: to-integer cliptrig/text
	clip-pos: s - 1
	
	myredraw cliptrig rotaryClips clip-pos
    	]
    at 280x5 button "$" 25x25 [
	clip-pos: length? rotaryClips
	myredraw cliptrig rotaryClips clip-pos
    	]

	
    below
    at 8x35 guide
     
    button "1 more" 80x30 green font [colors: [101.60.101 181.255.1]] [
        clip: read/binary clipboard://
	unless find rotaryClips clip [ 
		append rotaryClips clip 
		myredraw cliptrig rotaryClips 0
		]
    	]
    button "arc Save" 80x30 [
	write/lines/with archive-file rotaryClips "-=-=-"
        clipdisp/line-list: none
	clipdisp/text:  join "saved " join to-string length? rotaryClips join " records to " to-string archive-file
	show clipdisp
    	]
    button "arc Load" 80x30 [
	append  rotaryClips read/lines/with archive-file "-=-=-"
	 rotaryClips: unique rotaryClips
        clipdisp/line-list: none
	clipdisp/text:  join "loaded " join "records from " to-string archive-file
	show clipdisp
    	]
    button "remove 1" 80x30 [
	rm-item: copy clipdisp/text
;	rm-item: read clipboard://
	write clipboard:// ""
	remove find rotaryClips rm-item
	myredraw cliptrig rotaryClips 0
    	]
	[ to-error ]

    cliptrig: button "0" 80X80 font [size: 38 ] 180.0.0 [
	s: to-integer cliptrig/text
	either s < length? rotaryClips [ clip-pos: s + 1 ] 
		[clip-pos: 1]
	myredraw cliptrig rotaryClips clip-pos
    	]

    vh2 80x30 "00:00:00" rate 1 effect [gradient 0x1 0.0.150 0.0.50]
 feel [
	engage: func [face act evt] [
		face/text: now/time  show face
		clip: read/binary clipboard://
		unless find rotaryClips clip [ append rotaryClips clip ]
		clip-pos: index? find rotaryClips clip
		myredraw cliptrig rotaryClips clip-pos
		]
	]


    return
    indent 2
    space 1

    clipdisp: area d-size left font-size 10 font-color orange bold wrap
]


MyClips/offset: 970x58


view MyClips