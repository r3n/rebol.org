REBOL [
    Title: "resize window"
    Date: 31-May-2001
    Version: 1.1.0
    File: %resize-window.r
    Author: "Volker Nitsch"
    Usage: ["see help, demo. main trick: " 
    [.. func [SIZE-DIFF] [layout [area SIZE-DIFF + 320x240]] 
        {the first time it is called with 0x0, on resize with the difference to the original size}
    ] 
    "or" 
    [.. func [ORIG-DIFF LAST-DIFF LAST-FACE] [layout [area ORIG-DIFF + 320x240]] 
        "the first time it is called with (0x0 0x0 none)," 
        {on resize with the difference to the original size, to the last size, and the old face}
    ]
]
    Purpose: {{easy way to have a resizable window. also window close-button can be trappt.}
{may be used with fresh face or modifying the old now}
}
    Comment: [
    "mostly extracted from inbuild ctx-edit" 
    {bug in /view 1.2 kills detect-handler sometimes in list-window irreparable}
]
    History: [
    31-May-2001 {support for face-reuse and "fresh-fac with old data" added. some cleanup. examples} 
    30-May-2001 "posted"
]
    Email: agem@crosswinds.net
    library: [
        level: none 
        platform: none 
        type: 'tool 
        domain: [GUI] 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]
view-resizeable: func [
    "view in a resizable window, support resize-calculations"
    title "title for window"
    screen-part
    "the part of screen to cover. [9x9 10x10] would be 90% ( 9x9 / 10x10 ), if not block, ignored"
    close?
    "this function is called on close-button. return 'true if window can be closed."
    fresh-layout
    "this func[orig-diff last-diff last-face] has to return a layout."
    /new "without this, does 'do-event if only window"
    /no-center
    /local detect new-size resize-window pane current-layout-box window-layout min-size
    current-layout fresh-layout1 last-size offset?
] [
    context [
        fresh-layout1: :fresh-layout ;copy it in context!
        current-layout: fresh-layout1 0x0 0x0 none
        current-layout/offset: 0x0
        current-layout-box: none
        window-layout: layout [size current-layout/size origin 0x0
            current-layout-box: box current-layout/size with [pane: current-layout]
        ]
        min-size: window-layout/size
        last-size: window-layout/size
        resize-window: func [/new-size] [
            new-size: max min-size window-layout/size
            current-layout/size: new-size
            current-layout: fresh-layout1
            (new-size - min-size) (new-size - last-size) current-layout
            new-size: current-layout/size
            current-layout-box/size: new-size
            window-layout/size: new-size
            current-layout/offset: 0x0
            current-layout-box/pane: current-layout
            last-size: window-layout/size
            show window-layout
        ]
        if block? screen-part [
            window-layout/size: (system/view/screen-face/size) * screen-part/1 / screen-part/2
            resize-window
        ]
        if not no-center [
            window-layout: center-face window-layout
        ]
        view/new/title/options window-layout title [resize]
        window-layout/feel: make window-layout/feel [
            detect: func [face event] [
                switch event/type [
                    resize [
                        resize-window current-layout-box/pane
                        return true
                    ]
                    close [
                        if not do close? [return true]
                    ]
                ]
                event
            ]
        ]
        if not new [
            if 1 = length? system/view/screen-face/pane [do-events]
        ]
    ]
]

/main ;example
do [
    ;create demo-text
    do [
        echo %echo.txt
        probe system/script/header
        help view-resizeable
        print ""
        echo none
    ]
    my-text: read %echo.txt

    ;the usage-demo
    ;---------------
    ; 0x1 * 123x234 gives 0x234, is a trick to get y only
    ;using the extra features look like
    ;view-resizeable "resize-window demo" [9x9 10x10][request/confirm "boo! really quit me?"] 
    ;and the layout-function func [EXTRA-SPACE DIFF-SPACE OLD-FACE]

    windows: copy [] ;for windows-list

    ;---FRESH FACE, BASE OF DEMO
    context [t1: s1: tes: tds: f1: none
        new: view-resizeable/new "FRESH face, resize-window demo" 'layout-size true
        ;and the layout-function
        func [EXTRA-SPACE] [
            layout [
                across
                text "extra-space" text mold extra-space
                f1: field copy "enter something then resize"
                return
                t1: area EXTRA-SPACE + 300x240 para [] my-text
                s1: slider EXTRA-SPACE * 0x1 + 16x240 [scroll-para t1 s1]
            ]
        ]
        append windows new/window-layout
    ]

    ;---REUSED FACE
    context [t1: s1: tes: tds: f1: none
        new: view-resizeable/new "REUSED face, resize-window demo" 'layout-size true
        ;and the layout-function
        func [EXTRA-SPACE DIFF-SPACE OLD-FACE] [
            either OLD-FACE [
                t1/size: t1/size + diff-space
                s1/offset: 1x0 * diff-space + s1/offset
                s1/size: 0x1 * diff-space + s1/size
            ] [
                old-face: layout [
                    across
                    ;texts have to be fixed size now
                    text "extra-space" tes: text 50 text "diff-space" tds: text 50
                    f1: field copy "enter something then resize"
                    return
                    ;extra-space is 0x0-dummi, just to show using the original layout 
                    t1: area EXTRA-SPACE + 450x240 para [] my-text
                    s1: slider EXTRA-SPACE * 0x1 + 0x1 + 16x240 [scroll-para t1 s1]
                ]
            ]
            tes/text: mold extra-space tds/text: mold diff-space
            ;auto-shows in view-resizable
            old-face
        ]
        append windows new/window-layout
    ]

    ;---COPY DATA, FRESH FACE
    context [t1: s1: tes: tds: f1: none
        new: view-resizeable/new "COPY DATA, fresh face, resize-window demo" 'layout-size true
        ;and the layout-function
        func [EXTRA-SPACE dummi OLD-FACE /local lay] [
            lay: layout [
                across
                text "extra-space" text mold extra-space
                f1: field EITHER OLD-FACE [old-face/data/f1/text] [copy "enter something then resize"]
                return
                t1: area EXTRA-SPACE + 300x240 para []
                EITHER OLD-FACE [old-face/data/t1/text] [copy my-text]
                s1: slider EXTRA-SPACE * 0x1 + 16x240 [scroll-para t1 s1]
            ]
            lay/data: self
            lay
        ]
        append windows new/window-layout
    ]

    ;---DEMO-STUFF
    little-window-list:
    layout [
        title {resize the windows}
        across button "quit" [quit]
        mem-watch: field green rate 1 feel [
            engage: func [face a e] [face/text: reform [system/stats / 1024 "KB"] show face]]
        with [append init [size: size * 3x1 / 5x1]]
        below
        tl: text-list 200x50 "resize by fresh face" "resize by reusing face" "copy data, fresh face" [
            ;wild experimental hacking to get this running..
            to-front: pick windows index? find tl/data tl/picked
            unview/only to-front
            old-detect: get in to-front/feel 'detect
            view/new/options to-front [resize]
            to-front/feel/detect: func copy third :old-detect copy/deep second :old-detect
        ]
        text "sometimes resize breaks by this. rebol-bug? but not meant for real use anyway." tl/size/x
    ]

    view-resizeable/new/no-center "window list" 'layout-size [quit]
    func [extra-space] [
        little-window-list/size: little-window-list/size - extra-space little-window-list
    ] 

    ;do %x-nonlocal.r nologlo;check if /locals are ok

    do-events
]

;
