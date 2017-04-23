REBOL [
    Library: [
        level: 'intermediate
        platform: 'all
        type: tool
        domain:  VID
        tested-under: windows XP
        support: none
        license: none
        see-also: none
        ]

    Title: "World Clock"
    Date: 22-May-2001
    Author: "Allen Kamp"
    Email: allen@rebolforces.com
    Version: 1.0.2
    File: %link-clock.r
    Purpose: {Displays times for a number of Locations.}
    Category: [view VID 2]
]

world-clock: context [
; add yourself to the list or correct the GMT entry
; "Who"  GMT
zones: [
   "Local"    now/zone 
   "REBOL HQ"    -8:00
   "Allen"       10:00
   "Andrew"      12:00 
   "Brady"       -7:00 
   "Ed"          -5:00
   "Gabriele"     1:00
   "Ladislav"     1:00 
   "Larry"       -8:00  
   "Nenad"        1:00
   "Petr"         1:00
   "Robert"       1:00 
   "Steve"       -6:00 
]


clocks: stylize [
    clock: tt "00:00:00" center with [
        local-time: time-diff: gmt: none
        rate: 1
        feel: make feel [
            engage: func [face action event i][
                    local-time: now - face/time-diff
                    i: form local-time/time 
                    if 7 > length? i [append i ":00"]
                    face/text: join local-time/date [" " i " "] 
                    show face
            ]
        ]
       init: append self/init [if not gmt [gmt: now/zone] self/time-diff: now/zone - gmt]
     ]
]

lay: copy [
    styles clocks
    backcolor coal
    space 0x1
    across 
]

width: 0
f: make face []
i: 0

; create layout block from zones data
foreach [location zone] zones [
   ; calculate width		
   f/line-list: none
   f/text: location: form location
   if width < w: first size-text f [width: w + 4]

   i: i + 1
   ccol: tcol: pick [ivory (ivory - 20.20.20)] even? i 
   append lay compose/deep [
        txt :width (form location) black (:tcol) - 35.35.35 center
        clock with [gmt: (zone)] black (:ccol) - 20.20.20 160 left return
    ]
]
]

view center-face layout world-clock/lay