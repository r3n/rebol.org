Rebol [
	title: "Supercalculator"
	author: "Massimiliano Vessi"
	date:  17/02/2010
	email: maxint@tiscali.it
	file: %supercalculator.r
	Purpose: {"Scientific calculator in Rebol!"}
	;following data are for www.rebol.org library
	;you can find a lot of rebol script there
	library: [ 
		level: 'beginner 
		platform: 'all 
		type: [tutorial  tool] 
		domain: [vid gui  text-processing ui user-interface scientific] 
		tested-under: [windows linux] 
		support: none 
		license: [gpl] 
		see-also: none 
		] 
	version: 3.8.23
	]

;FOREWORDS
;I wrote this scientific calculatur with only 200 lines of code (1-2 hours)!
;I used RebGUI, but I could use VID...
;but RebGui is more beautiful than VID...
;no other language make people capable of writing a scientific calculatoin 2 hours or less.
if not exists? %rebgui_218.r  [  alert "RebGUI v.218 not found, I'll try to download it."
	temp: read http://www.maxvessi.net/rebsite/rebgui_218.r
	write %rebgui_218.r temp
	notify "RebGUI v.218 correctly downloaded and saved to disk."
	]

do %rebgui_218.r


;system variabels:
conf: make object! [
 fix_digits: true  ;set fixed digit approximation (just on the screen, numbers are never really approximated)
 digits:  2  ;set number of digits if fix_digits is true
 hystory: true  ;set write history 
 hystory_data: " "
 ultimo: 0
 hystory_len: 10
 ]

;load variables from configuration file, if it exists
if exists? %.supercalculator.conf [ conf:  do load %.supercalculator.conf ]



;Here starts supercalculator script:
errore: false  ;error checking
;set background color
CTX-REBGUI/COLORS/page: 255.255.240
	
;following lines are to obtain current file version
header-script: system/script/header
version: "Version: "
append version header-script/version
	
;che i load old results hystory
either conf/hystory [
	aa: risultato2: conf/hystory_data	
	ultimo: conf/ultimo
	] [
	aa: risultato2: " "
	ultimo: 0	
	]



decimali: 0.1 ** conf/digits
; We define a function to round the values to the specified digits
troncare: func [ misura2 ]
   [
   esatto: round/to misura2 decimali
   return esatto
   ]


valuta: func [frase][	
	frase: to-string frase
	frase: trim/all frase  ;we avoid spaces
	nega: false
	
	 
	;let's check if want to reuse last result
	if (parse frase  [ ["+"|"-"|"*"|"/"|"^^" ] to end ])  [ 
		ultimo2: to-decimal ultimo 
		if ultimo2 < 0 [   ;so we avoid problems with negative numbers
			ultimo: to-string ultimo 
			insert ultimo "0"  
			nega: true
			]
		insert frase ultimo
		]
	
	replace/all frase "("  " ((( " ;so we don't mix original parentheisis with the followings
	replace/all frase ")"  " ))) " ;so we don't mix original parentheisis with the followings
	replace/all frase  "abs-"   "  abs  " ;it's tricky but necessary
	replace/all frase  "abs+"   "  abs  "
	replace/all frase "exp-"   "  exp  negate "
	replace/all frase "log-"   "  log negate  "
	replace/all frase "ln-"   "  ln negate  "
	replace/all frase "sin-"   "  sin negate  " 
	replace/all frase "cos-"   "  cos negate  "
	replace/all frase "tangent-"   "  tangent  negate "
	replace/all frase "arcs-"   "  arcs negate  " ;bad change, but necessary
	replace/all frase "arcc-"   "  arcc negate  " ;bad change, but necessary
	replace/all frase "arct-"   "  arct negate  " ;bad change, but necessary
	replace/all frase "*"  " ) * ( "
	replace/all frase "/"   " ) / ( "
	replace/all frase "+"   " )) + (( "
	replace/all frase "-"   " )) - (( "
	replace/all frase "^^"   "  **  " ;bad change, but necessary
	replace/all frase "exp"   "  exp  "
	replace/all frase "log"   "  log-10  "
	replace/all frase "ln"   "  log-e  "
	replace/all frase "sqrt"   "  square-root  " ;bad change, but necessary
	replace/all frase  "abs"   "  abs  "
	replace/all frase "sin"   "  sine  " 
	replace/all frase "cos"   "  cosine  "
	replace/all frase "tangent"   "  tangent  "
	replace/all frase "arcs"   "  arcsine  " ;bad change, but necessary
	replace/all frase "arcc"   "  arccosine  " ;bad change, but necessary
	replace/all frase "arct"   "  arctangent  " ;bad change, but necessary
	replace/all frase "e )) - (( "   "e-" ;bad change, but necessary
	insert frase " (( "
	append frase " )) "	
	
	;uncomment the following line to debug or to see what happen...	
	;print frase
	
	frase2: parse frase none ;split frase
	temp2: 0
	;transform all integers in decimal, to avoid overflow
	foreach item frase2 [
		temp2: temp2 + 1
		temp: attempt [type? do item ]		
		if temp = integer! [frase2/(reduce temp2): to-decimal frase2/(reduce temp2) ]
		]
	frase2: form frase2
	
	risultato: attempt [do frase2 ]

	if risultato = none  [  errore: true 
		risultato: 0 ]
	
	ultimo:  risultato ;the last result
	;check if user wants to round result
	if  conf/fix_digits  [  risultato: troncare risultato ]
	
	;print risultato
	;restore the origina string
	replace/all frase    "  **  " "^^"
	replace/all frase   "  arcsine  "  "arcs" 
	replace/all frase    "  arccosine  " "arcc"
	replace/all frase   "  arctangent  " "arct" 
	replace/all frase    "  square-root  " "sqrt"
	replace/all frase    "  abs  "  "abs"
	replace/all frase    "  sine  "  "sin"
	replace/all frase   "  cosine  " "cos" 
	replace/all frase    "  log-10  " "log"
	replace/all frase    "  log-e  " "ln"
	
	replace/all frase    "  exp  negate " "exp-"
	replace/all frase    "  log negate  " "log-"
	replace/all frase    "  ln negate  "  "ln-"
	replace/all frase    "  sin negate  "  "sin-"
	replace/all frase    "  cos negate  " "cos-"
	replace/all frase    "  tangent  negate " "tangent-"
	replace/all frase   "  arcs negate  "   "arcs-" 
	replace/all frase    "  arcc negate  "  "arcc-"
	replace/all frase   "  arct negate  "  "arct-" 
	
	replace/all  frase " ) " "" ;remove al simple parenthesis
	replace/all  frase " ( " "" ;remove al simple parenthesis
	replace/all  frase " (( " "" ;remove al double parenthesis
	replace/all  frase " )) " "" ;remove al double parenthesis
	replace/all frase   " ((( "  "(" ;
	replace/all frase   " ))) "  ")"
	
	
	
	pretty_frase: trim/all frase
	if nega = true [ remove pretty_frase] ;we remove the first zero added to avoid problems with negative numbers
	;riga is the separetor line
	riga: copy "-------"
	n_riga: length? pretty_frase
	for i 1 n_riga 1 [ append riga "-" ]
	
	risultato2: head risultato2
	either errore [  risultato2: insert risultato2  (reform [ "^/" pretty_frase "^/" riga "^/= " " ERROR!^/"]) ] [
		risultato2: insert risultato2  (reform [ "^/" pretty_frase "^/" riga "^/= " risultato "^/"]) 
		]
	risultato2: head risultato2
	errore: false
	;save history, if it is set on
	if  conf/hystory [
		if   conf/hystory_len > 0 [ conf/hystory_data: copy/part risultato2  (conf/hystory_len * 30) ]
		if   conf/hystory_len = 0 [ conf/hystory_data: copy risultato2 ]
		conf/ultimo: ultimo
		save %.supercalculator.conf  conf
		] 		
	return risultato2
	]



display "Supercalculator" [

	text "History:"
	return
	a_field: area 130x50 aa
	
	
	
	
	return
	text "Write expression:"
	b_field: field 100x5 [ 
		if  b_field/text = "" [ b_field/text: "0"]
		a_field/text: to-string (valuta b_field/text)
		;b_field/text: copy []
		clear-text/focus b_field
		;b_field/text: to-string b_field/text
		show [ a_field b_field]
		]
	return 
	button  yellow "1" [ append b_field/text "1"  show b_field]
	button  yellow "2" [ append b_field/text "2"  show b_field]
	button  yellow "3" [ append b_field/text "3"  show b_field]
	button   "+" [ append b_field/text "+"  show b_field]
	button   "-" [ append b_field/text "-"  show b_field]
	button "sin"   [ append b_field/text "sin"  show b_field]
	button "cos"  [ append b_field/text "cos"  show b_field]
	button "tan"  [ append b_field/text "tangent"  show b_field]
	return
	button yellow  "4" [ append b_field/text "4"  show b_field]
	button  yellow "5" [ append b_field/text "5"  show b_field]
	button  yellow "6" [ append b_field/text "6"  show b_field]
	button   "*" [ append b_field/text "*"  show b_field]
	button   "/" [ append b_field/text "/"  show b_field]
	button "asin"  [ append b_field/text "arcs"  show b_field]
	button "acos"  [ append b_field/text "arcc"  show b_field]
	button "atan"  [ append b_field/text "arct"  show b_field]
	return
	button  yellow "7" [ append b_field/text "7"  show b_field]
	button  yellow "8" [ append b_field/text "8"  show b_field]
	button yellow  "9" [ append b_field/text "9"  show b_field]
	
	button   " ^^ " [ append b_field/text "^^"  show b_field]
	button  "EE" [ append b_field/text "e"  show b_field]
	button  "log"  [ append b_field/text "log"  show b_field]	
	button  "ln" [ append b_field/text "ln"  show b_field]	
	button  "e^^"  [ append b_field/text " exp "  show b_field]	
	
	return
	button  yellow "." [ append b_field/text "."  show b_field]
	button yellow  "0" [ append b_field/text "0"  show b_field]
	button   green "=" [ 
		if  b_field/text = "" [ b_field/text: "0"] ;b_field is formula field
		a_field/text: to-string (valuta b_field/text) ;a_field is history field
		b_field/text: copy []
		b_field/text: to-string b_field/text
		show [ a_field b_field]
		]
	button red  "CC" [ b_field/text: copy []   show b_field]
	button    "SQRT" [ append b_field/text "sqrt"  show b_field]
	
	button   "(" [ append b_field/text "("  show b_field]
	button   ")" [ append b_field/text ")"  show b_field]
	
	button  "abs"   [ append b_field/text "abs"  show b_field]	
		
		
	return
	
	
	button blue "Configuration" [ 
		display "Configuration" [
			y_chk: check "Fixed decimal digits?" data conf/fix_digits [ 
			conf/fix_digits: y_chk/data 
			save %.supercalculator.conf  conf
			]
			text "Digits"
			cifredecimali: spinner options [1 15 1]  data  conf/digits [
				decimali: 0.1 ** (  cifredecimali/data )
				conf/digits: cifredecimali/data
				save %.supercalculator.conf  conf
				]
			return	
			h_chk: check "Save history?" data 	conf/hystory [ 
				conf/hystory: h_chk/data   
				save %.supercalculator.conf  conf
				]
			text "History lenght?" 	
			hyst_len: spinner options [0 1000 1] data conf/hystory_len [ 
				conf/hystory_len: hyst_len/data
				save %.supercalculator.conf  conf
				]
			return 	
			text 	"(0 means infinite history)" italic
			]
		]
	button blue "?" [ display "Help"  [ 
			heading "HELP"
			return
			text {Welcome to Supercalculator, a Scientific calculator written in Rebol.
You can use it on Windows, Linux, Mac and whatever Rebol works!
You can write directly the formulas in the field an press ENTER or press =.
You can use parethesis to write correctly the formulas. 
If you have some trouble, try to delete ".supercalculator.conf" file.
You can contact me for help: 
Massimiliano Vessi }
return link ( rejoin [ "maxint" "@" "tiscali.it"])
			return
			text  version
			return
			image logo.gif [display "my note" [text {I wrote this scientific calculatur with only 200 lines of code (1-2 hours), 
I used RebGUI, but I could use the orginal VID reducing to the original 200 lines of code,
but RebGui is more beautiful than VID...
However no other language make people capable of writing a scientific calculator in 2 hours or less.
Massimiliano Vessi}] 
				]
			]
		]	
	text version ;to visualize version	
	do [set-focus b_field]
	]

do-events
	