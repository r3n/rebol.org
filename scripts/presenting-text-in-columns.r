REBOL [
    Title: "Presenting Text In Columns"
    Date: 24-Jul-2006
    Version: 1.1.0
    File: %presenting-text-in-columns.r
    Author: "r.v.d.Zee"
    Purpose: {The script hi-lights a method of presenting text in columns.}
    Notes:   {Much of this script is derived from:  
        %guestbook.r, http://www.rebol.net/rebservices/examples.html
	Title: "REBOL/Services Guestbook Demo"
	Author: "Gabriele Santilli"
	Version: 1.1.1
}
    library: [
        level: 'beginner
        platform: 'all
        type: [reference  tool tutorial]
        domain: [text text-processing user-interface]
        tested-under: linux
        support: none
        license: none
        see-also: none
        ]
    ]

introduction: {
There are two layouts.  The text-layout is shown in the text-panel pane.
The width of the text fields determines the  width of the columns.
 
1.  Start a new layout with a new block
    - text-layout: []

2.  Add initial layout attributes 
    - append clear text-layout [backcolor coffee origin 0x0 across space 0x0] 
         (clear is used to renew the layout if needed)

3.  Add text with attributes   style, width, orientation, font-size, color and  source 
    - forskip sampleData 3 [ 
        append text-layout compose [
            row: box 520x26 (row-color)
            origin row/offset
	    text bold 120              font-size 16         (     sampleData/1)       
	    text as-is 150  right      font-size 17 blue    (form sampleData/2)             
            text as-is 180  right      font-size 16 purple  (form sampleData/3)      return 
            box 520x1 green                                                          return
	    ]
        reverse row-colors                            ;a mechanism for alternating the color
        row-color: first row-colors
        ]   
        
}

row-colors: [tan teal]
row-color: first row-colors
text-layout: []
sampleData:  [
"Kabol"	          "647,500"	"29,929,000"
"Tirane"	  "28,748"	"3,563,100"
"El Djazair"	  "2,381,740"	"32,531,900"
"Pago Pago"	"199"	        "57,880"
"Luanda	"         "1,246,700"	"11,190,800"
"The Valley"	  "102"	        "13,250"
"Saint John's"	  "443"	        "68,720"
"Buenos Aires"	"2,766,890"	"39,537,900"
"Jerevan"	"29,800"        "2,982,900"
"Oranjestad"	"193"	        "71,570"
"Canberra"	"7,686,850"     "20,090,400"
"Wien"	        "83,858"	"8,184,700"
"Baki"	        "86,600"        "7,912,000"
"Nassau"        "13,940"        "301,800"
"Al-Man mah"	"665"           "688,300"
"Dhaka"         "144,000"       "144,319,600"
"Bridgetown"     "431"          "279,300"
"Minsk"         "207,600"       "10,300,500"
"Bruxelles"     "30,510"        "10,364,400"
"Belmopan"       "22,966"       "279,500"
"Porto-Novo"     "112,620"       "7,460,000"
] 
        ; population data from http://www.citypopulation.de/

main-layout: layout [
    backcolor water
    across
    space 0x20
    h1 "Presenting Text In Columns" navy                 return
    space 0x0
    box 25x0 h3 "City"                                   box 165x0  
    h3 "Area"                                                   box 130x0
    h3 "Population"                                       return
    space 0x5 
    
    text-panel: box 520x290 text-layout coffee edge [size: 1x1 color: red] 
    
    scroller1: scroller 16x290 water - 5 water + 5 [
        text-panel/pane/offset/y:  negate value * (text-panel/pane/size/y - text-panel/size/y) 
        show text-panel
        ]
    return

    btn 80 sky "Cities" [
        append clear text-layout [backcolor coffee origin 0x0 across space 0x0] 
	 
	forskip sampleData 3 [ 
	   append text-layout compose [
               b: box 520x26 (row-color)
               origin b/offset
	       text  bold 180             font-size 16         (     sampleData/1)       
	       text as-is 120  center      font-size 17 blue    (form sampleData/2)             
               text as-is 180  right      font-size 16 purple  (form sampleData/3)      return 
               box 520x1 green                                                          return
	       ]
           reverse row-colors
           row-color: first row-colors
        ]
    
        text-panel/pane: layout text-layout
        scroller1/data: 0
        text-panel/pane/offset: 0x0
        show scroller1
        show text-panel
    ] 
    
    btn sky 80 "Script" [print read %presenting-text-in-columns.r]     
    btn sky 80 "text-panel" [
    print "^/ The contents of the text-layout: ^/"
    print mold text-layout]
    btn sky 80 "Close" [quit] 
]


                                      view  main-layout

    		


