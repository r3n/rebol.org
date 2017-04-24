REBOL [
    	File: %pytagoras-thorem.r
    	Date: 25-9-2014
    	Title: "Pytagoras' theorem"
    	Purpose: {
                       User friendly interface to apply
                       the Pytagoras' theorem.
                       }
        Author: "Caridorc"
            library: [
                             level: 'beginner
                             platform: 'all
                             type: [tool]
                             domain: [Math]
                             tested-under: "Windows"
                             support: riki100024 AT gmail DOT com
                             license: CC 3.0 Attribution only
                             see-also: none
                        ]
]

view layout [
    box white 550x300 effect [
        draw [
            line-width 4
            pen blue
            line 80x210 520x210 ; C
			
			pen red
            line 80x210 80x50 ; c

			pen green
            line 80x50 520x210 ; i

                ]
        ]
	below
	across
	text "c" red font-size 25
	a: field font-size 25 200x35
	below
	across
	text "C" blue font-size 25
	b: field font-size 25 200x35
	below
	across
	text "i" leaf font-size 25
	c: field font-size 25 200x35
    below button "Calculate" font-size 25 130x35 [
	    if (a/text = "")
		    [alert join "c = " to-string (square-root (((power (to-integer c/text) 2) - (power (to-integer b/text) 2))))]
		if (b/text = "")
		    [alert join "C = " to-string (square-root (((power (to-integer c/text) 2) - (power (to-integer a/text) 2))))]
	    if (c/text = "")
		    [alert join "i = " to-string (square-root (((power (to-integer a/text) 2) + (power (to-integer b/text) 2))))]
        if (all [a/text <> "" b/text <> "" c/text <> ""])
		    [alert "Leave at least one blank"]
			]
	]