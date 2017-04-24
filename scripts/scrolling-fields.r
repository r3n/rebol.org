                                
REBOL [
    Title:        "Scrolling Fields"
    Date:        27-Mar-2006
    Name:      'Scrolling Fields
    Version:    0.1.0
    File:          %scrolling-fields.r
    Author:     "R.v.d.Zee"
    Owner:     "R.v.d.Zee"
    Rights:     {Copyright (C) R.v.d.Zee 2006}
    Tabs:       4
    Purpose: {This script illustrates the use of fields and a scroller to display  data.
                      Similar to a text-list, scrolling fields provides greater control over the  
                      presentation of data.  
                       }    
    Library: [
                    level: 'beginner
                    platform: 'Windows 
                    type: 'tutorial 
                    domain: [GUI] 
                    tested-under: none
                    support: none 
                    license: none 
                    see-also: none
    ]
    Notes: {   The data may be edited at the bottom row of fields directly above the buttons.
                     The new data presents itself in the scrolling fields - but the entry in the
                     original data (listData in this case)  is also changed.

                     The carry through of an edit to the original loaded  data works for strings,
                      but did not carry through when a time data type was used.  So all data in
                      listData are strings.  

                      Scrolling fields data may be edited and updated.                                           
   
    }
]



listData: [
    "MOUNT ISA"                    {-20°43'00"}  {+139°29'00"}  "06:47"   "18:50" 
    "TOOWOOMBA"                {-27°33'00"}  {+151°57'00"}  "05:58"   "18:00"
    "MAREEBA"                       {-16°59'00"}  {+145°25'00"}  "06:23"   "18:27"    
    "AYERS ROCK - ULURU"    {-25°20'00"}  {+131°02'00"}  "06:51"   "18:53"   
    "ADELAIDE"                      {-34°55'00"}  {+138°36'00"}  "06:22"   "18:22" 
    "PERTH"                           {-31°57'00"}  {+115°51'00"}  "06:22"   "18:24"
    "DARWIN"                        {-12°27'00"}  {+130°50'00"}  "06:51"   "18:55"
    "BRISBANE"                      {-27°28'00"}  {+153°01'00"}  "05:53"   "17:55"
    "HOBART"                        {-42°53'00"}  {+147°17'00"}  "07:17"   "19:17"
    "MELBOURNE"                  {-37°48'00"}  {+144°56'00"}  "07:26"   "19:27"
    "BROOME"                        {-17°57'00"}  {+122°14'00"}  "05:56"   "17:59"
]

dataLength: divide (length? listData) 5

gatherData: [
    cityData:          make block! dataLength 
    latitudeData:     make block! dataLength 
    longitudeData:  make block! dataLength 
    sunriseData:     make block! dataLength 
    sunsetData:      make block! dataLength
    forskip listData 5 [
        append cityData          first listData     
        append latitudeData    second listData
        append longitudeData third listData
        append sunriseData    fourth listData
        append sunsetData     fifth listData
    ]
]
do gatherData

populate:  [
        foreach face scrollingFields/pane [
            if face/style = 'city [
                face/text: first cityData
                show face
                cityData: next cityData 
            ]
            if face/style = 'latitude [
                face/text: first latitudeData
                show face
                latitudeData: next latitudeData 
            ]
            if face/style = 'longitude [
                face/text: first longitudeData
                show face
                longitudeData: next longitudeData 
            ]
            if face/style = 'sunrise [
                face/text: first sunriseData
                show face
                sunriseData: next sunriseData 
            ]
            if face/style = 'sunset [
                face/text: first sunsetData
                show face
                sunsetData: next sunsetData 
            ]
        ]
        listData: head listData
        cityData: head cityData
        latitudeData: head latitudeData
        longitudeData: head longitudeData
        sunriseData: head sunriseData
        sunsetData: head sunsetData 
    ]

    ; abbreviations for the fields: 
    ;    c for city   --  l for latitude   --   o for longitude  --   r for sunrise  --    s for sunset  

colorRow1: [
    c1/colors/1: l1/colors/1: o1/colors/1: r1/colors/1: s1/colors/1: water
    show [c1 l1 o1 r1 s1]
    edit1/text: c1/text  edit2/text: l1/text  edit3/text: o1/text  edit4/text: r1/text  edit5/text: s1/text
    show [edit1 edit2 edit3 edit4 edit5]        
]
colorRow2: [
     c2/colors/1: l2/colors/1: o2/colors/1: r2/colors/1: s2/colors/1: water
     show [c2 l2 o2 r2 s2]
     edit1/text: c2/text  edit2/text: l2/text  edit3/text: o2/text  edit4/text: r2/text  edit5/text: s2/text 
     show [edit1 edit2 edit3 edit4 edit5]           
]
colorRow3: [
    c3/colors/1: l3/colors/1: o3/colors/1: r3/colors/1: s3/colors/1: water
    show [c3 l3 o3 r3 s3]
    edit1/text: c3/text   edit2/text: l3/text  edit3/text: o3/text  edit4/text: r3/text  edit5/text: s3/text
    show [edit1 edit2 edit3 edit4 edit5]           
]
colorRow4: [
    c4/colors/1: l4/colors/1: o4/colors/1: r4/colors/1: s4/colors/1: water
    show [c4 l4 o4 r4 s4]
    edit1/text: c4/text  edit2/text: l4/text  edit3/text: o4/text  edit4/text: r4/text   edit5/text: s4/text
    show [edit1 edit2 edit3 edit4 edit5]           
]
colorRow5: [
    c5/colors/1: l5/colors/1: o5/colors/1: r5/colors/1: s5/colors/1: water
    show [c5 l5 o5 r5 s5]
    edit1/text: c5/text  edit2/text: l5/text  edit3/text: o5/text  edit4/text: r5/text  edit5/text: s5/text
    show [edit1 edit2 edit3 edit4 edit5]           
]

coloredAcross: false                    ;  a switch to improve performance, otherwise, everytime
                                                       ;  the scroller's dragger is moved, most fields would have
                                                       ;  the color changed  

unColor: [
    unfocus
    foreach face scrollingFields/pane [
        if  any [
            face/style = 'city                                  ;unColor is used to unhilight the row 
            face/style = 'latitude
            face/style = 'longitude
            face/style = 'sunrise
            face/style = 'sunset
        ][face/colors/1: olive show face]    
    ]
    coloredAcross: false
]

editData: make block! 5

hiLites: [                                                            ;determines which row to hilite
    engage: func [face action event] [ 
        if action = 'up [
            do unColor
            liteAt: to-integer remove form face/var      
            if liteAt = 1 [do colorRow1]
            if liteAt = 2 [do colorRow2]     
            if liteAt = 3 [do colorRow3]
            if liteAt = 4 [do colorRow4]
            if liteAt = 5 [do colorRow5]
           show scrollingFields/pane 
        ] 
    ]
    coloredAcross: true
]
  
scrollingFields: layout [
    size 1024x300
    backcolor coffee
    origin 20x38 box 542x146 pewter
    origin 22x40 
    style city           field  200x27 olive olive font-color green font-size 17 feel hiLites
    style latitude     field 100x27  olive olive font-color green font-size 17 feel hiLites
    style longitude  field 100x27 olive  olive font-color green font-size 17 feel hiLites
    style sunrise     field    60x27 olive  olive font-color green font-size 17 feel hiLites
    style sunset      field    60x27 olive  olive font-color green font-size 17 feel hiLites
    below
    space 0
    c1: city c2: city c3: city c4: city c5: city [print face/offset]
    return
    l1: latitude  l2: latitude  l3: latitude l4: latitude  l5: latitude
    return
    o1: longitude o2: longitude o3: longitude o4: longitude o5: longitude
    return
    r1: sunrise r2: sunrise r3: sunrise r4: sunrise r5: sunrise
    return
    s1: sunset  s2: sunset  s3: sunset  s4: sunset  s5: sunset

    origin 544x38 scrollAll: scroller 16x136 olive brown [
        unfocus
        if coloredAcross = true [do unColor]
        skipper: scrollAll/data * (length? cityData)
        cityData: skip cityData skipper
        latitudeData: skip latitudeData skipper
        longitudeData: skip longitudeData skipper
        sunriseData: skip sunriseData skipper
        sunsetData: skip sunsetData skipper 

        if (length? citydata) >= 5  [do populate]
        cityData: head cityData
        latitudeData: head latitudeData
        longitudeData: head longitudeData
        sunriseData: head sunriseData
        sunsetData: head sunsetData
    ]


    across     
    origin 40x205
    style edit  field 100x27 water water font-color green font-size 17 [
          show scrollingfields/pane
    ]
    edit1: edit 200x27 edit2: edit edit3: edit edit4: edit 60x27  edit5: edit 60x27 
    return
    across
    indent 347 
    btn silver  "Data" [do populate]
    btn silver "Update" [
        append listData ["NEW PLACE"  {-33°55'00"}  {+111°11'00"}  "00:00"   "11:00"]
        do gatherData
        do populate
    ]
    btn silver "Source" [
         clear showSource/text
         fieldCounter: 0
         forall listData  [
             either fieldCounter < 4 [
                 append showSource/text join  first listData  "^(tab)" 
                 fieldCounter: fieldCounter + 1
                 ][
                 append showSource/text join  first listData  "^/"
                 fieldCounter: 0
               ]
        ]    
        show showSource
    ] 
    btn silver "Quit" [quit]

    origin 610x38 showSource: label 400x300  green  font-size 12 top 

]

scrollingFields/offset: 0x30
s5/edge/size: 0x1
s5/edge/color: pewter

                                  view scrollingFields
        