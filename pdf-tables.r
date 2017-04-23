REBOL [
    Title: "PDF Tables"
    Purpose: "Create tables with the PDF Maker"
    Author: "Gabriele Santilli"
    EMail: giesse@rebol.it
    File: %pdf-tables.r
    Date: 24-Jul-2003
    Version: 1.5.0 ; majorv.minorv.status
                   ; status: 0: unfinished; 1: testing; 2: stable
    Library: [
        level: 'advanced
        platform: 'all
        type: 'function
        domain: [graphics printing text]
        tested-under: [view 1.2.8]
        support: none
        license: 'public-domain
        see-also: %pdf-maker.r
    ]
    History: [
        22-Jul-2003 1.1.0 "History start"
        23-Jul-2003 1.2.0 {
            Adding borders (note: they are drawn indipendently, so you will probably
            not like what they look like if the line width is not 0...)
        }
        23-Jul-2003 1.3.0 "Tried a different way to render borders, still awful in most cases..."
        24-Jul-2003 1.4.0 "Added MIDDLE as a possible vertical alignment for cells"
        24-Jul-2003 1.5.0 "Added ability to control page breaking"
    ]
]

context [
    row-heights: func [row /local heights] [
        heights: make block! 3 + length? row
        insert heights 0
        foreach [width valign padding margin borders color cell] row [
            insert tail heights padding/1 + padding/3 + margin/1 + margin/3 + precalc-textbox width cell
            heights/1: max heights/1 last heights
        ]
        heights
    ]
    norz: func [n] [either number? n [n] [0]]
    render-row: func [output x y row heights /local yy emit xl xr yt yb bt br bb bl] [
        emit: func [val] [insert tail output reduce val]
        nforeach [[width valign padding margin borders color cell] row height next heights] [
            yy: switch valign [
                top     [y - height]
                bottom  [y - heights/1]
                middle  [- heights/1 - height / 2 + y]
            ]
            xl: x + margin/4
            yt: y - margin/1
            xr: x + margin/4 + padding/4 + width + padding/2
            yb: y - heights/1 + margin/3
            if tuple? color [
                emit [
                    'fill color reduce ['box xl yb xr - xl yt - yb]
                ]
            ]
            emit [
                'textbox 
                    x + margin/4 + padding/4 
                    yy + margin/3 + padding/3 
                    width 
                    height - margin/1 - margin/3 - padding/1 - padding/3
                    cell
            ]
            nforeach [word [bt br bb bl] border borders] [
                set word divide norz border 2
            ]
            nforeach [
                bwidth borders
                [x1 y1 x2 y2] reduce [
                    xl - bl  yt       xr + br  yt
                    xr       yt + bt  xr       yb - bb
                    xl - bl  yb       xr + br  yb
                    xl       yt + bt  xl       yb - bb
                ]
            ] [
                if number? bwidth [
                    emit [
                        'line 'width bwidth x1 y1 x2 y2
                    ]
                ]
            ]
            x: xr + margin/2
        ]
    ]
    render-pages: func [pages x y height rows mkpage /local rowgroups i cury accum h toth] [
        i: 1
        insert/only tail pages mkpage i
        cury: y + height
        rowgroups: make block! length? rows
        insert/only rowgroups make block! 16
        foreach [row canbreak] rows [
            insert/only tail last rowgroups row
            if canbreak = 'force-break [
                insert tail last rowgroups 'force-break
            ]
            if canbreak <> 'don't-break [
                insert/only tail rowgroups make block! 16
            ]
        ]
        foreach rg rowgroups [
            accum: clear [ ]
            toth: 0
            foreach row rg [
                if block? row [
                    insert/only tail accum h: row-heights row
                    toth: toth + h/1
                ]
            ]
            if cury - toth < y [
                i: i + 1
                insert/only tail pages mkpage i
                cury: y + height
            ]
            nforeach [row rg heights accum] [
                either block? row [
                    render-row last pages x cury row heights
                    cury: cury - heights/1
                ] [
                    i: i + 1
                    insert/only tail pages mkpage i
                    cury: y + height
                ]
            ]
        ]
    ]
    
    system/words/render-pages: :render-pages
]
