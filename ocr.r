#! /usr/bin/rebview
REBOL [
    Title: "Rebol OCR"
    Date: 16-Nov-2009
    Version: 1.0
    Author: "François Jouen"
    File: %ocr.r
    Purpose: {
        use free tesseract OCR with rebol
        The Tesseract OCR engine was one of the top 3 engines in the 1995 UNLV Accuracy test. 
        Between 1995 and 2006 it had little work done on it, but it is probably one of the most accurate open source OCR engines available. 
        The source code will read a binary, grey or color image and output text. 
        A tiff reader is built in that will read uncompressed TIFF images, or libtiff can be added to read 
        compressed images.
	    see http://code.google.com/p/tesseract-ocr/
    }
    library: [
        level: 'intermediate
        platform: 'all
        type: [tool] 
        domain: [gui]   
        tested-under: 'Mac OSX 'Linux 
        support: none 
        license: 'pd 
        see-also: 
    ]
    
]


set 'app_dir what-dir
temp_dir: join app_dir "tmp/"
if not exists? temp_dir [make-dir temp_dir]
init: join temp_dir "init.txt"
if not exists? init [write init join "/usr/local/bin/convert" newline
					write/append init join "/usr/local/bin/tesseract" newline]
tmp_tiff: join temp_dir "temp.jpg"
tmp_text: join temp_dir "temp"
csize: 320x480
prog:""
langues: ["English" "French" "Dutch" "German" "Italian" "Spanish"]
fnames: ["Times" "Arial" "Courrier"]
fsizes: ["10" "12" "14" "16" "18" "20" "22" "24" "28" "36" "48"]
ocrl: "ENG"


quit_requested: does [
	if (confirm/with "Really Quit Rebol OCR ?" ["Yes" "No"]) [quit]
]

; where are convert and  tesseract  programs (for most of unix systems)
; please adapt for windows versions
Read_Config: does [
	initfile: read/Lines init
	imconverter: initfile/1 ; ImageMagic Convert Program location e.g. "/usr/local/bin/convert"
	freeocr: initfile/2 ; Free OCR Tesseract progam location e.g. "/usr/local/bin/tesseract" 	
]


Get_Os: func [] [
	switch system/version/4 [
		3 [os: "Windows" ]
		2 [os: "Mac OSX" ]
		4 [os: "Linux" ]
		5 [os: "BeOS" ]
		7 [os: "NetBSD"]
		9 [os: "OpenBSD"]
		10 [os: "SunSolaris"]
	]
	return os
]

; process tiff file
; warning: tesseract processes tiff file with only .tif extension !
Load_tiff: does [
	tfile: request-file/filter "*.tif" 
	if error? try [ v1/image: load "" result/text: "" 
					result/line-list: none
					show [v1 result]
					; first of all converts tiff file to jpeg format 
					; since rebol does not process natively tiff 
					sbar/text: "Converting file" show sbar
					if os = "Mac OSX" [ wait 0:0:001] ; for Mac OSX only
					prog: join imconverter [" " tfile " " tmp_tiff]
					t1: now/time/precise
				    call/wait reduce [to-local-file prog]
					v1/image: load to-file tmp_tiff 
					sbar/text: "Processing file" show sbar
					; warning: tesseract asks for a result text file without extension
					; warning: tesseract adds ".txt" 
					prog: join freeocr [" " tfile " " tmp_text " -l " ocrl]
					call/wait reduce [to-local-file prog]
					;call/wait prog
					append tmp_text ".txt"
					result/text: read to-file tmp_text
					t2: now/time/precise
					show [v1 result]
					if exists? tmp_tiff [delete tmp_tiff]
					if exists? tmp_text [delete tmp_text]
					]
				 [alert "Error in loading tif file" t2: t1: now/time/precise]
	sbar/text: join "Done in " to-string (t2 - t1) show sbar
]

;save result to text file to be used with word processing for example
Save_text: does [
	txtfile: request-file/save
	if error? try [ write to-file txtfile result/text]
				  [alert "Error in saving text file"]
]

Get_Os 
Read_Config

;our main window
mwin: layout/size [
	origin 0x0
	backdrop 160.160.220
	space 0x0
	across
	at 5x5  
	text 50 "Files" font [color: navy] 
	choice 80 160.160.220 edge [size: 1x1 color: 0.0.0 ] "Open Tiff" "Save Text" "Quit"[
					switch face/text [
						"Open Tiff" [Load_tiff]
						"Save Text" [Save_Text]
						"Quit" [quit_requested]
				]
		]
			
	pad 5
	text 100 "OCR Language" font [color: navy] 
	lang: choice 80 160.160.220 edge [size: 1x1 color: 0.0.0 ] data langues [
		switch/default face/text [
			"English" [ocrl: "ENG"]
			"French" [ocrl: "FRA"]
			"German" [ocrl: "DEU"]
			"Dutch" [ocrl: "NLD"]
			"Italian" [ocrl: "ITA"]
			"Spanish" [ocrl: "SPA"]
		 ] [ocrl: "ENG"]
	 ]
	pad 5 
	text 50 "Fonts" font [color: navy] 
	choice 80 160.160.220 edge [size: 1x1 color: 0.0.0 ] data fnames [
			switch face/text [
			"Arial" [result/font/name:  font-sans-serif
				    result/line-list: none]
			"Times" [result/font/name:  font-serif 
				    result/line-list: none]
			"Courrier" [result/font/name: font-fixed 
				    result/line-list: none]
			]
		    show result
	]
	pad 5
	choice 35 160.160.220 edge [size: 1x1 color: 0.0.0 ] data fsizes
			[result/font/size: to-integer face/text show result]
		pad 5
		text 60 "Options" font [color: navy] 
		choice 80 160.160.220 edge [size: 1x1 color: 0.0.0 ] "Convert" "Tesseract" [
			switch face/text [
				"Convert" [dest: request-text/title/default "Where is Image Convert ? " to-string imconverter]
				"Tesseract" [dest: request-text/title/default "Where is OCR Tesseract ? " to-string freeocr]
			]
			; if response is <> cancel write init file
			if not none? dest [write init join "/usr/local/bin/convert" newline
					           write/append init join "/usr/local/bin/tesseract" newline] 
	]	
	at 5x35 
	v1: box white csize frame navy pad 5
	result: area wrap csize frame navy
	pad 2
	sl: slider as-pair (16) (1 + second csize) [scroll-para result sl]
	at as-pair (5) (second csize + 41) 
	sbar: box left as-pair (first csize * 1.5) (30) font [shadow: none color: navy ] frame silver
	sbar2: box center as-pair (21 + first csize * 0.5) (30) font [shadow: none color: navy] 
	       join "Version: " os frame silver 
] as-pair (32 + first csize * 2) (80 + second csize)

view/new center-face mwin


insert-event-func [
	either all [event/type = 'close event/face = MWin][
		quit_requested
	][event]
]

do-events