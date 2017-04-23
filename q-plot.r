REBOL [
    Title: "Quick Plot Dialect"
    Date: 15-Feb-2002
    Version: 0.1.0
    File: %q-plot.r
    Author: "Matt Licholai"
    Rights: "(c) 2001,2002 M. Licholai"
    Usage: {Use as a block feeding REBOL VID dialect.  See ez-plot.r for details}
    Purpose: {Provide a quick and easy to use dialect for plotting in REBOL}
    Comment: {To-Do ==
                High --
                Med --
^-^-            + Update/Expand ez-plot.r documentation
                Low -- 
^-^-            + Add stacked bar charts
^-^-            * Rework x log scaling
    }
    History: [0.0.1 [10-Dec-2001 "Initial dialect based on my plot functions"] 
    0.0.2 [14-Dec-2001 "Basic aspects working."] 
    0.0.3 [17-Dec-2001 {Changed to return a layout object, making display easier.}] 
    0.0.4 [5-Jan-2002 "Cleaned up code and comments, added line-patterns"] 
    0.0.5 [15-Jan-2002 {Corrected a problem with offsetting the 
                        x start point and not centering bars}] 
    0.0.6 [16-Jan-2002 {Corrected problem with labels and various bug fixes}] 
    0.0.7 [19-Jan-2002 "Added multi-plot function"] 
    0.0.8 [21-Jan-2002 "Minor clean-up and removal of global words"] 
    0.0.9 [29-Jan-2002 {Start Change to an object, improve parse block,
                        add log scales and candlestick stock chart}] 
    0.1.0 [15-Feb-2002 {Completed changes to parse, and added basic pie chart}] 
    0.1.1 [16-Feb-2002 {Cleaned up code/comments and added exploded pie charts}]
]
    Email: m.s.licholai@ieee.org
    
        library: [
        level: [intermediate] 
        platform: [all] 
        type: [dialect]
        domain: [graphics dialects math gui]
        tested-under: none 
        support: none 
        license: none 
        see-also: %ez-plot.r
    ]
]

quick-plot-dialect: make object! [

    CVS-Id: { $Id: q-plot.r,v 1.33 2002/02/19 15:30:18 matt Exp $ }

        
    ; ------------------
    ; "declare" words that will be used in the object
    ;   This is needed to prevent words in the object from
    ;   bubbling up to global level  (Basically the same as 'use
    ;   but doesn't introduce a new level of indentation.)
    ; This is needed due to a bug? in the way REBOL creates binding
    ;   for word inside functions within objects.
    ; Set these key words in the object to none
    ; --------------------
    set-y-min: none
    set-y-max: none
    set-x-min: none
    set-x-max: none
    title: none
    title-vals: none
    label-nr: none
    bar-width: none
    y-data: none
    x-data: none
    p-size: none
    full-size: none
    result: none
    obj-parms: none
    default-font: none 
    default-color: none
    back-color: none
    default-fill: none
    up-color: none
    down-color: none
    border-width: none
    x-border: none
    y-border: none
    x-log-scale: none
    y-log-scale: none
    title-style: none
    dynamic-scale: none
    dyn-pct: none

    ; ---------------------------------------------
    ; Initialize and re initialize when needed
    ; --------------------------------------------- 
    initialize: func [
        [catch]
        /local
        x-min x-max y-min y-max y-diff y-scaler y-scaled-zero x-step bar-step temp-blk
    ][
        if (obj-parms) [return obj-parms] ; skip the initialization code if we've already done it
        
        ; -------------------------------------------------------
        ; Next we ensure that min and max y and x values are set
        ;    properly based on the type of data we are initially given.
        ;    Do not over ride a user supplied value.
        ; -------------------------------------------------------
        either set-y-min [y-min: set-y-min] [
            either y-data [
                y-min: first minimum-of y-data 
                if none? y-min [
                    temp-blk: sort copy y-data
                    while [none? y-min] [
                        y-min: first temp-blk: next temp-blk
                    ]
                ]
            ][
                y-min: first minimum-of third stock-data
                if none? y-min [
                    temp-blk: sort copy y-data
                    while [none? y-min] [
                        y-min: first temp-blk: next temp-blk
                    ]
                ]
            ]
        ]
        
        either set-y-max [y-max: set-y-max] [
            either y-data [
                y-max: first maximum-of y-data 
                if none? y-max [
                    temp-blk: sort copy y-data
                    while [none? y-max] [
                        y-max: first temp-blk: next temp-blk
                    ]
                ]
            ][
                y-max: first maximum-of second stock-data
                if none? y-max [
                    temp-blk: sort copy y-data
                    while [none? y-max] [
                        y-max: first temp-blk: next temp-blk
                    ]
                ]
            ]
        ]
        
        either set-x-min [x-min: set-x-min] [
            either x-data [
                x-min: first minimum-of x-data
                if none? x-min [
                    temp-blk: sort copy x-data
                    while [none? x-min] [
                        x-min: first temp-blk: next temp-blk
                    ]
                ]
            ][
                x-min: 1
            ]
        ]
        
        either set-x-max [x-max: set-x-max] [
            either x-data [
                x-max: first maximum-of x-data
                if none? x-max [
                    temp-blk: sort copy x-data
                    while [none? x-max] [
                        x-max: first temp-blk: next temp-blk
                    ]
                ]
                
            ][
                either y-data [
                    x-max: length? y-data
                ][
                    x-max: length? fourth stock-data
                ]
            ]
        ]

        ;  if give a block of stock prices, work with the closes
        if not y-data [y-data: fourth stock-data]

        if dynamic-scale [
            either ((abs y-max - y-min / y-max * 100) > dyn-pct) [
                y-log-scale: true
            ][
                y-log-scale: false
            ]
        ]

        y-diff: to-decimal either y-log-scale [
            either any [ y-max = 0 y-min = 0] [
                log-10 (y-max - y-min) 
            ][
                either any [(y-min >= 0.0) (y-max <= 0.0)] [        
                    ; min and max are both have the same sign
                    abs ((log-10 abs y-max) - log-10 (abs y-min))
                ][
                    ; min and max cross zero
                    (log-10 y-max) + log-10 abs y-min 
                ]
            ]
        ][
            y-max - y-min
        ]

        y-scaler: (to-decimal p-size/y) / y-diff

        ; start computing the y-scaled-zero
        either y-log-scale [
            either y-min = 0.0 [y-scaled-zero: 0.0][
                y-scaled-zero: y-scaler * log-10 (abs y-min)
            ]
            if y-min < 0 [
                y-scaled-zero: negate y-scaled-zero
                if y-max > 0 [y-scaled-zero: (negate y-max / (y-max + y-max) * p-size/y)]
            ]
        ][
            y-scaled-zero: (y-scaler * y-min)
        ]   
        ; is there a clear way to show what's being done here?
        y-scaled-zero: p-size/y + y-scaled-zero

        x-offset: either x-border [border-width] [0]

        x-step: (to-decimal p-size/x) / (to-decimal (length? y-data) - 1 )

        x-log-adj: either x-log-scale [
            (to-decimal length? y-data) / (0.25 + length? y-data)
        ][
            1.0
        ]

        bar-step: (to-decimal p-size/x) / (to-decimal (length? y-data ))

        obj-parms: reduce ['y-min y-min 'y-max y-max 'x-min x-min 'x-max x-max
            'y-scaler y-scaler 'y-scaled-zero y-scaled-zero 'x-step x-step 'bar-step  bar-step
            'x-offset x-offset 'x-log-adj x-log-adj
        ]

        return obj-parms
    ]
    

        
    ; --------------------
    ; plot functions (feed into draw dialect)
    ; --------------------

    y-lines: func [
        [catch]
        y-data [block!] "Block of y values to plot"
        /local
        y-pt x-val val-pair scale-y y-val parms 
    ][
        parms: initialize  ; get everything setup, if not already
        scale-y: y-curry parms/y-scaled-zero parms/y-scaler ; set up the scaler function
        
        x-val: parms/x-offset ; start the far left 
        
        insert tail result 'line

        x-increment: (to-decimal parms/x-step) / (parms/x-log-adj)
        foreach y-pt y-data [
            ; don't plot any none values (after incrementing x)
            if y-pt [
                val-pair: to-pair reduce [(to-integer x-val) (scale-y y-pt)]
                
                insert tail result val-pair
            ]
            x-val: (x-increment: x-increment * parms/x-log-adj) + x-val 
        ]
        insert tail result [line-pattern]       
    ]
    
    
    y-grids: func [
        [catch]
        p-size [pair!]
        nr-lines [integer!]
        /local
        y-val parms x-offset scale-y y-inc 
    ][
        parms: initialize  ; get everything setup

        insert tail result [line-pattern none] ; ensure we draw continuous lines

        scale-y: y-curry parms/y-scaled-zero parms/y-scaler ; set up the scaler function
        y-inc: (to-decimal parms/y-max - parms/y-min ) / (nr-lines - 1)
        x-offset: parms/x-offset

        y-val: parms/y-min
        y-pos: p-size/y - 1

        ; draw the line at the bottom of the plot
        insert insert tail result 'line (to-pair reduce [
                (x-offset) (to-integer y-pos)])
        insert tail result (to-pair reduce [(p-size/x + x-offset) (to-integer y-pos)])


        until [ 
            y-val: y-val + y-inc
            y-pos: scale-y y-val
            
            insert insert tail result 'line (to-pair reduce [
                    (x-offset) (to-integer y-pos)])
            insert tail result (to-pair reduce [(p-size/x + x-offset) (to-integer y-pos)])
            
            y-pos < 0.0
        ]
    ]
    
    
    x-grids: func [
        [catch]
        p-size [pair!]
        nr-lines [integer!]
        /local
        x-val x-inc parms 
    ][
        parms: initialize  ; get everything setup
        x-val: parms/x-offset + 1
        x-inc: (to-decimal p-size/x - 2) / (nr-lines - 1) / parms/x-log-adj

        insert tail result [line-pattern] ; ensure continuous lines
        
        until [
            insert insert tail result first [line] (to-pair reduce [(to-integer x-val) 0])
            insert tail result (to-pair reduce [(to-integer x-val) (p-size/y)])
            x-val: (x-inc: parms/x-log-adj *  x-inc) + x-val
            x-val > (p-size/x + parms/x-offset + 1)
        ]
    ]
    
    
    
    
    x-axis: func [
        [catch]
        p-size [pair!]
        full-size [pair!]
        nr-marks [integer!]
        /local
        x-step x-inc y-height x-val x-pos p-val x-adj parms i
    ][
        parms: initialize  ; get everything setup

        ; handle the special case when only x-data is only 2 items
        ;  shorthand for setting x-min and x-max
        if all [ x-data  ((length? x-data ) = 2)] [ 
            set-x-min: first x-data
            set-x-max: second x-data
            obj-parms: none
            x-data: none
            x-axis p-size full-size nr-marks 
        ]
        
        x-step: (to-decimal p-size/x) / (nr-marks - 1) / parms/x-log-adj
        x-inc: either x-data [
            (length? x-data) / nr-marks
        ][
            either date? parms/x-min [
                (parms/x-max - parms/x-min) / (nr-marks - 1)
            ][
                (to-decimal parms/x-max - parms/x-min ) / (nr-marks - 1)
            ]
        ]
        
        y-height: full-size/y - 25
        x-val: parms/x-min
        x-pos: parms/x-offset 
        
        insert insert tail result first [text] (to-pair reduce [(to-integer x-pos)
                (y-height)])
        insert tail result to-string parms/x-min
        
        x-pos: x-pos 
        
        i: 0
        until [ 
            i: i + 1
            x-val: either x-data [
                pick x-data round-0 (i * x-inc)
            ][
                parms/x-min + to-integer (x-inc * i)
            ]
            x-pos: x-pos + x-step: (x-step * parms/x-log-adj)
            
            insert insert tail result first [text] (to-pair reduce [
                    (to-integer x-pos) (y-height)])
            insert tail result to-string either date? x-val [x-val][round-2 x-val]
            
            x-pos > (full-size/x - (x-step))
        ]
        
        if x-log-scale [return]
        ; add a final label for the max value (since it falls off the chart otherwise
        ;  (this one is inset from the right end of the chart) 
        ;  (different inset for dates)
        insert insert tail result first [text] (to-pair reduce [
                (full-size/x - either date? parms/x-min [
                        55
                    ][
                        9 * (1 + to-integer log-10 p-val: round-2 parms/x-max)
                    ])
                (y-height)])
        insert tail result to-string either date? x-val [parms/x-max][p-val]
    ]
    
    
    
    y-axis: func [
        [catch]
        p-size [pair!]
        nr-marks [integer!]
        /local
        y-step y-inc x-offset y-val y-pos y-adj parms
    ][
        parms: initialize  ; get everything setup
        
        scale-y: y-curry parms/y-scaled-zero parms/y-scaler ; set up the scaler function
        y-inc: (to-decimal parms/y-max - parms/y-min ) / (nr-marks - 1)
        
        x-offset: 1
        y-val: parms/y-min
        y-pos: p-size/y - 16
        
        insert insert tail result first [text] (to-pair reduce [
                (x-offset) (to-integer y-pos)])
        insert tail result to-string round-2 parms/y-min
        
        until [ 
            y-val: y-val + y-inc
            y-pos: scale-y y-val
            
            insert insert tail result first [text] (to-pair reduce [
                    (x-offset) (to-integer y-pos)])
            insert tail result to-string round-2 y-val
            
            y-pos < 0.0
        ]
    ]
    
    
    
    stock-ohlc: func [
        [catch]
        data [block!] "[open high low close] each is a block of values"
        /local
        opens highs lows closes x-tick x-pos scale-y parms x-inc
    ][
        parms: initialize  ; get everything setup
        
        opens: first data
        highs: second data
        lows: third data
        closes: fourth data
        
        x-tick: to-integer( parms/x-step / 4 )
        if (x-tick < 1) [x-tick: 1]
        x-pos: parms/x-offset + x-tick
        x-inc: parms/x-step

        scale-y: y-curry parms/y-scaled-zero parms/y-scaler
                
        until [
            
            ; skip plotting the value if it is none (drop down to getting the next elements)
            if first closes [
                ; draw the day's high to low segment
                insert insert tail result first [line]  to-pair reduce [(to-integer x-pos)
                    (scale-y first highs)]
                insert tail result  to-pair reduce [(to-integer x-pos) (scale-y first lows)]   
                
                ; draw the open segment to the right of the High-Low line
                insert insert tail result first [line]  to-pair reduce [
                    (to-integer (x-pos - x-tick)) (scale-y first opens)]
                insert tail result  to-pair reduce [(to-integer x-pos) (scale-y first opens)]
                
                ; draw the close segment to the left of the High-Low line
                insert insert tail result first [line]  to-pair reduce [(to-integer x-pos)
                    (scale-y first closes)]
                insert tail result  to-pair reduce [(to-integer(x-pos + x-tick))
                    (scale-y first closes)]
            ]
            
            ; step to the next element in each vector of prices
            opens: next opens
            highs: next highs
            lows: next lows
            closes: next closes
            
            x-pos: x-pos + x-inc: (parms/x-log-adj * x-inc) 
            
            ; test to see if we've reached the end of the data in 
            ;   a representative vector {opens}
            tail? opens
        ]
        insert tail result [line-pattern]
    ]
    

    add_text: func [txt over up usr-font /local posit] [
        parms: initialize
        if usr-font [insert tail result compose [font (usr-font)] ]
        
        posit: to-pair reduce [to-integer (p-size/x + parms/x-offset * over / 100)
            to-integer (p-size/y * ( 100 - up / 100) )]
        insert tail result compose [text (posit) (txt)]
        insert tail result compose [font (default-font)]
    ]
    

    add_label: func [/local x-pos y-pos scale-y parms label-step][
        parms: initialize
        label-nr: label-nr + 1
        label-step: to-integer ((length? y-data) / 25 * label-nr)
        if ( label-step < 2 ) [label-step: 2]
        x-pos: to-integer label-step * parms/x-step + parms/x-offset
        if (x-pos > (p-size/x - 25 - parms/x-offset )) [
            label-nr: 1
            add_label
        ]
        scale-y: y-curry parms/y-scaled-zero parms/y-scaler
        y-pos: scale-y pick y-data label-step 
        insert insert tail insert tail result 'text to-pair reduce [x-pos y-pos] label-txt
    ]
    
    reset-init: does [
        obj-parms: none
    ]
    
    full-reset-init: does [
        obj-parms: none
        set-x-min: none
        set-x-max: none
        set-y-min: none
        set-y-max: none
    ]
    
    
    bar-graph: func [
        [catch]
        "draw a set of bar graphs"
        data [block!]
        p-size [pair!]
        /local
        x-pos low-left up-right val y-scale bar-step parms 
    ][
        parms: initialize  ; get everything setup, if not already
        
        if (not bar-width) [
            bar-width: (p-size/x / ((length? y-data) + 1 ))
        ]
        
        
        bar-step: parms/bar-step
        x-pos: parms/x-offset  ; use the line below to have the edge bars "fall off"
        ; x-pos: parms/x-offset - bar-width / 2.0 ; also need to make the change to 'bar-width
        
        y-scale: y-curry parms/y-scaled-zero parms/y-scaler
        
        foreach val data [
            ; skip over the data if it is none (drop down to increment x-pos)
            if val [
                low-left: to-pair reduce [(to-integer x-pos) (min y-scale parms/y-min y-scale 0)]
                up-right: to-pair reduce [( to-integer (x-pos + bar-width)) (y-scale val)]
                
                insert insert insert tail result first [box] low-left up-right
            ]
            x-pos: x-pos + parms/bar-step
        ]
        insert tail result [line-pattern fill-pen]
    ]


    stock-candles: func [
        [catch]
        data [block!] "[open high low close] each is a block of values"
        up-color 
        down-color 
        /local
        opens highs lows closes x-tick x-pos scale-y parms open-left close-right day-color
    ][
        parms: initialize  ; get everything setup
        
        opens: first data
        highs: second data
        lows: third data
        closes: fourth data
        
        x-tick: to-integer( parms/x-step / 4 )
        if (x-tick < 1) [x-tick: 1]
        x-pos: parms/x-offset + x-tick
        x-inc: parms/x-step
        
        scale-y: y-curry parms/y-scaled-zero parms/y-scaler
        
        until [
            
            ; skip plotting the value if it is none (drop down to getting the next elements)
            if first closes [
                
                ; determine the color for the day (if an up or down day)
                day-color: either ((first opens) <= (first closes)) [up-color][down-color]
                append result compose [fill-pen (day-color) pen (day-color)]
                
                
                ; draw the day's high to low segment
                insert insert tail result first [line]  to-pair reduce [(to-integer x-pos)
                    (scale-y first highs)]
                insert tail result to-pair reduce [(to-integer x-pos) (scale-y first lows)]   

                ; get the corners of the box representing the candle body
                open-left: to-pair reduce [
                    (to-integer (x-pos - x-tick)) (scale-y first opens)]
                close-right: to-pair reduce [(to-integer (x-pos + x-tick))
                    (scale-y first closes)]
                
                ; draw the candle body over the high-low line
                insert insert insert tail result 'box open-left close-right
            ]
            
            ; step to the next element in each vector of prices
            opens: next opens
            highs: next highs
            lows: next lows
            closes: next closes
            
            x-pos: x-pos + x-inc: (parms/x-log-adj * x-inc)             
            
            ; test to see if we've reached the end of the data in 
            ;   a representative vector {opens}
            tail? opens
        ]
        insert tail result [line-pattern pen default-color fill-pen]
    ]
    

    scatter: func [
        data-blk [block!] {data block x-y tuples/blocks/pairs}
        shape [word!]  {shape for the symbol to plot}
        sym-size [integer!] {size of the symbol to plot}
        /local
        x-diff x-scaled-zero x-scaler x-pt y-pt pt 
    ][
        x-data: copy [] 
        y-data: copy []

        foreach pt data-blk [
            insert tail x-data pt/1
            insert tail y-data pt/2
        ]
        
        parms: initialize
        
        ; ---------------------------------------------
        ; set up x scaling parameters
        ; ---------------------------------------------
        x-diff: to-decimal either x-log-scale [
            either any [ parms/x-max = 0 parms/x-min = 0] [
                log-10 (parms/x-max - parms/x-min) 
            ][
                either any [(parms/x-min >= 0.0) (parms/x-max <= 0.0)] [        
                    ; min and max are both have the same sign
                    abs ((log-10 abs parms/x-max) - log-10 (abs parms/x-min))
                ][
                    ; min and max cross zero
                    (log-10 parms/x-max) + log-10 abs parms/x-min 
                ]
            ]
        ][
            parms/x-max - parms/x-min
        ]

        x-scaler: (to-decimal p-size/x) / x-diff

        ; start computing the x-scaled-zero
        either x-log-scale [
            either parms/x-min = 0.0 [x-scaled-zero: 0.0][
                x-scaled-zero: x-scaler * log-10 (abs parms/x-min)
            ]
            if parms/x-min < 0 [
                x-scaled-zero: negate x-scaled-zero
                if parms/x-max > 0 [
                    x-scaled-zero: (negate parms/x-max / (parms/x-max + parms/x-max) * p-size/x)
                ]
            ]
        ][
            x-scaled-zero: (negate x-scaler * parms/x-min)
        ]   


        scale-x: x-curry x-scaled-zero x-scaler
        scale-y: y-curry parms/y-scaled-zero parms/y-scaler

        until [
            y-pt: first y-data
            x-pt: first x-data

            y-data: next y-data
            x-data: next x-data

            pt: to-pair reduce [(parms/x-offset + scale-x x-pt ) (scale-y y-pt)]


            append result switch shape [
                circle    [plot-circle pt sym-size]
                
                box       [plot-box pt sym-size]
                
                diamond   [plot-diamond pt sym-size]
                
                cross     [plot-cross pt sym-size]
                
                X-mark    [plot-X-mark pt sym-size]
                
                point     [plot-circle pt 1]
            ]
            
            tail? y-data
        ]
        x-data: none 
        y-data: head y-data
        
    ]
    
    ; symbol plotting functions
    plot-circle: func [pt [pair!] size [integer!] /local
        
    ][
        return reduce ['circle pt size]
    ]

    plot-box: func [pt [pair!] size [integer!] /local
        up-left low-rt
    ][
        up-left: pt - size
        low-rt: pt + size
        return reduce ['box up-left low-rt]
    ]

    plot-X-mark: func [pt [pair!] size [integer!] /local
        up-left low-left up-rt low-rt
    ][
        up-left: pt - size
        low-rt: pt + size
        up-rt: to-pair reduce [low-rt/x up-left/y]
        low-left: to-pair reduce [up-left/x low-rt/y]
        return reduce ['line up-left low-rt 'line low-left up-rt]
    ]

    plot-cross: func [pt [pair!] size [integer!] /local
        up-pt low-pt rt-pt left-pt
    ][
        up-pt: to-pair reduce [pt/x (pt/y - size)]
        low-pt: to-pair reduce [pt/x (pt/y + size)]
        left-pt: to-pair reduce [(pt/x - size) pt/y]
        rt-pt: to-pair reduce [(pt/x + size) pt/y]
        return reduce ['line up-pt low-pt 'line left-pt rt-pt]
    ]


    plot-diamond: func [pt [pair!] size [integer!] /local
        up-pt low-pt rt-pt left-pt
    ][
        up-pt: to-pair reduce [pt/x (pt/y - size)]
        low-pt: to-pair reduce [pt/x (pt/y + size)]
        left-pt: to-pair reduce [(pt/x - size) pt/y]
        rt-pt: to-pair reduce [(pt/x + size) pt/y]
        return reduce ['polygon up-pt rt-pt low-pt left-pt up-pt]
    ]


    pie: func [ data [block!] 
        p-size [pair!] 
        r-pct [integer!] "pct of full size"
        labels-blk [block!] "data labels"
        exp-blk [block!] "block with the number of each slice to explode"
        /local
        r midpoint sum pcts pct val x y val2 r2
    ][
        fills: [
            gold
            teal
            olive
            brick
            pink
            water
            purple
            violet
            khaki
            brown
            oldrab
            leaf
            coffee
            tan
            magenta
            navy
            orange
            aqua
            forest
            maroon
        ]

        midpoint: p-size / 2

        r: min midpoint/x midpoint/y
        
        sum: 0
        foreach val data [
            sum: sum + val
            ]

        pcts: copy []
        foreach val data [
            append pcts (to-decimal val / sum)
        ]
        
        append result compose [fill-pen (back-color)]
        append result compose [circle (midpoint) (r: r * r-pct / 100)]

        pt: to-pair reduce [midpoint/x   to-integer midpoint/y - r]
        append result compose [line (midpoint) (pt)]

        count: 0
        val: 0.0    ; start at 0 degrees rotation. 
        ; Y plots down from the top so its minus
        foreach pct pcts [
            count: count + 1
            if pct > 0 [
                fil-col: first fills
                old-val: val

                val2: (pct * 180.0 ) + val
                val: (pct * 360.0) + val
                x: r * sine val
                y: r * cosine val
                pt: to-pair reduce [(to-integer midpoint/x + x)  (to-integer midpoint/y - y)]
                
                x: (r - 5) * sine val2
                y: (r - 5) * cosine val2
                fill-pt: to-pair reduce [(to-integer midpoint/x + x)  (to-integer midpoint/y - y)]

                x: (r + 10) * sine val2
                y: (r + 10) * cosine val2
                label-pt: to-pair reduce [(to-integer midpoint/x + x)  (to-integer midpoint/y - y)]
                
                append result compose [line (midpoint) (pt)]
                
                ;; process the section if it is on the exploded list
                if find exp-blk count [
                    r*: 100 - r-pct / 100 * r
                    x*: r* * sine val2
                    y*: r* * cosine val2
                    mid*: to-pair reduce [to-integer midpoint/x + x* to-integer midpoint/y - y*]

                    ; note that x and y are still based on r + 10 and val2
                    label-pt: to-pair reduce [to-integer mid*/x + x  to-integer mid*/y - y]

                    append result compose [fill-pen (fil-col)]
                    append result compose [polygon (mid*)]
                    for theta old-val val 5 [
                        x: r * sine theta
                        y: r * cosine theta
                        pt: to-pair reduce [to-integer mid*/x + x  to-integer mid*/y - y]
                        append result pt
                    ]
                    append result mid*
                ]

                append result compose [fill-pen (fil-col)]
                append result compose [flood (fill-pt)]
                if not error? try [txt: first labels-blk][
                    append result compose [text (label-pt) (to-string txt)]]
                if tail? fills: next fills [fills: head fills]
                labels-blk: next labels-blk
            ]
        ]
    ]

    ;  this returns a function that gives the properly scaled y value
    ;       the function is different if we are using a log scale
    y-curry: func [
        "y-scaler curried with y-scaling constants"
        y-scaled-zero [decimal!]
        y-scaler [decimal!]
    ][
        either y-log-scale [
            return func [y][
                if (y = 0) [return to-integer y-scaled-zero]
                return either ( y > 0) [
                    to-integer (y-scaled-zero - (y-scaler * log-10 y))
                ][
                    to-integer (y-scaled-zero + (y-scaler * log-10 negate y))
                ]
            ]
        ][
            return func [y /local val][
                to-integer (y-scaled-zero - (y * y-scaler) )
            ]
        ]
    ]


    ; do the same for x values (only when needed -- scatter)
    x-curry: func [
        "x-scaler curried with x-scaling constants"
        x-scaled-zero [decimal!]
        x-scaler [decimal!]
    ][
        either x-log-scale [
            return func [x][
                if (x = 0) [return to-integer x-scaled-zero]
                return either ( x > 0) [
                    to-integer (x-scaled-zero + (x-scaler * log-10 x))
                ][
                    to-integer (x-scaled-zero - (x-scaler * log-10 negate x))
                ]
            ]
        ][
            return func [x][
                to-integer (x-scaled-zero + (x * x-scaler) )
            ]
        ]
    ]
    


    round-2: func [
        val [number!]
    ][          ; round by shifting decimal and truncating
        either val < 0 [
            if val < -100000 [return to-integer val] ; needed so we don't overflow
            return (to-integer ((val * 100) - 0.5))/ 100.0 
        ][
            if val > 1000000 [return to-integer val]
            return (to-integer ((val * 100) + 0.5)) / 100.0 
        ]
    ]
    

    round-0: func [
        val [number!]
    ][
        ; round by shifting decimal and truncating
        either val < 0 [
            return to-integer val - 0.5
        ][
            return to-integer val + 0.5 
        ]
    ]
    
    set 'quick-plot  func [
        {Implement a quick and easy plotting dialect to feed into View/Draw}
        [catch]
        cmds [block!] "Input block for processing"
        /local
        shape sym-size data-blk
    ][
        ; --------------------
        ; Re-initialize key words to none
        ;   and reset all the defaults
        ; --------------------
        obj-parms: none
        
        set-x-min: none
        set-x-max: none
        set-y-min: none
        set-y-max: none

        title-vals: copy []
        
        usr-font: none
        bar-width: none
        x-log-scale: false
        y-log-scale: false
        x-border: false
        y-border: false
        r-pct: 80
        lab-blk: copy []
        exp-blk: copy []
        
        y-data: none
        x-data: none
        result: none
        x-pct: 0
        y-pct: 0
        
        shape: 'x-mark
        sym-size: 3
        label-nr: 0

        default-font: make face/font [
            size: 14
            ; style: [bold]
            name: font-sans-serif
        ]
        
        default-color: black
        default-fill: gray
        back-color: rebolor
        up-color: silver
        down-color: 45.45.45 
        border-width: 35
        x-border: false
        y-border: false
        x-log-scale: false
        y-log-scale: false
        dynamic-scale: false
        dyn-pct: 100
        title-style: 'h1

        ; -------------------------
        ; Define the parse rules
        ;  There is one rule for every option in the dialect
        ; -------------------------

        ; plot rules
        scale-cmd:  ['scale ['log (y-log-scale: true x-log-scale: false) | 
                'log-linear (x-log-scale: false y-log-scale: true) |
                'log-log (x-log-scale: y-log-scale: true) |
                'linear (x-log-scale: y-log-scale: false) |
                'dynamic opt [set dyn-pct integer!] (dynamic-scale: true) 
            ] (reset-init)]
        plot-x-axis-cmd: ['x-axis x-axis-opts ]
        plot-y-axis-cmd: ['y-axis y-axis-opts ]

        x-axis-opts:  [any [ ['inset (y-border: false) | 'border (y-border: true) ] | 
                set nr-marks integer! ] ]
        y-axis-opts:  [any [ ['inset (x-border: false) | 'border (x-border: true) ] | 
                set nr-marks integer! ] ]

        plot-rules: [ any [
                scale-cmd |
                plot-x-axis-cmd |
                plot-y-axis-cmd |
                skip
            ]
        ]


        ; element rules
        line-cmd:   ['line set y-data block! opt [color-cmd] (y-lines y-data)]
        bar-cmd:    ['bars  any [color-cmd | fill-cmd | set y-data block!] (bar-graph y-data p-size)]
        stock-cmd:  ['stock  set stock-data block! opt [color-cmd] (stock-ohlc stock-data)]
        candles-cmd:  ['candles  any [ 'up set up-color [tuple! | word!] |
                'down set down-color [word! | tuple!] | color-cmd |
                set stock-data block! ]
                (stock-candles stock-data up-color down-color)]
        scatter-cmd: ['scatter  any ['symbol set shape [word!] | 'size set sym-size [integer!] |
                color-cmd | fill-cmd | set data-blk block!] (scatter data-blk shape sym-size) ]
        pie-cmd: ['pie set pie-data block! any ['labels set lab-blk block! | 
                'explode set exp-blk block! | 'size set r-pct integer!] 
            (pie pie-data p-size r-pct lab-blk exp-blk)]
        x-data-cmd: ['x-data set x-data block!]
        x-grd-cmd:  ['x-grid set nr-lines integer! (x-grids p-size nr-lines)]
        y-grd-cmd:  ['y-grid set nr-lines integer! (y-grids p-size nr-lines)]
        x-axis-cmd: ['x-axis x-axis-opts (x-axis p-size full-size nr-marks)]
        y-axis-cmd: ['y-axis y-axis-opts (y-axis p-size nr-marks)]
        title-cmd:  ['title  any ['style set title-style word! | set title string!] ]
        y-min-cmd:  ['y-min  set set-y-min number!    (reset-init)]
        y-max-cmd:  ['y-max  set set-y-max number!    (reset-init)]
        x-min-cmd:  ['x-min  set set-x-min number!    (reset-init)]
        x-max-cmd:  ['x-max  set set-x-max number!    (reset-init)]
        b-width-cmd: ['bar-width set bar-width integer!]
        label-cmd:  ['label set label-txt string! (add_label)]
        text-cmd:   ['text some [posit-cmd | font-cmd | color-cmd |
                set txt string! ] (add_text txt x-pct y-pct usr-font) ]
        misc-cmd:   [set misc [word! | tuple! | number!] (append result misc)]
        draw-cmd:  ['draw set misc block! (append result misc)]
        rescale-cmd: ['rescale (full-reset-init)]

        pattern-cmd: ['pattern (append result pattern) any [set misc integer! (append result misc)] ]
        color-cmd: ['color set misc [tuple! | word!] (append append result 'pen misc)]
        fill-cmd: ['fill set misc [tuple! | word!] (append append result 'fill-pen misc)]

        posit-cmd:  ['over set x-pct integer! | 'up set y-pct integer!]
        font-cmd:   ['font set usr-font word!]
        font-set-cmd:   ['font set new-font word! (append append result 'font new-font)]

        rules: [ any [
                line-cmd |
                bar-cmd |
                stock-cmd |
                candles-cmd |
                scatter-cmd |
                pie-cmd |
                x-data-cmd |
                x-grd-cmd |
                y-grd-cmd |
                x-axis-cmd |
                y-axis-cmd |
                y-min-cmd |
                y-max-cmd |
                x-min-cmd |
                x-max-cmd |
                b-width-cmd |
                title-cmd |
                label-cmd |
                text-cmd |
                rescale-cmd |
                scale-cmd | ; need this to properly go through all the cmds
                draw-cmd |
                misc-cmd  ; this needs to be last with no bar following it
                
            ]
            end
        ]

        
        ; -------------------------
        ; Prepare values for parsing and processing
        ; -------------------------
        reset-init ; get all the values zeroed out
        
        ; compose the input block to process any embedded REBOL
        ; throwing any errors in the process
        if error? set/any 'err try [cmds: compose/deep bind cmds 'quick-plot] [
            throw err
        ]
        
        full-size: first cmds ; extract the size of the plot
        
        if (not pair? full-size) [
            throw make error! "first value of the input block must be the plot size (pair!)"
        ]
        
        cmds: next cmds
        
        result: copy []

        ; ---------------------------------------------
        ; insert our defaults into the result block
        ; ---------------------------------------------
        append result copy compose [pen (default-color) fill-pen (default-fill)]
        append result copy compose [font (default-font)]
        

        ; -------------------------
        ; parse and process the dialect
        ; -------------------------
        ; first the plot rules (effect the entire plot)
        test: parse cmds plot-rules     
        
        ; now set the pot size and scales (since they effect all elements)
        p-size: full-size
        if x-border [p-size/x: (p-size/x - border-width)]
        if y-border [p-size/y: (p-size/y - border-width)]

        ; now the element rules
        test: parse cmds rules
        
        ; if there was an error in parsing the cmds then throw an
        ;  error to the user
        if not test [throw make error! "Unable to parse commands"]
        
        ; instead of returning a block to feed draw run the process
        ; all the way through layout (simpler for the user)
        
        ; if we have title text add it to the plot
        if title [
            title-vals: copy []
            ; approximately center the title 
            ;  each character using h1 font is about 7.5 pixels wide.  So we shift
            ;  to the middle less 4 pixels times the number of characters 
            ;  to start drawing the title.
            title-pos: to-integer ((p-size/x / 2 ) - (4 * length? title))  
            title-pos: to-pair reduce [title-pos 0]
            insert insert tail title-vals compose [origin (title-pos) text (title-style)] title
            title: none
        ]
        
        out-obj: do reduce compose/deep [
            ; create the layout object we will return to the user
            layout [
                size (full-size) 
                origin 0x0
                box (back-color) (full-size) effect [
                    draw [(result)]
                ]
                (title-vals)
            ]
        ]
        
        return out-obj
    ]

    set 'multi-plot func [
        [catch]
        p-size [pair!] "size of the complete multi-plot"
        plots [block!] "Block of quick-plot data blocks"
        /across "layout the plots side by side"
        /down  "layout the plots down the page"
        /ratio 
        ratios [block!] "block of relative sizes for the subplots"
        /local
        nr-plots this-sizer panes-blk box-size subplot this-img total-ratio
        this-origin val subplot-size next-origin-offset
    ][
        nr-plots: length? plots
        
        if ratio [if not-equal? length? ratios nr-plots [
                throw make error! "Ratio block must have an entry for each plot"
            ]
            
            total-ratio: 0
            foreach val ratios [
                total-ratio: total-ratio + val
            ]
        ]
        panes-blk: copy compose [size (p-size)]
        either across [
            append panes-blk 'across
            box-size: to-pair reduce [2 (p-size/y + 10)]
        ][
            append panes-blk 'below
            box-size: to-pair reduce [(p-size/x + 10) 2]
        ]
        this-origin: 0x0
        forall plots [
            subplot: first plots
            
            either ratio [
                this-sizer: total-ratio / first ratios
                ratios: next ratios
            ][
                this-sizer: nr-plots
            ]
            
            either across [
                subplot-size: to-pair reduce [to-integer (p-size/x / this-sizer - 4)  p-size/y]
                next-origin-offset: to-pair reduce [to-integer (p-size/x / this-sizer )  0]
            ][
                subplot-size: to-pair reduce [p-size/x  to-integer (p-size/y / this-sizer - 4)]
                next-origin-offset: to-pair reduce [0 to-integer (p-size/y / this-sizer )]
            ]
            if ((type? first subplot) = pair!) [remove subplot]
            this-img: to-image quick-plot (head insert subplot subplot-size)
            
            append panes-blk compose [origin (this-origin) image (copy this-img)]
            
            this-origin: this-origin + next-origin-offset
            if (not tail? next plots) [
                append panes-blk compose [origin (this-origin - 2) box (box-size) coal] 
            ]
            
        ]
        
        layout panes-blk
    ] ;multi-plot
]