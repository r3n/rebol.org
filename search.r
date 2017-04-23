REBOL [
    Title: "Search Center"
    Date: 3-Jan-2002
    Version: 1.2.1
    File: %search.r
    Author: "Kevin Adams"
    Needs: "REBOL View"
    Purpose: {Uses various resources for various searches without having to go to their website.}
    Email: kadams@netlane.com
    Notes: {Program first written on November 4, 2001 .A little source code take from Jos Yule's Dictionary Lookup program.}
    library: [
        level: 'intermediate 
        platform: none 
        type: none 
        domain: [other-net GUI web] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
] 

about: layout [ 
 backdrop 219.219.219
 h1 "Search Center" 28.52.86
 text "Version 1.2.0"
 text "written by Kevin Adams, kadams@netlane.com" 
 button "okay" [unview] 70x20 effect [gradient 0.0.0] 
] 

win1: layout/size [ 
    backdrop 219.219.219
    h1 "Search Center" 28.52.86
    guide
    pad 20
    button "Section  One" [panels/pane: panel1  show panels] 85x20 effect [gradient 0.0.0] 
    button "Section  Two" [panels/pane: panel2  show panels] 85x20 effect [gradient 0.0.0] 
    button "About" [view/new center-face about] 85x20 effect [gradient 0.0.0] 
    button "Quit" [quit] 85x20 effect [gradient 0.0.0] 
    return
    box 2x270 28.52.86
    return
    panels: box 180x280
] 350x350 

panel1: layout [ 
        backdrop 219.219.219
across

h2 "Dictionary Search" 28.52.86
return

    word_to_lookup2: field 120 [ 
         ] 
         button "Go" 30 effect [gradient 0.0.0] [ 
                browse/only join "" [http://www.m-w.com/cgi-bin/dictionary "?book=dictionary&va=" word_to_lookup2/text] 

    ]

return
h2 "Google Search" 28.52.86
return

    word_to_lookup3: field 120 [ 
    ] 
    button "Go" 30 effect [gradient 0.0.0] [ 
        browse/only join "" ["http://www.google.com/search?q=" word_to_lookup3/text "&btnG=Google+Search"] 
]

return
h2 "Yahoo Search" 28.52.86
return

    word_to_lookup6: field 120 [ 
    ] 
    button "Go" 30 effect [gradient 0.0.0] [ 
        browse/only join "" ["http://search.yahoo.com/bin/search?p=" word_to_lookup6/text ] 
]

return
h2 "Slashdot" 28.52.86
return

    word_to_lookup1: field 120 [ 
    ] 
    button "Go" 30 effect [gradient 0.0.0] [ 
        browse/only join "" ["http://slashdot.org/search.pl?query="word_to_lookup1/text ] 
]

]

panel2: layout [
backdrop 219.219.219
across

return
h2 "Image Search" 28.52.86
return

    word_to_lookup4: field 120 [ 
    ] 
    button "Go" 30 effect [gradient 0.0.0] [ 
        browse/only join "" ["http://images.google.com/images?num=20&q=" word_to_lookup4/text "&btnG=Google+Search"] 
]

return
h2 "Usenet Search" 28.52.86
return

    word_to_lookup5: field 120 [ 
    ] 
    button "Go" 30 effect [gradient 0.0.0] [ 
        browse/only join "" ["http://groups.google.com/groups?q=" word_to_lookup5/text "&hl=&btnG=Google+Search"] 
]

return
h2 "eBay Search" 28.52.86
return

    word_to_lookup7: field 120 [ 
    ] 
    button "Go" 30 effect [gradient 0.0.0]  [ 
        browse/only join "" ["http://search.ebay.com/search/search.dll?MfcISAPICommand=GetResult&ht=1&SortProperty=MetaEndSort&query=" word_to_lookup7/text "&x=-567&y=-92"] 
]

return
h2 "Stock Quote" 28.52.86
return

    word_to_lookup8: field 120 [ 
    ] 
    button "Go" 30 effect [gradient 0.0.0] [ 
        browse/only join "" ["http://finance.yahoo.com/q?s=" word_to_lookup8/text "&d=v3"] 
]

]

    panel1/offset: 0x0
    panel2/offset: 0x0

    panels/pane: panel1

view center-face win1                                                                                                                                       