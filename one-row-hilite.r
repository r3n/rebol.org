                                  
REBOL [
    Title:      "Text-Lists With One Row Hi-lite "
    Date:       18-Jun-2006
    Name:       'Text-Lists With One Row Hi-lite 
    Version:    0.1.1
    File:       %one-row-hilite.r
    Author:     "R.v.d.Zee"
    Owner:      "R.v.d.Zee"
    Rights:     {Copyright (C) R.v.d.Zee 2006}
    Tabs:       4
    Purpose: {The script was written to illustrate how a single hi-lite bar can be used with a group of text-lists.  The single bar is used instead of the in-built hi-lite of the text-list style. In a group of the default text-lists, all occurrences of identical data are hi-lighted if any one of them is picked  - and so no uniform hi-lite bar can be presented.
    
    The iter co-ordinates of the picked item of the text-list locate the hi-lite bar. 
     }
    Notes: {
     The Hi-Lite Bar:
     The hi-lite bar is a transparent drawn object. When an item in any of the text-lists is picked, the position of the item (the iter/offset/y) is noted.  The bar's offset/y is set to place the bar over the entire row of the picked item.  
    
    Getting The Data:
    As the  text-list data may be moved by the scroller, the scroll number (/sn) of a text-list must be used with the picked item's offset to recover the data that is hi-lighted in the row:
    		  
		  listData:  skip listData  city/sn + (position / 27 ) * 5
		  
    - position is the picked item's iter/offset/y
    - 27 is the iter height
    - and 5, the length of a row of data in listData (city latitude longitude sunrise sunset)  
    
    }         
    
    Library: [
        level: 'beginner
        platform: 'All
        type: 'tool 
        domain: [GUI] 
        tested-under: 'Linux
        support:  none 
        license:  none 
        see-also: none
        ]    
    ]

listData: [
    "PERTH"         {-31°57'00"}  {+115°51'00"}  06:22   18:24
    "DARWIN"        {-12°27'00"}  {+130°50'00"}  06:51   18:55
    "BRISBANE"      {-27°28'00"}  {+153°01'00"}  05:53   17:55
    "HOBART"        {-42°53'00"}  {+147°17'00"}  07:17   19:17
    "HOBART"        {-42°53'01"}  {+147°17'00"}  07:17   19:18
    "MELBOURNE"     {-37°48'00"}  {+144°56'00"}  07:26   19:27
    "BROOME"        {-17°57'00"}  {+122°14'00"}  05:56   17:59
    ]


dataLength:     divide (length? listData) 5
cityData:       make block! dataLength 
latitudeData:   make block! dataLength 
longitudeData:  make block! dataLength 
sunriseData:    make block! dataLength 
sunsetData:     make block! dataLength

forskip listData 5 [
    append cityData first listData     
    append latitudeData second listData
    append longitudeData third listData
    append sunriseData fourth listData
    append sunsetData fifth listData
    ]

     ;-------- PLACE BAR OVER ROW, RECOVER AND PRESENT THE SELECTED DATA

                        ; locate the bar over the row
put-bar--get-data: func [position][
    hiLite/offset/y: position + 45
    show hiLite
                        ; re-setting the faces removes the default hi-lite
    reset-face city 
    reset-face latitude 
    reset-face longitude 
    reset-face sunrise 
    reset-face sunset
                        ; gather and present the row of picked data
        
    listData:  skip listData  city/sn + (position / 27 ) * 5 ;could be any sn city/sn, lat/sn...
    selected-row/text: rejoin [
    	listData/1 "    " listData/2 "    " listData/3 "    " listData/4 "    " listData/5
	]
    show selected-row
    listData: head listData       
    ]


oneLIne: layout [
    backcolor 183.99.0  ;olive - 60
    across
    space 0
    style labels label font-color coffee
    indent 120 labels "City"
    indent 195 labels "Latitude"
    indent 90 labels  "Longitude"
    indent 55 labels  "Sunrise"
    indent 45 labels  "Sunset"
    return
    style lists  text-list 300x200  coffee  olive  font-size 22 [put-bar--get-data face/iter/offset/y] 
    city:    lists gold olive - 10 data cityData 
    indent -16 latitude:    lists  170x200 coffee - 50 olive data latitudeData center 
    indent -16 longitude: lists coffee - 100 olive - 10 170x200 data longitudeData center 
    indent -16 sunrise:    lists 100x200 0.0.105 olive data sunriseData  
    indent -16 sunset:     lists 141.0.0 olive - 10 100x200 data sunsetData 
    indent -16  scrollAll:  scroller 16x200 brown + 50 brown [
        city/sn: latitude/sn: longitude/sn: sunrise/sn: sunset/sn: round scrollAll/data * (length? listData)
        show [city latitude longitude sunrise sunset]
    ]
    return
    selected-row: field water water 778x30 font-size 17 center
    return
    scriptArea: area 762x350 black black  font-size 18 font-color green wrap read %one-row-hilite.r
    scriptScroller: scroller 16x350  brown + 50 brown [
        scroll-para scriptArea scriptScroller
        ]
    return
    indent 740 btn "Quit" gold red [quit]
    
   ;---------------------------- TRANSPARENT HI-LITE BAR ----------------------------------------
   
    origin 20x20 hiLite: box  755x24   effect [
        draw [
            pen      222.2.155.150
	    fill-pen 222.2.155.150
            box      5x1 755x24 
            ]
        ]
    ]
                    ;-------------- END OF LAYOUT --------------
                    
                    
sunrise/iter/para/indent: sunset/iter/para/indent: 10x2
scriptArea/para/origin:   city/iter/para/indent:       20x2
scrollAll/speed: 10      ;the default is 20, this may speed up the scrolling of the text-lists 
oneLine/offset: 300x0

;----make deafult hi-lite colors similar to the background color, so they may not be noticed

city/iter/feel: make  city/iter/feel [ 
    redraw: func[f a e] bind [ 
        f/color: either find picked f/text [olive - 10] [slf/color]
        ] in city 'self
    ]

latitude/iter/feel: make  latitude/iter/feel [ 
    redraw: func[f a e] bind [ 
        f/color: either find picked f/text [olive - 10] [slf/color]
    ] in latitude 'self
    ]

longitude/iter/feel: make  longitude/iter/feel [ 
    redraw: func[f a e] bind [ 
        f/color: either find picked f/text [olive - 10] [slf/color]
        ] in longitude 'self
    ]

sunrise/iter/feel: make  sunrise/iter/feel [ 
    redraw: func[f a e] bind [ 
        f/color: either find picked f/text [olive - 10] [slf/color]
        ] in sunrise 'self
    ]

sunset/iter/feel: make  sunset/iter/feel [ 
    redraw: func[f a e] bind [ 
        f/color: either find picked f/text [olive - 10] [slf/color]
         ] in sunset 'self
    ]

;------ this function is used to remove the hi-lite when the scoller dragger is moved
;------ the movement of any scroller's dragger in the layout may also remove the hi-lite bar 
;------ using either instead of if, seems to preserve the face's function
;------ aa - has no significance, other than to complete either statement

    city/sld/dragger/FEEL/detect: func [face event] [
            either event/type <> 'move [
                hide hiLite
                ][aa: false] 
            ]
                                  view oneLIne

        