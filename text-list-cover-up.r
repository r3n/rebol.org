                                
REBOL [
    Title:      "Text-List Cover Up"
    Date:      25-Mar-2006
    Name:    'Text-List Cover Up
    Version:  0.1.0
    File:        %text-list-cover-up.r
    Author:  "R.v.d.Zee"
    Owner:  "R.v.d.Zee"
    Rights:  {Copyright (C) R.v.d.Zee 2006}
    Tabs:    4
    Purpose: {This script illustrates an alternative method of displaying  text-list columns,  
                    and of providing a colored scroller to a text-list.}    
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
    Notes: {
        Overlapping text-lists are used to create the impression of a single text-list.  
        The scroll bar of the last text list is covered by a scroller.  
        The colors of the new scroller may easily be  set.
        Column & font colors and other facets may also be easily changed.

        As with all text-lists, all duplicated items in a text-list will be highlighted.
    }         
]


script: read %text-list-cover-up.r
backUp: copy script

listData: [
    "MOUNT ISA"                    {-20°43'00"}  {+139°29'00"}  06:47   18:50  
    "TOOWOOMBA"                {-27°33'00"}  {+151°57'00"}  05:58   18:00
    "MAREEBA"                       {-16°59'00"}  {+145°25'00"}  06:23   18:27    
    "AYERS ROCK - ULURU"     {-25°20'00"}  {+131°02'00"}  06:51   18:53   
    "ADELAIDE"                       {-34°55'00"}  {+138°36'00"}  06:22  18:22 
    "PERTH"                            {-31°57'00"}  {+115°51'00"}  06:22   18:24
    "DARWIN"                         {-12°27'00"}  {+130°50'00"}  06:51   18:55
    "BRISBANE"                      {-27°28'00"}  {+153°01'00"}  05:53   17:55
    "HOBART"                         {-42°53'00"}  {+147°17'00"}  07:17   19:17
    "MELBOURNE"                   {-37°48'00"}  {+144°56'00"}  07:26   19:27
    "BROOME"                        {-17°57'00"}  {+122°14'00"}  05:56   17:59
]


dataLength: divide (length? listData) 5
cityData:          make block! dataLength 
latitudeData:     make block! dataLength 
longitudeData:  make block! dataLength 
sunriseData:     make block! dataLength 
sunsetData:      make block! dataLength

forskip listData 5 [
    append cityData first listData     
    append latitudeData second listData
    append longitudeData third listData
    append sunriseData fourth listData
    append sunsetData fifth listData
]

hiLites: func [data picked][
    pickPoint: (length? data) - (length? find/only data picked)  + 1
    city/picked:           to-block mold pick  cityData pickPoint 
    latitude/picked:     to-block mold pick latitudeData pickPoint 
    longitude/picked:  to-block mold pick longitudeData pickPoint 
    sunrise/picked:     to-block pick sunriseData pickPoint 
    sunset/picked:      to-block pick sunsetData pickPoint    
    show [city latitude longitude sunrise sunset]
 
    listData: skip listData (5 *  (pickPoint - 1)) 
    oneLine/text: rejoin [listData/1 "    " listData/2 "    " listData/3 "    " listData/4 "    " listData/5]
    show oneLine
    listData: head listData       
]


coverUp: layout [
    backcolor 183.99.0 
    across
    space 0
    style labels label font-color coffee
    indent 120 labels "Place"
    indent 195 labels "Latitude"
    indent   90 labels "Longitude"
    indent   55 labels "Sunrise"
    indent   45 labels "Sunset"
    return
    style lists  text-list 300x204  coffee  olive  font-size 22 [
        hiLites face/data face/picked/1 
    ] 
    city:    lists gold olive - 10 data cityData 
    indent -16 latitude:    lists  170x204 coffee - 50 olive data latitudeData center 
    indent -16 longitude: lists coffee - 100 olive - 10 170x204 data longitudeData center 
    indent -16 sunrise:    lists 100x204 0.0.105 olive data sunriseData  
    indent -16 sunset:     lists 141.0.0 olive - 10 100x204 data sunsetData 
    indent -16  scrollAll:  scroller 16x204 brown + 50 brown [
        city/sn: latitude/sn: longitude/sn: sunrise/sn: sunset/sn: round scrollAll/data * (length? listData)
        show [city latitude longitude sunrise sunset]
    ]
    return
    oneLIne: field water water 776x30 font-size 17 center
    return
    scriptArea: area 762x350 black black  font-size 18 font-color green wrap script
    scriptScroller: scroller 16x350  brown + 50 brown [scroll-para scriptArea scriptScroller]
    return 
    btn "Copy" gold [write clipboard:// script]
    btn "Quit"   gold [quit]
]

sunrise/iter/para/indent: sunset/iter/para/indent: 10x2
scriptArea/para/origin:   city/iter/para/indent:       20x2
scrollAll/speed: 10      ;the default is 20, this may speed up the scrolling of the text-lists 

  ; - to illustrate how the hilite color may be changed -- I am uncertain of the original author 

city/iter/feel: make  city/iter/feel [ 
    redraw: func[f a e] bind [ 
        f/color: either find picked f/text [water] [slf/color]  
    ] in city 'self
 
]
                                  view coverUp

        