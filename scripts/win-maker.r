REBOL [
    Title: "Window maker"
    Date: 21-Aug-2001/13:32:30+2:00
    Version: 0.1.0
    File: %win-maker.r
    Author: "oldes"
    Usage: {
wm: make object! load %win-maker.r
wm/add-title/and-view layout [at 0x0 button "wow"] "test"
}
    Purpose: {Adds title with any buttons to any face (useful for windows without standard system title)}
    History: [
        15-Aug-2001 ["oldes" ["Extracted from %title-maker.r"]]
    ]
    Email: oldes@bigfoot.com
    library: [
        level: 'advanced 
        platform: none 
        type: 'tool 
        domain: 'GUI 
        tested-under: none 
        support: none 
        license: none 
        see-also: none
    ]
]

wincolor:   117.150.130
titlecolor: 99.113.107
winedge:    make object! [size: 1x1 color: 0.0.0 image: none effect: none]
titlesize:  0x13

iconImg: load read-thru http://sweb.cz/r-mud/imgz/icons12/rebapp.gif

make-button: func[str akce /offset ofs /local b st][
    if not offset [ofs: 0x0]
    layout [
        b: button str akce with [
            offset: 0x0
            font: make font [align: 'center valign: 'top offset: 0x0 size: 11 style: 'bold color: 235.250.240 colors: [235.250.240 255.255.10] name: 'arial shadow: 1x1]
            para: make object! [origin: 0x0 margin: 0x0 indent: 0x-3]
            
        ]
    ]
    st: size-text b
    b/edge/size: 1x1
    b/size/x: max st/x + 6 12
    b/size/y: 12
    b/effects: none
    b/color: 117.150.130
    ;b/image: GetButtImage st/x
    b/effect: [key 255.255.255]
    return b
]
empty-face:  make face [
    size: 0x0
    color: none
    pane: []
    edge: none
] 
GetButtonsFace: func[buts size /local butsf b][
    butsf: make empty-face [size: 1x12]
    foreach [n a] buts [
        b: make-button n a
        b/offset/x: butsf/size/x
        b/offset/y: 0
        butsf/size/x: butsf/size/x + b/size/x 
        append butsf/pane b
    ]
    butsf/size/x: butsf/size/x
    butsf/offset/x: size/x - butsf/size/x + 1
    butsf/offset/y: 2
    butsf
]

add-title: func[
    to-face
    name
    /and-view   "forces to view the titled face"
    /local f
][
    f: make face compose [
        size:  (to-face/size + to-face/offset + titlesize + ( 2 * winedge/size ) + 1x2)
        color: (wincolor)
        edge:  (winedge )
        pane:  [title none dragger none buttons none  content none ]
        minimized?: false
        minimize-on-drag?: on
        dragable?: true
        minimize: func[/state s][
            if not state [s: not minimized?]
            either s [
                if not minimized? [
                user-data: size
                size/y: 15
                minimized?: true
                show self
                ]
            ][  if minimized? [
                size/y: user-data/y 
                minimized?: false
                show self
                ]
            ]
        ]
    ]
    
    realtitlesize: to-pair reduce [f/size/x - (2 * winedge/size/x ) titlesize/y]
    f/pane/dragger: make face compose [
        edge: none color: none
        size: (realtitlesize)
        offset: (winedge/size)
        feel: make feel [
            engage: func [f a e][
                if a = 'down [
                    mouse-pos: e/offset
                    if f/parent-face/minimize-on-drag? [f/parent-face/minimize/state on]
                ]
                if a = 'up [if f/parent-face/minimize-on-drag? [f/parent-face/minimize/state off]]
                if find [over away] a [
                    if f/parent-face/dragable? = true [
                        f/parent-face/offset: f/parent-face/offset + (e/offset - mouse-pos)
                        show f/parent-face
                    ]
                ]
            ]
        ]
    ]
    f/pane/title: make face compose [
        edge:  make edge [size: 1x1 color: 0.0.0]
        color: (titlecolor)
        size:  (realtitlesize)
        offset: (winedge/size)
        pane: (make layout compose [
            origin 0x0
            at 0x0 box (realtitlesize + 2) with [
                edge: make edge [size: 2x2 color: titlecolor - 15 ] color: none
            ]
            at 0x0 box (realtitlesize + 1) with [
                edge: make edge [size: 1x1 color: titlecolor - 30 ] color: none
            ]
            at 0x-1 image (iconImg)
            at (to-pair reduce [ iconImg/size/x + 2 0 ])
            t: title (name) with [
                font: make font [align: 'left valign: 'top offset: 0x0 size: 11 style: 'bold color: 235.250.240 name: 'arial shadow: 2x2]
                para: make object! [origin: 0x0 margin: 0x0 indent: 0x-2]
            ]
        ][
            size: (realtitlesize)
            offset: 0x0 color: none
        ])
    ]
    
    f/pane/buttons: GetButtonsFace ["m" [face/parent-face/parent-face/minimize] "x" [unview]] realtitlesize
    
    f/pane/content: make face compose [
        edge: make edge [size: 1x1 color: 0.0.0] 
        size: (to-face/size + to-face/offset + (winedge/size ))
        offset: (to-pair reduce [1 titlesize/y + 2])
        pane: (to-face)
    ]
    either and-view [
        view/options center-face f [no-title no-border]
    ][ f ]
]
                                                                                                                                                                 