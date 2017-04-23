REBOL [
    Title: "Scripts To Change The Appearance Of Text-Lists"
    Date: 08-Mar-2008
    Version: 1.0.0
    File: %change-text-lists.r
    Author: "R.v.d.Zee"
    Owner: "R.v.d.Zee"
    Rights: "Copyright (C) R. v.d.Zee 2008 All Rights Reserved"

    Purpose: {This script is a tool that provides script writers with script that can be used to
             change the appearance of text-lists.}

    Usage: {Enter the name of your text-list in the field and select an attribute to modify.  Copy the
            displayed script with the Ctrl & C keys, and paste into your script. Some editing may be
            necessary.}

    Notes: {More changes and methods could be added to the list, and similar scripts could be written
           for other GUI objects, the scroller for example.            

           Most of the scripts included below can be found with the REBOL help command.  The change of
           color of the Highlight Bar is from an original script written in French, I have lost the
           author's name - apologies!.}

    History:   [11-Apr-2008 "Posted To Library"]

    Library: [
        level: 'beginner
        platform: 'all
        type: [demo how-to reference]
        domain: [GUI]
        support: none
        tested-under: [Rebol/View 2.7.6 [Windows]]
        license: none
    ] 
]

list-changes: [
    "Add Data" [
        clear example/data
        append example/data copy sample-data
    ]

    "Order Data - Default Tabs 40" [
        clear example/data
        foreach line sample-data [
            foreach sample line [
            list-line: []
            append list-line join sample  "^(tab)"
           ]
           append/only example/data list-line
        ]
    ]

    "Order Data - Set Tabs 80" [
        clear example/data
        example/iter/para/tabs: 80
        foreach line sample-data [
            foreach sample line [
            list-line: []
            append list-line join sample  "^(tab)"
            ]
            append/only example/data list-line
        ]
    ]

    "Order Data - Set Tabs 220" [
        clear example/data
        example/iter/para/tabs: 220
        foreach line sample-data [
            foreach sample line [
            list-line: []
            append list-line join sample  "^(tab)"
            ]
            append/only example/data list-line
        ]
    ]

    "Order Data - Script" [
        clear example/data
        example/iter/para/tabs: 40
        example/iter/font/name: "courier new" 
        longest-strings: array/initial 5 0
        sample-data2: copy/deep sample-data

        foreach entry sample-data2 [
            longest-strings/1: max longest-strings/1 (length? entry/1)
            longest-strings/2: max longest-strings/2 (length? entry/2)
            longest-strings/3: max longest-strings/3 (length? entry/3)
            longest-strings/4: max longest-strings/4 (length? entry/4)
            longest-strings/5: max longest-strings/5 (length? entry/5)
        ]
        foreach line sample-data2 [
            foreach string line [
                adds: (longest-strings/1 - (length? string))
                loop adds [append string " "]
                append string "^(tab)"
                longest-strings: next longest-strings
            ]
            longest-strings: head longest-strings
        ]
        clear example/data
        append example/data sample-data2
    ]

    "Set Dragger" [
        reset-dragger: func [list-var][
            list-var/pane/pane/2/pane/1/size/y:
            (list-var/lc / (length? list-var/data)) * (list-var/size/y - (list-var/sld/pane/2/size/y * 2))
            show list-var
        ]
        reset-face example
    ]

    "Set Dragger 2" [
        reset-dragger: func [list-var] [
            list-var/sld/redrag list-var/lc / max 1 (length? (head list-var/lines)) 
            reset-face list-var
        ]
    ]


    "Color Track"  [example/pane/pane/2/color: sky - 60]
    "Color Dragger"  [example/sld/pane/1/color:  sky -  100]
    "Color Top Clicker (up)"  [example/sld/pane/2/colors/1: sky - 130]
    "Color Top Clicker (down)"  [example/sld/pane/2/colors/2: orange]
    "Color Bottom Clicker (up)"  [example/sld/pane/3/colors/1: sky - 130]
    "Color Bottom Clicker (down)" [example/sld/pane/3/colors/2: orange]
    "Red Top Clicker Edge"  [example/sld/pane/2/edge/color: red]              
    "Red Dragger Edge"  [example/sld/pane/1/edge/color: red]
    "Red Bottom Clicker Edge" [example/sld/pane/3/edge/color: red]
    "Orange Font" [example/iter/font/color: orange]
    "Bold Font"  [example/iter/font/style: 'bold]
    "Number Lines" [
        counter: 0
        reset-face example
        reset-face example/sld
        foreach line example/data [
            counter: counter + 1
            insert/only line join counter "^(tab)"
        ]
    ]

    "Hide Numbers" [example/iter/para/indent/x: -40]

    "Plain Edge Effect" [example/sub-area/edge/effect: none]
    "Thin Edge Size" [example/sub-area/edge/size: 1x1]
    "Red Edge" [example/sub-area/edge/color: red]


    "Transparent Background" [
        example/pane/color: example/effect: 
        example/sub-area/color: example/slf/color: example/image: 
        see-chest/pane/color: see-chest/color: none
        example/text: ""
    ]

    "Image Background" [
        show changer
        example/pane/color: none
        example/sub-area/color: example/slf/color: example/effect: 
        see-chest/pane/color: see-chest/color: none
        example/text: ""
        either connected? [
            example/image: load http://www.rebol.com/view/demos/palms.jpg
        ][
            example/image: load logo.gif
        ] 
    ]

    "Fit Image" [example/effect: [fit aspect] show example "Fit Image"]

    "Gradient Background" [
        example/pane/color: none
        example/sub-area/color: example/slf/color: see-chest/pane/color: see-chest/color: none
        example/text: ""
        example/effect: [gradient 1x0 blue red]
    ]

    "Color Background Teal" [example/slf/color: teal]

    "Pattern Background" [
        example/pane/color: none
        example/sub-area/color: example/slf/color: see-chest/pane/color: see-chest/color: none
        example/text: ""
        example/effect:  [
            gradient 0x1 255.255.255 190.190.190 draw [
                pen none 
                fill-pen diagonal 237x806 0 295 6 2 6 
                160.82.45.201 0.0.0.174 160.180.160.210 44.80.132.184 255.255.255.164
                160.180.160.201 255.150.10.146 175.155.120.160 240.240.240.140 0.128.0.198
                139.69.19.199 255.255.255.163 255.205.40.189 255.164.200.169 250.240.230.220
                255.0.255.170 240.240.240.171 179.179.126.185 179.179.126.165 100.136.116.193
                box 0x0 example/size
            ]
        ]
        show example
    ]

    "Select Line 10" [example/picked: example/data/10]

    "Highlight Bar Color" [
        pick-color: 163.223.220 
        example/iter/feel: make example/iter/feel [
            redraw: func [f a e] bind [
                f/color: either find picked f/text [pick-color] [slf/color]
            ]
            in example 'self 
        ]
    ]
    
    "De-select" [example/picked: [] reset-face example] 
    "Left Hand Scroller" [
        example/sld/offset/x: 0
        example/sub-area/offset/x: 16
    ]

    "Adjust Height" [
        see-change/size/y: see-chest/size/y: example/size/y: example/sub-area/size/y: 
        example/pane/size/y: example/sld/size/y: example/pane/pane/2/pane-size/y: see-change/size/y + 5
        example/sld/pane/3/offset/y: example/sld/pane/3/offset/y + 5
    ]

    "No Scroller"  [
        example/sld/show?: false
        example/sub-area/size/x: 716
    ]

    "Arial Font"  [example/iter/font/name: "arial"]
    "Italic Font" [example/iter/font/style: 'italic]
    "Fixed Width Font"  [example/iter/font/name: "courier new"]
    "Large Font"  [example/iter/font/size: 18]
    "Large Line Height" [example/iter/size/y: 60]

    "Reset Font & Line" [
        example/iter/font/size: 12
        example/iter/size/y: 15
    ]

    "Notes"  []
]



do-list: make block! divide (length? list-changes) 2
forskip list-changes 2 [append do-list list-changes/1]

main: layout [
    size 800x710
    backdrop effect [
        gradient 0x1 255.255.255 190.190.190 draw [
            pen none 
            fill-pen cubic -354x-292 0 134 230 7 4 
            255.255.255.128 128.0.128.130 40.100.130.143
            255.255.255.139 222.184.135.157 128.128.128.137
            box 0x0 800x710
        ]
    ]
    across
    see-chest: box 700x300 green
    return
    pad 0x20
    note-pad: info 440x140 wrap font-size 14 with [
        edge/effect: none
        edge: none
        color: none
        para/margin: 10x10
        para/origin:  10x10
        effect: [
            draw [
            pen  255.255.240.190
            fill-pen 255.255.240.90
            box 0x0 438x138 16
            ]
        ]

    ]
    space 0
    pad 52
    changer: text-list 200x140 data do-list [

        change-note: func [note][
        note-pad/line-list: none
        note-pad/text: select notebook note
        show note-pad
        ]

        show-script: func [item][
            script-pad/line-list: none
            reset-face scroll-script-pad
            script-pad/text: copy form mold select list-changes item
            script-pad/text: copy form mold select list-changes item
            replace script-pad/text "see-chest/pane/color: see-chest/color: none" "" 
            example/text: "" 
            if not empty? namer/text [replace/all script-pad/text "example" namer/text]
            if (first script-pad/text) = #"[" [remove script-pad/text]
            if (last  script-pad/text) = #"]" [replace script-pad/text last script-pad/text ""]
            show script-pad
        ]

        show-script face/picked/1
        change-note face/picked/1
        change-text-list: func [a-change] [
           reduce select list-changes a-change
           show example
           see-chest/pane: see-change
           show see-chest
        ]
        change-text-list face/picked/1
    ]
    return
    pad 0x10
    script-pad:  info 685x140 font-size 14 with [
        edge/effect: none
        edge: none
        color: none
        para/margin: 10x10
        para/origin:  10x10
        effect: [
            draw [
            pen  255.255.240.190
            fill-pen 255.255.240.90
            box 0x0 683x138
            ]
        ]

    ]
    scroll-script-pad: scroller 14x140 (221.207.188 - 30)  206.192.173 [scroll-para script-pad scroll-script-pad]
    return
    pad 400x20
    namer: field silver left middle font-size 11 with [para/origin: para/margin: 2x2]
    pad 25x0
    btn "X" 206.192.173 + 40 font-color red 20x20 [quit]
    return
    pad 500
    h4 "Text-List Name" black 
]

changer/sub-area/edge/size: 1x1
changer/sub-area/edge/color: 221.207.188 - 30
changer/pane/pane/2/color: 221.207.188 - 15
changer/sld/pane/1/color:  221.207.188 - 30
changer/sld/pane/2/colors/1: changer/sld/pane/3/colors/1: 221.207.188 - 30
changer/sld/pane/1/edge/color: changer/sld/pane/2/edge/color: changer/sld/pane/3/edge/color: gold
changer/pane/color: changer/effect: changer/sub-area/color: changer/slf/color: none 
changer/text: ""

scroll-script-pad/color: 206.192.173
scroll-script-pad/pane/1/color: 191.178.158   
scroll-script-pad/pane/1/edge/color: gold
scroll-script-pad/pane/2/colors: [191.177.158  200.200.200]
scroll-script-pad/pane/3/colors: [191.177.158  200.200.200]
scroll-script-pad/pane/2/edge/color: gold
scroll-script-pad/pane/3/edge/color: gold
scroll-script-pad/edge/size: 1x0
scroll-script-pad/edge/color: ivory
scroll-script-pad/edge/effect: 'bevel


see-change: layout [
    origin 0x0
    example: text-list 700x300 data [
        "Line 1" "Line 2" "Line 3" "Line 4" "Line 5" "Line 6" "Line 7"
        "Line 8" "Line 9" "Line 10" "Line 11" "Line 12" "Line 13" "Line 14"
        "Line 15" "Line 16" "Line 17" "Line 18" "Line 19" "Line 20"
    ]
]

see-change/offset: 0x0
see-chest/pane: see-change

sample-data: [
["0200" "AUSTRALIAN NATIONAL UNIVERSITY" "ACT" "PO Boxes" "AUSTRALIAN NATIONAL UNI LPO"]
["0800" "DARWIN" "NT" "" "DARWIN DELIVERY CENTRE"]
["0801" "DARWIN" "NT" "GPO Boxes" "DARWIN DELIVERY CENTRE"]
["0804" "PARAP" "NT" "PO Boxes" "PARAP"]
["0810" "ALAWA" "NT"  "" "DARWIN DELIVERY CENTRE"]
["0810" "BRINKIN" "NT" "" "DARWIN DELIVERY CENTRE"]
["0810" "CASUARINA" "NT" "" "DARWIN DELIVERY CENTRE"]
["0810" "COCONUT GROVE" "NT" "" "DARWIN DELIVERY CENTRE"]
["0810" "JINGILI" "NT" "" "DARWIN DELIVERY CENTRE"]
["0810" "LEE POINT" "NT" "" "DARWIN DELIVERY CENTRE"]
["0810" "MILLNER" "NT" "" "DARWIN DELIVERY CENTRE"]
["0810" "MOIL" "NT" "" "DARWIN DELIVERY CENTRE"]
["0810" "MUIRHEAD" "NT" "" "DARWIN DELIVERY CENTRE"]
["0810" "NAKARA" "NT" "" "DARWIN DELIVERY CENTRE"]
["0810" "NIGHTCLIFF" "NT" "" "DARWIN DELIVERY CENTRE"]
["0810" "RAPID CREEK" "NT" "" "DARWIN DELIVERY CENTRE"]
["0810" "TIWI" "NT" "" "DARWIN DELIVERY CENTRE"]
["0810" "WAGAMAN" "NT" ""  "DARWIN DELIVERY CENTRE"]
["0810" "WANGURI" "NT" "" "DARWIN DELIVERY CENTRE"]
["0811" "CASUARINA" "NT" "PO Boxes" "CASUARINA"]
["0812" "ANULA" "NT" "" "DARWIN DELIVERY CENTRE"]
["0812" "KARAMA" "NT" "" "DARWIN DELIVERY CENTRE"]
["0812" "LEANYER" "NT" "" "DARWIN DELIVERY CENTRE"]
["0812" "MALAK" "NT" "" "DARWIN DELIVERY CENTRE"]
["0812" "MARRARA" "NT" "" "DARWIN DELIVERY CENTRE"]
["0812" "SANDERSON" "NT" "" "DARWIN DELIVERY CENTRE"]
["0812" "WULAGI" "NT" "" "DARWIN DELIVERY CENTRE"]
["0813" "SANDERSON" "NT" "PO Boxes" "SANDERSON"]
["0814" "NIGHTCLIFF" "NT" "PO Boxes" "NIGHTCLIFF"]
]

notebook: [
{}

"Add Data" {Each line of the text-list has 5 strings of data.  The strings run together because none of the 20 lines of text are formatted. The scroller dragger size is unchanged and it does not scroll the list.

The scrollers work, like the one to the right, if the length of the text-list data is equal to or greater than the number of lines of the list - when the layout was viewed.}

"Order Data - Default Tabs 40" {A tab with the default value of 40 pixels is appended to to each string of the series of 5 strings of each line.

Columns appear, but they are not evenly aligned.}

"Order Data - Set Tabs 80" {The value of the tabs are increased to 80, but not all of the columns have aligned.

The data is from the Australian Postal Codes.}

"Order Data - Set Tabs 220" {Eventually, when the tabs are about 220 across, an evenly spaced list is formed, but most of the columns appear to be quite far apart.}

"Order Data - Script" {The lines can also be formatted by:
- first changing to a font with fixed width characters,
- then finding the longest string in each column 
- increasing the length of all the shorter strings in a column
- appending all strings with a tab
}

"Set Dragger" {If no data is associated the with text-list, or if the length of the data is less than the line count,  the dragger appears to be unresponsive, even when new and longer data is later added.  

Initially assigning an array with at least as many elements as the line count will also activate the dragger.
}

"Color Top Clicker (down)" {The top clicker turns orange when clicked.  The arrow remains orange.}       

"Large Line Height" {If the font size is increased, the line height may need to be increased as well.  Increasing the line height allows the text to wrap within the line, an undesired effect in this case.}

"No Scroller" {A short list needs no scroller.  The red edge reveals that more script could be written....}

"Adjust Height" {A little untidy, the bottom line of the list was cut off. The script to change this is included, but just writing the script with the size  700x305 instead of 700x300 would do.}

"Red Track Edge" {All of the scroller component edges can be modified.  Providing an edge and color to the track can be done with   "Red Track Edge" [
        example/pane/pane/2/edge/size: 1x0
        example/pane/pane/2/edge/effect: none 
        example/pane/pane/2/edge/color: red
    ]
but...not included - all of the tracks & facets in the layouts are changed in this script.}

"Number Lines" {Numbering the lines can be useful, and can ensure that each line of the list is unique.  If two or more identical lines exist, highlighting one of them will cause all of the identical lines to be highlighted. Sequentially numbered lines are not identical, only one line can be hilighted.}

"Highlight Bar Color" {The new color is blue, the default color is a light yellow.}

"Image Background" {Downloading image from www.rebol.com

The highlight bar in the small text-list appears before the image has downloaded - but only because the line "show changer" was written before the download instruction. Otherwise, the highlight would not appear until after the image has downloaded. The delayed feedback can be ambiguous.}

"Pattern Background" {The background patterns of the script are generated by the Patterns script of the Rebol tool scripts, in the Rebol folder from the Rebol Viewtop.}

"Fit Image" {If no image appears, it must first be downloaded.  Click "Image Background"

If not connected to the internet, the in-built REBOL logo image, logo.gif,  will be loaded instead of the ocean  photo.}

"Arial Font" {Arial Font is not a fixed width font, so the column alignment has changed.}

"Notes" {Some scripts can be copied and pasted below the layout that contains the text-list. Others, however, like "Select Line 10", "De-select" or "Set Dragger" would not be written outside the layout.}

]
view main