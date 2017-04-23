Rebol [
	Title: " VID: Faces and Facets"
	Date: 20-March-2010
	File: %faces.r
	Author: "François Jouen"
	Purpose: "Show Faces and Facets Values"
	Help: "none"
	library: [
        level: 'intermediate
        platform: 'all
        type: [tool] 
        domain: [gui]   
        tested-under: 'Mac OSX 'Linux 'Windows
        support: none 
        license: 'pd 
        see-also: 
   ]
]

aface: none
selected_face: none
faces_list: []
vversion: join "You are using Rebol "  [ system/product " " system/version]


notused: ["face" "blank-face" "PANEL" "ANIM" "LIST"]

;to make an image
isize: 125x300
layout compose [img: image (isize) black]
img: to-image img
loop 5000 [
    col: random 255
    pcol: to-tuple reduce [col col col]
    poke img random isize/x * isize/y (pcol)  
]

;from Volker Nitsch. Thanks for disable-face function
disable-face: func [face'] [
    if 'disabler = face'/parent-face/style [return]
    change find face'/parent-face/pane face' (
        make-face/spec get-style 'image [
            style: 'disabler
            offset: face'/offset size: face'/size
            pane: reduce [
                face'
                make system/words/face [
                    size: face'/size
                    color: font: para: text: data: image: none
                    effect: [none]
                ]
            ]
        ]
    )
    face'/offset: 0x0
    show face'/parent-face
]

Get_Face_Names: does [
	faces_list: extract system/view/vid/vid-styles 2
	; on ne traite pas "face" et "blank-face"
	faces_list: skip faces_list 2
	;sort faces_list 
]


Get_Facet_Name: does
[
	clear property/data
	show property
	liste: first aface
	forall liste [append property/data first liste]
	either 0 = length? property/data [property/sld/redrag 1]
			[property/sld/redrag property/lc / length? property/data]
	property/sld/data: 0
	show property
]

Get_Facet_Values: does
[
	clear detail/data
	p_type/text: ""
	liste2:  second aface
	s:  pick liste2 pindex
	either object? s [ ss: third s 
							p_type/text: "Object"
							n: length? ss
							for i 1 n 2 [xs: join pick ss i [ ": " pick ss i + 1 newline] append detail/data xs]] 
			                [p_type/text: type? s append detail/data mold s]	
	show [p_type detail ]
	detail/line-list: none
]

Show_Face: does [
	aface: none
	clear detail/text
	p_type/text: "Type"
	show [detail p_type]
   	if error? try 
		[; basic faces
		aface: make-face to-word selected_face
		if none? aface/text [aface/text: selected_face]
		if none? aface/color [aface/color: blue]
		if none? aface/size [aface/size: 125x25 ]
		] 
		[
		; text faces
		 aface: make-face/offset/size to-word selected_face 0x0 125x100
		 aface/text: selected_face
		] 	
		; for fun
		if found? find to-string selected_face "IMAGE" [aface/size: 125x300 aface/image: img]
		if found? find to-string selected_face "ROTARY" [aface/data: ["Option 1" "Option 2" "Option 3"]]
		if found? find to-string selected_face "TEXT-LIST" [aface/data: read %.]
		if found? find to-string selected_face "PROGRESS" [aface/size: 125x16 aface/data: 0.5]
	    visu/pane: aface
	    disable-face visu ; no action  on widgets just illustration
		show visu		
]	

no_face: does [
	clear property/data
	clear detail/data
	clear detail/text
	p_type/text: ""
	visu/pane: none
	show [p_type detail property visu]
]


Get_Face_Names

styleswin: layout [
	backdrop 160.160.220
	across
	space 5x0
	at 5x3 info 150 "Faces" left edge [size: 1x1 color: 0.0.0 ] 
	       info 150 "Facets" left edge [size: 1x1 color: 0.0.0 ]
	       p_type: info 150 "Type" edge [size: 1x1 color: 0.0.0 ]
	       info 125 "Sample" Center edge [size: 1x1 color: 0.0.0 ]	       
	at 5x30  l1: text-list 150x300 black data faces_list  [
				selected_face: l1/picked/1 
				either not found? find notused to-string selected_face [Show_Face Get_Facet_Name]
				[no_face]			
	       ] 
	property: text-list 150X300  [pindex: face/cnt Get_Facet_Values]
	space 0x0
    detail: info 134x300 wrap edge [size: 1x1 color: 0.0.0 ] sl: slider 16x300 edge [size: 1x1 color: 0.0.0 ] 
		[scroll-para  detail sl]
	pad 5 
	visu: box 127x300 center edge [size: 1x1 color: 160.160.160 ] 
	at 5x335 info 590 vversion center edge [size: 1x1 color: 0.0.0 ]	
]
view center-face styleswin
