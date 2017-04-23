REBOL [
    Title:   "Linked Layout Demo"
    File:    %linked-layouts.r
    Author:  "Gregg Irwin"
    EMail:   greggirwin@acm.org
    Version: 0.0.1
    Date:    11-Oct-2003
    Purpose: {
        Shows how to "link" layouts so when a main window moves, the
        others stay in the same relative position to it.
    }
    library: [
        level:    'intermediate
        platform: 'all
        type:     [how-to]
        domain:   [UI]
        tested-under: [view/pro 1.2.8.3.1 on W2K]
        support:  none
        license:  'public-domain
        see-also: none
    ]
]

; We need to set title to "" or REBOL will put it on the seconary
; windows--those with no title bar--as text. We need a title in 
; the header for the library though.
system/script/title: ""

moved: true


evt-func: func [face event][
    if event/face = main-lay [
        ;if event/type <> 'time [print event/type]
        switch event/type [
            close  [shutdown]
            offset [moved: true]
            resize [moved: true]
            time [
                if moved [
                    ; The -4x4 offset accounts for REBOL *not* accounting for
                    ; border widths.
                    lay-2/offset: -4x4 + main-lay/offset + to pair! reduce [0 main-lay/size/y]
                    lay-3/offset: -4x4 + main-lay/offset + to pair! reduce [
                        main-lay/size/x - lay-3/size/x main-lay/size/y
                    ]
                    lay-2/changes: lay-3/changes: 'offset
                    show [lay-2 lay-3]
                    moved: false
                ]
            ]
        ]
    ]
    event
]

if not find system/view/screen-face/feel/event-funcs :evt-func [
    insert-event-func :evt-func
]

shutdown: does [unview/all]

main-lay: layout [
    size 400x100
    timer: sensor rate 0:0:1
]
lay-2: layout [size 150x200]
lay-3: layout [size 200x150]

view/new/options/offset main-lay [no-border resize] 100x100
view/new/options/offset lay-2 [no-title no-border resize] 100x200
view/new/options/offset lay-3 [no-title no-border resize] 300x200

do-events

quit