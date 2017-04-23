REBOL[	
	Title: "coding-mailto"
	Version: 1.0.0
	File: %coding-maito.r
	Author: "Philippe Le Goff"
	Date: 11-Sep-2004
	Email: pl--legoff--free-fr
	Copyright: {
	Philippe Le Goff-2004	
	License CeCILL
	http://www.inria.fr/valorisation/logiciels/Licence.CeCILL-V1.pdf
	http://www.inria.fr/valorisation/logiciels/Licence.CeCILL-V1_VA.pdf
	}
	Purpose: {a tool for coding the "mailto" info in a html page and avoid some spam }
	Category: []
	Library: [
		level: 'beginner
		platform: 'all
		type: [tool]
		domain: [email encryption html text ]
		Tested-under: 'win
		Support: pl--legoff--free-fr
		License: none
		
	]
	Note: { 
	This tool is just for fun. 
	Write you email in the field "mailto" and click on the button "Code it ".
	Then, copy the results in your html code.
	I suggest to create a javascript file apart, with generated code.
	}
]

;/// Functions Definitions ///

prejoin: func [  
    "Reduce and join a block of values."  
    block [block!] "Values to reduce and join"  
    /with string [ string! ]  
][  
    if empty? block: reduce block [return block]  
    if with [ block: next block forskip block 2 [ insert block string ] ]  
    block: head insert head block copy ""  
    append either series? first block [copy first block] [ form first block ] next block  
]  

;/// code  ////
to-ascii: func [ "retun ASCII code of a chars string" 
	value [ char! string! ] 
	/local value-block email-string ] [
	value-block: copy []
	email-string: ""
		if (type? value) = char! [ return to-integer value]
	count: length? value
	loop count [ append value-block to-integer pick value 1 value: next value ]
	email-string: prejoin/with  value-block ","
	return email-string
]


;/// GUI Definitions ///

my-styles: stylize [
	bout: btn  gray  center middle 85x20 font-size 11 font-name "Courrier" font-color white 
	tx-inf: text ivory font-size 10 font-name "Courrier" middle center 
	field-inf: field 200x18 ivory font-size 10 font-name "Courrier" middle center 
  vtext: text white bold right middle font-size 12 font-name "Courrier" 
  a-propos-text: text 200 white font-size 11 font-name "Courrier" font-color white  
]
; ///////////

; backdrop image
img-fond: load 64#{
R0lGODlhBAEyAPEBAFxcfeDp+O/r7PD1/SH5BAEAAAEALAAAAAAEATIAAQKHhI+p
y+0Po5y02ouz3rz7D4biSJbmiabqyrbuC8fyTNf2jef6zvf+DwwKh8Si8YhMKpfM
pvMJjUqn1Kr1is1qt9yu9wsOi8fksvmMTqvX7Lb7DY/L5/S6/Y7P6/f8vv8PGCg4
SFhoeIiYqLjI2Oj4CBkpOUlZaXmJmam5ydnp+QkaKjpKylcAADs=
}

;////////////


coding-layout: func [
/local  val-text ][

val-text: to-ascii f1/text
result: rejoin [  " function NoSpmAddress() { return String.fromCharCode("  val-text  "); }" newline  "function Zap() { return String.fromCharCode(109, 97, 105, 108, 116, 111, 58) + NoSpmAddress(); }"  ]  

; here we define the layout
my-lay: layout/size [ 
	styles my-styles
	backdrop img-fond
	at 10x5
	tx-inf yellow "Code to be placed in a javascript << NoSpm.js >> file : "  
	at 15x25
	bar 400x2 yellow 
	 
	at 30x1
	str1: tx-inf 400x150 to-string result middle left 
	 
	return
	at 10x150
	tx-inf yellow "Code to be placed between the <HEAD> ... </HEAD> tags of your HTML pages"  
	at 15x170
	bar 400x2 yellow 
	at 30x175
	tx-inf {<script SRC="NoSpm.js"></script>} middle left 
	
	return
	at 10x230
	below
	tx-inf yellow "Code to be placed in your email-contact tag of your HTML pages"  
	at 15x248
	bar 400x2 yellow 
	
	return
	at 30x255
	tx-inf 350  middle left  {<a href="javascript:void(0)" onclick="this.href=Zap()">Contact me !</A> }  
	return
	at 330x290
	bout "  Close  " 40x20 124.154.220 [unview coding-layout] 

] 430x330  ;end of my-lay 

f1/text: ""

my-lay
]   ; end of coding-layout



;//// Windows "A propos" (standard) 
aPropos: func [/local lay] [
    lay: copy [
    	styles my-styles
        across origin 0x0 space 0x0
        backdrop img-fond
        image logo.gif box 200x24 
        effect [merge gradmul 1x0 0.0.0 128.128.128] return
        pad 10x10 guide
    ]
    foreach [name value] third system/script/header [
        if not none? value [
            append lay reduce [
                'vtext mold :name 'tab 'a-propos-text form value
            ]
            switch/default type?/word value [
                string! [append lay mold [with [feel: none]]]
                email! [append/only lay compose/deep [
                        alive?: true error? try [emailer/to (value)]
                    ]]
                url! [append/only lay compose/deep [
                        error? try [browse (value)]
                    ]]
                file! [append/only lay compose/deep [
                        error? try [editor (value)]
                    ]]
            ] [append lay [with [feel: none]]]
            append lay 'return
        ]
    ]
    append lay [
        pad -10x10
        box 200x24 effect [merge gradmul 1x0 128.128.128 0.0.0]
        button "Close" black [unview/only lay] edge [size: none]
    ]
view/new/title center-face lay: layout lay join system/script/header/title system/script/header/version
]



; /////// main layout ///////
lay-main: layout/tight/size [
styles my-styles
	backtile img-fond
	box 25x50  effect [merge gradmul 0x1 0.0.0 128.128.128] 
	across
	at 30x15
	tx-inf "mailto:" 
	f1: field-inf "your.mail-address@here.com" [ result: "" ]
	at 285x15
	bout "Code it !" 50x20 0.106.5 [
		view/new/title center-face coding-layout  "Code" 
	] 
	
	at 350x15
	bout "Info" 40x20 167.17.17 [aPropos] 
	at 390x15
	bout "Quit" 40x20 124.154.220 [quit] 

]  450x50
;///////////  End GUI defs ///////////////////

;///// MAIN ////
view/new center-face lay-main
do-events
