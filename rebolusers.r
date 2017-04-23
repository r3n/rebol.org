Rebol [
	Title: "Rebol users" 
	Author: "Massimiliano Vessi" 
	Email: maxint@tiscali.it 
	Date: 21-March-2011 
	version: 1.1.0 
	file: %rebolusers.r 
	Purpose: {"Show rebol users faces!!!"} 
	;following data are for www.rebol.org library 
	;you can find a lot of rebol script there 
	;sond doens't work on MacOS
	library: [ 
		level: 'beginner 
		platform: 'all 
		type: [tutorial demos] 
		domain: [vid gui games sound] 
		tested-under: [windows linux mac] 
		support: none 
		license: [gpl] 
		see-also: none 
		] 

]

;starts random generator
random/seed now

MAC: false ;usually people don't use MAC... :-P
if (system/version/4 = 4) [ MAC: true ] ; if we are in a MacOs, it stops sound functions.

;opening sound port to play music!!!
if MAC =  false [sound-port:  open sound:// ]

;Talk with user
print "How many users enjoy with Rebol?"
wait 1
prin "."
wait 1
prin "."
wait 1
prin "."
wait 1
print "Let's find out!"
wait 1
print " "


;checking if images and sound files exist
;otherwise download them
if not exists? %rebolusers/  [ print "Creating images folder"   make-dir %rebolusers/ ]

change-dir %rebolusers/

sito: http://www.maxvessi.net/rebsite/rebolusers

if not exists? %files.txt [   write %files.txt  (read   sito/files.txt) 	]

t_files: load %files.txt ;all files needed list

foreach item t_files [
	if not (exists? item) [
	print reform [ "Downloading" item ]
	write/binary item  (read/binary   rejoin [sito "/" item])]
	]

names: read %names.txt


if MAC = false [ 
	print "Loading music..."
	music: load %music.wav	
	;music file is short, now it become 5 times longer
	loop 5 [ append music/data music/data ]
	insert sound-port  music 
	wait 2 ;wait is foundamntal to continue working while paying sound
	]

;now we load all images and remove not image files
foto: read %.
no_foto: copy []

foreach item foto [ 
	temp: suffix? item
	if (not ( (temp = %.jpg ) or ( temp = %.gif ) ) )    [  append/only no_foto item]		
	] 
	
	
foreach item no_foto [
	while [ find foto item ] [ remove find foto item ]
	]
	
;now we create random lists
foto2:  copy random  foto 
foto3:  copy random  foto 
foto4:  copy random  foto 
foto5: copy random foto

;foto5 must be at least 1000 items to create a beautiful backgroud
append foto5 foto5
append foto5 foto5
append foto5 foto5


;configuring screen size
scr-size: 400x400
scrl: scr-size * 0x1
c1: scrl
c2: as-pair scr-size/x / 2.5 scr-size/y / 5
c3: as-pair scr-size/x - (scr-size/x / 2.5) c2/y

; functions to create background
period: does [((to-integer * 1000 now/time/precise) // 20000) / 20000]

texture: func [size /local t ][
  t: copy [origin 0 space 0]
  print "Random mixing user images"
  for i 1 size * size 1 [    
    append t compose [image 50x50 (load-image foto5/1)  ]
    prin "."
      remove foto5
    if zero? (i // size) [append t 'return]
  ]
  prin  "done" 
  to-image layout/tight t
  
]

img: texture 30

; my personal email, I wrote this way to avoid spam
miamail: rejoin [ "angerangel" "@" "gmail.com" ]

; thanks window
thanks: layout [
	vh1 "Tanks to:"
	text "Carl Sassenrath, Henrik, Graham, Nick Antonaccio, Facebook Rebol group..."
	text "... and you!"
	text "If you want to add your photo and name, send me an email"
	field miamail
	]


;main window

view/title  layout [
	origin 0	
	b: box 400x400 rate 50 feel [engage: func [face action event][
		f: face/size / 2
		p: (1.3 + sine (360 * period)) * 5
		face/effect: compose/deep [
			draw [
				transform (f) (360 * period) 1 1 0x0
				image img (f - (f * p)) (f + (f * p))
				]
			]
		show face
		]
	] 
	at 110x10		
	vh1 "WELCOME TO:"	
	testi: vh1 "" font [ valign: 'top ] para [] 200x300  rate 20  feel [engage: func [face action event][
		if  face/text = "" [face/text:  names ]
		testi/para/scroll: testi/para/scroll + 0x-1
		show testi
		]]
	at 150x350
	button logo.gif  [view/new/title thanks "Thanks to..." ]
	at 10x10
	anim 50x50  rate 5 frames  foto  
	at 10x340
	anim 50x50  rate 2 frames  foto2
	at 340x10
	anim 50x50  rate 3 frames  foto3
	at 340x340
	anim 50x50  rate 4 frames  foto4
	
] "Rebol users" 

if MAC = false [close sound-port]

