rebol [
        title: "mytext"
	author: "Robert Paluch (BobikCZ)"
	copyright: "Free"
	name: "Text field(style) with dynamical changing of font size"
	date: 1-aug-2011
	purpose: { Text style which dynamically changes font-size in order to fit string to widget size }
        file: %mytext.r
]

stylize/master [
	mytext: text with [
			para/wrap?: false ;;we need unwrap 
            feel: make feel [
                redraw: func [face action pos] [
                    strsz: first size-text face	;; string size in field
                    flsz: first face/size		;; text style size 
                    ;;print [strsz flsz]
                    while [all [strsz > flsz  face/font/size > 10 ]]  [
							face/font/size: face/font/size - 1  ;;decrease font size
		                    strsz: first size-text face
		                    flsz: first face/size	
                	];;end of while
                ];;end of redraw
            ];;end of feel
	];;end of mytext
];;end of stylize

;;example for Condic :-)
view layout [
    t: mytext 100x30 font-size 20 "ABCDEEF"
    btn "add text" [
    	append t/text copy "X" 
    	show t
    ]
]