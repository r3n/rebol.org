REBOL [
    Title: "Iconic Image Browser"
    Date: 3-Dec-2012
    Version: 2.1.1
    File: %icon-browse2.r
    Author: ["Massimiliano Vessi" "Carl Sassenrath"]
    Purpose: {Browse a directory of images using a scrolling list of icons. }  
	    library: [
        level: 'intermediate 
        platform: [all]
        type: [tool]
        domain: [GUI] 
        tested-under: [windows linux]
        support: none 
        license: none 
        see-also: none
    ]
]

 

;-- Read directory, find image files:
newset: func [] [
	flash "Creating thumbnail..."
	files: copy []
	foreach item (read %.) [
		if  find [ %.bmp %.jpg %.gif %.png ]  (suffix? item)  [ append files item  ]
		]
	temp:  copy []
	foreach item files [
		append temp compose [icon (load item) (to-string item) [
			imageb/image: copy face/pane/image  
			image-name/text: face/text
			show [imageb image-name] ]
			]
		]
	temp:  layout/tight temp
	unview 
	]

;-- Create icons from images:
newset

;global resize function:

insert-event-func [
    either event/type = 'resize [
	;resize all widgets wih one line:
	;print imageb/parent-face/size/y
	icon-list/size/y:  sc/size/y: imageb/size/y:   imageb/parent-face/size/y - 120
	imageb/size/x:   imageb/parent-face/size/x - 140
	show [icon-list sc imageb]
        none   ; return this value when you don't want to do anything else with the event.
    ][
        event  ; return this value if the specified event is not found
    ]
]


;-- Main display:
view/options layout [     
    title reform ["REBOL" system/script/header/title   system/script/header/version] 
	across
	button "Change dir..." [
			change-dir request-dir  
			newset
			icon-list/pane: temp
			sc/data: 0
			show [icon-list  sc]
			]	
	toggle "fit"	"aspect" [either face/state [ imageb/effect:  'aspect] [imageb/effect: 'fit]    
			show imageb]  
	image-name:  text 280  
	return
	icon-list:  box  70x400 edge [size: 1x1]with [pane:  temp]
	sc: slider 15x400 [
		delta: abs ( icon-list/size/y - temp/size/y)
		icon-list/pane/offset: as-pair 0 (-1 * face/data * delta) 
		show icon-list
		]
	imageb: box 400x400 main-color  		
	] [resize]