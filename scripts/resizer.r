Rebol [
Title: "Resizer" 
File: %resizer.r 
Author: "Massimiliano Vessi" 
Date: 2011-07-22 
Version: 1.2.3
email: maxint@tiscali.it 
Purpose: {Simple image resizer} 
Library: [ 
	level: 'intermediate 
	platform: 'all 
	type: [tool demo ] 
	domain: [all] 
	tested-under: [view 2.7.8.3.1 Windows Linux ] 
	support: maxint@tiscali.it 
	license: 'gpl 
	see-also: none 
	]
]


suff: "_small"



ridimensiona:  does [
	immagini: request-file	
	foreach immagine_f   immagini [ 
		immagine_i: load-image immagine_f
		temp_imm: load-image immagine_f ;we'll use this for height check		
		if x/data [
			dimensioni: immagine_i/size
			max_L: to-integer maxL/text
			if dimensioni/1 > max_L [
				fattore:  dimensioni/1 / max_L   
				temp_L:  layout/tight [ image (dimensioni / fattore) immagine_i ] 
				temp_imm: to-image temp_L ;this will be used for heigh check
				if png/data [save/png (to-file rejoin [  immagine_f  suff_f/text ".png" ]) temp_imm]
				if bmp/data [save/bmp (to-file rejoin [  immagine_f  suff_f/text ".bmp" ]) temp_imm]
				
				]
			]
		if y/data [
			dimensioni: temp_imm/size ;this way, we'll use the X resized image or the original image
			max_H: to-integer maxH/text
			if dimensioni/2 > max_H [
				fattore:  dimensioni/2 / max_H   
				temp_L:  layout/tight [ image (dimensioni / fattore) immagine_i ] 
				temp_imm: to-image temp_L				
				if png/data [save/png (to-file rejoin [  immagine_f  suff_f/text ".png" ]) temp_imm]
				if bmp/data [save/bmp (to-file rejoin [  immagine_f  suff_f/text ".bmp" ]) temp_imm]
				]
			]

		]
	alert "DONE!"	
	]	


help_L: layout [ 
	title "Help"
	text 250 {This is software aims to create small copy of the original images, resize the to smaller size.
		You can choose what dimensions use, if software should check just length or height or both.
		You can select multiple files at one time.
		You can choose the suffix to append at the new images.
		If you need further help, you can contact me:}
	text (rejoin [ "maxint" "@" "tiscali.it" ])
	]


view layout [ 
	title "THUMBNAIL GENERATOR"
	across 
	x: check true
	h4 "Max Leight:" 
	maxL: field "70"
	return
	y: check
	h4 "Max Height:" 
	maxH: field "70"
	return
	h4 "Suffix:" 
	suff_f: field suff ;ths suffix to append at the file names of thumbnail immages
	return
	h4 "Output image format:" 
	bmp: radio
	text ".bmp"
	png: radio true
	text ".png"
	return
	button "Select image(s)" [ ridimensiona ]
	btn-help [ view/new help_L ]
	]