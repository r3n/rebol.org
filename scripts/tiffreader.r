#! usr/bin/rebview
REBOL [
	File: %tiffreader.r
    Date: 2-Mar-2010
    Title: "Rebol Tiff Reader"
    Version: 1.0
    Author: "François Jouen."
    Rights: 
    Purpose: {Some examples how to use tiff lib}
    library: [
        level: 'intermediate
        platform: 'all
        type: [demo ]
        domain: [file-handling]
        tested-under: all plateforms
        support: none
        license: 'BSD
        see-also: none
	]
]

;call Tiff Library
do %tifflib.r
Show_File_Information: does [
	t1/text: join "File: " file
	t2/text: join  "Image Type: "  Image_Type
	t3/text: join "Byte Order: "  byte_order
	hsl/data: 0 nimage/text: "1"
	either  (Number_of_Pages > 1) [show [hsl nimage]][hide [hsl nimage]]
	show [t1 t2 t3 ]
	
]


Show_Image_informations: does [
	clear test/text   
	test/line-list: none
	
    append test/text Tag_List
   
     switch Image_Type [
     	"bilevel" [tvisu: make image! reduce [ to-pair compose [ (TImage/ImageWidth) (TImage/ImageLength)] image_data ]]
     	"grayscale" [tvisu: make image! reduce [ to-pair compose [ (TImage/ImageWidth) (TImage/ImageLength)] image_rgb image_data  ]]
     	"palette" [tvisu: make image! reduce [ to-pair compose [ (TImage/ImageWidth) (TImage/ImageLength)] image_rgb image_data  ]]
     	"rgb" [tvisu: make image! reduce [ to-pair compose [ (TImage/ImageWidth) (TImage/ImageLength)] image_data ]]	
 	]
    

    visu/image: copy tvisu
    im: copy tvisu
    clear visu/text
    show [test visu] 	
]



MainWin: layout [
	origin 0X0
	space 0X0
	across
	at 5x3 btn 100 "Read" [
			tiffnimage: 1
			fichier: Read_Tiff_File
			code: to-integer first fichier
			file: to-file second fichier  
			if code = 0 [Show_File_Information Show_Image_informations show bts]
    ]
    bts: btn 100 "Save As" [ Write_Tiff_File im]
    pad 5 t1: info 405
    pad 5 t2: info 155
    pad 5 t3: info 155
	at 5x30 visu: image 512x512  frame blue
	at 520x30
	test: area wrap 416x512   sl: slider 16x512 [scroll-para test sl]
	
	at 5x555 hsl: scroller 445x12  [nimage/text: to-integer  (hsl/data * (Number_of_IFD - 1)) + 1 
	 	if (TImage/compression = 1 ) [
			tiffnimage: to-integer nimage/text 
	 		show nimage
	 		if  (Number_of_Pages > 1) [ Read_Image_Data tiffnimage Show_Image_informations ]
	 			
 		]
	]
	at 460x550 nimage: info center 50 to-string Number_of_Pages
	
	
]

view/new center-face MainWin
hide [hsl bts nimage]

insert-event-func [
	either all [event/type = 'close event/face = MainWin][
		quit
	][event]
]

do-events
