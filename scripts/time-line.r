REBOL [
    Title:   "Time-Line"
    Name:    'time-line
    File:    %time-line.r
    
    Version: 0.3.1
    Date:    4-Mar-2006 
        
    Author:  "Christian Ensel"
    Email:   christian.ensel@gmx.de
    
    Owner:   "Christian Ensel"
    
    Purpose: {
        Time-line VID style for use in time-table editing using AGG.
    }
    
    History: [
        0.3.1 4-Mar-2006 {
            - With View 1.3.2 script wasn't working as expected (misplaced gradients), fixed.
            - Grabbing the two ends of a period changed from left/right third to quarter width.
        }
    ]
    
    Library: [
        level:    'intermediate
        platform: 'all
        type: [tool demo]
        code: 'module
        domain: [user-interface vid gui]
        tested-under: [
            view 1.3.1 on "WinXP" 
            view 1.3.2 on "WinXP"
        ]
        support: none
        license: none
        see-also: none
    ]
]

;===============================================================================
;REBOL [
;    title: "collect"
;    file: %collect.r
;    author: "Brett Handley"
;    email: brett@codeconscious.com
;    web: http://www.codeconscious.com
;    date: 24-Jul-2003
;    purpose: "Accumulate a repeated expression.."
;]
;-------------------------------------------------------------------------------
collect: func [
    {Collects block evaluations, use as body in For, Repeat, etc.}
    block [block!] "Block to evaluate."
    /initial result [series! datatype!] "Initialise the result."
    /only "Inserts into result using Only refinement."
] [
    if not initial [result: block!]
    result: any [all [datatype? result make result 1000] result]
    reduce ['head pick [insert insert/only] not only 'tail result to paren! block]
]
;===============================================================================


stylize/master [
    time-line: box with [
        style: 'time-line
        size: 100x100
        handle: 0x0
        color: none 
        colors: reduce [none yellow + 0.191.191]
        start:  6:00
        end:   21:00
        data:  none
        
        font: make font [name: "Tahoma" size: 8 style: shadow: none]
        
        para: make para [       ;-- Hinder View's caret to be visible if the 
            origin: -100x-100   ;   face gets the focus. 
        ]
        
        resolution:  0:30       ;-- Resolution sets the granularity of edits.
                                ;   All edits are stored on a per minute base but
                                ;   are rounded before displaying them
        
        pixel-of: func [
            "Converts a time value into it's corresponding horizontal pixel offset."
            time [time!]
        ][
            size/x - 1 * (time - start) / (end - start)       
        ]
        
        time-of: func [
            "Converts a horizontal pixel offset into it's corresponding time value."
            pixel [number!]
        ][
            pixel * (end - start) / (size/x - 1) + start
        ]
        
        edge:  none         ;-- NOT SUPPORTED!
        
        mouse: 'away            ;-- Maybe I could do without this
        
        others: 'may-hover      ;-- Two state flag telling other time-line
                                ;   faces whether the are allowed to show up
                                ;   in hovered state ('MAY-HOVER) or 
                                ;   not ('NEED-NOT-HOVER).
                                
        edit:  none             ;-- Holds flags 'START and 'END, telling
                                ;   whether to resize a period at either it's
                                ;   start or end or to move it
                                
        active-period:    none
        
        selected-periods: none  ;-- Block holding all selected period objects
                                ;   for multi-edits
        
        words: [
            periods [                   
                new/data: second args       ;-- Period descriptions will be dialected
                next args                   ;   and converted to objects internally.
            ]
            range [
                new/start: first second args
                new/end:   second second args
                next args
            ]
        ]
        
        drawings: none      ;-- The context where all the drawings for
                            ;   grid, periods, selected-periods and the cursor
                            ;   are kept (initialised in the INIT block).
            
        draw: context [
            
            grid: func ["Draws the hourly, half and quarterly grid." face [object!]] [
                face/drawings/grid: any [face/drawings/grid copy []]
                insert clear face/drawings/grid for time face/start face/end 1:00 collect [
                    compose [
                        pen (face/color / 8)
                        line-width 0.5
                        line (as-pair face/pixel-of time 0) 
                             (as-pair face/pixel-of time face/size/y)
                        pen (face/color / 4)
                        line-width 0.25 
                        line (as-pair face/pixel-of time + 0:30 0) 
                             (as-pair face/pixel-of time + 0:30 face/size/y)
                        pen (face/color / 2)
                        line-width 0.125
                        line (as-pair face/pixel-of time + 0:15 0) 
                             (as-pair face/pixel-of time + 0:15 face/size/y)
                        line (as-pair face/pixel-of time + 0:45 0) 
                             (as-pair face/pixel-of time + 0:45 face/size/y)
                    ]
                ]
            ]
            
            periods: func [face [object!] /local start end] [
                face/drawings/periods: any [face/drawings/periods copy []]
                if empty? face/data [clear face/drawings/periods return]
                
                insert clear face/drawings/periods foreach period face/data collect [
                    start: round/to period/start face/resolution 
                    end:   round/to period/end   face/resolution
                    compose [
                        line-width 0,66
                        pen (black)
                        fill-pen linear 0x0 0 (face/size/y - 2) 90 1 1 (period/color + 0.0.0.64) 
                                                                       (255.255.255.64)
                                                                       (period/color + 0.0.0.64) 
                                                                       (period/color + 0.0.0.32)
                                                                       (period/color / 2)
                                                                       (period/color / 4)
                        box (as-pair face/pixel-of start 3)
                            (as-pair face/pixel-of   end face/size/y - 4) (period/radius)
                        pen black fill-pen white 
                        font (font)
                        text (copy/part skip tail join "0" mold start -5 5)
                             (as-pair   3 + face/pixel-of start face/size/y / 2 - 5)
                        text (copy/part skip tail join "0" mold   end -5 5)
                             (as-pair -21 + face/pixel-of   end face/size/y / 2 - 5)
                        
                    ]
                ]
            ]
        
            grip: func [
                "Draws the grip." face /local period fill start start? end end? width color
            ][
                face/drawings/grip: any [face/drawings/grip copy []]
                
                if none? period: face/active-period [
                    clear face/drawings/grip
                    return
                ] 
                
                start: round/to period/start face/resolution 
                end:   round/to period/end   face/resolution                 
                width: (face/pixel-of end) - (face/pixel-of start)
                color: period/color / 4 - 0.0.0.255 + 0.0.0.127 ;period/color
                ;color: gold + 0.0.0.127
                
                start?: found? find period/edit 'start? 
                end?:   found? find period/edit 'end?   
                
                fill: compose any [
                    if all [start? end?] [
                        ;[fill-pen linear (as-pair face/pixel-of start 0) (face/pixel-of start) (width) 0 1 1 (color + 0.0.0.127) (color) (color + 0.0.0.127)] ; + 0.0.0.255) (color + 0.0.0.127) (color + 0.0.0.63) (color) (color + 0.0.0.63) (color + 0.0.0.127) (color + 0.0.0.255)]
                        [fill-pen linear (as-pair face/pixel-of start 0) 0 (width) 0 1 1 (color + 0.0.0.255) (color) (color) (color + 0.0.0.255)]
                    ]
                    if start? [
                        ;[fill-pen linear (as-pair face/pixel-of start 0) (face/pixel-of start) (width) 0 1 1 (color) (color + 0.0.0.63) (color + 0.0.0.127) (color + 0.0.0.255)]
                        [fill-pen linear (as-pair face/pixel-of start 0) 0 (width) 0 1 1 (color) (color + 0.0.0.127) (color + 0.0.0.255) (color + 0.0.0.255)]
                    ]
                    if end? [
                        ;[fill-pen linear (as-pair face/pixel-of start 0) (face/pixel-of start) (width) 0 1 1 (color + 0.0.0.255) (color + 0.0.0.127) (color + 0.0.0.63) (color)]
                        [fill-pen linear (as-pair face/pixel-of start 0) 0 (width) 0 1 1 (color + 0.0.0.255) (color + 0.0.0.255) (color + 0.0.0.127) (color)]
                    ]
                ]
                    
                insert clear face/drawings/grip compose [
                    line-width 1 
                    pen black fill-pen (fill)
                    box (as-pair face/pixel-of start 3)
                        (as-pair face/pixel-of end   face/size/y - 4) (period/radius)
                ]
            ]
            
            cursor: func [
                "Draws the cursor."
                face [object!] offset [integer! none!] /local period time color
            ][
                color: navy ; + 0.0.0.63
                
                face/drawings/cursor: any [face/drawings/cursor copy []]
                clear face/drawings/cursor
                
                if any [
                    none? offset
                    face/active-period: face/feel/period? face offset
                ][
                    return
                ]
                
                time: round/to face/time-of offset face/resolution 
                insert face/drawings/cursor compose [
                    pen (color) line-width 3
                    line (as-pair face/pixel-of time 0) (as-pair face/pixel-of time face/size/y)
                    pen black
                    font (face/font)
                    text (copy/part skip tail join "0" mold round/to time 0:01 -5 5) (as-pair  -9 + face/pixel-of time face/size/y / 2 - 5)
                ]

            ]
            
            selected-periods: func [face /local start end color] [
                face/drawings/selected-periods: any [face/drawings/selected-periods copy []]
                
                clear face/drawings/selected-periods
                
                if empty? face/selected-periods [return]
                
                
                
                color: navy ;+ 0.0.0.63
                
                insert clear face/drawings/selected-periods foreach period face/selected-periods collect [
                    start: round/to period/start face/resolution 
                    end:   round/to period/end   face/resolution
                    compose [
                        line-width 3
                        pen (color) fill-pen none 
                        box (as-pair -2 + face/pixel-of start 1)
                            (as-pair +2 + face/pixel-of end   face/size/y - 2) (period/radius + 3)
                    
                        (
                            compose either find period/edit 'start [
                                [
                                    pen none fill-pen (color)
                                    triangle (as-pair -3 + face/pixel-of start 0)
                                             (as-pair -3 + face/pixel-of start face/size/y)
                                             (as-pair - face/size/y / 2 - 3 + face/pixel-of start face/size/y / 2)
                                ]
                            ][[]]
                        )
                        (
                            compose either find period/edit 'end [
                                [
                                    pen none fill-pen (color)
                                    triangle (as-pair 4 + face/pixel-of end 0) ;face/size/y - 1 / 3)
                                             (as-pair 4 + face/pixel-of end face/size/y)
                                             (as-pair face/size/y / 2 + 4 + face/pixel-of end face/size/y / 2)
                                ]
                            ][[]]
                        )
                    ]
                ]
            ]
        ]
        
        feel: make feel [
            
            redraw: func [face action offset] [
                either face <> system/view/focal-face [
                    face/color: face/colors/1
                    clear face/drawings/selected-periods
                ][
                    face/color: face/colors/2
                ]
                face/drawings/grid
            ]
            
            edit: func [
                "Determines the edit mode for the active period." face offset 
            /local
                period start end quarter
            ][
                if none? period: face/active-period [return]
                start: face/pixel-of round/to period/start face/resolution 
                end:   face/pixel-of round/to period/end   face/resolution                 
                quarter: end - start / 4
                any [
                    if all [start <= offset offset <= (start + quarter)] [
                        edit-end/data: off edit-start/data: on ;#####
                        remove find period/edit 'start?
                        remove find period/edit 'end?
                        insert period/edit 'start?
                    ]
                    if all [end - quarter <= offset offset <= end] [
                        edit-start/data: off edit-end/data: on ;#####
                        remove find period/edit 'start?
                        remove find period/edit 'end?
                        insert period/edit 'end?
                    ]
                    do [   
                        edit-start/data: edit-end/data: on ;#####
                        remove find period/edit 'start?
                        remove find period/edit 'end?
                        insert period/edit [start? end?]
                    ]
                ]
                show [edit-start edit-end] ;#####
            ]
            
            period?: func [face offset [pair! time! number! none!] /all] [
                if none? offset [return none]
                offset: switch type?/word offset [
                    integer! [face/time-of offset]
                    decimal! [face/time-of offset]
                    pair!    [face/time-of offset/x]
                    time!    [offset]
                ]
                foreach period face/data [
                    if (period/start < offset) and (offset < period/end) [break/return period]  
                ] 
            ]
            
            over: func [face over? offset] [
                face/selected-periods: any [face/selected-periods copy []]
                
                ;-- Don't hover time-line if we're editing another
                ;
                if all [
                    system/view/focal-face
                    get in system/view/focal-face 'style 
                    system/view/focal-face/style = 'time-line
                    system/view/focal-face <> face
                    system/view/focal-face/others = 'need-not-hover
                ][
                    return
                ] 
                
                offset: offset - win-offset? face   ;-- Remember, offset argument is relative to window here!
                face/feel/edit face offset/x
                
                face/mouse: pick [over away] over?
                
                face/draw/selected-periods face
                face/draw/grip face
                face/draw/cursor face offset/x
                if not over? [
                    clear face/drawings/cursor
                    clear face/drawings/grip
                ]
                
                show face
            ]
            
            engage: func [face action event /local delta swap edit offset] [
                shift-key/data: event/shift show shift-key
                control-key/data: event/control show control-key
                
                offset: event/offset - win-offset? face   ;-- Remember, offset argument is relative to window here!
                
                face/selected-periods: any [face/selected-periods copy []]
                if action = 'key [
                    if event/key = #"^[" [
                        foreach period face/selected-periods [
                            clear period/edit
                        ]
                        clear face/selected-periods
                    ]
                    if event/key = #"^A" [
                        insert clear face/selected-periods face/data
                        foreach period face/selected-periods [
                            insert clear period/edit [start end]
                        ]
                    ]
                    if event/key = 'up [
                        foreach period face/selected-periods [
                            insert clear period/edit 'start
                            if any [event/shift event/control] [
                                insert period/edit 'end
                            ]
                        ]
                    ]
                    if event/key = 'down  [
                        foreach period face/selected-periods [
                            insert clear period/edit 'end
                            if any [event/shift event/control] [
                                insert period/edit 'start
                            ]
                        ]
                    ]
                    if event/key = #"^M" [
                        clear face/selected-periods 
                        face/active-period: none
                    ]
                    if find [left right] event/key [
                        delta: face/resolution * select [left -1 right +1] event/key
                        foreach period face/selected-periods [
                            if find period/edit 'start [period/started: period/start: period/start + delta]
                            if find period/edit 'end   [period/ended:   period/end:   period/end + delta]
                            if period/start > period/end [
                                ;set bind [start end] in period 'self reduce bind [end start] in period 'self
                                swap: period/start period/start: period/end period/end: swap 
                                alter period/edit 'start
                                alter period/edit 'end
                                edit-start/data: not edit-start/data ;#####
                                edit-end/data: not edit-end/data ;#####
                                show [edit-start edit-end]
                            ]
                        ]
                    ]
                ]
                
                if find [over away] action [
                    foreach period face/selected-periods [
                        delta: (face/time-of event/offset/x - face/handle/x) - face/start
                        if find period/edit 'start [
                            period/start: round/to period/started + delta face/resolution
                        ]
                        if find period/edit 'end [
                            period/end: round/to period/ended + delta face/resolution
                        ]
                        if period/end < period/start [
                            swap: period/start period/start: period/end period/end: swap 
                            alter period/edit 'start
                            alter period/edit 'end
                            edit-start/data: not edit-start/data ;#####
                            edit-end/data: not edit-end/data ;#####
                            show [edit-start edit-end]
                        ]
                    ]
                    ;face/handle: event/offset
                    face/mouse: action
                ]
                
                if find [down alt-down] action [
                    if face <> system/view/focal-face [focus/no-show face]
                    either face/active-period [
                        remove find face/active-period/edit 'start
                        remove find face/active-period/edit 'end
                    ][
                        either not event/double-click [
                            clear face/selected-periods
                        ][
                            insert tail face/data face/active-period: make object! compose [
                                type:   'unknown 
                                started: start:  round/to face/time-of event/offset/x face/resolution
                                ended:   end:    round/to face/resolution + face/time-of event/offset/x face/resolution
                                color:  0.0.0.31 + random white 
                                radius: -1 + random 16
                                edit:   copy [end?]
                            ]
                        ]
                    ]
                    if not any [event/shift event/control] [
                        clear face/selected-periods
                        clear face/drawings/grip
                    ]
                    if face/active-period [
                        face/others: 'need-not-hover
                        if not found? find face/selected-periods face/active-period [
                            insert face/selected-periods face/active-period
                        ]
                        if find face/active-period/edit 'start? [insert face/active-period/edit 'start]
                        if find face/active-period/edit 'end?   [insert face/active-period/edit 'end  ]
                    ]
                    face/handle: event/offset
                ]
                
                if find [up alt-up] action [
                    foreach period face/data [
                        period/started: period/start
                        period/ended: period/end
                    ]
                    if not any [event/shift event/control] [
                        clear face/selected-periods
                        clear face/drawings/grip
                    ]
                    if face/active-period [
                        if not found? find face/selected-periods face/active-period [
                            insert face/selected-periods face/active-period
                        ]
                    ]
                    ;if face/mouse = 'away [clear face/drawings/cursor]
                    face/others: 'may-hover
                ]
                
                face/draw/periods face
                face/draw/selected-periods face
                face/draw/grip face
                
                clear face/drawings/cursor
                ;if not find [over away] action [ 
                ;    face/draw/cursor face event/offset/x
                ;]
                
                show face
            ]
        ]
        
        resize: func [new [pair!]] [
            ;size: max 90x12 new
            size: new
            draw/grid self
            draw/periods self
            draw/selected-periods self
            draw/grip self
        ]
        
        init: copy [
            data: any [data copy []]
            color: any [color white]
            colors/1: color
            selected-periods: copy []
            edit:      copy []
        
            drawings: context [grid: periods: selected-periods: grip: cursor: none]
            draw/grid       self
            draw/periods    self
            draw/selected-periods self
            draw/grip       self
            draw/cursor     self none
            effect: compose/only [draw (drawings/grid) draw (drawings/selected-periods) draw (drawings/periods) draw (drawings/grip) draw (drawings/cursor)]
        ]
    ]
    
]


;################################ DEMO #########################################
;

change-grid: func [resolution [time!]] [
    foreach face time-lines/pane [
        face/resolution: resolution
        foreach period face/data [
            period/started: period/start: round/to period/start resolution
            period/ended:   period/end:   round/to period/end   resolution
        ]
        face/draw/periods face
        face/draw/selected-periods face
        show face
    ]
]

window: center-face layout compose/deep [
    across space 8x1
    text "Working:" bold return
    pad 24x0 text "- Double click to create new periods." return
    pad 24x0 text "- Use cursor keys, CTRL+A and ESC for keyboard editing (incomplete)." return
    pad 0x24 
    text "To do:" bold return
    pad 24x0 text "- Currently, you can't resize 0-width periods (events)" return
    pad 24x0 text "- Swapping start and end times produces unexpected results for now" return
    pad 24x0 text "- Think about collision detection!" return
    pad 24x0 text "- Think about period names!" return
    pad 24x0 text "- Period dialect" return
    pad 0x24 
    text "Resolution:" bold
    radio-line "0:01 h" of 'grid [change-grid 0:01]  
    radio-line "0:05 h" of 'grid [change-grid 0:05]  
    radio-line "0:15 h" of 'grid [change-grid 0:15] 
    radio-line "0:30 h" of 'grid [change-grid 0:30] on
    radio-line "1:00 h" of 'grid [change-grid 1:00] 
    pad 80
    text "Edit Mode:" bold
    edit-start: check-line "start" of 'mode
    edit-end:   check-line "end"   of 'mode 
    pad 80
    text "Modifiers:" bold
    shift-key:   check-line "Shift"   
    control-key: check-line "Control" 
    return
    panel [
        across
        panel [
            space 1x1 origin 1x1
            btn 48x24 "Mo."
            btn 48x24 "Di." 
            btn 48x24 "Mi."
            btn 48x24 "Do." 
            btn 48x24 "Fr." 
            btn 48x24 "Sa." 255.223.223
            btn 48x24 "So." 255.191.191
        ]
        time-lines: panel [
            space 1x1 origin 1x1
            time-line 960x24 periods [
                (context [type: 'work started: start: 07:00 ended: end: 10:00 color: 255.255.255.031 radius: 4 edit: []])
                (context [type: 'away started: start: 10:00 ended: end: 16:00 color: 063.127.255.031 radius: 8 edit: []])
            ]
            time-line 960x24 periods [
                (context [type: 'away started: start: 09:00 ended: end: 12:00 color: 063.127.255.031 radius: 8 edit: []])
                (context [type: 'work started: start: 12:00 ended: end: 14:00 color: 255.127.063.031 radius: 4 edit: []])
                (context [type: 'ill  started: start: 16:00 ended: end: 18:00 color: 063.255.127.031 radius: 4 edit: []])
            ]
            time-line 960x24 periods []
            time-line 960x24 periods []
            time-line 960x24 periods []
            time-line 960x24 periods [] 255.223.223 range [0:00 24:00]
            time-line 960x24 periods [] 255.191.191 range [0:00 24:00]
        ]
    ]
]

if request/confirm {
    You may try the time-line with or without Romano Paolo Tenca's RESIZE-VID script.
    Do you want to do-thru http://www.rebol.it/~romano/resize-vid.r now?
} [
    do-thru http://www.rebol.it/~romano/resize-vid.r
    window: auto-resize window
]

view/options window [resize all-over]
