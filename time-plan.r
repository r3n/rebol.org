REBOL [
    Title:   "Time-Plan"
    Name:    'time-plan
    File:    %time-plan.r
    
    Version: 0.4.0
    Date:    12-Mar-2006 
        
    Author:  "Christian Ensel"
    Email:   christian.ensel@gmx.de
    
    Owner:   "Christian Ensel"
    
    Purpose: {
        Time-plan RebGUI for use in time-table editing using AGG.
    }
    
    History: [
        0.4.0 12-Mar-2006 {
            - Converted VID style to a RebGUI widget.
        }
    ]
    
    Library: [
        level:    'intermediate
        platform: 'all
        type: [tool demo]
        code: 'module
        domain: [user-interface gui]
        tested-under: [
            view 1.3.2 on "WinXP"
        ]
        support: none
        license: none
        see-also: none
    ]
]

do path-thru http://www.dobeash.com/rebgui/rebgui.r

ctx-rebgui/widgets: make ctx-rebgui/widgets bind [

    time-plan: make rebface [
        
        ;==================================================== Standard Facets ==
        ;
        
        size: 25x25
        color: white
        edge: default-edge
        span: #HW
        options: compose [
            start (to date! reduce [ 1  1 now/year])
            end   (to date! reduce [31 12 now/year])
        ]
        feel: make default-feel [
            redraw: func [plan action position /local x y] [
                plan/link/days/size/x: plan/size/x - x: plan/link/rows/size/x
                plan/link/mons/size/x: plan/size/x - x: plan/link/rows/size/x
                plan/link/rows/size/y: plan/size/y - y: plan/link/days/size/y + plan/link/mons/size/y
                plan/link/clip/size:   plan/size   - as-pair x y
            ]
        ]
        
        
        ;====================================================== Widget Facets ==
        ;
        
        link: make object! [plan: bird: rows: days: mons: clip: page: note: none]
        
        day-font:    make default-font [align: 'center valign: 'middle size: 9]
        note-font:   make default-font [align: 'left   valign: 'top    size: 9]
        
        period-font: make default-font []   ;-- Used to locate the name of the 
        period-para: make default-para []   ;   edited period near the mouse arrow,
                                            ;   all other periods use the RebGUI defaults
        
        
        ;==================================================== Period Creation ==
        ;
        
        create: context [
            name:  "Unnamed"
            color: gold
            days:  4
            note:  "This is a new period."
        ]
        ;---------------------------------------------------- Period Creation --
        
        
        ;=============================================================== TOOL ==
        ;
        ;   The TOOL context assembles some widget-specific helper functions
        ;   we'll use a lot in the following code.
        ;
        
        tool: context [
            date-of:  func [face x [integer!]] [face/link/plan/options/start - 1 + round x / (3 * unit-size)]
            group-of: func [face y [integer!]] [1 + round/floor face/link/page/size/y / (5 * unit-size) * y / face/link/page/size/y]
            
            dialect: none
            
            find-period: func [page location /local id date data] [
                id: group-of page location/y
                date:     date-of  page location/x
                foreach period any [page/pane []] [
                    if all [
                        period/group/id: id
                        period/start <= date date <= period/end
                    ][
                        break/return period
                    ]
                ]
            ]
            
            make-period: func [plan [object!] spec [block!] /local period] [
                probe reduce [spec/start '- plan/options/start]
                
                period: make rebface [
                    feel:    period-feel
                    text:    copy spec/name
                    name:    copy spec/name
                    font:    default-font
                    para:    default-para
                    start:   spec/start
                    offset:  3x5 * unit-size * (as-pair spec/start - plan/options/start spec/group - 1)
                    end:     spec/end
                    group:   spec/group
                    draw:    none
                    tool:    plan/tool
                    link:    plan/link
                    size:    3x5 * unit-size * (as-pair spec/end - spec/start + 1 1)
                    color:   none
                    ink:     spec/color + 0.0.0.63
                    over?:   no
                    edit?:   no
                    tool:    none
                    link:    none
                    drag:    none
                    free:    none
                    focus-action: none
                    edit:    []
                    rate:    none
                    comment: spec/note
                ]
                ;insert tail group/data period 
                ;insert tail link/page/pane period
                ;period/feel/draw period
                        
                insert tail pick plan/data spec/group period 
                insert tail plan/link/page/pane period
                period/feel/draw period
                period
            ]
        ]
        ;--------------------------------------------------------------- TOOL --
        
        
        ;======================================================== PERIOD-FEEL ==
        ;
        ;   The PERIOD-FEEL handles all the editing of periods.
        ;
        ;   Currently one can 
        ;      - edit period's start xor end by left-clicking & dragging them or
        ;      - move periods horizontally by left-clicking & dragging them
        ;      - regroup periods vertically by right-clicking & dragging them 
        ;
        
        period-feel: make default-feel [
            
            detect: func [period event /local offset] [
                offset: event/offset - win-offset? period 
                either event/type = 'move [
                    over period within? event/offset win-offset? period period/size offset
                ][
                    if find [down alt-down alt-up up time] event/type [event]
                ]
            ]
            
            over: func [period over? offset /local edited] [
                edited: copy period/edit
                insert clear period/edit any [
                    all [          0             <= offset/x offset/x <= (period/size/x / 4)     'left ]
                    all [(period/size/x / 4 * 3) <= offset/x offset/x <=  period/size/x          'right]
                    all [(period/size/x / 4)     <  offset/x offset/x <  (period/size/x / 4 * 3) 'move ]
                    []
                ]
                if period/edit = edited [exit]
                
                if all [period/edit = edited period/over? = over?]  [exit]
                
                period/rate: either period/over?: over? [1] [
                    foreach period period/parent-face/pane [period/rate: none]
                ]
                
                draw period
                show period
            ]

            engage: func [period action event /local page clip plan bird note here] [
                page: period/parent-face
                clip: page/link/clip 
                plan: page/link/plan
                bird: page/link/bird
                note: page/link/note
                
                either action = 'time [
                    if period/over? [
                        foreach period period/parent-face/pane [period/rate: none]
                        period/rate: 1 show period
                        note/offset: -16x16 + event/offset - win-offset? page
                        note/text: rejoin [either period/name [join period/name "^/"] [""] period/start " - " period/end "^/" any [period/comment 

""]]
                        if here: find page/pane note [remove here]
                        insert tail page/pane note
                        show page
                    ]
                ][
                    if here: find page/pane note [period/over?: no remove here show page]
                ]
                
                if find [down alt-down] action [
                    ;focus period
                    
                    insert tail remove find period/parent-face/pane period period
                    
                    period/drag: event/offset
                    period/edit?: yes
                    period/free: any [
                        all [action = 'alt-down                         'y]
                        all [event/offset/x <= (period/size/x / 4)      'start]
                        all [event/offset/x >= (period/size/x / 4 * 3)  'end]
                        all [                                           'x]
                    ]
                    draw period
                    show period
                ]
                if find [up alt-up] action [
                    if period/size/x < 1 [remove find page/pane period]
                    
                    period/edit?: no 
                    period/free: none 
                    
                    draw period
                    bird/feel/draw bird
                    show [period bird]
                ] 
                if find [over away] action [
                    free: period/free
                    period/over?: action = 'over
                    any [
                        if  'x   = free [
                            period/offset/x: round/to period/offset/x + event/offset/x - period/drag/x 3 * unit-size
                        ]
                        if  'y   = free [
                            period/offset: as-pair 
                                period/offset/x ;+ event/offset/x - period/drag/x
                                round/to period/offset/y + event/offset/y - period/drag/y 5 * unit-size
                        ]
                        if 'start = free [
                            either all [0 < event/offset/x event/offset/x < period/drag/x] [
                                period/drag/x: event/offset/x
                            ][
                                old.offset: period/offset 
                                period/offset/x: round/to period/offset/x - period/drag/x + event/offset/x 3 * unit-size
                                period/size/x:   period/size/x - period/offset/x + old.offset/x
                            ]
                            if period/size/x < (3 * unit-size) [
                                period/size/x: 3 * unit-size
                            ]
                        ]
                        if 'end = free [
                            either all [period/drag/x < event/offset/x event/offset/x < period/size/x] [
                                period/drag/x: event/offset/x
                            ][
                                period/size/x: period/size/x - period/drag/x + round/to event/offset/x 3 * unit-size
                                period/drag/x: round/to event/offset/x 3 * unit-size
                            ]
                            if period/size/x < (3 * unit-size) [
                                period/offset/x: period/offset/x - (3 * unit-size)
                                period/size/x: 3 * unit-size 
                            ]
                        ]
                    ]
                    period/start: 1 + plan/tool/date-of plan period/offset/x
                    period/end:   plan/tool/date-of plan period/offset/x + period/size/x - 1
                    draw period
                    show period
                ]
            ]

            ;-- PERIOD/FEEL/DRAW: As the name suggests, DRAW in opposite to REDRAW 
            ;   is called only for drawing face changes.
            ;
            ;   REDRAW, on the other hand, only redraws what has previously been drawed.
            ;
            
            draw: func [period /local group index lo ro ru lu mm lm rm l r o u color pen fill-pen] [
                period/effect: any [period/effect copy reduce ['draw copy []]]  
                insert clear period/effect/draw compose [
           
                    ;-- Always draw a period over all previously drawn bars
                    ;
                    
                    line-width 1
                    pen black
                    fill-pen linear 0x0 0 (period/size/y - 1) 90 1 1
                             (period/ink + 0.0.0.64) (255.255.255.64)
                             (period/ink + 0.0.0.64) (period/ink + 0.0.0.32)
                             (period/ink / 2) (period/ink / 4)
                    box (lo: as-pair l: 1 o: 1)
                        (ru: as-pair r: period/size/x - 1 u: period/size/y - 1) 2
                    
                    pen      none
                    fill-pen (
                        any [
                            all [
                                none? period/free
                                period/over?
                                find period/edit 'move 
                                compose [
                                    linear (lo) 0 (r - l) 0 1 1 (period/ink * 2 + 0.0.0.255)
                                                                (period/ink * 2) (period/ink * 2) (period/ink * 2 + 0.0.0.255)
                                ]
                            ]
                            all [
                                none? period/free
                                period/over?
                                find period/edit 'left 
                                compose [
                                    linear (lo) 0 (r - l) 0 1 1 (period/ink * 2) (period/ink * 2 + 0.0.0.095)
                                                                (period/ink * 2 + 0.0.0.255) (period/ink * 2 + 0.0.0.255)
                                ]
                            ]
                            all [
                                none? period/free
                                period/over?
                                find period/edit 'right 
                                compose [
                                    linear (lo) 0 (r - l) 0 1 1 (period/ink * 2 + 0.0.0.255) (period/ink * 2 + 0.0.0.255)
                                                                (period/ink * 2 + 0.0.0.095) (period/ink * 2) 
                                ]
                            ]
                        ]
                    )
                    
                    box (lo + 1x1) (ru) 2
                    
                    ;?? Why not calculate the offset of the arrows and draw them
                    ;?? once where they should show up instead of always drawing all
                    ;?? arrows in "invisible" colors?
                    ;??
                    ;?? And why not draw the up/down arrows near mouse pointer, too?
                    
                    line-width 0.75 
                    
                    (set [pen fill-pen] all [period/free = 'start find period/edit 'left reduce [black gold]] [])
                    pen (pen) fill-pen (fill-pen)
                    
                    triangle (lm: ru - lo / 2 * 0x1 lm + 12x-3) (lm + 12x3) (lm +  6x0) 
                    triangle (lm + 14x-3) (lm + 14x3) (lm + 20x0) 
                    
                    (set [pen fill-pen] all [period/free = 'x find period/edit 'move reduce [black gold]] [])
                    pen (pen) fill-pen (fill-pen)
                    
                    triangle (mm: ru - lo / 2 + lo mm - 1x3) (mm - 1x-3) (mm - 7x0)  
                    triangle (mm + 1x3) (mm + 1x-3) (mm + 7x0)  
                   
                    (set [pen fill-pen] all [period/free = 'end find period/edit 'right reduce [black gold]] [])
                    pen (pen) fill-pen (fill-pen)
                    
                    triangle (rm: u / 2 * 0x1 + (1x0 * r) rm - 12x-3) (rm - 12x3) (rm -  6x0)  
                    triangle (rm - 14x-3) (rm - 14x3) (rm - 20x0) 
                    
                    (set [pen fill-pen] all [period/free = 'y reduce [black gold]] [])
                    pen (pen) fill-pen (fill-pen)
                    
                    triangle (mm: ru - lo / 2 + lo mm - 3x1)  (mm + 3x-1) (mm - 0x7)  
                    triangle (mm - 3x-1) (mm + 3x1)  (mm + 0x7)  
                ]    
            ]
            
        ]
        
        ;========================================================== BIRD-FEEL == 
        ;
        ;   The BIRD-FEEL currently allows for scrolling the visible clip of
        ;   the page by dragging the clip region.
        ;   It centers the clicked page location into the page clip view.
        ;
        
        bird-feel: make default-feel [
            
            redraw: func [bird action position /local scale] [
                if empty? bird/effect/2 [draw bird]
                
                scale: min bird/size/x - 6 / bird/link/page/size/x 
                           bird/size/y - 6 / bird/link/page/size/y
                           
                insert clear bird/effect/4 compose [
                    translate (bird/size - (bird/link/page/size * scale + 6x6) / 2 + 2x2) 
                    line-width 2
                    pen red fill-pen none
                    box (- bird/link/page/offset * scale) (- bird/link/page/offset + bird/link/clip/size * scale)
                ]
            ]
            
            draw: func [bird /local plan scale clip page period view] [
                plan: bird/parent-face
                clip: plan/link/clip
                page: plan/link/page
                
                clear bird/effect/draw
                
                bird/size/x: bird/link/rows/size/x
                
                scale: min bird/size/x - 6 / page/size/x 
                           bird/size/y - 6 / page/size/y
                
                insert tail clear bird/effect/draw compose [
                    translate (bird/size - (page/size * scale + 6x6) / 2 + 2x2) 
                    pen none fill-pen silver
                    box  1x1  (page/size * scale + 3x3)
                    line-width 0.75
                    pen black fill-pen white
                    box -1x-1 (page/size * scale + 1x1)
                ]
                
                foreach period page/pane [
                    insert tail bird/effect/draw compose [
                        line-width 1 pen (period/ink - 0.0.0.255)
                        line (as-pair scale * min page/size/x max      0      period/offset/x                     period/offset/y * scale)
                             (as-pair scale * max       0     min page/size/x period/offset/x + period/size/x - 1 period/offset/y * scale)
                    ]
                ]
            ]
            
            engage: func [bird action event /local center click page plan scale clip rows days mons offset] [
                plan: bird/parent-face
                page: plan/link/page
                clip: plan/link/clip
                rows: plan/link/rows
                days: plan/link/days
                mons: plan/link/mons
                
                if find [down over] action [
                    scale: min bird/size/x - 6 / page/size/x 
                               bird/size/y - 6 / page/size/y
                
                    top-left-edge: bird/size - (page/size * scale + 6x6) / 2 + 3x3 
                    center: event/offset - top-left-edge
                    
                    offset: center / scale - (clip/size / 2)
                    
                    page/offset/x: - max 0 min offset/x page/size/x - clip/size/x 
                    days/offset/x: page/offset/x + page/link/rows/size/x
                    mons/offset/x: page/offset/x + page/link/rows/size/x
                    days/size/x:   page/size/x
                    mons/size/x:   page/size/x
                    
                    page/offset/y: - max 0 min offset/y page/size/y - clip/size/y
                    rows/offset/y: page/offset/y + page/link/days/size/y + page/link/mons/size/y
                    rows/size/y:   page/size/y
                    show plan ;[bird page mons days rows]
                ]
            ]
        ]
        ;---------------------------------------------------------- BIRD-FEEL --
        
            
        ;========================================================== PAGE-FEEL == 
        ;
        ;   The PAGE-FEEL currently allows for scrolling the visible clip of
        ;   the page by alt-clicking and dragging it.
        ;
        
        page-feel: make default-feel [
            
            over: func [page over? offset /local note] [
                if note: find page/pane page/link/note [remove note show page]
            ]
            
            engage: func [page action event /local plan days mons rows bird clip period focus note] [
                plan: page/link/plan
                
                any [
                    if action = 'down [
                        either event/double-click [
                            period: plan/tool/make-period plan probe compose [
                                name  (plan/create/name) 
                                note  (plan/create/note)
                                start (plan/tool/date-of plan round/ceiling/to event/offset/x 3 * unit-size) 
                                end   (plan/create/days - 1 + plan/tool/date-of plan round/ceiling/to event/offset/x 3 * unit-size)
                                color (plan/create/color)
                                group (plan/tool/group-of plan event/offset/y)
                            ]
                            period/over?: period/edit?: true
                            insert clear period/edit 'right
                            period/drag: 1x0
                            show plan
                        ][
                            page/drag: none page/edit: event/offset
                        ]
                    ]
                    if action = 'up   []
                    if action = 'alt-down [page/edit: none page/drag: event/offset]
                    if action = 'alt-up   [page/edit: none page/drag: none]
                    if find [over away] action [
                        if page/drag [
                            page/offset: min 0x0 max (- page/size + page/link/clip/size) page/offset + event/offset - page/drag
                            page/link/days/offset/x: page/offset/x + page/link/rows/size/x
                            page/link/mons/offset/x: page/offset/x + page/link/rows/size/x
                            page/link/days/size/x:   page/size/x
                            page/link/mons/size/x:   page/size/x
                            page/link/rows/offset/y: page/offset/y + page/link/days/size/y + page/link/mons/size/y
                            page/link/rows/size/y:   page/size/y
                            show reduce [page/link/bird page/link/clip page/link/rows page/link/days page/link/mons]
                        ]
                    ]
                ]
            ]
            
        ]
        ;---------------------------------------------------------- PAGE-FEEL --
        
        
        ;=============================================================== INIT ==
        ;
        ;   
        init: func [/local plan date place names] [
            
            ;-- Creation, initialisation and linking of the sub-faces involved 
            ;
            
            plan: self
            
            link/plan: plan
            link/bird: make rebface compose [
                feel: bird-feel
                link: (link)
                offset: 0x0
                size: (  30x10  * unit-size)
                color: white
                effect: [draw [] draw []]
            ]
            link/days: make rebface compose [
                link: (link)
                offset: (30x5  * unit-size)
                size:   (1x0 * (options/end - options/start + 1) * 3 + 0x5 * unit-size)             
                color: 231.231.231
                pane: []
            ]
            link/mons: make rebface compose [
                link: (link)
                offset: (30x0  * unit-size)
                size: (1x0 * (options/end - options/start + 1) * 3 + 0x5 * unit-size)             
                color: 231.231.231
                pane: []
            ]
            link/rows: make rebface compose [
                link:   (link)
                offset: (0x10 * unit-size)
                size:   (30x100 * unit-size)             
                color:  231.231.231
                pane:   []
            ]
            link/clip: make rebface compose [
                link:   (link)
                offset: (30x10 * unit-size)
                size:   ( -30x-10 * unit-size - plan/size) 
                color:  none
            ] 
            link/page: make rebface compose/deep [
                link:   (link)
                offset: 0x0
                size:   (options/end - options/start + 1 * 3x0 + 0x100 * unit-size)      
                color:  white 
                edit:   none
                drag:   none
                feel:   page-feel
                effect: [
                    grid (0x5 * unit-size) 0x0 223.223.223 
                    grid (3x0 * unit-size) 0x0 159.159.159
                    draw []
                ]
            ]
            link/note: make rebface compose/deep [
                link:   (link)
                font:   note-font 
                offset: 0x0
                size:   (40x20 * unit-size)
                edge:   make default-edge [size: 1x1 color: black]
                color:  yellow  
                effect: [merge alphamul 223]
                edit:   none
                drag:   none
                feel:   none
            ]
            
            pane: reduce [link/days link/mons link/rows link/clip link/bird]
            
            link/clip/pane: link/page
            
            link/days/effect: reduce ['grid 3x0 * unit-size 0x0 159.159.159]
            link/mons/effect: reduce ['grid 0x5 * unit-size 0x5 * unit-size - 1 159.159.159]
            link/rows/effect: reduce ['grid 0x5 * unit-size 0x0 159.159.159]
            link/page/pane: copy []
            
           
            ;== Parse the data, set up the periods ==
            ;
            
            ;-- Row titles are extracted group names --
            ;
            
            link/page/data: copy []  ;-- Holds the PERIODs converted to OBJECTs
            
            tool/dialect: context [
                period: lo: ro: ru: lu: l: r: o: u: name: note: start: end: color: none id: 0
                grammar: [any group-rule]
                group-rule: [
                    set name string! (
                        group: make object! compose [id: (id: id + 1) name: (name) data: copy []]
                        insert tail plan/link/page/data group
                    )
                    into [any period-rule]
                ] 
                period-rule: [
                    set name string!        
                    set note opt [string! | none!] 
                    set start [pair! | date! | time!]
                    set end   [pair! | date! | time!]
                    set color [tuple! | word!] (color: do color)                 
                    (
                        period: tool/make-period plan compose [
                            name (name) note (note) start (start) end (end) color (color) group (group/id)
                        ]
                        
                    )
                ]
            ]
            
            parse data tool/dialect/grammar
            
            ;-- Group names --
            ;
            
            place: 0x0 foreach group link/page/data [
                insert link/rows/pane make rebface [
                    offset: place
                    size:   as-pair link/rows/size/x 5 * unit-size 
                    font:   default-font
                    text:   copy group/name
                ]
                place: 0x5 * unit-size + place
            ]
            
            ;-- Day numbers --
            ;
            
            for date options/start options/end 1 [insert tail names: any [names []] date/day]
            place: 0x0 foreach name names [
                insert link/days/pane make rebface [
                    text: name 
                    size: as-pair 3 * unit-size link/days/size/y 
                    font: day-font 
                    offset: place
                ]
                place: 3x0 * unit-size + place
            ]
            
            ;-- Month names --
            ;
            
            first-date: options/start
            until [
                last-date: first-date
                last-date/day:   1
                last-date/month: last-date/month + 1
                last-date/day:   last-date/day   - 1
                last-date: min last-date options/end
                
                insert tail link/mons/pane month: make rebface compose [
                    offset: (as-pair first-date - options/start * 3 * unit-size 0)
                    size:   (as-pair last-date - first-date + 1 * 3 * unit-size 5 * unit-size)
                    font:   make default-font [align: 'center]
                    text:   (pick system/locale/months first-date/month)
                ]
                month/effect: reduce ['draw copy[]]
                insert month/effect/draw compose [
                    pen (default-edge/color) fill-pen (pick reduce [colors/widget white] odd? first-date/month)
                    box 0x-1 (month/size - 0x1) 
                ]
                first-date: last-date + 1
                first-date > options/end
            ]

            ;-- Colorize saturdays, sundays and optionally supplied holidays
            ;   for easier orientation while working with the plan
            ;
            
            for date options/start options/end 1 [
                if ink: any [
                    all [select options 'holidays find options/holidays date 255.0.0.127]
                    all [date/weekday = 7 any [select options 'sundays   255.0.0.191]]
                    all [date/weekday = 6 any [select options 'saturdays 255.0.0.223]]
                ][
                    insert tail link/page/effect/draw compose [
                        pen none fill-pen (ink)
                        box (as-pair date - options/start * unit-size * 3 + 1 0)
                            (as-pair date - options/start + 1 * unit-size * 3 link/page/size/y)
                    ]
                ]
            ]
            
        ]
    ]
] in ctx-rebgui 'self



;####################################################################### Demo ##
;

job-ids: reduce [
    "Project A" red  "Project B" blue "Project C" yellow 
    "Project D" leaf "Project E" gray "Project F" gold
]

jobs: func [number /local jobs id col start end] [
    jobs: copy []
    repeat job number [
        insert tail jobs compose [
            (id: random 6 id: pick job-ids 2 * id - 1)
            (start: 31-12-2005 + random 365)
            (end: start + random 10)
            (select job-ids id)
        ]
    ]
    jobs
]

display "Time-Plan Widget" compose/only/deep [
    time-plan: time-plan 200x100 options [
        start 15/1/2006 end 27/4/2006
        holidays [
            01-01-2006 "Neujahr"
            06-01-2006 "Heilige 3 Könige" 
            27-02-2006 "Rosenmontag"
            28-02-2006 "Fastnacht"
            01-03-2006 "Aschermittwoch"
            14-04-2006 "Karfreitag"  
            16-04-2006 "Ostersonntag"
            17-04-2006 "Ostermontag" 
            01-05-2006 "Maifeiertag"  
            25-05-2006 "Christi Himmelfahrt" 
            04-06-2006 "Pfingstsonntag"
            05-06-2006 "Pfingstmontag"    
            15-06-2006 "Fronleichnam"
            15-08-2006 &quot;Mariä Himmelfahrt"
            03-10-2006 "Tag der Deutschen Einheit"
            31-10-2006 "Reformationstag"  
            01-11-2006 "Allerheiligen"
            19-11-2006 "Volkstrauertag"
            22-11-2006 "Buß- und Bettag"
            26-11-2006 "Totensonntag"
            03-12-2006 "1. Advent"
            10-12-2006 "2. Advent"
            17-12-2006 "3. Advent"
            24-12-2006 "4. Advent"
            24-12-2006 "Heiligabend"
            25-12-2006 "1. Weihnachtstag"    
            26-12-2006 "2. Weihnachtstag"
            31-12-2006 "Silvester"
        ]
    ] data [
        "Alfons" (jobs 10) 
        "Bernd"  (jobs 10) 
        "Conny"  ["RebGUI" {Design some useful widgets!} 1-2-2006 28-2-2006 255.0.0]
        "Dieter" (jobs 10) 
        "Erika"  (jobs 10) 
        "Frauke" (jobs 10) 
        "Günter" (jobs 10) 
        "Heidi"  (jobs 10) 
        "Ingo"   (jobs 10) 
        "Jürgen" (jobs 10) 
    ]
    return
    text "New bars (created by double-clicks into empty areas of the page) are created with the following attributes:"  #Y
    return
    current.name: field "Unnamed" #Y [time-plan/create/name: face/text]
    button "Color"  #Y [
        time-plan/create/color: current.color/color: any [request-color current.color/color] 
        show current.color
    ]
    current.color: box 5x5 gold #Y
    current.note: field "This is a new period." #Y [time-plan/create/note: current.note/text]
    text #Y "Days:" current.days: slider 20x5 #Y [
        current.days.value/text: mold time-plan/create/days: 1 + round face/data * 9
        show current.days.value
    ] options [arrow together 0.4444]
    current.days.value: text #Y "4  "
]
do-events


