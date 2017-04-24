REBOL [
    Title: "Calendar and Scheduler"
    Date: 4-Jun-2001/10:20
    Version: 1.0.7   ;; correct format problem -- see discussion thread for details
    File: %calendar.r
    Author: "Sterling Newton"
    Purpose: "A simple calendar application."
    Email: sterling@rebol.com
]

cal-ctx: context [
    cal-data: either exists? %cal-sched.r [load %cal-sched.r] [copy []]
    cur-day-data: none
    
    sub-face: cal-face: dx: dy:
    size-hol: size-list: csize:
    cell-size:
    new-event?: none

    save-data: does [save %cal-sched.r cal-data]
    
    base-size: 567x446
    size-num: 20x16
    do set-base-sizes: does [
        dx: dy: to-integer base-size/x / 7
        size-hol: to-pair reduce [max dx - 20 0 16]
        size-list: to-pair reduce [dx max dx - 16 0]
        csize: dx
        cell-size: to-pair reduce [csize csize]
    ]
    base: now/date base/day: 1
    
    md: func [date] [join pick system/locale/months date/month [" " date/year]]
    update-cal: does [
        month/text: md base
        show cal-face
    ]

    sdaypan: [tmp: base if sub-num/text [tmp/day: sub-num/text show-day tmp]]
    
    sub-face: do sub-face-def: has [lay] [
        lay: layout [
            origin 0x0 space 0x0
            across
            sub-num: box bold size-num white font [size: 10 color: black style: none shadow: off] edge [size: 1x1] sdaypan
            sub-hol: text size-hol white font-size 10 sdaypan return
            sub-list: list size-list [
                across space 0x0 tinfo: txt (to-pair reduce [csize 20]) font-size (to-integer csize / 10 + 1)
            ] supply [
                either tmp: find cal-data sub-list/date [
                    tmp: tmp/2
                    count: count + sub-list/oset * 2
                    if count > length? tmp [face/show?: false exit]
                    face/show?: true
                    tinfo/text: get-ev-item tmp count info
                ] [face/show?: false exit]
            ] with [date: none oset: 0 action: sdaypan]
            at (cell-size - 8x16)
;           panel [origin 0x0 space 0x0 below
;           sub-au: arrow up 8x8
;           sub-ad: arrow down 8x8]
        ]
        lay/feel: make face/feel [
            detect: func [face act] [if act/type = 'down sdaypan act]
        ]
        lay
    ]

    
    pane-func: func [face oset /bas] [
        if pair? oset [return ((to-integer oset/y / csize) * 7) + to-integer (oset/x / csize) + 1]
        if any [none? oset oset > 42] [return none]
        sub-face/offset: to-pair reduce [(oset - 1) // 7 * csize (to-integer (oset - 1) / 7) * csize]
        bas: base
        
        either any [oset < bas/weekday (pick bas + oset - bas/weekday 2) <> base/month] [
            sub-num/text: none
            sub-num/color: gray
            sub-hol/color: gray
            sub-list/color: gray
            sub-list/date: bas + (oset - bas/weekday)
        ] [
            sub-num/text: bas/day + (oset - bas/weekday)
            sub-num/color: white
            sub-hol/color: base-color
            sub-list/color: white
            sub-list/date: bas + sub-num/text - 1
        ]
        sub-face
    ]

    iter-pane: make face [
        size: to-pair reduce [csize * 7 csize * 6]
        pane: :pane-func
        edge: none
    ]

    cal-face-def: does [layout [
        origin 0x0 space 0x0
        across
        al: arrow left [any [positive? base/month: base/month - 1 base/month: 12] update-cal]
        month: box 100.0.0 md base (to-pair reduce [7 * csize - (csize) to-integer csize / 2])
        ar: arrow right [any [13 > base/month: base/month + 1 base/month: 1] update-cal]
    ]]
    cal-face: do cal-face-def
    
    do set-main-info: does [
        sub-face: do sub-face-def
        sub-face/edge/size: 1x1
        sub-face/edge/color: black
        al/size: ar/size: 32x32
        month/size: (to-pair reduce [7 * csize - (2 * 32) - 2 32])
        month/offset: 1x0 * al/size/x
        ar/offset/x: al/size/x + month/size/x
        cal-face/size: to-pair reduce [7 * csize 6 * csize + 32]
        iter-pane/offset: 0x32
        iter-pane/size: 7x6 + to-pair reduce [csize * 7 csize * 6 + 32]
    ]
    append cal-face/pane iter-pane

    do-resize: does [
        set-base-sizes
        set-main-info
        show cal-face
    ]

    show-day: func [day] [
        dp-day/data: day
        dp-day/text: rejoin [pick system/locale/days day/weekday ", " day]
        if none? cur-day-data: find cal-data day [cur-day-data: copy []]
        if not empty? cur-day-data [cur-day-data: cur-day-data/2]
        either find system/view/screen-face/pane day-plan [
            show day-plan] [
            view/new day-plan]
            
    ]

    get-ev-item: func [list count 'word] [
        select pick list count word
    ]
    
    day-plan: layout [
        across
        dp-al: arrow left [show-day dp-day/data - 1]
        dp-day: h1 280x30 center font-size 18
        dp-ar: arrow right [show-day dp-day/data + 1] return
        dp-hol: text 300x16 black return
        m1: at dp-list: list 320x450 [
            space 0x0 across
            dp-from: txt black ivory 50x20
            dp-info: txt black ivory 270x20 [
                if dp-area/ff [
                    either tmp: find cur-day-data dp-area/time [
                        change/only next tmp compose [info (dp-area/text)]
                    ] [
                        append cur-day-data compose/deep [(dp-area/time) [info (dp-area/text)]]
                    ]
                ]
                if all [empty? dp-area/text tmp: find cur-day-data dp-area/time] [remove/part tmp 2]

                either all [cur-day-data tmp: find/tail cal-data dp-day/data] [
                    change/only tmp cur-day-data
                ] [
                    if not empty? cur-day-data [
                        append cal-data compose/deep [(dp-area/day) [(cur-day-data)]]]
                ]

                dp-area/ff: dp-info
                dp-area/day: dp-day/data
                dp-area/time: dp-from/text

                dp-area/offset: dp-list/offset + (0x22 * (dp-info/data - dp-list/oset))
                    + 50x0 + dp-list/edge/size
                dp-area/text: dp-info/text

                focus dp-area
                show [dp-area dp-list cal-face]
            ] font [colors: reduce [black black]] return
            box black 320x2
        ] supply [
            count: count + dp-list/oset
            if count > 48 [face/show?: false exit]
            face/show?: true
            dp-from/text: 0:30 * (count - 1)
            either tmp: find cur-day-data dp-from/text [
                dp-info/text: get-ev-item tmp 2 info
            ] [dp-info/text: none]

            dp-info/data: count - 1
        ] with [oset: 16 lc: to-integer 450 / 22]
        at m1 + 320x0 dp-sld: slider 16x450 [
            dp-list/oset: to-integer (48 - dp-list/lc * dp-sld/data)
            show dp-list
        ]
        return
        button "Close" [
            if dp-area/ff [dp-area/ff/action dp-area/ff none]
            save-data
            hide dp-area
            unview/only day-plan
            ]
        at m1 + (0x1 * dp-list/size / 2)
        at m1
        dp-area: area (dp-info/size - 4x0) ivory ivory edge [size: 0x0] with [show?: false ff: day: time: none]
    ]
    dp-sld/redrag dp-list/lc / (48 - dp-list/lc)
    dp-sld/data: 16 / (48 - dp-list/lc)

    event-lay: layout [
        across
        txt 37x24 middle bold "Start" ev-start: field 50 "8:00" ;ev-sampm: txt 20 "am"
        txt 37x24 middle bold "End" ev-end: field 50 "9:00" return ;ev-sampm: txt 20 "am" return
        ev-text: area 250x60 return
        button "Done" [
            dat: compose/deep [(ev-start/text) [end (ev-end/text) info (ev-text/text)]]
            either tmp: select cal-data dp-day/data [
                append tmp dat
            ] [
                append cal-data compose/deep [(dp-day/data) [(dat)]]
            ]
            save-data
            hide-popup
            show-day dp-day/data
            show cal-face
        ]
        button coal "Cancel" [unview/only event-lay]
    ]

    insert-event-func [
        if event/type = 'resize [
            base-size: cal-face/size
            do-resize
            return true
        ]
        event
    ]

    view/options cal-face [resize]
]

